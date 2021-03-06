NeP.library = {
	libs = { }
}

NeP.library.register = function(name, lib)
	if not NeP.library.libs[name] then
		NeP.library.libs[name] = lib
	end
end

NeP.library.fetch = function(name)
	return NeP.library.libs[name]
end

NeP.library.parse = function(evaluation)
	if string.sub(evaluation, -1) == ')' then
		return loadstring('return NeP.library.libs.'..evaluation)()
	else
		local a, b = strsplit(".", evaluation, 2)
		return NeP.library.libs[a][b]()
	end
end