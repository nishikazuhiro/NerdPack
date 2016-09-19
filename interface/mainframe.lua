local Intf = NeP.Interface
local addonColor = '|cff'..Intf.addonColor
local Tittle = addonColor..NeP.Info.Name
local Logo = '|T'..Intf.Logo..':15:15|t'
local Config = NeP.Config
local Round = NeP.Core.Round
local F = NeP.Interface.fetchKey
local TA = NeP.Core.TA

Intf.Extras = {}
Intf.buttonSize = 40
Intf.buttonPadding = 2
Intf.ClassSettings = nil

local function hasAnyTalent()
	for row=1, 7 do
		for col=1,3 do
			if hasTalent(row, col) then
				return true
			end
		end
	end
	return false
end

local function specInfo()
	local Spec = GetSpecialization()
	local localizedClass, englishClass, classIndex = UnitClass('player')
	local SpecInfo = classIndex
	if Spec and hasAnyTalent() then
		SpecInfo = GetSpecializationInfo(Spec)
	else
		SpecInfo = classIndex
	end
	return SpecInfo
end 

local function GetSpecTables()
	local SpecInfo = specInfo()
	if NeP.Engine.Rotations[SpecInfo] then
		return NeP.Engine.Rotations[SpecInfo]
	end
end

local fakeCR =  { 
	[true] = {},
	[false] = {},
	['InitFunc'] = (function() return end),
	['Name'] = 'NONE'
}
function Intf.GetSelectedCR()
	local SpecInfo = specInfo()
	local Selected = NeP.Config.Read('NeP_SlctdCR_'..SpecInfo)
	return GetSpecTables()[Selected] or fakeCR
end

local function updateSpec()
	local SlctdCR = Intf.GetSelectedCR()
	NeP.Interface.ResetToggles()
	if SlctdCR then 
		SlctdCR.InitFunc()
		Intf.AddClassSettings(SlctdCR.Name, SlctdCR.SpecConfig)
	end
end

function Intf.Add(name, func)
	table.insert(Intf.Extras, {
		text = tostring(name),
		func = func,
		notCheckable = 1
	})
end

function Intf.AddClassSettings(name, _SpecConfig)
	if _SpecConfig then
		NeP.Interface.buildGUI(_SpecConfig)
		Intf.ClassSettings = {
			text = '|cff'..NeP.Core.classColor('player')..'Class Settings', 
			func = function() NeP.Interface.ShowGUI(name) end, 
			notCheckable = 1
		}
	else
		Intf.ClassSettings = nil
	end
end

