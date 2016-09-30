NeP.Helpers = {}

local spellHasFailed = {}

local function addFailedSpell(GUID, spell)
	if spellHasFailed[GUID] == nil then
		spellHasFailed[GUID] = {}
	end
	spellHasFailed[GUID][spell] = true
end

local UI_Erros = {
	[SPELL_FAILED_NOT_BEHIND] = function(GUID, spell)
		addFailedSpell(GUID, spell)
		spellHasFailed[GUID].behind = false
	end,
	-- infront / LoS
	[50] = function(GUID, spell)
		addFailedSpell(GUID, spell)
		spellHasFailed[GUID].infront = false
	end,
	-- SPELL_FAILED_OUT_OF_RANGE
	[359] = function(GUID, spell)
		addFailedSpell(GUID, spell)
	end,
	[SPELL_FAILED_TOO_CLOSE] = function(GUID, spell)
		addFailedSpell(GUID, spell)
	end
}

function NeP.Helpers.infront(target)
	if target then
		local GUID = UnitGUID(target)
		if GUID and spellHasFailed[GUID] then
			return spellHasFailed[GUID].infront
		end
	end
	return true
end

function NeP.Helpers.SpellSanity(spell, target)
	if target and spell then
		local GUID = UnitGUID(target)
		if GUID and spellHasFailed[GUID] then
			return spellHasFailed[GUID][spell] == nil
		end
	end
	return true
end

NeP.Listener.register("UI_ERROR_MESSAGE", function(error)
	if UI_Erros[error] then
		-- Get the target from the engine
		local unit = NeP.Engine.lastTarget
		local spell = NeP.Engine.lastCast
		if unit and spell then
			local GUID = UnitGUID(unit)
			if GUID then
				UI_Erros[error](GUID, spell)
				UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
			end
		end
	end
end)

C_Timer.NewTicker(1, (function()
	wipe(spellHasFailed)
end), nil)