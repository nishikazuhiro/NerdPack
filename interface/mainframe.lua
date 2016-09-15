NeP.MFrame = {
	buttonPadding = 2,
	buttonSize = 40,
	Buttons = {},
	usedButtons = {},
	Settings = {},
	Plugins = {},
}

local Intf = NeP.Interface
local addonColor = '|cff'..Intf.addonColor
local Tittle = addonColor..NeP.Info.Name
local Logo = '|T'..Intf.Logo..':15:15|t'
local Config = NeP.Config
local Round = NeP.Core.Round
local F = NeP.Interface.fetchKey
local TA = NeP.Core.TA

local function OpenPage(URL)
	local URL = tostring(URL)
	if OpenURL then
		OpenURL(URL)
	else
		NeP.Core.Message('Please Visit:\n'..URL)
	end
end

local E, _L, V, P, G
if IsAddOnLoaded("ElvUI") then
	E, _L, V, P, G = unpack(ElvUI)
	ElvSkin = E:GetModule('ActionBars')
	NeP.MFrame.buttonPadding = 2
	NeP.MFrame.buttonSize = 32
end

local DropMenu = {}
local DropMenu_Add = {
	{ text = "Modules:", notCheckable = 1, hasArrow = true, menuList = NeP.MFrame.Plugins },
	{ text = TA('mainframe', 'OM'), notCheckable = 1, func = function() NeP.OM.List:Show() end },
	{ text = TA('mainframe', 'AL'), notCheckable = 1, func = function() PE_ActionLog:Show() end },
	{ text = TA('mainframe', 'Forum'), notCheckable = 1, func = function() OpenPage('http://nerdpackaddon.site/index.php/forum/index') end},
	{ text = TA('mainframe', 'Donate'), notCheckable = 1, func = function() OpenPage('http://goo.gl/yrctPO') end },
	{ text = TA('mainframe', 'HideNeP'), notCheckable = 1, func = function() NePFrame:Hide(); NeP.Core.Print(TA('Any', 'NeP_Show')) end },
	{ text = addonColor..NeP.Info.Name..' |r'..TA('mainframe', 'Settings'), notCheckable = 1, func = function() NeP.Interface.ShowGUI('NeP_Settings') end },
}

local function CreateDropMenu()
	wipe(DropMenu)
	-- title
	table.insert(DropMenu, { text = Logo..'['..Tittle..' |rv:'..NeP.Info.Version..' - '..NeP.Info.Branch..']', isTitle = 1 })
	-- Routines
	local routinesTable = NeP.Helpers.GetSpecTables()
	if routinesTable then
		local lastCR = NeP.Helpers.GetSelectedSpec()['Name']
		local SpecInfo = NeP.Helpers.specInfo()
		for k,v in pairs(routinesTable) do
			table.insert(DropMenu, {
				text = v['Name'],
				checked = (lastCR == k) or false,
				func = function(self)
					NeP.Core.Print(TA('mainframe', 'ChangeCR')..' ( '..v['Name']..' )')
					Config.Write('NeP_SlctdCR_'..(SpecInfo), k)
					NeP.Helpers.updateSpec()
				end
			})
		end
	else
		table.insert(DropMenu, {text = TA('mainframe', 'NoCR'), notCheckable = 1})
	end
	-- CR settings
	for i=1, #NeP.MFrame.Settings do
		table.insert(DropMenu, NeP.MFrame.Settings[i])
	end
	-- Rest
	for i=1, #DropMenu_Add do
		table.insert(DropMenu, DropMenu_Add[i])
	end
end

