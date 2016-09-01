NeP.Helpers = {
	behind = true,
	infront = true,
	range = true,
}

local Helpers = NeP.Helpers
local spellHasFailed = {}

local function addFailedSpell(GUID, spell)
	if spellHasFailed[GUID] == nil then
		spellHasFailed[GUID] = {}
	end
	spellHasFailed[GUID][spell] = true
end

local UI_Erros = {
	[SPELL_FAILED_NOT_BEHIND] = function(GUID, spell)
		NeP.Helpers.behind = false
		addFailedSpell(GUID, spell)
	end,
	-- infront / LoS
	[50] = function(GUID, spell)
		Helpers.infront = false
		addFailedSpell(GUID, spell)
	end,
	-- SPELL_FAILED_OUT_OF_RANGE
	[359] = function(GUID, spell)
		Helpers.range = false
		addFailedSpell(GUID, spell)
	end,
	[SPELL_FAILED_TOO_CLOSE] = function(GUID, spell)
		Helpers.range = false
		addFailedSpell(GUID, spell)
	end
}

function NeP.Helpers.SpellSanity(spell, target)
	if target and spell then
		local GUID = UnitGUID(target)
		if GUID and spellHasFailed[GUID] then
			return spellHasFailed[GUID][spell] == nil
		end
	end
	return true
end

function Helpers.specInfo()
	local Spec = GetSpecialization()
	local localizedClass, englishClass, classIndex = UnitClass('player')
	local SpecInfo = classIndex
	if Spec then
		SpecInfo = GetSpecializationInfo(Spec)
	end
	return SpecInfo
end 

function Helpers.GetSpecTables()
	local SpecInfo = Helpers.specInfo()
	if NeP.Engine.Rotations[SpecInfo] then
		return NeP.Engine.Rotations[SpecInfo]
	end
end

function Helpers.GetSelectedSpec()
	local SpecInfo = Helpers.specInfo()
	local Selected = NeP.Config.Read('NeP_SlctdCR_'..SpecInfo)
	return Helpers.GetSpecTables()[Selected] or { 
			[true] = {},
			[false] = {},
			['InitFunc'] = (function() return end),
			['Name'] = 'NONE'
		}
end

function Helpers.updateSpec()
	local SlctdCR = Helpers.GetSelectedSpec()
	if SlctdCR then
		NeP.Interface.ResetToggles()
		NeP.Interface.ResetSettings()
		NeP.Engine.SelectedCR = SlctdCR
		SlctdCR['InitFunc']()
	end
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

NeP.Listener.register("PLAYER_LOGIN", function(...)
	Helpers.updateSpec()
	NeP.Listener.register("PLAYER_SPECIALIZATION_CHANGED", function(unitID)
		if unitID == 'player' then
			Helpers.updateSpec()
		end
	end)
end)

C_Timer.NewTicker(1, (function()
	Helpers.behind = true
	Helpers.infront = true
	Helpers.range = true
	wipe(spellHasFailed)
end), nil)