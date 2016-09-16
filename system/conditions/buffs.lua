local RegisterConditon = NeP.DSL.RegisterConditon
--[[
					BUFFS/DEBUFFS CONDITIONS!
			Only submit BUFF specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

local heroismBuffs = { 32182, 90355, 80353, 2825, 146555 }
RegisterConditon("hashero", function(target, spell)
	for i = 1, #heroismBuffs do
		local SpellName = GetSpellName(heroismBuffs[i])
		local buff = NeP.APIs['UnitBuff']('player', SpellName, "any")
		if buff then return true end
	end
	return false
end)

------------------------------------------ BUFFS -----------------------------------------
------------------------------------------------------------------------------------------
RegisterConditon("buff", function(target, spell)
	local buff,_,_,caster = NeP.APIs['UnitBuff'](target, spell)
	return buff and (caster == 'player' or caster == 'pet')
end)

RegisterConditon("buff.any", function(target, spell)
	local buff,_,_,caster = NeP.APIs['UnitBuff'](target, spell, "any")
	return buff
end)

RegisterConditon("buff.count", function(target, spell)
	local buff,count,_,caster = NeP.APIs['UnitBuff'](target, spell)
	if buff and (caster == 'player' or caster == 'pet') then
		return count
	end
	return 0
end)

RegisterConditon("buff.duration", function(target, spell)
	print('hit')
	local buff,_,expires,caster = NeP.APIs['UnitBuff'](target, spell)
	if buff and (caster == 'player' or caster == 'pet') then
		print((expires - GetTime()))
		return (expires - GetTime())
	end
	return 0
end)

------------------------------------------ DEBUFFS ---------------------------------------
------------------------------------------------------------------------------------------

RegisterConditon("debuff", function(target, spell)
	local debuff,_,_,caster = NeP.APIs['UnitDebuff'](target, spell)
	return debuff and (caster == 'player' or caster == 'pet')
end)

RegisterConditon("debuff.any", function(target, spell)
	local debuff,_,_,caster = NeP.APIs['UnitDebuff'](target, spell, "any")
	return debuff
end)

RegisterConditon("debuff.count", function(target, spell)
	local debuff,count,_,caster = NeP.APIs['UnitDebuff'](target, spell)
	if debuff and (caster == 'player' or caster == 'pet') then
		return count
	end
	return 0
end)

RegisterConditon("debuff.duration", function(target, spell)
	local debuff,_,expires,caster = NeP.APIs['UnitDebuff'](target, spell)
	if debuff and (caster == 'player' or caster == 'pet') then
		return (expires - GetTime())
	end
	return 0
end)