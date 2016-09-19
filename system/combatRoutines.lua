local Engine = NeP.Engine
local ClassTable = NeP.Core.ClassTable
-- /dump NeP.Engine.Rotations

function Engine.Compiler(dsl)
	local final_Strg = ''
	-- table tp 1 string
	if type(dsl) == 'table' then
		final_Strg = final_Strg..'{'
		for i=1, #dsl do
			local temp = Engine.Compiler(dsl[i])
			if final_Strg == '{' then
				final_Strg = final_Strg..temp
			elseif temp == 'or' then
				final_Strg = final_Strg..'||'
			else
				final_Strg = final_Strg..'&'..temp
			end
		end
		final_Strg = final_Strg..'}'
	elseif type(dsl) == 'function' then
		final_Strg = 'false'
	else
		final_Strg = dsl
	end
	return final_Strg
end

function Engine.Nest_ToString(_table)
	local Result_Table = {}
	for i=1, #_table do
		local tTable = _table[i]
		if tTable then
			local spell, condition, target = unpack(tTable)
			if type(spell) == 'table' then
				spell = Engine.Nest_ToString(spell)
			end
			spell = NeP.Locale.Spells(spell)
			condition = Engine.Compiler(condition)
			table.insert(Result_Table, {spell, condition, target})
		end
	end
	return Result_Table
end

function Engine.registerRotation(SpecID, CrName, InCombat, OutCombat, initFunc, _SpecConfig)
	local _,_, classIndex = UnitClass('player')
	if ClassTable[classIndex][SpecID] or ClassTable[SpecID] then
		if Engine.Rotations[SpecID] == nil then Engine.Rotations[SpecID] = {} end

		InCombat = Engine.Nest_ToString(InCombat)
		OutCombat = Engine.Nest_ToString(OutCombat)

		Engine.Rotations[SpecID][CrName] = { 
			[true] = InCombat,
			[false] = OutCombat,
			InitFunc = initFunc or (function() return end),
			Name = CrName,
			SpecConfig = nil
		}

		if _SpecConfig then
			Engine.Rotations[SpecID][CrName].SpecConfig = {
				key = CrName,
				title = CrName,
				--subtitle = "",
				profiles = true,
				color = (function() return NeP.Core.classColor('player') end),
				width = 250,
				height = 500,
				config = _SpecConfig
			}
		end

	end
end