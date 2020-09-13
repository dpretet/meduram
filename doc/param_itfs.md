# Parameters and Interfaces

## Parameters

| Name | Description |
|-----|-----------|
| ADDR_WIDTH |  Address width in bits |
| RAM_DEPTH |  log2(ADDR_WIDTH) |
| DATA_WIDTH |  data width in bits |
| WRITE_COLLISION | Activate write collision detection (0 or 1) |
| READ_COLLISION | Activate read collision detection (0 or 1) |

## Interface

|Signal| Description|
|-----|-----------|
| wren | write enable|
| wraddr | write address|
| wrdata | data to write in `waddr` address|
| rden | read enable|
| rdaddr | read address|
| rddata | data read at `rdaddr` address|
| rdcollision | collision flags: bit 0 for write collision, bit 1 for read collision|
