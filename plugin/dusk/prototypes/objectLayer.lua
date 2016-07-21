-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Object Layer

Corresponds to an object layer in Tiled (suprise!)
--]]
-- ************************************************************************** --

local objectLayerPrototype = {}

-- ************************************************************************** --

local utils = require("plugin.dusk.misc.utils")

local unpack = unpack

local display_newCircle = display.newCircle
local display_newLine = display.newLine
local display_newRect = display.newRect
local display_newSprite = display.newSprite

local table_maxn = table.maxn

local math_huge = math.huge
local math_nhuge = -math.huge
local math_min = math.min
local math_max = math.max

local physicsKeys = {radius = true, isSensor = true, bounce = true, friction = true, density = true, shape = true, filter = true}

if physics and type(physics) == "table" and physics.addBody then
	physics_addBody = physics.addBody
else
	physics_addBody = function(...)
		require("physics")
		physics.start()
		physics_addBody = physics.addBody
		return physics_addBody(...)
	end
end

-- ************************************************************************** --

objectLayerPrototype._cullObject = function(self, objData, source)
	local shouldErase = false
	local obj = objData.constructedObject

	if source then
		if obj._drawers[source.hash] and obj._drawCount == 1 then
			obj._drawers[source.hash] = nil
			shouldErase = true
		elseif obj._drawers[source.hash] then
			obj._drawers[source.hash] = nil
			obj._drawCount = obj._drawCount - 1
		end
	elseif not source then
		shouldErase = true
	end

	if shouldErase then
		local objName, objType = objData.transfer._name, objData.transfer._duskType
		if self._objListeners.erased.name[objName] then
			local l = self._objListeners.erased.name[objName]
			for i = 1, #l do
				l[i]({
					object = obj,
					name = "erased"
				})
			end
		end
		if self._objListeners.erased.type[objType] then
			local l = self._objListeners.erased.type[objType]
			for i = 1, #l do
				l[i]({
					object = obj,
					name = "erased"
				})
			end
		end

		if not objData.isDataObject then
			display.remove(obj)

			self.objects[obj._name] = nil
			self.objects[objData.objectIndex] = nil

			objData.constructedObject = nil
		end
	end
end

-- ************************************************************************** --

objectLayerPrototype._constructObject = function(self, objData, source)
	if not objData.constructedObject then
		local obj

		if not objData.isDataObject then
			if objData.type == "ellipse" then
				obj = display_newCircle(0, 0, objData.radius)
				
				self._cachedSettings.styleEllipse(obj)
			elseif objData.type == "polywhatsit" then
				local points = objData.points

				obj = display_newLine(points[1].x, points[1].y, points[2].x, points[2].y)
				for i = 3, #points do obj:append(points[i].x, points[i].y) end
				if objData.closed then obj:append(points[1].x, points[1].y) end
			
				obj.points = objData.points
				self._cachedSettings.stylePointBased(obj)
			elseif objData.type == "image" then
				local tileData = objData.tileData
				local sheetIndex = tileData.tilesetIndex
				local tileGID = tileData.gid

				obj = display_newSprite(self._imageSheets[sheetIndex], self._imageSheetConfig[sheetIndex])
				obj:setFrame(tileGID)

				self._cachedSettings.styleImageObj(obj)
			elseif objData.type == "rect" then
				obj = display_newRect(0, 0, objData.width, objData.height)

				self._cachedSettings.styleRect(obj)
			end

			self:insert(obj)
		else
			if objData.type == "ellipse" then
				obj = {radius = objData.radius}
			elseif objData.type == "polywhatsit" then
				obj = {points = objData.points}
			elseif objData.type == "image" then
				obj = {tileData = objData.tileData}
			else
				obj = {width = objData.width, height = objData.height}
			end
		end

		if objData.physicsExistent and not objData.isDataObject then
			if #objData.physicsParameters == 1 then
				physics_addBody(obj, objData.physicsParameters[1])
			else
				physics_addBody(obj, unpack(objData.physicsParameters))
			end
		end

		for k, v in pairs(objData.transfer) do obj[k] = v end
		
		objData.constructedObject = obj
		obj._objData = objData

		self.objects[obj._name] = obj
		self.objects[objData.objectIndex] = obj

		if source then
			obj._drawers = {[source.hash] = true}
			obj._drawCount = 1
		end

		if self._objListeners.drawn.name[obj._name] then
			local l = self._objListeners.drawn.name[obj._name]
			for i = 1, #l do
				l[i]({
					object = objData.constructedObject,
					name = "drawn"
				})
			end
		end
		if self._objListeners.drawn.type[obj._duskType] then
			local l = self._objListeners.drawn.type[obj._duskType]
			for i = 1, #l do
				l[i]({
					object = objData.constructedObject,
					name = "drawn"
				})
			end
		end
	else
		if source then
			if not objData.constructedObject._drawers[source.hash] then
				objData.constructedObject._drawers[source.hash] = true
				objData.constructedObject._drawCount = objData.constructedObject._drawCount + 1
			end
		end
	end
end

