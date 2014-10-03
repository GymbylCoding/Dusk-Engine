## Plugins ##

Plugins are ways to extend Dusk functionality. They're used by placing the plugin's `.lua` file in your game directory and `require()`-ing the plugin.

- Lettermap (`plugins/lettermap.lua`)
Provides a "debug view" of tiles in a map. Not really useful unless you're validating the culling algorithm (that's why I created it).

- MapCutter (`plugins/mapcutter.lua`)
Allows you to build a map out of selected layers, instead of the whole thing. Useful for when you make a game with each level being a different layer.