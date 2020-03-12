# Functional Specification

## Features

- Multi-port block RAM capable. Any number of R/W agents supported.
- Can support independent clock domain per agent
- RAM core can be sourced with a specific clock to unleash performance
- Provide native RAM interface or AXI4
- Rely on replicated RAM block, one dedicated per write agent.
  A global register monitor (GRM) addresses bank selection based on last accesses.
- AXI4 interface supports outstanding request (configurable)
- Monitor write ops and detect collision. Can inform agents on such events.

## Architecture

Write interface:

                     -------------------      -------      --------------------
    Write Agent ---> | Input interface | ---> | CDC | ---> |     RAM Core     |
                     -------------------      -------      --------------------

Read interace:

    --------------------      -------      --------------------
    |     RAM Core     | ---> | CDC | ---> | Output interface | ---> Read Agent
    --------------------      -------      --------------------


RAM Core:

                ----------------
                |              |
    WR Addr --> |              |
                | XFER Monitor | --> RD Bank Switch --|
    RD Addr --> |              |                      |
                |              |                      |
                ----------------                      |
                                                      |
                                                      |
                 ----------------                     |
                 |              |                     v
    W0 Agent --> |   Bank 0     | -----------------> |\
                 |              | \                  | | --> RD0 Agent
                 ----------------  \    /----------> |/
                                    \  /              |
                                     \/               v
                 ----------------    /\-- ---------> |\
                 |              |   /                | | --> RD1 Agent
    W1 Agent --> |   Bank 1     |  ----------------> |/
                 |              |
                 ----------------
