### Release Notes for Dusk Dev Tag 0.4

* Stability improvements
* Re-added `enableCameraRounding` as a setting
* Added initial culling field support
	* Add a culling field via `map.newCullingField(w, h, x, y)`
	* Modify culling field's `x` and `y` to move it around
	* Currently, modifying a culling field's `w` and `h` doesn't seem to be working perfectly
	* *Note: Multiple culling fields seem to be working correctly, however, they are very untested and should not be used in a published product currently.*
* Data objects *should* call draw/erase listeners now when they move in and out of a culling field - this is useful to use them as sensors for when you're within range of something
* Added iterator for all raw object datas. This is currently the only way to iterate through all (drawn and un-drawn) objects in an object layer

**Notice: This dev tag marks the end of the recent Dusk dev branch "push development". I'm now planning on fixing the bugs and getting Dusk dev tag 0.4 or 0.3 perfectly stable for a stable release.**

### Release Notes for Dusk Dev Tag 0.3

* Miscellaneous improvements to performance, bug-free-ness, and general awesomeness
* Physics is now required automatically when needed
* Added initial plugin support
	* Custom escaped value prefixes
	* Basic map building callbacks
	* *Note: Unregistering a plugin via `dusk.unregisterPlugin()` is very untested*
* Removed Verby in favor of simple Lua errors and printing
* Removed extra `stats.lua` in favor of a single function in `functions.lua`

##### Dev Tag 0.2

* Added data objects
	* `!isData!` property for objects and object layers
	* `objectsDefaultToData` preference for program-wide default
* Renamed each `on***` preference function to `style***Object` for clarity
* Renamed object layer `._literal()` and `._match()` to `._literalIterator()` and `._matchIterator()`
* Fixed a bug where `objTypeRectPointSquare` preference didn't work correctly
* Encapsulated object layer object code into `layer.buildObject()` function
* Added `edgeModeX` and `edgeModeY` Lua properties to tile layers (Dusk currently supports `stop` [default], `clamp`, or `wrap` for these)
* Added `cullingMargin` preference
* Added early culling tile fields support (probably not publicly usable yet)
* Added early official plugin support (not publicly usable yet)