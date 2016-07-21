-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Culling Layer

Handles a single layer's culling.
--]]
-- ************************************************************************** --

local cullingLayerPrototype = {}

-- ************************************************************************** --

local math_ceil = math.ceil
local math_min = math.min
local math_max = math.max

-- ************************************************************************** --

cullingLayerPrototype.update = function(self)
	local layer = self.mapLayer
	
	local edgeModeLeft, edgeModeRight, edgeModeTop, edgeModeBottom = layer.edgeModeLeft, layer.edgeModeRight, layer.edgeModeTop, layer.edgeModeBottom
	local nl, nr, nt, nb = self:updatePositions()
	local pl, pr, pt, pb = self.prev.l, self.prev.r, self.prev.t, self.prev.b
	
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
			self.editQueue.add(pl, nl, pt, pb, "e", "r")
		end
	elseif lDiff < 0 then -- Moved right, so draw left
		if edgeModeLeft ~= "stop" or pl >= layer._leftmostTile then
			self.editQueue.add(pl, nl, nt, nb, "d")
		end
	end

	-- Right side
	if rDiff < 0 then -- Moved right, so erase right
		if edgeModeRight ~= "stop" or pr <= layer._rightmostTile then
			self.editQueue.add(pr, nr, pt, pb, "e", "l")
		end
	elseif rDiff > 0 then -- Moved left
		if edgeModeRight ~= "stop" or pr >= layer._leftmostTile then
			self.editQueue.add(pr, nr, nt, nb, "d")
		end
	end

	-- Top side
	if tDiff > 0 then -- Moved down, so erase top
		if edgeModeY ~= "stop" or pt >= layer._highestTile then
			self.editQueue.add(nl, nr, pt, nt, "e", "d")
		end
	elseif tDiff < 0 then -- Moved up, so draw down
		if edgeModeY ~= "stop" or pt <= layer._lowestTile then
			self.editQueue.add(nl, nr, pt, nt, "d")
		end
	end

	-- Bottom side
	if bDiff < 0 then -- Moved up, so erase bottom
		if edgeModeY ~= "stop" or pb <= layer._lowestTile then
			self.editQueue.add(nl, nr, pb, nb, "e", "u")
		end
	elseif bDiff > 0 then -- Moved down
		if edgeModeY ~= "stop" or pb >= layer._highestTile then
			self.editQueue.add(nl, nr, pb, nb, "d")
		end
	end

	-- Guard against tile "leaks"
	if lDiff > 0 and tDiff > 0 then -- Moved up-left
		self.editQueue.add(pl, nl, pt, nt, "e", "r")
	end

	if rDiff < 0 and tDiff > 0 then
		self.editQueue.add(nr, pr, pt, nt, "e", "l")
	end

	if lDiff > 0 and bDiff < 0 then
		self.editQueue.add(pl, nl, nb, pb, "e", "r")
	end

	if rDiff < 0 and bDiff < 0 then
		self.editQueue.add(nr, pr, nb, pb, "e", "l")
	end

	self.editQueue.execute()
	-- Reset current position
	self.now.l = nl
	self.now.r = nr
	self.now.t = nt
	self.now.b = nb
end

-- ************************************************************************** --

cullingLayerPrototype.updatePositionsWithRotatedCulling = function(self)
	local layer = self.mapLayer
	local tileField = self.tileField
	local divTileWidth, divTileHeight = self.cullingManager._divTileWidth, self.cullingManager._divTileHeight
	local cullingMargin = self.cullingManager._cullingMargin
	
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
	self.prev.l = self.now.l
	self.prev.r = self.now.r
	self.prev.t = self.now.t
	self.prev.b = self.now.b

	return l, r, t, b
end

-- ************************************************************************** --

cullingLayerPrototype.updatePositionsWithoutRotatedCulling = function(self)
	local layer = self.mapLayer
	local tileField = self.tileField
	local divTileWidth, divTileHeight = self.cullingManager._divTileWidth, self.cullingManager._divTileHeight
	local cullingMargin = self.cullingManager._cullingMargin
	
	local l, t = layer:contentToLocal(tileField.x - tileField.width * 0.5, tileField.y - tileField.height * 0.5)
	local r, b = layer:contentToLocal(tileField.x + tileField.width * 0.5, tileField.y + tileField.height * 0.5)

	-- Calculate left/right/top/bottom to the nearest tile
	-- We expand each position by one to hide the drawing and erasing
	l = math_ceil(l * divTileWidth) - cullingMargin
	r = math_ceil(r * divTileWidth) + cullingMargin
	t = math_ceil(t * divTileHeight) - cullingMargin
	b = math_ceil(b * divTileHeight) + cullingMargin

	-- Update previous position to be equal to current position
	self.prev.l = self.now.l
	self.prev.r = self.now.r
	self.prev.t = self.now.t
	self.prev.b = self.now.b
	
	return l, r, t, b
end

return cullingLayerPrototype