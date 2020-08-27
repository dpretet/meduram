`TEST_SUITE("ADVANCED SUITE - CONCURRENT ACCESS")

    `UNIT_TEST("------ TEST 1 ------")

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
            readAgent(AGENT1, addr, request, collision);
            `ASSERT((request === value1), "Failed to read correct agent 1 value");
            `ASSERT((request !== value2), "Failed to read correct agent 2 value");
            `ASSERT((collision === 1), "Expect collision is equal 1");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 2 ------")

        `INFO("Both write agent write the same address.");
        `INFO("Only agent 2 should write its data.");
        `INFO("Should detect a write collision on first read, then not on second");

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr;
            logic [DATA_WIDTH-1:0] value1;
            logic [DATA_WIDTH-1:0] value2;
            addr = pickRandomAddr();
            value1 = $urandom();
            value2 = $urandom();
            writeBothAgents(addr, value1, value2);
            readAgent(AGENT1, addr, request, collision);
            `ASSERT((request === value1), "Failed to read correct agent 1 value");
            `ASSERT(collision, "Expect write collision is equal 1");
            value1 = $urandom();
            writeAgent(AGENT1, addr, value1);
            readAgent(AGENT1, addr, request, collision);
            `ASSERT((request === value1), "Failed to read correct agent 1 value");
            `ASSERT((collision === 0), "Expect write collision is equal 0");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 3 ------")

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
            readBothAgents(addr, request1, request2, collision1, collision2);
            `ASSERT((value === request1), "Failed to read correct agent 1 value");
            `ASSERT((value === request2), "Failed to read correct agent 2 value");
            `ASSERT((collision1 === 2), "Expect collision is equal 2 for agent 1");
            `ASSERT((collision2 === 2), "Expect collision is equal 2 for agent 2");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 4 ------")

        `INFO("Both read agent access two different addresses");
        `INFO("Both agent should read a correct value without collision asserted");

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr1;
            logic [ADDR_WIDTH-1:0] addr2;
            logic [DATA_WIDTH-1:0] value;
            logic [DATA_WIDTH-1:0] value1;
            logic [DATA_WIDTH-1:0] value2;
            addr1 = pickRandomAddr();
            addr2 = addr1 + 3;
            value1 = $urandom();
            value2 = $urandom();
            writeAgent(AGENT1, addr1, value1);
            writeAgent(AGENT1, addr2, value2);
            readAgent(AGENT1, addr1, request1, collision);
            `ASSERT((value1 === request1), "Failed to read correct agent 1 value");
            `ASSERT((collision1 === 0), "Expect collision is equal 0 for agent 1");
            readAgent(AGENT2, addr2, request2, collision);
            `ASSERT((value2 === request2), "Failed to read correct agent 2 value");
            `ASSERT((collision2 === 0), "Expect collision is equal 0 for agent 2");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 5 ------")

        `INFO("Both read agent access the same block, but different address.");
        `INFO("Only agent 1 should read a correct value.");

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr1;
            logic [ADDR_WIDTH-1:0] addr2;
            logic [DATA_WIDTH-1:0] value;
            logic [DATA_WIDTH-1:0] value1;
            logic [DATA_WIDTH-1:0] value2;
            addr1 = pickRandomAddr();
            addr2 = addr1 + 1;
            value1 = $urandom();
            writeAgent(AGENT1, addr1, value1);
            value2 = $urandom();
            writeAgent(AGENT1, addr2, value2);
            readConcurrentAgents(addr1, addr2,
                                 request1, request2, collision1, collision2);
            `ASSERT((value1 === request1));
            `ASSERT((value2 !== request2));
            `ASSERT((collision1 === 2));
            `ASSERT((collision2 === 2));
        end

    `UNIT_TEST_END
`TEST_SUITE_END
