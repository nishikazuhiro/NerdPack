local RegisterConditon = NeP.DSL.RegisterConditon_Deprecated

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