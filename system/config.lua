NeP.Config = {}

local data = {}

local toLoad = {}
function NeP.Config.WhenLoaded(func)
	table.insert(toLoad, func)
end

NeP.Listener.register("NeP_Config", "ADDON_LOADED", function(...)
	local addon = ...
	if string.lower(addon) == string.lower(NeP.Info.Name) then
		if nDavG == nil then
			nDavG = {}
			data = nDavG
		else
			data = nDavG
		end
	end
	for i=1, #toLoad do
		toLoad[i]()
	end
end)

function NeP.Config.Read(key, ...)
	key = tostring(key)
	local length = select('#', ...)
	local default
	if length > 0 then
		default = select(length, ...)
	end

	if length <= 1 then
		if data[key] ~= nil then
			return data[key]
		elseif default ~= nil then
			data[key] = default
			return data[key]
		else
			return nil
		end
	end

	local _key = data[key]
	if not _key then
		data[key] = {}
		_key = data[key]
	end
	local __key
	for i = 1, length - 2 do
		__key = tostring(select(i, ...))
		if _key[__key] then
			_key = _key[__key]
		else
			_key[__key] = {}
			_key = _key[__key]
		end
	end
	__key = tostring(select(length - 1, ...))

	if _key[__key] then
		return _key[__key]
	elseif default ~= nil then
		_key[__key] = default
		return default
	end
end

function NeP.Config.Write(key, ...)
	key = tostring(key)
	local length = select('#', ...)
	local value = select(length, ...)

	if length == 1 then
		data[key] = value
		return
	end

	local _key = data[key]
	if not _key then
		data[key] = {}
		_key = data[key]
	end

	local __key
	for i = 1, length - 2 do
		__key = tostring(select(i, ...))
		if _key[__key] then
			_key = _key[__key]
		else
			_key[__key] = {}
			_key = _key[__key]
		end
	end

	__key = tostring(select(length - 1, ...))
	_key[__key] = value
end

function NeP.Config.Toggle(key)
	key = tostring(key)
	data[key] = not data[key]
	return data[key]
end