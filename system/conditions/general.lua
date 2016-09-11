local RegisterConditon = NeP.DSL.RegisterConditon
local rangeCheck = LibStub('LibRangeCheck-2.0')

local function checkChanneling(target)
	local name, _, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo(target)
	if name then return name, startTime, endTime, notInterruptible end
end

local function checkCasting(target)
	local name, startTime, endTime, notInterruptible = checkChanneling(target)
	if name then return name, startTime, endTime, notInterruptible end
	local name, _,_,_, startTime, endTime, _,_, notInterruptible = UnitCastingInfo(target)
	if name then return name, startTime, endTime, notInterruptible end
end

RegisterConditon('timetomax', function(target, spell)
	local max = UnitPowerMax(target)
	local curr = UnitPower(target)
	local regen = select(2, GetPowerRegen(target))
	return (max - curr) * (1.0 / regen)
end)

RegisterConditon('toggle', function(target, toggle)
	local toggle = string.lower(toggle)
	return NeP.Config.Read('bStates_'..tostring(toggle), false)
end)

RegisterConditon('casting.time', function(target, spell)
	local name, startTime, endTime = checkCasting(target)
	if not endTime or not startTime then return false end
	if name then return (endTime - startTime) / 1000 end
	return false
end)

RegisterConditon('casting.delta', function(target, spell)
	local name, startTime, endTime, notInterruptible = checkCasting(target)
	if not endTime or not startTime then return false end
	if name and not notInterruptible then
		local castLength = (endTime - startTime) / 1000
		local secondsLeft = endTime / 1000 - GetTime()
		return secondsLeft, castLength
	end
	return false
end)

RegisterConditon('casting.percent', function(target, spell)
	local name, startTime, endTime, notInterruptible = checkCasting(target)
	if name and not notInterruptible then
		local castLength = (endTime - startTime) / 1000
		local secondsLeft = endTime / 1000  - GetTime()
		return ((secondsLeft/castLength)*100)
	end
	return false
end)

RegisterConditon('channeling', function (target, spell)
	local name, startTime, endTime, notInterruptible = checkChanneling(target)
	local spell = GetSpellName(spell)
	if spell and (name == spell) then
		return true
	end
	return false
end)

RegisterConditon('casting', function(target, spell)
	local name, startTime, endTime, notInterruptible = checkCasting(target)
	local spell = GetSpellName(spell)
	if spell and (name == spell) then
		return true
	end
	return false
end)

RegisterConditon('interruptAt', function (target, spell)
	if UnitIsUnit('player', target) then return false end
	if NeP.DSL.Conditions['toggle'](nil, 'Interrupts') then
		local stopAt = tonumber(spell) or 35
		local stopAt = stopAt + math.random(-5, 5)
		local secondsLeft, castLength = NeP.DSL.Conditions['casting.delta'](target)
		if secondsLeft and 100 - (secondsLeft / castLength * 100) > stopAt then
			return true
		end
	end
	return false
end)

RegisterConditon('spell.cooldown', function(target, spell)
	local start, duration, enabled = GetSpellCooldown(spell)
	if not start then return false end
	if start ~= 0 then
		return (start + duration - GetTime())
	end
	return 0
end)

RegisterConditon('spell.recharge', function(target, spell)
	local charges, maxCharges, start, duration = GetSpellCharges(spell)
	if not start then return false end
	if start ~= 0 then
		return (start + duration - GetTime())
	end
	return 0
end)

RegisterConditon('spell.usable', function(target, spell)
	return (IsUsableSpell(spell) ~= nil)
end)

RegisterConditon('spell.exists', function(target, spell)
	if GetSpellBookIndex(spell) then
		return true
	end
	return false
end)

RegisterConditon('spell.charges', function(target, spell)
	return select(1, GetSpellCharges(spell))
end)

RegisterConditon('spell.count', function(target, spell)
	return select(1, GetSpellCount(spell))
end)

RegisterConditon('spell.cd', function(target, spell)
	return NeP.DSL.Conditions['spell.cooldown'](target, spell)
end)

RegisterConditon('spell.range', function(target, spell)
	local spellIndex, spellBook = GetSpellBookIndex(spell)
	if not spellIndex then return false end
	return spellIndex and IsSpellInRange(spellIndex, spellBook, target)
end)

RegisterConditon('combattime', function(target)
	return NeP.CombatTracker.CombatTime(target)
end)

RegisterConditon('timeout', function(target, args)
	local name, time = strsplit(',', args, 2)
	local time = tonumber(time)
	if time then
		if NeP.timeOut.check(name) then return false end
		NeP.timeOut.set(name, time)
		return true
	end
	return false
end)

local waitTable = {}
RegisterConditon('waitfor', function(target, args)
	local name, time = strsplit(',', args, 2)
	if time then
		local time = tonumber(time)
		local GetTime = GetTime()
		local currentTime = GetTime % 60
		if waitTable[name] then
			if waitTable[name] + time < currentTime then
				waitTable[name] = nil
				return true
			end
		else
			waitTable[name] = currentTime
		end
	end
	return false
end)

RegisterConditon('IsNear', function(target, args)
	local targetID, distance = strsplit(',', args, 2)
	local targetID = tonumber(targetID) or 0
	local distance = tonumber(distance) or 60
		for i=1,#NeP.OM.unitEnemie do
			local Obj = NeP.OM.unitEnemie[i]
			if Obj.id == targetID then
				if NeP.Engine.Distance('player', target) <= distance then
					return true
				end
			end
		end
	return false
end)
