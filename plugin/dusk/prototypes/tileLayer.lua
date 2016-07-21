-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Tile Layer

Handles everything pertaining to tiles.
--]]
-- ************************************************************************** --

local tileLayerPrototype = {}

-- ************************************************************************** --

local utils = require("plugin.dusk.misc.utils")

local setProperty = utils.setProperty
local constructTilePhysicsBody = utils.constructTilePhysicsBody

local tostring = tostring
local unpack = unpack

local display_newSprite = display.newSprite
local display_newRect = display.newRect
local display_newImageRect = display.newImageRect
local math_max = math.max
local table_maxn = table.maxn

local physics_addBody

-- ************************************************************************** --

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

local flipX = tonumber("80000000", 16)
local flipY = tonumber("40000000", 16)
local flipD = tonumber("20000000", 16)

-- ************************************************************************** --

tileLayerPrototype.tile = function(self, x, y) if self.tiles[x] ~= nil and self.tiles[x][y] ~= nil then return self.tiles[x][y] else return nil end end
tileLayerPrototype.isTileWithinCullingRange = function(self, x, y) return x >= self._drawnLeft and x <= self._drawnRight and y >= self._drawnTop and y <= self._drawnBottom end

-- ************************************************************************** --

tileLayerPrototype._getTileGID = function(self, x, y)
	local idX, idY = x, y

	if x < 1 or x > self._mapData.width then
		local edgeModeLeft, edgeModeRight = self.edgeModeLeft or self.edgeModeX or "stop", self.edgeModeRight or self.edgeModeX or "stop"
		local underX, overX = x < 1, x > self._mapData.width

		if (underX and edgeModeLeft == "stop") or (overX and edgeModeRight == "stop") then
			return 0
		elseif (underX and edgeModeLeft == "wrap") or (overX and edgeModeRight == "wrap") then
			idX = (idX - 1) % self._mapData.width + 1
		elseif (underX and edgeModeLeft == "clamp") or (overX and edgeModeRight == "clamp") then
			idX = (underX and 1) or (overX and self._mapData.width)
		end
	end

	if y < 1 or y > self._mapData.height then
		local edgeModeTop, edgeModeBottom = self.edgeModeTop or self.edgeModeY or "stop", self.edgeModeBottom or self.edgeModeY or "stop"
		local underY, overY = y < 1, y > self._mapData.height

		if (underY and edgeModeTop == "stop") or (overY and edgeModeBottom == "stop") then
			return 0
		elseif (underY and edgeModeTop == "wrap") or (overY and edgeModeBottom == "wrap") then
			idY = (idY - 1) % self._mapData.height + 1
		elseif (underY and edgeModeTop == "clamp") or (overY and edgeModeBottom == "clamp") then
			idY = (underY and 1) or (overY and self._mapData.height)
		end
	end

	local id = ((idY - 1) * self._mapData.width) + idX
	gid = self._layerData.data[id]

	if gid == 0 then return 0 end
	
	local flippedX, flippedY, flippedD = false, false, false
	if gid % (gid + flipX) >= flipX then gid = gid - flipX flippedX = true end
	if gid % (gid + flipY) >= flipY then gid = gid - flipY flippedY = true end
	if gid % (gid + flipD) >= flipD then gid = gid - flipD flippedD = true end
	
	return gid, flippedX, flippedY, flippedD
end

-- ************************************************************************** --

