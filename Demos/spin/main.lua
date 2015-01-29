--------------------------------------------------------------------------------
--[[
Dusk Engine Demo: Spin
--]]
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

local textureFilter = "nearest"
display.setDefault("minTextureFilter", textureFilter)
display.setDefault("magTextureFilter", textureFilter)

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local dusk = require("Dusk.Dusk")
local intersection = require("intersection")

local math_ceil = math.ceil
local math_abs = math.abs
local table_insert = table.insert

local map
local player
local move
local maxSpeed
local accelRate
local canJump
----
local gravity

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------
local distanceBetween = function(x1, y1, x2, y2) return (((x2 - x1) ^ 2) + ((y2 - y1) ^ 2)) ^ 0.5 end
local getPointsAlongLine = function(x1, y1, x2, y2, d) local points = {} local diffX = x2 - x1 local diffY = y2 - y1 local distBetween = math_ceil(distanceBetween(x1, y1, x2, y2) / d) local x, y = x1, y1 local addX, addY = diffX / distBetween, diffY / distBetween for i = 1, distBetween do table_insert(points, {x, y}) x, y = x + addX, y + addY end return points end
local clamp = function(v, l, h) return (v < l and l) or (v > h and h) or v end

--------------------------------------------------------------------------------
-- Load Map
--------------------------------------------------------------------------------
map = dusk.buildMap("map.json")

maxSpeed = 20
accelRate = 0.002
canJump = true

gravity = 0.3

--------------------------------------------------------------------------------
-- Create Player
--------------------------------------------------------------------------------
player = display.newImageRect("graphics/ball.png", 40, 40)
map.layer[1]:insert(player)

player.downSensorLength = 20 -- How far below the player the ground is stopped
player.sensorWidth = 3
player.xVel, player.yVel = 0, 0 -- Initial X and Y velocities
player.groundOffset = 20 -- Y-offset of the player's collision point
player.xRetain = 0.95
player.bounce = 0.5 -- Tweak this if you want
player.jumpForce = 15
player.isGrounded = false -- This flag represents if the player is on the ground

--------------------------------------------------------------------------------
-- Create Movement System
--------------------------------------------------------------------------------
move = display.newGroup()

-- Elements of movement system
move.background = display.newRoundedRect(0, 0, display.contentWidth - 20, 60, 9)
move.background.strokeWidth = 4
move.background:setFillColor(0, 0, 0)
move:insert(move.background)

move.fillBar = display.newRect(0, 0, 10, move.height - move.background.strokeWidth)
move.fillBar:setFillColor(1, 1, 1)
move:insert(move.fillBar)

move.bar = display.newRoundedRect(0, 0, move.background.height * 0.6, move.height, 9)
move:insert(move.bar)

move.jump = display.newPolygon(0, 0, {0,-30, 15,15, -15,15})
move.jump.strokeWidth = 3
move.jump:setStrokeColor(1, 1, 1)
move.jump:setFillColor(0, 0, 0)
move:insert(move.jump)

-- Position controls at bottom of screen
move.x, move.y = display.contentCenterX, display.contentHeight - 10 - move.height * 0.5

-- Function to draw the fill bar
function move.drawFill()
	move.fillBar.width = math_abs(move.bar.x)
	move.fillBar.x = move.bar.x * 0.5
end

function move:touch(event)
	if "began" == event.phase then
		display.getCurrentStage():setFocus(move, event.id)
		move.isFocus = true
		move.bar.x = clamp(event.x - move.x, -move.width * 0.5 + move.bar.width * 0.5, move.width * 0.5 - move.bar.width * 0.5)
		move.jump.x = move.bar.x
		move.jump.y = clamp((event.y - event.yStart) * 0.8, -move.background.height, 0)
		move.drawFill()
	elseif move.isFocus then
		if "moved" == event.phase then
			move.bar.x = clamp(event.x - move.x, -move.width * 0.5 + move.bar.width * 0.5, move.width * 0.5 - move.bar.width * 0.5)
			move.jump.x = move.bar.x
			move.jump.y = clamp((event.y - event.yStart) * 0.8, -move.background.height, 0)
			move.drawFill()
		elseif "ended" == event.phase then
			display.getCurrentStage():setFocus(nil, event.id)
			move.isFocus = false
			move.bar.x = 0
			move.jump.x, move.jump.y = 0, 0
			move.drawFill()
		end
	end

	if move.jump.y ~= -move.background.height then canJump = true end
