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

local screen = require("Dusk.dusk_core.misc.screen")
local lib_data = require("Dusk.dusk_core.load.data")
local lib_tilesets = require("Dusk.dusk_core.load.tilesets")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_tilelayer = require("Dusk.dusk_core.layer.tilelayer")
local lib_objectlayer = require("Dusk.dusk_core.layer.objectlayer")
local lib_imagelayer = require("Dusk.dusk_core.layer.imagelayer")
local lib_functions = require("Dusk.dusk_core.misc.functions")
local lib_update = require("Dusk.dusk_core.run.update")

local hasDeflate, deflate = pcall(require, "Dusk.dusk_core.external.deflatelua")
local base64 = require("Dusk.dusk_core.external.base64")

local type = type
local tonumber = tonumber
local display_newGroup = display.newGroup
local table_insert = table.insert
local table_remove = table.remove
local math_ceil = math.ceil
local getSetting = lib_settings.get
local setVariable = lib_settings.setMathVariable
local removeVariable = lib_settings.removeMathVariable

local escapedPrefixMethods = getSetting("escapedPrefixMethods")

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------
core.plugins = {}

core.pluginCallbacks = {
	onLoadMap = {},
	onBuildMap = {}
}

function core.registerPlugin(plugin)
	core.plugins[#core.plugins + 1] = plugin
	if plugin.initialize then plugin.initialize(core) end

	if plugin.onLoadMap then
		core.pluginCallbacks.onLoadMap[#core.pluginCallbacks.onLoadMap + 1] = {
			callback = plugin.onLoadMap,
			plugin = plugin
		}
		plugin._dusk_onLoadMapIndex = #core.pluginCallbacks.onLoadMap
	end

	if plugin.onBuildMap then
		core.pluginCallbacks.onBuildMap[#core.pluginCallbacks.onBuildMap + 1] = {
			callback = plugin.onBuildMap,
			plugin = plugin
		}
		plugin._dusk_onBuildMapIndex = #core.pluginCallbacks.onBuildMap
	end

	if plugin.escapedPrefixMethods then
		for k, v in pairs(plugin.escapedPrefixMethods) do
			escapedPrefixMethods[k] = v
		end
	end
end

--------------------------------------------------------------------------------
-- Load Map
--------------------------------------------------------------------------------
function core.loadMap(filename, base)
	local f1, f2 = filename:find("/?([^/]+%..+)$")
	local actualFileName = filename:sub(f1 + 1, f2)
	local dirTree = {}; for dir in filename:sub(1, f1):gmatch("(.-)/") do table_insert(dirTree, dir) end

	-- Load other things
	local data = lib_data.get(filename, base)
	local stats = lib_functions.getMapStats(data); data.stats = stats

	data._dusk = {
		dirTree = dirTree,
		layers = {}
	}
	
	for i = 1, #data.layers do
		data._dusk.layers[i] = {}
		if data.layers[i].type == "tilelayer" then
			if data.layers[i].encoding == "base64" then
        local decoded = {}
        
        if data.layers[i].compression == nil then
          decoded = base64.decode("byte", data.layers[i].data)
        elseif data.layers[i].compression == "zlib" then
          if not hasDeflate then
						error("Compression library not loaded; include the 'bit' plugin to add support for compressed maps. See https://docs.coronalabs.com/plugin/bit/index.html for more information.")
					end
					deflate.inflateZlib({
            input = base64.decode("string", data.layers[i].data),
            output = function(b) decoded[#decoded + 1] = b end
          })
        elseif data.layers[i].compression == "gzip" then
          error("Gzip compression not currently supported.")
        end
        
        local newData = {}
        for i = 1, #decoded, 4 do
          newData[#newData + 1] = base64.glueInt(decoded[i], decoded[i + 1], decoded[i + 2], decoded[i + 3])
        end
        data.layers[i].data = newData
      end
			
			local l, r, t, b = math.huge, -math.huge, math.huge, -math.huge
			local w, h = data.layers[i].width, data.layers[i].height
			for x = 1, w do
				for y = 1, h do
					local d = data.layers[i].data[(y - 1) * w + x]
					if d ~= 0 then
						if x < l then l = x end
						if x > r then r = x end
						if y < t then t = y end
						if y > b then b = y end
					end
				end
			end
			data._dusk.layers[i].leftTile = l
			data._dusk.layers[i].rightTile = r
			data._dusk.layers[i].topTile = t
			data._dusk.layers[i].bottomTile = b
		end
	end

	for i = 1, #core.pluginCallbacks.onLoadMap do
		core.pluginCallbacks.onLoadMap[i].callback(data, stats)
	end

	return data, stats
end

--------------------------------------------------------------------------------
-- Build Map
--------------------------------------------------------------------------------
function core.buildMap(data)
	local tilesetOptions, imageSheets, imageSheetConfig, tileProperties, tileIndex, tileIDs = lib_tilesets.get(data, data._dusk.dirTree)
	local escapedPrefixMethods = getSetting("escapedPrefixes")

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

	if data.backgroundcolor and getSetting("displayBackgroundRectangle") then
		local bkg = display.newRect(0, 0, display.contentWidth - display.screenOriginX * 2, display.contentHeight - display.screenOriginY * 2)
		bkg.x, bkg.y = display.contentCenterX, display.contentCenterY
		map:insert(bkg)
		map.background = bkg
		local r, g, b = tonumber(data.backgroundcolor:sub(2, 3), 16), tonumber(data.backgroundcolor:sub(4, 5), 16), tonumber(data.backgroundcolor:sub(6, 7), 16)
		bkg:setFillColor(r / 255, g / 255, b / 255)
	end

	-- Make sure map appears in same position for all devices
	map.anchorX, map.anchorY = 0, 0
	map.x, map.y = screen.left, screen.top

	map.layer = {}
	map.props = {}
	map.data = data.stats
	map.data.tilesetImageSheetOptions = tilesetOptions

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
				layer = lib_tilelayer.createLayer(map, data, data.layers[i], i, tileIndex, imageSheets, imageSheetConfig, tileProperties, tileIDs)
				layer._type = "tile"

				-- Tile layer-specific code
				if layer.tileCullingEnabled == nil then layer.tileCullingEnabled = true end
			elseif data.layers[i].type == "objectgroup" then
				layer = lib_objectlayer.createLayer(map, data, data.layers[i], i, tileIndex, imageSheets, imageSheetConfig)
				layer._type = "object"

				-- Any object layer-specific code
			elseif data.layers[i].type == "imagelayer" then
				layer = lib_imagelayer.createLayer(map, data.layers[i], data._dusk.dirTree)
				layer._type = "image"

				-- Any image layer-specific code could go here
			end

			layer._name = data.layers[i].name ~= "" and data.layers[i].name or "layer" .. layerIndex
			if layer.cameraTrackingEnabled == nil then layer.cameraTrackingEnabled = true end
			if layer.xParallax == nil then layer.xParallax = layer.parallax or 1 end
			if layer.yParallax == nil then layer.yParallax = layer.parallax or 1 end
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
			layerList.tile[#layerList.tile + 1] = i
		elseif map.layer[i]._type == "object" then
			layerList.object[#layerList.object + 1] = i
		elseif map.layer[i]._type == "image" then
			layerList.image[#layerList.image + 1] = i
		end
	end

	------------------------------------------------------------------------------
	-- Map Methods
	------------------------------------------------------------------------------

	------------------------------------------------------------------------------
	-- Tiles/Pixel Conversion
	------------------------------------------------------------------------------
	function map.tilesToPixels(x, y)
		if not (x ~= nil and y ~= nil) then error("Missing argument(s) to `map.tilesToPixels()`") end
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
		if x == nil or y == nil then error("Missing argument(s) to `map.pixelsToTiles()`") end
		return math_ceil(x / map.data.tileWidth), math_ceil(y / map.data.tileHeight)
	end
	
	map.localPixelsToTiles = map.pixelsToTiles
	
	function map.contentPixelsToTiles(x, y)
		if x == nil or y == nil then error("Missing argument(s) to `map.pixelsToTiles()`") end
		x, y = map:contentToLocal(x, y)
		return math_ceil(x / map.data.tileWidth), math_ceil(y / map.data.tileHeight)
	end

	------------------------------------------------------------------------------
	-- Is Tile in Map
	------------------------------------------------------------------------------
	function map.isTileWithinMap(x, y)
		if x == nil or y == nil then error("Missing argument(s) to `map.isTileWithinMap()`") end
		return (x >= 1 and x <= map.data.mapWidth) and (y >= 1 and y <= map.data.mapHeight)
	end

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

	function map.layers()
		local i = 0
		return function()
			i = i + 1
			if map.layer[i] then
				return map.layer[i], i
			else
				return nil
			end
		end
	end
	
	function map._getTileLayers() return layerList.tile end
	function map._getObjectLayers() return layerList.object end
	function map._getImageLayers() return layerList.image end

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