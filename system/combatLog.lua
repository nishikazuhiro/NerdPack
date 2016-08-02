NeP.CombatLog = {
	Data = {}
}

local Data = NeP.CombatLog.Data

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

local function toData(GUID)
	if Data[GUID] == nil then
		Data[GUID] = {
			dmgTaken = 0,
			hitsTaken = 0,
			healed = 0,
			healsTaken = 0
		}
	end
end

local logDamage = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, _, _, _, Amount = select(1, ...)
	toData(GUID)
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
	Data[GUID].hitsTaken = Data[GUID].hitsTaken + 1
end

local logSwing = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, Amount = select(1, ...)
	toData(GUID)
	Data[GUID].dmgTaken = Data[GUID].dmgTaken + Amount
	Data[GUID].hitsTaken = Data[GUID].hitsTaken + 1
end

local logHealing = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, _, _, _, Amount = select(1, ...)
	toData(GUID)
	Data[GUID].healed = Data[GUID].healed + Amount
	Data[GUID].healsTaken = Data[GUID].healsTaken + 1
end

local logDied = function(...)
	local Timestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, Amount = select(1, ...)
	Data[GUID] = nil
end

-- start the combat log (when the player enters combat)
local startLogging = function()
	NeP.Listener.register('ttd', "COMBAT_LOG_EVENT_UNFILTERED", function(...)
		local EVENT = select(2, ...)
		if DamageLogEvents[EVENT] then
			logDamage(...)
		elseif HealingLogEvents[EVENT] then
			logHealing(...)
		elseif EVENT == "SWING_DAMAGE" then
			logSwing(...)
		elseif EVENT == 'UNIT_DIED' then
			logDied(...)
		end
	end)
end

-- stop the combat log (when the player leaves combat)
local stopLogging = function()
	NeP.Listener.unregister('ttd', "COMBAT_LOG_EVENT_UNFILTERED", startLogging)
	wipe(Data)
end

-- register events
NeP.Listener.register('combatlog', "PLAYER_REGEN_ENABLED", stopLogging)
NeP.Listener.register('combatlog', "PLAYER_REGEN_DISABLED", startLogging)
NeP.Listener.register('combatlog', "PLAYER_LOGIN", stopLogging)

local function getHeals(GUID)
	local total = 1
	if Data[GUID].healed > 0 then
		total = Data[GUID].healed / Data[GUID].healsTaken
	end
	return total
end

local function getDMG(GUID)
	local total = 1
	if Data[GUID].dmgTaken > 0 then
		total = Data[GUID].dmgTaken / Data[GUID].hitsTaken
	end
	return total
end

function NeP.CombatLog.GetAVG_DIFF(UNIT)
	local total = 0
	local GUID = UnitGUID(UNIT)
	if Data[GUID] then
		local dmg = getDMG(GUID)
		local heal = getHeals(GUID)
		total = dmg - heal
	end
	return total
end