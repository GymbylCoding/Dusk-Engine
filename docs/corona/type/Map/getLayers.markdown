# map:getLayers()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      iterator
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Layer, iterator
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Iterates through layers in a map. Each iteration returns a layer and the index of the layer.


## Syntax

	map:getLayers([layerType])

##### layerType ~^(optional)^~
_[Number][api.type.String]._ The layer type to iterate. Can be set to `"tile"`, `"object"`, or `"image"` to iterate layers of a single type. If not set, Dusk will iterate over all layers in the map.


## Example

``````lua
for layer, index in map:getLayers("tile") do
	print(tostring(layer) .. " is a tile layer at index " .. index)
end
``````
