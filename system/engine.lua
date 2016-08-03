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
local Parse = NeP.DSL.parse
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

function NeP.Engine.FilterUnit(unit)
	local unit = tostring(unit)
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

local ListClassSpec = {
	[0] = {}, -- None
	[1] = { -- Warrior
		[71] = 'Arms',
		[72] = 'Fury',
		[73] = 'Protection',
	},
	[2] = {  -- Paladin
		[65] = 'Holy',
		[66] = 'Protection',
		[70] = 'Retribution',
	},
	[3] = { -- Hunter
		[253] = 'Beast Mastery',
		[254] = 'Marksmanship',
		[255] = 'Survival',
	},
	[4] = { -- Rogue
		[259] = 'Assassination',
		[260] = 'Combat',
		[261] = 'Subtlety',
	},
	[5] = {  -- Priest
		[256] = 'Discipline',
		[257] = 'Holy',
		[258] = 'Shadow',
	},
	[6] = { -- DeathKnight
		[250] = 'Blood',
		[251] = 'Frost',
		[252] = 'Unholy',
	},
	[7] = {  -- Shaman
		[262] = 'Elemental',
		[263] = 'Enhancement',
		[264] = 'Restoration',
	},
	[8] = {  -- Mage
		[62] = 'Arcane',
		[63] = 'Fire',
		[64] = 'Frost',
	},
	[9] = { -- Warlock
		[265] = 'Affliction',
		[266] = 'Demonology',
		[267] = 'Destruction',
	},
	[10] = { -- Monk
		[268] = 'Brewmaster',
		[269] = 'Windwalker',
		[270] = 'Mistweaver',
	},
	[11] = { -- Druid
		[102] = 'Balance',
		[103] = 'Feral Combat',
		[104] = 'Guardian',
		[105] = 'Restoration',
	},
	[12] = { -- Demon Hunter
		[577] = 'Havoc',
		[581] = 'Vengeance',
	}
}

-- Register CRs
function Engine.registerRotation(SpecID, CrName, InCombat, outCombat, initFunc)
	-- Only Load Crs for our current class (saves memory)
	local Spec = GetSpecialization() or 0
	local SpecInfo = GetSpecializationInfo(Spec)
	local localizedClass, englishClass, classIndex = UnitClass('player')
	if ListClassSpec[tonumber(classIndex)][tonumber(SpecID)]
	or ListClassSpec[tonumber(SpecID)] then
		-- If SpecID Table is not created yet, create one.
		if Engine.Rotations[SpecID] == nil then Engine.Rotations[SpecID] = {} end
		-- In case someone tries to load a cr with the same name of a existing one
		local TableName = CrName
		if Engine.Rotations[SpecID][CrName] then TableName = CrName..'_'..math.random(0,1000) end
		-- Create CR table
		Engine.Rotations[SpecID][TableName] = { 
			[true] = InCombat,
			[false] = outCombat,
			['InitFunc'] = initFunc or (function() return end),
			['Name'] = CrName
		}
	end
end


local function insertToLog(whatIs, spell, target)
	local targetName = UnitName(target or 'none')
	local name, icon
	if whatIs == 'Spell' then
		local spellIndex, spellBook = GetSpellBookIndex(spell)
		if spellBook then
			local spellID = select(2, GetSpellBookItemInfo(spellIndex, spellBook))
			name, _, icon = GetSpellInfo(spellIndex, spellBook)
		else
			name, _, icon = GetSpellInfo(spellIndex)
		end
	elseif whatIs == 'Item' or whatIs == 'InvItem' then
		name, _,_,_,_,_,_,_,_, icon = GetItemInfo(spell)
	end
	NeP.MFrame.usedButtons['MasterToggle'].texture:SetTexture(icon)
	NeP.ActionLog.insert('Engine_'..whatIs, name, icon, targetName)
end

local function Cast(spell, target, ground)
	if ground then
		Engine.CastGround(spell, target)
	else
		Engine.Cast(spell, target)
	end
	Engine.lastCast = spell
	insertToLog('Spell', spell, target)
