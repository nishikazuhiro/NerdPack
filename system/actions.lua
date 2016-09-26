NeP.Engine.Actions = {}
local Actions = NeP.Engine.Actions
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
Actions['dispelall'] = function()
	for i=1,#NeP.OM['unitFriend'] do
		local Obj = NeP.OM['unitFriend'][i]
		for _,_, name, _,_,_, dispelType in LibDisp:IterateDispellableAuras(Obj.key) do
			local spellName = GetSpellInfo(spellID)
			if dispelType then
				NeP.Engine.pCast(spellName, Obj.key, false)
				return true
			end
		end
	end
end

-- Automated tauting
Actions['taunt'] = function(_, _, args)
	local spell = NeP.Engine.Spell(args)
	for i=1,#NeP.OM['unitEnemie'] do
		local Obj = NeP.OM['unitEnemie'][i]
		local Threat = UnitThreatSituation("player", Obj.key)
		if Threat and Threat >= 0 and Threat < 3 and Obj.distance <= 30 then
			Cast(spell, Obj.key)
			return true
		end
	end
end

-- dots all units
Actions['adots'] = function()
	--FIXME: TODO
end

-- Ress all dead
Actions['ressdead'] = function(_, _, args)
	local spell = NeP.Engine.Spell(args)
	for i=1,#NeP.OM['DeadUnits'] do
		local Obj = NeP.OM['DeadUnits'][i]
		if spell and Obj.distance < 40 and UnitIsPlayer(Obj.Key)
		and UnitIsDeadOrGhost(Obj.key) and UnitPlayerOrPetInParty(Obj.key) then
			Cast(spell, Obj.key)
			return true
		end
	end
end

-- Pause
Actions['pause'] = function()
	return true
end

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

-- Items
Actions['#'] = function(item, target)
	item = item:sub(2)
	if invItems[item] then
		local invItem = GetInventorySlotInfo(invItems[item])
		item = GetInventoryItemID("player", invItem)
	else
		item = GetItemID(item)
	end
	if item and GetItemSpell(item) then
		local isUsable, notEnoughMana = IsUsableItem(item)
		if isUsable then
			local itemStart, itemDuration, itemEnable = GetItemCooldown(item)
			if itemStart == 0 and GetItemCount(item) > 0 then
				NeP.Engine.UseItem(GetItemInfo(item), target)
				NeP.Engine.insertToLog('Item', item, target)
				return true
			end
		end
	end
end

-- Lib
Actions['@'] = function(lib, target)
	local result = NeP.library.parse(lib:sub(2))
	if result then return result end
end

-- Macro
Actions['/'] = function(spell, target)
	NeP.Engine.Macro(spell)
	return true
end

-- These are special Actions
Actions['%'] = function(action, target)
	local arg1, arg2 = action:match('(.+)%((.+)%)')
	if arg2 then action = arg1 end
	action = action:lower():sub(2)
	local result = Actions[action] and Actions[action](spell, target, arg2)
	if result then return true end
end

Actions['!'] = function(spell, target, isGround)
	spell = NeP.Engine.Spell(spell:sub(2), target)
	if spell and spell ~= UnitCastingInfo('player') then
		SpellStopCasting()
		NeP.Engine.pCast(spell, target, isGround)
		return true
	end
end
			-- Cast this along with current cast
Actions['&'] = function(spell, target, isGround)
	spell = NeP.Engine.Spell(spell:sub(2), target)
	if spell then
		NeP.Engine.pCast(spell, target, isGround)
		return true
	end
end