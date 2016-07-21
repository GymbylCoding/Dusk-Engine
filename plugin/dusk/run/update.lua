--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Update

Wraps camera and tile culling to create a unified system.
--]]
--------------------------------------------------------------------------------

local lib_update = {}

-- ************************************************************************** --

local require = require

local screenInfo = require("plugin.dusk.misc.screenInfo")
local dusk_settings = require("plugin.dusk.misc.settings")

local getSetting = dusk_settings.get

local dusk_camera; if getSetting("enableCamera") then dusk_camera = require("plugin.dusk.run.camera") end
local dusk_culling; if getSetting("enableTileCulling") or getSetting("enableObjectCulling") then dusk_culling = require("plugin.dusk.run.culling") end
local dusk_anim = require("plugin.dusk.run.anim")

-- ************************************************************************** --

local function updateOnlyCamera(self)
	self._camera:processCameraPosition()
	self._animManager:update()
	for i = 1, #self._camera.layers do
		self._camera.layers[i]:update()
	end
	if self.background then
		self.background.xScale = 1 / self.xScale
		self.background.yScale = 1 / self.yScale
		self.background.x, self.background.y = self:contentToLocal(display.contentCenterX, display.contentCenterY)
	end
end

local function updateOnlyCulling(self)
	self._animManager:update()

	for k, v in pairs(self._culling.screenCullingField.layer) do
		v:update()
	end
	if self.background then
		self.background.xScale = 1 / self.xScale
		self.background.yScale = 1 / self.yScale
		self.background.x, self.background.y = self:contentToLocal(display.contentCenterX, display.contentCenterY)
	end
end

local function updateCameraAndCulling(self)
	self._camera:processCameraPosition()
	self._animManager:update()
	for layer, i in self:getLayers() do
		if self._camera.layers[i] then
			self._camera.layers[i]:update()
		end

		if self._culling.screenCullingField.layer[i] then
			self._culling.screenCullingField.layer[i]:update()
		end
	end
	if self.background then
		self.background.xScale = 1 / self.xScale
		self.background.yScale = 1 / self.yScale
		self.background.x, self.background.y = self:contentToLocal(display.contentCenterX, display.contentCenterY)
	end
end

-- ************************************************************************** --

function lib_update.register(map)
	local enableCamera, enableTileCulling, enableObjectCulling = getSetting("enableCamera"), getSetting("enableTileCulling"), getSetting("enableObjectCulling")
	local mapLayers = map.data.numLayers

	local update = {}
	local camera, culling
	local enableCulling = enableTileCulling or enableObjectCulling
	local anim = dusk_anim.new(map)
	
	update.map = map
	
	-- Add camera to map
	if enableCamera then
		if not dusk_camera then
			dusk_camera = require("plugin.dusk.run.camera")
		end

		camera = dusk_camera.addControl(map)
	end

	-- Add culling to map
	for layer in map:getLayers("object") do
		layer:_buildAllObjectDatas()
	end

	if enableCulling then
		if not dusk_culling then
			dusk_culling = require("plugin.dusk.run.culling")
		end

		culling = dusk_culling.addCulling(map)
		culling.screenCullingField.x, culling.screenCullingField.y = screenInfo.centerX, screenInfo.centerY

		culling.screenCullingField.initialize()

		for layer, i in map:getLayers() do
			if not culling.screenCullingField.layer[i] then
				if layer._layerType == "tile" then
					layer:_edit(1, map.data.mapWidth, 1, map.data.mapHeight, "d")
				elseif layer._layerType == "object" then
					layer:_buildAllObjects()
				end
			end
		end
	else
		for layer in map:getLayers("tile") do
			layer:_edit(1, map.data.mapWidth, 1, map.data.mapHeight, "d")
		end
		for layer in map:getLayers("object") do
			layer:_buildAllObjects()
		end
	end
	
	if enableCulling and not enableCamera then
		map.updateView = updateCulling
	elseif enableCamera and not enableCulling then
		map.updateView = updateOnlyCamera
	elseif enableCulling and enableCamera then
		map.updateView = updateCameraAndCulling
	elseif not enableCulling and not enableCamera then
		-- map.updateView = map._animManager.update
	end
	
	map._updateManager = update


	map:setCameraPosition(0, 0)

	return update
end

return lib_update