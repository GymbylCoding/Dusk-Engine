-- ************************************************************************** --
--[[
Dusk Engine Component: Object Layer

Builds an object layer from data.
--]]
-- ************************************************************************** --

local dusk_objectLayer = {}

-- ************************************************************************** --

local dusk_settings = require("plugin.dusk.misc.settings")
local dusk_objectGrid = require("plugin.dusk.misc.objectGrid")
local utils = require("plugin.dusk.misc.utils")

local objectLayerPrototype = require("plugin.dusk.prototypes.objectLayer")

local getSetting = dusk_settings.get

-- ************************************************************************** --

function dusk_objectLayer.createLayer(map, mapData, data, dataIndex, tileIndex, imageSheets, imageSheetConfig)
	local dotImpliesTable = getSetting("dotImpliesTable")
	local ellipseRadiusMode = getSetting("ellipseRadiusMode")
	local styleObject = getSetting("styleObject")
	local styleEllipse = getSetting("styleEllipseObject")
	local stylePointBased = getSetting("stylePointBasedObject")
	local styleImageObj = getSetting("styleImageObject")
	local styleRect = getSetting("styleRectObject")
	local autoGenerateObjectShapes = getSetting("autoGenerateObjectPhysicsShapes")
	local objectsDefaultToData = getSetting("objectsDefaultToData")
	local virtualObjectsVisible = getSetting("virtualObjectsVisible")
	local furtherClassifyRectangleObjects = getSetting("furtherClassifyRectangleObjects")

	local layerProps = utils.getProperties(data.properties, data.propertytypes, "objects", true)

	local layer = display.newGroup()
	layer.props = {}
	layer.objects = {}
	layer._layerType = "object"

	local objListeners = {
		drawn = {
			type = {},
			name = {},
		},
		erased = {
			type = {},
			name = {}
		}
	}
	local objDatas = {}
	
	layer._objDatas = objDatas
	
	layer._objectGrid = dusk_objectGrid.new()
	layer._objectGrid:prepare(map)
	layer._objectGrid.layer = layer

	layer.map = map
	
	layer._numObjects = #data.objects
	layer._mapData = mapData
	layer._data = data
	layer._objListeners = objListeners
	layer._layerProps = layerProps
	layer._tileIndex = tileIndex
	layer._imageSheets = imageSheets
	layer._imageSheetConfig = imageSheetConfig

	layer._cachedSettings = {
		dotImpliesTable = dotImpliesTable,
		ellipseRadiusMode = ellipseRadiusMode,
		styleObject = styleObject,
		styleEllipse = styleEllipse,
		stylePointBased = stylePointBased,
		styleImageObj = styleImageObj,
		styleRect = styleRect,
		autoGenerateObjectShapes = autoGenerateObjectShapes,
		objectsDefaultToData = objectsDefaultToData,
		virtualObjectsVisible = virtualObjectsVisible,
		furtherClassifyRectangleObjects = furtherClassifyRectangleObjects
	}

	for k, v in pairs(objectLayerPrototype) do
		layer[k] = v
	end

	for k, v in pairs(layerProps.props) do if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then utils.setProperty(layer.props, k, v) else layer.props[k] = v end end
	for k, v in pairs(layerProps.layer) do if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then utils.setProperty(layer, k, v) else layer[k] = v end end

	layer._isDataLayer = layer["!isData!"] == false

	return layer
end

return dusk_objectLayer