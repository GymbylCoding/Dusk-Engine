--------------------------------------------------------------------------------
--[[
The Runtest file for the multi-tileset test.
--]]
--------------------------------------------------------------------------------

local dusk = require("Dusk.Dusk")

-- Runtest
local function runtest()
	local dusk = require("Dusk.Dusk")
	local map = dusk.buildMap("tests/multi_tileset/map.json")
end

return runtest