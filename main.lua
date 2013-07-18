--------------------------------------------------------------------------------
--[[
Ceramic Tile Engine Demo

v1.0
--]]
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Miscellaneous Loading
--------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )
display.setDefault("minTextureFilter", "linear")
display.setDefault("magTextureFilter", "linear")

local cleanUp
local widget=require("widget")
local benchmarking=require("samples.benchmarks")
local maze=require("samples.maze")
local pathfinding=require("samples.maze_pathfinding")
local platformer=require("samples.platformer")

local buttonSheet=graphics.newImageSheet("assets/button.png", {width=168, height=96, numFrames=2})
local b={}

--------------------------------------------------------------------------------
-- Button Data
--------------------------------------------------------------------------------
local data={
	{"Benchmarking 1", function() cleanUp() benchmarking("maps/benchmarking1.json", "Benchmarking 1") end},
	{"Benchmarking 2", function() cleanUp() benchmarking("maps/benchmarking2.json", "Benchmarking 2") end},
	{"Sample 1: Simple Maze", function() cleanUp() maze() end},
	{"Sample 2: Pathfinding", function() cleanUp() pathfinding() end},
	{"Sample 3: Simple Platformer", function() cleanUp() platformer() end},
}

--------------------------------------------------------------------------------
-- Clean Up Function
--------------------------------------------------------------------------------
function cleanUp()
	for i=1, #b do
		b[i]:removeSelf()
		b[i]=nil
	end
	b=nil
	buttonSheet=nil
end

--------------------------------------------------------------------------------
-- Build Buttons
--------------------------------------------------------------------------------
for i=1, #data do
	b[i]=widget.newButton{
		label=data[i][1],
		labelColor={
			default={255, 255, 255},
			over={255, 255, 255}
		},
		fontSize=22,
		labelYOffset=-64,
		font="Courier New Bold",
		emboss=false,
		sheet=buttonSheet,
		defaultFrame=1,
		overFrame=2,
		onRelease=data[i][2]
	}
	b[i].x, b[i].y=display.contentCenterX, i*b[i].height
end