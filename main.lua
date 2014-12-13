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

local dusk = require("Dusk.Dusk")
dusk.setPreference("enableRotatedMapCulling", true)

local map = dusk.buildMap("maps/grass_stone.json")
map.setTrackingLevel(0.3) -- "Fluidity" of the camera movement; numbers closer to 0 mean more fluidly and slowly (but 0 itself will disable the camera!)

function map:touch(event)
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

function map:tap(event)
	if event.numTaps == 2 then
		map:rotate(10)
		map.updateView()
	end
end

map:addEventListener("touch")
-- map:addEventListener("tap")
Runtime:addEventListener("enterFrame", map.updateView)

-- native.showAlert("Dusk", "Welcome to the Dusk Engine. You have several (alliterative) options...\n\n- Do the demos in the Demos/ directory\n- Try the TOAD tool to tweak tilesets\n- Examine the example environment 'everything.json'\n\nThis example map that's loaded on the screen demonstrates a bunch of Dusk's features - object layers, tile culling, parallax, rotated maps, etc. You can drag and drop it, or double-tap/click to rotate.", {"Got it!"})