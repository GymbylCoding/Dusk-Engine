--------------------------------------------------------------------------------
--[[
Verby: Lightweight Pretty Printer
--]]
--------------------------------------------------------------------------------

local verby = {}
verby.verbose = true
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
local print = function(...) local args = {...} for i = 1, #args do io_write(tostring(args[i]) .. "\n") end if #args == 0 then io_write("\n") end end
local string_rep = string.rep

local indentLevel = 0
local indentStr = ""
local indentWith = "\027[2m**\027[0m"
local afterIndent = "\027[1m*\027[0m "
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
		if level == -1 then
			style = "\027[31m\027[1m"
		elseif level == 1 then
			style = verby.RESET
		elseif level == 2 then
			style = "\027[32m"
		elseif level == 3 then
			style = "\027[34m"
		end
	end

	if verby.allowCodeTags then
		msg = msg:gsub("`(.-)`", verby.CODE .. "%1" .. style)
	end

	if level == -1 then
		print(style .. "Error: " .. msg .. "\n(aborting)" .. verby.RESET)
	end

	if verby.verbose then
		if level == 1 then
			print(indentStr .. style .. msg .. "\027[0m")
		elseif level == 2 then
			print(indentStr .. style .. msg .. verby.RESET)
		elseif level == 3 then
			print(indentStr .. style .. msg .. verby.RESET)
		end
	end
end

verby.error = function(msg) verby.write(msg, -1) verby.resetIndent() error() end
verby.write1 = function(msg, style) verby.write(msg, 1, style) end
verby.write2 = function(msg, style) verby.write(msg, 2, style) end
verby.write3 = function(msg, style) verby.write(msg, 3, style) end
verby.writeBase = function(msg) local ind = indentStr indentStr = "" verby.write(msg, 1) indentStr = ind end
verby.separate = function() verby.writeBase(separator) end
verby.assert = function(what, msg) if not what then verby.error(msg) end end

return verby