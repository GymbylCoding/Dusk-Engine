### New Culling Algorithm Idea

Make a "culling rectangle" class that keeps track of one rectangle of tiles. Something like this:

```lua
local culling = newCullingRectangle(layer)

culling.widthInTiles = numScreenTilesX -- Number of tiles to cull to
culling.heightInTiles = numScreenTilesY

culling.x = display.contentCenterX -- Position of the rectangle
culling.y = display.contentCenterY

culling.update() -- Erase and draw tiles as needed from previous position
```

Just an idea for the future. This could also enable users to keep tiles underneath enemies or other NPCs "alive".