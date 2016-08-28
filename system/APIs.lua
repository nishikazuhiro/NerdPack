NeP.APIs = {}

local APIs = NeP.APIs

local function rFilter(expires, duration)
	if expires and expires ~= 0 then
		local expires = expires - GetTime()
		-- Break if debuff is gonna end
		if expires < GetReactionTime() then
			return false
		end
	end
	return true
end

local function oFilter(owner, spell, spellID, caster)
	if not owner then
		if spellID == tonumber(spell) and (caster == 'player' or caster == 'pet') then
			return false
		end
	elseif owner == "any" then
		if spellID == tonumber(spell) then
			return false
		end
	end
	return true
end

APIs['UnitBuff'] = function(target, spell, owner)
	local name, count, caster, expires, spellID
	if tonumber(spell) then
		local go, i = true, 0
		while i <= 40 and go do
			i = i + 1
			name,_,_,count,_,duration,expires,caster,_,_,spellID = _G['UnitBuff'](target, i)
			go = oFilter(owner, spell, spellID, caster)
		end
	else
		name,_,_,count,_,duration,expires,caster = _G['UnitBuff'](target, spell)
	end
	-- This adds some random factor
	if name and rFilter(expires, duration) then
		return name, count, expires, caster
	end
end

APIs['UnitDebuff'] = function(target, spell, owner)
	local name, count, caster, expires, spellID, power
	if tonumber(spell) then
		local go, i = true, 0
		while i <= 40 and go do
			i = i + 1
			name,_,_,count,_,duration,expires,caster,_,_,spellID,_,_,_,power = _G['UnitDebuff'](target, i)
			go = oFilter(owner, spell, spellID, caster)
		end
	else
		name,_,_,count,_,duration,expires,caster = _G['UnitDebuff'](target, spell)
	end
	-- This adds some random factor
	if name and rFilter(expires, duration) then
		return name, count, expires, caster, power
	end
end