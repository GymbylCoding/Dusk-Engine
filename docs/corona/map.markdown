# layer.map

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Map][plugin.dusk.type.Map]
> __Objects__           [TileLayer][plugin.dusk.type.TileLayer], [ObjectLayer][plugin.dusk.type.ObjectLayer], [ImageLayer][plugin.dusk.type.ImageLayer]
> __Library__           [dusk.*][plugin.dusk]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Map, parent
> --------------------- ------------------------------------------------------------------------------------------

## Overview

This property points to a layer's parent map. It is set on all layer types.


## Example

``````lua
local dusk = require("plugin.dusk")
local map = dusk.buildMap("map.json")

local layer = map.layer[1]
print(layer.map == map) -- true
``````
