-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Camera

Moves stuff around.
--]]
-- ************************************************************************** --

local cameraPrototype = {}

-- ************************************************************************** --

local screenInfo = require("plugin.dusk.misc.screenInfo")
local utils = require("plugin.dusk.misc.utils")

local clamp = utils.clamp
local math_huge = math.huge
local math_nhuge = -math.huge

-- ************************************************************************** --

cameraPrototype.getFocusXY = function(self)
	if self.focus == "point" then
		return self.viewX, self.viewY
	elseif self.focus then
		return self.focus.x, self.focus.y
	end
end

cameraPrototype.getFocusContentXY = function(self)
	if self.focus == "point" then
		if self.parallaxReferenceX and self.parallaxReferenceX == self.parallaxReferenceY then
			return self.parallaxReferenceX.mapLayer:localToContent(self.viewX, self.viewY)
		elseif self.parallaxReferenceX then
			local x, _ = self.parallaxReferenceX.mapLayer:localToContent(self.viewX, 0)
			local _, y = self.parallaxReferenceY.mapLayer:localToContent(0, self.viewY)
			return x, y
		end
	elseif self.focus and self.focus.parent then
		return self.focus.parent:localToContent(self.focus.x, self.focus.y)
	elseif self.focus and self.focus.localToContent then
		return self.focus:localToContent(0, 0)
	elseif self.focus then
		return self.focus.x, self.focus.y
	end
end

cameraPrototype.focusCoordinatesToContent = function(self, x, y)
	if self.focus and self.focus.parent then
		return self.focus.parent:localToContent(self.focus.x, self.focus.y)
	elseif self.focus and self.focus.localToContent then
		return self.focus:localToContent(x - self.focus.x, y - self.focus.y)
	else
		return x, y
	end
end

cameraPrototype.contentToFocusCoordinates = function(self, x, y)
	if self.focus and self.focus.parent then
		return self.focus.parent:contentToLocal(x, y)
	elseif self.focus and self.focus.contentToLocal then
		local newX, newY = self.focus:contentToLocal(x, y)
		return newX + self.focus.x, newY + self.focus.y
	else
		return x, y
	end
end

cameraPrototype.scaleBounds = function(self, doX, doY)
	if self.scaleBoundsToScreen then
		local xMin = self.bounds.xMin
		local xMax = self.bounds.xMax
		local yMin = self.bounds.yMin
		local yMax = self.bounds.yMax

		local doX = doX and not ((xMin == math_nhuge) or (xMax == math_huge))
		local doY = doY and not ((yMin == math_nhuge) or (yMax == math_huge))

		if doX then
			local scaled_xMin = xMin / self.map.xScale
			local scaled_xMax = xMax - (scaled_xMin - xMin)

			-- Check against "hopping"
			if scaled_xMax < scaled_xMin then
				local hopDist = scaled_xMin - scaled_xMax
				local halfDist = hopDist * 0.5
				scaled_xMax = scaled_xMax + halfDist
				scaled_xMin = scaled_xMin - halfDist
			end

			self.scaledBounds.xMin = scaled_xMin
			self.scaledBounds.xMax = scaled_xMax
		end

		if doY then
			local scaled_yMin = yMin / map.yScale
			local scaled_yMax = yMax - (scaled_yMin - yMin)

			-- Check against "hopping"
			if scaled_yMax < scaled_yMin then
				local hopDist = scaled_yMin - scaled_yMax
				local halfDist = hopDist * 0.5
				scaled_yMax = scaled_yMax + halfDist
				scaled_yMin = scaled_yMin - halfDist
			end

			self.scaledBounds.yMin = scaled_yMin
			self.scaledBounds.yMax = scaled_yMax
		end
	else
		-- Move along, nothing to see here; just set the scaled bounds to the layer bounds
		self.scaledBounds.xMin, self.scaledBounds.xMax, self.scaledBounds.yMin, self.scaledBounds.yMax = self.bounds.xMin, self.bounds.xMax, self.bounds.yMin, self.bounds.yMax
	end
end

-- ************************************************************************** --

-- Update layer addX and Y
cameraPrototype.updateAddXY = function(self)
	self.addX = screenInfo.centerX -- / self.map.xScale
	self.addY = screenInfo.centerY -- / self.map.yScale
end

cameraPrototype.centerParallax = function(self)
	for i = 1, #self.layers do
		self.layers[i]:calculateParallaxOffset()
	end
end

-- ************************************************************************** --

cameraPrototype.processCameraPosition = function(self)
	if self.trackFocus then
		self.previousRawFocusX, self.previousRawFocusY = self.rawFocusX, self.rawFocusY
		local x, y = self:getFocusXY()
		self.rawFocusX, self.rawFocusY = x, y
		
		self.previousRawFocusContentX, self.previousRawFocusContentY = self.rawFocusContentX, self.rawFocusContentY
		local contentX, contentY = self:getFocusContentXY()
		self.rawFocusContentX, self.rawFocusContentY = contentX, contentY

		local mapXScale, mapYScale = self.map.xScale, self.map.yScale

		if mapXScale ~= self.xScale or mapYScale ~= self.yScale then
			self:updateAddXY()
		end

		local scaleX, scaleY = false, false

		if mapXScale ~= self.xScale then
			self.xScale = mapXScale
			scaleX = true
		end

		if mapYScale ~= self.yScale then
			self.yScale = mapYScale
			scaleY = true
		end
		
		self:scaleBounds(scaleX, scaleY)

		x = clamp(x, self.scaledBounds.xMin, self.scaledBounds.xMax) + self.masterOffsetX - screenInfo.left
		y = clamp(y, self.scaledBounds.yMin, self.scaledBounds.yMax) + self.masterOffsetY - screenInfo.top

		if x ~= self.viewX or y ~= self.viewY or self.map.rotation ~= self.storedMapRotation then
			self.positionHasMoved = true
			self.positionDeltaX, self.positionDeltaY = self.viewX - x, self.viewY - y
			
			if self.map.rotation ~= self.storedMapRotation then
				self.deltaMapRotation = self.storedMapRotation - self.map.rotation
				self.mapHasRotated = true
			else
				self.mapHasRotated = false
			end
		else
			self.positionHasMoved = false
			self.mapHasRotated = false
			self.deltaMapRotation = 0
		end
		
		self.previousViewX, self.previousViewY = self.viewX, self.viewY
		self.viewX, self.viewY = x, y
		self.storedMapRotation = self.map.rotation
	end
end

return cameraPrototype