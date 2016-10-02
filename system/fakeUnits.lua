NeP.FakeUnits = {}
local Units = {}
local Healing = NeP.Healing

local Roles = {
	['TANK'] = 2,
	['HEALER'] = 1.5,
	['DAMAGER'] = 1,
	['NONE'] = 1	 
}


function NeP.FakeUnits.Add(Name, Func)
	if not Units[Name] then
		Units[Name] = Func
	end
end

function NeP.FakeUnits.Filter(unit)
	for token,func in pairs(Units) do
		if unit:find(token) then
			local arg1, arg2 = unit:match('(.+)%((.+)%)')
			local num = unit:match("%d+") or 1
			local real_unit = func(tonumber(num), arg2)
			return real_unit
		end
	end
	return unit
end

-- Lowest
NeP.FakeUnits.Add('lowest', function(num, role)
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if (role and Obj.role == role:upper()) or not role then
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
		if Obj.role == 'HEALER' then
			--local prio = Roles[Obj.role] * UnitManaMax(Obj.key)
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = Obj.prio
			}
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
		if Obj.role == 'DAMAGER' then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = Obj.prio
			}
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
