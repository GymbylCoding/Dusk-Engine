--------------------------------------------------------------------------------
--[[
Dusk Engine Startup File
--]]
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

-- Minimize border flicker
local textureFilter = "nearest"
display.setDefault("minTextureFilter", textureFilter)
display.setDefault("magTextureFilter", textureFilter)

require("physics")
physics.start()
physics.setDrawMode("hybrid")

local dusk = require("Dusk.Dusk")

local map = dusk.buildMap("everything.json")
map.setTrackingLevel(0.3) -- "Fluidity" of the camera movement

function map.drag(event)
	local viewX, viewY = map.getViewpoint()
	if "began" == event.phase then
		display.getCurrentStage():setFocus(map)
		map.isFocus = true
		map._x, map._y = event.x + viewX, event.y + viewY
	elseif map.isFocus then
		if "moved" == event.phase then
			map.setViewpoint(map._x - event.x, map._y - event.y)
			map.updateView() -- Update the map's camera and culling directly after changing position
		elseif "ended" == event.phase then
			display.getCurrentStage():setFocus(nil)
			map.isFocus = false
		end
	end
end

map:addEventListener("touch", map.drag)
Runtime:addEventListener("enterFrame", map.updateView)

native.showAlert("Dusk", "Welcome to the Dusk Engine. You have several (alliterative) options...\n\n- Do the demos in the Demos/ directory\n- Try the TOAD tool to tweak tilesets\n- Examine the example environment 'everything.json'", {"Got it!"})