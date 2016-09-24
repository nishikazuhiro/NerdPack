NeP.Engine.Actions = {}
local Actions = NeP.Engine.Actions

-- Dispell all
Actions['dispelall'] = function(_, target, args)
	for i=1,#NeP.Healing.Units do
		local Obj = NeP.Healing.Units[i]
		local dispellType = NeP.Dispells.CanDispellUnit(unit)
		if dispellType then
			local spell = NeP.Dispells.GetSpell(dispellType)
			if spell then
				Cast(spell, Obj.key)
				return true
			end
		end
	end
end

-- Automated tauting
Actions['taunt'] = function(_, target, args)
	if not spell then return end
	for i=1,#NeP.OMActions['unitEnemie'] do
		local Obj = NeP.OMActions['unitEnemie'][i]
		local spell = NeP.Engine.spellResolve(args, Obj.key)
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
Actions['ressdead'] = function(_, target, args)
	for i=1,#NeP.OMActions['DeadUnits'] do
		local Obj = NeP.OMActions['DeadUnits'][i]
		local spell = NeP.Engine.spellResolve(args, Obj.key)
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
				Engine.UseItem(GetItemInfo(item), target)
				Engine.insertToLog('Item', item, target)
				return true
			end
		end
	end
end

-- Lib
Actions['@'] = function(spell, target)
	local result = NeP.library.parse(false, lib, target)
	if result then return result end
end

-- Macro
Actions['/'] = function(spell, target)
	Engine.Macro(spell)
	return true
end

-- These are special Actions
Actions['%'] = function(spell, target)
	local arg1, arg2 = action:match('(.+)%((.+)%)')
	if arg2 then action = arg1 end
	local result = Actions[action] and Actions[action](spell, target, arg2)
	if result then return result end
end

Actions['!'] = function(spell, target)
	SpellStopCasting()
	local result = Engine.STRING(spell, nil, target, true)
	if result then return result end
end
			-- Cast this along with current cast
Actions['&'] = function(spell, target)
	local result = Engine.STRING(spell, nil, target, true)
	if result then return result end
end