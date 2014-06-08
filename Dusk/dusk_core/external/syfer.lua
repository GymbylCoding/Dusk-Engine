--------------------------------------------------------------------------------
--[[
Syfer Equation Solver

Solves equations in string form.

Includes a full version of the Shunting-Yard Algorithm.

by Caleb Place of Gymbyl Coding
www.github.com/GymbylCoding
www.gymbyl.com
--]]
--------------------------------------------------------------------------------

local syfer = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local tonumber = tonumber
local type = type
local pairs = pairs
local table_insert = table.insert
local table_remove = table.remove
local string_rep = string.rep

local word = "[%w%$]"
local notWord = "[^%w%$]"

-- Each operator in this table gets (1) the precedence, (2) the associativity (1 = left, 2 = right), and (3) the operation that gets executed on the stack.
local operators = {
	["^"] = {4, 2, function(a, b) return a ^ b end},
	["*"] = {3, 1, function(a, b) if type(a) == "string" then return string_rep(a, b) else return a * b end end},
	["/"] = {3, 1, function(a, b) return a / b end},
	["+"] = {2, 1, function(a, b) if type(a) == "string" or type(b) == "string" then return a .. b else return a + b end end},
	["-"] = {2, 1, function(a, b) return a - b end}
}

-- Each function in this table gets only the operation that gets executed on the stack, because they're all unary and need no associativity or precedence
local functions = {
	["neg"] = function(n) return -n end, -- Negate a number
	["abs"] = math.abs,
	["sqrt"] = function(n) return n ^ 0.5 end, -- Faster than math.sqrt
	["cbrt"] = function(n) return n ^ (0.33333333333333) end, -- Cube root
	["sin"] = math.sin,
	["sinh"] = math.sinh,
	["ceil"] = math.ceil,
	["floor"] = math.floor,
	["round"] = math.round,
	["cos"] = math.cos,
	["cosh"] = math.cosh,
	["acos"] = math.acos,
	["atan"] = math.atan,
	["atan2"] = math.atan2,
	["log"] = math.log,
	["log10"] = math.log10,
	["asin"] = math.asin,
	["tan"] = math.tan,
	["deg"] = math.deg,
	["rad"] = math.rad
}

--------------------------------------------------------------------------------
-- Tokenize a String
--------------------------------------------------------------------------------
local function tokenize(str)
	local tokens = {}
	
	str = str:gsub("[\n%s\t]", "")
	str = str:gsub("%-(%b())", "neg%1")
	str = str:gsub("([%+%-%*%/%(%z])%-", "%1#") -- We have to find negative numbers and change the operator in front of them from a minus, because otherwise the algorithm will treat it as a subtraction symbol
	str = str:gsub("^%-", "#") -- Check for the first digit also
	
	local i = 1
	while true do
		local char = str:sub(i, i)
		if char == "" then break end
		local s
		
		if (char:match("%d")) or (char == "#" and str:sub(i + 1, i + 1):match("%d")) then
			local f = str:find("[%+%-%*%/%^%z%)]", i)
			
			if not f then f = str:len() + 1 end
			
			local s = str:sub(i, f - 1)
			
			if char == "#" then s = "-" .. s:sub(2) end
			i = f
			table_insert(tokens, tonumber(s))
		else
			if char:match(word) then
				local f = str:find(notWord, i)
				if not f then f = str:len() + 1 end
				s = str:sub(i, f - 1)
				i = f
				table_insert(tokens, s)
			else
				--if not operators[char] and not char:match("[%(%)]") then print("Evalutation failed: Unexpected character \"" .. char .. "\" found") error() end
				table_insert(tokens, char)
				i = i + 1
			end
		end
	end
	
	--print("tokens: " .. table.concat(tokens, "  "))
	
	return tokens
end

--------------------------------------------------------------------------------
-- Shunting-Yard Algorithm
--------------------------------------------------------------------------------
function syfer.shuntingYard(tokens)
	local output, stack = {}, {}
	
	for i = 1, #tokens do
		local t = tokens[i]
		
		if functions[t] then
			table_insert(stack, t)
		elseif operators[t] then
			local o1 = t
			while true do
				local o2 = stack[#stack]
				if (o2 and operators[o2]) and ((operators[o1][2] == 1 and operators[o1][1] == operators[o2][1]) or (operators[o1][1] < operators[o2][1])) then
					table_insert(output, table_remove(stack))
				else
					break
				end
			end
			
			table_insert(stack, o2)
			table_insert(stack, o1)
		elseif t == "(" then
			table_insert(stack, t)
		elseif t == ")" then
			while true do
				local stackToken = table_remove(stack)
								
				if stackToken == "(" or not stackToken then
					if stackToken then
						-- It's a left parenthesis; all's well
					elseif stackToken == nil then
						print("Evaluation failed: Mismatched parentheses")
						error()
					end
					break
				elseif functions[stackToken] then
					table_insert(output, stackToken)
				else
					table_insert(output, stackToken)
				end
			end
		else
			table_insert(output, t)
		end
	end
	
	while #stack > 0 do
		if stack[#stack] == "(" or stack[#stack] == ")" then print("Evaluation failed: Mismatched parentheses") error() end
		table_insert(output, table_remove(stack))
	end
	
	--print("postfix: " .. table.concat(output, "  "))
	
	return output
end

--------------------------------------------------------------------------------
-- Solve Postfix Equation
--------------------------------------------------------------------------------
function syfer.solvePostfix(eq, vars)
	local stack = {}
	
	local i = 1
	while true do
		if operators[eq[i] ] then
			local a, b = table_remove(stack), table_remove(stack)
			table_insert(stack, operators[eq[i] ][3](b, a))
		elseif functions[eq[i] ] then
			local n = table_remove(stack)
			table_insert(stack, functions[eq[i] ](n))
		elseif vars[eq[i] ] then
			table_insert(stack, vars[eq[i] ])
		elseif eq[i] then
			table_insert(stack, eq[i])
		else
			break
		end

		--print("stack after iteration " .. i .. ": " .. table.concat(stack, "  "))
		i = i + 1
	end
	
	return stack[1]
end

--------------------------------------------------------------------------------
-- Solve an Equation
--------------------------------------------------------------------------------
function syfer.solve(str, vars)
	local tokens = tokenize(str)
	local p = syfer.shuntingYard(tokens)
	local answer = syfer.solvePostfix(p, vars or {})
	return answer
end

--------------------------------------------------------------------------------
-- Finish Up
--------------------------------------------------------------------------------
syfer.operators = operators
syfer.functions = functions

return syfer