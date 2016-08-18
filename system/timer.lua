NeP.Timer = {}

local timer = NeP.Timer
local debug = NeP.Core.Debug

local timers = {}

local function onUpdate(self, elapsed)
    for i=1, #timers do
      local timer = timers[i]
      timer.last = timer.last + elapsed
        if (timer.last > timer.period) then
            --debug('timer', 'Timer Fire: ' .. timer)
            timer.event(elapsed)
            timer.last = 0
        end
    end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnUpdate', onUpdate);

function timer.Register(module, _event, _period, _prio)
    local prio = prio or 2
    debug('timer', 'Timer Registered: ' .. module)
    if tonumber(_period) then
        timers[#timers+1] = {
            event = _event,
            period = (_period / 1000),
            last = 0,
            prio = prio
        }
        table.sort(timers, function(a,b) return a.prio < b.prio end)
    else
        NeP.Core.Print('Timer Error: ' .. module .. ' has no time period.')
    end
end

--function timer.Unregister(module)
--    debug('timer', 'Timer Unregistered: ' .. module)
--    timers[module] = nil
--end

--function timer.updatePeriod(module, period)
--    timers[module].period = (period / 1000)
--end
