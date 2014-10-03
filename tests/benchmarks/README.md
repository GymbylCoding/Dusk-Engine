## Benchmark Tests ##

The files found in this folder are benchmarks for Dusk's tile culling capabilities.

Each map is named by its dimensions; 256_192.json is a 256-width by 192-height map.

#### Result ####

These tests were last run for version 0.1.4 of Dusk. Output follows for the second run of each map.

```
runtest 128_96
-> map built
-> 12,288 tiles
-> 70.505 ms to load
```
```
runtest 256_192
-> map built
-> 49,152 tiles
-> 123.773 ms to load
```
```
runtest 512_384
-> map built
-> 196,608 tiles
-> 348.814 ms to load
```
```
runtest 1024_768
-> map built
-> 786,432 tiles
-> 1265.619 ms to load
```
```
runtest million
-> map built
-> 1,000,000 tiles
-> 1588.858 ms to load
```