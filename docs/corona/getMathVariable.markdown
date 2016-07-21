# dusk.getMathVariable()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      [Number][api.type.Number]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          math, property
> __See also__          [dusk.setMathVariable()][plugin.dusk.setMathVariable]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Returns the current value of a math variable.


## Syntax

	dusk.getMathVariable( key )

##### key ~^(required)^~
_[String][api.type.String]._ The name of the variable to get.


## Example

``````lua
local dusk = require("plugin.dusk")
local value = dusk.getMathVariable("myNumber") -- Get the current value of the variable "myNumber"
``````
