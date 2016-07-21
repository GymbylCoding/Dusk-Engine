--------------------------------------------------------------------------------
--[[
Bang

A super-lightweight (only ~44 SLOC, and nearly as many lines of explanatory
comments as there are lines of code itself!) serialization notation, with a
focus on conciseness, simplicity, and clarity. It eliminates the need for extra
text (including unquoted strings, optional commas, no brackets around the base
table - in other words, no boilerplate code like JSON requires), but remains
extremely readable and clear.

Syntax Pointers:
- Keys and values can be of any type, just as in Lua
- Commas are optional
- Single or double-quoted strings or long strings (long strings are triple-
	quoted) are all ok, as well as unquoted strings if the string is a valid
	identifier (i.e. thisIsOkay123); long strings ignore a leading newline if it
	exists
- Tables are surrounded in {}, but not the base table - if you surround the base
	table with {}, you'll get an array of length 1 with your data inside it
--]]
--------------------------------------------------------------------------------

local lib_bang = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local lpeg = require("lpeg")

local tonumber = tonumber
local table_concat = table.concat
local P = lpeg.P
local C = lpeg.C
local Ct = lpeg.Ct
local R = lpeg.R
local S = lpeg.S
local V = lpeg.V

local Any = P(1)
local None = P(0)
local Escape = P("\\")
local Skip = S(" \n\t") ^ 0
local EndOfInput = None + Skip
local Separator = S(" \n\t,") ^ 1

--------------------------------------------------------------------------------
-- Patterns
--------------------------------------------------------------------------------
local Number = C((R("09") ^ 1 * "." * R("09") ^ 0) + (P(".") * R("09") ^ 1) + R("09") ^ 1) / tonumber
local Identifier = C((R("AZ") + R("az") + "_") * (R("AZ") + R("az") + "_" + R("09")) ^ 0)
local EscapeSequence = Escape * (C("\"") + C("\'") + (P("n") / "\n") + (P("t") / "\t"))

local String =
	(P('"""') * P("\n") ^ -1 * Ct(((EscapeSequence) + C(Any - '"""')) ^ 0) / table_concat * P('"""')) + -- Double block string
	(P("'''") * P("\n") ^ -1 * Ct(((EscapeSequence) + C(Any - "'''")) ^ 0) / table_concat * P("'''")) + -- Single block string
	(P('"') * Ct(((EscapeSequence) + C(Any - '"')) ^ 0) / table_concat * P('"')) + -- Double quoted string
	(P("'") * Ct(((EscapeSequence) + C(Any - "'")) ^ 0) / table_concat * P("'")) + -- Single quoted string
	Identifier                                                                     -- Unquoted string

local Boolean = (P("true") / function() return true end + P("false") / function() return false end)

local Table = C({P("{") * ((Any - (S("{}"))) + V(1)) ^ 0 * "}"}) / function(t) return lib_bang.read(t:sub(2,-2)) end

local Value = Boolean + String + Table + Number

local KeyValuePair = (Value * Skip * ":" * Skip * Value) / function(k, v) return true, k, v end
local ArrayValue = Value / function(v) return false, 0, v end
local TableElement = KeyValuePair + ArrayValue

local KeyValueSequence = Ct(TableElement ^ -1 * ((Separator + Skip) * TableElement) ^ 0)

--------------------------------------------------------------------------------
-- Read Function
--------------------------------------------------------------------------------
function lib_bang.read(str)
	local match = KeyValueSequence:match(str)
	local t = {}

	for i = 1, #match, 3 do
		local isKeyValuePair, key, val = match[i], match[i + 1], match[i + 2]
		if isKeyValuePair then
			t[key] = val
		else
			t[#t + 1] = val
		end
	end

	return t
end

return lib_bang