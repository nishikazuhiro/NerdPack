local logo = '|T'..NeP.Media..'logo.blp:10:10|t'

NeP.Interface.MainFrame = NeP.Interface:BuildGUI({
	color = {0,0,0,0.6},
	size = {100, 0},
	title = logo..NeP.Color..NeP.Name..' v:'..NeP.Version
})

local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", NeP.Interface.MainFrame, "UIDropDownMenuTemplate")
menuFrame:SetPoint("BOTTOMLEFT", NeP.Interface.MainFrame, "BOTTOMLEFT", 0, 0)
menuFrame:Hide()

local function BuildMenu()
	local result = {}
	table.insert(result, {text = logo..'['..NeP.Name..' |rv:'..NeP.Version..']', isTitle = 1, notCheckable = 1})
	local CrList = NeP.CombatRoutines:GetList()
	local Spec = GetSpecializationInfo(GetSpecialization())
	local last = NeP.Config:Read('SELECTED', Spec)
	for Name, CR in pairs (CrList) do
		local temp = {
			text = Name,
			checked = (last == Name),
			func = function()
				NeP.Core:Print('Loaded: '..Name)
				NeP.CombatRoutines:Set(CR)
				NeP.Config:Write('SELECTED', Spec, Name)
			end
		}
		table.insert(result, temp)
	end
	return result
end

function NeP.Interface:DropMenu()
	EasyMenu(BuildMenu(), menuFrame, menuFrame, 0, 0, "MENU")
end

--mainframe.drag:Hide()