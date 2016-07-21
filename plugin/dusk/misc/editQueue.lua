-- ************************************************************************** --
--[[
Dusk Engine Component: Edit Queue

A small structure to queue edits for a later time, thereby allowing erase edits to go last.
--]]
-- ************************************************************************** --

local lib_editQueue = {}

-- ************************************************************************** --

function lib_editQueue.new()
	local editQueue = {}
	local target, source
	local draw = {}
	local erase = {}
	local di = 0
	local ei = 0

	-- ***** --
	
	function editQueue.add(x1, x2, y1, y2, mode, dir)
		if mode == "e" then
			ei = ei + 1
			if not erase[ei] then erase[ei] = {} end
			erase[ei][1] = x1
			erase[ei][2] = x2
			erase[ei][3] = y1
			erase[ei][4] = y2
			erase[ei][5] = dir
		elseif mode == "d" then
			di = di + 1
			if not draw[di] then draw[di] = {} end
			draw[di][1] = x1
			draw[di][2] = x2
			draw[di][3] = y1
			draw[di][4] = y2
			draw[di][5] = dir
		end
	end

	-- ***** --
	
	function editQueue.execute()
		if di == 0 and ei == 0 then return end
		if target._layerType == "tile" then
			if source.mode == "cull" then
				for i = 1, di do target:_edit(draw[i][1], draw[i][2], draw[i][3], draw[i][4], "d", source) end
				for i = 1, ei do target:_edit(erase[i][1], erase[i][2], erase[i][3], erase[i][4], "e", source) end
			elseif source.mode == "callback" then
				for i = 1, di do
					for tile in target:tilesInBlock(draw[i][1], draw[i][3], draw[i][2], draw[i][4]) do
						tile._editQueueCallback = tile._editQueueCallback or {}
						if tile._editQueueCallback[source.hash] then
							tile._editQueueCallback[source.hash] = tile._editQueueCallback[source.hash] + 1
						else
							tile._editQueueCallback[source.hash] = 1
						end
						
						if tile._editQueueCallback[source.hash] == 1 then
							source.onTileEnter(tile)
						end
					end
				end
				for i = 1, ei do
					for tile in target:tilesInBlock(erase[i][1], erase[i][3], erase[i][2], erase[i][4]) do
						tile._editQueueCallback = tile._editQueueCallback or {}
						if tile._editQueueCallback[source.hash] then
							if tile._editQueueCallback[source.hash] == 1 then
								source:onTileExit(tile)
							end
							tile._editQueueCallback[source.hash] = tile._editQueueCallback[source.hash] - 1
						end
					end
				end
			end
		elseif target._layerType == "object" then
			for i = 1, di do target:draw(draw[i][1], draw[i][2], draw[i][3], draw[i][4], source) end
			for i = 1, ei do target:erase(erase[i][1], erase[i][2], erase[i][3], erase[i][4], erase[i][5], source) end
		end

		di, ei = 0, 0
	end

	-- ***** --
	
	function editQueue.setTarget(t) target = t end
	function editQueue.setSource(s) source = s end

	return editQueue
end

return lib_editQueue