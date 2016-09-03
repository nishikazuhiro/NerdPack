NeP.Listener = {}

local listeners = {}

local function onEvent(self, event, ...)
	if not listeners[event] then return end

	for i = 1, #listeners[event] do
		listeners[event][i].callback(...)
	end
end

local frame = CreateFrame('Frame', 'NeP_Events')
frame:SetScript('OnEvent', onEvent)

function NeP.Listener.register(name, event, callback)
	if not callback then
		name, event, callback = 'default', name, event
	end
	if not listeners[event] then
		frame:RegisterEvent(event)
		listeners[event] = {}
	end
	table.insert(listeners[event], { name = name, callback = callback })
end

function NeP.Listener.unregister(name, event, callback)
	if not callback then
		name, callback = 'default', name
	end
	if listeners[event] then
		for i = 1, #listeners[event] do
			if listeners[event][i].name == name or listeners[event][i].callback == callback then
				table.remove(listeners[event], i)
			end
		end
		if #listeners[event] == 0 then
			listeners[event] = nil
			frame:UnregisterEvent(event)
		end
	end
end

function NeP.Listener.trigger(event, ...)
	onEvent(nil, event, ...)
end