# layer.tiles

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Table][api.type.Table]
> __Objects__           [TileLayer][plugin.dusk.type.TileLayer]
> __Library__           [dusk.*][plugin.dusk]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Tiles
> --------------------- ------------------------------------------------------------------------------------------

## Overview

This property stores the tiles in the layer. Tiles are stored under `layer.tiles[x][y]`. Note that if a column has no tiles in it, its entry in the `tiles` table may not even exist. This means that you cannot simply access `layer.tiles[x][y]`; instead, you must first check for `layer.tiles[x]` and then `layer.tiles[x][y]`.

Dusk provides convenience methods for iteration and tile access with error checking built in, so this property isn't often used.

Note that Tiled indexes tiles from 0, but Lua indexes from 1, so you'll need to add 1 to any position measurements you get from Tiled if you're trying to access a specific tile.


## Example

``````lua
local tile
if map.layers[1].tiles[5] and map.layers[1].tiles[5][3] then
	tile = map.layers[1].tiles[5][3] -- Get the tile at (5, 3)
end
``````
