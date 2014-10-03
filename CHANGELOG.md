Current Version: Version 0.1.5

Basic Features:

- Tile, object, and image layers
- JSON- and Lua-encoded maps
- Custom tile, object, and layer properties
- Automated tile culling algorithm
- Integrated camera system (w/ scaling support)
- Multiple tilesets
- Multiple maps
- Evaluate math within properties
- Optionally separate loading and building maps
- Flipped and rotated tiles
- Tile and object iterators
- Tile and object access on built map


#### Version History ####

Version 0.1.5
Release Date: Sept. 14, 2014

- Removed `dot` library in favor of a more built-in function
- Minor improvements to performance
- Bug fixes
- Added alert to deprecated function calls
- General housekeeping & maintenance
- Cleaned up GitHub repository
- Updated `README`, `CHANGELOG`, etc.

----------

Version 0.1.4
Release Date: June 8, 2014

- Various bug fixes
- Improvements to performance
- Switched debug system from TPrint to Verby for speed and simplicity
- Removed "Twindex" data structure; the extra speed gain wasn't worth the initial load time
- Cleaned up Dot and improved speed

----------

Version 0.1.3
Release Date: February 6, 2014

- Added math evaluation support - use !eval! to evaluate property values, along with a set of variables
- Added support for loading map data via dusk.loadMap(filename, base) and pass it to dusk.buildMap(), rather than only file-based maps

----------

Version 0.1.2
Release Date: February 5, 2014

- More localized function calls
- Better camera tracking algorithm
- Improved Lua map support
- Added support for rotated tiles

----------

Version 0.1.1
Release Date: January 1, 2014

- Fixed faulty same-directory tileset search algorithm
- Fixed layer iteration issue

----------

Version 0.1.0
Release Date: December 13, 2013

Initial release.