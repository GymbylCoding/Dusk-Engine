--------------------------------------------------------------------------------
--[[
Dusk Engine Demo: Bob
--]]
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

display.setDefault("minTextureFilter", "nearest")
display.setDefault("magTextureFilter", "nearest")

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode("hybrid")

local math_abs = math.abs

local levelNum
local gameEnded
local allowTouches
local spriteOptions
local gui
local map
local player
local m
local toggleGameEnd

--------------------------------------------------------------------------------
-- Declare Vars
--------------------------------------------------------------------------------
-- Point in rect, using Corona objects rather than a list of coordinates
local function pointInRect(point, rect) return (point.x <= rect.contentBounds.xMax) and (point.x >= rect.contentBounds.xMin) and (point.y <= rect.contentBounds.yMax) and (point.y >= rect.contentBounds.yMin) end

levelNum = 2
gameEnded = false
allowTouches = true
spriteOptions = {
	player = {
		{frames = {1, 2, 3, 2, 1, 4, 5, 4}, name = "move", time = 500},
		{frames = {6, 7, 8, 9, 10, 9, 8, 7}, name = "still", time = 1000}
	},
	finish = {
		{frames = {1, 2, 3, 4, 5, 5, 4, 3, 2, 1}, name = "still", time = 1000}
	}
}

--------------------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------------------
gui = display.newGroup()
gui.front = display.newGroup()
gui.back = display.newGroup()

gui:insert(gui.back)
gui:insert(gui.front)

--------------------------------------------------------------------------------
-- Load Map
--------------------------------------------------------------------------------
local dusk = require("Dusk.Dusk")

map = dusk.buildMap("levels/level" .. levelNum .. ".json")
gui.back:insert(map)

--------------------------------------------------------------------------------
-- Load Image Sheets
--------------------------------------------------------------------------------
local playerSheet = graphics.newImageSheet("graphics/bob.png", {width = 64, height = 64, sheetContentWidth = 320, sheetContentHeight = 192, numFrames = 10})
local finishSheet = graphics.newImageSheet("graphics/star.png", {width = 64, height = 64, sheetContentWidth = 320, sheetContentHeight = 64, numFrames = 5})

--------------------------------------------------------------------------------
-- Create Player
--------------------------------------------------------------------------------
player = display.newSprite(playerSheet, spriteOptions.player)
player.speed = 250
player:setFillColor(0, 0, 0)
player.title = "player" -- Used for indentifying player during collision events
map.layer["tiles"]:insert(player)

physics.addBody(player, "dynamic", {radius = player.width * 0.25})

function player:clean()
	self:setSequence("still")
	self:play()
end

--------------------------------------------------------------------------------
-- Create Finish Star
--------------------------------------------------------------------------------
-- We could just as easily transition.to it, but we'll use a sprite for the sake of terseness
local finish = display.newSprite(finishSheet, spriteOptions.finish)

physics.addBody(finish, "static", {radius = finish.width * 0.25, isSensor = true})
finish:setFillColor(0, 0, 0)

map.layer["tiles"]:insert(finish)

function finish:collision(event)
	if event.phase == "began" and event.other.title == "player" then
		transition.to(event.other, {x = self.x, y = self.y, time = 500})
		toggleGameEnd()
	end
end

--------------------------------------------------------------------------------
-- Movement Controls
--------------------------------------------------------------------------------
m = display.newGroup()
gui.front:insert(m)
m.result = "n"
m.prevResult = "n" -- Used to detect if the direction has moved

-- Quick function to make all buttons uniform
local function newButton(parent) local b = display.newRoundedRect(parent, 0, 0, 60, 60, 10) b:setFillColor(0, 0, 0) return b end

-- Create the four buttons and position them
m.l = newButton(m); m.l.x, m.l.y = -60, 0; m.r = newButton(m); m.r.x, m.r.y = 60, 0; m.u = newButton(m); m.u.x, m.u.y = 0, -60; m.d = newButton(m); m.d.x, m.d.y = 0, 60

-- Position controls at lower-left
m.x = display.screenOriginX + m.contentWidth * 0.5 + 20
m.y = display.contentHeight - m.contentHeight * 0.5 - 20

