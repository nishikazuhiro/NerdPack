NeP.Helpers = {
	behind = true,
	infront = true,
	range = true,
	range_failed = {}
}

local Helpers = NeP.Helpers

local UI_Erros = {
	[SPELL_FAILED_NOT_BEHIND] = function()
		Helpers.behind = false
	end,
	-- infront / LoS
	[50] = function()
		Helpers.infront = false
	end,
	-- SPELL_FAILED_OUT_OF_RANGE
	[359] = function()
		Helpers.range = false
	end,
	[SPELL_FAILED_TOO_CLOSE] = function()
		Helpers.range = false
	end
}

function NeP.Engine.SpellRange(spell, target)
	if not Helpers.range then
		if Helpers.range_failed[spell] then
			return false
		end
		Helpers.range_failed[spell] = true
		Helpers.range  = true
	end
	return Helpers.range and (NeP.Engine.Distance('player', 'target') <= 40)
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
		UI_Erros[error]()
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
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

NeP.Timer.Register("nep_Helpers", function()
	Helpers.behind = true
	Helpers.infront = true
	Helpers.range = true
	wipe(Helpers.range_failed)
end, 0.1, 3)