`TEST_SUITE("BASIC SUITE - NO CONCURRENT ACCESS")

    `UNIT_TEST("Write then Read some dummy words")
    
        writeAgent(AGENT1, 100, 32'h0000BEEF);
        readAgent(AGENT1, 100, request);
        `ASSERT((request === 32'h0000BEEF), "Error! Should fetch a beef...");
    
        writeAgent(AGENT1, 34, 32'h00001234);
        readAgent(AGENT2, 34, request);
        `ASSERT((request === 32'h00001234), "Error! Should fetch a 1234...");
    
        writeAgent(AGENT2, 0, 32'h00009876);
        readAgent(AGENT1, 0, request);
        `ASSERT((request === 32'h00009876), "Error! Should fetch 9876...");
    
        writeAgent(AGENT2, RAM_DEPTH-1, 32'hB00B);
        readAgent(AGENT2, RAM_DEPTH-1, request);
        `ASSERT((request === 32'h0000B00B), "Error! Should fetch a boob...");
    
    `UNIT_TEST_END
    
    `UNIT_TEST("Parse lineary the memory with a single agent pair (1/1)");
    
        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            logic [DATA_WIDTH-1:0] value;
            value = $urandom();
            writeAgent(AGENT1, addr, value);
            readAgent(AGENT1, addr, request);
            `ASSERT((request === value));
        end
    
    `UNIT_TEST_END
    
    `UNIT_TEST("Parse lineary the memory with a single agent pair (2/2)");
    
        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            logic [DATA_WIDTH-1:0] value;
            value = $urandom();
            writeAgent(AGENT2, addr, value);
            readAgent(AGENT2, addr, request);
            `ASSERT((request === value));
        end
    
    `UNIT_TEST_END
    
    `UNIT_TEST("Parse lineary the memory with a single agent pair (1/2)");
    
        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            logic [DATA_WIDTH-1:0] value;
            value = $urandom();
            writeAgent(AGENT1, addr, value);
            readAgent(AGENT2, addr, request);
            `ASSERT((request === value));
        end
    
    `UNIT_TEST_END
    
    `UNIT_TEST("Parse lineary the memory with a single agent pair (2/1)");
    
        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            logic [DATA_WIDTH-1:0] value;
            value = $urandom();
            writeAgent(AGENT2, addr, value);
            readAgent(AGENT1, addr, request);
            `ASSERT((request === value));
        end
    
    `UNIT_TEST_END
    
    `UNIT_TEST("Parse randomly the memory with random agent pair");
    
        for (int round=0; round<MAX_TEST_RUN; round=round+1) begin
            integer wix;
            integer rix;
            logic [ADDR_WIDTH-1:0] addr;
            logic [DATA_WIDTH-1:0] value;
            addr = pickRandomAddr();
            value = $urandom();
            wix = pickRandomAgent();
            rix = pickRandomAgent();
            writeAgent(wix, addr, value);
            readAgent(rix, addr, request);
            `ASSERT((request === value));
        end
    
    `UNIT_TEST_END

`TEST_SUITE_END
