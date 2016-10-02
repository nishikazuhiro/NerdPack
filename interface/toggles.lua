local mainframe = NeP.Interface.MainFrame

local ButtonsSize = 40
local ButtonsPadding = 2

local Toggles = {}
local tcount = 0

local function SetTexture(parent, icon)
	temp = parent:CreateTexture()
	if icon then
		temp:SetTexture(icon)
	else
		temp:SetColorTexture(1,1,1,0.7)
	end
	temp:SetAllPoints(parent)
	temp:SetTexCoord(.08, .92, .08, .92)
	return temp
end

local function OnClick(self, func)
	func(self)
	self.actv = self:GetChecked()
end

local function OnEnter(self, name, text)
	local OnOff = self.actv and 'ON' or 'OFF'
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddDoubleLine(name, OnOff)
	if text then
		GameTooltip:AddLine(text)
	end
	GameTooltip:Show()
end

local function CreateToggle(eval)
	local pos = (ButtonsSize*tcount)+(tcount*ButtonsPadding)-(ButtonsSize+ButtonsPadding)
	Toggles[eval.key] = CreateFrame("CheckButton", key, mainframe.content)
	local temp = Toggles[eval.key]
	temp:SetPoint("LEFT", mainframe.content, pos, 0)
	temp:SetSize(ButtonsSize, ButtonsSize)
	temp:SetFrameLevel(1)
	temp:SetNormalFontObject("GameFontNormal")
	temp.texture = SetTexture(temp, eval.icon)
	temp.actv = false
	temp:SetChecked(temp.actv)
	temp.Checked_texture = SetTexture(temp)
	temp:SetCheckedTexture(temp.Checked_texture)
	temp:SetScript("OnClick", function(self) OnClick(self, eval.func) end)
	temp:SetScript("OnEnter", function(self) OnEnter(self, eval.name, eval.text) end)
	temp:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end

function NeP.Interface:AddToggle(eval)
	tcount = tcount + 1
	if Toggles[eval.key] then
		Toggles[eval.key]:Show()
	else
		CreateToggle(eval)
	end
	self:RefreshToggles()
end

function NeP.Interface:RefreshToggles()
	local Width = tcount*(ButtonsSize+ButtonsPadding)-ButtonsPadding
	mainframe:SetSize(Width, ButtonsSize)
	mainframe.drag:SetSize(Width-ButtonsSize, ButtonsSize)
	mainframe.content:SetSize(Width, ButtonsSize)
end