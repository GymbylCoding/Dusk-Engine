--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Data Image

Encodes a Nightshade layer's tile data as an image for the shader to access.
--]]
--------------------------------------------------------------------------------

local lib_dataImage = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local lib_settings = require("Dusk.dusk_core.misc.settings")

local pngEncoder = require("Dusk.dusk_core.nightshade.png_encoder")

--------------------------------------------------------------------------------
-- Generate Layer Data Image
--------------------------------------------------------------------------------
function lib_dataImage.generateTileLayerDataImage(fileName, mapData, layerData)
  local r, g, b, a = {}, {}, {}, {}
  
  local i = 1
  for y = 1, mapData.height do
    for x = 1, mapData.width do
      local index = (mapData.width * (y - 1)) + x
      local data = layerData.data[index]
      
      r[i] = data
      g[i] = 0
      b[i] = 0
      a[i] = 255

      i = i + 1
    end
  end
  
  local str = pngEncoder.ToString_RGBA(r, g, b, a, mapData.width)
  
  local path = system.pathForFile(fileName, system.DocumentsDirectory)

  print("Writing data image to " .. path)

  local file = io.open(path, "wb")
  file:write(str)
  file:close()
  
  return str
end

return lib_dataImage