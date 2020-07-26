`TEST_SUITE("ADVANCED SUITE - CONCURRENT ACCESS")

    `UNIT_TEST("Concurrent write access to same address")

        `INFO("Both write agent write the same address.");
        `INFO("Only agent 2 should write its data.");

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr;
            logic [DATA_WIDTH-1:0] value1;
            logic [DATA_WIDTH-1:0] value2;
            addr = pickRandomAddr();
            value1 = $urandom();
            value2 = $urandom();
            writeBothAgents(addr, value1, value2);
            readAgent(AGENT1, addr, request);
            `ASSERT((request !== value1));
            `ASSERT((request === value2));
        end

    `UNIT_TEST_END

    `UNIT_TEST("Concurrent read access to same address")

        `INFO("Both read agent access the same address.");
        `INFO("Both agent should read a correct value.");

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr;
            logic [DATA_WIDTH-1:0] value;
            logic [DATA_WIDTH-1:0] value1;
            logic [DATA_WIDTH-1:0] value2;
            addr = pickRandomAddr();
            value = $urandom();
            writeAgent(AGENT1, addr, value);
            readBothAgents(addr, request1, request2);
            `ASSERT((value === request1));
            `ASSERT((value === request2));
        end

    `UNIT_TEST_END

    `UNIT_TEST("Concurrent read access on same block")

        `INFO("Both read agent access the same block, but different address.");
        `INFO("Only agent 1 should read a correct value.");

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr;
            logic [DATA_WIDTH-1:0] value;
            logic [DATA_WIDTH-1:0] value1;
            logic [DATA_WIDTH-1:0] value2;
            addr = pickRandomAddr();
            value1 = $urandom();
            writeAgent(AGENT1, addr, value1);
            value2 = $urandom();
            writeAgent(AGENT1, addr+1, value2);
            readBothAgents(addr, request1, request2);
            `ASSERT((value1 === request1));
            `ASSERT((value2 !== request2));
        end

    `UNIT_TEST_END
`TEST_SUITE_END
