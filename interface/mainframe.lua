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

NeP.MFrame = {
	buttonPadding = 2,
	buttonSize = 40,
	Buttons = {},
	usedButtons = {},
	Settings = {},
	Plugins = {},
	nSettings = {
		{
			name = TA('mainframe', 'Drag'),
			func = function() NePfDrag:Show() end
		},
		{
			name = TA('mainframe', 'OM'),
			func = function() NeP.OM.List:Show() end
		},
		{
			name = TA('mainframe', 'AL'),
			func = function() PE_ActionLog:Show() end
		},
		{
			name = TA('mainframe', 'Forum'),
			func = function() OpenPage('http://nerdpackaddon.site/index.php/forum/index') end
		},
		{
			name = TA('mainframe', 'HideNeP'),
			func = function() NePFrame:Hide(); NeP.Core.Print(TA('Any', 'NeP_Show')) end
		},
		{
			name = TA('mainframe', 'Donate'),
			func = function() OpenPage('http://goo.gl/yrctPO') end
		},
		{
			name = addonColor..NeP.Info.Name..' |r'..TA('mainframe', 'Settings'),
			func = function() NeP.Interface.ShowGUI('NePSettings') end
		}
	}
}

local E, _L, V, P, G
if IsAddOnLoaded("ElvUI") then
	E, _L, V, P, G = unpack(ElvUI)
	ElvSkin = E:GetModule('ActionBars')
	NeP.MFrame.buttonPadding = 2
	NeP.MFrame.buttonSize = 32
end

local function LoadCrs(info)
	local routinesTable = NeP.Helpers.GetSpecTables()
	if routinesTable then
		local lastCR = NeP.Helpers.GetSelectedSpec()['Name']
		local SpecInfo = NeP.Helpers.specInfo()
		for k,v in pairs(routinesTable) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v['Name']
			info.value = k
			info.checked = (lastCR == k) or false
			info.func = function(self)
				NeP.Core.Print(TA('mainframe', 'ChangeCR')..' ( '..v['Name']..' )')
				Config.Write('NeP_SlctdCR_'..(SpecInfo), k)
				NeP.Helpers.updateSpec()
			end
			UIDropDownMenu_AddButton(info)
		end
		return
	end
	-- No CR
	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = TA('mainframe', 'NoCR')
	UIDropDownMenu_AddButton(info)
end

local stD = {
	{n = 'CR Settings:', t = NeP.MFrame.Settings},
	{n = 'Modules:', t = NeP.MFrame.Plugins},
	{n = Logo..'['..Tittle..' |rv:'..NeP.Info.Version..' - '..NeP.Info.Branch..']', t = NeP.MFrame.nSettings}
}

local function dropdown(self)
	local info = UIDropDownMenu_CreateInfo()
	-- Routines
	info.isTitle = 1
	info.notCheckable = 1
	info.text = 'Combat Routines:'
	UIDropDownMenu_AddButton(info)
	LoadCrs(info)
	for k=1,#stD do
		local v = stD[k]
		if #v.t > 0 then
			info.isTitle = 1
			info.notCheckable = 1
			info.text = v.n
			UIDropDownMenu_AddButton(info)
			for i=1, #v.t do
				local z = v.t[i]
				info = UIDropDownMenu_CreateInfo()
				info.text = z.name
				info.value = z.name
				info.func = z.func
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info)
			end
		end
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
				NePfDrag:Show()
			else
				local ST_Dropdown = CreateFrame("Frame", "ST_Dropdown", self, "UIDropDownMenuTemplate");
				UIDropDownMenu_Initialize(ST_Dropdown, dropdown, "MENU");
				ToggleDropDownMenu(1, nil, ST_Dropdown, self, 0, 0);
			end
		end
	end)
	Intf.CreateToggle('Interrupts', 'Interface\\ICONS\\Ability_Kick.png', 'Interrupts', TA('mainframe', 'Interrupts'))
	Intf.CreateToggle('Cooldowns', 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png', 'Cooldowns', TA('mainframe', 'Cooldowns'))
	Intf.CreateToggle('AoE', 'Interface\\ICONS\\Ability_Druid_Starfall.png', 'AoE', TA('mainframe', 'AoE'))
end

Intf.CreateSetting = function(name, func)
	NeP.MFrame.Settings[#NeP.MFrame.Settings+1] = {
		name = name,
		func = func
	}
end

Intf.CreatePlugin = function(name, func)
	NeP.MFrame.Plugins[#NeP.MFrame.Plugins+1] = {
		name = tostring(name),
		func = func
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

	if state ~= nil then
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
	NePfDrag:SetSize((#NeP.MFrame.Buttons-1)*NeP.MFrame.buttonSize+(NeP.MFrame.buttonPadding*#NeP.MFrame.Buttons), 40)
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
function Config.CreateMainFrame()

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

	NePfDrag = CreateFrame("Frame", 'MOVENEP', NePFrame)
	NePfDrag:SetPoint('Right', NePFrame)
	NePfDrag:SetFrameLevel(2)
	NePfDrag:EnableMouse(true)
	local statusText = NePfDrag:CreateFontString('PE_StatusText')
	statusText:SetFont("Fonts\\ARIALN.TTF", 16)
	statusText:SetShadowColor(0,0,0, 0.8)
	statusText:SetShadowOffset(-1,-1)
	statusText:SetPoint("CENTER", NePfDrag)
	statusText:SetText("|cffffffff"..TA('mainframe', 'WhileDrag').."|r")
	local texture = NePfDrag:CreateTexture()
	texture:SetAllPoints(NePfDrag)
	texture:SetColorTexture(0,0,0,0.9)
	NePfDrag:SetSize((#NeP.MFrame.Buttons-1)*NeP.MFrame.buttonSize+(NeP.MFrame.buttonPadding*#NeP.MFrame.Buttons), NeP.MFrame.buttonSize)
	NePfDrag:RegisterForDrag('LeftButton', 'RightButton')
	NePfDrag:SetScript('OnDragStart', function() NePFrame:StartMoving() end)
	NePfDrag:SetScript('OnDragStop', function(self)
		local from, _, to, x, y = NePFrame:GetPoint()
		NePFrame:StopMovingOrSizing()
		Config.Write('NePFrame_POS_1', from)
		Config.Write('NePFrame_POS_2', x)
		Config.Write('NePFrame_POS_3', y)
		NePfDrag:Hide()
		NeP.Core.Print(TA('mainframe', 'AfterDrag'))
	end)
	NePfDrag:Hide()

	-- Show on 1st run
	if not Config.Read('NePranOnce', false) then
		NePfDrag:Show()
		Config.Write('NePranOnce', true)
	end

	defaultToggles()

end