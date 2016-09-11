local LibDispellable = LibStub('LibDispellable-1.0')
local RegisterConditon = NeP.DSL.RegisterConditon
local tlp = NeP.Tooltip

--[[
	state.purge
	state.charm
	state.disarm
	state.disorient
	state.dot
	state.fear
	state.incapacitate
	state.misc
	state.root
	state.silence
	state.sleep
	state.snare
	state.stun
	immune.all
	immune.charm
	immune.disorient
	immune.fear
	immune.incapacitate
	immune.melee
	immune.misc
	immune.silence
	immune.polly
	immune.sleep
	immune.snare
	immune.spell
	immune.stun
]]--

local states = {}
states.status = {
	charm = 		{'^charmed'},
	disarm = 		{'disarmed'},
	disorient = 	{'^disoriented'},
	dot = 			{'damage every.*sec', 'damage per.*sec'},
	fear = 			{'^horrified', '^fleeing', '^feared', '^intimidated', '^cowering in fear', '^running in fear', '^compelled to flee'},
	incapacitate = 	{'^incapacitated', '^sapped'},
	misc = 			{'unable to act', '^bound', '^frozen.$', '^cannot attack or cast spells', '^shackled.$'},
	root = 			{'^rooted', '^immobil', '^webbed', 'frozen in place', '^paralyzed', '^locked in place', '^pinned in place'},
	stun = 			{'^stunned', '^webbed'},
	silence = 		{'^silenced'},
	sleep = 		{'^asleep'},
	snare = 		{'^movement.*slowed', 'movement speed reduced', '^slowed by', '^dazed', '^reduces movement speed'}
}
states.immune = {
	all = 			{'dematerialize', 'deterrence', 'divine shield', 'ice block'},
	charm = 		{'bladestorm', 'desecrated ground', 'grounding totem effect', 'lichborne'},
	disorient = 	{'bladestorm', 'desecrated ground'},
	fear = 			{'berserker rage', 'bladestorm', 'desecrated ground', 'grounding totem','lichborne', 'nimble brew'},
	incapacitate = 	{'bladestorm', 'desecrated ground'},
	melee = 		{'dispersion', 'evasion', 'hand of protection', 'ring of peace', 'touch of karma'},
	misc = 			{'bladestorm', 'desecrated ground'},
	silence = 		{'devotion aura', 'inner focus', 'unending resolve'},
	polly = 		{'immune to polymorph'},
	sleep = 		{'bladestorm', 'desecrated ground', 'lichborne'},
	snare = 		{'bestial wrath', 'bladestorm', 'death\'s advance', 'desecrated ground','dispersion', 'hand of freedom', 'master\'s call', 'windwalk totem'},
	spell = 		{'anti-magic shell', 'cloak of shadows', 'diffuse magic', 'dispersion','massspell reflection', 'ring of peace', 'spell reflection', 'touch of karma'},
	stun = 			{'bestial wrath', 'bladestorm', 'desecrated ground', 'icebound fortitude','grounding totem', 'nimble brew'}
}

RegisterConditon('state.purge', function(target, spell)
	local spell = GetSpellID(GetSpellName(spell))
	return LibDispellable:CanDispelWith(target, spell) 
end)

RegisterConditon('state.charm', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.charm)
end)

RegisterConditon('state.disarm', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.disarm)
end)

RegisterConditon('state.disorient', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.disorient)
end)

RegisterConditon('state.dot', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.dot)
end)

RegisterConditon('state.fear', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.fear)
end)

RegisterConditon('state.incapacitate', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.incapacitate)
end)

RegisterConditon('state.misc', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.misc)
end)

RegisterConditon('state.root', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.root)
end)

RegisterConditon('state.silence', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.silence)
end)

RegisterConditon('state.sleep', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.sleep)
end)

RegisterConditon('state.snare', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.snare)
end)

RegisterConditon('state.stun', function(target, spell)
	return tlp.Scan_Debuff(target, states.status.stun)
end)

RegisterConditon('immune.all', function(target, spell)
	return tlp.Scan_Buff(target, states.all)
end)

RegisterConditon('immune.charm', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.charm)
end)

RegisterConditon('immune.disorient', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.disorient)
end)

RegisterConditon('immune.fear', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.fear)
end)

RegisterConditon('immune.incapacitate', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.incapacitate)
end)

RegisterConditon('immune.melee', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.melee)
end)

RegisterConditon('immune.misc', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.misc)
end)

RegisterConditon('immune.silence', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.silence)
end)

RegisterConditon('immune.poly', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.polly)
end)

RegisterConditon('immune.sleep', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.sleep)
end)

RegisterConditon('immune.snare', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.snare)
end)

RegisterConditon('immune.spell', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.spell)
end)

RegisterConditon('immune.stun', function(target, spell)
	return tlp.Scan_Buff(target, states.immune.stun)
end)
