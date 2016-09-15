NeP.Commands = {}
local Commands = NeP.Commands

function Commands.Register(name, func, ...)
    SlashCmdList[name] = func
    local command = ''
    for i = 1, select('#', ...) do
        command = select(i, ...)
        if strsub(command, 1, 1) ~= '/' then
            command = '/' .. command
        end
        _G['SLASH_'..name..i] = command
    end
end

NeP_CMDTable = {
    -- Master Toggle
    ['mastertoggle'] = function(rest)
        NeP.Interface.toggleToggle('MasterToggle', rest)
	end,
	['mt'] = function(rest) NeP_CMDTable['mastertoggle'](rest) end,
	['toggle'] = function(rest) NeP_CMDTable['mastertoggle'](rest) end,
	['tg'] = function(rest) NeP_CMDTable['mastertoggle'](rest) end,
    -- AoE
    ['aoe'] = function(rest) NeP.Interface.toggleToggle('AoE', rest) end,
    -- CDs
    ['cooldowns'] = function(rest) NeP.Interface.toggleToggle('Cooldowns', rest) end,
    -- Interrupts
    ['interrupts'] = function(rest) NeP.Interface.toggleToggle('Interrupts', rest) end,
    -- Hide
    ['hide'] = function(rest) NePFrame:Hide(); NeP.Core.Print('To Display NerdPack Execute: \n/nep show') end,
	-- Show
	['show'] = function(rest) NePFrame:Show() end,
	-- Version
	['version'] = function(rest) NeP.Core.Print(NeP.Info.Version..' - '..NeP.Info.Branch) end,
	['ver'] = function(rest) NeP_CMDTable['version'](rest) end,
    -- Drag
    ['drag'] = function(rest) NePFrame.NePfDrag:Show() end
}

Commands.Register('NeP', function(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$");
    local command, rest = string.lower(tostring(command)), string.lower(tostring(rest))

    if NeP_CMDTable[command] then
    	NeP_CMDTable[command](rest)
    else
        NeP.Core.Print('Invalid Command')
    end

end, 'nep', 'nerdpack')
