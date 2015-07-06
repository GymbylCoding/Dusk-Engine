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