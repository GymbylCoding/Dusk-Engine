# dusk.*

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Library][api.type.library]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          Dusk, tilemap
> __Platforms__			    Android, iOS, OS X, Windows
> --------------------- ------------------------------------------------------------------------------------------

## Overview

Dusk loads maps made with [Tiled](http://mapeditor.org) into your Corona projects and handles camera movement, culling, and physics.


## Syntax

	local dusk = require("plugin.dusk")


## Functions

#### [dusk.buildMap()][plugin.dusk.buildMap]

#### [dusk.loadMap()][plugin.dusk.loadMap]

#### [dusk.setConfigOption()][plugin.dusk.setConfigOption]

#### [dusk.getConfigOption()][plugin.dusk.getConfigOption]

#### [dusk.setMathVariable()][plugin.dusk.setMathVariable]

#### [dusk.getMathVariable()][plugin.dusk.getMathVariable]

#### [dusk.registerPlugin()][plugin.dusk.registerPlugin]


## Project Settings

To use this plugin, add an entry into the `plugins` table of `build.settings`. When added, the build server will integrate the plugin during the build phase.

``````lua
settings =
{
	plugins =
	{
		["plugin.dusk"] =
		{
			publisherId = "com.gymbyl",
			supportedPlatforms = {iphone = true, android = true, osx = true, win32 = true},
		}
	}
}
``````


## Support

* [Corona Forums](https://forums.coronalabs.com/forum/604-gymbyl-coding/)