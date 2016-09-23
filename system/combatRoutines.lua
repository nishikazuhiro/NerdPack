local Engine = NeP.Engine
local ClassTable = NeP.Core.ClassTable

-- WIP
local function BuildGUI(CrName, _SpecConfig)
	return _SpecConfig and {
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

function Engine.registerRotation(SpecID, CrName, InCombat, OutCombat, initFunc, _SpecConfig)
	local _,_, classIndex = UnitClass('player')
	if ClassTable[classIndex][SpecID] or ClassTable[SpecID] then
		if Engine.Rotations[SpecID] == nil then Engine.Rotations[SpecID] = {} end

		Engine.Rotations[SpecID][CrName] = {
			[true] = InCombat,
			[false] = OutCombat,
			InitFunc = initFunc or (function() return end),
			Name = CrName,
			SpecConfig = BuildGUI(CrName, _SpecConfig)
		}

	end
end