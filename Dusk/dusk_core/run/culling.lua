--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Tile Culling

Manages displayed tiles for tile layers in a map.
--]]
--------------------------------------------------------------------------------

local lib_tileculling = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local editQueue = require("Dusk.dusk_core.misc.editqueue")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")

local getSetting = lib_settings.get
local newEditQueue = editQueue.new
local math_abs = math.abs
local math_ceil = math.ceil
local math_max = math.max
local math_min = math.min

--------------------------------------------------------------------------------
-- Add Tile Culling to a Map
--------------------------------------------------------------------------------
function lib_tileculling.addCulling(map)
	local divTileWidth, divTileHeight = 1 / map.data.tileWidth, 1 / map.data.tileHeight

	local culling = {}
	local cullingMargin = getSetting("cullingMargin")
	local tileCullingEnabled = getSetting("enableTileCulling")
	local objectCullingEnabled = getSetting("enableObjectCulling")
	local multiCullingFieldsEnabled = getSetting("enableMultipleCullingFields")

	local enableRotatedMapCulling = getSetting("enableRotatedMapCulling")

	------------------------------------------------------------------------------
	-- New Culling Field
	------------------------------------------------------------------------------
	function culling.newCullingField(w, h, x, y)
		local tileField = {
			layer = {},
			onTileEnter = nil,
			onTileExit = nil,
			mode = "cull",
			width = w or screen.right - screen.left,
			height = h or screen.bottom - screen.top,
			x = x or 0,
			y = y or 0
		}

		tileField.hash = tostring(tileField)

		----------------------------------------------------------------------------
		-- Build Layer Culling
		----------------------------------------------------------------------------
		for layer, i in map.layers() do
			if (layer._layerType == "tile" and tileCullingEnabled) or (layer._layerType == "object" and objectCullingEnabled) then
				local layerCulling = {
					prev = {l = 0, r = 0, t = 0, b = 0},
					now = {l = 0, r = 0, t = 0, b = 0},
					update = function() end
				}

				local prev, now = layerCulling.prev, layerCulling.now

				local layerEdits = newEditQueue()
				layerEdits.setTarget(layer)

				-- if multiCullingFieldsEnabled then
					layerEdits.setSource(tileField)
				-- end
				
				--------------------------------------------------------------------------
				-- Update Culling
				--------------------------------------------------------------------------
				layerCulling.update = function()
					local edgeModeLeft, edgeModeRight, edgeModeTop, edgeModeBottom = layer.edgeModeLeft, layer.edgeModeRight, layer.edgeModeTop, layer.edgeModeBottom
					local nl, nr, nt, nb = layerCulling.updatePositions()
					local pl, pr, pt, pb = layerCulling.prev.l, layerCulling.prev.r, layerCulling.prev.t, layerCulling.prev.b
					
					layer._drawnLeft = nl
					layer._drawnRight = nr
					layer._drawnTop = nt
					layer._drawnBottom = nb
					
					-- if nl == pl and nr == pr and nt == pt and nb == pb then return end

					-- Difference between current positions and previous positions
					-- This is used to tell which direction the layer has moved
					local lDiff = nl - pl
					local rDiff = nr - pr
					local tDiff = nt - pt
					local bDiff = nb - pb
					
					-- Left side
					if lDiff > 0 then -- Moved left, so erase left
						if edgeModeLeft ~= "stop" or pl <= layer._rightmostTile then
							layerEdits.add(pl, nl, pt, pb, "e", "r")
						end
					elseif lDiff < 0 then -- Moved right, so draw left
						if edgeModeLeft ~= "stop" or pl >= layer._leftmostTile then
							layerEdits.add(pl, nl, nt, nb, "d")
						end
					end

					-- Right side
					if rDiff < 0 then -- Moved right, so erase right
						if edgeModeRight ~= "stop" or pr <= layer._rightmostTile then
							layerEdits.add(pr, nr, pt, pb, "e", "l")
						end
					elseif rDiff > 0 then -- Moved left
						if edgeModeRight ~= "stop" or pr >= layer._leftmostTile then
							layerEdits.add(pr, nr, nt, nb, "d")
						end
					end

					-- Top side
					if tDiff > 0 then -- Moved down, so erase top
						if edgeModeY ~= "stop" or pt >= layer._highestTile then
							layerEdits.add(nl, nr, pt, nt, "e", "d")
						end
					elseif tDiff < 0 then -- Moved up, so draw down
						if edgeModeY ~= "stop" or pt <= layer._lowestTile then
							layerEdits.add(nl, nr, pt, nt, "d")
						end
					end

					-- Bottom side
					if bDiff < 0 then -- Moved up, so erase bottom
						if edgeModeY ~= "stop" or pb <= layer._lowestTile then
							layerEdits.add(nl, nr, pb, nb, "e", "u")
						end
					elseif bDiff > 0 then -- Moved down
						if edgeModeY ~= "stop" or pb >= layer._highestTile then
							layerEdits.add(nl, nr, pb, nb, "d")
						end
					end

					-- Guard against tile "leaks"
					if lDiff > 0 and tDiff > 0 then -- Moved up-left
						layerEdits.add(pl, nl, pt, nt, "e", "r")
					end

					if rDiff < 0 and tDiff > 0 then
						layerEdits.add(nr, pr, pt, nt, "e", "l")
					end

					if lDiff > 0 and bDiff < 0 then
						layerEdits.add(pl, nl, nb, pb, "e", "r")
					end

					if rDiff < 0 and bDiff < 0 then
						layerEdits.add(nr, pr, nb, pb, "e", "l")
					end

					layerEdits.execute()
					-- Reset current position
					now.l = nl
					now.r = nr
					now.t = nt
					now.b = nb
				end

				--------------------------------------------------------------------------
				-- Update Positions
				--------------------------------------------------------------------------
				if enableRotatedMapCulling then
					layerCulling.updatePositions = function()
						local tlX, tlY = layer:contentToLocal(tileField.x - tileField.width * 0.5, tileField.y - tileField.height * 0.5)
						local trX, trY = layer:contentToLocal(tileField.x + tileField.width * 0.5, tileField.y - tileField.height * 0.5)
						local blX, blY = layer:contentToLocal(tileField.x - tileField.width * 0.5, tileField.y + tileField.height * 0.5)
						local brX, brY = layer:contentToLocal(tileField.x + tileField.width * 0.5, tileField.y + tileField.height * 0.5)

						local l, r = math_min(tlX, blX, trX, brX), math_max(tlX, blX, trX, brX)
						local t, b = math_min(tlY, blY, trY, brY), math_max(tlY, blY, trY, brY)

						-- Calculate left/right/top/bottom to the nearest tile
						-- We expand each position by the culling margin to hide the drawing and erasing
						l = math_ceil(l * divTileWidth) - cullingMargin
						r = math_ceil(r * divTileWidth) + cullingMargin
						t = math_ceil(t * divTileHeight) - cullingMargin
						b = math_ceil(b * divTileHeight) + cullingMargin

						-- Update previous position to be equal to current position
						prev.l = now.l
						prev.r = now.r
						prev.t = now.t
						prev.b = now.b

						return l, r, t, b
					end
				else
					layerCulling.updatePositions = function()
						local l, t = layer:contentToLocal(tileField.x - tileField.width * 0.5, tileField.y - tileField.height * 0.5)
						local r, b = layer:contentToLocal(tileField.x + tileField.width * 0.5, tileField.y + tileField.height * 0.5)

						-- Calculate left/right/top/bottom to the nearest tile
						-- We expand each position by one to hide the drawing and erasing
						l = math_ceil(l * divTileWidth) - cullingMargin
						r = math_ceil(r * divTileWidth) + cullingMargin
						t = math_ceil(t * divTileHeight) - cullingMargin
						b = math_ceil(b * divTileHeight) + cullingMargin

						-- Update previous position to be equal to current position
						prev.l = now.l
						prev.r = now.r
						prev.t = now.t
						prev.b = now.b
						
						return l, r, t, b
					end
				end

				layer._updateTileCulling = layerCulling.update
				tileField.layer[i] = layerCulling
			end
		end

		----------------------------------------------------------------------------
		-- Initialize Culling Field
		----------------------------------------------------------------------------
		function tileField.initialize()
			for layer, i in map.layers() do
				if tileField.layer[i] then
					local l, r, t, b = tileField.layer[i].updatePositions()
					tileField.layer[i].updatePositions()
					
					layer._drawnLeft = tileField.layer[i].now.l
					layer._drawnRight = tileField.layer[i].now.r
					layer._drawnTop = tileField.layer[i].now.t
					layer._drawnBottom = tileField.layer[i].now.b
					
					if tileField.mode == "cull" then
						if layer._layerType == "tile" then
							layer._edit(l, r, t, b, "d", tileField)
						else
							layer.draw(l, r, t, b, tileField)
						end
					end
				end
			end
		end

		----------------------------------------------------------------------------
		-- Update Layers
		----------------------------------------------------------------------------
		function tileField.updateLayers()
			for layer, i in  map.layers() do
				if tileField.layer[i] then
					tileField.layer[i].update()
				end
			end
		end

		function tileField.updateLayerPositions()
			for layer, i in map.layers() do
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

	return culling
end

return lib_tileculling