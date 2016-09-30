NeP = {
	Info = {
		Name = 'NerdPack',
		Nick = 'NeP',
		Author = 'MrTheSoulz',
		Version = 71.1011,
		Branch = 'BETA',
	},
	Interface = {
		Logo = 'Interface\\AddOns\\NerdPack\\media\\logo.blp',
		addonColor = '0070DE',
		printColor = '|cffFFFFFF',
		mediaDir = 'Interface\\AddOns\\NerdPack\\media\\',
	},
	Core = {},
	Locale = {}
}

local printPrefix = '|r[|cff'..NeP.Interface.addonColor..NeP.Info.Nick..'|r]: '..NeP.Interface.printColor

local locale = GetLocale()
function NeP.Core.TA(gui, index)
	--[[
		"frFR": French (France)
		"deDE": German (Germany)
		"enGB : English (Great Brittan) if returned, can substitute 'enUS' for consistancy
		"enUS": English (America)
		"itIT": Italian (Italy)
		"koKR": Korean (Korea) RTL - right-to-left
		"zhCN": Chinese (China) (simplified) implemented LTR left-to-right in WoW
		"zhTW": Chinese (Taiwan) (traditional) implemented LTR left-to-right in WoW
		"ruRU": Russian (Russia)
		"esES": Spanish (Spain)
		"esMX": Spanish (Mexico)
		"ptBR": Portuguese (Brazil)
	]]
	if NeP.Locale[locale] then
		if NeP.Locale[locale][gui] then
			if NeP.Locale[locale][gui][index] then
				return NeP.Locale[locale][gui][index]
			end
		end
	end
	local string = NeP.Locale['enUS'][gui][index] or 'INVALID STRING'
	return string
end

local lastPrint = ''
function NeP.Core.Print(txt)
	local text = tostring(txt)
	if text ~= lastPrint then
		print(printPrefix..text)
		lastPrint = text
	end
end

local lastMSG = ''
function NeP.Core.Message(txt)
	local text = tostring(txt)
	if text ~= lastMSG then
	message(printPrefix..text)
		lastMSG = text
	end
end

function NeP.Core.Round(num, idp)
	if num then
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	else
		return 0
	end
end

function GetSpellID(spell)
	if not spell or type(spell) == 'number' then return spell end
	local spellID = GetSpellLink(spell):match("spell:(%d+)")
	if spellID then
		return tonumber(spellID)
	end
end

function GetSpellName(spell)
	if spell and type(spell) == 'string' then return spell end
	local spellID = tonumber(spell)
	if spellID then
		return GetSpellInfo(spellID)
	end
	return spell
end

function GetItemID(item)
	if item and type(item) == 'number' then return item end
	local itemID = string.match(select(2, GetItemInfo(item)) or '', 'Hitem:(%d+):')
	if itemID then
		return tonumber(itemID)
	end
end

function GetSpellBookIndex(spell)
	local spellName = GetSpellName(spell)
	if not spellName then return false end
	spellName = string.lower(spellName)

	for t = 1, 2 do
		local _, _, offset, numSpells = GetSpellTabInfo(t)
		local i
		for i = 1, (offset + numSpells) do
			if string.lower(GetSpellBookItemName(i, BOOKTYPE_SPELL)) == spellName then
				return i, BOOKTYPE_SPELL
			end
		end
	end

	local numFlyouts = GetNumFlyouts()
	for f = 1, numFlyouts do
		local flyoutID = GetFlyoutID(f)
		local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID)
		if isKnown and numSlots > 0 then
			for g = 1, numSlots do
				local spellID, _, isKnownSpell = GetFlyoutSlotInfo(flyoutID, g)
				local name = GetSpellName(spellID)
				if name and isKnownSpell and string.lower(GetSpellName(spellID)) == spellName then
					return spellID, nil
				end
			end
		end
	end

	local numPetSpells = HasPetSpells()
	if numPetSpells then
		for i = 1, numPetSpells do
			if string.lower(GetSpellBookItemName(i, BOOKTYPE_PET)) == spellName then
				return i, BOOKTYPE_PET
			end
		end
	end

	return false
end

function hasTalent(row, col)
	local group = GetActiveSpecGroup()
	local talentId, talentName, icon, selected, active = GetTalentInfo(row, col, group)
	return active and selected
end

function UnitID(unit)
	if unit and UnitExists(unit) then
		local guid = UnitGUID(unit)
		if guid then
			local type, _, server_id,_,_, npc_id = strsplit("-", guid)
			if type == "Player" then 
				return tonumber(server_id)
			elseif npc_id then 
				return tonumber(npc_id)
			end
		end
	end
end

local _classColors = {
	['HUNTER'] = 		{ r = 0.67, g = 0.83, 	b = 0.45, 	Hex = 'abd473' },
	['WARLOCK'] = 		{ r = 0.58, g = 0.51, 	b = 0.79, 	Hex = '9482c9' },
	['PRIEST'] = 		{ r = 1.0, 	g = 1.0, 	b = 1.0, 	Hex = 'ffffff' },
	['PALADIN'] = 		{ r = 0.96, g = 0.55, 	b = 0.73, 	Hex = 'f58cba' },
	['MAGE'] = 			{ r = 0.41, g = 0.8, 	b = 0.94, 	Hex = '69ccf0' },
	['ROGUE'] = 		{ r = 1.0, 	g = 0.96, 	b = 0.41, 	Hex = 'fff569' },
	['DRUID'] = 		{ r = 1.0, 	g = 0.49, 	b = 0.04, 	Hex = 'ff7d0a' },
	['SHAMAN'] = 		{ r = 0.0, 	g = 0.44, 	b = 0.87, 	Hex = '0070de' },
	['WARRIOR'] = 		{ r = 0.78, g = 0.61, 	b = 0.43, 	Hex = 'c79c6e' },
	['DEATHKNIGHT'] = 	{ r = 0.77, g = 0.12 , 	b = 0.23, 	Hex = 'c41f3b' },
	['MONK'] = 			{ r = 0.0, 	g = 1.00 , 	b = 0.59, 	Hex = '00ff96' },
	['DEMONHUNTER'] = 	{ r = 0.64, g = 0.19 , 	b = 0.79, 	Hex = 'A330C9' },

}

function NeP.Core.classColor(unit, _type, alpha)
	if _type == nil then _type = 'HEX' end
	if UnitIsPlayer(unit) then
		local class, className = UnitClass(unit)
		local color = _classColors[className]
		if color then
			if _type == 'HEX' then
				return color.Hex
			elseif _type == 'RBG' then
				return color.r, color.g, color.b, alpha
			end
		end
	else
		return 'FFFFFF'
	end
end

--[[0.101 seconds is the current fastest reaction time recorded for human beings.
The average reaction time of human beings is around .215 seconds.
This is determined by the amount of time it takes for people to react when given the proper signal to click]]
function GetReactionTime()
	local rnd = math.random(5, 10) / 10
	return rnd
end

function NeP.string_split(string, delimiter)
	local result, from = {}, 1
	local delim_from, delim_to = string.find(string, delimiter, from)
	while delim_from do
		table.insert( result, string.sub(string, from , delim_from-1))
		from = delim_to + 1
		delim_from, delim_to = string.find(string, delimiter, from)
	end
	table.insert(result, string.sub(string, from))
	return result
end

function NeP.Core.OpenPage(URL)
	local URL = tostring(URL)
	if OpenURL then
		OpenURL(URL)
	else
		NeP.Core.Message('Please Visit:\n'..URL)
	end
end

-- FIXME: WIP
function NeP.Core.Debug(prefix, text)
	
end