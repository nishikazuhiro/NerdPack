NeP.CombatRoutines = {
	CR = {}
}

local CRs = {}
local smt = setmetatable
local UnitClass = UnitClass

function NeP.CombatRoutines:Add(SpecID, Name, InCombat, OutCombat, ExeOnLoad)
	local classIndex = select(3, UnitClass('player'))
	if NeP.ClassTable[classIndex][SpecID] or classIndex == SpecID then
		if not CRs[SpecID] then
			CRs[SpecID] = {}
		end
		CRs[SpecID][Name] = {}
		CRs[SpecID][Name].Exe = ExeOnLoad
		CRs[SpecID][Name]['true'] = smt({}, {__index=InCombat})
		CRs[SpecID][Name]['false'] = smt({}, {__index=OutCombat})
	end
end

function NeP.CombatRoutines:Set(CR)
	self.CR = CR
	if CR.Exe then
		CR.Exe()
	end
end

function NeP.CombatRoutines:GetList()
	local result = {}
	local Spec = GetSpecializationInfo(GetSpecialization())
	if CRs[Spec] then
		for k,v in pairs(CRs[Spec]) do
			result[k] = CRs[Spec][k]
		end
	end
	return result
end