end

local function checkTarget(spell, target)
	local ground = false
	local target = target
	-- decide a target
	if type(target) == 'nil' then
		if UnitExists('target') then
			target = 'target'
		else
			target = 'player'
		end
	end
	if type(spell) == 'string' then
		-- Allow functions/conditions to force a target
		if Engine.ForceTarget then
			target = Engine.ForceTarget	
		end
		-- Ground target
		if string.sub(target, -7) == '.ground' then
			ground = true
			target = string.sub(target, 0, -8)
		end
		-- Fake Target
		target = NeP.Engine.FilterUnit(target)
		-- Sanity Checks
		if ground and target == 'mouseover' then
			return true, target, ground
		elseif IsHarmfulSpell(spell) and not UnitCanAttack('player', target) then
			return false, target, false
		elseif UnitExists(target) and Engine.LineOfSight('player', target) then
			return true, target, ground
		end
		return false, target, ground
	end
	return true, target, ground
end

local function castingTime(target)
    local _,_,_,_,_, endTime= UnitCastingInfo(target)
    if endTime then return endTime end
    return 0
end

local function InterruptCast(spell)
	local pX = string.sub(spell, 1, 1)
	if pX == '!' then
		spell = string.sub(spell, 2);
		local castingTime = castingTime('player')
		if not castingTime or castingTime > 1 then
			return spell, true
		end
	end
	return spell, false
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

local function canIterate(pX)
	-- If not Dead and not mounted
	if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
		local tP, pX = type(px), nil
		if tP == 'string' then pX = string.sub(pX, 1, 1) end
		local nCasting = UnitCastingInfo('player') == nil
		local nChanneling = UnitChannelInfo('player') == nil
		-- If not Casting, channeling or should interrupt
		if nCasting and nChanneling or pX == '!' then
			return true
		end
	end
	return false
end

local sTrigger = {
	-- Item
	['#'] = function(spell, target, sI)
		Debug('Engine', 'Hit #Item')
		local item = string.sub(spell, 2);
		-- Inventory (Gear)
		if invItems[tostring(item)] then
			local item = invItems[tostring(item)]
			local item_X = GetInventoryItemID("player", GetInventorySlotInfo(item))
			local isUsable, notEnoughMana = IsUsableItem(item_X)
			if isUsable then
				local itemStart, itemDuration, itemEnable = GetItemCooldown(item_X)
				if itemStart == 0 then
					if sI then SpellStopCasting() end
					insertToLog('InvItem', item_X, target)
					Engine.UseInvItem(GetInventorySlotInfo(item))
					return true
				end
			end
		-- Normal
		else
			local isUsable, notEnoughMana = IsUsableItem(item)
			if isUsable then
				local itemStart, itemDuration, itemEnable = GetItemCooldown(item)
				if itemStart == 0 and GetItemCount(item) > 0 then
					if sI then SpellStopCasting() end
					insertToLog('Item', item, target)
					Engine.UseItem(item, target)
					return true
				end
			end
		end
	end,
	-- Lib
	['@'] = function(spell, target)
		local lib = string.sub(spell, 2);
		NeP.library.parse(false, spell, lib)
		return true
	end,
	-- Macro
	['/'] = function(spell, target, sI)
		if sI then SpellStopCasting() end
		Engine.Macro(spell)
		return true
	end
}

