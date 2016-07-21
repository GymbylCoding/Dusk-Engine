# map:getCameraPosition()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Number][api.type.number]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Camera, position, viewport
> __See also__          [map:setCameraPosition()][plugin.dusk.type.Map.setCameraPosition]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Returns the current target position of the camera. This may not be the position actually displayed due to tracking level functionality.


## Syntax

	map:getCameraPosition()


## Example

``````lua
map:setCameraPosition(100, 100)

local cameraX, cameraY = map:getCameraPosition()
print(cameraX .. ", " .. cameraY) -- 100, 100
``````
