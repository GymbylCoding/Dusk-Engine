--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Object Layer

Builds an object layer from data.
--]]
--------------------------------------------------------------------------------

local objectlayer = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_functions = require("Dusk.dusk_core.misc.functions")

local display_newGroup = display.newGroup
local display_newCircle = display.newCircle
local display_newRect = display.newRect
local display_newLine = display.newLine
local display_newSprite = display.newSprite
local display_remove = display.remove
local string_len = string.len
local math_max = math.max
local math_min = math.min
local math_huge = math.huge
local math_nhuge = -math_huge
local table_insert = table.insert
local table_maxn = table.maxn
local type = type
local unpack = unpack
local verby_error = verby.error
local physics_addBody; if physics and type(physics) == "table" and physics.addBody then physics_addBody = physics.addBody else physics_addBody = function() verby_error("Physics library was not found on Dusk Engine startup") end end
local getSetting = lib_settings.get
local spliceTable = lib_functions.spliceTable
local isPolyClockwise = lib_functions.isPolyClockwise
local reversePolygon = lib_functions.reversePolygon
local getProperties = lib_functions.getProperties
local setProperty = lib_functions.setProperty
local rotatePoint = lib_functions.rotatePoint
local physicsKeys = {radius = true, isSensor = true, bounce = true, friction = true, density = true, shape = true}

