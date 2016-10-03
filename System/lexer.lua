NeP.Lexer = {}

function NeP.Lexer:Tokenize(eval)
	
end

function NeP.Lexer:STRING(eval)
	local temp = self:Tokenize(eval)
end

function NeP.Lexer:TABLE(eval)
	for i=1, #eval do
		self:eval(eval[i])
	end
end

function NeP.Lexer:FUNCTION(eval)
	eval = {
		type = 'func',
		func = eval
	}
end

function NeP.Lexer:Lex(eval)
	local type = type(eval)
	self[type](self, eval)
end