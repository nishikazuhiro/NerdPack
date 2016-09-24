NeP.CombatTracker = {
	Data = {}
}

local Data = NeP.CombatTracker.Data

local function addToData(GUID)
	if not Data[GUID] then
		Data[GUID] = {
			dmgTaken = 0,
			Hits = 0,
			firstHit = GetTime(),
			lastHit = 0
		}
	end
end

local logDamage = function(...)
	local Timestamp, _,_,_,_,_,_, GUID, _, UnitFlag, _,_,_,_, Amount = ...
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
	Data[GUID].Hits = Data[GUID].Hits + 1
end

local logSwing = function(...)
	local Timestamp, _,_,_,_,_,_, GUID, _, UnitFlag, _, Amount = ...
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
	Data[GUID].Hits = Data[GUID].Hits + 1
end

local logHealing = function(...)
	local Timestamp, _,_,_,_,_,_, GUID, _, UnitFlag, _,_,_,_, Amount = ...
	Data[GUID].dmgTaken = Data[GUID].dmgTaken - Amount
end

local addAction = function(...)
	local timestamp, _,_, sourceGUID, sourceName,_,_, destGUID, destName,_,_, spellId, spellName = ...
	local playerGUID = UnitGUID('player')
	if spellName then
		-- Add to action Log
		if sourceGUID == playerGUID then
			local icon = select(3, GetSpellInfo(spellName))
			NeP.ActionLog.insert('Spell Cast Succeed', spellName, icon, destName)
		end
		addToData(sourceGUID)
		Data[sourceGUID].lastcast = spellName
	end
end

local EVENTS = {
	['SPELL_DAMAGE'] = function(...) logDamage(...) end,
	['DAMAGE_SHIELD'] = function(...) logDamage(...) end,
	['SPELL_PERIODIC_DAMAGE'] = function(...) logDamage(...) end,
	['SPELL_BUILDING_DAMAGE'] = function(...) logDamage(...) end,
	['RANGE_DAMAGE'] = function(...) logDamage(...) end,
	['SWING_DAMAGE'] = function(...) logSwing(...) end,
	['SPELL_HEAL'] = function(...) logHealing(...) end,
	['SPELL_PERIODIC_HEAL'] = function(...) logHealing(...) end,
	['UNIT_DIED'] = function(...) Data[select(8, ...)] = nil end,
	['SPELL_CAST_SUCCESS'] = function(...) addAction(...) end
}

function NeP.CombatTracker.LastCast(Unit)
	local GUID = UnitGUID(Unit)
	return Data[GUID] and Data[GUID].lastcast
end

function NeP.CombatTracker.getDMG(UNIT)
	local total, Hits = 0, 0
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		local time = GetTime()
		local combatTime = NeP.CombatTracker.CombatTime(UNIT)
		total = Data[GUID].dmgTaken / combatTime
		Hits = Data[GUID].Hits
		-- Remove a unit if it hasnt recived dmg for more then 5 sec
		if (time-Data[GUID].lastHit) > 5 then
			Data[GUID] = nil
		end
	end
	return total, Hits
end

function NeP.CombatTracker.CombatTime(UNIT)
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		local time = GetTime()
		local combatTime = (time-Data[GUID].firstHit)
		return combatTime
	end
	return 0
end

function NeP.CombatTracker.TimeToDie(unit)
	local ttd = 8675309
	if not isDummy(unit) then
		local DMG, Hits = NeP.CombatTracker.getDMG(unit)
		if DMG >= 1 and Hits > 1 then
			ttd = UnitHealth(unit) / DMG
		end
	end
	return ttd
end

NeP.DSL.RegisterConditon("incdmg", function(target, args)
	if target and UnitExists(target) then
		local pDMG = NeP.CombatTracker.getDMG(target)
		return pDMG * tonumber(args or 1)
	end
	return 0
end)

NeP.Listener.register('CombatTracker', 'COMBAT_LOG_EVENT_UNFILTERED', function(...)
	local _, EVENT, _,_,_,_,_, GUID = select(1, ...)
	-- Add the unit to our data if we dont have it
	addToData(GUID)
	-- Update last  hit time
	Data[GUID].lastHit = GetTime()
	-- Add the amount of dmg/heak
	if EVENTS[EVENT] then EVENTS[EVENT](...) end
end)

NeP.Listener.register('CombatTracker', 'PLAYER_REGEN_ENABLED', function(...)
	wipe(Data)
end)