end

--------------------------------------------------------------------------------
--[[
This is our main collision function. All it does is determine the intersection
point between two lines, if any, and return it.
--]]
--------------------------------------------------------------------------------
local checkTile = function(tile)
	local intersectionPoint = intersection(
		-- Line segment #1: line drawn between player's current and previous positions
		player.x, player.y + player.groundOffset,
		player.x, player.prevY,
		-- Line segment #2: Top of tile
		tile.x - (tile.width * 0.5), tile.y - (tile.height * 0.5),
		tile.x + (tile.width * 0.5), tile.y - (tile.height * 0.5)
	)

	if intersectionPoint then
		return true, intersectionPoint
	else
		return false
	end
end

--------------------------------------------------------------------------------
--[[
resolveCollision()

Resolves a collision with the player, given the collision point.
--]]
--------------------------------------------------------------------------------
local resolveCollision = function(point)
	if player.yVel >= 0 then
		player.y = point.y - player.groundOffset
		player.yVel = -(player.yVel * player.bounce)
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------------
--[[
updatePlayerCollisions()

This function wraps up checkTile() and resolveCollision().
--]]
--------------------------------------------------------------------------------
local updatePlayerCollisions = function()
	--[[
	First, we do a collision check on the current position of the player. If the
	player has collided, we return before checking through all the points.
	--]]
	local tile = map.layer[1].tileByPixels(player.x, player.y + player.groundOffset)
	if tile then
		local collided, point = checkTile(tile)
		if collided then
			return resolveCollision(point)
		end
	end

	--[[
	If we're still in the function, we didn't get a collision for the current
	position. Thus, we calculate the tiles between the player's current position
	and the player's previous position, then do a collision check for each one.
	This prevents the player from moving through the floor if it is going fast.
	--]]
	local points = getPointsAlongLine(player.x, player.prevY + player.groundOffset, player.x, player.y + player.groundOffset, map.data.tileHeight)

	for i = 1, #points do
		local tile = map.layer[1].tileByPixels(points[i][1], points[i][2])
		if tile then
			local collided, point = checkTile(tile)
			if collided then
				return resolveCollision(point)
			end
		end
	end

	return false
end

--------------------------------------------------------------------------------
--[[
gameLoop()

This function is executed each frame. It moves the player, applies gravity, and
calls the collision check functions.
--]]
--------------------------------------------------------------------------------
local gameLoop = function(event)
	player.prevX, player.prevY = player.x, player.y

	player.xVel = clamp(player.xVel + (move.bar.x * accelRate), -maxSpeed, maxSpeed) * player.xRetain
	player.yVel = player.yVel + gravity

	player:translate(player.xVel, player.yVel)

	local isGrounded = updatePlayerCollisions()
	player.isGrounded = isGrounded

	if player.isGrounded then
		if move.jump.y <= -move.background.height and canJump then
			player.yVel = -player.jumpForce
			canJump = false
		end
	end

	player:rotate(player.xVel * 2)
	
	map.updateView()
end

--------------------------------------------------------------------------------
-- Finish Up
--------------------------------------------------------------------------------
player.x, player.y = map.tilesToPixels(map.playerPosition)

map.setTrackingLevel(0.1)
map.setCameraFocus(player)

-- display.getCurrentStage():setFocus(move)

Runtime:addEventListener("enterFrame", gameLoop)
move:addEventListener("touch")

-- Display the initial alert
-- native.showAlert("Spin", "Welcome to the Spin demo. This is a demo that demonstrates non-Box2D physics using tile properties.\n\nControl the player by clicking or touching to either side of the screen and moving back and forth. To jump, slide the touch or click point upward. To do multiple jumps, you'll need to move your click or touch point to the position along the Y-axis that it started.\n\nRead the code to see how it works!", {"Got it!"})