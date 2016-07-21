# map:contentPixelsToTiles()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Number][api.type.Number]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Conversion, tiles, pixels
> __See also__          [map:tilesToContentPixels()][plugin.dusk.type.Map.tilesToContentPixels]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Converts a content pixel/point position to a tile position.


## Syntax

	map:contentPixelsToTiles(x, y)

##### x ~^(required)^~
_[Number][api.type.Number]._ The X-position in pixels to convert.

##### y ~^(required)^~
_[Number][api.type.Number]._ The Y-position in pixels to convert.


## Example

``````lua
local tileX, tileY = map:tilesToPixels(event.x, event.y) -- Convert a touch position to a tile position
``````
