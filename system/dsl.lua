NeP.DSL = {
	Conditions = {}
}

local DSL = NeP.DSL

local MathOPs = '[><=!~%+%-%*%/]'
local fOps = {['!='] = '~=', ['='] = '=='}
local function FindOperator(Strg)
	local Strg, StringOP = Strg, ''
	local OP = Strg:match(MathOPs);
	Strg = Strg:gsub(OP, '');
	local OP2 = Strg:match(MathOPs);
	if OP2 then Strg = Strg:gsub(OP2, '') end
	local OP = OP..(OP2 or '');
	StringOP = OP
	if fOps[OP] then OP = fOps[OP] end
	return StringOP, OP
end

local function ProcessString(Strg, spell)
	local Strg = Strg
	local _, args = Strg:match('(.+)%((.+)%)')
	if args then 
		args = NeP.Locale.Spells(args) -- Translates the name to the correct locale
		Strg = Strg:gsub('%((.+)%)', '') 
	end
	Strg = Strg:gsub('%s', '')
	if DSL.Conditions[Strg] then
		return DSL.Get(Strg)('player', (args or spell))
	else
		local unitId, rest = strsplit('.', Strg, 2)
		local unitId = NeP.Engine.FilterUnit(unitId)
		if UnitExists(unitId) then
			return DSL.Get(rest)(unitId, (args or spell))
		end
	end
	return Strg
end

local function Comperatores(Strg, spell)
	local StringOP, OP = FindOperator(Strg)
	local Strg1, Strg2 = unpack(NeP.string_split(Strg, StringOP))
	local Strg1, Strg2 = DSL.Eval(Strg1), DSL.Eval(Strg2)
	return loadstring(" return "..(Strg1 or 0)..OP..(Strg2 or 0))()
end

local function StringMath(Strg)
	local StringOP, OP = FindOperator(Strg)
	local Strg1, Strg2 = unpack(NeP.string_split(Strg, StringOP))
	local Strg1, Strg2 = DSL.Eval(Strg1), DSL.Eval(Strg2)
	return loadstring(" return "..(Strg1 or 0)..OP..(Strg2 or 0))()
end

function DSL.Eval(Strg, spell)
	local Strg, Modify, result = Strg, false, false
	if Strg:sub(1, 1) == '!' then
		Modify = true
		Strg = Strg:sub(2);
	end
	if Strg:find('[><=!~]') then
		result = Comperatores(Strg, spell)
	elseif Strg:find("[%+%-%*%/]") then
		result = SplitMath(Strg)
	else
		result = ProcessString(Strg)
	end
	if Modify then return not result end
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
		return DSL.Eval(dsl, spell)
	end,
	['nil'] = function(dsl, spell) return true end,
	['boolean']	 = function(dsl, spell) return dsl end,
}

function DSL.Get(condition)
	if condition then
		local condition = string.lower(condition)
		if DSL.Conditions[condition] then
			return DSL.Conditions[condition]
		end
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