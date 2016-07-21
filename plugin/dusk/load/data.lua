-- ************************************************************************** --
--[[
Dusk Engine Component:   

Loads map data from a filename.
--]]
-- ************************************************************************** --

local dusk_data = {}

-- ************************************************************************** --

local json = require("json")

local luaPreprocessor = require("plugin.dusk.load.luaPreprocessor")
local utils = require("plugin.dusk.misc.utils")

-- ************************************************************************** --

function dusk_data.get(filename, base)
	local extension = filename:match("%.[^%.]-$") or "[no extension]"
	if extension ~= ".json" and extension ~= ".lua" then error("Unsupported file extension " .. extension .. ".") end

	local path = system.pathForFile(filename, base)

	-- Check for nonexistent files
	if extension ~= ".lua" and path == nil then error("No file found at path '" .. filename .. "'") end

	-- ***** --
	
	if extension == ".json" then
		local contents = utils.getFileContents(filename, base)
		local data, _, msg = json.decode(contents) -- Ignore the second value - it's the character the issue was found on

		if not data then error("Failed to parse JSON data of map '" .. filename .. "'") end

		return data

	-- ***** --
	
	elseif extension == ".lua" then
		local luaName = filename:gsub("%.[^%.]-$", "")
		luaName = luaName:gsub("/", ".")
		local success, result = pcall(require, luaName)

		if not success then error("Failed to load Lua data from map '" .. filename .. "'") end

		luaPreprocessor.process(result) -- We need to preprocess Lua files because of the difference in formats
		return result
	end -- No need to check for other extensions because we already safeguarded with a check earlier

	return data
end

return dusk_data