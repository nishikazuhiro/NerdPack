local eQueue = {}

local Engine = NeP.Engine

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

Engine.add_Sync('eQueue_parser', function()
	for i=1, #eQueue do
		local time = GetTime()
		-- if the item in the queue has been there more than 5s,
		-- or if the spell was successfully cast, remove it
		if (((time - eQueue[i][4]) > 5) or Engine.Parse({eQueue[i]})) then
			table.remove(eQueue, i)
			break
		end
	end
end, 1)
