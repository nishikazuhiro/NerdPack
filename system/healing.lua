NeP.Healing = {
	Units = {},
}

local Healing = NeP.Healing
local LibDispellable = LibStub("LibDispellable-1.0")

local Roles = {
	['TANK'] = 2,
	['HEALER'] = 1.5,
	['DAMAGER'] = 1,
	['NONE'] = 1	 
}

-- BlackListed Units	
local BlackListUnit = {
	[90296] = 'Soulbound Constructor', -- HC
}

-- BlackListed Debuffs
local BlackListDebuff = {
	[184449] = 'Mark of the Necromancer', -- Mark of the Necromancer (HC)
}

-- Build Roster
C_Timer.NewTicker(0.25, (function()
	wipe(Healing.Units)
	for i=1,#NeP.OM.unitFriend do
		local Obj = NeP.OM.unitFriend[i]
		if (UnitPlayerOrPetInParty(Obj.key) or UnitIsUnit('player', Obj.key))
		and Obj.distance <= 40
		and not UnitIsDeadOrGhost(Obj.key)
		and not BlackListUnit[Obj.id] then
			if UnitIsVisible(Obj.key)
			and NeP.Engine.LineOfSight('player', Obj.key) then
				local Role = UnitGroupRolesAssigned(Obj.key) or 'NONE'
				local incDMG = 0
				--local tAbsorbs = UnitGetTotalAbsorbs(Obj.key) or 0
				local pAbsorbs = UnitGetTotalHealAbsorbs(Obj.key) or 0
				local incHeal = UnitGetIncomingHeals(Obj.key) or 0
				local healthRaw = UnitHealth(Obj.key) - incDMG - pAbsorbs + incHeal 
				local maxHealth = UnitHealthMax(Obj.key)
				local missingHealth = maxHealth - healthRaw
				local healthPercent =  (healthRaw / maxHealth) * 100
				local prio = Roles[tostring(Role)] * healthPercent
				--print(UnitName(Obj.key), ' / ', healthPercent)
				Healing.Units[#Healing.Units+1] = {
					key = Obj.key,
					prio = prio,
					name = Obj.name,
					id = Obj.id,
					health = healthPercent,
					healthRaw = health,
					distance = Obj.distance,
					role = Role
				}
			end
		end
	end
	table.sort(NeP.Healing.Units, function(a,b) return a.prio > b.prio end)
end), nil)

-- Lowest
Healing['lowest'] = function(num, role)
	local num = num or 1
	local tempTable = Healing.Units
	if role then
		wipe(tempTable)
		for i=1, #Healing.Units do
			local Obj = Healing.Units[i]
			if Obj.Role == string.upper(role) then
				tempTable[#tempTable+1] = {
					key = Obj.key,
					prio = prio
				}
			end
		end
	end
	if tempTable[num] then
		return tempTable[num].key
	end
end

-- healer
Healing['healer'] = function(num)
	local num = num or 1
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if Obj.Role == 'HEALER' then
			local prio = Roles[Obj.role] * UnitManaMax(Obj.key)
			if not UnitIsUnit('player', Obj.key) then
				tempTable[#tempTable+1] = {
					key = Obj.key,
					prio = prio
				}
			end
		end
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[num] then
		return tempTable[num].key
	end
end

-- healer
Healing['damager'] = function(num)
	local num = num or 1
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if Obj.Role == 'DAMAGER' then
			local prio = Roles[Obj.role] * UnitHealthMax(Obj.key)
			if not UnitIsUnit('player', Obj.key) then
				tempTable[#tempTable+1] = {
					key = Obj.key,
					prio = prio
				}
			end
		end
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[num] then
		return tempTable[num].key
	end
end

-- Tank
Healing['tank'] = function(num)
	local num = num or 1
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		local prio = Roles[Obj.role] * UnitHealthMax(Obj.key) - Obj.distance
		if not UnitIsUnit('player', Obj.key) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[num] then
		return tempTable[num].key
	end
end

NeP.library.register('coreHealing', {

	needsHealing = function(percent, count)
		NeP.Core.Print('@coreHealing.needsHealing has been removed, tell the author of your CR to replace it with AoEHeal.')
	end,

	lowestDebuff = function(debuff, health)
		for i=1, #Healing.Units do
			local Obj = Healing.Units[i]
			if Obj.health <= health then
				local debuff,_,_,caster = NeP.APIs['UnitDebuff'](Obj.key, debuff, "any")
				if not debuff then
					NeP.Engine.ForceTarget = Obj.key
					return true
				end
			end
		end
		return false
	end,

	lowestBuff = function(buff, health)
		for i=1, #Healing.Units do
			local Obj = Healing.Units[i]
			if Obj.health <= health then
				local buff,_,_,caster = NeP.APIs['UnitBuff'](Obj.key, buff, "any")
				if not buff then
					NeP.Engine.ForceTarget = Obj.key
					return true
				end
			end
		end
		return false
	end

})

--[[ CONDITIONS ]]
NeP.DSL.RegisterConditon('AoEHeal', function(args)
	local health, num, distance = strsplit(',', args, 3)
	local health, num, distance = tonumber(health or 100), tonumber(num or 3), tonumber(distance or 40)
	local total = 0	
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if Obj.health <= health and Obj.distance <= distance then
			total = total + 1
		end
	end
	return total >= num
end)

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
end)

NeP.DSL.RegisterConditon("health", function(target)
	local health = math.floor((UnitHealth(target) / UnitHealthMax(target)) * 100)
	return health
end)

NeP.DSL.RegisterConditon("health.actual", function(target)
	return UnitHealth(target)
end)

NeP.DSL.RegisterConditon("health.max", function(target)
	return UnitHealthMax(target)
end)