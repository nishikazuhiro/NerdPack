NeP.DSL = {
	Conditions = {}
}

local DSL = NeP.DSL

local OPs = {
	['>='] = function(arg1, arg2) return arg1 >= arg2 end,
	['<='] = function(arg1, arg2) return arg1 <= arg2 end,
	['=='] = function(arg1, arg2) return arg1 == arg2 end,
	['~='] = function(arg1, arg2) return arg1 ~= arg2 end,
	['>'] = function(arg1, arg2) return arg1 > arg2 end,
	['<'] = function(arg1, arg2) return arg1 < arg2 end,
	['+'] = function(arg1, arg2) return arg1 + arg2 end,
	['-'] = function(arg1, arg2) return arg1 - arg2 end,
	['/'] = function(arg1, arg2) return arg1 / arg2 end,
	['*'] = function(arg1, arg2) return arg1 * arg2 end,
	['!'] = function(arg1, arg2) return not DSL.Parse(arg1, arg2) end,
	['@'] = function(arg1, arg2) return NeP.library.parse(false, arg1, 'target') end,
	['true'] = function() return true end,
	['false'] = function() return false end,
}

local function DoMath(arg1, arg2, token)
	local arg1, arg2 = tonumber(arg1), tonumber(arg2)
	if arg1 ~= nil and arg2 ~= nil then
		return OPs[token](arg1, arg2)
	end
end

local function _AND(Strg, Spell)
	local Arg1, Arg2 = Strg:match('(.*)&(.*)')
	local Arg1 = DSL.Parse(Arg1, Spell)
	if not Arg1 then return false end -- Dont process anything in front sence we already failed
	local Arg2 = DSL.Parse(Arg2, Spell)
	return Arg1 and Arg2
end

local function _OR(Strg, Spell)
	local Arg1, Arg2 = Strg:match('(.*)||(.*)')
	local Arg1 = DSL.Parse(Arg1, Spell)
	if Arg1 then return true end -- Dont process anything in front sence we already hit
	local Arg2 = DSL.Parse(Arg2, Spell)
	return Arg1 or Arg2
end

local function FindNest(Strg)
	local Start, End = Strg:find('({.*})')
	local count1, count2 = 0, 0
	for i=Start, End do
		local temp = Strg:sub(i, i)
		if temp == "{" then
			count1 = count1 + 1
		elseif temp == "}" then
			count2 = count2 + 1
		end
		if count1 == count2 then
			return Start,  i
		end
	end
end

local function Nest(Strg, Spell)
	local Start, End = FindNest(Strg)
	local Result = DSL.Parse(Strg:sub(Start+1, End-1), Spell)
	Result = tostring(Result or false)
	Strg = Strg:sub(1, Start-1)..Result..Strg:sub(End+1)
	return DSL.Parse(Strg, Spell)
end

local function ProcessCondition(Strg, Args, Spell)
	local Args = Strg:match('%((.+)%)')
	if Args then 
		Args = NeP.Locale.Spells(Args) -- Translates the name to the correct locale
		Strg = Strg:gsub('%((.+)%)', '')
	else
		Args = Spell
	end
	Strg = Strg:gsub('%s', '')
	if DSL.Conditions[Strg] then
		return DSL.Get(Strg)('player', Args)
	end
	local unitId, rest = strsplit('.', Strg, 2)
	unitId = NeP.Engine.FilterUnit(unitId)
	if UnitExists(unitId) then
		return DSL.Get(rest)(unitId, Args)
	end
end

local function ProcessString(Strg, Spell)
	if Strg:find('%a') then
		return ProcessCondition(Strg, Spell)
	end
	return Strg:gsub('%s', '')
end

local fOps = {['!='] = '~=',['='] = '=='}
local function Comperatores(Strg, Spell)
	local OP = ''
	for Token in Strg:gmatch('[><=!~]') do OP = OP..Token end
	local arg1, arg2 = unpack(NeP.string_split(Strg, OP))
	arg1, arg2 = DSL.Parse(arg1, Spell), DSL.Parse(arg2, Spell)
	return DoMath(arg1, arg2, (fOps[OP] or OP))
end

local function StringMath(Strg, Spell)
	local OP, total = Strg:match('[%+%-%*%/]'), 0
	local tempT = NeP.string_split(Strg, OP)
	for i=1, #tempT do
		local Strg = DSL.Parse(tempT[i], Spell)
		total = DoMath(total, Strg, OP)
	end
	return total
end

-- Routes
local typesTable = {
	['function'] = function(dsl, Spell) return dsl() end,
	-- This is backwards compatibility
	['table'] = function(dsl, Spell)
		local final_Strg = ''
		for i=1, #dsl do
			local temp = dsl[i]
			if type(temp) == 'table' then
				local Result = DSL.Parse(temp, Spell)
				final_Strg = final_Strg..tostring(Result)
			elseif type(temp) == 'function' then
				final_Strg = final_Strg..'&'..tostring(temp())
			elseif final_Strg == '' then
				final_Strg = temp
			elseif temp == 'or' then
				final_Strg = final_Strg..'||'
			else
				final_Strg = final_Strg..'&'..temp
			end
		end
		return DSL.Parse(final_Strg, Spell)
	end,
	['string'] = function(Strg, Spell)
		local pX = string.sub(Strg, 1, 1)
		if OPs[pX] then
			local Strg = string.sub(Strg, 2);
			return OPs[pX](Strg, Spell)
		elseif OPs[Strg] or OPs[Strg] then
			return OPs[Strg](Strg, Spell)
		elseif Strg:find('{(.-)}') then
			return Nest(Strg, Spell)
		elseif Strg:find('||') then
			return _OR(Strg, Spell)
		elseif Strg:find('&') then
			return _AND(Strg, Spell)
		elseif Strg:find('[><=!~]') then
			return Comperatores(Strg, Spell)
		elseif Strg:find("[%+%-%*%/]") then
			return StringMath(Strg, Spell)
		else
			return ProcessString(Strg, Spell)
		end
	end,
	['nil'] = function(dsl, Spell) return true end,
	['boolean']	 = function(dsl, Spell) return dsl end,
}

local Deprecated_Warn = {}

function DSL.Get(condition)
	if condition then
		local condition = string.lower(condition)
		if DSL.Conditions[condition] then
			if Deprecated_Warn[condition] then
				NeP.Core.Print(condition..' Was deprecated, use: '..Deprecated_Warn[condition].replace..'instead.')
				Deprecated_Warn[condition] = nil
			end
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

function DSL.RegisterConditon_Deprecated(name, replace, condition, overwrite)
	local name = string.lower(name)
	DSL.RegisterConditon(name, condition, overwrite)
	if not Deprecated_Warn[name] then
		Deprecated_Warn[name] = {}
		Deprecated_Warn[name].replace = replace
	end
end

function DSL.Parse(dsl, Spell)
	if typesTable[type(dsl)] then
		return typesTable[type(dsl)](dsl, Spell)
	end
end