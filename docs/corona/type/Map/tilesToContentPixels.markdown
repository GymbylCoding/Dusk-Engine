# map:tilesToContentPixels()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Number][api.type.Number]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Conversion, tiles, pixels
> __See also__          [map:contentPixelsToTiles()][plugin.dusk.type.Map.contentPixelsToTiles]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Converts a tile position to pixels/points in content space.


## Syntax

	map:tilesToContentPixels(x, y)

##### x ~^(required)^~
_[Number][api.type.Number]._ The X-position in tiles to convert.

##### y ~^(required)^~
_[Number][api.type.Number]._ The Y-position in tiles to convert.


## Example

``````lua
local contentPixelX, contentPixelY = map:tilesToPixels(5, 5) -- Get the pixel location in content coordinates of the tile at (5, 5)
``````
