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

-- BlackListed Debuffs
local BlackListDebuff = {
	[184449] = 'Mark of the Necromancer', -- Mark of the Necromancer (HC)
}

-- Check if we have a spell
local function CheckSpell(spellID, pet)
	return spellID and IsSpellKnown(spellID, pet)
end

-- Check if a spell is usable
local function SpellIsUsable(spell)
	if spell and CheckSpell(spell, false)then
		-- Make sure we can cast the spell
		local start, duration, enabled = GetSpellCooldown(spell)
		local _, GCD = GetSpellCooldown(61304)
		local isUsable, notEnoughMana = IsUsableSpell(spell)
		if isUsable and (start <= GCD) and not notEnoughMana then
			return true
		end
	end
	return false
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

local function rFilter(expires, duration)
	if expires then
		local reactionTime = GetReactionTime()
		expires = expires - reactionTime
		-- Break if debuff is gonna end
		if expires <= reactionTime then
			return false
		-- Break if faster then we can react
		elseif expires > (duration-reactionTime) then
			return false
		end
	end
	return true
end

local function SpellCanDispelType(spellID, dispellType)
	if Spells[dispellType] then
		for i=1, #Spells[dispellType] do
			local tSpell = Spells[dispellType][i]
			if spellID == tSpell return true end
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
			if SpellIsUsable(spell) then
				return spell
			end
		end
	end
end

-- Returns if a unit can be dispelled and what type
function NeP.Dispells.CanDispellUnit(unit)
	if UnitExists(unit) then
		for i=1, 40 do
			local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID = _G["UnitDebuff"](unit, i)
			if dispellType and Spells[dispellType] and BlackListDebuff[spellID] == nil then
				if rFilter(expires, duration) then
					return dispellType
				end
			end
		end
	end
end

-- Returns if a unit can be dispeled with a certain spell
function NeP.Dispells.CanDispelWith(unit, spell)
	in spell and unit then
		local dispellType = NeP.Dispells.CanDispellUnit(unit)
		local spellID = GetSpellID(GetSpellName(spell))
		if spellID and dispellType then
			return SpellCanDispelType(spellID, dispellType)
		end
	end
end

NeP.DSL.RegisterConditon("dispellable", function(unit, spell)
	return NeP.Dispells.CanDispelWith(unit, spell)
end)