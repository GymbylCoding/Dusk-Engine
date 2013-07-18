--[[
Ceramic Tile Engine Sample: Simple Platformer

Demonstrates:
	- Basic access of Tiled properties and objects
	- Implementing physics into Tiled maps (object physics)
	- Identifying single objects from a layer
	- Camera system
	- Connecting player and map

Sample Version 1.0
--]]

return function()
	------------------------------------------------------------------------------
	-- Load Miscellaneous
	------------------------------------------------------------------------------
	require("physics")
	physics.start()
	physics.setScale(140)
	--physics.setDrawMode("hybrid")

	local bkg=display.newRect(0, 0, display.contentWidth, display.contentHeight) -- Build rect to cover background
	bkg:setFillColor(255, 0, 255)

	local ceramic=require("Ceramic")
	local map=ceramic.buildMap("maps/platformer.json")

	------------------------------------------------------------------------------
	-- Create Player
	------------------------------------------------------------------------------
	local player=display.newRect(0, 0, 32, 64)

	physics.addBody(player, 
		{bounce=0, friction=0.5}, -- The collisions body
		{isSensor=true, shape={-12,32, 12,32, 12,33, -12,33}} -- The grounding body
	)
	player.isFixedRotation=true
	player.velX=1 -- Velocity
	player.prevVelX=1
	player.grounded=0 -- Must be a counter because if it's a Boolean and player is touching two grounding objects at once, when player ends collision with one, but remains touching the other, it registers as not grounded
	player.linearDamping=1
	player.canMove=true

	player.x=map.layer["objects"].object["playerSpawn"].x
	player.y=map.layer["objects"].object["playerSpawn"].y

	map.layer["layer_1"]:insert(player)

	------------------------------------------------------------------------------
	-- Player Collision and Pre-Collision
	------------------------------------------------------------------------------
	function player:collision(event)
		if "began"==event.phase then
			if event.other._type=="ground" and event.selfElement==2 then -- Sensor object created in Tiled
				player.grounded=player.grounded+1
			elseif event.other._type=="pipe" and event.selfElement==2 then
				player.canMove=false
				
				transition.to(player, {x=event.other.x, time=200, onComplete=function()
					player.isBodyActive=false
					transition.to(player, {
						y=event.other.y+32,
						time=750,
						delay=200,
						onComplete=function()
							player.isVisible=false
							transition.to(player, {
								x=map.layer["objects"].object[event.other.destination].x,
								y=map.layer["objects"].object[event.other.destination].y+32,
								time=1000,
								delay=200,
								onComplete=function()
									player.isVisible=true
									transition.to(player, {
										y=map.layer["objects"].object[event.other.destination].y-32,
										time=750,
										delay=200,
										onComplete=function()
											player.isBodyActive=true
											player.canMove=true
											player:applyLinearImpulse(0.001, -0.003)
										end
									})
								end
							})
						end
					})
				end
			})
			
			end
		elseif "ended"==event.phase then
			if event.other._type=="ground" and event.selfElement==2 then
				player.grounded=player.grounded-1
			end
		end
	end

	function player:preCollision(event)
		if event.contact then
			if event.other.collisionType=="platform" then -- Custom property "collisionType"
				if event.other.contentBounds.yMin>=self.contentBounds.yMax then -- Make sure player is above platform
					event.contact.isEnabled=true
				else
					event.contact.isEnabled=false
				end
			end
		end
	end

	player:addEventListener("collision")
	player:addEventListener("preCollision")

	------------------------------------------------------------------------------
	-- Animate Player and Set Velocity
	------------------------------------------------------------------------------
	local function setPlayerVelocityX()
		if player.canMove then

			local vx, vy=player:getLinearVelocity()
			if player.velX~=0 then
				player:setLinearVelocity(player.velX, vy) -- Retain Y-velocity
			end

			if player.grounded>0 and vy==0 then
				player:applyLinearImpulse(0, -0.007)
			end
		end
	end

	------------------------------------------------------------------------------
	-- Move Player with Touch
	------------------------------------------------------------------------------
	local function movePlayer(event)
		player.velX=event.x-display.contentCenterX
		player.velX=math.min(math.max(player.velX, -300), 300)

		if "began"==event.phase then

		elseif "ended"==event.phase then
			player.velX=0
			player.isJumping=false
		end
	end

	------------------------------------------------------------------------------
	-- Main EnterFrame Listener
	------------------------------------------------------------------------------
	local function onEnterFrame()
		setPlayerVelocityX()
		map.updateCamera()
	end

	------------------------------------------------------------------------------
	-- Add Listeners
	------------------------------------------------------------------------------
	Runtime:addEventListener("touch", movePlayer)
	Runtime:addEventListener("enterFrame", onEnterFrame)

	map.setCameraFocus(player)
	map.setCameraBounds(
		display.contentCenterX, map("mapWidth")*map("tileWidth")-display.contentCenterX,
		display.contentCenterY, map("mapHeight")*map("tileHeight")-display.contentCenterY
	)
end