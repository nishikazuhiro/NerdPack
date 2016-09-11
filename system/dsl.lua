NeP.DSL = {
	Conditions = {}
}

local DSL = NeP.DSL

local tableComparator = {
	['>='] 	= function(value, compare_value) return value >= compare_value 	end,
	['<='] 	= function(value, compare_value) return value <= compare_value 	end,
	['>'] 	= function(value, compare_value) return value >  compare_value 	end,
	['<'] 	= function(value, compare_value) return value <  compare_value 	end,
	['='] 	= function(value, compare_value) return value == compare_value 	end,
	['!='] 	= function(value, compare_value) return value ~= compare_value 	end
}

local function pString(mString, spell)
	local _, args = mString:match('(.+)%((.+)%)')
	if args then mString = mString:gsub('%((.+)%)', '') end
	if DSL.Conditions[mString] then
		local result = DSL.Get(mString)(nil, (args or spell))
		return result
	else
		local unitId, rest = strsplit('.', mString, 2)
		local unitId = NeP.Engine.FilterUnit(unitId)
		if UnitExists(unitId) then
			local result = DSL.Get(rest)(unitId, (args or spell))
			return result
		end
	end
end

local function Comperatores(mString, spell)
	for k,v in pairs(tableComparator) do
		local comperator = ' '..k..' '
		if mString:find(comperator) then
			local tempT = string.split(mString, comperator)
			for i=1, #tempT do
				if not string.match(tempT[i], '%d') then
					tempT[i] = pString(tempT[i], spell)
				else
					tempT[i] = tonumber(tempT[i])
				end
			end
			if type(tempT[1]) == type(tempT[2]) then
				local result = tableComparator[k](tempT[1], tempT[2], spell)
				return result
			end
		end
	end
end

local function Parse(dsl, spell)
	local modify_not = false
	local result = false
	if string.sub(dsl, 1, 1) == '!' then
		dsl = string.sub(dsl, 2)
		modify_not = true
	end
	local Comperatores = Comperatores(dsl)
	if Comperatores ~= nil then
		result =  Comperatores
	else
		result = pString(dsl, spell)
	end
	if modify_not then
		return not result
	end
	return result
end

-- Routes
local typesTable = {
	['function'] = function(dsl, spell) return dsl() end,
	['table'] = function(dsl, spell)
		local r_Tbl = {[1] = true}
		for _,String in ipairs(dsl) do
			if String == 'or' then
				r_Tbl[#r_Tbl+1] = true
			elseif r_Tbl[#r_Tbl] then
				local eval = DSL.Parse(String, spell)
				r_Tbl[#r_Tbl] = eval or false
			end
		end
		for i = 1, #r_Tbl do
			if r_Tbl[i] then
				return true
			end
		end
		return false
	end,
	['string'] = function(dsl, spell) 
		if string.sub(dsl, 1, 1) == '@' then
			return NeP.library.parse(false, dsl, 'target')
		else
			return Parse(dsl, spell)
		end
	end,
	['nil'] = function(dsl, spell) return true end,
	['boolean']	 = function(dsl, spell) return dsl end,
}


function DSL.Get(condition)
	local condition = string.lower(condition)
	if DSL.Conditions[condition] then
		return DSL.Conditions[condition]
	end
	return (function() end)
end

function DSL.RegisterConditon(name, condition, overwrite)
	local name = string.lower(name)
	if not DSL.Conditions[name] or overwrite then
		DSL.Conditions[name] = condition
	end
end

function DSL.Parse(dsl, spell)
	if typesTable[type(dsl)] then
		return typesTable[type(dsl)](dsl, spell)
	end
end