NeP.Listener:Add("NeP_Config", "PLAYER_LOGIN", function(addon)
	local Spec = GetSpecializationInfo(GetSpecialization())
	NeP.CombatRoutines:Add(Spec, 'NONE', {}, {}, function() print('callback') end)
end)