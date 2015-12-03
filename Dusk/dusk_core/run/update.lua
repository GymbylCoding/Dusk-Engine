--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Update

Wraps camera and tile culling to create a unified system.
--]]
--------------------------------------------------------------------------------

local lib_update = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")

local getSetting = lib_settings.get

local lib_camera; if getSetting("enableCamera") then lib_camera = require("Dusk.dusk_core.run.camera") end
local lib_culling; if getSetting("enableTileCulling") or getSetting("enableObjectCulling") then lib_tileculling = require("Dusk.dusk_core.run.culling") end
local lib_anim = require("Dusk.dusk_core.run.anim")

--------------------------------------------------------------------------------
-- Register Tile Culling and Camera
--------------------------------------------------------------------------------
function lib_update.register(map)
	local enableCamera, enableTileCulling, enableObjectCulling = getSetting("enableCamera"), getSetting("enableTileCulling"), getSetting("enableObjectCulling")
	local mapLayers = #map.layer

	local update = {}
	local camera, culling
	local enableCulling = enableTileCulling or enableObjectCulling
	local anim = lib_anim.new(map)

	------------------------------------------------------------------------------
	-- Add Camera and Tile Culling to Map
	------------------------------------------------------------------------------
	if enableCamera then
		if not lib_camera then
			lib_camera = require("Dusk.dusk_core.run.camera")
		end

		camera = lib_camera.addControl(map)
	end

	if enableCulling then
		if not lib_culling then
			lib_culling = require("Dusk.dusk_core.run.culling")
		end

		culling = lib_culling.addCulling(map)
		map._culling = culling
		culling.screenCullingField.x, culling.screenCullingField.y = screen.centerX, screen.centerY

		culling.screenCullingField.initialize()

		for layer in map.objectLayers() do
			layer._buildAllObjectDatas()
		end

		for layer, i in map.layers() do
			if not culling.screenCullingField.layer[i] then
				if layer._layerType == "tile" then
					layer._edit(1, map.data.mapWidth, 1, map.data.mapHeight, "d")
				elseif layer._layerType == "object" then
					layer._buildAllObjects()
				end
			end
		end
	else
		for layer in map.tileLayers() do
			layer._edit(1, map.data.mapWidth, 1, map.data.mapHeight, "d")
		end
		for layer in map.objectLayers() do
			layer.draw(1, map.data.mapWidth, 1, map.data.mapHeight)
		end
	end
	
	------------------------------------------------------------------------------
	-- Update Culling Only
	------------------------------------------------------------------------------
	local function updateCulling()
		map._animManager.update()

		for i = 1, #culling.screenCullingField.layer do
			culling.screenCullingField.layer[i].update()
		end
	end

	------------------------------------------------------------------------------
	-- Update Camera Only
	------------------------------------------------------------------------------
	local function updateCamera()
		camera.processCameraViewpoint()
		map._animManager.update()
		
		for i = 1, #camera.layer do
			camera.layer[i].update()
		end
	end
	
	------------------------------------------------------------------------------
	-- Omni-Update
	------------------------------------------------------------------------------
	local function updateView()
		camera.processCameraViewpoint()
		map._animManager.update()
		for i = 1, mapLayers do
			if camera.layer[i] then
				camera.layer[i].update()
			end

			if culling.screenCullingField.layer[i] then
				culling.screenCullingField.layer[i].update()
			end
		end
	end

	------------------------------------------------------------------------------
	-- Destroy
	------------------------------------------------------------------------------
	function update.destroy()
		camera = nil
		culling = nil
	end

	function map.snapCamera()
		local trackingLevel = map.getTrackingLevel()
		map.setTrackingLevel(1)
		map.updateView()
		map.setTrackingLevel(trackingLevel)
	end

	------------------------------------------------------------------------------
	-- Give Tile/Camera Updating to Map
	------------------------------------------------------------------------------
	if enableCulling and not enableCamera then
		map.updateView = updateCulling
		updateView = nil
		updateCamera = nil
	elseif enableCamera and not enableCulling then
		map.updateView = updateCamera
		updateTileCulling = nil
		updateView = nil
	elseif enableCulling and enableCamera then
		map.updateView = updateView
		updateCamera = nil
		updateTileCulling = nil
	elseif not enableCulling and not enableCamera then
		map.updateView = map._animManager.update
	end

	return update
end

return lib_update