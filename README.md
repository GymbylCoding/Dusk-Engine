## Dusk Engine ##

##### [Dash it all, I just want to get started!][quickstart] #####

The Dusk Engine is a fully featured Tiled map game engine for [Corona SDK][corona]. It's designed to make maps made with [Tiled][tiled] as easy as possible to import into your Corona SDK project.

It's written on a powerful base, but interfaced with simple, intuitive commands that stay out of your way as much as possible. In fact, many of the normal Corona function calls you're used to - `map:scale()`, `layer:insert()`, and the such - work seamlessly with Dusk.


#### Quick Message ####
I'm a 16-year-old software developer doing this in my spare time; if you don't mind, show your support of Dusk by [purchasing ($0.99) my first game!][game] It's really cool; if you like neon graphics, hexagons, light reflection, minimalist style, and puzzles, you'll love it.


### What's Here ###

This folder (download the ZIP and unpack) includes...
- The engine itself (`Dusk/*`)
- A folder of engine tests (`tests/*`)
- A folder of engine demos (`demos/*`)
- A tileset I packed from the set by www.kenney.nl (`tilesets/tileset.png` with corresponding `@2x` version, plus all the tilesets in the `Tests` folder)
- Some demo maps for Dusk (`maps/*`)
- A quick roadmap (`ROADMAP.md`)
- List of basic features of Dusk (`FEATURES.md`)
- Copy of MIT license (`LICENSE.md`)
- Plugins (`plugins/*`)
- Lua files to run the sample (`main.lua`, `config.lua`, `build.settings`)


### Documentation

Documentation is coming along slowly but surely. You can either browse it from your local repository or [read online from `rawgit.com`][rawgitdocs].


### Install ###

The engine itself is found in the folder named "Dusk". It's what you'll actually use. To use Dusk in your project, copy the folder into your project's **root** directory (where `main.lua` is) and `require` it like so:
```Lua
local dusk = require("Dusk.Dusk")
```

You won't have to worry about any other files in the Dusk folder, unless you want to take a peek at the code. They're all used internally by the engine itself.


### Contribute ###

One of the good things about open source projects is that anyone can code on them. Contributions are welcome. Take a look at the files in `contribute/` to get started.


### Made a Game With Dusk? ###

If you've published a game with Dusk, please contact me from [my website][contact] and I'll see about setting up a finished games showcase.


### License ###

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

[quickstart]: http://github.com/GymbylCoding/Dusk-Engine/wiki/Quickstart
[corona]: http://www.coronalabs.com
[tiled]: http://www.mapeditor.org
[game]: http://bit.ly/1mpG2wD
[contact]: http://www.gymbyl.com/contact
[rawgitdocs]: http://cdn.rawgit.com/GymbylCoding/Dusk-Engine/v0.2/docs/index.html