-- Wait until saved vars are loaded
NeP.Config.WhenLoaded(function()

	-- Read Saved Frame Position
	local POS_1 = Config.Read('NePFrame_POS_1', 'CENTER')
	local POS_2 = Config.Read('NePFrame_POS_2', 0)
	local POS_3 = Config.Read('NePFrame_POS_3', 0)

	-- Update size
	local NeP_Size = F('NePSettings', 'tSize', 40)
	if NeP_Size < 25 then NeP_Size = 40 end
	Intf.buttonSize = NeP_Size

	--parent frame
	NePFrame = CreateFrame("Frame", "NePFrame", UIParent)
	NePFrame:SetPoint(POS_1, POS_2, POS_3)
	NePFrame:SetMovable(true)
	NePFrame:SetFrameLevel(0)
	NePFrame:SetFrameStrata('HIGH')
	NePFrame:SetClampedToScreen(true)
	NePFrame:SetSize(#Intf.Buttons*Intf.buttonSize, Intf.buttonSize)

	NePFrame.menuFrame = CreateFrame("Frame", "ExampleMenuFrame", NePFrame, "UIDropDownMenuTemplate")
	NePFrame.menuFrame:Hide();

	NePFrame.NePfDrag = CreateFrame("Frame", 'MOVENEP', NePFrame)
	NePFrame.NePfDrag:SetPoint('Right', NePFrame)
	NePFrame.NePfDrag:SetFrameLevel(2)
	NePFrame.NePfDrag:EnableMouse(true)
	local statusText = NePFrame.NePfDrag:CreateFontString('PE_StatusText')
	statusText:SetFont("Fonts\\ARIALN.TTF", 16)
	statusText:SetShadowColor(0,0,0, 0.8)
	statusText:SetShadowOffset(-1,-1)
	statusText:SetPoint("CENTER", NePFrame.NePfDrag)
	statusText:SetText("|cffffffff"..TA('mainframe', 'WhileDrag').."|r")
	local texture = NePFrame.NePfDrag:CreateTexture()
	texture:SetAllPoints(NePFrame.NePfDrag)
	texture:SetColorTexture(0,0,0,0.9)
	NePFrame.NePfDrag:SetSize((#Intf.Buttons-1)*Intf.buttonSize+(Intf.buttonPadding*#Intf.Buttons), Intf.buttonSize)
	NePFrame.NePfDrag:RegisterForDrag('LeftButton', 'RightButton')
	NePFrame.NePfDrag:SetScript('OnDragStart', function() NePFrame:StartMoving() end)
	NePFrame.NePfDrag:SetScript('OnDragStop', function(self)
		local from, _, to, x, y = NePFrame:GetPoint()
		NePFrame:StopMovingOrSizing()
		Config.Write('NePFrame_POS_1', from)
		Config.Write('NePFrame_POS_2', x)
		Config.Write('NePFrame_POS_3', y)
		NePFrame.NePfDrag:Hide()
		NeP.Core.Print(TA('mainframe', 'AfterDrag'))
	end)
	NePFrame.NePfDrag:Hide()

	-- Show on 1st run
	if not Config.Read('NePranOnce', false) then
		NePFrame.NePfDrag:Show()
		Config.Write('NePranOnce', true)
	end

end)

local DropMenu = {}
local DropMenu_Add = {
	{ text = "Extra Settings:", notCheckable = 1, hasArrow = true, menuList = Intf.Extras },
	{ text = TA('mainframe', 'OM'), notCheckable = 1, func = function() NeP.OM.List:Show() end },
	{ text = TA('mainframe', 'AL'), notCheckable = 1, func = function() PE_ActionLog:Show() end },
	{ text = TA('mainframe', 'Forum'), notCheckable = 1, func = function() OpenPage('http://nerdpackaddon.site/index.php/forum/index') end},
	{ text = TA('mainframe', 'Donate'), notCheckable = 1, func = function() OpenPage('http://goo.gl/yrctPO') end },
	{ text = TA('mainframe', 'HideNeP'), notCheckable = 1, func = function() NePFrame:Hide(); NeP.Core.Print(TA('Any', 'NeP_Show')) end },
	{ text = addonColor..NeP.Info.Name..' |r'..TA('mainframe', 'Settings'), notCheckable = 1, func = function() NeP.Interface.ShowGUI('NeP_Settings') end },
}

function Intf.CreateDropMenu()
	wipe(DropMenu)
	-- title
	table.insert(DropMenu, {text = Logo..'['..Tittle..' |rv:'..NeP.Info.Version..' - '..NeP.Info.Branch..']', isTitle = 1, notCheckable = 1})
	-- Routines
	local routinesTable = GetSpecTables()
	if routinesTable then
		local lastCR = Intf.GetSelectedCR().Name
		local SpecInfo = specInfo()
		for k,v in pairs(routinesTable) do
			table.insert(DropMenu, {
				text = v.Name,
				checked = (lastCR == v.Name) or false,
				func = function(self)
					NeP.Core.Print(TA('mainframe', 'ChangeCR')..' ( '..v['Name']..' )')
					Config.Write('NeP_SlctdCR_'..(SpecInfo), k)
					updateSpec()
				end
			})
		end
		if Intf.ClassSettings then table.insert(DropMenu, Intf.ClassSettings) end
	else
		table.insert(DropMenu, {text = TA('mainframe', 'NoCR'), notCheckable = 1})
	end
	-- Rest
	for i=1, #DropMenu_Add do
		table.insert(DropMenu, DropMenu_Add[i])
	end
	EasyMenu(DropMenu, NePFrame.menuFrame, "cursor", 0, 0, "MENU");
end

NeP.Listener.register("PLAYER_LOGIN", function(...)
	updateSpec()
	NeP.Listener.register("PLAYER_SPECIALIZATION_CHANGED", function(unitID)
		if unitID == 'player' then
			updateSpec()
		end
	end)
end)