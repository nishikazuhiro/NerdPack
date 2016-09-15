--[[Insert the spell name here and its matching ID]]
local SpellID = {
	-- Racials
	["Shadowmeld"] = {58984},
	-- DRUID
	["Moonfire"] = {8921},
	["Rejuvenation"] = {774},
	["Rake"] = {1822},
	["Shred"] = {5221},
	["Rip"] = {1079},
	["Ferocious Bite"] = {22568},
	["Trash"] = {106830},
	["Swipe"] = {213764},
	["Tiger's Fury"] = {5217},
	["Prowl"] = {5215},
	-- Paladin
	["Hand of Reckoning"] = {62124},
	["Arcane Blast"] = {32935},
	["Eye of Tyr"] = {209202},
	["Hammer of the Righteous"] = {53595},
	["Judgment"] = {20271},
	["Seraphim"] = {152262},
	["Shield of the Righteous"] = {53600},
	["Consecration"] = {26573},
	["Avenging Wrath"] = {31884},
	["Bastion of Light"] = {204035},
	["Rebuke"] = {96231},
	["Hammer of Justice"] = {853},
	["Divine Shield"] = {642},
	["Flash of Light"] = {19750},
	["Lay on Hands"] = {633},
	["Ardent Defender"] = {31850},
	["Light of the Protector"] = {184092},
	["Redemption"] = {7328},
	["Blinding Light"] = {115750},
	["Blessing of Sacrifice"] = {6940},
	["Blessing of Protection"] = {1022},
	["Cleanse Toxins"] = {213644},
	["Divine Steed"] = {190784},
	["Blessing of Freedom"] = {1044},
	["Zeal"] = {217020},
	["Blade of Justice"] = {184575},
	["Divine Storm"] = {53385},
	["Templar's Verdict"] = {85256},
	["Justicar's Vengeance"] = {215661},
	["Greater Blessing of Wisdom"] = {203539},
	["Greater Blessing of Might"] = {203528},
	["Greater Blessing of Kings"] = {203538},
	["Hand of Hindrance"] = {183218},
	-- Demon Hunter
	["Fel Rush"] = {195072},
	["Throw Glaive"] = {185123,204157},
	["Demon's Bite"] = {162243},
	["Chaos Strike"] = {162794},
	["Eye Beam"] = {198013},
	["Fury of the Illidari"] = {201467},
	["Blade Dance"] = {188499},
	["Chaos Nova"] = {179057},
	["Vengeful Retreat"] = {198793},
	["Darkness"] = {196718},
	["Metamorphosis"] = {191427,187827},
	["Imprison"] = {217832},
	["Consume Magic"] = {183752},
	["Nemesis"] = {206491},
	["Blur"] = {198589},
	["Spectral Sight"] = {188501},
	["Torment"] = {185245},
	["Infernal Strike"] = {189110},
	["Demon Spikes"] = {203720},
	["Soul Cleave"] = {228477},
	["Immolation Aura"] = {178740},
	["Sigil of Flame"] = {204596},
	["Fiery Brand"] = {204021},
}

local GetSpellInfo = GetSpellInfo
function NeP.Locale.Spells(spell)
	if SpellID[spell] and not GetSpellInfo(spell) then
		for i=1, #SpellID[spell] do
			local spell = GetSpellInfo(SpellID[spell][i])
			if spell then return spell end
		end
	end
	return spell
end