-- ************************************************************************** --
--[[
Dusk Engine Component: Image Layer

Builds an image layer from data.
--]]
-- ************************************************************************** --

local dusk_imageLayer = {}

-- ************************************************************************** --

local dusk_settings = require("plugin.dusk.misc.settings")
local utils = require("plugin.dusk.misc.utils")

-- ************************************************************************** --

function dusk_imageLayer.createLayer(map, data, dirTree)
	local props = utils.getProperties(data.properties, data.propertytypes, "image", true)

	local layer = display.newGroup()
	layer.props = {}
	layer._layerType = "image"

	local imageDir, filename = utils.getDirectory(dirTree, data.image)

	layer.image = display.newImage(layer, imageDir .. filename)
	layer.image.x, layer.image.y = data.x + (layer.image.width * 0.5), data.y + (layer.image.height * 0.5)
	
	layer.destroy = utils.defaultLayerDestroy

	utils.addProperties(props, "props", layer.props)
	utils.addProperties(props, "layer", layer)

	return layer
end

return dusk_imageLayer