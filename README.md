# MEDURAM

<p align="center">
  <img width="300" height="300" src="./doc/gorgone.jpg">
</p>

## Introduction

Meduram is an IP core implementing a multi-port block RAM in order to share
a memory space between multiple agents of a system. Meduram provides native
block RAM interface (EN / ADDR / DATA) or AXI4-lite interface. It also supports
independent clock domain for each read/write interface as for the RAM core,
enabling a TDM-like implmentation to unleash performance. Finally, Meduram
provides flags to the read agents connected in case write read collisions occur.

It's widely inspired by the concepts discussed in the paper
["Efficient Multi-Ported Memories for FPGAs"](http://www.eecg.toronto.edu/~steffan/papers/laforest_fpga10.pdf)
by Charles Eric LaForest and J. Gregory Steffan.

## Documentation

- [Read and write collision](doc/rw_collision.md)
- [Parameters & Interface](doc/param_itfs.md)

## Flow

To execute a basic synthesis with Yosys:

    ./flow.sh syn

To execute the testsuite:

    ./flow.sh sim

## TODO

- Enhance documentation and README
- Add AXI4-lite interface
- Test with multiple SERV processors to write advanced tests

## License

This IP core is licensed under MIT license. It grants nearly all rights to use,
modify and distribute these sources.

Please refer to [LICENSE file](./LICENSE) for more details.
