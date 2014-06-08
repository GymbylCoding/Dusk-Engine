--------------------------------------------------------------------------------
-- config.lua
--------------------------------------------------------------------------------

local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
	content = {
		width = 768,--aspectRatio > 1.5 and 800 or math.ceil( 1200 / aspectRatio ),
		height = 1024,
		scale = "none",
		fps = 60,
		imageSuffix = {
			["@2x"] = 1.3,
		}
	}
}