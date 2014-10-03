--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Stats

Collects general statistics about a map.
--]]
--------------------------------------------------------------------------------

local lib_stats = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
local screen = require("Dusk.dusk_core.misc.screen")

--------------------------------------------------------------------------------
-- Get Stats
--------------------------------------------------------------------------------
function lib_stats.get(data)
	local stats = {}

	stats.numTiledLayers = #data.layers
	stats.tilesetCount = #(data.tilesets or {})
	stats.orientation = data.orientation
	stats.mapWidth = data.width
	stats.mapHeight = data.height
	stats.rawTileWidth = data.tilewidth
	stats.rawTileHeight = data.tileheight
	stats.tileWidth = data.tilewidth * screen.zoomX
	stats.tileHeight = data.tileheight * screen.zoomY
	stats.width = stats.mapWidth * stats.tileWidth
	stats.height = stats.mapHeight * stats.tileHeight

	return stats
end

return lib_stats