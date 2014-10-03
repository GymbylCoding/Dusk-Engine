## TOAD: Tileset Operations and Doodads ##

This is the TOAD system, a friendly, open-source command-line utilities library for modifying tilesets. It's meant to be easily usable by anyone, even people who don't regularly use the terminal, or who don't like toads.

TOAD was written for the Dusk engine by Caleb Place of Gymbyl Coding.


## Usage (for terminal newbies) ##

*Before you can use TOAD, you'll need to install TOAD's ImageMagick dependencies. The instructions for that are given in `INSTALL.md`, found in this folder.*

The terminal is a way of telling the computer what to do. Instead of clicking around on icons, you enter commands to be done into the terminal window. TOAD is built as a command-line utility, so to use it, you tell the terminal "run the `toad` utility and tell it to do xyz".

To use TOAD, first open up a terminal window (on Mac, Applications/Terminal), wait a bit, and, depending on your computer, you should get a line of text that says something like `yourcomputer:~ yourname$` or similar. This means "enter a command" in Terminal-ese.

Now, you'll change directories (move to another folder). Assuming the location of this file is `Downloads/Dusk-Engine-master/TOAD/README.md`, type into the terminal window `cd ~/Downloads/Dusk-Engine-master/TOAD`. What you're doing is saying "computer, change my current directory to `~/Downloads/Dusk-Engine-master/TOAD`".

*On Mac, the name of this command is `cd`. On Windows, it's `cwd` (I think). Anyhow, if you use `cd` and you get `command not found`, try `cwd`.*

First, let's start up the interactive TOAD shell. Type in `toad/toad`. That means, "computer, open the file `toad/toad`". Because of the permissions and settings on the file, the computer knows to run it instead of open it with a text editor. When you run it, you should get a startup message, followed by a prompt `> `. This is just like the terminal's prompt - it means "enter a command".

TOAD supports three tileset commands right now: `extract`, `pack`, and `extrude`. To use them from the TOAD Shell, just type the name of the utility, followed by any arguments.

For example, to extrude the tileset in this directory and save it as `tileset_extruded.png`, just type `extrude tileset.png tileset_extruded.png`. Or, to extract all tiles from the tileset in this directory and save them in a directory named `tiles`, just type `extract tileset.png tiles`.

You can get more information on a utility by typing `help` followed by the name of the utility you need help with. Arguments are passed to the utility by typing `-argname argvalue` after the utility name. Each utility supports a number of arguments so that you can customize your output.

For example, to extract tiles from `tileset.png` and pack them with a margin and spacing into a new tileset named `tileset_marginspacing.png`, type `extract tileset.png tiles` and press enter. TOAD will extract the tiles into the directory. Once TOAD is finished, type `pack tiles tileset_marginspacing.png -dimensions 7x4 -margin 10 -spacing 5`. TOAD will generate a new tileset from the images in `tiles`, line them up on a 7x4 grid, and add a margin of 10 and spacing of 5.

To use TOAD in your project, you can copy the `toad` folder (with `toad`, `toad_extract`, etc. in it) into your project, change directories to it (like we did above with `cd`), and use it in the exact same way.

For a pseudo-tutorial, you can also run the tests by typing `tests` at the TOAD Shell, or by typing `toad/toad tests` at the terminal window when you're in the TOAD directory.


## Usage (for terminal nerds) ##

*Before you can use TOAD, you'll need to install TOAD's ImageMagick dependencies. Basic instructions for that are given in `INSTALL.md`, found in this folder. If you want, you can also just install ImageMagick as you would a normal tool - TOAD works with that, too.*

`cd` to the TOAD directory and open up the interactive shell with `toad/toad`. You can optionally put TOAD somewhere in your `PATH` to use it anywhere.

If you're a terminal nerd (and I assume you are, or you wouldn't be in this section), you can figure TOAD out yourself. It's not hard. To get started, just call `toad/toad help`.


## Troubleshooting ##

#### I'm getting `toad/toad: No such file or directory` when I try to run TOAD ####
You're not in this directory. Follow the instructions above to change directories.

#### I'm getting `Warning: ImageMagick's convert/composite tool was not found; some features of TOAD may not be available` when I try to run TOAD ####
Do what it says - open up INSTALL.md and read the installation instructions.

#### I'm getting `toad/toad: /bin/bash: bad interpreter: No such file or directory` when I try to run TOAD ####
You don't have the language TOAD is written in installed on your system. Do a web search for `install bash on [your platform name]`.

I hope someday to rewrite TOAD in C++ or similar for portability (it would also remove the need to install ImageMagick), but currently, you'll have to install Bash.


## Errors ##

By default, any errors are written to `toad/log`. You can usually ignore most of them.