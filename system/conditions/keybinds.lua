--[[
						KEYBINDS CONDITIONS!
			Only submit keybind specific conditions here.
					KEEP ORGANIZED AND CLEAN!


TODO: Find a way to add more keybinds

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

local KEYBINDS = {
	-- Shift
	['shift'] = function() return IsShiftKeyDown() end,
	['lshift'] = function() return IsLeftShiftKeyDown() end,
	['rshift'] = function() return IsRightShiftKeyDown() end,
	-- Control
	['control'] = function() return IsControlKeyDown() end,
	['lcontrol'] = function() return IsLeftControlKeyDown() end,
	['rcontrol'] = function() return IsRightControlKeyDown() end,
	-- Alt
	['alt'] = function() return IsAltKeyDown() end,
	['lalt'] = function() return IsLeftAltKeyDown() end,
	['ralt'] = function() return IsRightAltKeyDown() end,
}

NeP.DSL.RegisterConditon("keybind", function(_, Arg)
	if Arg and KEYBINDS[string.lower(Arg)] then
		return KEYBINDS[string.lower(Arg)]() and not GetCurrentKeyBoardFocus()
	end
	return false
end)