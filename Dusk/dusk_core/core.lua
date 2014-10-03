--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Core

Wraps up all core libraries and provides an interface for them.
--]]
--------------------------------------------------------------------------------

local core = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_data = require("Dusk.dusk_core.load.data")
local lib_stats = require("Dusk.dusk_core.load.stats")
local lib_tilesets = require("Dusk.dusk_core.load.tilesets")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_tilelayer = require("Dusk.dusk_core.layer.tilelayer")
local lib_objectlayer = require("Dusk.dusk_core.layer.objectlayer")
local lib_imagelayer = require("Dusk.dusk_core.layer.imagelayer")
local lib_functions = require("Dusk.dusk_core.misc.functions")
local lib_update = require("Dusk.dusk_core.run.update")

local display_newGroup = display.newGroup
local type = type
local table_insert = table.insert
local math_ceil = math.ceil
local getSetting = lib_settings.get
local setVariable = lib_settings.setEvalVariable
local removeVariable = lib_settings.removeEvalVariable
local verby_error = verby.error
local verby_alert = verby.alert
local getXY = lib_functions.getXY

--------------------------------------------------------------------------------
-- Load Map
--------------------------------------------------------------------------------
function core.loadMap(filename, base)
	local f1, f2 = filename:find("/?([^/]+%..+)$")
	local actualFileName = filename:sub(f1 + 1, f2)
	local dirTree = {}; for dir in filename:sub(1, f1):gmatch("(.-)/") do table_insert(dirTree, dir) end

	-- Load other things
	local data = lib_data.get(filename, base)
	local stats = lib_stats.get(data); data.stats = stats

	data._dusk = {}
	data._dusk.dirTree = dirTree

	return data, stats
end

