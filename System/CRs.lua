NeP.CombatRoutines = {}

local CRs = {}

--/dump NeP.CombatRoutines:GetCR(NeP.CombatRoutines:GetList()[1])['true'][1][1]

function NeP.CombatRoutines:Add(SpecID, Name, InCombat, OutCombat, ExeOnLoad)
	local _,_, classIndex = UnitClass('player')
	if NeP.ClassTable[classIndex][SpecID] or NeP.ClassTable[SpecID] then
		CRs[Name] = {}
		CRs[Name]['Name'] = Name
		CRs[Name]['Exe'] = ExeOnLoad
		CRs[Name]['true'] = setmetatable({}, {__index=InCombat})
		CRs[Name]['false'] = setmetatable({}, {__index=OutCombat})
	end
end

function NeP.CombatRoutines:GetCR(name)
	return CRs[name]
end

function NeP.CombatRoutines:GetList()
	local result = {}
	for k,v in pairs(CRs) do
		result[#result+1] = k
	end
	return result
end