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
	["Prowl"] = 5215,
	-- Paladin
	["Hand of Reckoning"] = 62124,
	["Arcane Blast"] = 32935,
	["Eye of Tyr"] = 209202,
	["Hammer of the Righteous"] = 53595,
	["Judgment"] = 20271,
	["Seraphim"] = 152262,
	["Shield of the Righteous"] = 53600,
	["Consecration"] = 26573,
	["Avenging Wrath"] = 31884,
}

local GetSpellInfo = GetSpellInfo
function NeP.Locale.Spells(spell)
	if SpellID[spell] and not GetSpellInfo(spell) then
		return GetSpellInfo(SpellID[spell])
	end
	return spell
end