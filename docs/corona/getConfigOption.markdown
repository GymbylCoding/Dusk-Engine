# dusk.getConfigOption()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      (variable)
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          option, setting
> __See also__          [dusk.setConfigOption()][plugin.dusk.setConfigOption]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Returns the current value of a Dusk configuration option.


## Syntax

	dusk.getConfigOption( key, value )

##### key ~^(required)^~
_[String][api.type.String]._ The name of the option to get.


## Example

``````lua
local dusk = require("plugin.dusk")
local option = dusk.getConfigOption("dotImpliesTable")
print(option)
``````