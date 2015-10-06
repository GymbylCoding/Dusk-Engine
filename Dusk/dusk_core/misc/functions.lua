--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Functions

Various helper functions for the rest of Dusk to use.
--]]
--------------------------------------------------------------------------------

local lib_functions = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local json = require("json")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local bang = require("Dusk.dusk_core.external.bang")
local syfer = require("Dusk.dusk_core.external.syfer")

local tonumber = tonumber
local type = type
local pairs = pairs
local table_concat = table.concat
local string_gmatch = string.gmatch
local string_len = string.len
local math_sin = math.sin
local math_cos = math.cos
local math_rad = math.rad
local json_decode = json.decode
local syfer_solve = syfer.solve
local getSetting = lib_settings.get
local keyPattern = "([%w_%-%+\"\'!@#$%^&*%(%)]+)%."

local storedPrefixes = getSetting("escapedPrefixMethods")

local stringToValue, spliceTable, isPolyClockwise, reversePolygon, clamp, reverseTable, addProperties, getDirectory, rotatePoint, setProperty, getMapStats

--------------------------------------------------------------------------------
-- General Helper Functions
--------------------------------------------------------------------------------
-- Splice table
function spliceTable(elements, primary, secondary) local newTable = {} for k, v in pairs(elements) do newTable[k] = primary[k]; if newTable[k] == nil then newTable[k] = secondary[k] end end return newTable end
-- Is polygon clockwise
function isPolyClockwise(pointList) local area = 0 for i = 1, #pointList - 2, 2 do local pointStart = {x = pointList[i] - pointList[1], y = pointList[i + 1]-pointList[2]} local pointEnd = {x = pointList[i + 2]-pointList[1], y = pointList[i + 3]-pointList[2]} area = area + (pointStart.x*-pointEnd.y)-(pointEnd.x*-pointStart.y) end return (area < 0) end
-- Reverse polygon (in form of [x,y, x,y, x,y], not [[x,y], [x,y]])
function reversePolygon(t) local nt = {} for i = 1, #t, 2 do nt[#nt + 1] = t[#t - i] nt[#nt + 1] = t[#t - i + 1] end return nt end
-- Clamp value to a range
function clamp(v, l, h) return (v < l and l) or (v > h and h) or v end
-- Reverse table ([1, 2, 3] -> [3, 2, 1])
function reverseTable(t) local new = {} for i = 1, #t do new[#t - (i - 1)] = t[i] end return new end
-- Get directory
function getDirectory(dirTree, path) local path = path local numDirs = #dirTree local _i = 1 while path:sub(_i, _i + 2) == "../" do _i = _i + 3 numDirs = numDirs - 1 end local filename = path:sub(_i) local dirPath = table_concat(dirTree, "/", 1, numDirs) return dirPath, filename end
-- Rotate point
function rotatePoint(pointX, pointY, degrees) local x, y = pointX, pointY local theta = math_rad(degrees) local cosTheta, sinTheta = math_cos(theta), math_sin(theta) local endX = x * cosTheta - y * sinTheta local endY = x * sinTheta + y * cosTheta return endX, endY end

