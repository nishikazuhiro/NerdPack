local TrackedDummys = {
	[31144] = '',		-- Training Dummy - Lvl 80
	[31146] = '',		-- Raider's Training Dummy - Lvl ??
	[32541] = '', 		-- Initiate's Training Dummy - Lvl 55 (Scarlet Enclave)
	[32542] = '',		-- Disciple's Training Dummy - Lvl 65
	[32545] = '',		-- Initiate's Training Dummy - Lvl 55
	[32546] = '',		-- Ebon Knight's Training Dummy - Lvl 80
	[32666] = '',		-- Training Dummy - Lvl 60
	[32667] = '',		-- Training Dummy - Lvl 70
	[46647] = '',		-- Training Dummy - Lvl 85
	[67127] = '',		-- Training Dummy - Lvl 90
	[87318] = '',		-- Dungeoneer's Training Dummy <Damage> ALLIANCE GARRISON
	[87761] = '',		-- Dungeoneer's Training Dummy <Damage> HORDE GARRISON
	[87322] = '',		-- Dungeoneer's Training Dummy <Tanking> ALLIANCE ASHRAN BASE
	[88314] = '',		-- Dungeoneer's Training Dummy <Tanking> ALLIANCE GARRISON
	[88836] = '',		-- Dungeoneer's Training Dummy <Tanking> HORDE ASHRAN BASE
	[88288] = '',		-- Dunteoneer's Training Dummy <Tanking> HORDE GARRISON
	[87317] = '',		-- Dungeoneer's Training Dummy - Lvl 102 (Lunarfall - Damage)
	[87320] = '',		-- Raider's Training Dummy - Lvl ?? (Stormshield - Damage)
	[87329] = '',		-- Raider's Training Dummy - Lvl ?? (Stormshield - Tank)
	[87762] = '',		-- Raider's Training Dummy - Lvl ?? (Warspear - Damage)
	[88837] = '',		-- Raider's Training Dummy - Lvl ?? (Warspear - Tank)
	[88906] = '',		-- Combat Dummy - Lvl 100 (Nagrand)
	[88967] = '',		-- Training Dummy - Lvl 100 (Lunarfall, Frostwall)
	[89078] = '',		-- Training Dummy - Lvl 100 (Lunarfall, Frostwall)
}

function isDummy(Obj)
	return TrackedDummys[UnitID(Obj)] ~= nil
end