-- Background
m.bkg = display.newRoundedRect(m, 0, 0, m.width + 10, m.height + 10, 20)
m.bkg.x, m.bkg.y = 0, 0
m.bkg:toBack()

-- Touch listener for controls
function m:touch(event)
	if not allowTouches then return false end
	
	if event.target.isFocus or "began" == event.phase then

		m.prevResult = m.result

		-- Set result according to where touch is
		    if pointInRect(event, m.l) then m.result = "l"
		elseif pointInRect(event, m.r) then m.result = "r"
		elseif pointInRect(event, m.u) then m.result = "u"
		elseif pointInRect(event, m.d) then m.result = "d"
		elseif not pointInRect(event, m) then m.result = "n"
		end

	end

	-- Just a generic touch listener
	if "began" == event.phase then
		display.getCurrentStage():setFocus(event.target)
		event.target.isFocus = true
	elseif event.target.isFocus then
		if "ended" == event.phase or "cancelled" == event.phase then
			display.getCurrentStage():setFocus(nil)
			event.target.isFocus = false
			m.result = "n"
		end
	end

	-- Did the direction change?
	if m.prevResult ~= m.result then m.changed = true end

	return true
end

-- Cancel touch event
function m:cancelTouch()
	display.getCurrentStage():setFocus(nil)
	self.isFocus = false
	self.result = "n"
	return true
end

-- Clean
function m:clean()
	self:cancelTouch()
	self:removeEventListener("touch")
	self.l.alpha = 1; self.r.alpha = 1; self.u.alpha = 1; self.d.alpha = 1
end

--------------------------------------------------------------------------------
-- Game Loop
--------------------------------------------------------------------------------
local function gameLoop(event)
	-- Set player velocity according to movement result
	    if m.result == "l" then player:setLinearVelocity(-player.speed, 0)
	elseif m.result == "r" then player:setLinearVelocity(player.speed, 0)
	elseif m.result == "u" then player:setLinearVelocity(0, -player.speed)
	elseif m.result == "d" then player:setLinearVelocity(0, player.speed)
	elseif m.result == "n" then player:setLinearVelocity(0, 0)
	end

	-- This is required because we only want to reset the animation if Bob has changed his state - not every frame
	if m.changed then
		m.changed = false
		m.l.alpha = 1; m.r.alpha = 1; m.u.alpha = 1; m.d.alpha = 1
		if m.result ~= "n" then			
			player:setSequence("move")
			player:play()

			-- "Cheat" so we don't have to have four animations
			    if m.result == "l" then m.l.alpha = 0.5 player.rotation = 0
			elseif m.result == "r" then m.r.alpha = 0.5 player.rotation = 180
			elseif m.result == "u" then m.u.alpha = 0.5 player.rotation = 90
			elseif m.result == "d" then m.d.alpha = 0.5 player.rotation = 270
			end
		elseif m.result == "n" then
			player:setSequence("still")
			player:play()
		end
	end

	map.updateView() -- Cull tiles, update camera, etc. via a single function call
end

--------------------------------------------------------------------------------
-- Game End
--------------------------------------------------------------------------------
function toggleGameEnd()
	m:clean()
	player:clean()
	transition.to(gui, {alpha = 0, time = 1500, transition = easing.outQuad})
end

--------------------------------------------------------------------------------
-- Finish Up
--------------------------------------------------------------------------------
Runtime:addEventListener("enterFrame", gameLoop)
m:addEventListener("touch")
finish:addEventListener("collision")

-- Position player and star
player.x, player.y = map.tilesToPixels(map.playerLocation.x + 0.5, map.playerLocation.y + 0.5)
finish.x, finish.y = map.tilesToPixels(map.finishLocation.x + 0.5, map.finishLocation.y + 0.5)

-- Set up map camera
map.setCameraFocus(player)
map.setTrackingLevel(0.1)

-- Set up animations
player:setSequence("still")
player:play()
finish:setSequence("still") -- Always good to be explicit, even if there's only one animation
finish:play()

-- Display the initial alert
native.showAlert("Bob", "Welcome to the Bob demo. This demo uses Box2D physics added via properties to make a simple maze environment for Bob to move around in.\n\nControl the player with the D-pad in the bottom left corner.\n\nRead the code to see how it works!", {"Got it!"})