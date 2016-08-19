NeP.Engine = {
	Run = false,
	SelectedCR = nil,
	ForceTarget = nil,
	lastCast = nil,
	forcePause = false,
	Current_Spell = nil,
	isGroundSpell = false,
	Rotations = {},
}

local Engine = NeP.Engine
local Core = NeP.Core
local Debug = Core.Debug
local TA = Core.TA
local fK = NeP.Interface.fetchKey

local fakeUnits = {
	{ -- Tank
		token = 'tank',
		unit = function(num) return NeP.Healing['tank'](num) end
	},
	{ -- Lowest
		token = 'lowest',
		unit = function(num) return NeP.Healing['lowest'](num) end
	},
	{ -- Healer
		token = 'healer',
		unit = function(num) return NeP.Healing['healer'](num) end
	},
	{ -- Damager
		token = 'damager',
		unit = function(num) return NeP.Healing['damager'](num) end
	}
}

-- Engine will bypass IsMounted() if unit has any of this mount buff
local ByPassMounts = {
	[165803] = '', -- Telaari Talbuk
	[164222] = '', -- Frostwolf War Wolf
	[221883] = '', -- Divine Steed (pally cd)
	[221887] = '', -- Divine Steed (pally cd)
}

local invItems = {
	['head']		= 'HeadSlot',
	['helm']		= 'HeadSlot',
	['neck']		= 'NeckSlot',
	['shoulder']	= 'ShoulderSlot',
	['shirt']		= 'ShirtSlot',
	['chest']		= 'ChestSlot',
	['belt']		= 'WaistSlot',
	['waist']		= 'WaistSlot',
	['legs']		= 'LegsSlot',
	['pants']		= 'LegsSlot',
	['feet']		= 'FeetSlot',
	['boots']		= 'FeetSlot',
	['wrist']		= 'WristSlot',
	['bracers']		= 'WristSlot',
	['gloves']		= 'HandsSlot',
	['hands']		= 'HandsSlot',
	['finger1']		= 'Finger0Slot',
	['finger2']		= 'Finger1Slot',
	['trinket1']	= 'Trinket0Slot',
	['trinket2']	= 'Trinket1Slot',
	['back']		= 'BackSlot',
	['cloak']		= 'BackSlot',
	['mainhand']	= 'MainHandSlot',
	['offhand']		= 'SecondaryHandSlot',
	['weapon']		= 'MainHandSlot',
	['weapon1']		= 'MainHandSlot',
	['weapon2']		= 'SecondaryHandSlot',
	['ranged']		= 'RangedSlot'
}

-- Register CRs
local ClassTable = NeP.Core.ClassTable
function Engine.registerRotation(SpecID, CrName, InCombat, outCombat, initFunc)
	local _,_, classIndex = UnitClass('player')
	if ClassTable[classIndex][SpecID] or ClassTable[SpecID] then
		if Engine.Rotations[SpecID] == nil then Engine.Rotations[SpecID] = {} end
		Engine.Rotations[SpecID][CrName] = { 
			[true] = InCombat,
			[false] = outCombat,
			['InitFunc'] = initFunc or (function() return end),
			['Name'] = CrName
		}
	end
end

local function insertToLog(whatIs, spell, target)
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
	NeP.MFrame.usedButtons['mastertoggle'].texture:SetTexture(icon)
	NeP.ActionLog.insert('Engine_'..whatIs, name, icon, targetName)
end

local function Cast(spell, target)
	if Engine.isGroundSpell then
		Engine.CastGround(spell, target)
	else
		Engine.Cast(spell, target)
	end
	Engine.lastCast = spell
	insertToLog('Spell', spell, target)
end

local function checkTarget(target)
	local target = target
	target = Engine.ForceTarget or NeP.Engine.FilterUnit(target)
	if string.sub(target, -7) == '.ground' then
		Engine.isGroundSpell = true
		target = string.sub(target, 0, -8)
	end
	if (UnitExists(target) or Engine.isGroundSpell and target == 'mouseover') 
	and Engine.LineOfSight('player', target) then
		return target
	end
end

local function castingTime(target)
    local a_name, _,_,_, a_startTime, a_endTime = UnitCastingInfo("player")
    local b_name, _,_,_, b_startTime, b_endTime = UnitChannelInfo("player")
    local time = GetTime() * 1000
    if a_endTime then return (a_endTime - time) / 1000 end
    if b_endTime then return (b_endTime - time) / 1000 end
    return 0
end

local function IsMountedCheck()
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID then
			if ByPassMounts[tonumber(mountID)] then
				return true
			end
		end
	end
	return not IsMounted()
end

local function canIterate(spell)
	local Iterate, spell, sI = false, spell, false
	local sType = type(spell)
	-- If not Dead and not mounted
	if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
		local castingTime = castingTime('player')
		if castingTime == 0 or sType == 'table' then
			Iterate = true
		end
		if sType == 'string' then
			local pX = string.sub(spell, 1, 1)
			-- Interrupts current cast and cast this instead
			if pX == '!' then
				spell = string.sub(spell, 2);
				if spell ~= Engine.lastCast and castingTime >= 0.5 then
					sI = true
					Iterate = true
				end
			-- Cast this along with current cast
			elseif pX == '&' then
				spell = string.sub(spell, 2);
				Iterate = true
			end
		end
	end
	return Iterate, spell, sI
