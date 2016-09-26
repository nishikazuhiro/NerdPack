NeP.OM = {
	unitEnemie = {},
	unitFriend = {},
	GameObjects = {},
	DeadUnits = {}
}

local F = NeP.Interface.fetchKey
local bDebuff = NeP.BlacklistedDebuffs

local function InsertToOM(tableName, Obj, distance)
	local GUID = UnitGUID(Obj) or '0'
	local objectType, _, _, _, _, ObjID, _ = strsplit('-', GUID)
	local ObjID = tonumber(ObjID) or '0'
	table.insert(NeP.OM[tableName], {
		key = Obj,
		name = UnitName(Obj),
		distance = distance,
		id = ObjID,
		guid = GUID,
	})
end

function NeP.OM.addToOM(Obj)
	if not bDebuff(Obj) then
		local distance = NeP.Engine.Distance('player', Obj)
		if distance < F('NePSettings', 'OM_MaxDis', 100) then
			-- Dead Units
			if UnitIsDeadOrGhost(Obj) then
				InsertToOM('DeadUnits', Obj, distance)
			-- Friendly
			elseif UnitIsFriend('player', Obj) then
				InsertToOM('unitFriend', Obj, distance)
			-- Enemie
			elseif UnitCanAttack('player', Obj) then
				InsertToOM('unitEnemie', Obj, distance)
			-- Object
			elseif ObjectWithIndex and ObjectIsType(Obj, ObjectTypes.GameObject) then
				InsertToOM('GameObjects', Obj, distance)
			end
		end
	end
end

local lnr = LibStub("AceAddon-3.0"):NewAddon("NerdPack", "LibNameplateRegistry-1.0")
local ValidUnits = {'player', 'mouseover', 'target', 'arena1', 'arena2'}
local Nameplates = {}
	
function lnr:OnEnable()
	self:LNR_RegisterCallback("LNR_ON_NEW_PLATE")
	self:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE")
end

function lnr:LNR_ON_NEW_PLATE(_, _, plateData)
	local tK = plateData.unitToken
	Nameplates[tK] = tK
end

function lnr:LNR_ON_RECYCLE_PLATE(_, _, plateData)
	local tK = plateData.unitToken
	Nameplates[tK] = nil
end

local function GenericFilter(unit)
	if not UnitExists(unit) then return false end
	local table = UnitCanAttack('player', unit) and 'unitEnemie' or 'unitFriend'
	for i=1, #NeP.OM[table] do
		local Obj = NeP.OM[table][i]
		if Obj.guid == UnitGUID(unit) then
			return false
		end
	end
	return true	
end

function NeP.OM.Maker()
	-- If in Group scan frames...
	if IsInGroup() or IsInRaid() then
		local prefix = (IsInRaid() and 'raid') or 'party'
		for i = 1, GetNumGroupMembers() do
			-- Unit
			local friendly = prefix..i
			if GenericFilter(friendly) then
				NeP.OM.addToOM(friendly)
				-- Unit's Target
				local target = friendly..'target'
				if GenericFilter(target) then
					NeP.OM.addToOM(target)
				end
			end
		end
	end
	-- Valid Units
	for i=1, #ValidUnits do
		local object = ValidUnits[i]
		if GenericFilter(object) then
			NeP.OM.addToOM(object)
		end
	end
	-- Nameplate cache
	for k,_ in pairs(Nameplates) do
		local plate = Nameplates[k]
		if GenericFilter(plate) then
			NeP.OM.addToOM(plate)
		end
	end
end

-- Run OM
NeP.Timer.Sync("nep_OM", 0.5, function()
	wipe(NeP.OM.unitEnemie)
	wipe(NeP.OM.unitFriend)
	wipe(NeP.OM.GameObjects)
	wipe(NeP.OM.DeadUnits)
	NeP.OM.Maker()
	table.sort(NeP.OM.unitEnemie, function(a,b) return a.distance < b.distance end)
	table.sort(NeP.OM.unitFriend, function(a,b) return a.distance < b.distance end)
	table.sort(NeP.OM.GameObjects, function(a,b) return a.distance < b.distance end)
	table.sort(NeP.OM.DeadUnits, function(a,b) return a.distance < b.distance end)
end)