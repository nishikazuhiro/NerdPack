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
	Data[GUID].hitsTaken = Data[GUID].hitsTaken + 1
	Data[GUID].timestamp = GetTime() * 1000
end

local logSwing = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, Amount = select(1, ...)
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
	Data[GUID].hitsTaken = Data[GUID].hitsTaken + 1
end

local logHealing = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, _, _, _, Amount = select(1, ...)
	Data[GUID].healed = Data[GUID].healed + Amount
	Data[GUID].healsTaken = Data[GUID].healsTaken + 1
end

-- start the combat log (when the player enters combat)
NeP.Listener.register('ttd', "COMBAT_LOG_EVENT_UNFILTERED", function(...)
	local Timestamp, EVENT, _,_,_,_,_, GUID= select(1, ...)
		
	-- Add the unit to our data if we dont have it
	if Data[GUID] == nil then
		Data[GUID] = {
			dmgTaken = 0,
			hitsTaken = 0,
			healed = 0,
			healsTaken = 0,
			timestamp = 0
		}
	end

	-- Add a timestamp
	Data[GUID].timestamp = GetTime()

	-- add the amount of dmg/heak
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

C_Timer.NewTicker(1, (function()
	local cTime = GetTime()
	for k,v in pairs(Data) do
		local test = (cTime-v.timestamp)
		-- remove from data
		if v.dmgTaken < 1 then
			Data[k] = nil
		-- reduce
		elseif test > 1 then
			v.dmgTaken = v.dmgTaken/2
			v.hitsTaken = v.hitsTaken/2
			v.healed = v.healed/2
			v.healsTaken = v.healsTaken/2
		end
	end
end), nil)

function  NeP.CombatLog.getHeals(UNIT)
	local total = 0
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		if Data[GUID].healed > 0 then
			total = Data[GUID].healed / Data[GUID].healsTaken
		end
	end
	return total
end

function NeP.CombatLog.getDMG(UNIT)
	local total = 0
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		if Data[GUID].dmgTaken > 0 then
			total = Data[GUID].dmgTaken / Data[GUID].hitsTaken
		end
	end
	return total
end

function NeP.CombatLog.GetAVG_DIFF(UNIT)
	local total = 0
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		local dmg =  NeP.CombatLog.getDMG(GUID)
		local heal =  NeP.CombatLog.getHeals(GUID)
		total = dmg - heal
	end
	return total
end