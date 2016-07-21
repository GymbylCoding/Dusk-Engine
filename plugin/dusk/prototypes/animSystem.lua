-- ************************************************************************** --
--[[
Dusk Engine Object Prototype: Animation System

Takes care of syncing and displaying tile animations.
--]]
-- ************************************************************************** --

local animSystemPrototype = {}

-- ************************************************************************** --

local system_getTimer = system.getTimer
local tostring = tostring
local table_insert = table.insert
local table_remove = table.remove

local setSyncAnimation = function(tile, s)
	local anim = tile._animSystem
	local animDatas = anim.animDatas
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

-- ************************************************************************** --

animSystemPrototype.watchTileCallback = function(event)
	local anim = event.target._animSystem
	anim.animDatas[event.target._animDataHash].currentFrame = event.target.frame
	anim:sync(anim.animDatas[event.target._animDataHash], event.target.frame)
end

-- ************************************************************************** --

animSystemPrototype.initWatchTile = function(self, d)
	if d.watchTile then d.watchTile:removeEventListener("sprite", self.watchTileCallback) end
	local i = 1
	local wt = d.tiles[i]
	while wt and not wt._syncTileAnimation do
		i = i + 1
		wt = d.tiles[i]
	end
	d.watchTile = wt
	if d.watchTile then
		local timeElapsed = self.time - self.animStartTime
		local framesElapsed = math.floor(timeElapsed / d.frameTime)
		local frame = (framesElapsed - 1) % d.frameCount + 1
		d.watchTile:setFrame(frame)
		d.requiresManualAnimStart = true
		d.currentFrame = d.watchTile.frame
		d.watchTile:addEventListener("sprite", self.watchTileCallback)
	end
end

-- ************************************************************************** --

animSystemPrototype.animatedTileCreated = function(self, tile)
	local animData = tile._animData
	animData.options.time = animData.options.time or display.fps * tile.numFrames
		
	tile._animSystem = self
		
	local tileX, tileY = tile.tileX, tile.tileY

	if not animData.hash then
		animData.hash = tostring(animData)
		self.animDataIndex[#self.animDataIndex + 1] = animData.hash
	end

	local hash = animData.hash
	
	if self.animDatas[hash] then
		self.animDatas[hash].tiles[#self.animDatas[hash].tiles + 1] = tile
		tile._animTilesIndex = #self.animDatas[hash].tiles
	else
		self.animDatas[hash] = {
			zero = self.time,
			tiles = {tile},
			noSyncTileAnimation = {},
			frameTime = animData.options.time / tile.numFrames,
			frameCount = tile.numFrames,
			nextFrameTime = 0,
			numFramesElapsed = 1,
			options = animData.options,
			nextSyncTime = 0,
			currentFrame = 1,
			watchTile = nil,
			requiresManualAnimStart = true
		}
		
		local timeElapsed = self.time - self.animStartTime
		local framesElapsed = math.floor(timeElapsed / self.animDatas[hash].frameTime)
		local frame = (framesElapsed - 1) % self.animDatas[hash].frameCount + 1
		self.animDatas[hash].currentFrame = frame
		
		tile._animTilesIndex = 1
		self.animDatas[hash].nextFrameTime = self.animDatas[hash].zero + self.animDatas[hash].frameTime
	end

	----------------------------------------------------------------------------
	-- Tile Methods
	----------------------------------------------------------------------------
	tile._syncTileAnimation = true
	
	if self.animDatas[hash].noSyncTileAnimation[tileX] and self.animDatas[hash].noSyncTileAnimation[tileX][tileY] then
		tile._syncTileAnimation = false
	end

	tile.setSyncAnimation = setSyncAnimation

	if not self.animDatas[hash].watchTile then
		self:initWatchTile(self.animDatas[hash])
	end
	
	tile._animDataHash = hash
	if tile._syncTileAnimation then
		tile:setFrame(self.animDatas[hash].currentFrame)
	elseif animDatas[hash].noSyncTileAnimation[tileX] and self.animDatas[hash].noSyncTileAnimation[tileX][tileY] then
		tile:setFrame(self.animDatas[hash].noSyncTileAnimation[tileX][tileY])
	end
end

-- ************************************************************************** --

animSystemPrototype.animatedTileRemoved = function(self, tile)
	local d = self.animDatas[tile._animDataHash]
	if not tile._syncTileAnimation and d.noSyncTileAnimation[tile.tileX] and d.noSyncTileAnimation[tile.tileX][tile.tileY] then
		d.noSyncTileAnimation[tile.tileX][tile.tileY] = tile.frame
	end
	table_remove(d.tiles, tile._animTilesIndex)
	for i = tile._animTilesIndex, #d.tiles do
		d.tiles[i]._animTilesIndex = d.tiles[i]._animTilesIndex - 1
	end
	if tile == d.watchTile then
		d.watchTile = nil
		self:initWatchTile(d)
		if not d.watchTile then
			-- No more tiles to watch, we'll have to do it manually
			d.requiresManualAnimStart = true
		end
	end
end

-- ************************************************************************** --

animSystemPrototype.update = function(self)
	self.time = system_getTimer()
	for i = 1, #self.animDataIndex do
		local d = self.animDatas[self.animDataIndex[i] ]
		if d.requiresManualAnimStart and #d.tiles > 0 then
			if self.time >= d.nextFrameTime then
				d.requiresManualAnimStart = false
				
				if d.watchTile then
					d.watchTile:setFrame(((d.currentFrame + 1) % d.frameCount) + 1)
					d.watchTile:play()
					self:sync(d, d.watchTile.frame)
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

-- ************************************************************************** --

animSystemPrototype.sync = function(self, d, frame)
	for i = 1, #d.tiles do
		if d.tiles[i] ~= d.watchTile and d.tiles[i]._syncTileAnimation then
			d.tiles[i]:setFrame(frame)
		end
	end
end

return animSystemPrototype