--------------------------------------------------------------------------------
--[[
The Runtest file for the Dusk benchmarks.
--]]
--------------------------------------------------------------------------------

local dusk = require("Dusk.Dusk")

local table_insert = table.insert
local table_concat = table.concat
local tostring = tostring
local string_format = string.format
local system_getTimer = system.getTimer

-- from http://lua-users.org/wiki/FormattingNumbers
local function commas(n) local n = tostring(n) local left, num, right = n:match('^([^%d]*%d)(%d*)(.-)$') return left .. (num:reverse():gsub('(%d%d%d)','%1,'):reverse()) .. right end

-- Runtest
local function runtest(name)
	local startTime = system_getTimer()

	local map = dusk.buildMap("tests/benchmarks/" .. name .. ".json")
	
	local buildTime = system_getTimer() - startTime; buildTime = string_format("%.03f", buildTime)
	local numTiles = commas(map.data.mapWidth * map.data.mapHeight)

	local str = "\n\nruntest " .. name .. "\n"
	str = str .. "-> map built" .. "\n"
	str = str .. "-> " .. numTiles .. " tiles" .. "\n"
	str = str .. "-> " .. buildTime .. " ms to load" .. "\n"

	print(str)

	map.setTrackingLevel(0.3)

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
end

return runtest