-- ************************************************************************** --
--[[
Dusk Engine Component: Animation

Adds the ability for tiles to be animated in a map.

Currently a little unstable.
--]]
-- ************************************************************************** --

local lib_anim = {}

-- ************************************************************************** --

local utils = require("plugin.dusk.misc.utils")

local animSystemPrototype = require("plugin.dusk.prototypes.animSystem")

-- ************************************************************************** --

function lib_anim.new(map)
	local anim = {}
	
	anim.time = system.getTimer()
		
	local animDatas = {}
	local animDataIndex = {}
	
	map._animManager = anim
	
	anim.animDatas = animDatas
	anim.animDataIndex = animDataIndex
	anim.animStartTime = system.getTimer()
	anim.time = anim.animStartTime
	
	for k, v in pairs(animSystemPrototype) do
		anim[k] = v
	end
	
	return anim
end

return lib_anim