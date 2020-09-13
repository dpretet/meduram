# MEDURAM

<p align="center">
  <img width="300" height="300" src="./doc/gorgone.jpg">
</p>

## Introduction

Meduram is an IP core implementing a multi-port block RAM in order to share
a memory space between multiple agents of a system. Meduram provides native
block RAM interface (EN / ADDR / DATA) or AXI4-lite interface. It also supports
independent clock domain for each read/write interface as for the RAM core,
enabling a TDM-like implmentation to unleash performance when using AXI4-lite
interfaces. In order to manage synchronization mechanism thru the memory space,
Meduram provides flags to the read agents connected in case write or read
collisions occur.

It's widely inspired by the concepts discussed in the paper
["Efficient Multi-Ported Memories for FPGAs"](http://www.eecg.toronto.edu/~steffan/papers/laforest_fpga10.pdf)
by Charles Eric LaForest and J. Gregory Steffan.

## Features

- Multi-port block RAM capable. Any number of R/W agents supported.
- Provide native RAM interface or AXI4-lite
- Can support independent clock domain per agent when using AXI4-lite interface
- Rely on replicated RAM block, one dedicated per write agent.
- AXI4-lite interface supports outstanding request (configurable)
- Monitor write ops and detect collision. Can inform agents on such events.

## Documentation

- [Architecture](doc/architecture.md)
- [Read and write collision](doc/rw_collision.md)
- [Parameters & Interface](doc/param_itfs.md)

## Flow

Meduram uses Icarus Verilog for simulation and Yosys for synthesis.

To execute a basic synthesis with Yosys:

    ./flow.sh syn

or into syn folder

    ./run.sh


To execute the testsuite:

    ./flow.sh sim

or into sim folder

    ./run.sh

Meduram relies on [SVUT](https://github.com/dpretet/svut) to create and execute
testsuites.

## TODO

- Implement a retry circuit in AXI4-lite read interface if read collision occurs
- Manage APROT in AXI4-lite interface

## License

This IP core is licensed under MIT license. It grants nearly all rights to use,
modify and distribute these sources. However, consider to contribute and provide
updates to this core if you add feature and fix, would be greatly appreciated :)

Please refer to [LICENSE file](./LICENSE) for more details.
