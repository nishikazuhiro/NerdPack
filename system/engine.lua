NeP.Engine = {
	ForceTarget = nil,
	lastTarget = nil,
	lastCast = nil,
	forcePause = nil,
	Rotations = {},
}

local Engine = NeP.Engine

local function checkTarget(target)
	local isGroundCast = false
	-- none defined (decide one)
	if not target then
		target = UnitExists('target') and 'target' or 'player'
	else
		-- fake units
		target = NeP.FakeUnits.Filter(target)
		if not target then return end
	end
	-- is it ground?
	if target:sub(-7) == '.ground' then
		isGroundCast = true
		target = target:sub(0,-8)
	end
	-- Sanity checks
	if isGroundCast and target == 'mouseover'
	or UnitExists(target) and UnitIsVisible(target)
	and Engine.LineOfSight('player', target) then
		return target, isGroundCast
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

function Engine.Spell(spell, target)
	spell = Engine.ConvertSpell(spell)
	if spell and SpellSanity(spell, target) then
		local skillType = GetSpellBookItemInfo(spell)
		local isUsable, notEnoughMana = IsUsableSpell(spell)
		if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
			local GCD = NeP.DSL.Get('gcd')()
			if GetSpellCooldown(spell) <= GCD then
				return spell
			end
		end
	end
end

function Engine.FUNCTION(spell, conditions)
	local result = NeP.DSL.Parse(conditions) and spell()
	if result then return true end
end

function Engine.TABLE(nest, conditions)
	if NeP.DSL.Parse(conditions) then
		for i=1, #nest do
			local result = Engine.Parse(unpack(nest[i]))
			if result then return true end
		end
	end
end

function Engine.STRING(spell, conditions, target)
	local pX = spell:sub(1, 1)
	if Engine.Actions[pX] and NeP.DSL.Parse(conditions) then
		local result = Engine.Actions[pX](spell, target)
		if result then return true end
	elseif (castingTime('player') == 0) then
		local target, isGround = checkTarget(target)
		spell = Engine.Spell(spell, target)
		if spell and NeP.DSL.Parse(conditions, spell) then
			Engine.pCast(spell, target, isGround)
			return true
		end
	end
end

function Engine.Parse(spell, conditions, target)
	if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
		local tP = type(spell):upper()
		local result = Engine[tP] and Engine[tP](spell, conditions, target)
		if result then return true end
	end
	-- Reset States
	Engine.isGroundSpell = false
	Engine.ForceTarget = nil
end

function Engine.ConvertSpell(spell)
	-- Convert Ids to Names
	if spell and spell:find('%d') then
		spell = GetSpellInfo(spell)
		if not spell then return end
	end
	-- locale spells
	spell = NeP.Locale.Spells(spell)
	return spell
end

function Engine.insertToLog(whatIs, spell, target)
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

function Engine.pCast(spell, target, isGround)
	if Engine.ForceTarget then
		target = Engine.ForceTarget
	end
	if isGround then
		Engine.CastGround(spell, target)
	else
		Engine.Cast(spell, target)
	end
	Engine.lastCast = spell
	Engine.lastTarget = target
	Engine.insertToLog('Spell', spell, target)
end

NeP.Timer.Sync("nep_parser", 0.1, function()
	local SelectedCR = NeP.Interface.GetSelectedCR()
	if SelectedCR then
		local table = SelectedCR[InCombatLockdown()]
		Engine.Parse(table)
	else
		local MSG = NeP.Core.TA('Engine', 'NoCR')
		NeP.Core.Message(MSG)
	end
end, 3)
