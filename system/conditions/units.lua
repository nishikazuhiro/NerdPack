--[[
					UNITS CONDITIONS!
			Only submit UNITS specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

NeP.DSL.RegisterConditon("modifier.party", function()
	return IsInGroup()
end)

NeP.DSL.RegisterConditon("modifier.raid", function()
	return IsInRaid()
end)

NeP.DSL.RegisterConditon("party", function(target)
	return UnitInParty(target)
end)

NeP.DSL.RegisterConditon("raid", function(target)
	return UnitInRaid(target)
end)

NeP.DSL.RegisterConditon("modifier.members", function()
	return (GetNumGroupMembers() or 0)
end)

NeP.DSL.RegisterConditon("modifier.player", function()
	return UnitIsPlayer("target")
end)

------------------------------------------ ANY -------------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL.RegisterConditon('boss', function (target, spell)
	local classification = UnitClassification(target)
	if classification == 'rareelite'
	or classification == 'rare'
	or classification == 'worldboss'
	or LibBoss.BossIDs[tonumber(UnitID(target))] then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon('elite', function (target, spell)
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

NeP.DSL.RegisterConditon("id", function(target, id)
	local expectedID = tonumber(id)
	if expectedID and UnitID(target) == expectedID then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("threat", function(target)
	if UnitThreatSituation("player", target) then
		local isTanking, status, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", target)
		return scaledPercent
	end
	return 0
end)

NeP.DSL.RegisterConditon("aggro", function(target)
	return (UnitThreatSituation(target) and UnitThreatSituation(target) >= 2)
end)

NeP.DSL.RegisterConditon("moving", function(target)
	local speed, _ = GetUnitSpeed(target)
	return speed ~= 0
end)

NeP.DSL.RegisterConditon("classification", function (target, spell)
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

NeP.DSL.RegisterConditon("target", function(target, spell)
	return ( UnitGUID(target .. "target") == UnitGUID(spell) )
end)

NeP.DSL.RegisterConditon("player", function (target)
	return UnitIsPlayer(target)
end)

NeP.DSL.RegisterConditon("exists", function(target)
	return (UnitExists(target))
end)

NeP.DSL.RegisterConditon('dead', function (target)
	return UnitIsDeadOrGhost(target)
end)

NeP.DSL.RegisterConditon("alive", function(target, spell)
	return (UnitExists(target) and UnitHealth(target) > 0)
end)

NeP.DSL.RegisterConditon("behind", function(target, spell)
	return not NeP.Engine.Infront('player', target)
end)

NeP.DSL.RegisterConditon("infront", function(target, spell)
	return NeP.Engine.Infront('player', target)
end)

local movingCache = { }
NeP.DSL.RegisterConditon("lastmoved", function(target)
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

NeP.DSL.RegisterConditon("movingfor", function(target)
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

NeP.DSL.RegisterConditon("friend", function(target, spell)
	return ( UnitCanAttack("player", target) ~= 1 )
end)

NeP.DSL.RegisterConditon("enemy", function(target, spell)
	return UnitCanAttack("player", target)
end)

NeP.DSL.RegisterConditon("distance", function(target)
	return NeP.Engine.Distance('player', target)
end)

NeP.DSL.RegisterConditon("range", function(target)
	return NeP.DSL.Conditions["distance"](target)
end)

NeP.DSL.RegisterConditon("level", function(target, range)
	return UnitLevel(target)
end)

NeP.DSL.RegisterConditon("combat", function(target, range)
	return UnitAffectingCombat(target)
end)

NeP.DSL.RegisterConditon("role", function(target, role)
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

NeP.DSL.RegisterConditon("name", function (target, expectedName)
	return UnitExists(target) and UnitName(target):lower():find(expectedName:lower()) ~= nil
end)

NeP.DSL.RegisterConditon("creatureType", function (target, expectedType)
	return UnitCreatureType(target) == expectedType
end)

NeP.DSL.RegisterConditon("class", function (target, expectedClass)
	local class, _, classID = UnitClass(target)
	if tonumber(expectedClass) then
		return tonumber(expectedClass) == classID
	else
		return expectedClass == class
	end
end)

------------------------------------------ PLAYER ----------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL.RegisterConditon("ilevel", function()
	return math.floor(select(1,GetAverageItemLevel()))
end)

NeP.DSL.RegisterConditon('swimming', function ()
	return IsSwimming()
end)

NeP.DSL.RegisterConditon("lastcast", function(spell, arg)
	if arg then spell = arg end
	return NeP.Engine.lastCast == GetSpellName(spell)
end)

NeP.DSL.RegisterConditon("mounted", function()
	return IsMounted()
end)

NeP.DSL.RegisterConditon("enchant.mainhand", function()
	return (select(1, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL.RegisterConditon("enchant.offhand", function()
	return (select(4, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL.RegisterConditon("falling", function()
	return IsFalling()
end)

NeP.DSL.RegisterConditon("deathin", function(target)
	return NeP.TimeToDie(target)
end)

NeP.DSL.RegisterConditon("ttd", function(target)
	return NeP.DSL.Conditions["deathin"](target)
end)

NeP.DSL.RegisterConditon("charmed", function(unit, _)
	return UnitIsCharmed(unit)
end)

NeP.DSL.RegisterConditon("talent", function(args)
	local row, col = strsplit(",", args, 2)
	return hasTalent(tonumber(row), tonumber(col))
end)

NeP.DSL.RegisterConditon("glyph", function()
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

------------------------------------------ OM CRAP ---------------------------------------
------------------------------------------------------------------------------------------
NeP.DSL.RegisterConditon("modifier.enemies", function()
	return #NeP.OM.unitEnemie
end)

NeP.DSL.RegisterConditon("area.enemies", function(unit, distance)
	local total = 0
	local distance = tonumber(distance)
	if UnitExists(unit) then
		for i=1, #NeP.OM.unitEnemie do
			local Obj = NeP.OM.unitEnemie[i]
			if NeP.Engine.Distance(unit, Obj.key) <= distance then
				total = total +1
			end
		end
	end
	return total
end)

NeP.DSL.RegisterConditon("area.friendly", function(unit, distance)
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