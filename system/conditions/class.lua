local RegisterConditon = NeP.DSL.RegisterConditon
--[[
						CLASS CONDITIONS!
			Only submit class specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

RegisterConditon('energy', function(target, spell)
	return UnitPower(target, UnitPowerType(target))
end)

-- Returns the amount of energy you have left till max (e.g. you have a max of 100 energy and 80 energy now, so it will return 20)
RegisterConditon('energydiff', function(target, spell)
	local max = UnitPowerMax(target, UnitPowerType(target))
	local curr = UnitPower(target, UnitPowerType(target))
	return (max - curr)
end)

RegisterConditon('mana', function(target, spell)
	if UnitExists(target) then
		return math.floor((UnitMana(target) / UnitManaMax(target)) * 100)
	end
	return 0
end)

--------------------------------------------------- PRIEST ---------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('insanity', function(target, spell)
	return UnitPower(target, SPELL_POWER_INSANITY)
end)

--------------------------------------------------- HUNTER ---------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('petrange', function(target)
	if target then
		return NeP.Engine.Distance('pet', target)
	end
	return 0
end)

RegisterConditon('focus', function(target, spell)
	return UnitPower(target, SPELL_POWER_FOCUS)
end)

--------------------------------------------------- DEATHKNIGH -----------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('runicpower', function(target, spell)
	return UnitPower(target, SPELL_POWER_RUNIC_POWER)
end)

RegisterConditon('runes', function(target, rune)
	local count = 0
	local next = 0
	for i=1, 6 do
		local start, duration, runeReady = GetRuneCooldown(i)
		if runeReady then
			count = count + 1
		elseif duration > next then
			next = duration
		end
	end
	if next > 0 then count = count + (next/10) end
	return count
end)

--------------------------------------------------- SHAMMMAN -------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('maelstrom', function(target, spell)
    return UnitPower(target, SPELL_POWER_MAELSTROM)
end)

RegisterConditon('totem', function(target, totem)
	for index = 1, 4 do
		local _, totemName, startTime, duration = GetTotemInfo(index)
		if totemName == GetSpellName(totem) then
			return true
		end
	end
	return false
end)

RegisterConditon('totem.duration', function(target, totem)
	for index = 1, 4 do
	local _, totemName, startTime, duration = GetTotemInfo(index)
	if totemName == GetSpellName(totem) then
		return floor(startTime + duration - GetTime())
	end
	end
	return 0
end)

--------------------------------------------------- WARLOCK --------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('demonicfury', function(target, spell)
	return UnitPower(target, SPELL_POWER_DEMONIC_FURY)
end)

RegisterConditon('embers', function(target, spell)
	return UnitPower(target, SPELL_POWER_BURNING_EMBERS, true)
end)

RegisterConditon('soulshards', function(target, spell)
	return UnitPower(target, SPELL_POWER_SOUL_SHARDS)
end)

--------------------------------------------------- MONK -----------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('chi', function(target, spell)
	return UnitPower(target, SPELL_POWER_CHI)
end)

-- Returns the number of chi you have left till max (e.g. you have a max of 5 chi and 3 chi now, so it will return 2)
RegisterConditon('chidiff', function(target, spell)
    local max = UnitPowerMax(target, SPELL_POWER_CHI)
    local curr = UnitPower(target, SPELL_POWER_CHI)
    return (max - curr)
end)

--------------------------------------------------- DRUID ----------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('form', function(target, spell)
	return GetShapeshiftForm()
end)

RegisterConditon('combopoints', function(target)
	return GetComboPoints('player', 'target')
end)

RegisterConditon('mushrooms', function ()
	local count = 0
	for slot = 1, 3 do
	if GetTotemInfo(slot) then
		count = count + 1 end
	end
	return count
end)

--------------------------------------------------- PALADIN --------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('holypower', function(target, spell)
	return UnitPower(target, SPELL_POWER_HOLY_POWER)
end)

RegisterConditon('seal', function(target, spell)
	return GetShapeshiftForm()
end)

--------------------------------------------------- WARRIOR --------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('rage', function(target, spell)
	return UnitPower(target, SPELL_POWER_RAGE)
end)

RegisterConditon('stance', function(target, spell)
	return GetShapeshiftForm()
end)

--------------------------------------------------- DEMONHUNTER ----------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterConditon('fury', function(target, spell)
	return UnitPower(target, SPELL_POWER_FURY)
end)

RegisterConditon('pain', function(target, spell)
	return UnitPower(target, SPELL_POWER_PAIN)
end)

-- Returns the number of fury you have left till max (e.g. you have a max of 100 fury and 80 fury now, so it will return 20)
RegisterConditon('furydiff', function(target, spell)
    local max = UnitPowerMax(target, SPELL_POWER_FURY)
    local curr = UnitPower(target, SPELL_POWER_FURY)
    return (max - curr)
end)