tileLayerPrototype._constructTileData = function(self, x, y)
	local gid, tilesetGID, tileProps, isSprite, isAnimated, flippedX, flippedY, rotated, pixelX, pixelY
	
	local layerTiles = self.tiles
	local tileProperties = self._tileProperties
	local layerProperties = self._layerProperties
	
	if layerTiles[x] ~= nil and layerTiles[x][y] ~= nil then
		local tile = layerTiles[x][y]

		gid = tile.gid
		
		tilesetGID = tile.tilesetGID

		local sheetIndex = tile.tileset

		if tileProperties[sheetIndex][tilesetGID] then
			tileProps = tileProperties[sheetIndex][tilesetGID]
		end

		isSprite = tile.isSprite
		isAnimated = tile.isAnimated

		pixelX, pixelY = tile.x, tile.y
		flippedX = tile.flippedX
		flippedY = tile.flippedY
	else
		gid, flippedX, flippedY, rotated = self:_getTileGID(x, y)
		local tilesheetData = self._tileIndex[gid]
		local sheetIndex = tilesheetData.tilesetIndex
		local tileGID = tilesheetData.gid

		if tileProperties[sheetIndex][tileGID] then
			tileProps = tileProperties[sheetIndex][tileGID]
		end

		isSprite = tileProps and tileProps.object["!isSprite!"]
		tilesetGID = tileGID
		pixelX, pixelY = self._mapData.stats.tileWidth * (x - 0.5), self._mapData.stats.tileHeight * (y - 0.5)
	end

	local tileData = {
		gid = gid,
		tilesetGID = tilesetGID,
		isSprite = isSprite,
		isAnimated = isAnimated,
		flippedX = flippedX,
		flippedY = flippedY,
		width = self._mapData.stats.tileWidth,
		height = self._mapData.stats.tileHeight,
		contentWidth = self._mapData.stats.tileWidth,
		contentHeight = self._mapData.stats.tileHeight,
		xScale = flippedX and -1 or 1,
		yScale = flippedY and -1 or 1,
		tileX = x,
		tileY = y,
		parent = self,
		x = pixelX,
		y = pixelY,
		props = {}
	}

	for k, v in pairs(layerProperties.object) do
		if (self._dotImpliesTable or layerProperties.options.usedot[k]) and not layerProperties.options.nodot[k] then setProperty(tileData, k, v) else tileData[k] = v end
	end

	if tileProps then
		for k, v in pairs(tileProps.object) do
			if (self._dotImpliesTable or layerProperties.options.usedot[k]) and not layerProperties.options.nodot[k] then setProperty(tileData, k, v) else tileData[k] = v end
		end

		for k, v in pairs(tileProps.props) do
			if (self._dotImpliesTable or layerProperties.options.usedot[k]) and not layerProperties.options.nodot[k] then setProperty(tileData.props, k, v) else tileData.props[k] = v end
		end
	end

	return tileData
end

-- ************************************************************************** --

tileLayerPrototype._drawTile = function(self, x, y, source)
	local layerTiles = self.tiles
	local locked = self._locked
	local tileProperties = self._tileProperties
	local layerProperties = self._layerProperties
	
	if locked[x] and locked[x][y] == "e" then return false end
	
	if not (layerTiles[x] and layerTiles[x][y]) then
		local gid, flippedX, flippedY, rotated = self:_getTileGID(x, y)
		
		if gid == 0 then return false end

		if gid > self._mapData.highestGID or gid < 0 then error("Invalid GID at position [" .. x .. "," .. y .."] (index #" .. id ..") - expected [0 <= GID <= " .. self._mapData.highestGID .. "] but got " .. gid .. " instead.") end

		local tileData = self._tileIndex[gid]
		local sheetIndex = tileData.tilesetIndex
		local tileGID = tileData.gid

		local tile
		local tileProps

		if tileProperties[sheetIndex][tileGID] then
			tileProps = tileProperties[sheetIndex][tileGID]
		end

		if tileProps and tileProps.object["!isSprite!"] then
			tile = display_newSprite(self._imageSheets[sheetIndex], self._imageSheetConfig[sheetIndex])
			tile:setFrame(tileGID)
			tile.isSprite = true
		elseif tileProps and tileProps.anim.enabled then
			tile = display_newSprite(self._imageSheets[sheetIndex], tileProps.anim.options)
			tile._animData = tileProps.anim
			tile.isAnimated = true
		else
			if useTileImageSheetFill then
				tile = display_newRect(0, 0, self._mapData.stats.tileWidth, self._mapData.stats.tileHeight)
				tile.imageSheetFill = {
					type = "image",
					sheet = self._imageSheets[sheetIndex],
					frame = tileGID
				}
				tile.fill = tile.imageSheetFill
			else
				tile = display_newImageRect(self._imageSheets[sheetIndex], tileGID, self._mapData.stats.tileWidth, self._mapData.stats.tileHeight)
			end
		end
		
		tile.props = {}
		
		tile.x, tile.y = self._mapData.stats.tileWidth * (x - 0.5), self._mapData.stats.tileHeight * (y - 0.5)
		-- tile.xScale, tile.yScale = screen.zoomX, screen.zoomY

		tile.gid = gid
		tile.tilesetGID = tileGID
		tile.tileset = sheetIndex
		tile.layerIndex = dataIndex
		tile.tileX, tile.tileY = x, y
		tile.hash = tostring(tile)
		
		if source then
			tile._drawers = {[source.hash] = true}
			tile._drawCount = 1
		end

		if flippedX then tile.xScale = -tile.xScale end
		if flippedY then tile.yScale = -tile.yScale end

		-- ***** --

		if tileProps then
			local shouldAddPhysics = tileProps.options.physicsExistent
			if shouldAddPhysics == nil then shouldAddPhysics = layerProperties.options.physicsExistent end
			if shouldAddPhysics then
				local physicsParameters
				if tileProps.storedPhysicsData then
					physicsParameters = tileProps.storedPhysicsData
				else
					physicsParameters = constructTilePhysicsBody(tile, layerProperties, tileProps)
					tileProps.storedPhysicsData = physicsParameters
				end

				if physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
					physics_addBody(tile, physicsParameters[1])
				else
					physics_addBody(tile, unpack(physicsParameters))
				end
			end
			
			for k, v in pairs(layerProperties.object) do
				if (self._dotImpliesTable or layerProperties.options.usedot[k]) and not layerProperties.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
			end

			for k, v in pairs(tileProps.object) do
				if (self._dotImpliesTable or layerProperties.options.usedot[k]) and not layerProperties.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
			end

			for k, v in pairs(tileProps.props) do
				if (self._dotImpliesTable or layerProperties.options.usedot[k]) and not layerProperties.options.nodot[k] then setProperty(tile.props, k, v) else tile.props[k] = v end
			end
		else -- if tileProps
			if layerProperties.options.physicsExistent then
				if layerProperties.options.physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
					physics_addBody(tile, layerProperties.physics)
				else
					physics_addBody(tile, unpack(layerProperties.physics))
				end
			end
			
			for k, v in pairs(layerProperties.object) do
				if (self._dotImpliesTable or layerProperties.options.usedot[k]) and not layerProperties.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
			end
		end

		if not layerTiles[x] then layerTiles[x] = {} end
		layerTiles[x][y] = tile
		self:insert(tile)
		tile:toBack()
		
		if tile.isAnimated and self.map._animManager then self.map._animManager:animatedTileCreated(tile) end

		if self._tileDrawListeners[gid] then
			for i = 1, #self._tileDrawListeners[gid] do
				self._tileDrawListeners[gid][i]({
					tile = tile,
					name = "drawn"
				})
			end
		end
		self.map:dispatchEvent({
			name = "tileDrawn",
			map = self.map,
			target = tile,
			layer = self,
			tileX = x,
			tileY = y
		})
	elseif source then
		local tile = layerTiles[x][y]
		if not tile._drawers[source.hash] then
			tile._drawers[source.hash] = true
			tile._drawCount = tile._drawCount + 1
		end
	end
