NeP.Dispells = {}

-- Check if we have a spell
local function CheckSpell(spellID, pet)
	return spellID and IsSpellKnown(spellID, pet)
end


Spells = {
	['Debuffs'] = {},
	['Buffs'] = {}
}

local Debuffs = {
	-- Druid
	[88423] = {'Magic', 'Curse', 'Poison'}, -- Nature's Cure
	[2782] = {'Curse', 'Poison'}, -- Remove Corruption
	-- Monk
	[115450] = {'Magic', 'Poison', 'Disease'}, -- Detox (Mistweaver)
	[218164] = {'Poison', 'Disease'}, -- Detox (Brewmaster or Windwalker)
	-- Paladin
	[4987] = {'Magic', 'Poison', 'Disease'}, -- Cleanse
	[213644] = {'Poison', 'Disease'}, -- Cleanse Toxins
	-- Priest
	[527] = {'Magic', 'Disease'}, -- Purify
	[213634] = {'Disease'}, -- Purify Disease
	-- Shaman
	[77130] = {'Magic', 'Curse'},  -- Purify Spirit
	[51886] = {'Curse'} -- Cleanse Spirit
	
}

local Buffs = {
	-- Mage
	[30449] = {'Magic'}, -- Spellsteal
	-- Shaman
	[370] = {'Magic'}, -- Purge
	-- Priest
	[528] = {'Magic'} -- Dispel Magic
}

function UpdateSpells()
	for k,v in pairs(Debuffs) do
		if CheckSpell(k, false) then
			for i=1, #v do
				local dispellType = v[i]
				if Spells['Debuffs'][dispellType] == nil then
					Spells['Debuffs'][dispellType] = {}
				end
				table.insert(Spells['Debuffs'][dispellType], k)
			end
		end
	end
end