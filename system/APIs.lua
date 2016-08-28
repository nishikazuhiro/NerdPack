NeP.APIs = {}

local APIs = NeP.APIs

local function rFilter(expires, duration)
	if expires then
		local reactionTime = GetReactionTime()
		expires = expires - reactionTime
		-- Break if debuff is gonna end
		if expires <= reactionTime then
			return false
		-- Break if faster then we can react
		elseif expires > (duration-reactionTime) then
			return false
		end
	end
	return true
end

APIs['UnitBuff'] = function(target, spell, owner)
	local buff, count, caster, expires, spellID
	if tonumber(spell) then
		local go, i = true, 0
		while i <= 40 and go do
			i = i + 1
			buff,_,_,count,_,duration,expires,caster,_,_,spellID = _G['UnitBuff'](target, i)
			if not owner then
				if spellID == tonumber(spell) and (caster == 'player' or caster == 'pet') then
					go = false
				end
			elseif owner == "any" then
				if spellID == tonumber(spell) then
					go = false
				end
			end
		end
	else
		buff,_,_,count,_,duration,expires,caster = _G['UnitBuff'](target, spell)
	end
	-- This adds some random factor
	if rFilter(expires, duration) then
		return buff, count, expires, caster
	end
end

APIs['UnitDebuff'] = function(target, spell, owner)
	local debuff, count, caster, expires, spellID, power
	if tonumber(spell) then
		local go, i = true, 0
		while i <= 40 and go do
			i = i + 1
			debuff,_,_,count,_,duration,expires,caster,_,_,spellID,_,_,_,power = _G['UnitDebuff'](target, i)
			if not owner then
				if spellID == tonumber(spell) and (caster == 'player' or caster == 'pet') then
					go = false
				end
			elseif owner == "any" then
				if spellID == tonumber(spell) then
					go = false
				end
			end
		end
	else
		debuff,_,_,count,_,duration,expires,caster = _G['UnitDebuff'](target, spell)
	end
	-- This adds some random factor
	if rFilter(expires, duration) then
		return debuff, count, expires, caster, power
	end
end
