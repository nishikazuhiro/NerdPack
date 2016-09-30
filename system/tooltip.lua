NeP.Tooltip = {
	frame = CreateFrame('GameTooltip', 'NeP_ScanningTooltip', UIParent, 'GameTooltipTemplate')
}

local function pPattern(tooltipText, pattern)
	if type(pattern) == 'string' then
		local match = tooltipText:lower():match(pattern)
		if match then return true end
	elseif type(pattern) == 'table' then
		for i=1, #pattern do
			local match = tooltipText:lower():match(pattern[i])
			if match then return true end
		end
	end
end

function NeP.Tooltip.Scan_Buff(target, pattern)
	for i = 1, 40 do
		NeP.Tooltip.frame:SetOwner(UIParent, 'ANCHOR_NONE')
		NeP.Tooltip.frame:SetUnitBuff(target, i)
		local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
		return tooltipText and pPattern(tooltipText, pattern)
	end
	return false
end

function NeP.Tooltip.Scan_Debuff(target, pattern)
	for i = 1, 40 do
		NeP.Tooltip.frame:SetOwner(UIParent, 'ANCHOR_NONE')
		NeP.Tooltip.frame:SetUnitDebuff(target, i)
		local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
		return tooltipText and pPattern(tooltipText, pattern)
	end
	return false
end

function NeP.Tooltip.Unit(target, pattern)
	NeP.Tooltip.frame:SetOwner(UIParent, 'ANCHOR_NONE')
	NeP.Tooltip.frame:SetUnit(target)
	local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
	return tooltipText and pPattern(tooltipText, pattern)
end