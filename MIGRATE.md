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