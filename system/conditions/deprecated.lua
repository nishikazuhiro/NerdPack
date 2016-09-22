local RegisterConditon = NeP.DSL.RegisterConditon_Deprecated

-- FFS, lets make old crs work again...
-- At some point this will be removed, do not use it!
NeP.DSL.parse = NeP.DSL.Parse
NeP.DSL.get = NeP.DSL.Get
NeP.Interface.CreatePlugin = NeP.Interface.Add
NeP.Interface.CreateSetting = function(name, key)
	C_Timer.After(1, function()
		NeP.Interface.ClassSettings = {
			text = name, 
			func = key, 
			notCheckable = 1
		}
	end)
end

RegisterConditon("modifier.multitarget", "toggle(aoe)", function(target, spell)
	return NeP.DSL.Get("toggle")(nil, "aoe")
end)

RegisterConditon("modifier.cooldowns", "toggle(coodowns)", function(target, spell)
	return NeP.DSL.Get("toggle")(nil, "coodowns")
end)

RegisterConditon("modifier.interrupt", "UNIT.interruptAt(%%)", function(target, spell)
	return NeP.DSL.Get("interruptAt")("target", "40")
end)

RegisterConditon("modifier.shift", "keybind(shift)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "shift")
end)

RegisterConditon("modifier.rshift", "keybind(rshift)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "rshift")
end)

RegisterConditon("modifier.lshift", "keybind(lshift)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "lshift")
end)

RegisterConditon("modifier.control", "keybind(control)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "control")
end)

RegisterConditon("modifier.rcontrol", "keybind(rcontrol)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "rcontrol")
end)

RegisterConditon("modifier.lcontrol", "keybind(lcontrol)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "lcontrol")
end)

RegisterConditon("modifier.alt", "keybind(alt)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "alt")
end)

RegisterConditon("modifier.ralt", "keybind(ralt)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "ralt")
end)

RegisterConditon("modifier.lalt", "keybind(lalt)", function(target, spell)
	return NeP.DSL.Get("keybind")(nil, "lalt")
end)

RegisterConditon("modifier.player", 'UNIT.isPlayer', function()
	return UnitIsPlayer("target")
end)

RegisterConditon("modifier.members", "group.members", function()
	return (GetNumGroupMembers() or 0)
end)

RegisterConditon("party", 'UNIT.ingroup', function(target)
	return UnitInParty(target)
end)

RegisterConditon("raid", 'UNIT.ingroup', function(target)
	return UnitInRaid(target)
end)

RegisterConditon("modifier.party", 'UNIT.ingroup', function()
	return IsInGroup()
end)

RegisterConditon("modifier.raid", 'UNIT.ingroup', function()
	return IsInRaid()
end)

RegisterConditon("isPlayer", function(target)
	return UnitIsUnit(target, 'player')
end)

RegisterConditon("modifier.enemies", 'UNIT.area(DISTANCE).enemies', function()
	return #NeP.OM['unitEnemie']
end)