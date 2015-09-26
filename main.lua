--------------------------------------------------------------------------------
--[[
Dusk Engine Startup File
--]]
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

display.setDefault("minTextureFilter", "nearest")
display.setDefault("magTextureFilter", "nearest")
display.setDefault("isShaderCompilerVerbose", true)

-- This ain't needed now - Dusk auto-loads physics if needed
-- require("physics")
-- physics.start()
-- physics.setDrawMode("hybrid")

local mapTouch

local dusk = require("Dusk.Dusk")
dusk.setPreference("enableRotatedMapCulling", true)

local currMap = "test2.json"

local fpsText = display.newText({
	text = "FPS",
	fontSize = 13
})

local map = dusk.buildMap("maps/" .. currMap)
map.setTrackingLevel(0.3) -- "Fluidity" of the camera movement; numbers closer to 0 mean more fluidly and slowly (but 0 itself will disable the camera!)

local mapX, mapY

local prevFrame = system.getTimer()

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
			"Load: simple.json",
			"Load: test2.json",
			"Cancel"
		}, function(event)
			if event.index == 1 then
				setMap("simple.json")
			elseif event.index == 2 then
				setMap("test2.json")
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
-- EnterFrame Listener
--------------------------------------------------------------------------------
local function onEnterFrame(event)
	local frameDiff = event.time - prevFrame
	prevFrame = event.time
	local fps = 1000 / frameDiff
	fpsText.text = "FPS: " .. math.round(fps) .. " (target " .. display.fps .. ")"
	fpsText.x, fpsText.y = display.screenOriginX + fpsText.width * 0.5, display.screenOriginY + fpsText.height * 0.5
	fpsText:toFront()
	map.updateView()
end

--------------------------------------------------------------------------------
-- Add Listeners
--------------------------------------------------------------------------------
map:addEventListener("touch", mapTouch)
Runtime:addEventListener("enterFrame", onEnterFrame)
Runtime:addEventListener("tap", onTap)

-- native.showAlert("Dusk", "Welcome to the Dusk Engine. Try double-tapping to load different example maps.", {"Got it!"})