NeP.OM = {
	unitEnemie = {},
	unitFriend = {},
	GameObjects = {},
	DeadUnits = {}
}

local Round = NeP.Core.Round

--[[
	DESC: Places the object in its correct place.
	This is done in a seperate function so we dont have
	to repeate code over and over again for all unlockers.
---------------------------------------------------]]
local function InsertToOM(tableName, Obj, GUID, ObjID, distance)
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
	if not NeP.BlacklistedDebuffs(Obj) then
		local distance = NeP.Engine.Distance('player', Obj)
		if distance < NeP.Interface.fetchKey('NePSettings', 'OM_MaxDis', 100) then
			-- Dead Units
			if UnitIsDeadOrGhost(Obj) then
				InsertToOM('DeadUnits', Obj, GUID, ObjID, distance)
			-- Friendly
			elseif UnitIsFriend('player', Obj) then
				InsertToOM('unitFriend', Obj, GUID, ObjID, distance)
			-- Enemie
			elseif UnitCanAttack('player', Obj) then
				InsertToOM('unitEnemie', Obj, GUID, ObjID, distance)
			-- Object
			elseif ObjectWithIndex and ObjectIsType(Obj, ObjectTypes.GameObject) then
				InsertToOM('GameObjects', Obj, GUID, ObjID, distance)
			end
		end
	end
end

local DiesalGUI = LibStub('DiesalGUI-1.0')

local statusBars = {}
local statusBarsUsed = {}

NeP.OM.List = DiesalGUI:Create('Window')
local OMListGUI = NeP.OM.List
OMListGUI.frame:SetSize(500, 250)
OMListGUI.frame:SetMinResize(500, 250)
OMListGUI:SetTitle('ObjectManager GUI')
OMListGUI.frame:SetClampedToScreen(true)
OMListGUI:SetEventListener('OnDragStop', function(self, event, left, top)
	NeP.Config.Write('OML_window', {left, top})
end)

NeP.Config.WhenLoaded(function()
	local left, top = unpack(NeP.Config.Read('OML_window', {false, false}))
	if left and top then
		OMListGUI.settings.left = left
		OMListGUI.settings.top = top
		OMListGUI:UpdatePosition()
	end
end)

OMListGUI:Hide()
local dOM = 'unitEnemie'
local bt = {
	['ENEMIE'] = {a = 'TOPLEFT', b = 'unitEnemie'},
	['FRIENDLY'] = {a = 'TOP', b = 'unitFriend'},
	['OBJECTS'] = {a = 'TOPRIGHT', b = 'GameObjects'}
}

for k,v in pairs(bt) do
	bt[k] = DiesalGUI:Create("Button")
	OMListGUI:AddChild(bt1)
	bt[k]:SetParent(OMListGUI.content)
	bt[k]:SetPoint(v.a, OMListGUI.content, v.a, 0, 0)
	bt[k].frame:SetSize(OMListGUI.content:GetWidth()/3, 30)
	bt[k]:AddStyleSheet(NeP.buttonStyleSheet)
	bt[k]:SetEventListener("OnClick", function() dOM = v.b end)
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

local function WipeOM()
	wipe(NeP.OM['unitEnemie'])
	wipe(NeP.OM['unitFriend'])
	wipe(NeP.OM['GameObjects'])
	wipe(NeP.OM['DeadUnits'])
end

NeP.Listener.register('OM', "PLAYER_ENTERING_WORLD", function(...)
	WipeOM()
end)

-- Run OM
NeP.Timer.Sync("nep_OM", 0.25, function()
	WipeOM()
	if NeP.OM.Maker then
		NeP.OM.Maker()
		table.sort(NeP.OM['unitEnemie'], function(a,b) return a.distance < b.distance end)
		table.sort(NeP.OM['unitFriend'], function(a,b) return a.distance < b.distance end)
		table.sort(NeP.OM['GameObjects'], function(a,b) return a.distance < b.distance end)
		table.sort(NeP.OM['DeadUnits'], function(a,b) return a.distance < b.distance end)
	end
	-- UPDATE GUI
	if NeP.OM.List:IsShown() then 
		local offset = -5
		recycleStatusBars()
		for i=1,# NeP.OM[dOM] do
			local Obj =  NeP.OM[dOM][i]
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
		bt['ENEMIE']:SetText('ENEMIE ('..#NeP.OM['unitEnemie']..')')
		bt['FRIENDLY']:SetText('FRIENDLY ('..#NeP.OM['unitFriend']..')')
		bt['OBJECTS']:SetText('OBJECTS ('..#NeP.OM['GameObjects']..')')
	end
end)