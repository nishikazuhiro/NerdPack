NeP.Lexer = {}

function NeP.Lexer:Tokenize(eval)
	
end

function NeP.Lexer:STRING(eval)
	local temp = self:Tokenize(eval)
end

function NeP.Lexer:TABLE(eval)
	for i=1, #eval do
		self:Lex(eval[i])
	end
end

function NeP.Lexer:FUNCTION(eval)
	eval = {
		type = 'func',
		func = eval
	}
end

function NeP.Lexer:Lex(eval)
	local type = type(eval):upper()
	print(type)
	if self[type] then
		self[type](self, eval)
	end
end