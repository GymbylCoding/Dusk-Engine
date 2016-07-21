-- ************************************************************************** --
--[[
Dusk Engine

The main Dusk library.
--]]
-- ************************************************************************** --

local Library = require("CoronaLibrary")

local dusk = Library:new({name = "dusk", publisherId = "com.gymbyl"})

-- ************************************************************************** --

local dusk_core = require("plugin.dusk.core")
local dusk_settings = require("plugin.dusk.misc.settings")

-- ************************************************************************** --

dusk.setConfigOption = dusk_settings.set
dusk.getConfigOption = dusk_settings.get
dusk.setMathVariable = dusk_settings.setMathVariable
dusk.removeMathVariable = dusk_settings.removeMathVariable

dusk.registerPlugin = dusk_core.registerPlugin
-- dusk.unregisterPlugin = dusk_core.unregisterPlugin

dusk.loadMap = dusk_core.loadMap

-- ************************************************************************** --

dusk.buildMap = function(data, base)
	local map

	if type(data) == "string" then
		local mapData = dusk_core.loadMap(data, base)
		map = dusk_core.buildMap(mapData)
	elseif type(data) == "table" then
		map = dusk_core.buildMap(data)
	end

	map:updateView()

	return map
end

return dusk