function Load_DSL_Test()





local DSL = NeP.DSL

local function Parse(dsl, spell)
	print(dsl, ' - ', spell)
end

-- Routes
local typesTable = {
	['function'] = function(dsl, spell) return dsl() end,
	['table'] = function(dsl, spell)
		local tArray = {[1] = true}
		for k,v in ipairs(dsl) do
			if v == 'or' then
				tArray[#tArray+1] = {}
			elseif tArray[#tArray] then
				local eval = DSL.Parse(v, spell)
				tArray[#tArray] = eval or false
			end
		end
		-- search for "true"
		for i = 1, #tArray do
			if tArray[i] then
				return true
			end
		end
		return false
	end,
	['string'] = function(dsl, spell) 
		-- Lib Call
		if string.sub(dsl, 1, 1) == '@' then
			return NeP.library.parse(false, dsl, 'target')
		else
			return parsez(dsl, spell)
		end
	end,
	['lib'] = function(dsl, spell) return NeP.library.parse(false, dsl, 'target') end,
	['nil'] = function(dsl, spell) return true end,
	['boolean']	 = function(dsl, spell) return dsl end,
}

-- Global Call
function DSL.Parse(dsl, spell)
	return typesTable[dslType](type(dsl), spell)
end






end