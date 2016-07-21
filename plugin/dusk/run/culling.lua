-- ************************************************************************** --
--[[
Dusk Engine Component: Culling

Deletes and draws tiles and objects as needed.
--]]
-- ************************************************************************** --

local dusk_culling = {}

-- ************************************************************************** --

local editQueue = require("plugin.dusk.misc.editQueue")
local screenInfo = require("plugin.dusk.misc.screenInfo")
local dusk_settings = require("plugin.dusk.misc.settings")

local cullingLayerPrototype = require("plugin.dusk.prototypes.cullingLayer")

local getSetting = dusk_settings.get
local newEditQueue = editQueue.new
local math_abs = math.abs
local math_ceil = math.ceil
local math_max = math.max
local math_min = math.min

-- ************************************************************************** --

function dusk_culling.addCulling(map)
	local divTileWidth, divTileHeight = 1 / map.data.tileWidth, 1 / map.data.tileHeight

	local culling = {}
	local cullingMargin = getSetting("cullingMargin")
	local tileCullingEnabled = getSetting("enableTileCulling")
	local objectCullingEnabled = getSetting("enableObjectCulling")
	local multiCullingFieldsEnabled = getSetting("enableMultipleCullingFields")

	local enableRotatedMapCulling = getSetting("enableRotatedMapCulling")

	culling._divTileWidth, culling._divTileHeight = divTileWidth, divTileHeight
	culling._cullingMargin = cullingMargin

	-- ***** --
	
	function culling.newCullingField(w, h, x, y)
		local tileField = {
			layer = {},
			onTileEnter = nil,
			onTileExit = nil,
			mode = "cull",
			width = w or screenInfo.right - screenInfo.left,
			height = h or screenInfo.bottom - screenInfo.top,
			x = x or 0,
			y = y or 0
		}

		tileField.hash = tostring(tileField)

		for layer, i in map:getLayers() do
			if (layer._layerType == "tile" and tileCullingEnabled) or (layer._layerType == "object" and objectCullingEnabled) then
				local layerCulling = {
					prev = {l = 0, r = 0, t = 0, b = 0},
					now = {l = 0, r = 0, t = 0, b = 0},
					mapLayer = layer,
					tileField = tileField,
					cullingManager = culling
				}

				local prev, now = layerCulling.prev, layerCulling.now
				local layerEdits = newEditQueue()
				layerEdits.setTarget(layer)

				layerCulling.editQueue = layerEdits

				layerEdits.setSource(tileField)

				for k, v in pairs(cullingLayerPrototype) do
					layerCulling[k] = v
				end
				
				if enableRotatedMapCulling then
					layerCulling.updatePositions = layerCulling.updatePositionsWithRotatedCulling
				else
					layerCulling.updatePositions = layerCulling.updatePositionsWithoutRotatedCulling
				end
				
				layer._updateTileCulling = layerCulling.update
				tileField.layer[i] = layerCulling
			end
		end

		-- ***** --
		
		function tileField.initialize()
			for layer, i in map:getLayers() do
				if tileField.layer[i] then
					local l, r, t, b = tileField.layer[i]:updatePositions()
					tileField.layer[i]:updatePositions()
					
					layer._drawnLeft = tileField.layer[i].now.l
					layer._drawnRight = tileField.layer[i].now.r
					layer._drawnTop = tileField.layer[i].now.t
					layer._drawnBottom = tileField.layer[i].now.b
					
					if tileField.mode == "cull" then
						if layer._layerType == "tile" then
							layer:_edit(l, r, t, b, "d", tileField)
						else
							layer:draw(l, r, t, b, tileField)
						end
					end
				end
			end
		end

		-- ***** --
		
		function tileField.updateLayers()
			for layer, i in map:getLayers() do
				if tileField.layer[i] then
					tileField.layer[i].update()
				end
			end
		end

		function tileField.updateLayerPositions()
			for layer, i in map:getLayers() do
				if tileField.layer[i] then
					tileField.layer[i].updatePositions()
				end
			end
		end

		return tileField
	end

	culling.screenCullingField = culling.newCullingField()

	if multiCullingFieldsEnabled then
		map.newCullingField = culling.newCullingField
	end
	
	map._culling = culling

	return culling
end

return dusk_culling