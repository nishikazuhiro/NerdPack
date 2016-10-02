local LibBoss = LibStub("LibBossIDs-1.0")
--[[
					UNITS CONDITIONS!
			Only submit UNITS specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]
NeP.DSL:RegisterConditon("ingroup", function(target)
	return UnitInParty(target) or UnitInRaid(target)
end)

NeP.DSL:RegisterConditon("group.members", function()
	return (GetNumGroupMembers() or 0)
end)

------------------------------------------ ANY -------------------------------------------
------------------------------------------------------------------------------------------

local UnitClsf = {
	['elite'] = 2,
	['rareelite'] = 3,
	['rare'] = 4,
	['worldboss'] = 5
}

NeP.DSL:RegisterConditon('boss', function (target)
	local classification = UnitClassification(target)
	if UnitClsf[classification] then 
		return UnitClsf[classification] >= 3
	elseif LibBoss.BossIDs[UnitID(target)] then
		return true
	end
	return false
end)

NeP.DSL:RegisterConditon('elite', function (target, spell)
	local classification = UnitClassification(target)
	if UnitClsf[classification] then
		return UnitClsf[classification] >= 2
	elseif LibBoss.BossIDs[UnitID(target)] then
		return true
	end
	return false
end)

NeP.DSL:RegisterConditon("id", function(target, id)
	local expectedID = tonumber(id)
	return expectedID and UnitID(target) == expectedID 
end)

NeP.DSL:RegisterConditon("threat", function(target)
	if UnitThreatSituation("player", target) then
		local isTanking, status, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", target)
		return scaledPercent
	end
	return 0
end)

NeP.DSL:RegisterConditon("aggro", function(target)
	return (UnitThreatSituation(target) and UnitThreatSituation(target) >= 2)
end)

NeP.DSL:RegisterConditon("moving", function(target)
	local speed, _ = GetUnitSpeed(target)
	return speed ~= 0
end)

NeP.DSL:RegisterConditon("classification", function (target, spell)
	if not spell then return false end
	local classification = UnitClassification(target)
	if string.find(spell, '[%s,]+') then
		for classificationExpected in string.gmatch(spell, '%a+') do
			if classification == string.lower(classificationExpected) then
			return true
			end
		end
		return false
	else
		return UnitClassification(target) == string.lower(spell)
	end
end)

NeP.DSL:RegisterConditon("target", function(target, spell)
	return ( UnitGUID(target .. "target") == UnitGUID(spell) )
end)

NeP.DSL:RegisterConditon("player", function(target)
	return UnitIsPlayer(target)
end)

NeP.DSL:RegisterConditon("isself", function(target)
	return UnitIsUnit(target, 'player')
end)

NeP.DSL:RegisterConditon("exists", function(target)
	return (UnitExists(target))
end)

NeP.DSL:RegisterConditon('dead', function (target)
	return UnitIsDeadOrGhost(target)
end)

NeP.DSL:RegisterConditon("alive", function(target, spell)
	return (UnitExists(target) and UnitHealth(target) > 0)
end)

NeP.DSL:RegisterConditon("behind", function(target, spell)
	return not NeP.Engine.Infront('player', target)
end)

NeP.DSL:RegisterConditon("infront", function(target, spell)
	return NeP.Engine.Infront('player', target)
end)

local movingCache = { }
NeP.DSL:RegisterConditon("lastmoved", function(target)
	if target == 'player' then
		if not NeP.Listener.locals.moving then
			return GetTime() - NeP.Listener.locals.movingTime
		end
		return false
	else
		if UnitExists(target) then
			local guid = UnitGUID(target)
			if movingCache[guid] then
				local moving = (GetUnitSpeed(target) > 0)
				if not movingCache[guid].moving and moving then
					movingCache[guid].last = GetTime()
					movingCache[guid].moving = true
					return false
				elseif moving then
					return false
				elseif not moving then
					movingCache[guid].moving = false
					return GetTime() - movingCache[guid].last
				end
			else
				movingCache[guid] = { }
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = (GetUnitSpeed(target) > 0)
				return false
			end
		end
		return false
	end
end)

NeP.DSL:RegisterConditon("movingfor", function(target)
	if target == 'player' then
		if NeP.Listener.locals.moving then
			return GetTime() - NeP.Listener.locals.movingTime
		end
		return false
	else
		if UnitExists(target) then
			local guid = UnitGUID(target)
			if movingCache[guid] then
				local moving = (GetUnitSpeed(target) > 0)
				if not movingCache[guid].moving then
					movingCache[guid].last = GetTime()
					movingCache[guid].moving = (GetUnitSpeed(target) > 0)
					return false
				elseif moving then
					return GetTime() - movingCache[guid].last
				elseif not moving then
					movingCache[guid].moving = false
					return false
				end
			else
				movingCache[guid] = { }
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = (GetUnitSpeed(target) > 0)
				return false
			end
		end
		return false
	end
end)

NeP.DSL:RegisterConditon("friend", function(target, spell)
	return UnitExists(target) and not UnitCanAttack("player", target)
end)

NeP.DSL:RegisterConditon("enemy", function(target, spell)
	return UnitExists(target) and UnitCanAttack("player", target)
end)

NeP.DSL:RegisterConditon("distance", function(target)
	return NeP.Engine.UnitCombatRange('player', target)
end)

NeP.DSL:RegisterConditon("range", function(target)
	return NeP.DSL.Conditions["distance"](target)
end)

NeP.DSL:RegisterConditon("level", function(target, range)
	return UnitLevel(target)
end)

NeP.DSL:RegisterConditon("combat", function(target, range)
	return UnitAffectingCombat(target)
end)

NeP.DSL:RegisterConditon("role", function(target, role)
	local role = role:upper()
	local damageAliases = { "DAMAGE", "DPS", "DEEPS" }
	local targetRole = UnitGroupRolesAssigned(target)
	if targetRole == role then return true
	elseif role:find("HEAL") and targetRole == "HEALER" then
		return true
	else
		for i = 1, #damageAliases do
			if role == damageAliases[i] then
				return true
			end
		end
	end

	return false
end)

NeP.DSL:RegisterConditon("name", function (target, expectedName)
	return UnitExists(target) and UnitName(target):lower():find(expectedName:lower()) ~= nil
end)

NeP.DSL:RegisterConditon("creatureType", function (target, expectedType)
	return UnitCreatureType(target) == expectedType
end)

NeP.DSL:RegisterConditon("class", function (target, expectedClass)
	local class, _, classID = UnitClass(target)
	if tonumber(expectedClass) then
		return tonumber(expectedClass) == classID
	else
		return expectedClass == class
	end
end)

NeP.DSL:RegisterConditon("inMelee", function(target)
	return NeP.Engine.UnitAttackRange('player', target, 'melee')
end)

NeP.DSL:RegisterConditon("inRanged", function(target)
	return NeP.Engine.UnitAttackRange('player', target, 'ranged')
end)

NeP.DSL:RegisterConditon("power.regen", function(target)
	return select(2, GetPowerRegen(target))
end)

NeP.DSL:RegisterConditon("casttime", function(target, spell)
	local name, rank, icon, cast_time, min_range, max_range = GetSpellInfo(spell)
	return cast_time
end)

------------------------------------------ PLAYER ----------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL:RegisterConditon("ilevel", function()
	return math.floor(select(1,GetAverageItemLevel()))
end)

NeP.DSL:RegisterConditon('swimming', function ()
	return IsSwimming()
end)

NeP.DSL:RegisterConditon("lastcast", function(Unit, Spell)
	local lastcast = NeP.CombatTracker.LastCast(Unit)
	return lastcast == GetSpellInfo(Spell)
end)

NeP.DSL:RegisterConditon("mounted", function()
	return IsMounted()
end)

NeP.DSL:RegisterConditon("enchant.mainhand", function()
	return (select(1, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL:RegisterConditon("enchant.offhand", function()
	return (select(4, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL:RegisterConditon("falling", function()
	return IsFalling()
end)

NeP.DSL:RegisterConditon("deathin", function(target)
	return NeP.CombatTracker.TimeToDie(target)
end)

NeP.DSL:RegisterConditon("ttd", function(target)
	return NeP.DSL.Conditions["deathin"](target)
end)

NeP.DSL:RegisterConditon("charmed", function(target, _)
	return UnitIsCharmed(target)
end)

NeP.DSL:RegisterConditon("talent", function(target, args)
	local row, col = strsplit(",", args, 2)
	return hasTalent(tonumber(row), tonumber(col))
end)

NeP.DSL:RegisterConditon("glyph", function()
	local spellId = tonumber(spell)
	local glyphName, glyphId
	for i = 1, 6 do
		glyphId = select(4, GetGlyphSocketInfo(i))
		if glyphId then
			if spellId then
				if select(4, GetGlyphSocketInfo(i)) == spellId then
					return true
				end
			else
				glyphName = GetSpellName(glyphId)
				if glyphName:find(spell) then
					return true
				end
			end
		end
	end
	return false
end)

NeP.DSL:RegisterConditon('twohand', function(target)
	return IsEquippedItemType("Two-Hand")
end)

NeP.DSL:RegisterConditon('onehand', function(target)
	return IsEquippedItemType("One-Hand")
end)

------------------------------------------ OM CRAP ---------------------------------------
------------------------------------------------------------------------------------------
NeP.DSL:RegisterConditon("area.enemies", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for i=1, #NeP.OM['unitEnemie'] do
		local Obj = NeP.OM['unitEnemie'][i]
		if UnitExists(Obj.key) and (UnitAffectingCombat(Obj.key) or isDummy(Obj.key))
		and NeP.Engine.Distance(unit, Obj.key) <= tonumber(distance) then
			total = total +1
		end
	end
	return total
end)

NeP.DSL:RegisterConditon("area.friendly", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for i=1, #NeP.Healing.Units do
		local Obj = NeP.Healing.Units[i]
		if UnitExists(Obj.key) and NeP.Engine.Distance(unit, Obj.key) <= tonumber(distance) then
			total = total +1
		end
	end
	return total
end)
