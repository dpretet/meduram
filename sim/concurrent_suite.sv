`TEST_SUITE("ADVANCED SUITE - CONCURRENT ACCESS")

    `UNIT_TEST("Concurrent write access to same address");

        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            logic [ADDR_WIDTH-1:0] addr;
            logic [DATA_WIDTH-1:0] value;
            addr = pickRandomAddr();
            value = $urandom();
            fork
                begin
                    writeAgent(AGENT1, addr, value);
                end
                begin
                    writeAgent(AGENT2, addr, value);
                end
            join
            readAgent(AGENT1, addr, request);
            `ASSERT((request === value));
        end

    `UNIT_TEST_END

`TEST_SUITE_END
