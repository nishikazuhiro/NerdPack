-- Time To Death function
-- Made by DarkNemie

-- Return this if no data
local fakeTTD = 99999

-- the public function that this is all about
NeP.TimeToDie = function(unit)
	local ttd = fakeTTD

	if not isDummy(unit) then
		local AVG = NeP.CombatLog.GetAVG_DIFF(unit)
		if AVG >= 1 then
			ttd = UnitHealth(unit) / AVG
		end
	end

	return ttd
end