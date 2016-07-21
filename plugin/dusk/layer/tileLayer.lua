-- ************************************************************************** --
--[[
Dusk Engine Component: Tile Layer

Builds a tile layer from data.
--]]
-- ************************************************************************** --

local dusk_tileLayer = {}

-- ************************************************************************** --

local screen = require("plugin.dusk.misc.screenInfo")
local dusk_settings = require("plugin.dusk.misc.settings")
local utils = require("plugin.dusk.misc.utils")

local tileLayerPrototype = require("plugin.dusk.prototypes.tileLayer")

local string_len = string.len
local tonumber = tonumber
local tostring = tostring
local pairs = pairs
local unpack = unpack
local type = type
local getSetting = dusk_settings.get
local setVariable = dusk_settings.setEvalVariable
local removeVariable = dusk_settings.removeEvalVariable
local getProperties = utils.getProperties
local addProperties = utils.addProperties
local setProperty = utils.setProperty

-- ************************************************************************** --

function dusk_tileLayer.createLayer(map, mapData, data, dataIndex, tileIndex, imageSheets, imageSheetConfig, tileProperties, tileIDs)
	local layerProps = getProperties(data.properties, data.propertytypes, "tiles", true)
	local dotImpliesTable = getSetting("dotImpliesTable")
	local useTileImageSheetFill = getSetting("useTileImageSheetFill")

	local layer = display.newGroup()
	layer.map = map
		
	layer._leftmostTile = (mapData._dusk.layers[dataIndex].leftTile or -math.huge) - 1
	layer._rightmostTile = (mapData._dusk.layers[dataIndex].rightTile or math.huge) + 1
	layer._highestTile = (mapData._dusk.layers[dataIndex].topTile or -math.huge) - 1
	layer._lowestTile = (mapData._dusk.layers[dataIndex].bottomTile or math.huge) + 1
	
	layer._mapData = mapData
	layer._layerData = data
	layer._dataIndex = dataIndex
	layer._tileIndex = tileIndex
	layer._imageSheets = imageSheets
	layer._imageSheetConfig = imageSheetConfig
	layer._tileProperties = tileProperties
	layer._layerProperties = layerProps
	layer._tileIDs = tileIDs
	layer._dotImpliesTable = dotImpliesTable
	layer._useTileImageSheetFill = useTileImageSheetFill
	
	layer._layerType = "tile"

	local mapWidth, mapHeight = mapData.width, mapData.height

	layer.props = {}
	-- layer.edgeModeLeft, layer.edgeModeRight = "stop", "stop"
	-- layer.edgeModeTop, layer.edgeModeBottom = "stop", "stop"

	if layer._leftmostTile == math.huge then
		layer._isBlank = true
		-- If we want, we can overwrite the normal functions with blank ones; this
		-- layer is completely empty so no reason to have useless functions that
		-- take time. However, in the engine, we can just check for layer._isBlank
		-- and it'll be even faster than a useless function call.
		--[[
		function layer.tile() return nil end
		function layer._drawTile() end
		function layer._eraseTile() end
		function layer._redrawTile() end
		function layer._lockTileDrawn() end
		function layer._lockTileErased() end
		function layer._unlockTile() end
		function layer._edit() end
		function layer.draw() end
		function layer.erase() end
		function layer.lock() end
		--]]
	end

	local layerTiles = {}
	local locked = {}

	local tileDrawListeners = {}
	local tileEraseListeners = {}

	layer.tiles = layerTiles
	layer._locked = locked
	layer._tileDrawListeners = tileDrawListeners
	layer._tileEraseListeners = tileEraseListeners

	for k, v in pairs(tileLayerPrototype) do
		layer[k] = v
	end

	for k, v in pairs(layerProps.props) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer.props, k, v) else layer.props[k] = v end
	end

	for k, v in pairs(layerProps.layer) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer, k, v) else layer[k] = v end
	end

	return layer
end

return dusk_tileLayer