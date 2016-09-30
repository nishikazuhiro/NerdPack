NeP.Tooltip = {
	frame = CreateFrame('GameTooltip', 'NeP_ScanningTooltip', UIParent, 'GameTooltipTemplate')
}

local function pPattern(text, pattern)
	if type(pattern) == 'string' then
		local match = text:lower():match(pattern)
		if match then return true end
	elseif type(pattern) == 'table' then
		for i=1, #pattern do
			local match = text:lower():match(pattern[i])
			if match then return true end
		end
	end
end

function NeP.Tooltip:Scan_Buff(target, pattern)
	for i = 1, 40 do
		self.frame:SetOwner(UIParent, 'ANCHOR_NONE')
		self.frame:SetUnitBuff(target, i)
		local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
		return tooltipText and pPattern(tooltipText, pattern)
	end
	return false
end

function NeP.Tooltip:Scan_Debuff(target, pattern)
	for i = 1, 40 do
		self.frame:SetOwner(UIParent, 'ANCHOR_NONE')
		self.frame:SetUnitDebuff(target, i)
		local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
		return tooltipText and pPattern(tooltipText, pattern)
	end
	return false
end

function NeP.Tooltip:Unit(target, pattern)
	self.frame:SetOwner(UIParent, 'ANCHOR_NONE')
	self.frame:SetUnit(target)
	local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
	return tooltipText and pPattern(tooltipText, pattern)
end