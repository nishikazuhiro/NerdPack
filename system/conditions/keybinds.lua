--[[
						KEYBINDS CONDITIONS!
			Only submit keybind specific conditions here.
					KEEP ORGANIZED AND CLEAN!


TODO: Find a way to add more keybinds

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

NeP.DSL.RegisterConditon("modifier.shift", function()
	return IsShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.control", function()
	return IsControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.alt", function()
	return IsAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.lshift", function()
	return IsLeftShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.lcontrol", function()
	return IsLeftControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.lalt", function()
	return IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.rshift", function()
	return IsRightShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.rcontrol", function()
	return IsRightControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.ralt", function()
	return IsRightAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)