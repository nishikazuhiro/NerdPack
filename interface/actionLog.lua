NeP.ActionLog = {
	log = {}
}

local log_height = 16
local log_items = 10
local abs_height = log_height * log_items + log_height
local delta = 0

local DiesalTools = LibStub('DiesalTools-1.0')
local DiesalStyle = LibStub('DiesalStyle-1.0')
local DiesalGUI = LibStub('DiesalGUI-1.0')
local DiesalMenu = LibStub('DiesalMenu-1.0')
local SharedMedia = LibStub('LibSharedMedia-3.0')

PE_ActionLog = DiesalGUI:Create('Window')
local ActionLog = PE_ActionLog
ActionLog.frame:SetSize(450, abs_height)
ActionLog.frame:SetClampedToScreen(true)
ActionLog.frame:SetMinResize(300, 400)
PE_ActionLog:Hide()

local ActionLogHeader = CreateFrame("Frame", nil, ActionLog.frame)
ActionLogHeader:SetFrameLevel(92)
ActionLogHeader:SetHeight(log_height)
ActionLogHeader:SetPoint("TOPLEFT", ActionLog.frame, "TOPLEFT")
ActionLogHeader:SetPoint("TOPRIGHT", ActionLog.frame, "TOPRIGHT")

ActionLogHeader.statusTextA = ActionLogHeader:CreateFontString('PE_ActionLogHeaderText')
ActionLogHeader.statusTextA:SetFont("Fonts\\ARIALN.TTF", log_height-3)
ActionLogHeader.statusTextA:SetPoint("LEFT", ActionLogHeader, 5, 0)
ActionLogHeader.statusTextA:SetText("|cfffdcc00Action")

ActionLogHeader.statusTextB = ActionLogHeader:CreateFontString('PE_ActionLogHeaderText')
ActionLogHeader.statusTextB:SetFont("Fonts\\ARIALN.TTF", log_height-3)
ActionLogHeader.statusTextB:SetPoint("LEFT", ActionLogHeader, 130, 0)
ActionLogHeader.statusTextB:SetText("|cfffdcc00Description")

ActionLogHeader.statusTextC = ActionLogHeader:CreateFontString('PE_ActionLogHeaderText')
ActionLogHeader.statusTextC:SetFont("Fonts\\ARIALN.TTF", log_height-3)
ActionLogHeader.statusTextC:SetPoint("LEFT", ActionLogHeader, 400, 0)
ActionLogHeader.statusTextC:SetText("|cfffdcc00Time")

ActionLog.frame:SetScript("OnMouseWheel", function(self, mouse)
	local top = #NeP.ActionLog.log - log_items

	if IsShiftKeyDown() then
		if mouse == 1 then
			delta = top
		elseif mouse == -1 then
			delta = 0
		end
	else
		if mouse == 1 then
			if delta < top then
				delta = delta + mouse
			end
		elseif mouse == -1 then
			if delta > 0 then
				delta = delta + mouse
			end
		end
	end

	NeP.ActionLog.update()
end)

local ActionLogItem = { }

for i = 1, (log_items) do

	ActionLogItem[i] = CreateFrame("Frame", nil, ActionLog.frame)
	ActionLogItem[i]:SetFrameLevel(94)
	local texture = ActionLogItem[i]:CreateTexture(nil, "BACKGROUND")
	texture:SetAllPoints(ActionLogItem[i])

	ActionLogItem[i].texture = texture

	ActionLogItem[i]:SetHeight(log_height)
	ActionLogItem[i]:SetPoint("LEFT", ActionLog.frame, "LEFT")
	ActionLogItem[i]:SetPoint("RIGHT", ActionLog.frame, "RIGHT")

	ActionLogItem[i].itemA = ActionLogItem[i]:CreateFontString('itemA')
	ActionLogItem[i].itemA:SetFont("Fonts\\ARIALN.TTF", log_height-3)
	ActionLogItem[i].itemA:SetShadowColor(0,0,0, 0.8)
	ActionLogItem[i].itemA:SetShadowOffset(-1,-1)
	ActionLogItem[i].itemA:SetPoint("LEFT", ActionLogItem[i], 5, 0)

	ActionLogItem[i].itemB = ActionLogItem[i]:CreateFontString('itemA')
	ActionLogItem[i].itemB:SetFont("Fonts\\ARIALN.TTF", log_height-3)
	ActionLogItem[i].itemB:SetShadowColor(0,0,0, 0.8)
	ActionLogItem[i].itemB:SetShadowOffset(-1,-1)
	ActionLogItem[i].itemB:SetPoint("LEFT", ActionLogItem[i], 130, 0)

	ActionLogItem[i].itemC = ActionLogItem[i]:CreateFontString('itemA')
	ActionLogItem[i].itemC:SetFont("Fonts\\ARIALN.TTF", log_height-3)
	ActionLogItem[i].itemC:SetShadowColor(0,0,0, 0.8)
	ActionLogItem[i].itemC:SetShadowOffset(-1,-1)
	ActionLogItem[i].itemC:SetPoint("LEFT", ActionLogItem[i], 400, 0)

	local position = ((i * log_height) * -1)
	ActionLogItem[i]:SetPoint("TOPLEFT", ActionLog.frame, "TOPLEFT", 0, position)
end

NeP.ActionLog.insert = function(type, spell, spellIcon, target)
	if spellIcon then
		if NeP.ActionLog.log[1]
		and NeP.ActionLog.log[1]['event'] == type
		and NeP.ActionLog.log[1]['description'] == spell
		and NeP.ActionLog.log[1]['target'] == target then
			NeP.ActionLog.log[1]['count'] = NeP.ActionLog.log[1]['count'] + 1
			NeP.ActionLog.log[1]['time'] = date("%H:%M:%S")
		else
			table.insert(NeP.ActionLog.log, 1, {
				event = type,
				target = target,
				icon = spellIcon,
				description = spell,
				count = 1,
				time = date("%H:%M:%S")
			})
			if delta > 0 and delta < #NeP.ActionLog.log - log_items then
				delta = delta + 1
			end
		end
	end
end

NeP.ActionLog.updateRow = function (row, a, b, c)
	ActionLogItem[row].itemA:SetText(a)
	ActionLogItem[row].itemB:SetText(b)
	ActionLogItem[row].itemC:SetText(c)
end

NeP.ActionLog.update = function ()
	local offset = 0
	for i = log_items, 1, -1 do
		offset = offset + 1
		local item = NeP.ActionLog.log[offset + delta]
		if not item then
			NeP.ActionLog.updateRow(i, '', '', '')
		else
			local target = item.target and ' |cfffdcc00@|r (' .. item.target .. ')' or ''
			local icon = '|T'..item.icon..':'..(log_height-3)..':'..(log_height-3)..'|t'
			local desc = icon..'[|cfffdcc00'..item.count..'|r] '..item.description..target
			NeP.ActionLog.updateRow(i, "|cff85888c"..item.event.."|r", desc, "|cff85888c"..item.time.."|r")
		end
	end
end

C_Timer.NewTicker(0.05, (function()
	if ActionLog.content:IsShown() then
		NeP.ActionLog.update()
	else
		wipe(NeP.ActionLog.log)
	end
end), nil)