--------------------------------------------------------------------------------
-- Engine Helper Functions
--------------------------------------------------------------------------------
-- String to value
function stringToValue(value)
	local v
	local t = tonumber(value)
	local m = value:match("^!(.-)![^!]")

	if value == "true" or value == "false" then
		if value == "true" then
			v = true
		else
			v = false
		end
	elseif t then
		v = t
	elseif m == "json" then
		v = json_decode(value:sub(7))
	elseif m == "!" then
		v = bang.read(value:sub(4))
	elseif m == "math" then
		v = syfer_solve(value:sub(7), getSetting("evalVariables"))
	elseif m == "tags" then
		value = value:sub(7)
		local t = {}
		for str in value:gmatch("%s*(.-)[,%z]") do t[str] = true end
		local str = value:match("[^,%s]+$") if str then t[str] = true end
		v = t
	elseif storedPrefixes[m] then
		v = storedPrefixes[m](value:sub(#m + 3))
	else
		if value:sub(1,1) == "\"" and value:sub(-1) == "\"" then
			v = value:sub(2, -2)
		else
			v = value
		end
	end
	return v
end

-- Add properties
function addProperties(props, propName, obj)
	local dotImpliesTable = getSetting("dotImpliesTable")
	for k, v in pairs(props[propName]) do
		if (dotImpliesTable or props.options.usedot[k]) and not props.options.nodot[k] then
			setProperty(obj, k, v)
		else
			obj[k] = v
		end
	end
end

-- Set property
function setProperty(t, str, value)
	local write = t
	local path = {}

	for pathElement in string_gmatch(str, keyPattern) do
		path[#path + 1] = stringToValue(pathElement)
	end

	if #path == 0 then write[str] = value return end

	path[#path + 1] = stringToValue(str:match("[%w_%-%+\"\'!@#$%^&*%(%)]+$"))

	for i = 1, #path - 1 do
		if write[path[i] ] == nil then write[path[i] ] = {} end
		write = write[path[i] ]
	end

	write[path[#path] ] = value
	t = write
end

-- Get map statistics
function getMapStats(data)
	local stats = {}
	stats.numTiledLayers = #data.layers
	stats.tilesetCount = #(data.tilesets or {})
	stats.orientation = data.orientation
	stats.mapWidth = data.width
	stats.mapHeight = data.height
	stats.rawTileWidth = data.tilewidth
	stats.rawTileHeight = data.tileheight
	stats.tileWidth = data.tilewidth
	stats.tileHeight = data.tileheight
	stats.width = stats.mapWidth * stats.tileWidth
	stats.height = stats.mapHeight * stats.tileHeight
	stats.mapData = data

	return stats
end

--------------------------------------------------------------------------------
-- Get Properties
--------------------------------------------------------------------------------
local function getProperties(data, objPrefix, isLayer)
	local p = {
		options = {nodot = {}, usedot = {}},
		physics = {{}}, -- Start with one element for the default body
		object = {},
		layer = {},
		props = {},
		anim = {currentFrame = 1, tiles = {}}
	}

	if not isLayer then p.layer = nil end

	local insertionTable
	local objPrefix = objPrefix or "tiles" -- This goes in front of the properties meant for each object in the layer
	local objPrefixLen = objPrefix:len() + 2 -- +2 because +1 is required for the colon after the prefix, and +1 is required to start at the character after that
	local objPrefixMatch = "^" .. objPrefix .. ":"

	local prefixes = getSetting("escapedPrefixMethods")

	for key, value in pairs(data) do
		local k, v

		local dotMode

		if key:match("^!noDot!") then
			key = key:sub((getSetting("spaceAfterEscapedPrefix") and 9) or 8)
			dotMode = false
		elseif key:match("^!dot!") then
			key = key:sub((getSetting("spaceAfterEscapedPrefix") and 7) or 6)
			dotMode = true
		end

		if key:match("^physics:") then
			insertionTable = p.physics[1]
			k = key:sub(9)
		elseif key:match("^physics%d+:") then
			local match = key:match("physics(%d+):")
			local _i = tonumber(match)
			if not p.physics[_i] then p.physics[_i] = {} end
			insertionTable = p.physics[_i]
			k = key:sub(9 + string_len(match))
		elseif key:match("^props:") then
			insertionTable = p.props
			k = key:sub(7)
		elseif key:match("^anim:") then
			insertionTable = p.anim
			k = key:sub(6)
		else
			if isLayer then
				if key:match(objPrefixMatch) then
					insertionTable = p.object
					k = key:sub(objPrefixLen)
				else
					insertionTable = p.layer
					if key:match("^layer:") then k = key:sub(7) else k = key end
				end
			else
				insertionTable = p.object
				if key:match("^self:") then k = key:sub(5) else k = key end
			end
		end

		v = stringToValue(value, prefixes)

		if k == "enabled" and insertionTable == p.physics[1] then
			if v == true then
				p.options.physicsExistent = true
			elseif v == false then
				p.options.physicsExistent = false
			end
		else
			if dotMode == true then p.options.usedot[k] = true elseif dotMode == false then p.options.nodot[k] = true end
			insertionTable[k] = v
		end
	end

	local i = 1
	local newPhysics = {}

	while p.physics[i] do newPhysics[i] = p.physics[i] i = i + 1 end -- Clip off any gaps in the physics table (created with a property like physics3:somethingOrOther and no physics2)

	p.physics = newPhysics
	p.options.physicsBodyCount = #p.physics

	return p
end

--------------------------------------------------------------------------------
-- Add Functions to Public Library
--------------------------------------------------------------------------------
lib_functions.stringToValue = stringToValue
lib_functions.spliceTable = spliceTable
lib_functions.isPolyClockwise = isPolyClockwise
lib_functions.reversePolygon = reversePolygon
lib_functions.clamp = clamp
lib_functions.reverseTable = reverseTable
lib_functions.rotatePoint = rotatePoint
lib_functions.getDirectory = getDirectory
lib_functions.addProperties = addProperties
lib_functions.getProperties = getProperties
lib_functions.setProperty = setProperty
lib_functions.getMapStats = getMapStats

return lib_functions