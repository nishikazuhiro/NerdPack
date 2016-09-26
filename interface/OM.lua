local Round = NeP.Core.Round
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

local function RefreshGUI()
	local offset = -5
	recycleStatusBars()
	for i=1,# NeP.OM[dOM] do
		local Obj =  NeP.OM[dOM][i]
		local Health = UnitHealth(Obj.key) and math.floor((UnitHealth(Obj.key) / UnitHealthMax(Obj.key)) * 100) or 100
		local statusBar = getStatusBar()
		statusBar.frame:SetPoint('TOP', ListWindow.content, 'TOP', 2, offset )
		statusBar.frame.Left:SetText('|cff'..NeP.Core.classColor(Obj.key)..Obj.name)
		statusBar.frame.Right:SetText('( |cffff0000ID|r: '..Obj.id..' / |cffff0000Health|r: '..Health..' / |cffff0000Dist|r: '..Round(Obj.distance)..' )')
		statusBar.frame:SetScript('OnMouseDown', function(self) TargetUnit(Obj.key) end)
		statusBar:SetValue(Health)
		offset = offset -18
	end
	bt['ENEMIE']:SetText('ENEMIE ('..#NeP.OM['unitEnemie']..')')
	bt['FRIENDLY']:SetText('FRIENDLY ('..#NeP.OM['unitFriend']..')')
	bt['OBJECTS']:SetText('OBJECTS ('..#NeP.OM['GameObjects']..')')
end

C_Timer.NewTicker(0.1, (function()
	if NeP.OM.List:IsShown() then 
		RefreshGUI()
	end
end), nil)