--------------------------------------------------------------------------------
-- Build Map
--------------------------------------------------------------------------------
function core.buildMap(data)
	local imageSheets, imageSheetConfig, tileProperties, tileIndex = lib_tilesets.get(data, data._dusk.dirTree)

	setVariable("mapWidth", data.stats.mapWidth)
	setVariable("mapHeight", data.stats.mapHeight)
	setVariable("pixelWidth", data.stats.width)
	setVariable("pixelHeight", data.stats.height)
	setVariable("tileWidth", data.stats.tileWidth)
	setVariable("tileHeight", data.stats.tileHeight)
	setVariable("rawTileWidth", data.stats.rawTileWidth)
	setVariable("rawTileHeight", data.stats.rawTileHeight)
	setVariable("scaledTileWidth", data.stats.tileWidth)
	setVariable("scaledTileHeight", data.stats.tileHeight)

	------------------------------------------------------------------------------
	-- Map Object
	------------------------------------------------------------------------------
	local map = display_newGroup()
	local update

	-- Make sure map appears in same position for all devices
	--map:setReferencePoint(display.TopLeftReferencePoint) -- For older versions of Corona, just uncomment it to use
	map.anchorX, map.anchorY = 0, 0
	map.x, map.y = screen.left, screen.top

	map.layer = {}
	map.props = {}
	map.data = data.stats

	local mapProperties = lib_functions.getProperties(data.properties or {}, "map")
	lib_functions.addProperties(mapProperties, "object", map)
	lib_functions.addProperties(mapProperties, "props", map.props)

	------------------------------------------------------------------------------
	-- Create Layers
	------------------------------------------------------------------------------
	local enableTileCulling = getSetting("enableTileCulling")
	local layerIndex = 0 -- Use a separate variable so that we can keep track of !inactive! layers
	local numLayers = 0

	for i = 1, #data.layers do
		if (data.layers[i].properties or {})["!inactive!"] ~= "true" then
			numLayers = numLayers + 1
		end
	end

	map.data.numLayers = numLayers

	local layerList = {
		tile = {},
		object = {},
		image = {}
	}

	for i = 1, #data.layers do
		if (data.layers[i].properties or {})["!inactive!"] ~= "true" then
			local layer

			-- Pass each layer type to that layer builder
			if data.layers[i].type == "tilelayer" then
				layer = lib_tilelayer.createLayer(data, data.layers[i], i, tileIndex, imageSheets, imageSheetConfig, tileProperties)
				layer._type = "tile"

				-- Tile layer-specific code
				if layer.tileCullingEnabled == nil then layer.tileCullingEnabled = true end
			elseif data.layers[i].type == "objectgroup" then
				layer = lib_objectlayer.createLayer(data, data.layers[i], i, tileIndex, imageSheets, imageSheetConfig)
				layer._type = "object"

				-- Any object layer-specific code
			elseif data.layers[i].type == "imagelayer" then
				layer = lib_imagelayer.createLayer(data.layers[i], data._dusk.dirTree)
				layer._type = "image"

				-- Any image layer-specific code could go here
			end

			layer._name = data.layers[i].name ~= "" and data.layers[i].name or "layer" .. layerIndex
			if layer.cameraTrackingEnabled == nil then layer.cameraTrackingEnabled = true end
			if layer.xParallax == nil then layer.xParallax = 1 end
			if layer.yParallax == nil then layer.yParallax = 1 end
			layer.isVisible = data.layers[i].visible

			--------------------------------------------------------------------------
			-- Add Layer to Map
			--------------------------------------------------------------------------

			map.layer[numLayers - layerIndex] = layer
			map.layer[layer._name] = layer
			map:insert(layer)

			layerIndex = layerIndex + 1
		end
	end

	-- Now we add each layer to the layer list, for quick layer iteration of a specific type
	for i = 1, #map.layer do
		if map.layer[i]._type == "tile" then
			table_insert(layerList.tile, i)
		elseif map.layer[i]._type == "object" then
			table_insert(layerList.object, i)
		elseif map.layer[i]._type == "image" then
			table_insert(layerList.image, i)
		end
	end

	------------------------------------------------------------------------------
	-- Map Methods
	------------------------------------------------------------------------------

	------------------------------------------------------------------------------
	-- Tiles/Pixel Conversion
	------------------------------------------------------------------------------
	function map.tilesToPixels(x, y)
		local x, y = getXY(x, y)

		if not (x ~= nil and y ~= nil) then verby_error("Missing argument(s) to `map.tilesToPixels()`") end

		x, y = x - 0.5, y - 0.5

		return (x * map.data.tileWidth), (y * map.data.tileHeight)
	end

	map.tilesToLocalPixels = map.tilesToPixels

	function map.tilesToContentPixels(x, y)
		local _x, _y = map.tilesToPixels(x, y)
		return map:localToContent(_x, _y)
	end

	------------------------------------------------------------------------------
	-- Pixels/Tiles Conversion
	------------------------------------------------------------------------------
	function map.pixelsToTiles(x, y)
		local x, y = getXY(x, y)

		if x == nil or y == nil then verby_error("Missing argument(s) to `map.pixelsToTiles()`") end

		x, y = map:contentToLocal(x, y)
		return math_ceil(x / map.data.tileWidth), math_ceil(y / map.data.tileHeight)
	end

	------------------------------------------------------------------------------
	-- Is Tile in Map
	------------------------------------------------------------------------------
	function map.isTileWithinMap(x, y)
		local x, y = getXY(x, y)

		if x == nil or y == nil then verby_error("Missing argument(s) to `map.isTileWithinMap()`") end

		return (x >= 1 and x <= map.data.mapWidth) and (y >= 1 and y <= map.data.mapHeight)
	end

	map.tileWithinMap = function(x, y) verby_alert("Warning: `map.tileWithinMap()` is deprecated in favor of `map.isTileWithinMap()`.") return map.isTileWithinMap(x, y) end

	------------------------------------------------------------------------------
	-- Iterators
	------------------------------------------------------------------------------
	function map.tileLayers()
		local i = 0
		return function()
			i = i + 1
			if layerList.tile[i] then
				return map.layer[layerList.tile[i] ], i
			else
				return nil
			end
		end
	end

	function map.objectLayers()
		local i = 0
		return function()
			i = i + 1
			if layerList.object[i] then
				return map.layer[layerList.object[i] ], i
			else
				return nil
			end
		end
	end

	function map.imageLayers()
		local i = 0
		return function()
			i = i + 1
			if layerList.image[i] then
				return map.layer[layerList.image[i] ], i
			else
				return nil
			end
		end
	end

	------------------------------------------------------------------------------
	-- Destroy Map
	------------------------------------------------------------------------------
	function map.destroy()
		update.destroy()

		for i = 1, #map.layer do
			map.layer[i].destroy()
			map.layer[i] = nil
		end

		display.remove(map)
		map = nil
		return true
	end

	------------------------------------------------------------------------------
	-- Finish Up
	------------------------------------------------------------------------------
	update = lib_update.register(map)

	return map
end

return core