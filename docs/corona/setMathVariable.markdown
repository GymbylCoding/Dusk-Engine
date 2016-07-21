# dusk.setMathVariable()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      none
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          math, property
> __See also__          [dusk.getMathVariable()][plugin.dusk.getMathVariable]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Sets a Dusk math variable. Property values prefixed with `!math!` will be evaluated as mathematical equations; this function sets variables for use with equations.


## Gotchas

Math variables with only take effect if they are set before a map is built. Make sure to call this before `dusk.buildMap()`.


## Syntax

	dusk.setMathVariable( key, value )

##### key ~^(required)^~
_[String][api.type.String]._ The name of the variable to set.

##### value ~^(required)^~
_[Number][api.type.Number]._ The value to set the variable to.


## Example

``````lua
local dusk = require("plugin.dusk")
dusk.setMathVariable("myNumber", 48)
-- Now equations involving the variable "myNumber" will use 48 as its value
``````
