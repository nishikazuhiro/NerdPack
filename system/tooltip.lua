NeP.Tooltip = {
	frame = CreateFrame('GameTooltip', 'NeP_ScanningTooltip', UIParent, 'GameTooltipTemplate')
}

function NeP.Tooltip.Scan_Buff(target, pattern)
	for i = 1, 40 do
		NeP.Tooltip.frame:SetOwner(UIParent, 'ANCHOR_NONE')
		NeP.Tooltip.frame:SetUnitBuff(target, i)
		local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
		if tooltipText then
			if type(pattern) == 'string' then
				local match = tooltipText:lower():match(pattern)
				if match then return true end
			elseif type(pattern) == 'table' then
				for _, curPattern in pairs(pattern) do
					local match = tooltipText:lower():match(curPattern)
					if match then return true end
				end
			end
		end
	end
	return false
end

function NeP.Tooltip.Scan_Debuff(target, pattern)
	-- debuffs
	for i = 1, 40 do
		NeP.Tooltip.frame:SetOwner(UIParent, 'ANCHOR_NONE')
		NeP.Tooltip.frame:SetUnitDebuff(target, i)
		local tooltipText = _G["NeP_ScanningTooltipTextLeft2"]:GetText()
		if tooltipText then
			if type(pattern) == 'string' then
				local match = tooltipText:lower():match(pattern)
				if match then return true end
			elseif type(pattern) == 'table' then
				for _, curPattern in pairs(pattern) do
					local match = tooltipText:lower():match(curPattern)
					if match then return true end
				end
			end
		end
	end
	return false
end

function NeP.Tooltip.CastTime(target, pattern)
	--WIP
end