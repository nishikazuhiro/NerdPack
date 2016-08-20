NeP.Timer = {}

local timer = NeP.Timer
local debug = NeP.Core.Debug

local timers = {}

C_Timer.NewTicker(0.1, (function()
    for i=1, #timers do
        local timer = timers[i]
        debug('timer', 'Timer Fire: ' .. timer.name)
        if timer.callback() then break end
    end
end), nil)

function timer.Sync(_name, _callback, _prio)
    local prio = _prio or 1
    debug('timer', 'Timer Registered: ' .. _name)
    timers[#timers+1] = {
        name = _name,
        callback = _callback,
        prio = _prio
    }
    table.sort(timers, function(a,b) return a.prio < b.prio end)
end

--function timer.Unregister(module)
--    debug('timer', 'Timer Unregistered: ' .. module)
--    timers[module] = nil
--end

--function timer.updatePeriod(module, period)
--    timers[module].period = (period / 1000)
--end
