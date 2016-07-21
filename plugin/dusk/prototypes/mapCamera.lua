-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Map Camera

The camera functions we need to transfer to the map.
--]]
-- ************************************************************************** --

local mapCameraPrototype = {}

-- ************************************************************************** --

local math_round = math.round
local math_min = math.min
local math_max = math.max

-- ************************************************************************** --

mapCameraPrototype.setCameraPosition = function(self, x, y)
	self._camera.viewX, self._camera.viewY = math_round(x), math_round(y)
	self._camera.focus = "point"
	self._camera.trackFocus = true
end

mapCameraPrototype.getCameraPosition = function(self)
	return self._camera.viewX, self._camera.viewY
end

-- ************************************************************************** --

mapCameraPrototype.positionCamera = function(self, x, y)
	self:setCameraPosition(x, y)
	self:snapCamera()
end

-- ************************************************************************** --

mapCameraPrototype.enableCameraFocusTracking = function(self, t)
	self._camera.trackFocus = not not t -- Convert to Boolean

	-- if not self._camera.trackFocus then
		-- self._camera.getFocusXY = function() return self._camera.viewX, self._camera.viewY end
	-- end
end

-- ************************************************************************** --

mapCameraPrototype.setCameraFocus = function(self, f, noSnapCamera)
	if not (f ~= nil and f.x ~= nil and f.y ~= nil) then error("Invalid focus object passed to `self.setCameraFocus()`") end

	self._camera.focus = f
	self._camera.trackFocus = true

	if noSnapCamera then
		-- Do nothing
	else
		self._camera.enableParallax = false
		self:snapCamera()
		self._camera.enableParallax = true
	end
end

-- ************************************************************************** --

mapCameraPrototype.getCameraFocus = function(self)
	return self._camera.focus
end

-- ************************************************************************** --

mapCameraPrototype.setCameraBounds = function(self, bounds)
	local xMin, xMax, yMin, yMax

	if bounds.xMin then xMin = bounds.xMin elseif bounds.xMin == false then xMin = math_nhuge else xMin = self._camera.bounds.xMin end
	if bounds.xMax then xMax = bounds.xMax elseif bounds.xMax == false then xMax = math_huge else xMax = self._camera.bounds.xMax end
	if bounds.yMin then yMin = bounds.yMin elseif bounds.yMin == false then yMin = math_nhuge else yMin = self._camera.bounds.yMin end
	if bounds.yMax then yMax = bounds.yMax elseif bounds.yMax == false then yMax = math_huge else yMax = self._camera.bounds.yMax end

	self._camera.bounds.xMin = math_min(xMin, xMax)
	self._camera.bounds.xMax = math_max(xMin, xMax)
	self._camera.bounds.yMin = math_min(yMin, yMax)
	self._camera.bounds.yMax = math_max(yMin, yMax)

	self._camera:scaleBounds(true, true)
end

-- ************************************************************************** --

mapCameraPrototype.setCameraTrackingLevel = function(self, t)
	if not t then error("Missing argument to `map:setCameraTrackingLevel()`") end
	if t <= 0 then error("Invalid argument passed to `map:setCameraTrackingLevel()`: expected t > 0 but got " .. t .. " instead") end
	self._camera.trackingLevel = t
end

mapCameraPrototype.getCameraTrackingLevel = function(self)
	return self._camera.trackingLevel
end

mapCameraPrototype.setCameraMasterOffset = function(self, x, y)
	self._camera.masterOffsetX = x
	self._camera.masterOffsetY = y
end

mapCameraPrototype.getCameraMasterOffset = function(self)
	return self._camera.masterOffsetX, self._camera.masterOffsetY
end

mapCameraPrototype.centerCameraParallax = function(self)
	self._camera:centerParallax()
end

-- ************************************************************************** --

mapCameraPrototype.snapCamera = function(self)
	local t = self:getCameraTrackingLevel()
	self:setCameraTrackingLevel(1)
	self:updateView()
	self:setCameraTrackingLevel(t)
end

return mapCameraPrototype
