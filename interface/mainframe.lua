local logo = '|T'..NeP.Media..'logo.blp:10:10|t'

NeP.Interface.MainFrame = NeP.Interface:BuildGUI({
	color = {0,0,0,0.6},
	size = {100, 0},
	title = logo..NeP.Color..NeP.Name..' v:'..NeP.Version
})

local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", NeP.Interface.MainFrame, "UIDropDownMenuTemplate")
menuFrame:SetPoint("BOTTOMLEFT", NeP.Interface.MainFrame, "BOTTOMLEFT", 0, 0)
menuFrame:Hide()

local DropMenu = {
	 { text = "TEST", isTitle = true},
}

function NeP.Interface:DropMenu()
	EasyMenu(DropMenu, menuFrame, menuFrame, 0, 0, "MENU")
end

--mainframe.drag:Hide()