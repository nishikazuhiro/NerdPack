NeP.CombatTracker = {}

local Data = {}

local logDamage = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, _, _, _, Amount = select(1, ...)
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
	Data[GUID].Hits = Data[GUID].Hits + 1
end

local logSwing = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, Amount = select(1, ...)
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
	Data[GUID].Hits = Data[GUID].Hits + 1
end

local logHealing = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, _, _, _, Amount = select(1, ...)
	Data[GUID].dmgTaken = Data[GUID].dmgTaken - Amount
end

local EVENTS = {
	["SPELL_DAMAGE"] = function(...) logDamage(...) end,
	["DAMAGE_SHIELD"] = function(...) logDamage(...) end,
	["SPELL_PERIODIC_DAMAGE"] = function(...) logDamage(...) end,
	["SPELL_BUILDING_DAMAGE"] = function(...) logDamage(...) end,
	["RANGE_DAMAGE"] = function(...) logDamage(...) end,
	["SWING_DAMAGE"] = function(...) logSwing(...) end,
	["SPELL_HEAL"] = function(...) logHealing(...) end,
	["SPELL_PERIODIC_HEAL"] = function(...) logHealing(...) end,
	["UNIT_DIED"] = function(...) Data[select(8, ...)] = nil end
}

-- start the combat log (when the player enters combat)
NeP.Listener.register('ttd', "COMBAT_LOG_EVENT_UNFILTERED", function(...)
	local _, EVENT, _,_,_,_,_, GUID = select(1, ...)
	-- Add the unit to our data if we dont have it
	if not Data[GUID] then
		Data[GUID] = {
			dmgTaken = 0,
			Hits = 0,
			firstHit = GetTime(),
			lastHit = 0,
		}
	end
	-- Update last  hit time
	Data[GUID].lastHit = GetTime()
	-- Add the amount of dmg/heak
	if EVENTS[EVENT] then EVENTS[EVENT](...) end
end)

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

local fakeTTD = 8675309
NeP.TimeToDie = function(unit)
	local ttd = fakeTTD

	if not isDummy(unit) then
		local DMG, Hits = NeP.CombatTracker.getDMG(unit)
		if DMG >= 1 and Hits > 1 then
			ttd = UnitHealth(unit) / DMG
		end
	end

	return ttd
end