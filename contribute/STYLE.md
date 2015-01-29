## Dusk Coding Style ##

#### Naming ####
* Functions and variables are in `camelCase`
* File names are `allinlowercase.lua`
* Localized functions from a Lua or Corona library just replace the dot with an underscore; i.e. `local math_round = math.round` or `local display_newRect = display.newRect`. This helps distinguish "native" functions from Dusk functions.
* Localized functions from a Dusk component or library are just the function name; i.e. `local spliceTable = lib_functions.spliceTable`.

#### General Practices ####
* Tabs to indent, **not spaces**. Tabs take up less *space* (heh heh) and allow people to view the code however they like.
* No spaces between parentheses. This includes all forms of parentheses spacing - `parenthesesSpacing( isJustUgly, isJustUgly2 )`, `function parenthesesSpacing ( isJustUgly, isJustUgly2 )`, `v = ( parenthesesSpacing + isJustUgly )`. Functions should be flat against the side of their argument list, and arguments should be firmly enclosed between the parentheses (once an argument just up and flew away in a 3rd-party library I used that used parentheses spacing).Function calls and equations should be the same
* Spaces between all **binary** operators (not **unary** minus, though, obviously) - addition, subtraction, division, multiplication, assignment, exponentation, you name it. This makes them prettier and easier to read - `v = (x + y) * 66.57 ^ z` vs `v=(x+y)*66.57^z`. Notice that the above rule also applies to equations, so no `v = ( x + y )`.
* Don't put unnecessary or excess squirrels in the code (this includes all other types of small potentially biting animals as well)
* Don't use excessive parentheses when you know operator precedence and it's unambiguous. When two binary operators have nearly the same precedence, you should use parentheses, though. `v = (x * y) + z` is bad, but `v = (x * y) / z` is good.
* If you use acronyms, contrary to most coding styles, they should be capitalized - `getID` vs `getId`, even when they're in the middle of a name - `isXMLValid`. Put acronyms at the end of function or variable names when possible (in the previous example, `isValidXML` would have been a better name). The only time acronyms should be lower case is when they begin a word: `xmlParser` instead of `XMLParser`.
* Don't put parentheses around `if`, `elseif`, `while`, `for`, etc. conditions. Lua doesn't need this, and it looks better without them. Use `if conditionIsTrue then` instead of `if (conditionIsTrue) then`.
