### Animation Mechanism Ideas ###

Here's how I'm currently envisioning the animation mechanism working:

```
- Keep track of the current frame each animation set (separate instance of animation data in tile properties) will start at using time calculation
- When we create a tile, set it to that frame but don't auto-animate it (`sprite:start()`); instead, insert it into a "pending animation start" queue
- Each frame (or other time interval), check each tile in the pending animation start queue to see if the next frame should happen; if it should, set the frame and `tile:start()`
```

Why so complex? Culling makes things a little harder; if we just do that, newly created tiles will have their animations started at the wrong time. Also, animations aren't per-clock-cycle events - a tile may get created halfway through an animation frame, so we can't just start it when it's created. That's what the queue is for.