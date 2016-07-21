# map:isTileWithinMap()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Boolean][api.type.Boolean]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Tile, bounds
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Checks whether a tile location is within the map's tile bounds. This function can be used to tell whether a particular tile is off the edge of the map in any direction. This function will not tell you whether a tile exists at a location; instead, it merely queries whether a tile could potentially exist at a location.


## Syntax

	map:isTileWithinMap(x, y)

##### x ~^(required)^~
_[Number][api.type.Number]._ The X-position in tiles of the tile.

##### y ~^(required)^~
_[Number][api.type.Number]._ The Y-position in tiles of the tile.


## Example

``````lua
local tileX, tileY = map:contentPixelsToTiles(event.x, event.y) -- Convert touch to tile position

local isInMap = map:isTileWithinMap(tileX, tileY)

if isInMap then
	print("Touch was within map bounds")
else
	print("Touch was not within map bounds")
end
``````
