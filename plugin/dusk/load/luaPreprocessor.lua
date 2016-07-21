-- ************************************************************************** --
--[[
Dusk Engine Component: Lua Preprocessor

Processes a Lua map to conform with Dusk's format.
--]]
-- ************************************************************************** --

local dusk_luaPreprocessor = {}

-- ************************************************************************** --

local tostring = tostring

-- ************************************************************************** --

function dusk_luaPreprocessor.process(data)
	for i = 1, #data.tilesets do
		local t = data.tilesets[i]
		t.tileproperties = {}
		
		--t.columns = math.ceil((t.imagewidth - t.margin * 2) / (t.tilewidth + t.spacing) - t.spacing)

		for n = 1, #t.tiles do
			local p = t.tiles[n]
			t.tileproperties[tostring(p.id)] = p.properties
		end
	end
end

return dusk_luaPreprocessor