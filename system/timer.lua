NeP.Timer = {}

local timer = NeP.Timer
local debug = NeP.Core.Debug

local timers = {}

C_Timer.NewTicker(0.1, (function()
	local time = GetTime()
	for i=1, #timers do
		local timer = timers[i]
		if timer.lastCall < time then
			debug('timer', 'Timer Fire: ' .. timer.name)
			timer.callback()
			timer.lastCall = (time + timer.time)
        end
	end
end), nil)

function timer.Sync(_name, time, _callback, _prio)
	debug('timer', 'Timer Registered: ' .. _name)
	timers[#timers+1] = {
		name = _name,
		callback = _callback,
		time = time,
		lastCall = 0,
		prio = _prio or 2
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