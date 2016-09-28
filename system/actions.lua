NeP.Engine.Actions = {}
local Actions = NeP.Engine.Actions
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
Actions['dispelall'] = function()
	for i=1,#NeP.OM['unitFriend'] do
		local Obj = NeP.OM['unitFriend'][i]
		for _,spellID, name, _,_,_, dispelType in LibDisp:IterateDispellableAuras(Obj.key) do
			local spell = GetSpellInfo(spellID)
			if dispelType then
				return NeP.Engine:STRING(spell, Obj.key)
			end
		end
	end
end

-- Automated tauting
Actions['taunt'] = function(args)
	local spell = NeP.Engine:Spell(args)
	if not spell then return false end
	for i=1,#NeP.OM['unitEnemie'] do
		local Obj = NeP.OM['unitEnemie'][i]
		local Threat = UnitThreatSituation("player", Obj.key)
		if Threat and Threat >= 0 and Threat < 3 and Obj.distance <= 30 then
			return NeP.Engine:STRING(spell, Obj.key)
		end
	end
end

-- dots all units
Actions['adots'] = function()
	--FIXME: TODO
end

-- Ress all dead
Actions['ressdead'] = function(args)
	local spell = NeP.Engine:Spell(args)
	if not spell then return false end
	for i=1,#NeP.OM['DeadUnits'] do
		local Obj = NeP.OM['DeadUnits'][i]
		if spell and Obj.distance < 40 and UnitIsPlayer(Obj.Key)
		and UnitIsDeadOrGhost(Obj.key) and UnitPlayerOrPetInParty(Obj.key) then
			return NeP.Engine:STRING(spell, Obj.key)
		end
	end
end

-- Pause
Actions['pause'] = function()
	return (function() end)
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
				return NeP.Engine.UseItem, item, target
			end
		end
	end
end

-- Lib
Actions['@'] = function(lib, target)
	local result = NeP.library.parse(lib:sub(2))
	if result then return (function() end) end
end

-- Macro
Actions['/'] = function(spell, target)
	return NeP.Engine.Macro, spell, target
end

-- These are special Actions
Actions['%'] = function(action, target)
	local arg1, args = action:match('(.+)%((.+)%)')
	if args then action = arg1 end
	action = action:lower():sub(2)
	if Actions[action] then
		return Actions[action](args, target)
	end
end

Actions['!'] = function(spell, target)
	spell = NeP.Engine:Spell(spell:sub(2), target)
	if spell and spell ~= UnitCastingInfo('player') then
		SpellStopCasting()
		return NeP.Engine:STRING(spell, target)
	end
end
			-- Cast this along with current cast
Actions['&'] = function(spell, target)
	spell = NeP.Engine:Spell(spell:sub(2), target)
	if spell then
		return NeP.Engine.Cast, spell, target
	end
end