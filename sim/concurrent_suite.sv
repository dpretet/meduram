`TEST_SUITE("ADVANCED SUITE - CONCURRENT ACCESS")

    `UNIT_TEST("Concurrent write access to same address")

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr;
            logic [DATA_WIDTH-1:0] value1;
            logic [DATA_WIDTH-1:0] value2;
            addr = pickRandomAddr();
            value1 = $urandom();
            value2 = $urandom();
            writeBothAgents(addr, value1, value2);
            readAgent(AGENT1, addr, request);
            `ASSERT((request === value1));
        end

    `UNIT_TEST_END

`TEST_SUITE_END
