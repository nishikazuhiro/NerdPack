NeP.CombatLog = {}

local Data = {}

-- combat log events to watch for damage
local DamageLogEvents = {
	["SPELL_DAMAGE"] = '',
	["DAMAGE_SHIELD"] = '',
	["SPELL_PERIODIC_DAMAGE"] = '',
	["SPELL_BUILDING_DAMAGE"] = '',
	["RANGE_DAMAGE"] = ''
}

-- combat log events to watch for healing
local HealingLogEvents = {
	["SPELL_HEAL"] = '',
	["SPELL_PERIODIC_HEAL"] = ''
}

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

-- start the combat log (when the player enters combat)
NeP.Listener.register('ttd', "COMBAT_LOG_EVENT_UNFILTERED", function(...)
	local Timestamp, EVENT, _,_,_,_,_, GUID= select(1, ...)
		
	-- Add the unit to our data if we dont have it
	if Data[GUID] == nil then
		Data[GUID] = {
			dmgTaken = 0,
			Hits = 0,
			firstHit = GetTime(),
			lastHit = 0,
		}
	end

	Data[GUID].lastHit = GetTime()

	-- Add the amount of dmg/heak
	if DamageLogEvents[EVENT] then
		logDamage(...)
	elseif HealingLogEvents[EVENT] then
		logHealing(...)
	elseif EVENT == "SWING_DAMAGE" then
		logSwing(...)
	elseif EVENT == 'UNIT_DIED' then
		Data[GUID] = nil
	end
end)

function NeP.CombatLog.getDMG(UNIT)
	local total, Hits = 0, 0
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		local time = GetTime()
		local timePassed = (time-Data[GUID].firstHit)
		total = Data[GUID].dmgTaken / timePassed
		Hits = Data[GUID].Hits
		-- Remove a unit if ir hasnt recived dmg for 5 sec
		if (time-Data[GUID].lastHit) >= 5 then
			Data[GUID] = nil
		end
	end
	return total, Hits
end

function NeP.CombatLog.CombatTime(UNIT)
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		local time = GetTime()
		local timePassed = (time-Data[GUID].firstHit)
		return timePassed
	end
	return 0
end

local fakeTTD = 8675309
NeP.TimeToDie = function(unit)
	local ttd = fakeTTD

	if not isDummy(unit) then
		local DMG, Hits = NeP.CombatLog.getDMG(unit)
		if DMG >= 1 and Hits > 1 then
			ttd = UnitHealth(unit) / DMG
		end
	end

	return ttd
end