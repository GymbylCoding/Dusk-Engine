# map:pixelsToTiles()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Number][api.type.Number]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Conversion, tiles, pixels
> __See also__          [map:tilesToPixels()][plugin.dusk.type.Map.tilesToPixels]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Converts a pixel/point position to a tile position.


## Syntax

	map:pixelsToTiles(x, y)

##### x ~^(required)^~
_[Number][api.type.Number]._ The X-position in pixels to convert.

##### y ~^(required)^~
_[Number][api.type.Number]._ The Y-position in pixels to convert.


## Example

``````lua
local tileX, tileY = map:tilesToPixels(display.contentCenterX, display.contentCenterY) -- Get the position in tiles of the tile at the center of the screen
``````
