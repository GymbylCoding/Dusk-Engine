# map:positionCamera()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      none
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Camera, position, viewport, snap
> __See also__          [map:snapCamera()][plugin.dusk.type.Map.snapCamera], [map:setCameraPosition()][plugin.dusk.type.Map.setCameraPosition]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Moves the camera to a location relative to the map, ignoring the map's current tracking level. It can be used to snap the camera to a point.


## Syntax

	map:setCameraPosition(x, y)

##### x ~^(required)^~
_[Number][api.type.Number]._ The X-position at which to position the camera, relative to the map.

##### y ~^(required)^~
_[Number][api.type.Number]._ The Y-position at which to position the camera, relative to the map.


## Example

``````lua
map:positionCamera(0, 0) -- Snap the camera to the top-left corner
``````
