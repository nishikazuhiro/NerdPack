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
C_Timer.NewTicker(0.5, (function()
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
				local incHeal = UnitGetIncomingHeals(Obj.key)
				local healthRaw = (UnitHealth(Obj.key) - incDMG) + incHeal
				local maxHealth = UnitHealthMax(Obj.key)
				local missingHealth = maxHealth - healthRaw
				local healthPercent =  (healthRaw / maxHealth) * 100
				local prio = Roles[tostring(Role)] * healthPercent
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
	table.sort(NeP.Healing.Units, function(a,b) return a.prio < b.prio end)
end), nil)

-- Lowest
Healing['lowest'] = function()
	if Healing.Units[1] then
		return Healing.Units[1].key 
	else
		return 'player'
	end
end

-- AoE Healing
Healing['AoEHeal'] = function(health)
	local health = tonumber(health)
	local numb = 0	
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if Obj.health > health then
			numb = numb + 1
		end
	end
	return numb
end

-- Tank
Healing['tank'] = function()
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		local prio = Roles[Obj.role] * UnitHealthMax(Obj.key)
		if not UnitIsUnit('player', Obj.key) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[1] then
		return tempTable[1].key
	else
		-- I dont want it to pass :P
		return 'FUCKTHISINVALIDUNIT'
	end
end

-- Dispell's
Healing['DispellAll'] = function(spell)
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
			return true, Obj.key
		end
	end
	return false, nil

end

-- Remaining complatible with ALL PEs Crs..
NeP.library.register('coreHealing', {
	
	needsHealing = function(percent, count)
		local total = Healing['AoEHeal'](percent)
		return total >= count
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
	local health, num = strsplit(',', args, 2)
	local health, num = tonumber(health), tonumber(num)
	if num then
		return NeP.Healing['AoEHeal'](health) >= num
	end
end)

NeP.DSL.RegisterConditon('dispellAll', function(spell)
	local condtion, target = NeP.Healing['DispellAll'](spell)
	if condtion then
		NeP.Engine.ForceTarget = target
		return true
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