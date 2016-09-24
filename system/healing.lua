NeP.Healing = {
	Units = {},
}

local Healing = NeP.Healing

local Roles = {
	['TANK'] = 2,
	['HEALER'] = 1.5,
	['DAMAGER'] = 1,
	['NONE'] = 1	 
}

-- Build Roster
C_Timer.NewTicker(0.25, (function()
	wipe(Healing.Units)
	for i=1,#NeP.OM['unitFriend'] do
		local Obj = NeP.OM['unitFriend'][i]
		if (UnitPlayerOrPetInParty(Obj.key) or UnitIsUnit('player', Obj.key))
		and not UnitIsDeadOrGhost(Obj.key) then
			if UnitIsVisible(Obj.key) and Obj.distance <= 40
			and NeP.Engine.LineOfSight('player', Obj.key) then
				local Role = UnitGroupRolesAssigned(Obj.key) or 'NONE'
				local pAbsorbs = UnitGetTotalHealAbsorbs(Obj.key) or 0
				local incHeal = UnitGetIncomingHeals(Obj.key) or 0
				local healthRaw = UnitHealth(Obj.key) - pAbsorbs + incHeal 
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
					healthRaw = healthRaw,
					distance = Obj.distance,
					role = Role
				}
			end
		end
	end
	table.sort(NeP.Healing.Units, function(a,b) return a.health < b.health end)
end), nil)

--[[ CONDITIONS ]]
NeP.DSL.RegisterConditon('AoEHeal', function(target, args)
	local target, args = target, args
	if not args then
		args = target
		target = 'player'
	end
	local health, num, maxDis = strsplit(',', args, 3)
	local health, num, maxDis = tonumber(health or 100), tonumber(num or 3), tonumber(distance or 40)
	local total = 0	
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		local distance = NeP.Engine.Distance(target, Obj.key)
		if Obj.health <= health and distance <= maxDis then
			total = total + 1
		end
	end
	return total >= num
end)

NeP.DSL.RegisterConditon('HealInfront', function(args)
	local health, num, maxDis = strsplit(',', args, 3)
	local health, num, maxDis = tonumber(health or 100), tonumber(num or 3), tonumber(distance or 40)
	local total = 0	
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		local distance = NeP.Engine.Distance('player', Obj.key)
		if Obj.health <= health and distance <= maxDis then
			if NeP.Engine.Infront('player', Obj.key) then
				total = total + 1
			end
		end
	end
	return total >= num
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