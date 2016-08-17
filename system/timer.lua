NeP.Timer = {}
local timer = NeP.Timer
local debug = NeP.Core.Debug

local timers = {}

local function onUpdate(self, elapsed)
    for timer, struct in pairs(timers) do
        struct.last = struct.last + elapsed
        if (struct.last > struct.period) then
            debug('timer', 'Timer Fire: ' .. timer)
            struct.event(elapsed)
            struct.last = 0
        end
    end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnUpdate', onUpdate);

function timer.Register(module, _event, _period)
    debug('timer', 'Timer Registered: ' .. module)
    if tonumber(_period) then
            timers[module] = {
            event = _event,
            period = (_period / 1000),
            last = 0
        }
        return
    end
    NeP.Core.Print('Timer Error: ' .. module .. ' has no time period.')
end

function timer.Unregister(module)
    debug('timer', 'Timer Unregistered: ' .. module)
    timers[module] = nil
end

function timer.updatePeriod(module, period)
    timers[module].period = (period / 1000)
end