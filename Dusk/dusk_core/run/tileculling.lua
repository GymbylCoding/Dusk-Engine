--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Tile Culling

Manages displayed tiles for tile layers in a map.
--]]
--------------------------------------------------------------------------------

local tileculling = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local editQueue = require("Dusk.dusk_core.misc.editqueue")
local screen = require("Dusk.dusk_core.misc.screen")

local newEditQueue = editQueue.new
local math_abs = math.abs
local math_ceil = math.ceil

--------------------------------------------------------------------------------
-- Add Tile Culling to a Map
--------------------------------------------------------------------------------
function tileculling.addTileCulling(map)
	local divTileWidth, divTileHeight = 1 / map.data.tileWidth, 1 / map.data.tileHeight

	local culling = {
		layer = {}
	}

	------------------------------------------------------------------------------
	-- Load Layers
	------------------------------------------------------------------------------
	for layer, i in map.tileLayers() do
		if layer.tileCullingEnabled then
			local layerCulling = {
				prev = {l = 0, r = 0, t = 0, b = 0},
				now = {l = 0, r = 0, t = 0, b = 0},
				update = function() end
			}

			local prev, now = layerCulling.prev, layerCulling.now

			local layerEdits = newEditQueue()
			layerEdits.setTarget(layer)

			--------------------------------------------------------------------------
			-- Update Culling
			--------------------------------------------------------------------------
			layerCulling.update = function()
				local nl, nr, nt, nb = layerCulling.updatePositions()
				local pl, pr, pt, pb = layerCulling.prev.l, layerCulling.prev.r, layerCulling.prev.t, layerCulling.prev.b

				if nl == pl and nr == pr and nt == pt and nb == pb then return end

				-- Difference between current positions and previous positions
				-- This is used to tell which direction the layer has moved
				local lDiff = nl - pl
				local rDiff = nr - pr
				local tDiff = nt - pt
				local bDiff = nb - pb

				if lDiff > 0 then
					layerEdits.add(pl, nl, pt, pb, "e")
				elseif lDiff < 0 then
					layerEdits.add(pl, nl, nt, nb, "d")
				end

				if rDiff < 0 then
					layerEdits.add(pr, nr, pt, pb, "e")
				elseif rDiff > 0 then
					layerEdits.add(pr, nr, nt, nb, "d")
				end

				if tDiff > 0 then
					layerEdits.add(nl, nr, pt, layerCulling.now.t, "e")
				elseif tDiff < 0 then
					layerEdits.add(nl, nr, pt, layerCulling.now.t, "d")
				end

				if bDiff < 0 then
					layerEdits.add(nl, nr, pb, layerCulling.now.b, "e")
				elseif bDiff > 0 then
					layerEdits.add(nl, nr, pb, layerCulling.now.b, "d")
				end

				-- Guard against tile "leaks"
				if lDiff > 0 and tDiff > 0 then
					layerEdits.add(pl, nl, pt, nt, "e")
				end

				if rDiff < 0 and tDiff > 0 then
					layerEdits.add(nr, pr, pt, nt, "e")
				end

				if lDiff > 0 and bDiff < 0 then
					layerEdits.add(pl, nl, nb, pb, "e")
				end

				if rDiff < 0 and bDiff < 0 then
					layerEdits.add(nr, pr, nb, pb, "e")
				end

				layerEdits.execute()
			end

			--------------------------------------------------------------------------
			-- Update Positions
			--------------------------------------------------------------------------
			layerCulling.updatePositions = function()
				local l, t = layer:contentToLocal(screen.left, screen.top)
				local r, b = layer:contentToLocal(screen.right, screen.bottom)

				-- Calculate left/right/top/bottom to the nearest tile
				-- We expand each position by one to hide the drawing and erasing
				l = math_ceil(l * divTileWidth) - 1
				r = math_ceil(r * divTileWidth) + 1
				t = math_ceil(t * divTileHeight) - 1
				b = math_ceil(b * divTileHeight) + 1

				-- Update previous position to be equal to current position
				prev.l = now.l
				prev.r = now.r
				prev.t = now.t
				prev.b = now.b

				-- Reset current position
				now.l = l
				now.r = r
				now.t = t
				now.b = b

				return l, r, t, b
			end


			layer._updateTileCulling = layerCulling.update

			culling.layer[i] = layerCulling
		end
	end

	return culling
end

return tileculling