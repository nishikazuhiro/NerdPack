NeP.Config = {}

local data = {}

function NeP.Config.Load()
	local tbl = NeP_Data
	if tbl == nil then
		print('hit')
		tbl = {}
		data = tbl
	else
		data = tbl
	end
end

function NeP.Config.Read(key, ...)
	key = tostring(key)
	local length = select('#', ...)
	local default
	if length > 0 then
		default = select(length, ...)
	end

	if length <= 1 then
		if data[key] then
			return data[key]
		elseif default then
			data[key] = default
			return data[key]
		else
			return nil
		end
	end

	local vKey = data[key]
	if not vKey then
		data[key] = {}
		vKey = data[key]
	end
	local bKey
	for i = 1, length - 2 do
		bKey = tostring(select(i, ...))
		if vKey[bKey] then
			vKey = vKey[bKey]
		else
			vKey[bKey] = {}
			vKey = vKey[bKey]
		end
	end
	bKey = tostring(select(length - 1, ...))

	if vKey[bKey] then
		return vKey[bKey]
	elseif default then
		vKey[bKey] = default
		return default
	end

	return nil
end

function NeP.Config.Write(key, ...)
	key = tostring(key)
	local length = select('#', ...)
	local value = select(length, ...)

	if length == 1 then
		data[key] = value
		return
	end

	local vKey = data[key]
	if not vKey then
		data[key] = {}
		vKey = data[key]
	end
	local bKey
	for i = 1, length - 2 do
		bKey = tostring(select(i, ...))
		if vKey[bKey] then
			vKey = vKey[bKey]
		else
			vKey[bKey] = {}
			vKey = vKey[bKey]
		end
	end

	bKey = tostring(select(length - 1, ...))
	vKey[bKey] = value
end

function NeP.Config.Toggle(key)
	key = tostring(key)
	data[key] = not data[key]
	return data[key]
end