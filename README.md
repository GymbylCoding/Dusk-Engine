### Dusk Engine

Here it is. The first public branch of Dusk 1.0. Get it, try it, and let me know what you think of it.


#### WIP

Even though it's labelled 1.0, this version is still technically a WIP. The engine is really quite stable, but it's missing complete docs, demos, and other stuff you'd expect from a software library. That's all coming along. Right now I'm just trying to get something out there: I'm afraid that if I don't get Dusk 1.0 released in some form, my perfectionism may never let me do it at all.


#### Converting from Pre-1.0 Versions to 1.0

There are a number of changes in 1.0 that aren't backwards-compatible with previous versions. Most of the engine uses the same ideas as older versions, but the way you go about doing things has changed in some parts. Here are most of the major changes that you'll need to edit your code for:

```lua
--
-- All methods now use colons (:) instead of dots (.) to better manage memory and to stay close to Lua OOP standards
--
map.updateView()  -- Incorrect; old way
map:updateView()  -- Correct

--
-- Map and layer iterators have been compressed
--
for layer, index in map.objectLayers() do       -- Incorrect; old way
for layer, index in map:getLayers("object") do  -- Correct

for layer, index in map.layers() do     -- Incorrect; old way
for layer, index in map:getLayers() do  -- Correct

for object in layer.objects() do     -- Incorrect; old way
for object in layer:getObjects() do  -- Correct

for object in layer.typeIs("theTypeToIterate") do             -- Incorrect; old way
for object in layer:getObjects("type", "theTypeToIterate") do  -- Correct ("type" can be "name" for layer.nameIs() equivalent)

--
-- Other changed functions (mostly in the camera system)
--
map.setViewpoint() -> map:setCameraPosition()
map.getViewpoint() -> map:getCameraPosition()
map.enableFocusTracking() -> map:enableCameraFocusTracking()
map.setTrackingLevel() -> map:setCameraTrackingLevel()
map.setDamping() -> (Removed)
tileLayer.tileByPixels() -> tileLayer:tileAtScreenPosition()
```

If you find something else that isn't backwards-compatible, let me know and I'll add it to this list.


#### Install

Dusk 1.0 will eventually become a pure-Lua Corona SDK plugin, but for now, just copy the `plugin` directory into your project and include Dusk via:
```lua
local dusk = require("plugin.dusk")
```
That's it!
