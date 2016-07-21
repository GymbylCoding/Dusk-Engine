# map:snapCamera()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      none
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Camera, position, viewport
> __See also__          [map:positionCamera()][plugin.dusk.type.Map.positionCamera]
> --------------------- ------------------------------------------------------------------------------------------

## Overview

Snaps the camera to the camera's current target position. This function basically ignores the camera's tracking level for one tick of the camera movement function, thereby instantly positioning the camera wherever it needs to be.


## Syntax

	map:snapCamera()


## Example

``````lua
map:setTrackingLevel(0.01) -- Very slow tracking level
map:setCameraPosition(display.contentWidth, display.contentHeight) -- Move the map somewhere

map:snapCamera() -- Instantly position the camera at the target position
``````
