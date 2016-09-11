NeP.DSL = {}

local DSL = NeP.DSL

function string:split(delimiter)
	local result, from = {}, 1
	local delim_from, delim_to = string.find(self, delimiter, from)
	while delim_from do
		table.insert( result, string.sub(self, from , delim_from-1))
		from = delim_to + 1
		delim_from, delim_to = string.find(self, delimiter, from)
	end
	table.insert(result, string.sub(self, from))
	return result
end

local tableComparator = {
	['>='] 	= function(value, compare_value) return value >= compare_value 	end,
	['<='] 	= function(value, compare_value) return value <= compare_value 	end,
	['>'] 	= function(value, compare_value) return value >  compare_value 	end,
	['<'] 	= function(value, compare_value) return value <  compare_value 	end,
	['='] 	= function(value, compare_value) return value == compare_value 	end,
	['!='] 	= function(value, compare_value) return value ~= compare_value 	end
}

local function pString(string, spell)
	local args = string:match("%((%a+)%)")
	if args then string = string:gsub('%((%a+)%)', '') end
	local dot1, dot2 = strsplit('.', string, 2)
	if UnitExists(dot1) then
		return DSL.get(dot2)(dot1, args, spell)
	elseif DSL.Conditions[string] then
		return DSL.get(string)(nil, args, spell)
	end
end

-- This runs the conditions so it returns the int
local function pNumber(arg1, arg2, eval, spell)
	local arg1, arg2 = arg1, arg2
	if not string.match(arg1, '%d') then
		arg1 = pString(arg1, spell)
	end
	if not string.match(arg2, '%d') then
		arg2 = pString(arg2, spell)
	end
	if arg1 and arg2 then
		local result = tableComparator[eval](arg1, arg2, spell)
		return result
	end
	return false
end

local function Parse(dsl, spell)
	local parse_table = string.split(dsl, ' || ')
	local r_table = {}
	for i=1, #parse_table do
		local ev = parse_table[i]
		r_table[i] = true
		local tempT = string.split(ev, ' && ')
		for k=1, #tempT do
			local eva = tempT[k]
			if r_table[i] then
				local arg1, arg2, arg3 = unpack(string.split(eva, ' '))
				-- Comparators
				if tableComparator[arg2] then
					r_table[i] = pNumber(arg1, arg3, arg2, spell)
				else
					local result = pString(eva, spell)
					r_table[i] = result
				end
			end
		end
	end
	for i=1, #r_table do
		if r_table[i] then
			return true
		end
	end
end

-- Routes
local typesTable = {
	['function'] = function(dsl, spell) return dsl() end,
	['table'] = function(dsl, spell)
		
	end,
	['string'] = function(dsl, spell) 
		-- Lib Call
		if string.sub(dsl, 1, 1) == '@' then
			return NeP.library.parse(false, dsl, 'target')
		else
			return Parse(dsl, spell)
		end
	end,
	['nil'] = function(dsl, spell) return true end,
	['boolean']	 = function(dsl, spell) return dsl end,
}


function DSL.get(condition)
	local condition = string.lower(condition)
	if DSL.Conditions[condition] then
		return DSL.Conditions[condition]
	end
	return (function() return false end)
end

function DSL.RegisterConditon(name, eval, overwrite)
	local name = string.lower(name)
	if not DSL.Conditions[name] or overwrite then
		DSL.Conditions[name] = eval
	end
end

function DSL.Parse(dsl, spell)
	if typesTable[type(dsl)] then
		return typesTable[type(dsl)](dsl, spell)
	end
end