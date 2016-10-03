NeP.CombatRoutines = {
	CRs = {}
}

local smt = setmetatable
local UnitClass = UnitClass
local CRs = smt({}, {__index=NeP.CombatRoutines.CRs})

function NeP.CombatRoutines:Add(SpecID, Name, InCombat, OutCombat, ExeOnLoad)
	local classIndex = select(3, UnitClass('player'))
	if NeP.ClassTable[classIndex][SpecID] or classIndex == SpecID then
		if not CRs[SpecID] then
			CRs[SpecID] = {}
		end
		CRs[SpecID][Name] = {}
		CRs[SpecID][Name]['Exe'] = ExeOnLoad
		CRs[SpecID][Name]['true'] = smt({}, {__index=InCombat})
		CRs[SpecID][Name]['false'] = smt({}, {__index=OutCombat})
	end
end

function NeP.CombatRoutines:GetCR(SpecID, Name)
	return CRs[SpecID] and CRs[SpecID][Name]
end

function NeP.CombatRoutines:GetList()
	local result = {}
	local Spec = GetSpecializationInfo(GetSpecialization())
	local Class = select(3, UnitClass('player'))
	if CRs[Spec] then
		for k,v in pairs(CRs[Spec]) do
			print(k)
			result[#result+1] = k
		end
	end
	if CRs[Class] then
		for k,v in pairs(CRs[Class]) do
			result[#result+1] = k
		end
	end
	return result
end