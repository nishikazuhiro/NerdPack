local TA = NeP.Core.TA
local Intf = NeP.Interface
local Config = NeP.Config

Intf.Buttons = {}
Intf.usedButtons = {}

local function defaultToggles()
	NeP.Interface.CreateToggle('MasterToggle',
		'Interface\\ICONS\\Ability_repair.png',
		'MasterToggle',
		TA('mainframe','MasterToggle'),
		function(self, button) 
		if button == "RightButton" then
			if IsControlKeyDown() then
				NePFrame.NePfDrag:Show()
			else
				Intf.CreateDropMenu()
			end
		end
	end)
	NeP.Interface.CreateToggle('Interrupts', 'Interface\\ICONS\\Ability_Kick.png', 'Interrupts', TA('mainframe', 'Interrupts'))
	NeP.Interface.CreateToggle('Cooldowns', 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png', 'Cooldowns', TA('mainframe', 'Cooldowns'))
	NeP.Interface.CreateToggle('AoE', 'Interface\\ICONS\\Ability_Druid_Starfall.png', 'AoE', TA('mainframe', 'AoE'))
end

NeP.Config.WhenLoaded(function()
	defaultToggles()
end)

local E, _L, V, P, G
if IsAddOnLoaded("ElvUI") then
	E, _L, V, P, G = unpack(ElvUI)
	ElvSkin = E:GetModule('ActionBars')
	Intf.buttonPadding = 2
	Intf.buttonSize = 32
end

local function createButtons(key, icon, name, tooltip, func)
	if Intf.usedButtons[key] ~= nil then
		Intf.usedButtons[key]:Show()
	else
		local pos = (Intf.buttonSize*#Intf.Buttons)+(#Intf.Buttons*Intf.buttonPadding)-(Intf.buttonSize+Intf.buttonPadding)
		Intf.usedButtons[key] = CreateFrame("CheckButton", key, NePFrame, 'ActionButtonTemplate')
		local temp = Intf.usedButtons[key]
		temp:SetPoint("TOPLEFT", NePFrame, pos, 0)
		temp:SetSize(Intf.buttonSize, Intf.buttonSize)
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

function NeP.Interface.toggleToggle(key, state)
	local key = string.lower(key)
	button = _G[key]
	if state ~= nil and state ~= '' then
		button.actv = state == 'on'
	else
		button.actv = not button.actv
	end
	button:SetChecked(button.actv)
	Config.Write('bStates_'..key, button.actv)
	NeP.Interface.RefreshToggles()
end

function NeP.Interface.RefreshToggles()
	for k,v in pairs(Intf.usedButtons) do
		Intf.usedButtons[k]:SetSize(Intf.buttonSize, Intf.buttonSize)
	end
	for k,v in pairs(Intf.Buttons) do
		createButtons( v.key, v.icon, v.name, v.tooltip, v.func )
	end
	NePFrame:SetSize(#Intf.Buttons*Intf.buttonSize+(Intf.buttonPadding*#Intf.Buttons), Intf.buttonSize)
	NePFrame.NePfDrag:SetSize((#Intf.Buttons-1)*Intf.buttonSize+(Intf.buttonPadding*#Intf.Buttons), 40)
end

function NeP.Interface.ResetToggles()
	for k,v in pairs(Intf.usedButtons) do
		Intf.usedButtons[k]:Hide()
	end
	wipe(Intf.Buttons)
	defaultToggles()
end

function NeP.Interface.CreateToggle(key, icon, name, tooltipz, callback)
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
	table.insert(Intf.Buttons, {
		key = string.lower(key),
		name = tostring(name),
		tooltip = tooltipz,
		icon = icon,
		func = func
	})
	NeP.Interface.RefreshToggles()
end

function NeP.Interface.UpdateToggleIcon(toggle, icon)
	if icon then Intf.usedButtons[toggle].texture:SetTexture(icon) end
end