end

-- ************************************************************************** --

tileLayerPrototype._eraseTile = function(self, x, y, source)
	local layerTiles = self.tiles
	local locked = self._locked
	
	if locked[x] and locked[x][y] == "d" then return end

	local shouldErase = false
	local tile
	if layerTiles[x] and layerTiles[x][y] then tile = layerTiles[x][y] end

	if not tile then return end

	if source and tile then
		if tile._drawCount == 1 and tile._drawers[source.hash] then
			shouldErase = true
		elseif tile._drawers[source.hash] then
			tile._drawCount = tile._drawCount - 1
			tile._drawers[source.hash] = nil
		end
	elseif tile and not source then
		shouldErase = true
	end
	
	if shouldErase then
		if tile.isAnimated and self.map._animManager then self.map._animManager:animatedTileRemoved(tile) end
		
		if self._tileEraseListeners[tile.gid] then
			for i = 1, #self._tileEraseListeners[tile.gid] do
				self._tileEraseListeners[tile.gid][i]({
					tile = tile,
					name = "erased"
				})
			end
		end
		self.map:dispatchEvent({
			name = "tileErased",
			map = self.map,
			target = tile,
			layer = self,
			tileX = x,
			tileY = y
		})

		display.remove(tile)
		layerTiles[x][y] = nil

		-- Need this for tile edge modes
		if table_maxn(layerTiles[x]) == 0 then
			layerTiles[x] = nil -- Clear row if no tiles in the row
		end
	end
end

-- ************************************************************************** --

tileLayerPrototype._redrawTile = function(self, x, y)
	self:_eraseTile(x, y)
	self:_drawTile(x, y)
end

-- ************************************************************************** --

tileLayerPrototype.lockTileDrawn = function(self, x, y)
	local locked = self._locked
	if not locked[x] then
		locked[x] = {}
	end
	locked[x][y] = "d"
	self:_drawTile(x, y)
end

tileLayerPrototype.lockTileErased = function(self, x, y)
	local locked = self._locked
	if not locked[x] then
		locked[x] = {}
	end
	locked[x][y] = "e"
	self:_eraseTile(x, y)
end

tileLayerPrototype.unlockTile = function(self, x, y)
	local locked = self._locked
	if locked[x] and locked[x][y] then
		locked[x][y] = nil
		if table_maxn(locked[x]) == 0 then
			locked[x] = nil
		end
	end
end

-- ************************************************************************** --

