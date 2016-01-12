--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Tile Layer

Builds a tile layer from data.
--]]
--------------------------------------------------------------------------------

local lib_tilelayer = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_functions = require("Dusk.dusk_core.misc.functions")

local display_remove = display.remove
local display_newGroup = display.newGroup
local display_newImageRect = display.newImageRect
local display_newSprite = display.newSprite
local math_abs = math.abs
local math_max = math.max
local math_ceil = math.ceil
local table_maxn = table.maxn
local table_insert = table.insert
local string_len = string.len
local tonumber = tonumber
local tostring = tostring
local pairs = pairs
local unpack = unpack
local type = type
local getSetting = lib_settings.get
local setVariable = lib_settings.setEvalVariable
local removeVariable = lib_settings.removeEvalVariable
local getProperties = lib_functions.getProperties
local addProperties = lib_functions.addProperties
local setProperty = lib_functions.setProperty
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

local flipX = tonumber("80000000", 16)
local flipY = tonumber("40000000", 16)
local flipD = tonumber("20000000", 16)

--------------------------------------------------------------------------------
-- Create Layer
--------------------------------------------------------------------------------
function lib_tilelayer.createLayer(map, mapData, data, dataIndex, tileIndex, imageSheets, imageSheetConfig, tileProperties, tileIDs)
	local layerProps = getProperties(data.properties or {}, "tiles", true)
	local dotImpliesTable = getSetting("dotImpliesTable")
	local useTileImageSheetFill = getSetting("useTileImageSheetFill")

	local layer = display_newGroup()
	
	layer._leftmostTile = mapData._dusk.layers[dataIndex].leftTile - 1
	layer._rightmostTile = mapData._dusk.layers[dataIndex].rightTile + 1
	layer._highestTile = mapData._dusk.layers[dataIndex].topTile - 1
	layer._lowestTile = mapData._dusk.layers[dataIndex].bottomTile + 1

	layer.props = {}
	layer._layerType = "tile"

	local mapWidth, mapHeight = mapData.width, mapData.height
	
	layer.edgeModeLeft, layer.edgeModeRight = "stop", "stop"
	layer.edgeModeTop, layer.edgeModeBottom = "stop", "stop"

	if layer._leftmostTile == math.huge then
		layer._isBlank = true
		-- If we want, we can overwrite the normal functions with blank ones; this
		-- layer is completely empty so no reason to have useless functions that
		-- take time. However, in the engine, we can just check for layer._isBlank
		-- and it'll be even faster than a useless function call.
		--[[
		function layer.tile() return nil end
		function layer._drawTile() end
		function layer._eraseTile() end
		function layer._redrawTile() end
		function layer._lockTileDrawn() end
		function layer._lockTileErased() end
		function layer._unlockTile() end
		function layer._edit() end
		function layer.draw() end
		function layer.erase() end
		function layer.lock() end
		--]]
	end

	local layerTiles = {}
	local locked = {}

	local tileDrawListeners = {}
	local tileEraseListeners = {}

	function layer.tile(x, y) if layerTiles[x] ~= nil and layerTiles[x][y] ~= nil then return layerTiles[x][y] else return nil end end
	function layer.isTileWithinCullingRange(x, y) return x >= layer._drawnLeft and x <= layer._drawnRight and y >= layer._drawnTop and y <= layer._drawnBottom end

	layer.tiles = layerTiles

	------------------------------------------------------------------------------
	-- Get Tile GID
	------------------------------------------------------------------------------
	function layer._getTileGID(x, y)
		local idX, idY = x, y

		if x < 1 or x > mapWidth then
			local edgeModeLeft, edgeModeRight = layer.edgeModeLeft, layer.edgeModeRight
			local underX, overX = x < 1, x > mapWidth

			if (underX and edgeModeLeft == "stop") or (overX and edgeModeRight == "stop") then
				return false
			elseif (underX and edgeModeLeft == "wrap") or (overX and edgeModeRight == "wrap") then
				idX = (idX - 1) % mapWidth + 1
			elseif (underX and edgeModeLeft == "clamp") or (overX and edgeModeRight == "clamp") then
				idX = (underX and 1) or (overX and mapWidth)
			end
		end

		if y < 1 or y > mapHeight then
			local edgeModeTop, edgeModeBottom = layer.edgeModeTop, layer.edgeModeBottom
			local underY, overY = y < 1, y > mapHeight

			if (underY and edgeModeTop == "stop") or (overY and edgeModeBottom == "stop") then
				return false
			elseif (underY and edgeModeTop == "wrap") or (overY and edgeModeBottom == "wrap") then
				idY = (idY - 1) % mapHeight + 1
			elseif (underY and edgeModeTop == "clamp") or (overY and edgeModeBottom == "clamp") then
				idY = (underY and 1) or (overY and mapHeight)
			end
		end

		local id = ((idY - 1) * mapData.width) + idX
		gid = data.data[id]

		if gid == 0 then return false end
		
		if gid % (gid + flipX) >= flipX then gid = gid - flipX end
		if gid % (gid + flipY) >= flipY then gid = gid - flipY end
		if gid % (gid + flipD) >= flipD then gid = gid - flipD end
	end

	------------------------------------------------------------------------------
	-- Construct Tile Data
	------------------------------------------------------------------------------
	function layer._constructTileData(x, y)
		local gid, tilesetGID, tileProps, isSprite, isAnimated, flippedX, flippedY, rotated, pixelX, pixelY
		
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
			local idX, idY = x, y

			if x < 1 or x > mapWidth then
				local edgeModeLeft, edgeModeRight = layer.edgeModeLeft, layer.edgeModeRight
				local underX, overX = x < 1, x > mapWidth

				if (underX and edgeModeLeft == "stop") or (overX and edgeModeRight == "stop") then
					return false
				elseif (underX and edgeModeLeft == "wrap") or (overX and edgeModeRight == "wrap") then
					idX = (idX - 1) % mapWidth + 1
				elseif (underX and edgeModeLeft == "clamp") or (overX and edgeModeRight == "clamp") then
					idX = (underX and 1) or (overX and mapWidth)
				end
			end

			if y < 1 or y > mapHeight then
				local edgeModeTop, edgeModeBottom = layer.edgeModeTop, layer.edgeModeBottom
				local underY, overY = y < 1, y > mapHeight

				if (underY and edgeModeTop == "stop") or (overY and edgeModeBottom == "stop") then
					return false
				elseif (underY and edgeModeTop == "wrap") or (overY and edgeModeBottom == "wrap") then
					idY = (idY - 1) % mapHeight + 1
				elseif (underY and edgeModeTop == "clamp") or (overY and edgeModeBottom == "clamp") then
					idY = (underY and 1) or (overY and mapHeight)
				end
			end

			local id = ((idY - 1) * mapData.width) + idX
			gid = data.data[id]

			if gid == 0 then return false end
			
			if gid % (gid + flipX) >= flipX then flippedX = true gid = gid - flipX end
			if gid % (gid + flipY) >= flipY then flippedY = true gid = gid - flipY end
			if gid % (gid + flipD) >= flipD then rotated = true gid = gid - flipD end

			local tilesheetData = tileIndex[gid]
			local sheetIndex = tilesheetData.tilesetIndex
			local tileGID = tilesheetData.gid

			if tileProperties[sheetIndex][tileGID] then
				tileProps = tileProperties[sheetIndex][tileGID]
			end

			isSprite = tileProps and tileProps.object["!isSprite!"]
			gid = gid
			tilesetGID = tileGID
			pixelX, pixelY = mapData.stats.tileWidth * (x - 0.5), mapData.stats.tileHeight * (y - 0.5)
		end

		local tileData = {
			gid = gid,
			tilesetGID = tilesetGID,
			isSprite = isSprite,
			isAnimated = isAnimated,
			flippedX = flippedX,
			flippedY = flippedY,
			width = mapData.stats.tileWidth,
			height = mapData.stats.tileHeight,
			xScale = flippedX and -1 or 1,
			yScale = flippedY and -1 or 1,
			tileX = x,
			tileY = y,
			x = pixelX,
			y = pixelY,
			props = {}
		}

		for k, v in pairs(layerProps.object) do
			if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tileData, k, v) else tileData[k] = v end
		end

		if tileProps then
			for k, v in pairs(tileProps.object) do
				if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tileData, k, v) else tileData[k] = v end
			end

			for k, v in pairs(tileProps.props) do
				if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tileData.props, k, v) else tileData.props[k] = v end
			end
		end

		return tileData
	end

	------------------------------------------------------------------------------
	-- Draw a Single Tile to the Screen
	------------------------------------------------------------------------------
	function layer._drawTile(x, y, source)
		if locked[x] and locked[x][y] == "e" then return false end
		
		if not (layerTiles[x] and layerTiles[x][y]) then
			local idX, idY = x, y

			if x < 1 or x > mapWidth then
				local edgeModeLeft, edgeModeRight = layer.edgeModeLeft, layer.edgeModeRight
				local underX, overX = x < 1, x > mapWidth

				if (underX and edgeModeLeft == "stop") or (overX and edgeModeRight == "stop") then
					return false
				elseif (underX and edgeModeLeft == "wrap") or (overX and edgeModeRight == "wrap") then
					idX = (idX - 1) % mapWidth + 1
				elseif (underX and edgeModeLeft == "clamp") or (overX and edgeModeRight == "clamp") then
					idX = (underX and 1) or (overX and mapWidth)
				end
			end

			if y < 1 or y > mapHeight then
				local edgeModeTop, edgeModeBottom = layer.edgeModeTop, layer.edgeModeBottom
				local underY, overY = y < 1, y > mapHeight

				if (underY and edgeModeTop == "stop") or (overY and edgeModeBottom == "stop") then
					return false
				elseif (underY and edgeModeTop == "wrap") or (overY and edgeModeBottom == "wrap") then
					idY = (idY - 1) % mapHeight + 1
				elseif (underY and edgeModeTop == "clamp") or (overY and edgeModeBottom == "clamp") then
					idY = (underY and 1) or (overY and mapHeight)
				end
			end

			local id = ((idY - 1) * mapData.width) + idX
			local gid = data.data[id]

			-- Skip blank tiles
			if gid == 0 then return false end

			--------------------------------------------------------------------------
			-- Tile Data/Preparation
			--------------------------------------------------------------------------
			local flippedX = false
			local flippedY = false
			local rotated = false
			if gid % (gid + flipX) >= flipX then flippedX = true gid = gid - flipX end
			if gid % (gid + flipY) >= flipY then flippedY = true gid = gid - flipY end
			if gid % (gid + flipD) >= flipD then rotated = true gid = gid - flipD end

			if gid > mapData.highestGID or gid < 0 then error("Invalid GID at position [" .. x .. "," .. y .."] (index #" .. id ..") - expected [0 <= GID <= " .. mapData.highestGID .. "] but got " .. gid .. " instead.") end

			local tileData = tileIndex[gid]
			local sheetIndex = tileData.tilesetIndex
			local tileGID = tileData.gid

			local tile
			local tileProps

			if tileProperties[sheetIndex][tileGID] then
				tileProps = tileProperties[sheetIndex][tileGID]
			end

			------------------------------------------------------------------------
			-- Create Tile
			------------------------------------------------------------------------
			if tileProps and tileProps.object["!isSprite!"] then
				tile = display_newSprite(imageSheets[sheetIndex], imageSheetConfig[sheetIndex])
				tile:setFrame(tileGID)
				tile.isSprite = true
			elseif tileProps and tileProps.anim.enabled then
				tile = display_newSprite(imageSheets[sheetIndex], tileProps.anim.options)
				tile._animData = tileProps.anim
				tile.isAnimated = true
			else
				if useTileImageSheetFill then
					tile = display.newRect(0, 0, mapData.stats.tileWidth, mapData.stats.tileHeight)
					tile.imageSheetFill = {
						type = "image",
						sheet = imageSheets[sheetIndex],
						frame = tileGID
					}
					tile.fill = tile.imageSheetFill
				else
					tile = display_newImageRect(imageSheets[sheetIndex], tileGID, mapData.stats.tileWidth, mapData.stats.tileHeight)
				end
			end
			
			tile.props = {}
			
			tile.x, tile.y = mapData.stats.tileWidth * (x - 0.5), mapData.stats.tileHeight * (y - 0.5)
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

			--------------------------------------------------------------------------
			-- Tile Properties
			--------------------------------------------------------------------------
			if tileProps then
				------------------------------------------------------------------------
				-- Add Physics to Tile
				------------------------------------------------------------------------
				local shouldAddPhysics = tileProps.options.physicsExistent
				if shouldAddPhysics == nil then shouldAddPhysics = layerProps.options.physicsExistent end
				if shouldAddPhysics then
					local physicsParameters = {}
					local physicsBodyCount = layerProps.options.physicsBodyCount
					local tpPhysicsBodyCount = tileProps.options.physicsBodyCount; if tpPhysicsBodyCount == nil then tpPhysicsBodyCount = physicsBodyCount end

					physicsBodyCount = math_max(physicsBodyCount, tpPhysicsBodyCount)

					for i = 1, physicsBodyCount do
						physicsParameters[i] = {}
						local tilePhysics = tileProps.physics[i]
						local layerPhysics = layerProps.physics[i]

						if tilePhysics and layerPhysics then
							for k, v in pairs(physicsKeys) do
								physicsParameters[i][k] = tilePhysics[k]
								if physicsParameters[i][k] == nil then physicsParameters[i][k] = layerPhysics[k] end
							end
						elseif tilePhysics then
							physicsParameters[i] = tilePhysics
						elseif layerPhysics then
							physicsParameters[i] = layerPhysics
						end
					end

					if physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
						physics_addBody(tile, physicsParameters[1])
					else
						physics_addBody(tile, unpack(physicsParameters))
					end
				end
				
				for k, v in pairs(layerProps.object) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
				end

				for k, v in pairs(tileProps.object) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
				end

				for k, v in pairs(tileProps.props) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile.props, k, v) else tile.props[k] = v end
				end
			else -- if tileProps
				------------------------------------------------------------------------
				-- Add Physics to Tile
				------------------------------------------------------------------------
				if layerProps.options.physicsExistent then
					if layerProps.options.physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
						physics_addBody(tile, layerProps.physics)
					else
						physics_addBody(tile, unpack(layerProps.physics))
					end
				end
				
				for k, v in pairs(layerProps.object) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
				end
			end

			if not layerTiles[x] then layerTiles[x] = {} end
			layerTiles[x][y] = tile
			layer:insert(tile)
			tile:toBack()
			
			if tile.isAnimated and map._animManager then map._animManager.animatedTileCreated(tile) end

			if tileDrawListeners[gid] then
				for i = 1, #tileDrawListeners[gid] do
					tileDrawListeners[gid][i]({
						tile = tile,
						name = "drawn"
					})
				end
			end
		elseif source then
			local tile = layerTiles[x][y]
			if not tile._drawers[source.hash] then
				tile._drawers[source.hash] = true
				tile._drawCount = tile._drawCount + 1
			end
		end
	end

	------------------------------------------------------------------------------
	-- Erase a Single Tile from the Screen
	------------------------------------------------------------------------------
	function layer._eraseTile(x, y, source)
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
			if tile.isAnimated and map._animManager then map._animManager.animatedTileRemoved(tile) end
			
			if tileEraseListeners[tile.gid] then
				for i = 1, #tileEraseListeners[tile.gid] do
					tileEraseListeners[tile.gid][i]({
						tile = tile,
						name = "erased"
					})
				end
			end


			display_remove(tile)
			layerTiles[x][y] = nil

			-- Need this for tile edge modes
			if table_maxn(layerTiles[x]) == 0 then
				layerTiles[x] = nil -- Clear row if no tiles in the row
			end
		end
	end

	------------------------------------------------------------------------------
	-- Redraw a Tile
	------------------------------------------------------------------------------
	function layer._redrawTile(x, y)
		layer._eraseTile(x, y)
		layer._drawTile(x, y)
	end

	------------------------------------------------------------------------------
	-- Lock/Unlock a Tile
	------------------------------------------------------------------------------
	function layer.lockTileDrawn(x, y) if not locked[x] then locked[x] = {} end locked[x][y] = "d" layer._drawTile(x, y) end
	function layer.lockTileErased(x, y) if not locked[x] then locked[x] = {} end locked[x][y] = "e" layer._eraseTile(x, y) end
	function layer.unlockTile(x, y) if locked[x] and locked[x][y] then locked[x][y] = nil if table_maxn(locked[x]) == 0 then locked[x] = nil end end end

	------------------------------------------------------------------------------
	-- Add Tile Listener
	------------------------------------------------------------------------------
	function layer.addTileListener(tileID, eventName, callback)
		local gid = tileIDs[tileID]
		if not gid then error("No tile with ID '" .. tileID .. "' found.") end
		local listenerTable = (eventName == "drawn" and tileDrawListeners) or (eventName == "erased" and tileEraseListeners) or error("Invalid tile event '" .. eventName .. "'")

		local l = listenerTable[gid] or {}
		l[#l + 1] = callback
		listenerTable[gid] = l
	end

	function layer.removeTileListener(tileID, eventName, callback)
		local gid
		if type(tileID) == "number" then
			gid = tileID
		else
			gid = tileIDs[tileID]
			if not gid then error("No tile with ID '" .. tileID .. "' found.") end
		end

		local listenerTable = (eventName == "drawn" and tileDrawListeners) or (eventName == "erased" and tileEraseListeners) or error("Invalid tile event '" .. eventName .. "'")
		local l = listenerTable[gid]

		if callback then
			for i = 1, #l do
				if l[i] == callback then
					table_remove(l, i)
					break
				end
			end
		else
			l = nil
		end
		listenerTable[gid] = l
	end

	------------------------------------------------------------------------------
	-- Edit Section
	------------------------------------------------------------------------------
	function layer._edit(x1, x2, y1, y2, mode, source)
		local mode = mode or "d"
		local x1 = x1 or 0
		local x2 = x2 or x1
		local y1 = y1 or 0
		local y2 = y2 or y1

		-- "Shortcuts" for cutting down time
		if x1 > x2 then x1, x2 = x2, x1 end; if y1 > y2 then y1, y2 = y2, y1 end
		-- if x2 < 1 or x1 > mapData.stats.mapWidth then return true end; if y2 < 1 or y1 > mapData.stats.mapHeight then return true end
		-- if x1 < 1 then x1 = 1 end; if y1 < 1 then y1 = 1 end
		-- if x2 > mapData.stats.mapWidth then x2 = mapData.stats.mapWidth end; if y2 > mapData.stats.mapHeight then y2 = mapData.stats.mapHeight end

		-- Function associated with edit mode
		local layerFunc = "_eraseTile"
		if mode == "d" then layerFunc = "_drawTile" elseif mode == "ld" then layerFunc = "_lockTileDrawn" elseif mode == "le" then layerFunc = "_lockTileErased" elseif mode == "u" then layerFunc = "_unlockTile" end

		for x = x1, x2 do
			for y = y1, y2 do
				layer[layerFunc](x, y, source)
			end
		end
	end

	------------------------------------------------------------------------------
	-- Draw Section (shortcut, shouldn't be used in speed-intensive places because it's just a tail call)
	------------------------------------------------------------------------------
	function layer.draw(x1, x2, y1, y2)
		return layer._edit(x1, x2, y1, y2, "d")
	end

	------------------------------------------------------------------------------
	-- Erase Section (shortcut, shouldn't be used in speed-intensive places because it's just a tail call)
	------------------------------------------------------------------------------
	function layer.erase(x1, x2, y1, y2)
		return layer._edit(x1, x2, y1, y2, "e")
	end

	------------------------------------------------------------------------------
	-- Lock Section (shortcut, shouldn't be used in speed-intensive places because it's just a tail call)
	------------------------------------------------------------------------------
	function layer.lock(x1, y1, x2, y2, mode)
		if mode == "draw" or mode == "d" then
			return layer._edit(x1, x2, y1, y2, "ld")
		elseif mode == "erase" or mode == "e" then
			return layer._edit(x1, x2, y1, y2, "le")
		elseif mode == "unlock" or mode == "u" then
			return layer._edit(x1, x2, y1, y2, "u")
		end
	end

	------------------------------------------------------------------------------
	-- Tiles to Pixels Conversion
	------------------------------------------------------------------------------
	function layer.tilesToPixels(x, y)
		if x == nil or y == nil then error("Missing argument(s).") end
		x, y = (x - 0.5) * mapData.stats.tileWidth, (y - 0.5) * mapData.stats.tileHeight
		return x, y
	end

	------------------------------------------------------------------------------
	-- Pixels to Tiles Conversion
	------------------------------------------------------------------------------
	function layer.pixelsToTiles(x, y)
		if x == nil or y == nil then error("Missing argument(s).") end
		return math_ceil(x / mapData.stats.tileWidth), math_ceil(y / mapData.stats.tileHeight)
	end

	------------------------------------------------------------------------------
	-- Tile by Pixels
	------------------------------------------------------------------------------
	function layer.tileByPixels(x, y)
		local x, y = layer.pixelsToTiles(x, y)
		if layerTiles[x] and layerTiles[x][y] then
			return layerTiles[x][y]
		else
			return nil
		end
	end

	------------------------------------------------------------------------------
	-- Get Tiles in Range
	------------------------------------------------------------------------------
	function layer._getTilesInRange(x, y, w, h)
		local t = {}
		local incrX, incrY = 1, 1
		if w < 0 then incrX = -1 end
		if h < 0 then incrY = -1 end
		for xPos = x, x + w - 1, incrX do
			for yPos = y, y + h - 1, incrY do
				local tile = layer.tile(xPos, yPos)
				if tile then t[#t + 1] = tile end
			end
		end

		return t
	end

	------------------------------------------------------------------------------
	-- Tile Iterators
	------------------------------------------------------------------------------
	function layer.tilesInRange(x, y, w, h)
		if x == nil or y == nil or w == nil or h == nil then error("Missing argument(s).") end

		local tiles = layer._getTilesInRange(x, y, w, h)

		local i = 0
		return function()
			i = i + 1
			if tiles[i] then return tiles[i] else return nil end
		end
	end

	function layer.tilesInRect(x, y, w, h)
		if x == nil or y == nil or w == nil or h == nil then error("Missing argument(s).") end

		local tiles = layer._getTilesInRange(x - w, y - h, w * 2, h * 2)

		local i = 0
		return function()
			i = i + 1
			if tiles[i] then return tiles[i] else return nil end
		end
	end

	function layer.tilesInBlock(x1, y1, x2, y2)
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
	
		local tiles = layer._getTilesInRange(x1, y1, w, h)

		local i = 0
		return function()
			i = i + 1
			if tiles[i] then return tiles[i] else return nil end
		end
	end

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
	for k, v in pairs(layerProps.props) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer.props, k, v) else layer.props[k] = v end
	end

	for k, v in pairs(layerProps.layer) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer, k, v) else layer[k] = v end
	end

	return layer
end

return lib_tilelayer