--------------------------------------------------------------------------------
-- Create Layer
--------------------------------------------------------------------------------
function objectlayer.createLayer(mapData, data, dataIndex, tileIndex, imageSheets, imageSheetConfig)
	local dotImpliesTable = getSetting("dotImpliesTable")
	local ellipseRadiusMode = getSetting("ellipseRadiusMode")
	local onObj = getSetting("onObj")
	local onEllipse = getSetting("onEllipse")
	local onPointBased = getSetting("onPointBased")
	local onImageObj = getSetting("onImageObj")
	local onRect = getSetting("onRect")
	local autoGenerateObjectShapes = getSetting("autoGenerateObjectShapes")

	local layerProps = getProperties(data.properties or {}, "objects", true)

	local layer = display_newGroup()
	layer.props = {}

	layer.object = {}

	------------------------------------------------------------------------------
	-- Create Objects
	------------------------------------------------------------------------------
	for i = 1, #data.objects do
		local o = data.objects[i]
		if not (o ~= nil) then verby_error("Object data missing at index " .. i) end

		local obj
		local objProps = getProperties(o.properties or {}, "object", false)
		local physicsExistent = objProps.options.physicsExistent; if physicsExistent == nil then physicsExistent = layerProps.options.physicsExistent end

		----------------------------------------------------------------------------
		-- Ellipse Object
		----------------------------------------------------------------------------
		if o.ellipse then
			local zx, zy, zw, zh = o.x * screen.zoomX, o.y * screen.zoomY, o.width * screen.zoomX, o.height * screen.zoomY

			if zw > zh then
				obj = display_newCircle(layer, 0, 0, zw * 0.5); obj.yScale = zh / zw
			else
				obj = display_newCircle(layer, 0, 0, zh * 0.5); obj.xScale = zw / zh
			end

			obj.x, obj.y = zx + (obj.contentWidth * 0.5), zy + (obj.contentHeight * 0.5)
			if o.rotation ~= 0 then
				local cornerX, cornerY = zx, zy
				local rX, rY = rotatePoint(zw * 0.5, zh * 0.5, o.rotation or 0)
				obj.x, obj.y = rX + cornerX, rY + cornerY
				obj.rotation = o.rotation
			end

			-- Generate shape
			if autoGenerateObjectShapes and physicsExistent then
				if ellipseRadiusMode == "min" then
					objProps.physics[1].radius = math_min(zw * 0.5, zh * 0.5) -- Min radius
				elseif ellipseRadiusMode == "max" then
					objProps.physics[1].radius = math_max(zw * 0.5, zh * 0.5) -- Max radius
				elseif ellipseRadiusMode == "average" then
					objProps.physics[1].radius = ((zw * 0.5) + (zh * 0.5)) * 0.5 -- Average radius
				end
			end

			obj._objType = "ellipse"
			onEllipse(obj)

		----------------------------------------------------------------------------
		-- Polygon or Polyline Object
		----------------------------------------------------------------------------
		elseif o.polygon or o.polyline then
			local points = o.polygon or o.polyline

			obj = display_newLine(points[1].x, points[1].y, points[2].x, points[2].y)
			obj.points = points -- Give the object the raw point data

			for i = 3, #points do obj:append(points[i].x, points[i].y) end -- Append each point

			if o.polygon then obj:append(points[1].x, points[1].y) end
			obj.x, obj.y = o.x, o.y

			-- Generate physics shape
			if autoGenerateObjectShapes and physicsExistent then
				local physicsShape = {}

				for i = 1, math_min(#points, 8) do
					table_insert(physicsShape, points[i].x)
					table_insert(physicsShape, points[i].y)
				end

				-- Reverse shape if not clockwise (Corona only allows clockwise physics shapes)
				if not isPolyClockwise(physicsShape) then
					physicsShape = reversePolygon(physicsShape)
				end

				objProps.physics[1].shape = physicsShape
			end

			obj._objType = (o.polygon and "polygon") or "polyline"
			onPointBased(obj)

		----------------------------------------------------------------------------
		-- Image Object
		----------------------------------------------------------------------------
		elseif o.gid then
			local tileData = tileIndex[o.gid]
			local sheetIndex = tileData.tilesetIndex
			local tileGID = tileData.gid

			obj = display_newSprite(imageSheets[sheetIndex], imageSheetConfig[sheetIndex])
				obj:setFrame(tileGID)
				obj.x, obj.y = o.x + (mapData.stats.tileWidth * 0.5), o.y - (mapData.stats.tileHeight * 0.5)
				obj.xScale, obj.yScale = screen.zoomX, screen.zoomY

			obj._objType = "image"
			onImageObj(obj)

			-- No need to generate shape because it automatically fits to rectangle shapes

		----------------------------------------------------------------------------
		-- Rectangle Object
		----------------------------------------------------------------------------
		else
			obj = display_newRect(o.x * screen.zoomX, o.y * screen.zoomY, o.width * screen.zoomX, o.height * screen.zoomY)
			obj:translate(obj.width * 0.5, obj.height * 0.5)

			if o.rotation ~= 0 then
				local cornerX, cornerY = o.x, o.y
				local rX, rY = rotatePoint(o.width * 0.5, o.height * 0.5, o.rotation or 0)
				obj.x, obj.y = rX + cornerX, rY + cornerY
				obj.rotation = o.rotation
			end

			obj._objType = "rectangle"
			-- Create point or square special type for objects
			if getSetting("objTypeRectPointSquare") then if obj.width == 0 and obj.height == 0 then obj.objType = "point" elseif obj.width == obj.height then obj.objType = "square" end end

			onRect(obj)

			-- No need to generate shape because it automatically fits to rectangle shapes
		end

		----------------------------------------------------------------------------
		-- Add Physics to Object
		----------------------------------------------------------------------------
		if physicsExistent then
			local physicsParameters = {}
			local physicsBodyCount = layerProps.options.physicsBodyCount
			local tpPhysicsBodyCount = objProps.options.physicsBodyCount; if tpPhysicsBodyCount == nil then tpPhysicsBodyCount = physicsBodyCount end

			physicsBodyCount = math_max(physicsBodyCount, tpPhysicsBodyCount)

			for i = 1, physicsBodyCount do
				physicsParameters[i] = spliceTable(physicsKeys, objProps.physics[i] or {}, layerProps.physics[i] or {})
			end

			if physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
				physics_addBody(obj, physicsParameters[1])
			else
				physics_addBody(obj, unpack(physicsParameters))
			end
		end

		----------------------------------------------------------------------------
		-- Add Properties
		----------------------------------------------------------------------------
		-- Apply onObj function to object
		onObj(obj)

		-- Add object properties
		obj.props = {}

		for k, v in pairs(layerProps.object) do if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(obj, k, v) else obj[k] = v end end
		for k, v in pairs(objProps.object) do if (dotImpliesTable or objProps.options.usedot[k]) and not objProps.options.nodot[k] then setProperty(obj, k, v) else obj[k] = v end end
		for k, v in pairs(objProps.props) do if (dotImpliesTable or objProps.options.usedot[k]) and not objProps.options.nodot[k] then setProperty(obj.props, k, v) else obj.props[k] = v end end

		if obj._objType ~= "image" then
			obj.isVisible = getSetting("virtualObjectsVisible")
		end

		----------------------------------------------------------------------------
		-- Finish Up
		----------------------------------------------------------------------------
		obj._name = o.name
		obj._type = o.type
		layer.object[obj._name] = obj
		table_insert(layer.object, obj)
		layer:insert(obj)
	end

	------------------------------------------------------------------------------
	-- Object Iterator Template
	------------------------------------------------------------------------------
	function layer._newIterator(condition, inTable)
		if not inTable then
			local objects = {}

			for i = 1, table_maxn(layer.object) do
				if layer.object[i] and condition(layer.object[i]) then
					table_insert(objects, {index = i})
				end
			end

			local index = 0

			return function()
				index = index + 1
				if objects[index] then
					return layer.object[objects[index].index]
				else
					return nil
				end
			end
		elseif inTable then
			local objects = {}

			for i = 1, table_maxn(layer.object) do
				if layer.object[i] and condition(layer.object[i]) then
					table_insert(objects, layer.object[i])
				end
			end

			return objects
		end
	end

	------------------------------------------------------------------------------
	-- Iterator: _literal()
	------------------------------------------------------------------------------
	function layer._literal(n, checkFor, inTable)
		if not (n ~= nil) then verby_error("Nothing was passed to constructor of literal-match iterator") end

		local n = n
		local checkFor = checkFor or "type"

		return layer._newIterator(function(obj) return obj[checkFor] == n end, inTable)
	end

	------------------------------------------------------------------------------
	-- Iterator: _match()
	------------------------------------------------------------------------------
	function layer._match(n, checkFor, inTable)
		if not (n ~= nil) then verby_error("Nothing was passed to constructor of pattern-based iterator") end

		local n = n
		local checkFor = checkFor or "type"

		return layer._newIterator(function(obj) return obj[checkFor]:match(n) ~= nil end, inTable)
	end

	------------------------------------------------------------------------------
	-- Iterators
	------------------------------------------------------------------------------
	-- nameIs()
	function layer.nameIs(n, inTable) return layer._literal(n, "_name", inTable) end
	-- nameMatches()
	function layer.nameMatches(n, inTable) return layer._match(n, "_name", inTable) end
	-- typeIs()
	function layer.typeIs(n, inTable) return layer._literal(n, "_type", inTable) end
	-- typeMatches()
	function layer.typeMatches(n, inTable) return layer._match(n, "_type", inTable) end
	-- objTypeIs()
	function layer.objTypeIs(n, inTable) return layer._literal(n, "_objType", inTable) end
	-- objects()
	function layer.objects(inTable) return layer._newIterator(function() return true end, inTable) end

	------------------------------------------------------------------------------
	-- Destroy Layer
	------------------------------------------------------------------------------
	function layer.destroy()
		display_remove(layer)
		layer = nil
	end

	------------------------------------------------------------------------------
	-- Finish Up
	------------------------------------------------------------------------------
	for k, v in pairs(layerProps.props) do if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer.props, k, v) else layer.props[k] = v end end
	for k, v in pairs(layerProps.layer) do if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer, k, v) else layer[k] = v end end

	return layer
end

return objectlayer