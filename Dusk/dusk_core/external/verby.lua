--------------------------------------------------------------------------------
--[[
Verby: Lightweight Pretty Printer

Specialized for the Dusk Engine.
--]]
--------------------------------------------------------------------------------

local verby = {}

verby.allowCodeTags = true

verby.BOLD = "\027[1m"
verby.LIGHT = "\027[2m"
verby.CODE = "\027[30m"
verby.RESET = "\027[30m\027[0m"

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local io_write = io.write
local error = error
local tostring = tostring
local string_rep = string.rep

local indentLevel = 0
local indentStr = ""
local indentWith = "\027[2m  \027[0m"
local afterIndent = ""
local separator = "\n\027[1m----------" .. verby.RESET
local resetIndentStr = function() indentStr = string_rep(indentWith, indentLevel) .. afterIndent end
resetIndentStr()

--------------------------------------------------------------------------------
-- Indentation Controls
--------------------------------------------------------------------------------
verby.indent = function() indentLevel = indentLevel + 1 resetIndentStr() end
verby.dedent = function() indentLevel = indentLevel - 1 resetIndentStr() end
verby.resetIndent = function() indentLevel = 0 resetIndentStr() end

--------------------------------------------------------------------------------
-- Write
--------------------------------------------------------------------------------
verby.write = function(msg, level, style)
	local style = style
	local msg = tostring(msg)

	if not style then
		if level == -1 then -- Error
			style = "\027[31m\027[1m"
		elseif level == 1 then -- Message
			style = verby.RESET
		elseif level == 2 then -- Alert
			style = "\027[31m\027[1m"
		end
	end

	if verby.allowCodeTags then
		msg = msg:gsub("`(.-)`", verby.CODE .. "%1" .. style)
	end

	if level == -1 then
		print(style .. "Error: " .. msg .. "\n(aborting)" .. verby.RESET)
	elseif level == 1 then
		print(indentStr .. style .. msg .. "\027[0m")
	elseif level == 2 then
		print(indentStr .. style .. msg .. verby.RESET)
	end
end

verby.error = function(msg) verby.write(msg, -1) verby.resetIndent() error() end
verby.print = function(msg, style) verby.write(msg, 1, style) end
verby.alert = function(msg, style) verby.write(msg, 2, style) end
verby.writeBase = function(msg) local ind = indentStr indentStr = "" verby.write(msg, 1) indentStr = ind end
verby.separate = function() verby.writeBase(separator) end

return verby