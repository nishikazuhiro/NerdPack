local LoS_Ignore = {
	76585,77063,77182,77891,
	77893,78981,81318,83745,
	86252,56173,56471,57962,
	55294,56161,52409,87761
}

function NeP.LoS_Ignore(ID)
	for i=1, #LoS_Ignore do
		if tonumber(ID) == LoS_Ignore[i] then
			return true
		end
	end
end