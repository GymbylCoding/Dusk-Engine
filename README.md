## Dusk Engine ##

##### Read the quickstart guide [here](http://github.com/GymbylCoding/Dusk-Engine/wiki/Quickstart) #####

The Dusk Engine is a fully featured game engine for [Corona SDK](http://www.coronalabs.com). It's designed to help you "weed out" extra code for level creation and let you focus on the game mechanics, instead of the level makeup.  

It's written on a powerful base, but interfaced with simple, intuitive commands that are easy to learn (when they even exist!). Adding Dusk to your project barely makes a ripple on your code. You can keep all the normal Corona function calls you're used to: `map:scale()`, `layer:insert()`, and the such; you don't have to use separate engine functions to do normal task. Dusk is meant to incorporate seamlessly into your project's flow.


### New in this Version ###

After a long delay - following the release of [my first game](http://forums.coronalabs.com/topic/47069-crystalline-deflection-made-by-a-14-year-old/); if you don't want to pay the $0.99 my game costs, at least read my story `:)` - a new version (v0.1.4) is finally out! It's just an upkeep release; various improvements to speed, code cleanup, etc.

With this update, though, I've got something new (and super awesome!) to offer: TOAD: Tileset Operations and Doodads. TOAD is a command-line utility that makes it easy to extrude tilesets, pack them from a folder, and more, so you don't have to do tedious repetitive operations.


### What's Here ###

This folder (download the ZIP and unpack) includes...
* The Dusk Engine itself (`Dusk/*`)
* A folder of engine tests (`tests/*`)
* A folder of engine demos (`Demos/*`)
* A tileset I packed from the set by www.kenney.nl (`tilesets/tileset.png` with corresponding `@2x` version, plus all the tilesets in the `tests` folder)
* A demo map that uses various feature of Dusk (`everything`, both the JSON and TMX versions)
* A list of things left to be done (`TODO.txt`)
* A folder that will hold plugins (`Plugins/*`)
* Corona/Lua files to run the sample (`main.lua`, `config.lua`, `build.settings`)
* The TOAD system (`TOAD/*`)


### Install ###

The engine itself is found (strangely enough!) in the folder named "Dusk". It's what you'll use for your personal projects. To use Dusk in your project, copy the folder into your project's **root** directory (where `main.lua` is) and `require` it like so:
```Lua
local dusk = require("Dusk.Dusk")
```
You won't have to worry about any other files in the Dusk folder, unless you want to take a peek at the code. They're all used internally by the engine itself

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
