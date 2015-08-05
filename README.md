clWrap
======

a nicer way to OpenCL

## Generating the function binding wrappers
* ```dub build :bindgen```
* ```./genFunctions <path-to-DerelictCL>/source/derelict/opencl/function.d > level1/clWrap/l1/functions.d```
