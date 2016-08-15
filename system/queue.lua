local eQueue = {}

local Engine = NeP.Engine

function Engine.Cast_Queue(spell, target)
	-- if the spell already exists in the queue do not add it again
	for i=1, #eQueue do
		if eQueue[i][1] = spell then
			return false
		end
	end
	eQueue[#eQueue+1] = {spell, nil, target}
end

function Engine.clear_Cast_Queue()
	wipe(eQueue)
end

Engine.add_Sync('eQueue_parser', function()
	for i=1, #eQueue do
		if Engine.Parse({eQueue[i]}) then
			table.remove(eQueue, i)
		end
	end
end, 1)
