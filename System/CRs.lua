NeP.CombatRoutines = {
	CRs = {}
}

local CRs = setmetatable({}, { __index = NeP.CombatRoutines.CRs })

function NeP.CombatRoutines:Add(SpecID, Name, InCombat, OutCombat, ExeOnLoad)
	local _,_, classIndex = UnitClass('player')
	if ClassTable[classIndex][SpecID] or ClassTable[SpecID] then
		CRs[Name] = {}
		CRs[Name].Name = Name
		CRs[Name][true] = setmetatable({}, { __index = InCombat })
		CRs[Name][false] = setmetatable({ __index = OutCombat }, {})
		CRs[Name].Exe = ExeOnLoad
	end
end