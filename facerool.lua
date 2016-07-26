local Engine = NeP.Engine
local faceroll = {
	buttonMap = { },
	lastFrame = false,
	rolling = false,
	bars = {
		"ActionButton",
		"MultiBarBottomRightButton",
		"MultiBarBottomLeftButton",
		"MultiBarRightButton",
		"MultiBarLeftButton"
	}
}

NeP.FaceRoll = CreateFrame('Frame', 'activeCastFrame', UIParent)
local activeFrame = NeP.FaceRoll
activeFrame:SetWidth(32)
activeFrame:SetHeight(32)
activeFrame:SetPoint("CENTER", UIParent, "CENTER")
activeFrame.glow = activeFrame:CreateTexture()
activeFrame.glow:SetColorTexture(0,1,1,1)
activeFrame.glow:SetAllPoints(activeFrame)
activeFrame.glow.texture = activeFrame:CreateTexture()
activeFrame.glow.texture:SetTexture("Interface/TARGETINGFRAME/UI-RaidTargetingIcon_8")
--activeFrame.glow.texture:SetVertexColor(0, 1, 0, 1)
activeFrame.glow.texture:SetAllPoints(activeFrame)
activeFrame:SetFrameStrata('HIGH')
activeFrame:Hide()

local frame = CreateFrame("FRAME", "FooAddonFrame");
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", function(self, event, ...)
	wipe(faceroll.buttonMap)
	for _, group in ipairs(faceroll.bars) do
		for i =1, 12 do
			local button = _G[group .. i]
			if button then
				local actionType, id, subType = GetActionInfo(ActionButton_CalculateAction(button, "LeftButton"))
				if actionType == 'spell' then
					local spell = GetSpellInfo(id)
					if spell then
						faceroll.buttonMap[spell] = button
					end
				end
			end
		end
	end
end)

function NeP.Engine.FaceRoll()
	local function showActiveSpell(spell)
		local spellButton = faceroll.buttonMap[spell]
		if spellButton and spell then
			activeFrame:Show()
			activeFrame:SetPoint("CENTER", spellButton, "CENTER")
		end
	end

	-- cast on ground
	function Engine.CastGround(spell, target)
		showActiveSpell(spell)
	end

	-- Cast
	function Engine.Cast(spell, target)
		showActiveSpell(spell)
	end

	-- Macro
	function Engine.Macro(text)
	end

	function Engine.UseItem(name, target)
	end

	function Engine.UseInvItem(slot)
	end

	function Engine.LineOfSight(a, b)
		return true
	end

	-- Distance
	local rangeCheck = LibStub("LibRangeCheck-2.0")
	function Engine.Distance(a, b)
		if UnitExists(b) then
			local minRange, maxRange = rangeCheck:GetRange(b)
			return maxRange or minRange
		end
		return 0
	end

	-- Infront
	function Engine.Infront(a, b)
		return true
	end

	--[[				Generic OM
	---------------------------------------------------]]
	local function GenericFilter(unit)
		if UnitExists(unit) then
			local objectType, _, _, _, _, _id, _ = strsplit('-', UnitGUID(Obj))
			local GUID = tonumber(_id) or '0'
			local alreadyExists = false
			-- Enemie Filter
			if UnitCanAttack('player', unit) then
				for i=1, #NeP.TempOM.unitEnemie do
					local object = NeP.TempOM.unitEnemie[i]
					if object.ID == GUID then
						alreadyExists = true
					end
				end
				-- Friendly Filter
			elseif UnitIsFriend('player', unit) then
				for i=1, #NeP.TempOM.unitFriend do
					local object = NeP.TempOM.unitFriend[i]
					if object.ID == GUID then
						alreadyExists = true
					end
				end
			end
			if not alreadyExists then return true end
		end
		return false
	end

	function NeP.OM.Maker()
		-- Self
		NeP.OM.addToOM('player', 5)
		-- Mouseover
		if UnitExists('mouseover') then
			local object = 'mouseover'
			local ObjDistance = Engine.Distance('player', object)
			if GenericFilter(object) then
				if ObjDistance <= 100 then
					NeP.OM.addToOM(object)
				end
			end
		end
		-- Target Cache
		if UnitExists('target') then
			local object = 'target'
			local ObjDistance = Engine.Distance('player', object)
			if GenericFilter(object) then
				if ObjDistance <= 100 then
					NeP.OM.addToOM(object)
				end
			end
		end
		-- If in Group scan frames...
		if IsInGroup() or IsInRaid() then
			local prefix = (IsInRaid() and 'raid') or 'party'
			for i = 1, GetNumGroupMembers() do
				-- Enemie
				local target = prefix..i..'target'
				local ObjDistance = Engine.Distance('player', target)
				if GenericFilter(target) then
					if ObjDistance <= 100 then
						NeP.OM.addToOM(target)
					end
				end
				-- Friendly
				local friendly = prefix..i
				local ObjDistance = Engine.Distance('player', friendly)
				if GenericFilter(friendly) then
					if ObjDistance <= 100 then
						NeP.OM.addToOM(friendly)
					end
				end
			end
		end
	end
end

NeP.Engine.FaceRoll()