tileLayerPrototype.addTileListener = function(self, tileID, eventName, callback)
	local gid = self._tileIDs[tileID]
	if not gid then error("No tile with ID '" .. tileID .. "' found.") end
	local listenerTable = (eventName == "drawn" and self._tileDrawListeners) or (eventName == "erased" and self._tileEraseListeners) or error("Invalid tile event '" .. eventName .. "'")

	local l = listenerTable[gid] or {}
	l[#l + 1] = callback
	listenerTable[gid] = l
end

tileLayerPrototype.removeTileListener = function(self, tileID, eventName, callback)
	local gid
	if type(tileID) == "number" then
		gid = tileID
	else
		gid = tileIDs[tileID]
		if not gid then error("No tile with ID '" .. tileID .. "' found.") end
	end

	local listenerTable = (eventName == "drawn" and self._tileDrawListeners) or (eventName == "erased" and self._tileEraseListeners) or error("Invalid tile event '" .. eventName .. "'")
	local l = listenerTable[gid]

	if callback then
		for i = 1, #l do
			if l[i] == callback then
				table.remove(l, i)
				break
			end
		end
	else
		l = nil
	end
	listenerTable[gid] = l
end

-- ************************************************************************** --

tileLayerPrototype._edit = function(self, x1, x2, y1, y2, mode, source)
	local mode = mode or "d"
	local x1 = x1 or 0
	local x2 = x2 or x1
	local y1 = y1 or 0
	local y2 = y2 or y1

	if x1 > x2 then x1, x2 = x2, x1 end; if y1 > y2 then y1, y2 = y2, y1 end

	local layerFunc = "_eraseTile"
	if mode == "d" then layerFunc = "_drawTile" elseif mode == "ld" then layerFunc = "_lockTileDrawn" elseif mode == "le" then layerFunc = "_lockTileErased" elseif mode == "u" then layerFunc = "_unlockTile" end

	for x = x1, x2 do
		for y = y1, y2 do
			self[layerFunc](self, x, y, source)
		end
	end
end

-- ************************************************************************** --

tileLayerPrototype.draw = function(self, x1, x2, y1, y2)
	return self:_edit(x1, x2, y1, y2, "d")
end

tileLayerPrototype.erase = function(self, x1, x2, y1, y2)
	return self:_edit(x1, x2, y1, y2, "e")
end

tileLayerPrototype.lock = function(self, x1, y1, x2, y2, mode)
	if mode == "draw" or mode == "d" then
		return self:_edit(x1, x2, y1, y2, "ld")
	elseif mode == "erase" or mode == "e" then
		return self:_edit(x1, x2, y1, y2, "le")
	elseif mode == "unlock" or mode == "u" then
		return self:_edit(x1, x2, y1, y2, "u")
	end
end

-- ************************************************************************** --

tileLayerPrototype.tilesToPixels = function(self, x, y)
	if x == nil or y == nil then error("Missing argument(s).") end
	x, y = (x - 0.5) * self._mapData.stats.tileWidth, (y - 0.5) * self._mapData.stats.tileHeight
	return x, y
end

tileLayerPrototype.pixelsToTiles = function(self, x, y)
	if x == nil or y == nil then error("Missing argument(s).") end
	return math.ceil(x / self._mapData.stats.tileWidth), math.ceil(y / self._mapData.stats.tileHeight)
end

tileLayerPrototype.tileAtScreenPosition = function(self, x, y)
	local x, y = self:contentToLocal(x, y)
	x, y = self:pixelsToTiles(x, y)
	return self:tile(x, y)
end

-- ************************************************************************** --

tileLayerPrototype._getTilesInRange = function(self, x, y, w, h)
	local t = {}
	local incrX, incrY = 1, 1
	if w < 0 then incrX = -1 end
	if h < 0 then incrY = -1 end
	for xPos = x, x + w - 1, incrX do
		for yPos = y, y + h - 1, incrY do
			local tile = self:tile(xPos, yPos)
			if tile then t[#t + 1] = tile end
		end
	end

	return t
end

tileLayerPrototype.getTilesInBlock = function(self, x1, y1, x2, y2)
	if x1 == nil or y1 == nil or x2 == nil or y2 == nil then error("Missing argument(s).") end
	
	if x1 > x2 then x1, x2 = x2, x1 end
	if y1 > y2 then y1, y2 = y2, y1 end

	local w = x2 - x1
	local h = y2 - y1
	
	if w == 0 then
		w = 1
	end
	if h == 0 then
		h = 1
	end

	local tiles = self:_getTilesInRange(x1, y1, w, h)

	local i = 0
	return function()
		i = i + 1
		if tiles[i] then return tiles[i] else return nil end
	end
end

-- ************************************************************************** --
tileLayerPrototype.destroy = utils.defaultLayerDestroy

return tileLayerPrototype