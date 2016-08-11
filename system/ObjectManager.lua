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
		local distance = NeP.Engine.Distance('player', Obj)
		-- Friendly
		if UnitIsFriend('player', Obj) then
			NeP.OM.unitFriend[#NeP.OM.unitFriend+1] = {
				key = Obj,
				name = UnitName(Obj),
				class = Classifications[UnitClassification(Obj)],
				distance = distance,
				is = 'friendly',
				id = ObjID,
				guid = GUID,
			}
		-- Enemie
		elseif UnitCanAttack('player', Obj) then
			NeP.OM.unitEnemie[#NeP.OM.unitEnemie+1] = {
				key = Obj,
				name = UnitName(Obj),
				class = Classifications[UnitClassification(Obj)],
				distance = distance,
				is = isDummy(Obj) and 'dummy' or 'enemie',
				id = ObjID,
				guid = GUID,
			}
		-- Object
		elseif ObjectWithIndex and ObjectIsType(Obj, ObjectTypes.GameObject) then
			NeP.OM.GameObjects[#NeP.OM.GameObjects+1] = {
				key = Obj,
				name = UnitName(Obj) or '',
				distance = distance,
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

local buttonStyleSheet = {
	['frame-color'] = {	
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '2f353b',
		offset		= 0,	
	},
	['frame-highlight'] = {
		type		= 'texture',
		layer		= 'BORDER',
		gradient	= 'VERTICAL',					
		color		= 'FFFFFF',
		alpha 		= 0,
		alphaEnd	= .1,
		offset		= -1,
	},	
	['frame-outline'] = {
		type		= 'outline',
		layer		= 'BORDER',			
		color		= '000000',
		offset		= 0,		
	},	
	['frame-inline'] = {		
		type		= 'outline',
		layer		= 'BORDER',
		gradient	= 'VERTICAL',
		color		= 'ffffff',
		alpha 		= .02,
		alphaEnd	= .09,
		offset		= -1,
	},
	['frame-hover'] = {
		type		= 'texture',
		layer		= 'HIGHLIGHT',
		color		= 'ffffff',
		alpha		= .1,
		offset		= 0,
	},
	['text-color'] = {
		type		= 'Font',
		color		= 'b8c2cc',
	},
}

local statusBars = {}
local statusBarsUsed = {}
local tOM = NeP.OM.unitEnemie

NeP.OM.List = DiesalGUI:Create('Window')
local OMListGUI = NeP.OM.List
OMListGUI.frame:SetSize(500, 250)
OMListGUI.frame:SetMinResize(500, 250)
OMListGUI:SetTitle('ObjectManager GUI')
OMListGUI.frame:SetClampedToScreen(true)
OMListGUI:SetEventListener('OnDragStop', function(self, event, left, top)
	NeP.Config.Write('OML_window', {left, top})
end)

function NeP.Config.CreateOMFrame(  )
	local left, top = unpack(NeP.Config.Read('OML_window', {false, false}))
	if left and top then
		OMListGUI.settings.left = left
		OMListGUI.settings.top = top
		OMListGUI:UpdatePosition()
	end
end

OMListGUI:Hide()

local bt = {
	['ENEMIE'] = {a = 'TOPLEFT', b = NeP.OM.unitEnemie},
	['FRIENDLY'] = {a = 'TOP', b = NeP.OM.unitFriend},
	['OBJECTS'] = {a = 'TOPRIGHT', b = NeP.OM.GameObjects}
}

for k,v in pairs(bt) do
	bt[k] = DiesalGUI:Create("Button")
	OMListGUI:AddChild(bt1)
	bt[k]:SetParent(OMListGUI.content)
	bt[k]:SetPoint(v.a, OMListGUI.content, v.a, 0, 0)
	bt[k].frame:SetSize(OMListGUI.content:GetWidth()/3, 30)
	bt[k]:AddStyleSheet(buttonStyleSheet)
	bt[k]:SetEventListener("OnClick", function() tOM = v.b end)
end

local ListWindow = DiesalGUI:Create('ScrollFrame')
OMListGUI:AddChild(ListWindow)
ListWindow:SetParent(OMListGUI.content)
ListWindow:SetPoint("TOP", OMListGUI.content, "TOP", 0, -30)
ListWindow.frame:SetSize(OMListGUI.content:GetWidth(), OMListGUI.content:GetHeight()-30)
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
	local offset = -5
	recycleStatusBars()
	for i=1,#tOM do
		local Obj = tOM[i]
		local ID = Obj.id or ''
		local Name = Obj.name or ''
		local Distance = Obj.distance or ''
		local maxHealth = UnitHealthMax(Obj.key) or 1
		local rawHealth = UnitHealth(Obj.key) or 1
		local Health = math.floor((rawHealth / maxHealth) * 100)
		local classColor = NeP.Core.classColor(Obj.key)
		local statusBar = getStatusBar()
		statusBar.frame:SetPoint('TOP', ListWindow.content, 'TOP', 2, offset )
		statusBar.frame.Left:SetText('|cff'..classColor..Name)
		statusBar.frame.Right:SetText('( |cffff0000ID|r: '..ID..' / |cffff0000Health|r: '..Health..' / |cffff0000Dist|r: '..Round(Distance)..' )')
		statusBar.frame:SetScript('OnMouseDown', function(self) TargetUnit(Obj.key) end)
		statusBar:SetValue(Health)
		offset = offset -18
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
	-- UPDATE GUI
	if NeP.OM.List:IsShown() then 
		RefreshGUI()
		bt['ENEMIE']:SetText('ENEMIE ('..#NeP.OM.unitEnemie..')')
		bt['FRIENDLY']:SetText('FRIENDLY ('..#NeP.OM.unitFriend..')')
		bt['OBJECTS']:SetText('OBJECTS ('..#NeP.OM.GameObjects..')')
	end
end), nil)