-- ************************************************************************** --
--[[
Dusk Engine Component: Camera

Adds virtual camera functionality to maps.
--]]
-- ************************************************************************** --

local dusk_camera = {}

-- ************************************************************************** --

local screenInfo = require("plugin.dusk.misc.screenInfo")
local dusk_settings = require("plugin.dusk.misc.settings")

local cameraPrototype = require("plugin.dusk.prototypes.camera")
local mapCameraPrototype = require("plugin.dusk.prototypes.mapCamera")

local getSetting = dusk_settings.get

local math_round = math.round
local math_huge = math.huge
local math_nhuge = -math.huge

-- ************************************************************************** --

local function calculateCameraLayerPosition(self, skipParallax)
	local layer = self.mapLayer
	local camera = self.camera

	local positionDeltaX, positionDeltaY

	local contentX, contentY = camera.rawFocusContentX, camera.rawFocusContentY
	local layerContentX, layerContentY = layer.parent:localToContent(self.layerX, self.layerY)

	local addX, addY = camera.addX + self.xOffset + camera.masterOffsetX, camera.addY + self.yOffset + camera.masterOffsetY

	self.x = layerContentX - contentX
	self.y = layerContentY - contentY

	local localX, localY = layer.parent:contentToLocal(self.x + addX, self.y + addY)
	
	self.layerX = self.layerX + (localX - self.layerX) * camera.trackingLevel * (skipParallax and 1 or layer.xParallax)
	self.layerY = self.layerY + (localY - self.layerY) * camera.trackingLevel * (skipParallax and 1 or layer.yParallax)
	if layer.xParallax == 1 then
		camera.parallaxReferenceX = self
	end
	if layer.yParallax == 1 then
		camera.parallaxReferenceY = self
	end
end

local function updateCameraLayer(self)
	self:calculateLayerPosition()
	self.mapLayer.x, self.mapLayer.y = self.layerX, self.layerY
	self.mapLayer:translate(self.parallaxOffsetX, self.parallaxOffsetY)
	self.mapLayer:translate(-self.mapLayer.map.data.pixelWidth * 0.5, -self.mapLayer.map.data.pixelHeight * 0.5)
end

local function calculateCameraLayerParallaxOffset(self)
	if self.camera.parallaxReferenceX then
		self.parallaxOffsetX = self.camera.parallaxReferenceX.layerX - self.layerX
	end
	if self.camera.parallaxReferenceY then
		self.parallaxOffsetY = self.camera.parallaxReferenceY.layerY - self.layerY
	end
end

local function setMapLayerCameraOffset(self, x, y)
	self._cameraLayer.xOffset = x or self._cameraLayer.xOffset
	self._cameraLayer.yOffset = y or self._cameraLayer.yOffset
end

local function getMapLayerCameraOffset(self)
	return self._cameraLayer.xOffset, self._cameraLayer.yOffset
end

local function setCameraMasterOffset(self, x, y)
	self._camera.masterOffsetX = x
	self._camera.masterOffsetY = y
end

local function getCameraMasterOffset(self)
	return self._camera.masterOffsetX, self._camera.masterOffsetY
end


-- ************************************************************************** --

function dusk_camera.addControl(map)
	local camera = {
		map = map,
		
		storedMapRotation = 0,
		positionHasMoved = false,
		mapHasRotated = false,
				
		enableParallax = true,
		trackingLevel = getSetting("defaultCameraTrackingLevel"),
		scaleBoundsToScreen = getSetting("scaleCameraBoundsToScreen"),
		enableCameraRounding = getSetting("enableCameraRounding"),
		masterOffsetX = 0,
		masterOffsetY = 0,
		layers = {},

		xScale = 1,
		yScale = 1,

		addX = screenInfo.centerX,
		addY = screenInfo.centerY,

		bounds = {
			xMin = math_nhuge,
			yMin = math_nhuge,
			xMax = math_huge,
			yMax = math_huge
		},

		scaledBounds = {
			xMin = math_nhuge,
			yMin = math_nhuge,
			xMax = math_huge,
			yMax = math_huge
		},

		focus = "point",
		scaleBounds = nil,
		trackFocus = false,

		viewX = screenInfo.centerX,
		viewY = screenInfo.centerY,
		previousViewX = screenInfo.centerX,
		previousViewY = screenInfo.centerY,
		
		rawFocusX = 0,
		rawFocusY = 0,
		previousRawFocusX = 0,
		previousRawFocusY = 0,
		
		rawFocusContentX = 0,
		rawFocusContentY = 0,
		previousRawFocusContentX = 0,
		previousRawFocusContentY = 0
	}

	-- ***** --
	
	for i = 1, #map.layers do
		if map.layers[i].cameraTrackingEnabled then
			map.layers[i]._cameraLayer = camera.layers[i]
			camera.layers[i] = {
				mapLayer = map.layers[i],
				camera = camera,
				xOffset = 0,
				yOffset = 0,
				layerX = 0,
				layerY = 0,
				parallaxOffsetX = 0,
				parallaxOffsetY = 0,
				x = 0,
				y = 0
			}

			camera.layers[i].calculateLayerPosition = calculateCameraLayerPosition
			camera.layers[i].calculateParallaxOffset = calculateCameraLayerParallaxOffset
			camera.layers[i].update = updateCameraLayer

			map.layers[i]._cameraLayer = camera.layers[i]
			map.layers[i].setCameraOffset = setMapLayerCameraOffset
			map.layers[i].getCameraOffset = getMapLayerCameraOffset
			
			if not map.layers[i]._isDataLayer and map.layers[i].xParallax == 1 then camera.parallaxReferenceX = camera.layers[i] end
			if not map.layers[i]._isDataLayer and map.layers[i].yParallax == 1 then camera.parallaxReferenceY = camera.layers[i] end
		end
	end


	for k, v in pairs(cameraPrototype) do
		camera[k] = v
	end
	
	for k, v in pairs(mapCameraPrototype) do
		map[k] = v
	end
	
	map._camera = camera

	return camera
end

return dusk_camera
