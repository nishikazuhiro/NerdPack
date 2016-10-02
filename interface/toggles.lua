local mainframe = NeP.Interface.MainFrame

local ButtonsSize = 40
local ButtonsPadding = 2

local Toggles = {}
local tcount = 0

local function CreateToggle(eval)
	local pos = (ButtonsSize*tcount)+(tcount*ButtonsPadding)-(ButtonsSize+ButtonsPadding)
	Toggles[eval.key] = CreateFrame("CheckButton", key, mainframe.content)
	local temp = Toggles[eval.key]
	temp:SetPoint("LEFT", mainframe.content, pos, 0)
	temp:SetSize(ButtonsSize, ButtonsSize)
	temp:SetFrameLevel(1)
	temp:SetNormalFontObject("GameFontNormal")
	temp.texture = temp:CreateTexture()
	temp.texture:SetTexture(eval.icon)
	temp.texture:SetAllPoints()
	temp.texture:SetTexCoord(.08, .92, .08, .92)
	temp.actv = false
	temp:SetChecked(temp.actv)
	temp:SetScript("OnClick", function(self) eval.func(self) end)
	temp:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(eval.name..'\n'..eval.text)
		if tooltip then
			GameTooltip:AddLine(tooltip)
		end
		GameTooltip:Show()
	end)
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