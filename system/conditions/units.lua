local RegisterConditon = NeP.DSL.RegisterConditon
local LibBoss = LibStub("LibBossIDs-1.0")
--[[
					UNITS CONDITIONS!
			Only submit UNITS specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

RegisterConditon("modifier.party", function()
	return IsInGroup()
end)

RegisterConditon("modifier.raid", function()
	return IsInRaid()
end)

RegisterConditon("party", function(target)
	return UnitInParty(target)
end)

RegisterConditon("raid", function(target)
	return UnitInRaid(target)
end)

RegisterConditon("modifier.members", function()
	return (GetNumGroupMembers() or 0)
end)

RegisterConditon("modifier.player", function()
	return UnitIsPlayer("target")
end)

------------------------------------------ ANY -------------------------------------------
------------------------------------------------------------------------------------------

RegisterConditon('boss', function (target, spell)
	local classification = UnitClassification(target)
	if classification == 'rareelite'
	or classification == 'rare'
	or classification == 'worldboss'
	or LibBoss.BossIDs[tonumber(UnitID(target))] then
		return true
	end
	return false
end)

RegisterConditon('elite', function (target, spell)
	local classification = UnitClassification(target)
	if classification == 'elite'
	or classification == 'rareelite'
	or classification == 'rare'
	or classification == 'worldboss'
	or LibBoss.BossIDs[tonumber(UnitID(target))] then
		return true
	end
	return false
end)

RegisterConditon("id", function(target, id)
	local expectedID = tonumber(id)
	if expectedID and UnitID(target) == expectedID then
		return true
	end
	return false
end)

RegisterConditon("threat", function(target)
	if UnitThreatSituation("player", target) then
		local isTanking, status, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", target)
		return scaledPercent
	end
	return 0
end)

RegisterConditon("aggro", function(target)
	return (UnitThreatSituation(target) and UnitThreatSituation(target) >= 2)
end)

RegisterConditon("moving", function(target)
	local speed, _ = GetUnitSpeed(target)
	return speed ~= 0
end)

RegisterConditon("classification", function (target, spell)
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

RegisterConditon("target", function(target, spell)
	return ( UnitGUID(target .. "target") == UnitGUID(spell) )
end)

RegisterConditon("player", function(target)
	return UnitIsPlayer(target)
end)

RegisterConditon("isPlayer", function(target)
	return UnitIsUnit(target, 'player')
end)

RegisterConditon("exists", function(target)
	return (UnitExists(target))
end)

RegisterConditon('dead', function (target)
	return UnitIsDeadOrGhost(target)
end)

RegisterConditon("alive", function(target, spell)
	return (UnitExists(target) and UnitHealth(target) > 0)
end)

RegisterConditon("behind", function(target, spell)
	return not NeP.Engine.Infront('player', target)
end)

RegisterConditon("infront", function(target, spell)
	return NeP.Engine.Infront('player', target)
end)

local movingCache = { }
RegisterConditon("lastmoved", function(target)
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

RegisterConditon("movingfor", function(target)
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

RegisterConditon("friend", function(target, spell)
	return ( UnitCanAttack("player", target) ~= 1 )
end)

RegisterConditon("enemy", function(target, spell)
	return UnitCanAttack("player", target)
end)

RegisterConditon("distance", function(target)
	return NeP.Engine.Distance('player', target)
end)

RegisterConditon("range", function(target)
	return NeP.DSL.Conditions["distance"](target)
end)

RegisterConditon("level", function(target, range)
	return UnitLevel(target)
end)

RegisterConditon("combat", function(target, range)
	return UnitAffectingCombat(target)
end)

RegisterConditon("role", function(target, role)
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

RegisterConditon("name", function (target, expectedName)
	return UnitExists(target) and UnitName(target):lower():find(expectedName:lower()) ~= nil
end)

RegisterConditon("creatureType", function (target, expectedType)
	return UnitCreatureType(target) == expectedType
end)

RegisterConditon("class", function (target, expectedClass)
	local class, _, classID = UnitClass(target)
	if tonumber(expectedClass) then
		return tonumber(expectedClass) == classID
	else
		return expectedClass == class
	end
end)

NeP.DSL.RegisterConditon("inMelee", function(target)
	return NeP.Engine.UnitAttackRange('player', target, 'melee')
end)

NeP.DSL.RegisterConditon("inRanged", function(target)
	return NeP.Engine.UnitAttackRange('player', target, 'ranged')
end)

NeP.DSL.RegisterConditon("power.regen", function(target)
	return select(2, GetPowerRegen(target))
end)

NeP.DSL.RegisterConditon("casttime", function(target, spell)
	local name, rank, icon, cast_time, min_range, max_range = GetSpellInfo(spell)
	return cast_time
end)

------------------------------------------ PLAYER ----------------------------------------
------------------------------------------------------------------------------------------

RegisterConditon("ilevel", function()
	return math.floor(select(1,GetAverageItemLevel()))
end)

RegisterConditon('swimming', function ()
	return IsSwimming()
end)

RegisterConditon("lastcast", function(spell, arg)
	if arg then spell = arg end
	return NeP.Engine.lastCast == GetSpellName(spell)
end)

RegisterConditon("mounted", function()
	return IsMounted()
end)

RegisterConditon("enchant.mainhand", function()
	return (select(1, GetWeaponEnchantInfo()) == 1)
end)

RegisterConditon("enchant.offhand", function()
	return (select(4, GetWeaponEnchantInfo()) == 1)
end)

RegisterConditon("falling", function()
	return IsFalling()
end)

RegisterConditon("deathin", function(target)
	return NeP.TimeToDie(target)
end)

RegisterConditon("ttd", function(target)
	return NeP.DSL.Conditions["deathin"](target)
end)

RegisterConditon("charmed", function(unit, _)
	return UnitIsCharmed(unit)
end)

RegisterConditon("talent", function(args)
	local row, col = strsplit(",", args, 2)
	return hasTalent(tonumber(row), tonumber(col))
end)

RegisterConditon("glyph", function()
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

NeP.DSL.RegisterConditon('twohand', function(target)
	return IsEquippedItemType("Two-Hand")
end)

NeP.DSL.RegisterConditon('onehand', function(target)
	return IsEquippedItemType("One-Hand")
end)

------------------------------------------ OM CRAP ---------------------------------------
------------------------------------------------------------------------------------------
RegisterConditon("modifier.enemies", function()
	return #NeP.OM.unitEnemie
end)

RegisterConditon("area.enemies", function(unit, distance)
	local total = 0
	local distance = tonumber(distance)
	if UnitExists(unit) then
		for i=1, #NeP.OM.unitEnemie do
			local Obj = NeP.OM.unitEnemie[i]
			if (UnitAffectingCombat(Obj.key) or isDummy(Obj.key))
			and UnitExists(Obj.key)
			and (NeP.Engine.Distance(unit, Obj.key) <= distance) then
				total = total +1
			end
		end
	end
	return total
end)

RegisterConditon("area.friendly", function(unit, distance)
	local total = 0
	local distance = tonumber(distance)
	if UnitExists(unit) then
		for i=1, #NeP.OM.unitFriend do
			local Obj = NeP.OM.unitFriend[i]
			if NeP.Engine.Distance(unit, Obj.key) <= distance then
				total = total +1
			end
		end
	end
	return total
end)