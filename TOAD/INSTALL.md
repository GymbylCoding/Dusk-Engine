If you try and run TOAD and you get the message "ImageMagick not found; please install", you'll need to download and install ImageMagick. ImageMagick is a command-line suite of image processing tools. It's what TOAD uses to do all the nifty tileset operations, so no ImageMagick = no TOAD.

#### Quick installation of ImageMagick (if you want to hurry up and get TOAD to work) ####

TOAD is configured to work with ImageMagick's convert and composite tools in the same directory, so that makes it easy to install ImageMagick dependencies if you don't want anything else.

- Go to `http://www.imagemagick.org/download/binaries/` and download the version you need
- Once you've downloaded it, decompress it.
- In that folder, you'll find several subfolders. Open the one named `bin`. There should be about 16 files in it.
- Copy the two files "convert" and "composite" into the "toad" directory (the one this file is in)
- Done!