end

local function castSanityCheck(spell)
	-- Convert Ids to Names
	if string.match(spell, '%d') then
		spell = GetSpellInfo(tonumber(spell))
	end
	if spell then
		-- Make sure we can cast the spell
		local skillType, spellId = GetSpellBookItemInfo(spell)
		local start, duration, enabled = GetSpellCooldown(spell)
		local _, GCD = GetSpellCooldown(61304)
		local isUsable, notEnoughMana = IsUsableSpell(spell)
		if skillType == 'FUTURESPELL' then 
			return
		elseif isUsable and (start <= GCD) and not notEnoughMana then
			Engine.Current_Spell = spell
			return spell
		end
	end
end

local sTriggers = {
	['#'] = function(spell, target, sI)
		Debug('Engine', 'Hit #Item')
		local item = string.sub(spell, 2);
		local invItemReady = true
		if invItems[item] then
			item = GetInventoryItemID("player", GetInventorySlotInfo(invItems[item]))
			invItemReady = GetItemSpell(item) ~= nil
		end
		if invItemReady then
			local isUsable, notEnoughMana = IsUsableItem(item)
			if isUsable then
				local itemStart, itemDuration, itemEnable = GetItemCooldown(item)
				if itemStart == 0 and GetItemCount(item) > 0 then
					if sI then SpellStopCasting() end
					Engine.UseItem(item, target)
					insertToLog('Item', item, target)
					return true
				end
			end
		end
	end,
	['@'] = function(spell)
		if sI then SpellStopCasting() end
		local lib = string.sub(spell, 2);
		return NeP.library.parse(false, spell, lib)
	end,
	['/'] = function(spell)
		if sI then SpellStopCasting() end
		Engine.Macro(spell)
		return true
	end
}

function Engine.FilterUnit(unit)
	if type(unit) == 'nil' then
		unit = 'player'
		if UnitExists('target') then
			unit = 'target'
		end
		return unit
	end
	-- This is needed to reattatch to the string
	local wT, pF = '', ''
	local pX = string.sub(unit, 1, 1)
	if string.find(unit, 'target') then wT = 'target' end
	if pX == '!' then pF = pX end
	-- Find fake units
	for i=1, #fakeUnits do
		local token = fakeUnits[i].token
		if string.find(unit, token) then
			local num = tonumber(string.match(unit, "%d+") or 1)
			local _, x2 = string.match(unit, '(.+)%((.+)%)')
			local unit = fakeUnits[i].unit(num, x2)
			if unit then
				local result = pF..unit..wT
				return result
			end
		end
	end
	return unit
end

-- This iterates the routine table itself.
function Engine.Parse(table)
	for i=1, #table do
		local aR, tP = table[i], type(table[i][1])
		local spell, conditions, target = aR[1], aR[2], aR[3]
		local Iterate, spell, sI = canIterate(spell)
		if Iterate then
			local target = checkTarget(target)
			if target then
				Debug('Engine', 'Can Iterate: '..tP..'_'..tostring(spell)..' With Target: '..tostring(target))
				if tP == 'table' then
					if NeP.DSL.parse(conditions, '') then
						Debug('Engine', 'Hit Table')
						if Engine.Parse(spell) then return true end
					end
				elseif tP == 'function' then
					if NeP.DSL.parse(conditions, '') then
						Debug('Engine', 'Hit Function')
						if spell() then return true end
					end
				elseif tP == 'string' then
					Debug('Engine', 'Hit String')
					local pX = string.sub(spell, 1, 1)
					if string.lower(spell) == 'pause' then
						if NeP.DSL.parse(conditions, '') then
							return true
						end
					elseif sTriggers[pX] then
						if NeP.DSL.parse(conditions, '') then
							if sTriggers[pX](spell, target, sI) then return true end
						end
					else
						Debug('Engine', 'Hit Regular')
						local spell = castSanityCheck(spell)
						if spell and NeP.Engine.SpellRange(spell, target)  then
							if NeP.DSL.parse(conditions, spell) then
								if not (IsHarmfulSpell(spell) and not UnitCanAttack('player', target)) then
									if sI then SpellStopCasting() end
									Cast(spell, target)
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	-- Reset States
	Engine.isGroundSpell = false
	Engine.Current_Spell = nil
	Engine.ForceTarget = nil
	NeP.Helpers.Reset_Helpers()
end

NeP.Timer.Register("nep_parser", function()
	local Running = NeP.DSL.get('toggle')('mastertoggle')
	if Running then
		NeP.FaceRoll:Hide()
		if Engine.SelectedCR then
			if not Engine.forcePause then
				local InCombatCheck = InCombatLockdown()
				local table = Engine.SelectedCR[InCombatCheck]
				-- Break the timers
				if Engine.Parse(table) then return true end
			end
		else
			Core.Message(TA('Engine', 'NoCR'))
		end
	end
end, 0.1, 2)