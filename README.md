# wang-tiles
An experiment to play around with wang-tiles and the ppm P6 file format


## Example generated picture:

![Example grid generated](https://github.com/sotolf2/wang-tiles/blob/main/Skjermbilde.PNG?raw=true)

## Purpose

This is just a little experiment with me having fun getting something to work
it's not "production ready" nor is it exemplary done, but it was fun getting it
to work

## How-To:

I used ```Nim Compiler Version 1.7.1 [Linux: amd64]``` to make this and I don't know how well it will work with others, but it's not doing anything fancy, and is not using any libraries outside of the standard library, so it should work on older versions as well

```
$ nim c -d:danger -r wanggrid.nim
$ feh wang-grid.ppm
```

All the variables are just encoded in the binary, so just change them in the code and recompile or write some simple way to input them if you feel you need it ;)
