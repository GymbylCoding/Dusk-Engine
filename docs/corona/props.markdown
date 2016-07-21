# object.props

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Table][api.type.Table]
> __Objects__           [Map][plugin.dusk.type.Map], [TileLayer][plugin.dusk.type.TileLayer], [ObjectLayer][plugin.dusk.type.ObjectLayer], [ImageLayer][plugin.dusk.type.ImageLayer], [Tile][plugin.dusk.type.Tile], [Object][plugin.dusk.type.Object]
> __Library__           [dusk.*][plugin.dusk]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Property
> --------------------- ------------------------------------------------------------------------------------------

## Overview

This property gives you an alternative place to store Tiled properties from the object's root structure. If a property in Tiled is prefixed with `props:`, it will be transferred to this table rather than directly to the object. This is useful for properties that may have another meaning (such as Corona fields like `x` or `alpha`) or for when you simply want a neater object structure. The properties may be retrieved simply by indexing this table.


## Example

``````lua
--
-- Earlier, in the Tiled map, set the property props:foo in the map to 25
--

local dusk = require("plugin.dusk")
local map = dusk.buildMap("map.json")
local foo = map.props.foo
print(foo) -- 25
``````
