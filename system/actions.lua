NeP.Engine.Actions = {}
local Actions = NeP.Engine.Actions
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
Actions['dispelall'] = function(eval, args)
	for i=1,#NeP.OM['unitFriend'] do
		local Obj = NeP.OM['unitFriend'][i]
		for _,spellID, name, _,_,_, dispelType in LibDisp:IterateDispellableAuras(Obj.key) do
			local spell = GetSpellInfo(spellID)
			if dispelType then
				eval.spell = spell
				eval.target = Obj.key
				return NeP.Engine:STRING(eval)
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
			eval.spell = spell
			eval.target = Obj.key
			return NeP.Engine:STRING(eval)
		end
	end
end

-- dots all units
Actions['adots'] = function()
	--FIXME: TODO
end

-- Ress all dead
Actions['ressdead'] = function(eval, args)
	local spell = NeP.Engine:Spell(args)
	if not spell then return false end
	for i=1,#NeP.OM['DeadUnits'] do
		local Obj = NeP.OM['DeadUnits'][i]
		if spell and Obj.distance < 40 and UnitIsPlayer(Obj.Key)
		and UnitIsDeadOrGhost(Obj.key) and UnitPlayerOrPetInParty(Obj.key) then
			eval.spell = spell
			eval.target = Obj.key
			return NeP.Engine:STRING(eval)
		end
	end
end

-- Pause
Actions['pause'] = function(eval)
	eval.breaks = true
	return eval
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
Actions['#'] = function(eval)
	item = eval.spell:sub(2)
	if invItems[item] then
		local invItem = GetInventorySlotInfo(invItems[item])
		item = GetInventoryItemID("player", invItem)
	end
	if item and GetItemSpell(item) then
		local name, _,_,_,_,_,_,_,_, icon = GetItemInfo(item)
		local isUsable, notEnoughMana = IsUsableItem(item)
		local ready = select(2, GetItemCooldown(item)) == 0
		if isUsable and ready and (GetItemCount(item) > 0) then
			eval.spell = name
			eval.icon = icon
			eval.func = NeP.Engine.UseItem
			return eval
		end
	end
end

-- Lib
Actions['@'] = function(eval)
	eval.conditions = NeP.DSL.Parse(eval.conditions)
	if eval.conditions then
		local result = NeP.library.parse(lib:sub(2))
		if result then eval.breaks = true end
		return eval
	end 
end

-- Macro
Actions['/'] = function(eval)
	eval.func = NeP.Engine.Macro
	return eval
end

-- These are special Actions
Actions['%'] = function(eval)
	eval.spell = eval.spell:lower():sub(2)
	local arg1, args = eval.spell:match('(.+)%((.+)%)')
	if args then eval.spell = arg1 end
	if Actions[eval.spell] then
		return Actions[eval.spell](eval, args)
	end
end

-- Interrupt and cast
Actions['!'] = function(eval)
	eval.spell = eval.spell:sub(2)
	eval.bypass = true
	eval.si = eval.spell ~= UnitCastingInfo('player')
	return NeP.Engine:STRING(eval)
end

-- Cast this along with current cast
Actions['&'] = function(eval)
	eval.spell = eval.spell:sub(2)
	eval.bypass = true
	return NeP.Engine:STRING(eval)
end