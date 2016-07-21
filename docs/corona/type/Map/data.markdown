# map.data

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Table][api.type.Table]
> __Objects__           [Map][plugin.dusk.type.Map]
> __Library__           [dusk.*][plugin.dusk]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Data
> --------------------- ------------------------------------------------------------------------------------------

## Overview

This property contains data about a map.


## Fields

#### numTiledLayers

The number of layers in the map as set in Tiled. This may not be equal to `numLayers` if you have made a layer inactive with the `!inactive!` property.

#### numLayers

The number of layers in the map as built by Dusk. This may not be equal to `numTiledLayers` if you have made a layer inactive with the `!inactive!` property.

#### numTilesets

The number of tilesets in the map.

#### orientation

Will always be the string `orthogonal`. Dusk does not currently support isometric maps or hex maps.

#### width

The width of the map in tiles.

#### height

The height of the map in tiles.

#### rawTileWidth

The width of each tile in the map as specified in Tiled.

#### rawTileHeight

The height of each tile in the map as specified in Tiled.

#### tileWidth

The width of each tile in the map.

#### tileHeight

The height of each tile in the map.

#### pixelWidth

The total width of the map in pixels/points. This may not be equal to simply `map.contentWidth` due to Dusk's culling mechanisms.

#### pixelHeight

The total height of the map in pixels/points. This may not be equal to simply `map.contentHeight` due to Dusk's culling mechanisms.

#### mapData

The data used to create the map.


## Example

``````lua
local map = dusk.buildMap("map.json")

print(map.data.tileWidth, map.data.tileHeight) -- Print the size of each tile in the map
``````
