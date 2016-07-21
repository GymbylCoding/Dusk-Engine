-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Object Grid

The structure that handles object culling.
--]]
-- ************************************************************************** --

local objectGridPrototype = {}

-- ************************************************************************** --

local math_ceil = math.ceil

objectGridPrototype.prepare = function(self, map)
	self.tileWidth, self.tileHeight = map.data.tileWidth, map.data.tileHeight
end

objectGridPrototype.pixelsToGrid = function(self, x, y)
	return math_ceil(x / self.tileWidth), math_ceil(y / self.tileHeight)
end

objectGridPrototype.makeGridEntry = function(self)
	return {lt = {}, rt = {}, lb = {}, rb = {}}
end

-- ************************************************************************** --

objectGridPrototype.generateObjectDataBounds = function(self, objData)
	if objData.type == "ellipse" or objData.type == "rect" or objData.type == "image" then
		objData.bounds.xMin = objData.transfer.x - objData.width * 0.5
		objData.bounds.xMax = objData.transfer.x + objData.width * 0.5
		objData.bounds.yMin = objData.transfer.y - objData.height * 0.5
		objData.bounds.yMax = objData.transfer.y + objData.height * 0.5
	elseif objData.type == "polywhatsit" then
		objData.bounds.xMin = objData.xMin + objData.transfer.x
		objData.bounds.xMax = objData.xMax + objData.transfer.x
		objData.bounds.yMin = objData.yMin + objData.transfer.y
		objData.bounds.yMax = objData.yMax + objData.transfer.y
	end
end

-- ************************************************************************** --

objectGridPrototype.registerData = function(self, objData)
	local l, t = self:pixelsToGrid(objData.bounds.xMin, objData.bounds.yMin)
	local r, b = self:pixelsToGrid(objData.bounds.xMax, objData.bounds.yMax)

	local cells = self.cells

	cells[l] = cells[l] or {}
	cells[r] = cells[r] or {}

	cells[l][t] = cells[l][t] or self:makeGridEntry()
	cells[r][t] = cells[r][t] or self:makeGridEntry()
	cells[l][b] = cells[l][b] or self:makeGridEntry()
	cells[r][b] = cells[r][b] or self:makeGridEntry()

	cells[l][t].lt[#cells[l][t].lt + 1] = objData
	cells[r][t].rt[#cells[r][t].rt + 1] = objData
	cells[l][b].lb[#cells[l][b].lb + 1] = objData
	cells[r][b].rb[#cells[r][b].rb + 1] = objData
end

-- ************************************************************************** --

objectGridPrototype.draw = function(self, x1, x2, y1, y2, source)
	if x1 > x2 then x1, x2 = x2, x1 end
	if y1 > y2 then y1, y2 = y2, y1 end

	for x = x1, x2 do
		if self.cells[x] then
			for y = y1, y2 do
				if self.cells[x][y] then
					local c = self.cells[x][y]

					for i = 1, #c.rt do self.layer:_constructObject(c.rt[i], source) end
					for i = 1, #c.lt do self.layer:_constructObject(c.lt[i], source) end
					for i = 1, #c.rb do self.layer:_constructObject(c.rb[i], source) end
					for i = 1, #c.lb do self.layer:_constructObject(c.lb[i], source) end
				end
			end
		end
	end
end

-- ************************************************************************** --

objectGridPrototype.erase = function(self, x1, x2, y1, y2, dir, source)
	if x1 > x2 then x1, x2 = x2, x1 end
	if y1 > y2 then y1, y2 = y2, y1 end

	for x = x1, x2 do
		if self.cells[x] then
			for y = y1, y2 do
				if self.cells[x][y] then
					local c = self.cells[x][y]

					if dir == "r" and (#c.rt > 0 or #c.rb > 0) then
						for i = 1, #c.rt do if c.rt[i].constructedObject then self.layer:_cullObject(c.rt[i], source) end end
						for i = 1, #c.rb do if c.rb[i].constructedObject then self.layer:_cullObject(c.rb[i], source) end end
					elseif dir == "l" and (#c.lt > 0 or #c.lb > 0) then
						for i = 1, #c.lt do if c.lt[i].constructedObject then self.layer:_cullObject(c.lt[i], source) end end
						for i = 1, #c.lb do if c.lb[i].constructedObject then self.layer:_cullObject(c.lb[i], source) end end
					elseif dir == "u" and (#c.rt > 0 or #c.lt > 0) then
						for i = 1, #c.rt do if c.rt[i].constructedObject then self.layer:_cullObject(c.rt[i], source) end end
						for i = 1, #c.lt do if c.lt[i].constructedObject then self.layer:_cullObject(c.lt[i], source) end end
					elseif dir == "d" and (#c.rb > 0 or #c.lb > 0) then
						for i = 1, #c.rb do if c.rb[i].constructedObject then self.layer:_cullObject(c.rb[i], source) end end
						for i = 1, #c.lb do if c.lb[i].constructedObject then self.layer:_cullObject(c.lb[i], source) end end
					end
				end
			end
		end
	end
end

return objectGridPrototype