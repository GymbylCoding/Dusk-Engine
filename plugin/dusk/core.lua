-- ************************************************************************** --
--[[
Dusk Engine Component: Core

Wraps up all core libraries and provides an interface for them.
--]]
-- ************************************************************************** --

local core = {}

-- ************************************************************************** --

local screenInfo = require("plugin.dusk.misc.screenInfo")
local dusk_data = require("plugin.dusk.load.data")
local dusk_tilesets = require("plugin.dusk.load.tilesets")
local dusk_settings = require("plugin.dusk.misc.settings")
local dusk_tileLayer = require("plugin.dusk.layer.tileLayer")
local dusk_objectLayer = require("plugin.dusk.layer.objectLayer")
local dusk_imageLayer = require("plugin.dusk.layer.imageLayer")
local utils = require("plugin.dusk.misc.utils")
local dusk_update = require("plugin.dusk.run.update")

local dusk_mapPrototype = require("plugin.dusk.prototypes.map")

local hasDeflate, deflate = pcall(require, "plugin.dusk.external.deflatelua")
local base64 = require("plugin.dusk.external.base64")

local table_insert = table.insert
local table_remove = table.remove
local math_ceil = math.ceil
local getSetting = dusk_settings.get
local setVariable = dusk_settings.setMathVariable
local removeVariable = dusk_settings.removeMathVariable

local escapedPrefixMethods = getSetting("escapedPrefixMethods")

-- ************************************************************************** --

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


-- ************************************************************************** --
-- ************************************************************************** --

function core.loadMap(filename, base)
	local f1, f2 = filename:find("/?([^/]+%..+)$")
	local actualFileName = filename:sub(f1 + 1, f2)
	local dirTree = {}; for dir in filename:sub(1, f1):gmatch("(.-)/") do dirTree[#dirTree + 1] = dir end

	local data = dusk_data.get(filename, base)
	local stats = utils.getMapStats(data); data.stats = stats

	-- ***** --

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
						error("Compression library not loaded; include the 'bit' plugin to add support for compressed maps or set Tiled to encode layers as CSV or XML. See https://docs.coronalabs.com/plugin/bit/index.html for more information.")
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


-- ************************************************************************** --
-- ************************************************************************** --

function core.buildMap(data)
	local tilesetOptions, imageSheets, imageSheetConfig, tileProperties, tileIndex, tileIDs = dusk_tilesets.get(data, data._dusk.dirTree)
	local escapedPrefixMethods = getSetting("escapedPrefixes")

	setVariable("width", data.stats.width)
	setVariable("height", data.stats.height)
	setVariable("pixelWidth", data.stats.pixelWidth)
	setVariable("pixelHeight", data.stats.pixelHeight)
	setVariable("tileWidth", data.stats.tileWidth)
	setVariable("tileHeight", data.stats.tileHeight)
	setVariable("rawTileWidth", data.stats.rawTileWidth)
	setVariable("rawTileHeight", data.stats.rawTileHeight)
	-- setVariable("scaledTileWidth", data.stats.tileWidth)
	-- setVariable("scaledTileHeight", data.stats.tileHeight)

	-- ***** --
	
	local map = display.newGroup()
	local update
	local mapProperties

	-- ***** --
	
	if data.backgroundcolor and (getSetting("displayBackgroundRectangle") or data.properties.displayBackgroundRectangle) then
		local bkg = display.newRect(0, 0, display.contentWidth - display.screenOriginX * 2, display.contentHeight - display.screenOriginY * 2)
		bkg.x, bkg.y = display.contentCenterX, display.contentCenterY
		map:insert(bkg)
		map.background = bkg
		local r, g, b = tonumber(data.backgroundcolor:sub(2, 3), 16), tonumber(data.backgroundcolor:sub(4, 5), 16), tonumber(data.backgroundcolor:sub(6, 7), 16)
		bkg:setFillColor(r / 255, g / 255, b / 255)
	end

	-- ***** --
	
	map.anchorX, map.anchorY = 0, 0
	map.x, map.y = screenInfo.left, screenInfo.top
	map.layers = {}
	map.props = {}
	map.data = data.stats
	map.data.tilesetImageSheetOptions = tilesetOptions

	-- ***** --

	mapProperties = utils.getProperties(data.properties, data.propertytypes, "map")
	utils.addProperties(mapProperties, "object", map)
	utils.addProperties(mapProperties, "props", map.props)

	-- ***** --
	-- ***** --
	-- ***** --

	local enableTileCulling = getSetting("enableTileCulling")
	local layerIndex = 0 -- Use a separate variable so that we can keep track of !inactive! layers
	local numLayers = 0

	for i = 1, #data.layers do
		if (data.layers[i].properties or {})["!inactive!"] ~= "true" then numLayers = numLayers + 1 end
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

			-- ***** --
			
			if data.layers[i].type == "tilelayer" then
				layer = dusk_tileLayer.createLayer(map, data, data.layers[i], i, tileIndex, imageSheets, imageSheetConfig, tileProperties, tileIDs)
				layer._duskType = "tile"

				if layer.tileCullingEnabled == nil then layer.tileCullingEnabled = true end
			
			-- ***** --
			
			elseif data.layers[i].type == "objectgroup" then
				layer = dusk_objectLayer.createLayer(map, data, data.layers[i], i, tileIndex, imageSheets, imageSheetConfig)
				layer._duskType = "object"

			-- ***** --
			
			elseif data.layers[i].type == "imagelayer" then
				layer = dusk_imageLayer.createLayer(map, data.layers[i], data._dusk.dirTree)
				layer._duskType = "image"
			end

			-- ***** --

			layer._name = data.layers[i].name ~= "" and data.layers[i].name or "layer" .. layerIndex
			if layer.cameraTrackingEnabled == nil then layer.cameraTrackingEnabled = true end
			if layer.xParallax == nil then layer.xParallax = layer.parallax or 1 end
			if layer.yParallax == nil then layer.yParallax = layer.parallax or 1 end
			
			layer.isVisible = data.layers[i].visible
			layer.alpha = data.layers[i].opacity

			-- ***** --

			map.layers[numLayers - layerIndex] = layer
			map.layers[layer._name] = layer
			map:insert(layer)

			layerIndex = layerIndex + 1
		end
	end

	-- ***** --

	for i = 1, #map.layers do
		if map.layers[i]._duskType == "tile" then
			layerList.tile[#layerList.tile + 1] = i
		elseif map.layers[i]._duskType == "object" then
			layerList.object[#layerList.object + 1] = i
		elseif map.layers[i]._duskType == "image" then
			layerList.image[#layerList.image + 1] = i
		end
	end

	-- ************************************************************************ --
	-- ************************************************************************ --
	-- ************************************************************************ --

	map._layerTypes = layerList

	for k, v in pairs(dusk_mapPrototype) do
		map[k] = v
	end

	update = dusk_update.register(map)

	map:addEventListener("finalize", map._finalizeListener)

	return map
end

return core