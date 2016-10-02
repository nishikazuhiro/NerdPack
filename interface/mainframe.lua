NeP.Interface.MainFrame = NeP.Interface:BuildGUI({
	color = {0,0,0,0.6},
	size = {0, 0},
})
local mainframe = NeP.Interface.MainFrame

mainframe.drag = NeP.Interface:BuildGUI({
	color = {0,0,0,0.1},
	size = {0, 0},
	parent = mainframe,
	loc = {'RIGHT'}
})
mainframe.drag:SetFrameLevel(2)
mainframe.drag:EnableMouse(true)
NeP.Interface:AddText(mainframe.drag, 'DRAG ME!')
mainframe.drag:RegisterForDrag('LeftButton', 'RightButton')
mainframe.drag:SetScript('OnDragStart', function() mainframe:StartMoving() end)
mainframe.drag:SetScript('OnDragStop', function(self)
	mainframe:StopMovingOrSizing()
	mainframe.drag:Hide()
end)

--mainframe.drag:Hide()