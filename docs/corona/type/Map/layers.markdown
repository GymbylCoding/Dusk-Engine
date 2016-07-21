# map.layers

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Table][api.type.Table]
> __Objects__           [Map][plugin.dusk.type.Map]
> __Library__           [dusk.*][plugin.dusk]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Layers, layer
> __See also__          [TileLayer][plugin.dusk.type.TileLayer], [ObjectLayer][plugin.dusk.type.ObjectLayer], [ImageLayer][plugin.dusk.type.ImageLayer]
> --------------------- ------------------------------------------------------------------------------------------

## Overview

This table contains each layer in the map.


## Usage

You can access individual layers in a map through this table. Each layer in the map is added twice to this table: once by index and once by name. This means that you can access a layer as `map.layers[1]` or as `map.layers["Name in Tiled"]`.

Layers are indexed from 1 to the number of layers in Tiled, where layer #1 is the **topmost** layer and the layer with the highest index is the **bottommost** layer.

Each layer is simply a Corona display group. For more information, see the devoted documentation pages on each type of layer.


## Gotchas

Be careful when iterating manually through this table. Since each layer is added twice to this table, you may iterate each layer twice if you use a normal `pairs()` loop. The recommended approach for iterating layers is with one of the map's layer iterators.


## Example

``````lua
local map = dusk.buildMap("map.json")

map.layers[1].alpha = 0 -- Set the alpha of the topmost layer to 0
map.layers[#map.layers].rotation = 45 -- Rotate the bottom layer by 45 degrees
map.layers["Tile Layer 1"].x = 100 -- Set the X of the layer named "Tile Layer 1"
``````
