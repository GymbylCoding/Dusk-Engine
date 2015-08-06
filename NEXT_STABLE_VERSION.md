### Roadmap for Dusk v0.2

Here are some things I want to get done before Dusk 0.2 becomes official.


##### Stabilize object culling

Right now, object culling seems to work perfectly, but it still feels a little "beta".

##### Complete multiple culling fields

This is currently supported, but it's very "green" and not very stable. This would solve myriad problems people have with keeping tiles "alive", making objects collide offscreen, etc.

##### Complete the Lua importer

The engine is written around the JSON table format, so I have a preprocessor to load Lua maps and modify them to fit the JSON-style data. I'm not positively sure it covers all edge cases, though.

##### Complete plugin support

This is just a nice thing to have for any engine, and it makes development a lot easier for people creating more complex games who need to modify the engine but don't want to... modify the engine (i.e. myself). Plugin support still needs more callbacks, possibilities for custom Tiled property prefixes, etc.


As I think of more things, I'll add them to this list.