-- ************************************************************************** --

objectLayerPrototype._constructObjectData = function(self, o)
	local layerProps = self._layerProps
	
	local data = {
		type = "",
		transfer = {props = {}},
		bounds = {
			xMin = math_huge,
			xMax = math_nhuge,
			yMin = math_huge,
			yMax = math_nhuge
		}
	}
	
	local objProps = utils.getProperties(o.properties, o.propertytypes, "object", false)
	local physicsExistent = objProps.options.physicsExistent
	if physicsExistent == nil then physicsExistent = layerProps.options.physicsExistent end

	local isDataObject
	
	if objProps.object["!isData!"] ~= nil then
		isDataObject = objProps["!isData!"]
	elseif layerProps.layer["!isData!"] ~= nil then
		isDataObject = layerProps.layer["!isData!"]
	else
		isDataObject = self._cachedSettings.objectsDefaultToData
	end

	data.physicsExistent = physicsExistent
	data.isDataObject = isDataObject
	data.objectIndex = o.objectIndex

	-- Ellipse
	if o.ellipse then
		data.type = "ellipse"
		data.transfer._objType = "ellipse"
		data.transfer.isVisible = self._cachedSettings.virtualObjectsVisible

		local zx, zy, zw, zh = o.x, o.y, o.width, o.height

		if zw > zh then
			data.radius = zw * 0.5
			data.transfer.yScale = zh / zw
			data.transfer.x = zx + data.radius
			data.transfer.y = zy + data.radius * data.transfer.yScale
		else
			data.radius = zh * 0.5
			data.transfer.xScale = zw / zh
			data.transfer.x = zx + data.radius * data.transfer.xScale
			data.transfer.y = zy + data.radius
		end

		data.width, data.height = zw, zh

		if o.rotation and o.rotation ~= 0 then
			local cornerX, cornerY = zx, zy
			local rX, rY = utils.rotatePoint(zw * 0.5, zh * 0.5, o.rotation)
			data.transfer.x, data.transfer.y = rX + cornerX, rY + cornerY
			data.transfer.rotation = o.rotation
		end

		if autoGenerateObjectShapes and physicsExistent then
			if ellipseRadiusMode == "min" then
				objProps.physics[1].radius = math_min(zw * 0.5, zh * 0.5) -- Min radius
			elseif ellipseRadiusMode == "max" then
				objProps.physics[1].radius = math_max(zw * 0.5, zh * 0.5) -- Max radius
			elseif ellipseRadiusMode == "average" then
				objProps.physics[1].radius = ((zw * 0.5) + (zh * 0.5)) * 0.5 -- Average radius
			end
		end
	-- Polygon, polyline
	elseif o.polygon or o.polyline then
		data.type = "polywhatsit"
		data.transfer._objType = o.polygon and "polygon" or "polyline"
		data.transfer.isVisible = self._cachedSettings.virtualObjectsVisible
		
		local xMin, yMin, xMax, yMax = math_huge, math_huge, math_nhuge, math_nhuge
		local points = o.polygon or o.polyline
		
		for i = 1, #points do
			if points[i].x < xMin then
				xMin = points[i].x
			elseif points[i].x > xMax then
				xMax = points[i].x
			end

			if points[i].y < yMin then
				yMin = points[i].y
			elseif points[i].y > yMax then
				yMax = points[i].y
			end
		end

		data.xMin, data.yMin, data.xMax, data.yMax = xMin, yMin, xMax, yMax
		data.points = points

		data.transfer.x, data.transfer.y = o.x, o.y

		if o.polygon then data.closed = true end -- Just add a `closed` property so we can keep the name "polywhatsit" for joy and gladness

		if self._cachedSettings.autoGenerateObjectShapes and physicsExistent then
			local physicsShape = {}
			for i = 1, math_min(#points, 8) do
				physicsShape[#physicsShape + 1] = points[i].x
				physicsShape[#physicsShape + 1] = points[i].y
			end

			if not utils.isPolyClockwise(physicsShape) then
				physicsShape = utils.reversePolygon(physicsShape)
			end

			objProps.physics[1].shape = physicsShape
		end
	-- Tile image
	elseif o.gid then
		data.type = "image"
		data.transfer._objType = "image"
		data.tileData = self._tileIndex[o.gid]
		data.transfer.x, data.transfer.y = o.x + o.width * 0.5, o.y - o.height * 0.5
		data.width, data.height = o.width, o.height
	-- Rectangle
	else
		data.type = "rect"
		data.transfer._objType = "rect"
		data.transfer.isVisible = self._cachedSettings.virtualObjectsVisible

		data.width, data.height = o.width, o.height

		if self._cachedSettings.furtherClassifyRectangleObjects then
			if data.width == 0 and data.height == 0 then
				data.transfer._objType = "point"
			elseif data.width == data.height then
				data.transfer._objType = "square"
			end
		end
		
		data.transfer.x = o.x + o.width * 0.5
		data.transfer.y = o.y + o.height * 0.5
		
		if o.rotation and o.rotation ~= 0 then
			local cornerX, cornerY = o.x, o.y
			local rX, rY = utils.rotatePoint(o.width * 0.5, o.height * 0.5, o.rotation)
			data.transfer.x, data.transfer.y = rX + cornerX, rY + cornerY
			data.transfer.rotation = o.rotation
		end
	end

	data.transfer._name = o.name
	data.transfer._duskType = o.type

	local dotImpliesTable = self._cachedSettings.dotImpliesTable
	for k, v in pairs(layerProps.object) do if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then utils.setProperty(data.transfer, k, v) else data.transfer[k] = v end end
	for k, v in pairs(objProps.object) do if (dotImpliesTable or objProps.options.usedot[k]) and not objProps.options.nodot[k] then utils.setProperty(data.transfer, k, v) else data.transfer[k] = v end end
	for k, v in pairs(objProps.props) do if (dotImpliesTable or objProps.options.usedot[k]) and not objProps.options.nodot[k] then utils.setProperty(data.transfer.props, k, v) else data.transfer.props[k] = v end end

	-- Physics data
	if physicsExistent then
		local physicsParameters = {}
		local physicsBodyCount = layerProps.options.physicsBodyCount
		local tpPhysicsBodyCount = objProps.options.physicsBodyCount; if tpPhysicsBodyCount == nil then tpPhysicsBodyCount = physicsBodyCount end

		physicsBodyCount = math_max(physicsBodyCount, tpPhysicsBodyCount)

		for i = 1, physicsBodyCount do
			physicsParameters[i] = utils.spliceTable(physicsKeys, objProps.physics[i] or {}, layerProps.physics[i] or {})
		end

		data.physicsParameters = physicsParameters
	end

	if data.isDataObject then
		self:_constructObject(data)
	else
		if not o.rotation or o.rotation == 0 then
			self._objectGrid:generateObjectDataBounds(data)
			self._objectGrid:registerData(data)
		else
			-- Currently can't do rotated objects because of manual bounds calculation
			print("Warning: Object rotation is not 0; object will not be added to culling grid or culled.")
			self:_constructObject(data)
		end
	end

	return data
end

-- ************************************************************************** --

objectLayerPrototype.draw = function(self, x1, x2, y1, y2, source)
	self._objectGrid:draw(x1, x2, y1, y2, source)
end

objectLayerPrototype.erase = function(self, x1, x2, y1, y2, dir, source)
	self._objectGrid:erase(x1, x2, y1, y2, dir, source)
end

-- ************************************************************************** --

objectLayerPrototype.addObjectListener = function(self, forField, value, eventName, callback)
	local target = self._objListeners[eventName]
	if not target then error("Unrecognized event \"" .. eventName .. "\"") end

	if forField == "name" then
		target = target.name
		for object in self:getObjects("name", value) do
			if eventName == "drawn" and object then
				callback({
					object = object,
					name = "drawn"
				})
			elseif eventName == "erased" and not object then
				callback({
					object = object,
					name = "erased"
				})
			end
		end
	elseif forField == "type" then
		target = target.type
		for object in self:getObjects("type", value) do
			if eventName == "drawn" and object then
				callback({
					object = object,
					name = "drawn"
				})
			elseif eventName == "erased" and not object then
				callback({
					object = object,
					name = "erased"
				})
			end
		end
	end

	target[value] = target[value] or {}
	target[value][#target[value] + 1] = callback
end

-- ************************************************************************** --

objectLayerPrototype._buildAllObjectDatas = function(self)
	self._objectGrid:prepare(self.map)
	for i = 1, #self._data.objects do
		local o = self._data.objects[i]
		if o == nil then error("Object data missing at index " .. i) end
		o.objectIndex = i
		self._objDatas[i] = self:_constructObjectData(o)
	end
end

objectLayerPrototype._buildAllObjects = function(self)
	for i = 1, #self._objDatas do
		self:_constructObject(self._objDatas[i])
	end
end

-- ************************************************************************** --

objectLayerPrototype.getObjects = function(self, key, value)
	local i = 0
	return function()
		while true do
			i = i + 1
			if self.objects[i] then
				if key == nil then
					return self.objects[i], i
				elseif value == nil then
					if self.objects[i]._name == key then
						return self.objects[i], i
					end
				else
					if key == "name" and self.objects[i]._name == value then
						return self.objects[i], i
					elseif key == "type" and self.objects[i]._duskType == value then
						return self.objects[i], i
					elseif key == "objectType" and self.objects[i]._objType == value then
						return self.objects[i], i
					end
				end
			elseif i > self._numObjects then
				return nil
			end
		end
		return nil
	end
end

objectLayerPrototype.getObjectDatas = function(self)
	local i = 0
	return function()
		i = i + 1
		if self._objDatas[i] then
			return self._objDatas[i]
		else
			return nil
		end
	end
end

-- ************************************************************************** --

objectLayerPrototype.destroy = function(self)
	for obj in self:getObjects() do
		self:_cullObject(obj._objData)
	end
	display.remove(self)
	self = nil
end

return objectLayerPrototype