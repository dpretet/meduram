# Read and Write Collision Support

Meduram by providing mutliple read and write ports unlike a dual port RAM has
to handle properly the possible collisions occuring during agents requests.

## Write Collision

When two or more agents access the same memory address at the same time,
Meduram will store with the accounter circuit the highest write agent index
which participates to the collision event. Along this index, it will stores a
flag to inform during the completion about the collision event. The flag can be
asserted during the same clock cycle the data is transmitted, or can be
registered to be asserted one cycle later. In case AXI4-lite interface
is used, the flag will be used to encode in `BRESP` the return code `SLVERR =
0b10`, return along the completion channel one cycle after the write channel
handshake.

## Read collision

When two or more agents access the same memory address at the same time,
Meduram will face two possible scenarios to assert a collision flag:

1. A write collision occured previously on the address, meaning this value
   should be invalidated for all agents. All read completions are driven to the
   agents but data integrity can't be ensured. rdcollision Bit 0 is asserted.
2. No write collision occured, but the agents tried to access the same bank
   (not necessarly the same address in the bank). Only the higher index agent will
   receive the correct data without collision notified, all other will receive the
   same value with the collision flag asserted. 

The flag `rdcollision` will be asserted according the read latency specified by
the user. In case AXI4-lite interface is used, the flag `rdcollision[0]` will
be used to encode in `RRESP` with return code `SLVERR = 0b10`, returned along
the completion channel one cycle after the read channel handshake. If the
collision is a concurrent read collision (`rdcollision[1] = 1'b1`), the
AXI4-lite will retry the access as long `rdcollision[1]` is asserted. The retry
number is configurable by the user with `RD_RETRY` parameter.

