--[[
Dot Table Writer
v1.1

Adds a value to a table by navigating through a string.

Originally for the Dusk Engine.

by Caleb Place of Gymbyl Coding
www.github.com/GymbylCoding
www.gymbyl.com
--]]

-- Localize
local json					= require("json")
local tonumber			= tonumber
local type					= type

-- Convert a string key or value to a key or value
local function toV(value) local v if type(v)=="string" then if value=="true" or value=="false" then if value=="true" then v=true else v=false end elseif value:match("[+-]?%d+%.?[%d]+")==value then v=tonumber(value) elseif value:match("^!json!") then v=json.decode(value:sub(7)) else if value:sub(1,1)=="\"" and value:sub(-1)=="\"" then v=value:sub(2, -2) else v=value end end else v=value end return v end
local function toK(key) local tonum = tonumber(key) if tonum then return tonum else if key:match("^\".+\"$") then key=key:sub(2, -2) end return key end end

local k = "[%w_%-%+\"\'!@#$%^&*%(%)]+" -- Pattern to match names with

--------------------------------------------------------------------------------
-- Main Function
--------------------------------------------------------------------------------
local function dot(t, str, v)
	local t = t
	local write = t -- Table we edit
	local i = 1

	while (true) do -- Loop until manually broken
		local n1, n2 = str:find(k, i) -- Find next occurence of a valid name

		if n1 and n2 then
			local key = str:sub(n1, n2) -- The actual key
			i = n2 + 1

			if str:match(k, i) then -- Still key(s) left after this one
				local K = toK(key)

				if not write[K] then
					write[K] = {} -- Give a parent and a key
				end

				write = write[K] -- Change to next table
			else -- End of list
				local V = toV(v)
				local K = toK(key)
				write[K] = V -- Add the value
				break
			end
		else
			break
		end
	end

	t = write -- Clean up
end

return dot