local function castSanityCheck(spell)
	if type(spell) == 'string' and spell ~= 'pause' then
		local pX = string.sub(spell, 1, 1)
		if not sTrigger[pX] then
			local spell, sI = InterruptCast(spell)
			-- Turn string to number (If they'r IDs)
			if string.match(spell, '%d') then
				spell = tonumber(spell)
				-- SOME SPELLS DO NOT CAST BY IDs! (make them names...)
				spell = GetSpellInfo(spell)
			end
			if spell then
				-- Make sure we have the spell
				local skillType, spellId = GetSpellBookItemInfo(tostring(spell))
				if skillType == 'FUTURESPELL' then 
					return false
				-- Spell Sanity Checks
				elseif IsUsableSpell(spell) then
					if GetSpellCooldown(spell) < 1 then
						Engine.Current_Spell = spell
						return true, spell, sI
					end 
				end
			end
			return false
		end
	end
	return true, spell, false
end

local pTypes = {
	['table'] = function(spell, target)
		Debug('Engine', 'Hit Table')
		Engine.Iterate(spell)
	end,
	['function'] = function(spell, target)
		Debug('Engine', 'Hit Function')
		spell()
		return true
	end,
	['string'] = function(spell, target, sI)
		Debug('Engine', 'Hit String')
		local pX = string.sub(spell, 1, 1)
		-- Pause
		if spell == 'pause' then
			Debug('Engine', 'Hit Pause')
			return true
		-- Special trigers
		elseif sTrigger[pX] then
			local sb = sTrigger[pX](spell, target, sI)
			return sb
		-- Regular sanity checks
		else
			if sI then SpellStopCasting() end
			Debug('Engine', 'Hit Regular')
			Cast(spell, target, Engine.isGroundSpell)
			return true
		end
	end
}

-- This iterates the routine table itself.
function Engine.Iterate(table)
	for i=1, #table do
		local aR, tP = table[i], type(table[i][1])
		if pTypes[tP] and canIterate(aR[1]) then
			local canCast, spell, sI = castSanityCheck(aR[1])
			if canCast and Parse(aR[2], spell) then
				Debug('Engine', 'Iterate: '..tP..'_'..tostring(spell))
				local hasTarget, target, ground = checkTarget(spell, aR[3])
				Engine.isGroundSpell = ground 
				if hasTarget then
					Debug('Engine', 'Passed Target: '..tostring(UnitName(target)))
					local sB = pTypes[tP](spell, target, sI)
					if sB then break end
				end
			end
		end
	end
	-- Reset States
	Engine.isGroundSpell = false
	Engine.Current_Spell = nil
	Engine.ForceTarget = nil
end

function NeP.Core.updateSpec()
	local Spec = GetSpecialization()
	local localizedClass, englishClass, classIndex = UnitClass('player')
	local pLvL = UnitLevel('player')
	if Spec and pLvL >= 10 then
		local SpecInfo = GetSpecializationInfo(Spec)
		if NeP.Engine.Rotations[SpecInfo] then
			local SlctdCR = NeP.Config.Read('NeP_SlctdCR_'..SpecInfo)
			if NeP.Engine.Rotations[SpecInfo][SlctdCR] then
				NeP.Interface.ResetToggles()
				NeP.Interface.ResetSettings()
				NeP.Engine.SelectedCR = NeP.Engine.Rotations[SpecInfo][SlctdCR]
				NeP.Engine.Rotations[SpecInfo][SlctdCR]['InitFunc']()
			end
		end
	-- Basic CRs (When no spec available)
	elseif NeP.Engine.Rotations[classIndex] then
		local SlctdCR = NeP.Config.Read('NeP_SlctdCR_'..classIndex)
		if NeP.Engine.Rotations[classIndex][SlctdCR] then
			NeP.Interface.ResetToggles()
			NeP.Interface.ResetSettings()
			NeP.Engine.SelectedCR = NeP.Engine.Rotations[classIndex][SlctdCR]
			NeP.Engine.Rotations[classIndex][SlctdCR]['InitFunc']()
		end
	end
end

-- Engine Ticker
local LastTimeOut = 0
C_Timer.NewTicker(0.1, (function()
	local Running = NeP.Config.Read('bStates_MasterToggle', false)
	if Running and not Engine.forcePause then
		-- Hide FaceRoll.
		NeP.FaceRoll:Hide()
		-- Run the engine.
		if Engine.SelectedCR then
			local InCombatCheck = UnitAffectingCombat('player')
			local table = Engine.SelectedCR[InCombatCheck]
			Engine.Iterate(table)
		else
			Core.Message(TA('Engine', 'NoCR'))
		end
	end
end), nil)