--------------------------------------------------------------------------------
--[[
Dusk Plugin: Lettermap

Provides a debug view of any tile layer in a map using simple ASCII art.
--]]
--------------------------------------------------------------------------------

local lettermap = {}

local table_insert = table.insert
local table_concat = table.concat

lettermap.yes = function(tile) return "[#]" end
lettermap.no = function(tile) return " - " end

--------------------------------------------------------------------------------
-- Add Lettermap Plugin
--------------------------------------------------------------------------------
function lettermap.register(map)
	for i = 1, #map.layer do

		if map.layer[i]._type == "tile" then
			map.layer[i].lettermap_filter = function(t) return true end -- A function that returns whether we should give a lettermap entry for it

			map.layer[i].lettermap = function(startX, startY, w, h)
				local startX = startX or 1
				local startY = startY or 1
				local w = w or map.data.mapWidth
				local h = h or map.data.mapHeight
				local lm = {}
				
				for y = startY, startY + h do
					for x = startX, startX + w do
						if map.layer[i].tile(x, y) then
							if map.layer[i].lettermap_filter(map.layer[i].tile(x, y)) then
								table_insert(lm, lettermap.yes(map.layer[i].tile(x, y)))
							else
								table_insert(lm, lettermap.no(map.layer[i].tile(x, y)))
							end
						else
							table_insert(lm, lettermap.no({tileX = x, tileY = y}))
						end
					end
					table_insert(lm, "\n")
				end -- for

				return table_concat(lm)
			end
		end
	end
end

return lettermap