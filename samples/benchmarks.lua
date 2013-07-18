--[[
Ceramic Tile Engine Benchmarking

v1.0
--]]

return function(filename, name)
	local ceramic=require("Ceramic")
	local map=ceramic.buildMap(filename)

	local description="Benchmark Name: "..name.."\nMap File: "..filename.."\nMap Width: "..map("mapWidth").." tiles\nMap Height: "..map("mapHeight").." tiles\nTotal Tiles: "..map("mapWidth")*map("mapHeight")

	local descriptionText=display.newEmbossedText(description, 0, 0, display.contentCenterX, 0, native.systemFontBold, 20)
	descriptionText.x, descriptionText.y=display.contentCenterX, display.contentCenterY
	descriptionText:setTextColor(255, 255, 255)
	descriptionText:setEmbossColor{
		highlight={r=128, g=128, b=128},
		shadow={r=0, g=0, b=0}
	}

	local function dragMap(event)
		if "began"==event.phase then
			map._x, map._y=event.x/map.xScale-map.viewX, event.y/map.yScale-map.viewY
		elseif "moved"==event.phase then
			map.viewX, map.viewY=event.x/map.xScale-map._x, event.y/map.yScale-map._y
			map.render()
		end
	end

	Runtime:addEventListener("touch", dragMap)
end