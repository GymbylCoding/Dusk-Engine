--------------------------------------------------------------------------------
--[[
Dusk Engine Startup File
--]]
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

display.setDefault("minTextureFilter", "nearest")
display.setDefault("magTextureFilter", "nearest")

require("physics")
physics.start()
physics.setDrawMode("hybrid")

local mapTouch

local dusk = require("Dusk.Dusk")
dusk.setPreference("enableRotatedMapCulling", true)

local map = dusk.buildMap("maps/grass_stone.json")
map.setTrackingLevel(0.3) -- "Fluidity" of the camera movement; numbers closer to 0 mean more fluidly and slowly (but 0 itself will disable the camera!)

local currMap = "grass_stone.json"
local mapX, mapY


--------------------------------------------------------------------------------
-- Set Map
--------------------------------------------------------------------------------
local function setMap(mapName)
	mapX, mapY = map.getViewpoint()
	Runtime:removeEventListener("enterFrame", map.updateView)
	map.destroy()
	map = dusk.buildMap("maps/" .. mapName)
	currMap = mapName
	map.setViewpoint(mapX, mapY)
	map.snapCamera()
	map.setTrackingLevel(0.3)
	map:addEventListener("touch", mapTouch)
	Runtime:addEventListener("enterFrame", map.updateView)
end

--------------------------------------------------------------------------------
-- Runtime Tap Event
--------------------------------------------------------------------------------
local function onTap(event)
	if event.numTaps == 2 then
		native.showAlert("Action", "What would you like to do?", {
			"Load: grass_stone.json",
			"Load: everything.json",
			"Load: square_animated.json",
			"Turn camera rounding " .. (dusk.getPreference("experimental:roundCameraPosition") == true and "off" or "on"),
			"Cancel"
		}, function(event)
			if event.index == 1 then
				setMap("grass_stone.json")
			elseif event.index == 2 then
				setMap("everything.json")
			elseif event.index == 3 then
				setMap("square_animated.json")
			elseif event.index == 4 then
				dusk.setPreference("experimental:roundCameraPosition", not dusk.getPreference("experimental:roundCameraPosition"))
				setMap(currMap)
				native.showAlert("Camera Rounding", "Camera rounding is " .. (dusk.getPreference("experimental:roundCameraPosition") == true and "on" or "off"), {"OK"})
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- Map Touch Event
--------------------------------------------------------------------------------
function mapTouch(event)
	local viewX, viewY = map.getViewpoint()
	local eventX, eventY = map:contentToLocal(event.x, event.y)
	if "began" == event.phase then
		display.getCurrentStage():setFocus(map)
		map.isFocus = true
		map._x, map._y = eventX + viewX, eventY + viewY
	elseif map.isFocus then
		if "moved" == event.phase then
			map.setViewpoint(map._x - eventX, map._y - eventY)
			map.updateView() -- Update the map's camera and culling directly after changing position
		elseif "ended" == event.phase then
			display.getCurrentStage():setFocus(nil)
			map.isFocus = false
		end
	end
end

--------------------------------------------------------------------------------
-- Add Listeners
--------------------------------------------------------------------------------
map:addEventListener("touch", mapTouch)
Runtime:addEventListener("enterFrame", map.updateView)
Runtime:addEventListener("tap", onTap)

-- native.showAlert("Dusk", "Welcome to the Dusk Engine. You have several (alliterative) options...\n\n- Do the demos in the Demos/ directory\n- Try the TOAD tool to tweak tilesets\n- Examine the example environment 'everything.json'\n\nThis example map that's loaded on the screen demonstrates a bunch of Dusk's features - object layers, tile culling, parallax, rotated maps, etc. You can drag and drop it, or double-tap/click to rotate.", {"Got it!"})