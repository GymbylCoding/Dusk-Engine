-- ************************************************************************** --
--[[
Dusk Engine Component: Tilesets

Loads tilesets from data.
--]]
-- ************************************************************************** --

local dusk_tilesets = {}

-- ************************************************************************** --

local dusk_settings = require("plugin.dusk.misc.settings")
local utils = require("plugin.dusk.misc.utils")

local graphics_newImageSheet = graphics.newImageSheet
local math_floor = math.floor
local math_ceil = math.ceil
local table_insert = table.insert
local table_concat = table.concat
local tostring = tostring
local string_len = string.len
local getProperties = utils.getProperties
local getDirectory = utils.getDirectory

-- ************************************************************************** --

function dusk_tilesets.get(data, dirTree)
	local data = data
	local dirTree = dirTree or {}

	local tilesetOptions = {}
	local imageSheets = {}					-- The tileset image sheets themselves
	local imageSheetConfig = {}			-- The image sheet configurations
	local tileProperties = {}				-- Tile properties for each tileset
	local tileIndex = {}						-- Tile GID table - each number in the data corresponds to a tile
	local c = 0											-- Total number of tiles from all tilesets
	local tileIDs = {}              -- Tile ID list

	-- ***** --
	
	for i = 1, #data.tilesets do
		local gid = 0									-- The GID for this tileset
		local tilesetProperties = {}	-- Element to add to the tileProperties table for this tileset
		local options									-- Data table for this tileset
		
		-- Make sure the tileset has properties (if it has no properties, Tiled saves it without even a blank table as the properties table)
		data.tilesets[i].tileproperties = data.tilesets[i].tileproperties or {}
		data.tilesets[i].tiles = data.tilesets[i].tiles or {}
		
		local directoryPath, filename = getDirectory(dirTree, data.tilesets[i].image)

		options = {
			config = {
				frames = {},
				sheetContentWidth = data.tilesets[i].imagewidth,
				sheetContentHeight = data.tilesets[i].imageheight,
				width = data.tilesets[i].tilewidth,
				height = data.tilesets[i].tileheight,
				start = 1,
				count = 0
			},

			image = directoryPath .. "/" .. filename,
			margin = data.tilesets[i].margin,
			spacing = data.tilesets[i].spacing,
			tilewidth = data.tilesets[i].tilewidth,
			tileheight = data.tilesets[i].tileheight,
			tilesetWidth = 0,
			tilesetHeight = 0
		}

		-- Remove opening slash, if existent
		if options.image:sub(1,1) == "/" or options.image:sub(1,1) == "\\" then options.image = options.image:sub(2) end
		
		data.tilesets[i].columns = data.tilesets[i].columns or math.floor((data.tilesets[i].imagewidth - data.tilesets[i].margin * 2 + data.tilesets[i].spacing) / (data.tilesets[i].tilewidth + data.tilesets[i].spacing))
		
		-- Tileset width/height in tiles
		options.tilesetWidth  = data.tilesets[i].columns
		options.tilesetHeight = data.tilesets[i].tilecount / data.tilesets[i].columns
				
		-- Iterate throught the tileset
		for y = 1, options.tilesetHeight do
			for x = 1, options.tilesetWidth do
				local element = {
					-- X and Y of the tile on the sheet
					x = (x - 1) * (options.tilewidth + options.spacing) + options.margin,
					y = (y - 1) * (options.tileheight + options.spacing) + options.margin,
					-- Width of tile
					width = options.tilewidth,
					height = options.tileheight
				}

				gid = gid + 1
				c = c + 1
				table_insert(options.config.frames, gid, element) -- Add to the frames of the sheet
				tileIndex[c] = {tilesetIndex = i, gid = gid}

				local strGID = tostring(gid - 1) -- Tile properties start at 0, so we must subtract 1. Because of the sparse table that tileset properties usually are, they're encoded into JSON with string keys, thus we must tostring() the GID first
			
				if data.tilesets[i].tileproperties[strGID] then
					tilesetProperties[gid] = getProperties(data.tilesets[i].tileproperties[strGID], data.tilesets[i].tilepropertytypes[strGID], "tile", false)
					if tilesetProperties[gid].object["!tileID!"] then
						tileIDs[tilesetProperties[gid].object["!tileID!"] ] = gid
					end
				end
			
				if data.tilesets[i].tiles[strGID] and data.tilesets[i].tiles[strGID].objectgroup then
					tilesetProperties[gid] = tilesetProperties[gid] or getProperties({}, {}, "tile", false)
					tilesetProperties[gid].physics = data.tilesets[i].tiles[strGID]
				end
			end
		end

		-- ***** --
		
		imageSheets[i] = graphics_newImageSheet(options.image, options.config)

		options.config.count = gid

		if not imageSheets[i] then error("Tileset image (\"" .. options.image .. "\") not found.") end

		imageSheetConfig[i] = options.config
		tileProperties[i] = tilesetProperties
		
		tilesetOptions[#tilesetOptions + 1] = options
	end

	data.highestGID = c

	return tilesetOptions, imageSheets, imageSheetConfig, tileProperties, tileIndex, tileIDs
end

return dusk_tilesets