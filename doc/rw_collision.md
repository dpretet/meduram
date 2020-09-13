# Read and Write Collision Support

Meduram by providing mutliple read and write ports unlike a dual port RAM has
to handle properly the possible R/W collisions and inform agents. Without this
information, the implementation of memory synchronization could be very tricky.

When two or more agents access the same memory address at the same time,
Meduram will face two possible scenarios to assert the collision flag:

1. A write collision occured previously on the address, meaning this value
   should be invalidated for all agents. All read completions are driven to the
   agents but data integrity can't be ensured. rdcollision Bit 0 is asserted.
2. No write collision occured, but the agents tried to access the same bank
   (not necessarly the same address in the bank). Only the higher index agent will
   receive the correct data without collision notified, all other will receive the
   same value with the collision flag asserted. 

## Write Collision

Meduram to provide multi port capability uses a RAM block for each write agent.
In order to drives the right RAM data to a read agent, an accounter circuit
monitors each address to store the last write agent which accessed the memory
cell. This index will be used by the read switch circuit to drives the correct
RAM output.

When two or more agents access the same memory address at the same time,
the accounter circuit stores along the lowest write agent index a collision flag
to indicate the read agent the memory cell content should be discarded.

In case a native RAM interface is used, write collision will be transmitted
to a read agent on `rdcollision[0]`.

In case AXI4-lite interface is used, the flag will be used to encode in `BRESP` 
the return code `SLVERR = 0b10`.

## Read collision

With Meduram, an agent can also experience a read collision when multiple
read agents try to read the same memory bank at the same time. 
Indeed, if two agents read addresses updated by the same write agent, the read
switchs can't serve both the requests in the same cycle because the agents will
access the same memory bank. Both the request will receive a collision flag
asserted during the data completion.

In case a native RAM interface is used, read collision will be transmitted
to a read agent on `rdcollision[1]`.

In case AXI4-lite interface is used, the flag `rdcollision[1]` will
be used to encode in `RRESP` with return code `SLVERR = 0b10`.
