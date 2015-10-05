--------------------------------------------------------------------------------
--[[
Dusk Engine Component:   

Loads map data from a filename.
--]]
--------------------------------------------------------------------------------

local lib_data = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local json = require("json")
local preprocessor_lua = require("Dusk.dusk_core.load.preprocessor_lua")

local system_pathForFile = system.pathForFile
local json_decode = json.decode
local pcall = pcall

local function getFileContents(filename, base) local base = base or system.ResourceDirectory local path = system.pathForFile(filename, base) local contents local file = io.open(path, "r") if file then contents = file:read("*a") io.close(file) file = nil end return contents end

--------------------------------------------------------------------------------
-- Get Map Data
--------------------------------------------------------------------------------
function lib_data.get(filename, base)
	local extension = filename:match("%.[^%.]-$") or "[no extension]"
	if extension ~= ".json" and extension ~= ".lua" then error("Unsupported file extension " .. extension .. ".") end

	local path = system_pathForFile(filename, base)

	-- Check for nonexistent files
	if extension ~= ".lua" and path == nil then error("No file found at path '" .. filename .. "'") end

	------------------------------------------------------------------------------
	-- Load JSON
	------------------------------------------------------------------------------
	if extension == ".json" then
		local contents = getFileContents(filename, base)
		local data, _, msg = json_decode(contents) -- Ignore the second value - it's the character the issue was found on

		if not data then error("Failed to parse JSON data of map '" .. filename .. "'") end

		return data

	------------------------------------------------------------------------------
	-- Load Lua
	------------------------------------------------------------------------------
	elseif extension == ".lua" then
		local luaName = filename:gsub("%.[^%.]-$", "")
		luaName = luaName:gsub("/", ".")
		local success, result = pcall(require, luaName)

		if not success then error("Failed to load Lua data from map '" .. filename .. "'") end

		preprocessor_lua.process(result) -- We need to preprocess Lua files because of the difference in formats
		return result
	end -- No need to check for other extensions because we already safeguarded with a check earlier

	return data
end

return lib_data