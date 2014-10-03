--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Edit Queue

A small (and probably temporary) structure to queue edits for a later time, thereby allowing erase edits to go last.
--]]
--------------------------------------------------------------------------------

local lib_editQueue = {}

--------------------------------------------------------------------------------
-- New Edit Queue
--------------------------------------------------------------------------------
function lib_editQueue.new()
	local editQueue = {}
	local target
	local draw = {}
	local erase = {}
	local di = 0
	local ei = 0

	------------------------------------------------------------------------------
	-- Add an Edit to the Queue
	------------------------------------------------------------------------------
	function editQueue.add(x1, x2, y1, y2, mode)
		if mode == "e" then
			ei = ei + 1
			if not erase[ei] then erase[ei] = {} end
			erase[ei][1] = x1
			erase[ei][2] = x2
			erase[ei][3] = y1
			erase[ei][4] = y2
		elseif mode == "d" then
			di = di + 1
			if not draw[di] then draw[di] = {} end
			draw[di][1] = x1
			draw[di][2] = x2
			draw[di][3] = y1
			draw[di][4] = y2
		end
	end

	------------------------------------------------------------------------------
	-- Execute Edits
	------------------------------------------------------------------------------
	function editQueue.execute()
		for i = 1, di do target._edit(draw[i][1], draw[i][2], draw[i][3], draw[i][4], "d") end
		for i = 1, ei do target._edit(erase[i][1], erase[i][2], erase[i][3], erase[i][4], "e") end

		di, ei = 0, 0
	end

	------------------------------------------------------------------------------
	-- Set Queue Target
	------------------------------------------------------------------------------
	function editQueue.setTarget(t) target = t end

	return editQueue
end

return lib_editQueue