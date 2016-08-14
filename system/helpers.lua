NeP.pHelpers = {
	behind = true,
	infront = true,
	range = true,
	range_failed = {}
}

local UI_Erros = {
	[SPELL_FAILED_NOT_BEHIND] = function()
		NeP.pHelpers.behind = false
	end,
	-- infront / LoS
	[50] = function()
		NeP.pHelpers.infront = false
	end,
	-- SPELL_FAILED_OUT_OF_RANGE
	[359] = function()
		NeP.pHelpers.range = false
	end,
	[SPELL_FAILED_TOO_CLOSE] = function()
		NeP.pHelpers.range = false
	end
}

function NeP.Engine.Reset_Helpers()
	NeP.pHelpers.behind = true
	NeP.pHelpers.infront = true
	NeP.pHelpers.range = true
	wipe(pHelpers.range_failed)
end

function Engine.SpellRange(spell, target)
	if not pHelpers.range then
		if pHelpers.range_failed[spell] then
			return false
		end
		pHelpers.range_failed[spell] = true
		pHelpers.range  = true
	end
	return pHelpers.range and IsSpellInRange(spell, target) ~= 0
end

NeP.Listener.register("UI_ERROR_MESSAGE", function(error)
	if UI_Erros[error] then
		UI_Erros[error]()
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	end
end)