NeP.Healing = {
	Units = {},
}

local Roster = NeP.Healing.Units

local RolesAssigned = UnitGroupRolesAssigned
local UH = UnitHealth
local THA = UnitGetTotalHealAbsorbs
local IH = UnitGetIncomingHeals
local DoG = UnitIsDeadOrGhost
local PoPiP = UnitPlayerOrPetInParty
local UHMax = UnitHealthMax
local F = NeP.Interface.fetchKey

local Roles = {
	['TANK'] = 2,
	['HEALER'] = 1.5,
	['DAMAGER'] = 1,
	['NONE'] = 1	 
}

local function incHeal(Obj)
	if F('NePSettings', 'ignoreIH', false) then
		return 0
	end
	return (IH(Obj) or 0) --[[+NeP.CombatTracker.IncHeal]]
end

local function addUnit(Obj)
	local Role = RolesAssigned(Obj.key) or 'NONE'
	local healthRaw = UH(Obj.key)-(THA(Obj.key) or 0)+incHeal(Obj.key)
	local maxHealth = UHMax(Obj.key)
	local healthPercent =  (healthRaw / maxHealth) * 100
	table.insert(Roster, {
		key = Obj.key,
		prio = Roles[Role]*healthPercent,
		name = Obj.name,
		id = Obj.id,
		health = healthPercent,
		healthRaw = healthRaw,
		healthMax = maxHealth,
		distance = Obj.distance,
		role = Role
	})
end

-- Build Roster
NeP.Timer.Sync("nep_parser", 0.1, function()
	wipe(Roster)
	for i=1,#NeP.OM['unitFriend'] do
		local Obj = NeP.OM['unitFriend'][i]
		if (PoPiP(Obj.key) or UnitIsUnit('player', Obj.key))
		and not DoG(Obj.key) then
			if UnitIsVisible(Obj.key) and Obj.distance <= 40
			and NeP.Engine.LineOfSight('player', Obj.key) then
				addUnit(Obj)
			end
		end
	end
	table.sort(Roster, function(a,b) return a.health < b.health end)
end, 2.1)

--[[ CONDITIONS ]]
NeP.DSL.RegisterConditon('AoEHeal', function(target, args)
	local health, num, maxDis = strsplit(',', args, 3)
	local health, num, maxDis = tonumber(health or 100), tonumber(num or 3), tonumber(distance or 40)
	local total = 0	
	for i=1, #Roster do
		local Obj = Roster[i]
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
	for i=1, #Roster do
		local Obj = Roster[i]
		if Obj.health <= health and Obj.distance <= maxDis then
			if NeP.Engine.Infront('player', Obj.key) then
				total = total + 1
			end
		end
	end
	return total >= num
end)

NeP.DSL.RegisterConditon("health", function(target)
	local health = math.floor((UH(target) / UHMax(target)) * 100)
	return health
end)

NeP.DSL.RegisterConditon("health.actual", function(target)
	return UH(target)
end)

NeP.DSL.RegisterConditon("health.max", function(target)
	return UHMax(target)
end)
