# dusk.buildMap()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Map][plugin.dusk.type.Map]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          map, tilemap, Dusk map
> __See also__          [dusk.loadMap()][plugin.dusk.loadMap]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Builds a map from data exported from Tiled.


## Supported Formats

Dusk supports maps exported from Tiled in both JSON and Lua formats. Because of the differences in data exported from Tiled, JSON maps are preferred.


## Syntax

	dusk.buildMap( data [, baseDir] )

##### data ~^(required)^~
_[String][api.type.String], [Table][api.type.Table]._ This can either be a string denoting the path to the map file exported from Tiled, or a map loaded with [dusk.loadMap()][plugin.dusk.loadMap].

##### baseDir ~^(optional)^~
_[Constant][api.type.Constant]._ The base directory containing the map file if `data` is a file path.


## Examples

##### File Path
``````lua
local dusk = require("plugin.dusk")
local map = dusk.buildMap("path/to/map.json")
``````

##### Pre-Loaded Data

``````lua
local dusk = require("plugin.dusk")
local mapData = dusk.loadMap("path/to/map.json")
local map = dusk.buildMap(mapData)
``````