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
end

local logSwing = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, Amount = select(1, ...)
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
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
			firstHit = GetTime()
		}
	end

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
	local total = 0
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		local timePassed = (GetTime()-Data[GUID].firstHit)
		total = Data[GUID].dmgTaken / timePassed
		if total < 1 then
			Data[GUID] = nil
		end
	end
	return total
end