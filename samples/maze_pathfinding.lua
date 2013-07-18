--[[
Ceramic Tile Engine Sample: Pathfinding Maze

Demonstrates:
	- Generating a pathfinding map
	- Using pathfinding in tandem with Ceramic

Note:
	The Jumper pathfinding module was sourced from github.com/yonaba/jumper.

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
	local map=ceramic.buildMap("maps/maze_pathfinding.json", true) -- Notice the true; this tells Ceramic to load map using basic mode
	
	local jumper_grid=require("jumper.grid")
	local jumper_pathfinder=require("jumper.pathfinder")

	local mapGrid={}

	local str=""

	------------------------------------------------------------------------------
	-- Generate Map Grid
	------------------------------------------------------------------------------
	for y=1, map("mapHeight") do
		mapGrid[y]={}
		str=str.."\n"
		for x=1, map("mapWidth") do
			if map.layer["layer1"].tile(x, y) then
				mapGrid[y][x]=1
				str=str.."##"
			else
				mapGrid[y][x]=0
				str=str.."  "
			end
		end
	end

	print("\nRepresentation of generated pathfinding map: "..str)

	local grid=jumper_grid(mapGrid)
	local pathfinder=jumper_pathfinder(grid, "JPS", 0)

	------------------------------------------------------------------------------
	-- Create Player
	------------------------------------------------------------------------------
	local playerXY=map.layer["layer1"].playerSpawn

	local player=display.newImageRect("assets/player.png", 32, 32)
	player.x=(playerXY[1]-0.5)*map("tileWidth")
	player.y=(playerXY[2]-0.5)*map("tileHeight")

	player.gridX=math.ceil((player.x)/map("tileWidth")) -- Position in tiles
	player.gridY=math.ceil((player.y)/map("tileHeight"))
	
	player.movementAllowed=true -- Allow touches to trigger movement or not
	player.path={} -- Path calculated by Jumper
	player.pathDisplay={} -- Display objects to mark travelled path
	player.nodeIndex=2 -- Current node

	function player.updateGridPos()
		player.gridX, player.gridY=math.ceil((player.x)/map("tileWidth")), math.ceil((player.y)/map("tileHeight"))
	end

	------------------------------------------------------------------------------
	-- Move Player to Next Node
	------------------------------------------------------------------------------
	function player.toNextNode()
		if player.path[player.nodeIndex] then
			if player.nodeTrans then transition.cancel(player.nodeTrans) end

			player.nodeTrans=transition.to(player, {
				x=(player.path[player.nodeIndex][1]-0.5)*map("tileWidth"),
				y=(player.path[player.nodeIndex][2]-0.5)*map("tileHeight"),
				time=100,
				onComplete=function()
					transition.to(player.pathDisplay[player.nodeIndex-1], {xScale=0.5, yScale=0.5, time=100})
					player.pathDisplay[player.nodeIndex-1]:setFillColor(255, 255, 0)
					player.toNextNode()
				end
			})

			player.nodeIndex=player.nodeIndex+1
		else
			player.nodeIndex=2
			player.movementAllowed=true
		end
	end

	map.layer["layer1"]:insert(player)

	------------------------------------------------------------------------------
	-- Check for Existence of Tile at Location
	------------------------------------------------------------------------------
	local function checkForTile(x, y)
		x=math.ceil(x/map("tileWidth"))
		y=math.ceil(y/map("tileHeight"))
		
		return map.layer["layer1"].tile(x, y)~=nil, x, y
	end

	------------------------------------------------------------------------------
	-- Move Player
	------------------------------------------------------------------------------
	local function movePlayer(event)
		if "began"==event.phase and player.movementAllowed then
			for i=1, #player.pathDisplay do
				display.remove(player.pathDisplay[i])
				player.pathDisplay[i]=nil
			end

			player.updateGridPos() -- Reset player grid position

			local pointBlocked, tileX, tileY=checkForTile(event.x, event.y)

			if not pointBlocked then
				local path=pathfinder:getPath(player.gridX, player.gridY, tileX, tileY)
				if path then -- With this map, there will always be a path, but I just put this check in for safety with other maps.
					local length=path:getLength()
					player.path={}
					for node, count in path:nodes() do
						table.insert(player.path, {node:getX(), node:getY()})

						local obj=display.newCircle(0, 0, 10)
						obj.x, obj.y=(node:getX()-0.5)*map("tileWidth"), (node:getY()-0.5)*map("tileHeight")
						table.insert(player.pathDisplay, obj)

						if count==1 then
							obj:setFillColor(255, 255, 0)
						else
							obj:setFillColor(255, 0, 0)
						end
					end

					player.movementAllowed=false
					player.toNextNode() -- Initiate movement
				end
			end
		end
	end

	Runtime:addEventListener("touch", movePlayer)
end