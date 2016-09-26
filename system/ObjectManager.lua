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