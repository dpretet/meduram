# Read and Write Collision Support

Meduram by providing mutliple read and write ports unlike a dual port RAM
has to handle properly the possible collisions occuring during agents requests.

## BRAM Modes

- Read latency
- Read after write
- Write after read
- How to configure the behavior
- Impact on write and read collision circuit?

## Write Collision

When two or more agents access the same memory address at the same time,
Meduram will store with the accounter circuit the higher write agent index
which participate to the collision event. Along this index, it will store a
flag to inform during the completion about the collision event. The flag can be
asserted during the same clock cycle the write access occur, or can be
registered to be asserted to occur one cycle later. In case AXI4-lite interface
is used, the flag will be used to encode in `BRESP` the return code `SLVERR =
0b10`, return along the completion channel one cycle after the write channel
handshake.

## Read collision

When two or more agents access the same memory address at the same time,
Meduram will face two possible scenarios to assert a collision flag:

1. A write collision occured previously on the address, meaning this value
   should be invalidated in all agents. All read completion are driven to the
   agents but data integrity can be ensured. RDcol Bit 0 is asserted.
2. No write collision occured, but the agents tried to access the same bank 
   (not necessarly the same address in the bank). Only the higher index agent
   will receive the correct data without collision notified, all other will 
   receive the same value with the collision flag asserted. 

The flag `RDcol` will be asserted according the read latency specified by the
user. In case AXI4-lite interface is used, the flag `RDcol[0]` will be used to
encode in `RRESP` the return code `SLVERR = 0b10`, returned along the completion
channel one cycle after the read channel handshake. If the collision is a
concurrent read collision (`RDcol[1] = 1'b1`), the AXI4-lite will retry the
access as long `RDcol[1]` is asserted. The retry number is configurable by the
user with `RD_RETRY` parameter.

