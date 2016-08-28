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

-- TEST CRAP
function NeP.Dispells.TEST()
	local spellID = GetSpellID(GetSpellName(spell))
	local skip = false
	for i=1,#NeP.Healing.Units do
		local Obj = NeP.Healing.Units[i]
		local dispellType = NeP.Dispells.CanDispellUnit(unit)
		if dispellType then
			local spell = NeP.Dispells.GetSpell(dispellType)
			if spell then
				return spell, Obj.key
			end
		end
	end
end


--[[
local LibDispellable = LibStub("LibDispellable-1.0")

NeP.DSL.RegisterConditon('dispellAll', function(spell)
	local spellID = GetSpellID(GetSpellName(spell))
	local skip = false
	for i=1,#Healing.Units do
		local Obj = Healing.Units[i]
		-- Check if the unit dosent have a blacklisted debuff
		for k,v in pairs(BlackListDebuff) do 
			local debuff = GetSpellName(tonumber(k))
			if UnitDebuff(Obj.key, tostring(debuff)) then
				skip = true
			end
		end
		if not skip and LibDispellable:CanDispelWith(Obj.key, spellID) then
			NeP.Engine.ForceTarget = Obj.key
			return true
		end
	end
	return false
end)

NeP.DSL.RegisterConditon("dispellable", function(target, spell)
	local spellID = GetSpellID(GetSpellName(spell))
	local skip = false
	for k,v in pairs(BlackListDebuff) do 
		local debuff = GetSpellName(tonumber(k))
		if UnitDebuff(target, tostring(debuff)) then
			skip = true
		end
	end
	if not skip then
		return LibDispellable:CanDispelWith(target, spellID)
	end
	return false
end)]]