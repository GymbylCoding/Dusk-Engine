--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Settings

Controls and keeps track of user preferences for various engine aspects.
--]]
--------------------------------------------------------------------------------

local settings = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
local screen = require("Dusk.dusk_core.misc.screen")

local type = type
local verby_assert = verby.assert
local verby_error = verby.error

--------------------------------------------------------------------------------
-- Data
--------------------------------------------------------------------------------
local data = {
	dotImpliesTable = true,
	detectMapPath = true,
	
	redrawOnTileExistent = false, -- WARNING: Lowers performance by a large amount!
	enableTwindex = false,
	
	ellipseRadiusMode = "min",
	objTypeRectPointSquare = true,

	spaceAfterEscapedPrefix = false,

	virtualObjectsVisible = true,
	autoGenerateObjectShapes = true,

	enableCamera = true,
	defaultCameraTrackingLevel = 1,
	scaleCameraBoundsToScreen = true,

	enableTileCulling = true,

	-- On object creation
	onPointBased = function(p) p.strokeWidth = 5 p:setStrokeColor(1, 1, 1, 0.5) end,
	onEllipse = function(e) e:setFillColor(0, 0, 0, 0) e.strokeWidth = 5 e:setStrokeColor(1, 1, 1, 0.5) end,
	onImageObj = function(t) end,
	onRect = function(r) r:setFillColor(0, 0, 0, 0) r.strokeWidth = 5 r:setStrokeColor(1, 1, 1, 0.5) end,
	onObj = function(o) end,

	evalVariables = {
		screenWidth = screen.width,
		screenHeight = screen.height
	}
}

local config = {
	dotImpliesTable = "boolean",
	detectMapPath = "boolean",
	redrawOnTileExistent = "boolean",
	enableTwindex = "boolean",
	ellipseRadiusMode = "string",
	objTypeRectPointSquare = "boolean",
	spaceAfterEscapedPrefix = "boolean",
	virtualObjectsVisible = "boolean",
	enableCamera = "boolean",
	defaultCameraTrackingLevel = "number",
	scaleCameraBoundsToScreen = "boolean",
	enableTileCulling = true,
	onPointBased = "function",
	onEllipse = "function",
	onImageObj = "function",
	onRect = "function",
	onObj = "function"
}

--------------------------------------------------------------------------------
-- Set Preference
--------------------------------------------------------------------------------
function settings.set(preferenceName, value)
	if not preferenceName or value == nil then verby_error("Missing one or more arguments to `settings.set()` (`dusk.setPreference()`)") end
	if not config[preferenceName] then verby_error("Unrecognized setting \"" .. preferenceName .. "\".") end
	--local value_type = type(value) if config[preferenceName] ~= value_type then verby_error("Wrong type for setting \"" .. preferenceName .. "\" (expected " .. config[preferenceName] .. " but got " .. value_type .." instead)") end
	
	data[preferenceName] = value
end

--------------------------------------------------------------------------------
-- Get Preference
--------------------------------------------------------------------------------
function settings.get(preferenceName)
	if not (preferenceName ~= nil) then verby_error("No argument passed to `settings.get()` (`dusk.getPreference()`)") end
	return data[preferenceName] or nil
end

--------------------------------------------------------------------------------
-- Add/Remove Evaluation Variable
--------------------------------------------------------------------------------
function settings.setEvalVariable(varName, value)
	data.evalVariables[varName] = value
end

function settings.removeEvalVariable(varName)
	data.evalVariables[varName] = nil
end

return settings