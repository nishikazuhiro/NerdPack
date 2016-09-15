--[[Insert the spell name here and its matching ID]]
local SpellID = {
	-- DRUID
	["Moonfire"] = 8921,
	["Rejuvenation"] = 774,
	["Rake"] = 1822,
	["Shred"] = 5221,
	["Rip"] = 1079,
	["Ferocious Bite"] = 22568,
	["Trash"] = 106830,
	["Swipe"] = 213764,
	["Tiger's Fury"] = 5217,
	["Prowl"] = 5215
}

local GetSpellInfo = GetSpellInfo
function NeP.Locale.Spells(spell)
	if SpellID[spell] and not GetSpellInfo(spell) then
		return GetSpellInfo(SpellID[spell])
	end
	return spell
end