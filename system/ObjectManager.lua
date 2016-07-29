NeP.OM = {
	unitEnemie = {},
	unitFriend = {},
	GameObjects = {},
}

NeP.Listener.register('OM', "PLAYER_ENTERING_WORLD", function(...)
	wipe(NeP.OM.unitEnemie)
	wipe(NeP.OM.unitFriend)
	wipe(NeP.OM.GameObjects)
end)

local Round = NeP.Core.Round
local Classifications = {
	['minus'] 		= 1,
	['normal'] 		= 2,
	['elite' ]		= 3,
	['rare'] 		= 4,
	['rareelite' ]	= 5,
	['worldboss' ]	= 6,
}

--[[
	DESC: Checks if unit has a Blacklisted Debuff.
	This will remove the unit from the OM cache.
---------------------------------------------------]]
local BlacklistedAuras = {
		-- CROWD CONTROL
	[118] = '',        -- Polymorph
	[1513] = '',       -- Scare Beast
	[1776] = '',       -- Gouge
	[2637] = '',       -- Hibernate
	[3355] = '',       -- Freezing Trap
	[6770] = '',       -- Sap
	[9484] = '',       -- Shackle Undead
	[19386] = '',      -- Wyvern Sting
	[20066] = '',      -- Repentance
	[28271] = '',      -- Polymorph (turtle)
	[28272] = '',      -- Polymorph (pig)
	[49203] = '',      -- Hungering Cold
	[51514] = '',      -- Hex
	[61305] = '',      -- Polymorph (black cat)
	[61721] = '',      -- Polymorph (rabbit)
	[61780] = '',      -- Polymorph (turkey)
	[76780] = '',      -- Bind Elemental
	[82676] = '',      -- Ring of Frost
	[90337] = '',      -- Bad Manner (Monkey) -- FIXME: to check
	[115078] = '',     -- Paralysis
	[115268] = '',     -- Mesmerize
		-- MOP DUNGEONS/RAIDS/ELITES
	[106062] = '',     -- Water Bubble (Wise Mari)
	[110945] = '',     -- Charging Soul (Gu Cloudstrike)
	[116994] = '',     -- Unstable Energy (Elegon)
	[122540] = '',     -- Amber Carapace (Amber Monstrosity - Heat of Fear)
	[123250] = '',     -- Protect (Lei Shi)
	[143574] = '',     -- Swelling Corruption (Immerseus)
	[143593] = '',     -- Defensive Stance (General Nazgrim)
		-- WOD DUNGEONS/RAIDS/ELITES
	[155176] = '',     -- Damage Shield (Primal Elementalists - Blast Furnace)
	[155185] = '',     -- Cotainment (Primal Elementalists - BRF)
	[155233] = '',     -- Dormant (Blast Furnace)
	[155265] = '',     -- Cotainment (Primal Elementalists - BRF)
	[155266] = '',     -- Cotainment (Primal Elementalists - BRF)
	[155267] = '',     -- Cotainment (Primal Elementalists - BRF)
	[157289] = '',     -- Arcane Protection (Imperator Mar'Gok)
	[174057] = '',     -- Arcane Protection (Imperator Mar'Gok)
	[182055] = '',     -- Full Charge (Iron Reaver)
	[184053] = '',     -- Fel Barrier (Socrethar)
}

local function BlacklistedDebuffs(Obj)
	for i = 1, 40 do
		local spellID = select(11, UnitDebuff(Obj, i))
		if spellID and BlacklistedAuras[tonumber(spellID)] then
			return true
		end
	end
	return false
end

--[[
	DESC: Checks if Object is a Blacklisted.
	This will remove the Object from the OM cache.
---------------------------------------------------]]
local BlacklistedObjects = {
	[76829] = '',		-- Slag Elemental (BrF - Blast Furnace)
	[78463] = '',		-- Slag Elemental (BrF - Blast Furnace)
	[60197] = '',		-- Scarlet Monastery Dummy
	[64446] = '',		-- Scarlet Monastery Dummy
	[93391] = '',		-- Captured Prisoner (HFC)
	[93392] = '',		-- Captured Prisoner (HFC)
	[93828] = '',		-- Training Dummy (HFC)
	[234021] = '',
	[234022] = '',
	[234023] = '',
}

local function BlacklistedObject(ObjID)
	return BlacklistedObjects[tonumber(ObjID)] ~= nil
end

--[[
	DESC: Places the object in its correct place.
	This is done in a seperate function so we dont have
	to repeate code over and over again for all unlockers.
---------------------------------------------------]]
function NeP.OM.addToOM(Obj)
	local GUID = UnitGUID(Obj) or '0'
	local objectType, _, _, _, _, ObjID, _ = strsplit('-', GUID)
	local ObjID = tonumber(ObjID) or '0'
	if not BlacklistedObject(ObjID) and not BlacklistedDebuffs(Obj) then
		local maxHealth = UnitHealthMax(Obj) or 1
		local rawHealth = UnitHealth(Obj) or 1
		local health = math.floor((rawHealth / maxHealth) * 100)
		-- Friendly
		if UnitIsFriend('player', Obj) and UnitHealth(Obj) > 0 then
			NeP.OM.unitFriend[#NeP.OM.unitFriend+1] = {
				key = Obj,
				name = UnitName(Obj),
				class = Classifications[tostring(UnitClassification(Obj))],
				distance = NeP.Engine.Distance('player', Obj),
				is = 'friendly',
				id = ObjID,
				guid = GUID,
				health = health,
				maxHealth = maxHealth,
				actualHealth = rawHealth
			}
		-- Enemie
		elseif UnitCanAttack('player', Obj) and UnitHealth(Obj) > 0 then
			NeP.OM.unitEnemie[#NeP.OM.unitEnemie+1] = {
				key = Obj,
				name = UnitName(Obj),
				class = Classifications[tostring(UnitClassification(Obj))],
				distance = NeP.Engine.Distance('player', Obj),
				is = isDummy(Obj) and 'dummy' or 'enemie',
				id = ObjID,
				guid = GUID,
				health = health,
				maxHealth = maxHealth,
				actualHealth = rawHealth
			}
		-- Object
		elseif ObjectWithIndex and ObjectIsType(Obj, ObjectTypes.GameObject) then
			NeP.OM.GameObjects[#NeP.OM.GameObjects+1] = {
				key = Obj,
				name = UnitName(Obj) or '',
				distance = NeP.Engine.Distance('player', Obj),
				is = 'object',
				id = ObjID,
				guid = GUID
			}
		end
	end
end

local DiesalTools = LibStub('DiesalTools-1.0')
local DiesalStyle = LibStub('DiesalStyle-1.0')
local DiesalGUI = LibStub('DiesalGUI-1.0')
local DiesalMenu = LibStub('DiesalMenu-1.0')
local SharedMedia = LibStub('LibSharedMedia-3.0')

-- Tables to Control Status Bars Used
local statusBars = { }
local statusBarsUsed = { }

NeP.OM.List = DiesalGUI:Create('Window')
local OMListGUI = NeP.OM.List
OMListGUI:SetWidth(500)
OMListGUI:SetHeight(250)
OMListGUI:SetTitle('ObjectManager GUI')
OMListGUI.frame:SetClampedToScreen(true)
OMListGUI:Hide()

local ListWindow = DiesalGUI:Create('ScrollFrame')
OMListGUI:AddChild(ListWindow)
ListWindow:SetParent(OMListGUI.content)
ListWindow:SetAllPoints(OMListGUI.content)
ListWindow.OMListGUI = OMListGUI

local function getStatusBar()
	local statusBar = tremove(statusBars)
	if not statusBar then
		statusBar = DiesalGUI:Create('StatusBar')
		statusBar:SetParent(ListWindow.content)
		OMListGUI:AddChild(statusBar)
		statusBar.frame:SetStatusBarColor(1,1,1,0.35)
	end
	statusBar:Show()
	table.insert(statusBarsUsed, statusBar)
	return statusBar
end

local function recycleStatusBars()
	for i = #statusBarsUsed, 1, -1 do
		statusBarsUsed[i]:Hide()
		tinsert(statusBars, tremove(statusBarsUsed))
	end
end

local function RefreshGUI()
	local tempTable = {}

	-- Combine all tables..
	for i=1, #NeP.OM.unitEnemie do tempTable[#tempTable+1] = NeP.OM.unitEnemie[i] end
	for i=1, #NeP.OM.unitFriend do tempTable[#tempTable+1] = NeP.OM.unitFriend[i] end
	for i=1, #NeP.OM.GameObjects do tempTable[#tempTable+1] = NeP.OM.GameObjects[i] end
	table.sort(tempTable, function(a,b) return a.distance < b.distance end)

	local offset = -5
	recycleStatusBars()

	for i=1,#tempTable do
		local Obj = tempTable[i]
		local ID = Obj.id or ''
		local Name = Obj.name or ''
		local Distance = Obj.distance or ''
		local Health = Obj.health or 100
		local classColor = NeP.Core.classColor(Obj.key)
		local statusBar = getStatusBar()

		statusBar.frame:SetPoint('TOP', ListWindow.content, 'TOP', 2, offset )
		statusBar.frame.Left:SetText('|cff'..classColor..Name)
		statusBar.frame.Right:SetText('( |cffff0000ID|r: '..ID..' / |cffff0000Health|r: '..Health..' / |cffff0000Dist|r: '..Round(Distance)..' )')

		statusBar.frame:SetScript('OnMouseDown', function(self) TargetUnit(Obj.key) end)
		statusBar:SetValue(Health)
		offset = offset -17
	end
end

-- Run OM
C_Timer.NewTicker(0.25, (function()
	-- wait until added from unlocker.
	if NeP.OM.Maker then
		-- Wipe Cache
		wipe(NeP.OM.unitEnemie)
		wipe(NeP.OM.unitFriend)
		wipe(NeP.OM.GameObjects)

		-- Run OM depending on unlocker
		NeP.OM.Maker()
		-- Sort by distance
		table.sort(NeP.OM.unitEnemie, function(a,b) return a.distance < b.distance end)
		table.sort(NeP.OM.unitFriend, function(a,b) return a.distance < b.distance end)
		table.sort(NeP.OM.GameObjects, function(a,b) return a.distance < b.distance end)
	end
	if NeP.OM.List:IsShown() then RefreshGUI() end
end), nil)