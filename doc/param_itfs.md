# Parameters and Interfaces

## Parameters

    - ADDR_WIDTH: width defining all address bus
    - RAM_DEPTH: log2(ADDR_WIDTH)
    - DATA_WIDTH: width defining all data bus
    - WRITE_COLLISION: enable write collision detection
    - READ_COLLISION: enable read collision detection

## Interface

    - wren: write enable
    - wraddr: write address
    - wrdata: data to write in `waddr` address
    - rden: read enable
    - rdaddr: read address
    - rddata: data read at `rdaddr` address
    - rdcollision: collision flags:
        - bit0: write collision at `rdaddr` occured, several agents wrote at
          the same address at the same time
        - bit1: read collision detetected, several agents tried to access
          the same memory bank
