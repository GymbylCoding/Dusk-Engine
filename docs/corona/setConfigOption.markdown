# dusk.setConfigOption()

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.function]
> __Library__           [dusk.*][plugin.dusk]
> __Return value__      none
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          option, configuration
> __See also__          [dusk.getConfigOption()][plugin.dusk.getConfigOption]
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Sets a Dusk configuration option. These options change different aspects of Dusk to be more convenient or to better fit your needs.


## Gotchas

Many of these options affect the way a map is built. This means that options must be set **before** building a map. They will not take effect if they are set after building the map.


## Syntax

	dusk.setConfigOption( key, value )

##### key ~^(required)^~
_[String][api.type.String]._ The name of the option to set.

##### value ~^(required)^~
_(variable)._ The value to set the option to.


## Supported Options

##### displayBackgroundRectangle
_[Boolean][api.type.Boolean]._ Whether to display a simple rectangle coloured in Tiled's background color when the map is created or not. Defaults to `false`.

##### dotImpliesTable
_[Boolean][api.type.Boolean]._ Whether a dot in Tiled properties denotes a separate table or is accepted as part of a string key. When this is set to `true`, properties like `foo.bar.baz` will create the necessary tables in the object and set `object.foo.bar.baz` to the property value. When this is set to `false`, `foo.bar.baz` will result in `object["foo.bar.baz"]`. Defaults to `true`.

##### detectMapPath
_[Boolean][api.type.Boolean]._ Whether Dusk should look for tilesets relative to the directory of the map. Tiled exports tileset data as relative from the map, so this should nearly always be set to `true`. Defaults to `true`.

##### spaceAfterEscapedPrefix
_[Boolean][api.type.Boolean]._ For escaped property prefixes like `!dot!` or `!json!`, this option defines whether Dusk should skip the first character after the prefix (allowing for more clarity, as in `!json! { }`) or not. Usually, a value of `false` should work for most cases, whether or not you add a space after the prefix. Defaults to `false`.

##### autoGenerateObjectPhysicsShapes
_[Boolean][api.type.Boolean]._ This option defines if, when physics is enabled on an object, Dusk should automatically generate the physics body for it, matching the object's Tiled shape as closely as possible. Defaults to `true`.

##### ellipseRadiusMode
_[String][api.type.String]._ If `autoGenerateObjectPhysicsShapes` is `true`, this option defines how Dusk generates radial bodies for ellipses. If this is set to `"min"`, the object's automatically generated body will have a radius equal to the smaller dimension of the ellipse; if set to `"max"`, it will have a radius equal to the larger dimension; and if set to `"average"`, it will be equal to the average of the dimensions. Defaults to `"min"`.

##### furtherClassifyRectangleObjects
_[Boolean][api.type.Boolean]._ Whether Dusk should automatically classify rectangle objects in an object layer as `"square"` (for an equal-sided rectangle) and `"point"` (for a zero-sized rectangle) for iterators and the `_objType` property. Defaults to `true`.

##### virtualObjectsVisible
_[Boolean][api.type.Boolean]._ Whether virtual objects (rectangles, ellipses, polylines, and polygons) should be visible in object layers. Defaults to `true`.

##### enableCamera
_[Boolean][api.type.Boolean]._ Whether or not to add camera functionality to maps. Defaults to `true`.

##### defaultCameraTrackingLevel
_[Number][api.type.Number]._ The default tracking level for map camera systems. The closer to 0 this is, the more slowly and fluidly the camera tracks; the closer to 1 it is, the more rigidly and precisely. This can be changed at runtime with `map:setCameraTrackingLevel`. Defaults to 1.

##### scaleCameraBoundsToScreen
_[Boolean][api.type.Boolean]._ Whether the camera should stop at bounds when the edge of the screen reaches the bounds or whether it should stop when the bounds position is in the center of the camera. Defaults to `true`.

##### enableCameraRounding
_[Boolean][api.type.Boolean]._ Whether or not to round the camera's position to help eliminate tile flickering. This should be `true` unless you notice issues with the camera's tracking smoothness. Defaults to `true`.

##### enableTileCulling
_[Boolean][api.type.Boolean]._ Whether Dusk should clip and draw tiles as needed. Defaults to `true`.

##### enableObjectCulling
_[Boolean][api.type.Boolean]._ Whether Dusk should clip and draw objects as needed. Defaults to `true`.

##### cullingMargin
_[Number][api.type.Number]._ The margin (in tiles) to draw objects outside the screen. Unless you're noticing objects being drawn and erased, this should be left at default. Defaults to 1.

##### stylePointBasedObject, styleEllipseObject, styleImageObject, styleRectObject, styleObject
_[Function][api.type.Function]._ Functions called when objects are created to style them if `virtualObjectsVisible` is set to `true`. These should not be used as logic functions. They should be purely cosmetic. Each defaults to a basic styling function with grey lines.

##### objectsDefaultToData
_[Boolean][api.type.Boolean]._ Whether objects in an object layer default to data objects with no visual representation. Defaults to `false`.

##### useTileImageSheetFill
_[Boolean][api.type.Boolean]._ Draw tiles as rectangles with image sheet frame fills instead of as sprites (except when sprites are necessary). Defaults to `true`.

##### enableRotatedMapCulling
_[Boolean][api.type.Boolean]._ Allow Dusk to adjust culling as required to allow rotated maps. This should be `false` unless you're rotating your maps, as enabling this will add a tiny performance hit to your runtime. Defaults to `false`.

##### enableMultipleCullingFields
_[Boolean][api.type.Boolean]._ Allow multiple culling fields (currently an experimental feature). Defaults to `false`.


## Example

``````lua
local dusk = require("plugin.dusk")
dusk.setConfigOption("ellipseRadiusMode", "max")
``````
