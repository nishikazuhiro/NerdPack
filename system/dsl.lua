NeP.DSL = {
	Conditions = {}
}

local DSL = NeP.DSL

local tokens = {
	{ 'string', { '^\'.-\'', '^".-"' } },
	{ 'logic', { '^and', '^or', '^&&', '^||', '^&', '^|' } },
	{ 'constant', { '^true', '^false', '^nil', '^null' } },
	{ 'comparator', { '^>=', '^=>',	'^>', '^<=', '^=<', '^<', '^==', '^!=', '^~=', '^=' } },
	{ 'not', { '^not', '^!' } },
	{ 'identifier', {'^[_%a][_%w]*'} },
	{ 'number', { '^%d+%.?%d*', '^%d+%.?%d*', '^%.%d+' } },
	{ 'operator', {'^[%*/%-%+%%^]'} },
	{ 'character', {'^[@,:\'%(%){}%[%]%.#%$~`\\\";?%s]'} },
}

local function Tokenize(Strg, ignore)
	local list = {}
	local index = 1
	local length = #Strg + 1
	while index < length do
		local found = false
		for i = 1, #tokens do
			local token, patterns = tokens[i][1], tokens[i][2]
			if ignore[token] then break end
			for j = 1, #patterns do
				local sI, eI = Strg:find(patterns[j], index)
				if sI then
					index = eI + 1
					found = true
					list[#list+1] = {kind = token, value = Strg:sub(sI, eI), from = sI, to = eI}
					break
				end
			end
			if found then break end
		end
		if not found then return list end
	end
	return list
end

function DSL:Parse(Strg, Spell)
	if Strg == nil then return true end
	local result = Tokenize(Strg, { space = false })
	return false
end

function DSL:Get(Strg)
	Strg = Strg:lower()
	if DSL.Conditions[Strg] then
		Deprecated(Strg)
		return DSL.Conditions[Strg]
	end
end

function DSL:RegisterConditon(name, condition, overwrite)
	local name = name:lower()
	if not DSL.Conditions[name] or overwrite then
		DSL.Conditions[name] = condition
	end
end