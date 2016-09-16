NeP.DSL = {
	Conditions = {}
}

local DSL = NeP.DSL

local OPs = '[><=!~%+%-%*%/]'
local fOps = {['!='] = '~=',['='] = '=='}
local function FindOperator(Strg)
	local Strg, StringOP = Strg, '';
	local OP = Strg:match(OPs);
	Strg = Strg:gsub(OP, '');
	local OP2 = Strg:match(OPs);
	if OP2 then Strg = Strg:gsub(OP2, '') end
	local OP = OP..(OP2 or '');
	StringOP = OP;
	if fOps[OP] then OP = fOps[OP] end
	return StringOP, OP
end

local function Iterate(Strg, spell)
	local OP = Strg:match('[|&]');
	local Strg1, Strg2 = unpack(NeP.string_split(Strg, OP));
	local Strg1, Strg2 = DSL.Parse(Strg1), DSL.Parse(Strg2);
	if OP == '|' then return Strg1 or Strg2 end
	return Strg1 and Strg2
end

local function Nest(Strg, spell)
	local result = true;
	local Nest = Strg:match('{(.-)}');
	if not Nest then Nest = Strg:gsub('[{}]', '') end
	return DSL.Parse(Nest, spell)
end

local function ProcessCondition(Strg, args, spell)
	if DSL.Conditions[Strg] then
		return DSL.Get(Strg)('player', (args or spell))
	end
	local unitId, rest = strsplit('.', Strg, 2);
	local unitId = NeP.Engine.FilterUnit(unitId);
	if UnitExists(unitId) then
		return DSL.Get(rest)(unitId, (args or spell))
	end
end

local function ProcessString(Strg)
	local Strg = Strg;
	if Strg:find('%a') then
		local Args = Strg:match('%((.+)%)');
		if Args then 
			Args = NeP.Locale.Spells(Args); -- Translates the name to the correct locale
			Strg = Strg:gsub('%((.+)%)', '');
		end
		Strg = Strg:gsub('%s', '');
		return ProcessCondition(Strg, Args, spell)
	end
	return Strg:gsub('%s', '');
end

local function Comperatores(Strg, spell)
	local StringOP, OP = FindOperator(Strg);
	local Strg1, Strg2 = unpack(NeP.string_split(Strg, StringOP));
	local Strg1, Strg2 = DSL.Parse(Strg1), DSL.Parse(Strg2);
	return loadstring(" return "..(Strg1 or 0)..OP..(Strg2 or 0))()
end

local function StringMath(Strg)
	local StringOP, OP = FindOperator(Strg);
	local Strg1, Strg2 = unpack(NeP.string_split(Strg, StringOP));
	local Strg1, Strg2 = DSL.Parse(Strg1), DSL.Parse(Strg2);
	return loadstring(" return "..(Strg1 or 0)..OP..(Strg2 or 0))()
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
	['string'] = function(Strg, spell)
		if string.sub(Strg, 1, 1) == '!' then
			local Strg = string.sub(Strg, 2);
			return not DSL.Parse(Strg, spell)
		elseif Strg:find('[|&]') then
			return Iterate(Strg, spell)
		elseif Strg:find('[{}]') then
			return Nest(Strg, spell)
		elseif Strg:find('[><=!~]') then
			return Comperatores(Strg, spell)
		elseif Strg:find("[%+%-%*%/]") then
			return SplitMath(Strg)
		else
			return ProcessString(Strg)
		end
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