--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Animation

Adds the ability for tiles to be animated in a map.
--]]
--------------------------------------------------------------------------------

local lib_anim = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
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
	
	------------------------------------------------------------------------------
	-- Tile Created Callback
	------------------------------------------------------------------------------
	function anim.animatedTileCreated(tile)
		local animData = tile._animData
		animData.options.time = animData.options.time or display.fps * animData.options.count
		
		if not animData.hash then
			animData.hash = tostring(animData)
			table.insert(animDataIndex, animData.hash)
		end
		
		local hash = animData.hash
		
		if animDatas[hash] then
			local pending = animDatas[hash].pending
			table_insert(pending, tile)
			tile._animPendingIndex = #pending
		else
			animDatas[hash] = {
				zero = time,
				pending = {tile},
				frameTime = animData.options.time / animData.options.count,
				nextFrameTime = 0,
				numFramesElapsed = 2,
				options = animData.options,
			}
			animDatas[hash].nextFrameTime = time + animDatas[hash].frameTime
		end
	end
	
	function anim.animatedTileRemoved(tile)
		if tile._animPendingIndex then
			local d = animDatas[tile._animData.hash]
			table_remove(d.pending, tile._animPendingIndex)
			for i = tile._animPendingIndex, #d.pending do
				d.pending[i]._animPendingIndex = d.pending[i]._animPendingIndex - 1
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
			if time > d.nextFrameTime then
				d.nextFrameTime = d.zero + d.frameTime * d.numFramesElapsed
				d.numFramesElapsed = d.numFramesElapsed + 1
				for p = 1, #d.pending do
					d.pending[p]._animPendingIndex = nil
					d.pending[p]:setFrame(((d.numFramesElapsed - 1) % d.options.count) + 1)
					d.pending[p]:play()
				end
				d.pending = {} -- Clear out all the pending tiles
			end
		end
	end
	
	return anim
end

return lib_anim