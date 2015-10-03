### Nightshade

Nightshade is a new component of Dusk which renders tile layers completely with a shader. It's pretty cool, but is still in the development phase. I don't recommend you use it for a production game right now.

To test it out, create a tile layer in a map and add the property `!nightshade!` to it, set to `true`.


#### Speed Improvements

With Nightshade, a layer's performance is pretty much constant. Unlike a normal tile layer, the number of tiles on-screen in the layer has nothing to do with the layer's performance. For example, a map with tiles of size 1x1 px, and a layer with 1024x768 of them to completely fill an iPad screen (786,432 total tiles) runs incredibly slow with a normal tile layer (obviously), but at a normal spiffy speed with Nightshade.


#### Caveats

##### To Be Fixed

In this early development stage of Nightshade, there are some things that don't work yet, but will eventually be fixed:

- Margin and spacing is currently not supported
- Nightshade **does not** run on devices


##### Inherent Limitations

Due to the limitations of using a shader versus actual tiles, there are some things to note. Using a shader will always be inherently less flexible than building separate tiles, which is why you can turn the shader on and off. Nightshade should be used for layers with a lot of tiles in them that don't need a lot of flexibility (e.g. backgrounds).

- No per-tile stuff (e.g. rotation, scale, properties, draw and erase listeners, etc.)
- No tile physics
- No culling margin customizing


#### Engine Stuff

Dusk has a few new settings for Nightshade. The names for these aren't stable yet.

- `developmentMode` - If set to `true`, Nightshade will generate data images each time the app is run. If set to `false`, you'll need to transfer the data images from the app's sandbox to `Dusk/nightshade_data_images/` before Nightshade will work.
- `nightshadeProductionDataImageDirectory` - The directory in which Nightshade will look for data images when dev mode is off. This defaults to `Dusk/nightshade_data_images/`.
- `nightshadeVariableShiftDistance` - should not be changed; this is a core value denoting how far to shift bits to store multiple variables in one vertex userdata field.