-- These are the default toggles.
local function defaultToggles()
	Intf.CreateToggle('MasterToggle',
		'Interface\\ICONS\\Ability_repair.png',
		'MasterToggle',
		TA('mainframe','MasterToggle'),
		function(self, button) 
		if button == "RightButton" then
			if IsControlKeyDown() then
				NePFrame.NePfDrag:Show()
			else
				CreateDropMenu()
				EasyMenu(DropMenu, NePFrame.menuFrame, "cursor", 0, 0, "MENU");
			end
		end
	end)
	Intf.CreateToggle('Interrupts', 'Interface\\ICONS\\Ability_Kick.png', 'Interrupts', TA('mainframe', 'Interrupts'))
	Intf.CreateToggle('Cooldowns', 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png', 'Cooldowns', TA('mainframe', 'Cooldowns'))
	Intf.CreateToggle('AoE', 'Interface\\ICONS\\Ability_Druid_Starfall.png', 'AoE', TA('mainframe', 'AoE'))
end

Intf.CreateSetting = function(name, func)
	NeP.MFrame.Settings[#NeP.MFrame.Settings+1] = {
		text = name,
		func = func,
		notCheckable = 1
	}
end

Intf.CreatePlugin = function(name, func)
	NeP.MFrame.Plugins[#NeP.MFrame.Plugins+1] = {
		text = tostring(name),
		func = func,
		notCheckable = 1
	}
end

Intf.CreateToggle = function(key, icon, name, tooltipz, callback)
	func = function(self, button)
		if callback then
			callback(self, button)
		end
		if button == "LeftButton" then
			self.actv = not self.actv
			Config.Write('bStates_'..string.lower(key), self.actv)
		end
		self:SetChecked(self.actv)
	end
	NeP.MFrame.Buttons[#NeP.MFrame.Buttons+1] = {
		key = string.lower(key),
		name = tostring(name),
		tooltip = tooltipz,
		icon = icon,
		func = func
	}
	Intf.RefreshToggles()
end

Intf.toggleToggle = function(key, state)
	local key = string.lower(key)
	button = _G[key]

	if state ~= nil and state ~= '' then
		button.actv = state == 'on'
	else
		button.actv = not button.actv
	end

	button:SetChecked(button.actv)
	Config.Write('bStates_'..key, button.actv)	Intf.RefreshToggles()
end

local function createButtons(key, icon, name, tooltip, func)
	if NeP.MFrame.usedButtons[key] ~= nil then
		NeP.MFrame.usedButtons[key]:Show()
	else
		local pos = (NeP.MFrame.buttonSize*#NeP.MFrame.Buttons)+(#NeP.MFrame.Buttons*NeP.MFrame.buttonPadding)-(NeP.MFrame.buttonSize+NeP.MFrame.buttonPadding)
		NeP.MFrame.usedButtons[key] = CreateFrame("CheckButton", key, NePFrame, 'ActionButtonTemplate')
		local temp = NeP.MFrame.usedButtons[key]
		temp:SetPoint("TOPLEFT", NePFrame, pos, 0)
		temp:SetSize(NeP.MFrame.buttonSize, NeP.MFrame.buttonSize)
		temp:SetFrameLevel(1)
		temp:SetNormalFontObject("GameFontNormal")
		temp.texture = temp:CreateTexture()
		temp.texture:SetTexture(icon)
		temp.texture:SetAllPoints()
		if ElvSkin then
			ElvSkin.db = E.db.actionbar
			temp.texture:SetTexCoord(.08, .92, .08, .92)
			ElvSkin:StyleButton(temp)
			temp:CreateBackdrop('Default')
			local htex = temp:CreateTexture()
			htex:SetColorTexture(NeP.Core.classColor('player', 'RBG', 0.65))
			htex:SetAllPoints()
			temp:SetCheckedTexture(htex)
		end
		temp.actv = Config.Read('bStates_'..key, false)
		temp:SetChecked(temp.actv)
		temp:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		temp:SetScript("OnClick", func)
		temp:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:AddLine("|cffFFFFFF"..name..' '..(self.actv and '|cff08EE00'..TA('Any', 'ON') or '|cffFF0000'..TA('Any', 'OFF')).."|r")
			if tooltip then
				GameTooltip:AddLine(tooltip)
			end
			GameTooltip:Show()
		end)
		temp:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

	end
end

-- Refresh Toggles
Intf.RefreshToggles = function()
	for k,v in pairs(NeP.MFrame.usedButtons) do
		NeP.MFrame.usedButtons[k]:SetSize(NeP.MFrame.buttonSize, NeP.MFrame.buttonSize)
	end
	for k,v in pairs(NeP.MFrame.Buttons) do
		createButtons( v.key, v.icon, v.name, v.tooltip, v.func )
	end
	NePFrame:SetSize(#NeP.MFrame.Buttons*NeP.MFrame.buttonSize+(NeP.MFrame.buttonPadding*#NeP.MFrame.Buttons), NeP.MFrame.buttonSize)
	NePFrame.NePfDrag:SetSize((#NeP.MFrame.Buttons-1)*NeP.MFrame.buttonSize+(NeP.MFrame.buttonPadding*#NeP.MFrame.Buttons), 40)
end

Intf.ResetSettings = function()
	wipe(NeP.MFrame.Settings)
end

Intf.ResetToggles = function()
	for k,v in pairs(NeP.MFrame.usedButtons) do
		NeP.MFrame.usedButtons[k]:Hide()
	end
	wipe(NeP.MFrame.Buttons)
	defaultToggles()
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
	NeP.MFrame.buttonSize = NeP_Size

	--parent frame
	NePFrame = CreateFrame("Frame", "NePFrame", UIParent)
	NePFrame:SetPoint(POS_1, POS_2, POS_3)
	NePFrame:SetMovable(true)
	NePFrame:SetFrameLevel(0)
	NePFrame:SetFrameStrata('HIGH')
	NePFrame:SetClampedToScreen(true)
	NePFrame:SetSize(#NeP.MFrame.Buttons*NeP.MFrame.buttonSize, NeP.MFrame.buttonSize)

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
	NePFrame.NePfDrag:SetSize((#NeP.MFrame.Buttons-1)*NeP.MFrame.buttonSize+(NeP.MFrame.buttonPadding*#NeP.MFrame.Buttons), NeP.MFrame.buttonSize)
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

	defaultToggles()

end)