-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Map

The head honcho.
--]]
-- ************************************************************************** --

local mapPrototype = {}

-- ************************************************************************** --

mapPrototype.tilesToPixels = function(self, x, y)
	if not (x ~= nil and y ~= nil) then error("Missing argument(s) to `self.tilesToPixels()`") end
	x, y = x - 0.5, y - 0.5
	return (x * self.data.tileWidth), (y * self.data.tileHeight)
end

mapPrototype.tilesToContentPixels = function(self, x, y)
		local _x, _y = self.tilesToPixels(x, y)
		return self:localToContent(_x, _y)
	end

mapPrototype.pixelsToTiles = function(self, x, y)
	if x == nil or y == nil then error("Missing argument(s) to `self.pixelsToTiles()`") end
	return math.ceil(x / self.data.tileWidth), math.ceil(y / self.data.tileHeight)
end

mapPrototype.contentPixelsToTiles = function(self, x, y)
	if x == nil or y == nil then error("Missing argument(s) to `self.pixelsToTiles()`") end
	x, y = self:contentToLocal(x, y)
	return math.ceil(x / self.data.tileWidth), math.ceil(y / self.data.tileHeight)
end

-- mapPrototype.tilesToLocalPixels = mapPrototype.tilesToPixels
-- mapPrototype.localPixelsToTiles = mapPrototype.pixelsToTiles

-- ************************************************************************** --

mapPrototype.isTileWithinMap = function(self, x, y)
	if x == nil or y == nil then error("Missing argument(s) to `self.isTileWithinMap()`") end
	return (x >= 1 and x <= self.data.mapWidth) and (y >= 1 and y <= self.data.mapHeight)
end

-- ************************************************************************** --

mapPrototype.getLayers = function(self, t)
	local i = 0
	return function()
		while true do
			i = i + 1
			if self.layers[i] and (t and self.layers[i]._layerType == t or not t) then
				return self.layers[i], i
			elseif not self.layers[i] then
				return nil
			end
		end
	end
end

mapPrototype._getTileLayers = function(self) return self._layerTypes.tile end
mapPrototype._getObjectLayers = function(self) return self._layerTypes.object end
mapPrototype._getImageLayers = function(self) return self._layerTypes.image end

-- ************************************************************************** --

mapPrototype._finalizeListener = function(event)
	local self = event.target
	-- self._updateManager.destroy()

	for i = 1, #self.layers do
		self.layers[i]:destroy()
		self.layers[i] = nil
	end

	display.remove(self)
	self = nil
	return true
end

return mapPrototype