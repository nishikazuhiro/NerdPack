NeP.CombatRoutines = {
	CR = {}
}

local CRs = {}
local UnitClass = UnitClass



function NeP.CombatRoutines:Compile(eval)

end

function NeP.CombatRoutines:Add(SpecID, Name, InCombat, OutCombat, ExeOnLoad)
	local classIndex = select(3, UnitClass('player'))
	if NeP.ClassTable[classIndex][SpecID] or classIndex == SpecID then
		if not CRs[SpecID] then
			CRs[SpecID] = {}
		end
		CRs[SpecID][Name] = {}
		CRs[SpecID][Name].Exe = ExeOnLoad
		CRs[SpecID][Name][true] = NeP.Lexer:Lex(InCombat)
		CRs[SpecID][Name][false] = NeP.Lexer:Lex(OutCombat)
	end
end

function NeP.CombatRoutines:Set(Spec, Name)
	if not CRs[Spec][Name] then
		Name = 'NONE'
	end
	self.CR = CRs[Spec][Name]
	NeP.Config:Write('SELECTED', Spec, Name)
	if self.CR.Exe then
		self.CR.Exe()
	end
end

function NeP.CombatRoutines:GetList(Spec)
	local result = {}
	if CRs[Spec] then
		for k,v in pairs(CRs[Spec]) do
			result[#result+1] = k
		end
	end
	return result
end