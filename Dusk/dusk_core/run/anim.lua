--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Animation

Adds the ability for tiles to be animated in a map.

Currently a little unstable.
--]]
--------------------------------------------------------------------------------

local lib_anim = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local lib_functions = require("Dusk.dusk_core.misc.functions")

local system_getTimer = system.getTimer
local tostring = tostring
local table_insert = table.insert
local table_remove = table.remove

--------------------------------------------------------------------------------
-- New Animation Manager
--------------------------------------------------------------------------------
function lib_anim.new(map)
	local anim = {}
	
	local time = system_getTimer()
	
	local animDatas = {}
	local animDataIndex = {}
	
	map._animManager = anim

	local function watchTileCallback(event)
		animDatas[event.target._animDataHash].currentFrame = event.target.frame
		anim.sync(animDatas[event.target._animDataHash], event.target.frame)
	end

	local function initWatchTile(d)
		if d.watchTile then d.watchTile:removeEventListener("sprite", watchTileCallback) end
		local i = 1
		local wt = d.tiles[i]
		while wt and not wt._syncTileAnimation do
			i = i + 1
			wt = d.tiles[i]
		end
		d.watchTile = wt
		if d.watchTile then
			d.requiresManualAnimStart = true
			d.currentFrame = d.watchTile.frame
			d.watchTile:addEventListener("sprite", watchTileCallback)
		end
	end
	
	------------------------------------------------------------------------------
	-- Tile Created Callback
	------------------------------------------------------------------------------
	function anim.animatedTileCreated(tile)
		local animData = tile._animData
		animData.options.time = animData.options.time or display.fps * tile.numFrames
		
		local tileX, tileY = tile.tileX, tile.tileY

		if not animData.hash then
			animData.hash = tostring(animData)
			table_insert(animDataIndex, animData.hash)
		end

		local hash = animData.hash
		
		if animDatas[hash] then
			table_insert(animDatas[hash].tiles, tile)
			tile._animTilesIndex = #animDatas[hash].tiles
		else
			animDatas[hash] = {
				zero = time,
				tiles = {tile},
				noSyncTileAnimation = {},
				frameTime = animData.options.time / tile.numFrames,
				frameCount = tile.numFrames,
				nextFrameTime = 0,
				numFramesElapsed = 2,
				options = animData.options,
				nextSyncTime = 0,
				currentFrame = 1,
				watchTile = nil,
				requiresManualAnimStart = true
			}
			tile._animTilesIndex = 1
			animDatas[hash].nextFrameTime = time + animDatas[hash].frameTime
		end

		----------------------------------------------------------------------------
		-- Tile Methods
		----------------------------------------------------------------------------
		tile._syncTileAnimation = true
		
		if animDatas[hash].noSyncTileAnimation[tileX] and animDatas[hash].noSyncTileAnimation[tileX][tileY] then
			tile._syncTileAnimation = false
		end

		function tile:setSyncAnimation(s)
			if s then
				tile:setFrame(animDatas[hash].currentFrame)
				if animDatas[hash].noSyncTileAnimation[tileX] and animDatas[hash].noSyncTileAnimation[tileX][tileY] then
					animDatas[hash].noSyncTileAnimation[tileX][tileY] = nil
				end
				tile._syncTileAnimation = s
			else
				tile:setFrame(1)
				if not animDatas[hash].noSyncTileAnimation[tileX] then animDatas[hash].noSyncTileAnimation[tileX] = {} end
				animDatas[hash].noSyncTileAnimation[tileX][tileY] = 1
				tile._syncTileAnimation = s
				if tile == animDatas[hash].watchTile then
					tile:pause()
					animDatas[hash].watchTile = nil
					initWatchTile(animDatas[hash])
					if not animDatas[hash].watchTile then
						animDatas[hash].requiresManualAnimStart = true
					end
				end
			end
		end

		if not animDatas[hash].watchTile then
			initWatchTile(animDatas[hash])
		end
		
		tile._animDataHash = hash
		if tile._syncTileAnimation then
			tile:setFrame(animDatas[hash].currentFrame)
		elseif animDatas[hash].noSyncTileAnimation[tileX] and animDatas[hash].noSyncTileAnimation[tileX][tileY] then
			tile:setFrame(animDatas[hash].noSyncTileAnimation[tileX][tileY])
		end
	end
	
	------------------------------------------------------------------------------
	-- Tile Removed Callback
	------------------------------------------------------------------------------
	function anim.animatedTileRemoved(tile)
		local d = animDatas[tile._animDataHash]
		if not tile._syncTileAnimation and d.noSyncTileAnimation[tile.tileX] and d.noSyncTileAnimation[tile.tileX][tile.tileY] then
			d.noSyncTileAnimation[tile.tileX][tile.tileY] = tile.frame
		end
		table_remove(d.tiles, tile._animTilesIndex)
		for i = tile._animTilesIndex, #d.tiles do
			d.tiles[i]._animTilesIndex = d.tiles[i]._animTilesIndex - 1
		end
		if tile == d.watchTile then
			d.watchTile = nil
			initWatchTile(d)
			if not d.watchTile then
				-- No more tiles to watch, we'll have to do it manually
				d.requiresManualAnimStart = true
			end
		end
	end
	
	------------------------------------------------------------------------------
	-- Sync Tiles to a Frame
	------------------------------------------------------------------------------
	function anim.sync(d, frame)
		for i = 1, #d.tiles do
			if d.tiles[i] ~= d.watchTile and d.tiles[i]._syncTileAnimation then
				d.tiles[i]:setFrame(frame)
			end
		end
	end

	------------------------------------------------------------------------------
	-- Update
	------------------------------------------------------------------------------
	function anim.update()
		time = system_getTimer()
		for i = 1, #animDataIndex do
			local d = animDatas[animDataIndex[i] ]
			if d.requiresManualAnimStart and #d.tiles > 0 then
				if time >= d.nextFrameTime then
					d.requiresManualAnimStart = false
					
					if d.watchTile then
						d.watchTile:setFrame(((d.currentFrame + 1) % d.frameCount) + 1)
						d.watchTile:play()
						anim.sync(d, d.watchTile.frame)
					end
					
					d.nextFrameTime = d.zero + d.frameTime * d.numFramesElapsed
					d.numFramesElapsed = d.numFramesElapsed + 1
				end
			end

			if d.watchTile then
				d.currentFrame = d.watchTile.frame
			else
				d.currentFrame = ((d.numFramesElapsed - 1) % d.frameCount) + 1
			end
		end
	end
	
	return anim
end

return lib_anim