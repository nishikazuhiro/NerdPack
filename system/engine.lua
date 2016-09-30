NeP.Engine = {
	ForceTarget = nil,
	lastTarget = nil,
	lastCast = nil,
	forcePause = nil,
	Rotations = {},
}

local Engine = NeP.Engine

local function checkTarget(eval)
	eval.isGroundCast = false
	-- none defined (decide one)
	if not eval.target then
		eval.target = UnitExists('target') and 'target' or 'player'
	else
		-- fake units
		eval.target = NeP.FakeUnits.Filter(target)
		if not eval.target then return end
	end
	-- is it ground?
	if eval.target:sub(-7) == '.ground' then
		eval.isGroundCast = true
		eval.target = eval.target:sub(0,-8)
	end
	-- Sanity checks
	if isGroundCast and eval.target == 'mouseover'
	or UnitExists(eval.target) and UnitIsVisible(eval.target)
	and Engine.LineOfSight('player', eval.target) then
		return eval
	end
end

local function castingTime()
	local time = GetTime()
	local a_endTime = select(6,UnitCastingInfo("player"))
	if a_endTime then return (a_endTime/1000 )-time end
	local b_endTime = select(6,UnitCastingInfo("player"))
	if b_endTime then return (b_endTime/1000)-time end
	return 0
end

local function IsMountedCheck()
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID and NeP.ByPassMounts(mountID) then
			return true
		end
	end
	return not IsMounted()
end

local SpellSanity = NeP.Helpers.SpellSanity

function Engine:Spell(eval)
	spell = self:ConvertSpell(eval.spell)
	if spell and SpellSanity(spell, eval.target) then
		local skillType = GetSpellBookItemInfo(spell)
		local isUsable, notEnoughMana = IsUsableSpell(spell)
		if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
			local GCD = NeP.DSL.Get('gcd')()
			if GetSpellCooldown(spell) <= GCD then
				eval.ready = true
			end
		end
	end
	return eval
end

function Engine:FUNCTION(eval)
	eval.func = eval.spell
	return eval
end

function Engine:TABLE(eval)
	if NeP.DSL.Parse(eval.conditions) then
		for i=1, #eval.spell do
			local sB = Engine:Parse(unpack(eval.spell[i]))
			if sB then
				eval.breaks = true
				return eval
			end
		end
	end
end

function Engine:STRING(eval)
	local pX = eval.spell:sub(1, 1)
	if self.Actions[pX] then
		eval = self.Actions[pX](eval)
	elseif eval.bypass or (castingTime('player') == 0) then
		eval = checkTarget(eval)
		if not eval then return end
		eval = self:Spell(eval)
		if eval.ready then
			eval.func = eval.isGround and self.CastGround or self.Cast
		end
	end
	return eval
end

function Engine:Parse(spell, conditions, target)
	local eval = {
		spell = spell,
		target = target,
		conditions = conditions
	}
	eval.type = type(spell):upper()
	eval = self[eval.type](self, eval)
	if eval and NeP.DSL.Parse(eval.conditions, eval.spell)  then
		if eval.si then SpellStopCasting() end
		if eval.breaks then
			return true
		elseif eval.func then
			if self.ForceTarget then target = self.ForceTarget end
			self.ForceTarget = nil
			self.lastCast = spell
			self.lastTarget = target
			eval.func(eval.spell, eval.target)
			return eval
		end
	end
end

function Engine:ConvertSpell(spell)
	-- Convert Ids to Names
	if spell and spell:find('%d') then
		spell = GetSpellInfo(spell)
		if not spell then return end
	end
	-- locale spells
	spell = NeP.Locale.Spells(spell)
	return spell
end

function Engine:insertToLog(whatIs, spell, target)
	local targetName = UnitName(target or 'player')
	local name, icon
	if whatIs == 'Spell' then
		local spellIndex, spellBook = GetSpellBookIndex(spell)
		if spellBook then
			local spellID = select(2, GetSpellBookItemInfo(spellIndex, spellBook))
			name, _, icon = GetSpellInfo(spellIndex, spellBook)
		else
			name, _, icon = GetSpellInfo(spellIndex)
		end
	elseif whatIs == 'Item' then
		name, _,_,_,_,_,_,_,_, icon = GetItemInfo(spell)
	end
	NeP.Interface.UpdateToggleIcon('mastertoggle', icon)
	NeP.ActionLog.insert('Engine_'..whatIs, name, icon, targetName)
end

NeP.Timer.Sync("nep_parser", 0.1, function()
	local SelectedCR = NeP.Interface.GetSelectedCR()
	if SelectedCR then
		if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
			local table = SelectedCR[InCombatLockdown()]
			Engine:Parse(table)
		end
	else
		local MSG = NeP.Core.TA('Engine', 'NoCR')
		NeP.Core.Message(MSG)
	end
end, 3)
