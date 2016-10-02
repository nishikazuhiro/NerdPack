NeP.Helpers = {}

local spellHasFailed = {}

local function addToData(GUID)
	if not spellHasFailed[GUID] then
		spellHasFailed[GUID] = {}
	end
end

local UI_Erros = {
	--[SPELL_FAILED_NOT_BEHIND] = function(GUID, spell)
	--	addToData(GUID)
	--	spellHasFailed[GUID].behind = true
	--end,
	--[SPELL_FAILED_TOO_CLOSE] = function(GUID, spell)
	--	addToData(GUID)
	--	spellHasFailed[GUID][spell] = true
	--end
	-- infront / LoS
	[50] = function(GUID, spell)
		addToData(GUID)
		spellHasFailed[GUID].infront = false
	end,
	-- SPELL_FAILED_OUT_OF_RANGE
	[359] = function(GUID, spell)
		addToData(GUID)
		spellHasFailed[GUID][spell] = true
	end,
	-- Cant while moving
	[220] = function(GUID, spell)
		addToData(GUID)
		spellHasFailed[GUID][spell] = true
	end
}

function NeP.Helpers.infront(target)
	if not target then return end
	local GUID = UnitGUID(target)
	if GUID and spellHasFailed[GUID] then
		return (spellHasFailed[GUID].infront)
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
	if not UI_Erros[error] then return end
	local unit, spell = NeP.Engine.lastTarget, NeP.Engine.lastCast
	if unit and spell then
		local GUID = UnitGUID(unit)
		if GUID then
			UI_Erros[error](GUID, spell)
			UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
		end
	end
end)

C_Timer.NewTicker(1, (function()
	wipe(spellHasFailed)
end), nil)