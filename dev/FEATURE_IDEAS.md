## Feature Ideas

Not all these may be realized; these are just me having ideas and throwing them out there.

- TMX files
Support for the TMX map format. This doesn't seem to be a very requested feature, so I'm not sure about adding it.

- TSX tileset files
Tiled enables you to export tileset files as `.tsx`; Dusk could load these if TMX parsing is ever implemented.

- New culling algorithm
Right now, only tile layers are cull-able. A refactoring of the culling system with a new algorithm could make all things be cull-able.

- Layer-specific scaling support
Right now, the map can be scaled, but the camera system doesn't work so well (litotes) with independent layers being scaled.

- Make polygon objects using `display.newPolygon`
Currently not done because of unexpected behaviour with Corona's polygon objects

- Demos
Needs more demos/samples.

- Polygon triangulation/convex partitioning
For more complex physics shapes.

- Instant update for scaling
Without an `onUpdate()` transition parameter, scaling the map with `transition.to()` makes the map jitter when tile culling is turned on. A temporary solution could be a metatable with `__newindex` for scaling, or perchance a temporary transition library with `onUpdate()` included.
