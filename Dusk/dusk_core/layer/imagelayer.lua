--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Image Layer

Builds an image layer from data.
--]]
--------------------------------------------------------------------------------

local lib_imagelayer = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_functions = require("Dusk.dusk_core.misc.functions")

local display_newGroup = display.newGroup
local display_newImage = display.newImage
local setVariable = lib_settings.setEvalVariable
local getProperties = lib_functions.getProperties
local addProperties = lib_functions.addProperties
local getDirectory = lib_functions.getDirectory

--------------------------------------------------------------------------------
-- Create Layer
--------------------------------------------------------------------------------
function lib_imagelayer.createLayer(map, data, dirTree)
	local props = getProperties(data.properties or {}, "image", true)

	local layer = display_newGroup()
	layer.props = {}
	layer._layerType = "image"

	local imageDir, filename = getDirectory(dirTree, data.image)

	layer.image = display_newImage(layer, imageDir .. filename)
	layer.image.x, layer.image.y = data.x + (layer.image.width * 0.5), data.y + (layer.image.height * 0.5)

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
	addProperties(props, "props", layer.props)
	addProperties(props, "layer", layer)

	return layer
end

return lib_imagelayer