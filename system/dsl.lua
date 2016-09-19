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
	local unitID, rest = strsplit('.', Strg, 2)
	local target =  'player' -- default target
	unitID =  NeP.Engine.FilterUnit(unitID)
	if unitID and UnitExists(unitID) then target = unitID end
	if rest then Strg = rest end
	local Condition = DSL.Get(Strg)
	if Condition then return Condition(target, Args) end
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
	['string'] = function(Strg, Spell)
		local pX = Strg:sub(1, 1)
		if OPs[pX] then
			local Strg = Strg:sub(2);
			return OPs[pX](Strg, Spell)
		elseif OPs[Strg] then
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
local function Deprecated(Strg)
	if Deprecated_Warn[Strg] then
		NeP.Core.Print(Strg..' Was deprecated, use: '..Deprecated_Warn[Strg].replace..'instead.')
		Deprecated_Warn[Strg] = nil
	end
end

function DSL.Get(Strg)
	local fakeC = (function() end)
	if not Strg then return fakeC end
	local Strg = Strg:lower()
	if DSL.Conditions[Strg] then
		Deprecated(Strg)
		return DSL.Conditions[Strg]
	end
	return fakeC
end

function DSL.RegisterConditon(name, condition, overwrite)
	local name = name:lower()
	if not DSL.Conditions[name] or overwrite then
		DSL.Conditions[name] = condition
	end
end

function DSL.RegisterConditon_Deprecated(name, replace, condition, overwrite)
	local name = name:lower()
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