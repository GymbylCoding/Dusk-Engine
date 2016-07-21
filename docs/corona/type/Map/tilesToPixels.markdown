# map:tilesToPixels()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Number][api.type.Number]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Conversion, tiles, pixels
> __See also__          [map:pixelsToTiles()][plugin.dusk.type.Map.pixelsToTiles]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Converts a tile position to pixels/points.


## Syntax

	map:tilesToPixels(x, y)

##### x ~^(required)^~
_[Number][api.type.Number]._ The X-position in tiles to convert.

##### y ~^(required)^~
_[Number][api.type.Number]._ The Y-position in tiles to convert.


## Example

``````lua
local pixelX, pixelY = map:tilesToPixels(5, 5) -- Get the pixel location relative to the map of the tile at (5, 5)
``````
