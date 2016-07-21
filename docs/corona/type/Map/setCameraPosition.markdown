# map:setCameraPosition()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      none
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Camera, position, viewport
> __See also__          [map:getCameraPosition()][plugin.dusk.type.Map.getCameraPosition]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Positions the camera at a location relative to the map. This function will take into account the map's current tracking level. It can be used to move the camera to a position of interest or to lock the camera to a position.


## Syntax

	map:setCameraPosition(x, y)

##### x ~^(required)^~
_[Number][api.type.Number]._ The X-position to move the camera to, relative to the map.

##### y ~^(required)^~
_[Number][api.type.Number]._ The Y-position to move the camera to, relative to the map.


## Example

``````lua
map:setCameraPosition(0, 0) -- Move the camera to the top-left corner of the map

Runtime:addEventListener("enterFrame", function()
	map:updateView() -- Call updateView() each frame
end)
``````
