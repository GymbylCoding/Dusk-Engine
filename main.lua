--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

display.setDefault("minTextureFilter", "nearest")
display.setDefault("magTextureFilter", "nearest")
display.setDefault("isImageSheetSampledInsideFrame", true)

-- ***** --

local dusk = require("plugin.dusk")

local map = dusk.buildMap("maps/demo.json")

native.showAlert("Welcome", "Welcome to Dusk 1.0. We're a little short on demos right now, but 1.0 works in much the same way other versions of Dusk do. That means you can get demos from older versions of Dusk and try them out yourself by following the instructions in MIGRATE.md. Give it a try!", {"Gotcha"})
