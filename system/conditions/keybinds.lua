local RegisterConditon = NeP.DSL.RegisterConditon
--[[
						KEYBINDS CONDITIONS!
			Only submit keybind specific conditions here.
					KEEP ORGANIZED AND CLEAN!


TODO: Find a way to add more keybinds

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

RegisterConditon("keybind.shift", function()
	return IsShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.control", function()
	return IsControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.alt", function()
	return IsAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.lshift", function()
	return IsLeftShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.lcontrol", function()
	return IsLeftControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.lalt", function()
	return IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.rshift", function()
	return IsRightShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.rcontrol", function()
	return IsRightControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

RegisterConditon("keybind.ralt", function()
	return IsRightAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)