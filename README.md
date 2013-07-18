Ceramic Tile Engine (CoronaTiled)
=================================

An opensource, easy to use, fast [Corona SDK](http://www.coronalabs.com) project to load JSON and Lua map files saved from [Tiled](http://www.mapeditor.org).

##### Authors: #####
* Michael Wilson of [No. 2 Games](http://www.no2games.com)
* Caleb Place of [Gymbyl Coding](http://www.gymbyl.com)

##### Miscellaneous: #####
* The Jumper module found in this folder was written by Roland Yonaba, and can be found [here](http://github.com/yonaba/jumper).

##### Basic Usage: #####
```Lua
local ceramic = require("Ceramic")

-- Directory is optional, but note that directories (even for Lua maps) are specified with a slash (/), not a dot (.)

-- Make sure you include the extension!


-- Lua Encoding --
local map = ceramic.buildMap("directory/mapName.lua") 

-- JSON Encoding --
local map = ceramic.buildMap("directory/mapName.json")
```

##### Snippets #####
You can find snippets/mini-libraries [here](http://github.com/GymbylCoding/CeramicSnippets)

##### 0.7 Update Info: #####
* Complete code overhaul
* Camera system
* Tile culling
* New samples
* Bug fixes
* Various miscellaneous updates
* Per-object physics
* Per-tile physics
* Include JSON tables in properties with `!json!`

##### Update History: #####

* 0.1 - Initial release
* 0.2 - GridMap + Tiled release
* 0.3 - Bugfixes & starting TMX support
* 0.4 - Load a map region & tile properties including shapes
* 0.5 - Bug fixes & sprite layers
* 0.6 - First GUI release and "tile gap" fix
* 0.7 - See update info

##### Features: #####
* Unlimited layers
* Unlimited maps within the same project
* Unlimited tilesets
* Very flexible
* JSON or Lua encoded map files
* Object layers
* Tile layers
* Fast map loading
* Optional debug messages
* Basic mode
* Tileset offsets and margins
* Automatic culling algorithm
* Ridiculously easy to use
* Entirely free
* Camera system
	* Object tracking
	* Layer parallax
	* Lock a layer from moving with the camera with layer property trackingEnabled
	* Activates auto-culling
* Manual tile drawing and erasing
* Optional test setting
* Ability to lock tiles from being culled
* Tile and object Box2D physics
* Custom properties for tiles, layers, and objects
* JSON encoded table properties
* Per-tile physics
* Per-object physics

##### Unsupported #####
* TMX map encoding
* External tilesets (.tsx files)
* Custom culling range (currently only culls to screen size)
* Isometric maps
* Flipped and rotated tiles (but you can set a layer property to be `tiles:rotation = 90` or `tiles:Scale = -1`)
* Editing of loaded maps
* Camera system + scaled maps