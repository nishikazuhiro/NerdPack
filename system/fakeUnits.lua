NeP.FakeUnits = {}
local Units = {}

local Healing = NeP.Healing

function NeP.FakeUnits.Add(Name, Func)
	if not Units[Name] then
		Units[Name] = func
	end
end

function NeP.FakeUnits.Filter(unit)
	for token,func in pairs(Units) do
		if unit:find(token) then
			local arg1, arg2 = unit:match('(.+)%((.+)%)')
			if arg2 then unit = arg1 end
			local num = unit:match("%d+") or 1
			local real_unit = func(num, arg2)
			return real_unit and unit:gsub(token, real_unit)
		end
	end
	return unit
end

-- Lowest
NeP.FakeUnits.Add('lowest', function(num, role)
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if role and Obj.Role == role:upper() or not role then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	if tempTable[num] then
		return tempTable[num].key
	end
end)

-- LowestBuff
NeP.FakeUnits.Add('lbuff', function(num, buff)
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if NeP.DSL.Get('buff')(Obj.key, buff) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	if tempTable[num] then
		return tempTable[num].key
	end
end)

-- LowestBuff
NeP.FakeUnits.Add('ldebuff', function(num, debuff)
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if NeP.DSL.Get('debuff')(Obj.key, debuff) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	if tempTable[num] then
		return tempTable[num].key
	end
end)

-- healer
NeP.FakeUnits.Add('healer', function(num)
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if Obj.Role == 'HEALER' then
			local prio = Roles[Obj.role] * UnitManaMax(Obj.key)
			if not UnitIsUnit('player', Obj.key) then
				tempTable[#tempTable+1] = {
					key = Obj.key,
					prio = prio
				}
			end
		end
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[num] then
		return tempTable[num].key
	end
end)

-- healer
NeP.FakeUnits.Add('damager', function(num)
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if Obj.Role == 'DAMAGER' then
			local prio = Roles[Obj.role] * UnitHealthMax(Obj.key)
			if not UnitIsUnit('player', Obj.key) then
				tempTable[#tempTable+1] = {
					key = Obj.key,
					prio = prio
				}
			end
		end
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[num] then
		return tempTable[num].key
	end
end)

-- Tank
NeP.FakeUnits.Add('tank', function(num)
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		local prio = Roles[Obj.role] * UnitHealthMax(Obj.key) - Obj.distance
		if not UnitIsUnit('player', Obj.key) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[num] then
		return tempTable[num].key
	end
end)