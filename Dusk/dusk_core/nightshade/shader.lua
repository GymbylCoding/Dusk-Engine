--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Shader

The actual Nightshade shader.
--]]
--------------------------------------------------------------------------------

local kernel = {}

-- ***** --

local lib_settings = require("Dusk.dusk_core.misc.settings")

-- ***** --

kernel.category = "composite"
kernel.name = "nightshade"

-- ***** --

kernel.vertexData = {
  {
    name = "layerSize",
    default = 0,
    min = 0,
    max = math.huge,
    index = 0
  },
  {
    name = "tilesetTileWH",
    default = 0,
    min = 0,
    max = math.huge,
    index = 1
  },
  {
    name = "tilesetWH",
    default = 0,
    min = 0,
    max = math.huge,
    index = 2
  },
  {
    name = "mapDimensions",
    default = 0,
    min = 0,
    max = math.huge,
    index = 3
  }
}

-- ***** --

local shiftDistance = lib_settings.get("nightshadeVariableShiftDistance")

kernel.fragment = [[
#extension GL_EXT_gpu_shader4 : enable

P_POSITION int layerSize = int(CoronaVertexUserData.x);
P_POSITION int tilesetTileWH = int(CoronaVertexUserData.y);
P_POSITION int tilesetWH = int(CoronaVertexUserData.z);
P_POSITION int mapDimensions = int(CoronaVertexUserData.w);

P_POSITION vec2 layerPixelDimensions = vec2(
  layerSize >> ]] .. shiftDistance .. [[,
  layerSize & ((1 << ]] .. shiftDistance .. [[) - 1)
);

P_POSITION vec4 tilesetDimensions = vec4(
  tilesetTileWH >> ]] .. shiftDistance .. [[,
  tilesetTileWH & ((1 << ]] .. shiftDistance .. [[) - 1),
  tilesetWH >> ]] .. shiftDistance .. [[,
  tilesetWH & ((1 << ]] .. shiftDistance .. [[) - 1)
);

P_POSITION vec2 mapTileDimensions = vec2(
  mapDimensions >> ]] .. shiftDistance .. [[,
  mapDimensions & ((1 << ]] .. shiftDistance .. [[) - 1)
);

P_POSITION vec2 tilesetPixelDimensions = vec2(tilesetDimensions.x * tilesetDimensions.z, tilesetDimensions.y * tilesetDimensions.w);

P_COLOR vec4 FragmentKernel(P_UV vec2 textureCoordinate) {
  P_COLOR vec4 dataSample = texture2D(CoronaSampler0, textureCoordinate);
  
  P_POSITION float gid = floor(dataSample.r * 255) - 1;
  
  if (gid == -1)
    return CoronaColorScale(vec4(0, 0, 0, 0));
  
  // Pixel coordinate in the layer
  P_POSITION vec2 pixelCoordinate = vec2(
    textureCoordinate.x * layerPixelDimensions.x,
    textureCoordinate.y * layerPixelDimensions.y
  ); 
  
  // Coordinates of this tile in the tileset
  P_POSITION vec2 tileCoordinates;
  tileCoordinates.y = floor(gid / tilesetDimensions.z);
  tileCoordinates.x = gid - (tileCoordinates.y * tilesetDimensions.z);

  // Offset coordinates of the tile in this layer
  P_POSITION vec2 clampedTilePosition = vec2(
    floor(pixelCoordinate.x / tilesetDimensions.x) * tilesetDimensions.x, // floor() gives us the tile we're currently "in" for this pixel in the layer, then multiplication gives us the pixel location of that tile
    floor(pixelCoordinate.y / tilesetDimensions.y) * tilesetDimensions.y
  );
    
  P_POSITION vec2 tileOffset = vec2(
    pixelCoordinate.x - clampedTilePosition.x,
    pixelCoordinate.y - clampedTilePosition.y
  );
  
  P_POSITION vec2 tilesetNormalizedCoordinate;

  tilesetNormalizedCoordinate.x = (tileCoordinates.x * tilesetDimensions.x + tileOffset.x) / tilesetPixelDimensions.x;
  tilesetNormalizedCoordinate.y = (tileCoordinates.y * tilesetDimensions.y + tileOffset.y) / tilesetPixelDimensions.y;
  
  P_COLOR vec4 outColor = texture2D(CoronaSampler1, tilesetNormalizedCoordinate);
  return CoronaColorScale(outColor);
}
]]

return kernel