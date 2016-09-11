local RegisterConditon = NeP.DSL.RegisterConditon
--[[
						KEYBINDS CONDITIONS!
			Only submit keybind specific conditions here.
					KEEP ORGANIZED AND CLEAN!


TODO: Find a way to add more keybinds

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

RegisterConditon("modifier.shift", function()
	return IsShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.control", function()
	return IsControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.alt", function()
	return IsAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.lshift", function()
	return IsLeftShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.lcontrol", function()
	return IsLeftControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.lalt", function()
	return IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.rshift", function()
	return IsRightShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.rcontrol", function()
	return IsRightControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("modifier.ralt", function()
	return IsRightAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)