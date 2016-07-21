# dusk.loadMap()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Table][api.type.Table]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          map, tilemap, Dusk map
> __See also__          [dusk.buildMap()][plugin.dusk.loadMap]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Loads a map from data exported from Tiled. The data returned can then be altered if needed and passed to `dusk.buildMap()`.

If `dusk.buildMap()` is called with a file path as the map data, it will automatically call this function. This means that, in most cases, `dusk.loadMap()` is unnecessary and should only be used by power users who need to edit something about the map before building it or store the map's data in a structure of their own.


## Syntax

	dusk.loadMap( fileName [, baseDir] )

##### fileName ~^(required)^~
_[String][api.type.String]._ The path to the map file from Tiled. The file extension (`.json` or `.lua`) must be included.

##### baseDir ~^(optional)^~
_[Constant][api.type.Constant]._ The base directory containing the map file.


## Example

``````lua
local dusk = require("plugin.dusk")
local mapData = dusk.loadMap("path/to/map.json")
local map = dusk.buildMap(mapData)
``````