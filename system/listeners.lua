NeP.Listener.locals = {
	moving = false,
	movingTime = 0,
	combat = false,
	combatTime = 0
}

NeP.Listener.register("PLAYER_STARTED_MOVING", function(...)
	NeP.Listener.locals.moving = true
	NeP.Listener.locals.movingTime = GetTime()
end)

NeP.Listener.register("PLAYER_STOPPED_MOVING", function(...)
	NeP.Listener.locals.moving = false
	NeP.Listener.locals.movingTime = GetTime()
end)

NeP.Listener.register("PLAYER_REGEN_DISABLED", function(...)
	NeP.Listener.locals.combat = true
	NeP.Listener.locals.combatTime = GetTime()
end)
