NeP.Dispells = {}

local SpellList = {
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

-- Check if we have a spell
local function CheckSpell(spellID, pet)
	return spellID and IsSpellKnown(spellID, pet)
end

-- Builds a list of all available spells
local Spells = {}
function UpdateSpells()
	for k,v in pairs(SpellList) do
		if CheckSpell(k, false) then
			for i=1, #v do
				local dispellType = v[i]
				if Spells[dispellType] == nil then
					Spells[dispellType] = {}
				end
				table.insert(Spells[dispellType], k)
			end
		end
	end
end

-- Update spells
NeP.Listener.register("PLAYER_LOGIN", function(...)
	UpdateSpells()
	NeP.Listener.register("PLAYER_SPECIALIZATION_CHANGED", function(unitID)
		if unitID == 'player' then
			UpdateSpells()
		end
	end)
end)

-- Returns a usable spell
function NeP.Dispells.GetSpell(dispellType)
	if Spells[dispellType] then
		for i=1, #Spells[dispellType] do
			local spell = Spells[dispellType][i]
			-- Convert Ids to Names
			if string.match(spell, '%d') then
				spell = GetSpellInfo(tonumber(spell))
			end
			if spell then
				-- Make sure we can cast the spell
				local start, duration, enabled = GetSpellCooldown(spell)
				local _, GCD = GetSpellCooldown(61304)
				local isUsable, notEnoughMana = IsUsableSpell(spell)
				if isUsable and (start <= GCD) and not notEnoughMana then
					return spell
				end
			end
		end
	end
end