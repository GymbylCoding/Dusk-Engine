--[[
Ceramic Tile Engine Sample: Simple Maze

Demonstrates:
	- Finding tiles in map
	- Non-physical maps
	- Using Ceramic's basic mode

Note:
	Ceramic has a different mode for less advanced projects that doesn't include 
	culling or the camera system. This makes map loading a tad faster but doesn't
	give you the extra functionality. To use this mode, add a second argument to
	the ceramic.buildMap() call as the Boolean value of "true".

Sample Version 1.0
--]]

return function()
	------------------------------------------------------------------------------
	-- Load Miscellaneous
	------------------------------------------------------------------------------
	require("physics")
	physics.start()
	physics.setScale(140)
	physics.setDrawMode("hybrid")

	local ceramic=require("Ceramic")
	local map=ceramic.buildMap("maps/maze.json", true) -- Notice the true; this tells Ceramic to load map using basic mode

	------------------------------------------------------------------------------
	-- Create Player
	------------------------------------------------------------------------------
	local player=display.newImageRect("assets/player.png", 32, 32)
	player.x=map.layer["objects"].object["playerSpawn"].x
	player.y=map.layer["objects"].object["playerSpawn"].y

	map.layer["layer1"]:insert(player)

	------------------------------------------------------------------------------
	-- Check for Existence of Tile at Location
	------------------------------------------------------------------------------
	local function checkForTile(x, y)
		local x=math.ceil((player.x+x)/map("tileWidth"))
		local y=math.ceil((player.y+y)/map("tileHeight"))
		
		return map.layer["layer1"].tile(x, y)~=nil
	end

	------------------------------------------------------------------------------
	-- Move Player
	------------------------------------------------------------------------------
	local function movePlayer(event)
		if "began"==event.phase then
			local xDist=math.abs(event.x-player.x)
			local yDist=math.abs(event.y-player.y)

			if xDist>yDist then
				if event.x<player.x then
					if not checkForTile(-map("tileWidth"), 0) then
						player:translate(-map("tileWidth"), 0)
					end
				elseif event.x>player.x then
					if not checkForTile(map("tileWidth"), 0) then
						player:translate(map("tileWidth"), 0)
					end
				end
			elseif yDist>xDist then
				if event.y<player.y then
					if not checkForTile(0, -map("tileHeight")) then
						player:translate(0, -map("tileHeight"))
					end
				elseif event.y>player.y then
					if not checkForTile(0, map("tileHeight")) then
						player:translate(0, map("tileHeight"))
					end
				end
			end
		end
	end

	Runtime:addEventListener("touch", movePlayer)
end