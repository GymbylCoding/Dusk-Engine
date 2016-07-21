-- ************************************************************************** --
--[[
Dusk Engine Component: Object Grid

Stores a grid of objects used for object culling.
--]]
-- ************************************************************************** --

local dusk_objectGrid = {}

-- ************************************************************************** --

local objectGridPrototype = require("plugin.dusk.prototypes.objectGrid")

-- ************************************************************************** --

function dusk_objectGrid.new()
	local grid = {}
	
	grid.cells = {}
	
	for k, v in pairs(objectGridPrototype) do
		grid[k] = v
	end
	
	return grid
end

return dusk_objectGrid