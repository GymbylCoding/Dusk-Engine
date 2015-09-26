--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Nightshade Layer

Builds a Nightshade layer from data.
--]]
--------------------------------------------------------------------------------

local lib_nightshadelayer = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local bit = require("plugin.bit")

local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_functions = require("Dusk.dusk_core.misc.functions")
local screen = require("Dusk.dusk_core.misc.screen")

local nightshade_dataImage = require("Dusk.dusk_core.nightshade.dataimage")
local nightshade_shader = require("Dusk.dusk_core.nightshade.shader")

local layerSizeShiftDistance = nightshade_shader.layerSizeShiftDistance

local display_newGroup = display.newGroup
local display_newImage = display.newImage
local setVariable = lib_settings.setEvalVariable
local getProperties = lib_functions.getProperties
local addProperties = lib_functions.addProperties
local getDirectory = lib_functions.getDirectory

local shiftDistance = lib_settings.get("nightshadeVariableShiftDistance")

graphics.defineEffect(nightshade_shader)

--------------------------------------------------------------------------------
-- Create Layer
--------------------------------------------------------------------------------
function lib_nightshadelayer.createLayer(map, data, layerData)
	local layerProps = getProperties(layerData.properties or {}, "", true)
  local devMode = lib_settings.get("developmentMode")
	
	local fileName = lib_functions.getNightshadeLayerDataImageFilename(data._dusk.fileName, layerData)
	
	if devMode then
  	nightshade_dataImage.generateTileLayerDataImage(fileName, data, layerData)
	else
		fileName = lib_settings.get("nightshadeProductionDataImageDirectory") .. "/" .. fileName
	end
		
	local layer = display_newGroup()
	layer.props = {}
	layer._layerType = "nightshade"

  local rect = display.newRect(0, 0, math.max(map.data.width, screen.width), math.max(map.data.height, screen.height))
  rect.x, rect.y = screen.left + rect.width * 0.5, screen.top + rect.height * 0.5
  layer:insert(rect)
	
	-- ***** --
	
	local dataImagePath = system.pathForFile(fileName, devMode and system.DocumentsDirectory or system.ResourceDirectory)
	if not dataImagePath then
		error("Could not find data image at " .. fileName)
	end
	
	-- ***** --
	
  rect.fill = {
    type = "composite",
    paint1 = {
      type = "image",
      filename = fileName,
      baseDir = devMode and system.DocumentsDirectory or system.ResourceDirectory
    },
    paint2 = {
      type = "image",
      filename = layerData._dusk.baseTileset.image
    }
  }

	local layerSize = rect.width
	layerSize = bit.lshift(layerSize, shiftDistance)
	layerSize = bit.bor(layerSize, rect.height)
		
	local tilesetTileWH = layerData._dusk.baseTileset.tilewidth
	tilesetTileWH = bit.lshift(tilesetTileWH, shiftDistance)
	tilesetTileWH = bit.bor(tilesetTileWH, layerData._dusk.baseTileset.tileheight)
	
	local tilesetWH = layerData._dusk.baseTileset.tilesetWidth
	tilesetWH = bit.lshift(tilesetWH, shiftDistance)
	tilesetWH = bit.bor(tilesetWH, layerData._dusk.baseTileset.tilesetHeight)
	
	local mapDimensions = map.data.mapWidth
	mapDimensions = bit.lshift(mapDimensions, shiftDistance)
	mapDimensions = bit.bor(mapDimensions, map.data.mapHeight)
		
  rect.fill.effect = "composite.custom.nightshade"
	
	rect.fill.effect.layerSize = layerSize
	rect.fill.effect.tilesetTileWH = tilesetTileWH
	rect.fill.effect.tilesetWH = tilesetWH
	rect.fill.effect.mapDimensions = mapDimensions
	
  layer.rect = rect

	------------------------------------------------------------------------------
	-- Destroy Layer
	------------------------------------------------------------------------------
	function layer.destroy()
		display.remove(layer)
		layer = nil
	end

	------------------------------------------------------------------------------
	-- Finish Up
	------------------------------------------------------------------------------
	for k, v in pairs(layerProps.props) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer.props, k, v) else layer.props[k] = v end
	end

	for k, v in pairs(layerProps.layer) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer, k, v) else layer[k] = v end
	end

	return layer
end

return lib_nightshadelayer