--------------------------------------------------------------------------------
--[[
Dusk Engine

The main Dusk library.
--]]
--------------------------------------------------------------------------------

local dusk = {}

--------------------------------------------------------------------------------
-- Include Libraries and Localize
--------------------------------------------------------------------------------
local require = require

local dusk_core = require("Dusk.dusk_core.core")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")

local type = type

--------------------------------------------------------------------------------
-- Set/Get Preferences
--------------------------------------------------------------------------------
dusk.setPreference = lib_settings.set
dusk.getPreference = lib_settings.get
dusk.setMathVariable = lib_settings.setMathVariable
dusk.removeMathVariable = lib_settings.removeMathVariable

dusk.registerPlugin = dusk_core.registerPlugin
dusk.unregisterPlugin = dusk_core.unregisterPlugin

--------------------------------------------------------------------------------
-- Load Map
--------------------------------------------------------------------------------
dusk.loadMap = dusk_core.loadMap

--------------------------------------------------------------------------------
-- Build Map
--------------------------------------------------------------------------------
function dusk.buildMap(data, base)
	local map

	if type(data) == "string" then
		local mapData = dusk_core.loadMap(data, base)
		map = dusk_core.buildMap(mapData)
	elseif type(data) == "table" then
		map = dusk_core.buildMap(data)
	end

	map.updateView()

	return map
end

return dusk