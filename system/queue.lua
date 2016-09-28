local eQueue = {}

local Engine = NeP.Engine

function OverWriteActions()
	for k,v in pairs(NeP.Faceroll.buttonMap) do
		v:SetScript("OnClick", function(self)
			NeP.Engine.Cast_Queue(k)
		end)
	end
	-- we also need to get keybinds!
end

--C_Timer.After(10, function()
--	NeP.Core.Print("loaded queue")
--	OverWriteActions()
--end)

function Engine.Cast_Queue(spell, target)
	-- if the spell already exists in the queue do not add it again
	for i=1, #eQueue do
		if eQueue[i][1] == spell then
			return false
		end
	end
	local time = GetTime()
	eQueue[#eQueue+1] = {spell, nil, target, time}
end

function Engine.clear_Cast_Queue()
	wipe(eQueue)
end

NeP.Timer.Sync("nep_queue", 0.01, function()
	local Running = NeP.DSL.Get('toggle')(nil, 'mastertoggle')
	if Running then
		local time = GetTime()
		for i=1, #eQueue do
			if (time - eQueue[i][4]) > 5 then
				table.remove(eQueue, i)
			else
				local func, spell, target = Engine:Parse(unpack(eQueue[i]))
				if func then
					func(func, spell)
					table.remove(eQueue, i)
				end
			end
		end
	end
end, 1)
