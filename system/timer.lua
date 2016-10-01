NeP.Timer = {}

local timer = NeP.Timer
local debug = NeP.Core.Debug
local timers = {}

C_Timer.NewTicker(0.1, (function()
	if NeP.DSL.Get('toggle')(nil, 'mastertoggle')
	and not NeP.Engine.forcePause then
		local time = GetTime()
		for i=1, #timers do
			local timer = timers[i]
			if timer.lastCall < time then
				pcall(timer.callback)
				timer.lastCall = (time + timer.time)
			end
		end
	end
end), nil)

function timer.Sync(name, time, callback, prio)
    if type(callback) ~= 'function' then return end
	timers[#timers+1] = {
		name = name,
		callback = callback,
		time = time or 1,
		lastCall = 0,
		prio = prio or 2
	}
	table.sort(timers, function(a,b) return a.prio < b.prio end)
end

function timer.Unregister(_name)
	for i=1, #timers do
		local timer = timers[i]
		if timer.name == _name then
			timers[_name] = nil
		end
	end
end