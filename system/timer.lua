NeP.Timer = {}

local timer = NeP.Timer
local debug = NeP.Core.Debug
local timers = {}

C_Timer.NewTicker(0.1, (function()
	if NeP.DSL.Get('toggle')(nil, 'mastertoggle')
	and not NeP.Engine.forcePause then
		for i=1, #timers do
			local timer = timers[i]
			--debug('timer', 'Timer Fire: ' .. timer.name)
			timer.callback()
		end
	end
end), nil)

function timer.Sync(name, _, callback, prio)
    if type(callback) ~= 'function' then return end
	--debug('timer', 'Timer Registered: ' .. name)
	timers[#timers+1] = {
		name = name,
		callback = callback,
		--time = time,
		lastCall = 0,
		prio = prio or 2
	}
	table.sort(timers, function(a,b) return a.prio < b.prio end)
end

function timer.Unregister(_name)
	for i=1, #timers do
		local timer = timers[i]
		if timer.name == _name then
			debug('timer', 'Timer Unregistered: ' .. _name)
			timers[_name] = nil
		end
	end
end