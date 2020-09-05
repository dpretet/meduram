`include "svut_h.sv"

`timescale 1 ns / 100 ps
`default_nettype none

module top_2w_2r_unit_test;

    `SVUT_SETUP

    parameter ADDR_WIDTH = 3;
    parameter RAM_DEPTH = 2**ADDR_WIDTH;
    parameter DATA_WIDTH = 8;

    parameter ALL = 0;
    parameter AGENT1 = 1;
    parameter AGENT2 = 2;
    parameter MAX_TEST_RUN = 4;
    // Enable write collision support
    parameter WRITE_COLLISION = 1;
    // Enable read collision support
    parameter READ_COLLISION = 1;

    reg                   aclk;
    reg                   aresetn;
    reg                   wren1;
    reg  [ADDR_WIDTH-1:0] wraddr1;
    reg  [DATA_WIDTH-1:0] wrdata1;
    reg                   wren2;
    reg  [ADDR_WIDTH-1:0] wraddr2;
    reg  [DATA_WIDTH-1:0] wrdata2;
    reg                   rden1;
    reg  [ADDR_WIDTH-1:0] rdaddr1;
    wire [DATA_WIDTH-1:0] rddata1;
    wire [           1:0] rdcollision1;
    reg                   rden2;
    reg  [ADDR_WIDTH-1:0] rdaddr2;
    wire [DATA_WIDTH-1:0] rddata2;
    wire [           1:0] rdcollision2;

    logic [DATA_WIDTH-1:0] value;
    integer               request;
    integer               request1;
    integer               request2;
    integer               collision;
    integer               collision1;
    integer               collision2;

    `include "functions.sv"

    top
    #(
    ADDR_WIDTH,
    RAM_DEPTH,
    DATA_WIDTH,
    WRITE_COLLISION,
    READ_COLLISION
    )
    dut
    (
    aclk,
    aresetn,
    wren1,
    wraddr1,
    wrdata1,
    wren2,
    wraddr2,
    wrdata2,
    rden1,
    rdaddr1,
    rddata1,
    rdcollision1,
    rden2,
    rdaddr2,
    rddata2,
    rdcollision2
    );

    initial aclk = 0;
    always #2 aclk <= ~aclk;

    task setup(msg="");
    begin
        aresetn = 1'b0;
        wren1 = 1'b0;
        wraddr1 = {ADDR_WIDTH{1'b0}};
        wrdata1 = {DATA_WIDTH{1'b0}};
        wren2 = 1'b0;
        wraddr2 = {ADDR_WIDTH{1'b0}};
        wrdata2 = {DATA_WIDTH{1'b0}};
        rden1 = 1'b0;
        rdaddr1 = {ADDR_WIDTH{1'b0}};
        rden2 = 1'b0;
        rdaddr2 = {ADDR_WIDTH{1'b0}};
        # 10;
        aresetn = 1'b1;
        repeat (4) @ (posedge aclk);
    end
    endtask

    task teardown(msg="");
    begin
        wren1 = 1'b0;
        wren2 = 1'b0;
        rden1 = 1'b0;
        rden2 = 1'b0;
        repeat (4) @ (posedge aclk);
    end
    endtask

    `TEST_SUITE("MEDURAM TEST_SUITE")

    `UNIT_TEST("------ TEST 1 ------")

        `INFO("Write then Read some dummy words");


        value = $urandom();
        writeAgent(AGENT1, 0, value);
        readAgent(AGENT1, 0, request, collision);
        `ASSERT((request === value), "Don't read expected value");
        `ASSERT((collision === 0), "Doesn't expect collision");

        value = $urandom();
        writeAgent(AGENT1, RAM_DEPTH/4, value);
        readAgent(AGENT2, RAM_DEPTH/4, request, collision);
        `ASSERT((request === value), "Don't read expected value");
        `ASSERT((collision === 0), "Doesn't expect collision");

        value = $urandom();
        writeAgent(AGENT2, RAM_DEPTH/2, value);
        readAgent(AGENT1, RAM_DEPTH/2, request, collision);
        `ASSERT((request === value), "Don't read expected value");
        `ASSERT((collision === 0), "Doesn't expect collision");

        value = $urandom();
        writeAgent(AGENT2, RAM_DEPTH-1, value);
        readAgent(AGENT2, RAM_DEPTH-1, request, collision);
        `ASSERT((request === value), "Don't read expected value");
        `ASSERT((collision === 0), "Doesn't expect collision");

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 2 ------")

        `INFO("Parse lineary the memory with a single agent pair (1/1)");

        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            value = $urandom();
            writeAgent(AGENT1, addr, value);
            readAgent(AGENT1, addr, request, collision);
            `ASSERT((request === value), "Don't read expected value");
        `ASSERT((collision === 0), "Expect collision is equal 0 for agent 1");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 3 ------")

        `INFO("Parse lineary the memory with a single agent pair (2/2)");

        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            value = $urandom();
            writeAgent(AGENT2, addr, value);
            readAgent(AGENT2, addr, request, collision);
            `ASSERT((request === value), "Don't read expected value");
            `ASSERT((collision === 0), "Expect collision is equal 0 for agent 1");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 4 ------")

        `INFO("Parse lineary the memory with a single agent pair (1/2)");

        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            value = $urandom();
            writeAgent(AGENT1, addr, value);
            readAgent(AGENT2, addr, request, collision);
            `ASSERT((request === value), "Don't read expected value");
            `ASSERT((collision === 0), "Expect collision is equal 0 for agent 1");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 5 ------")

        `INFO("Parse lineary the memory with a single agent pair (2/1)");

        for (int addr=0; addr<RAM_DEPTH; addr=addr+1) begin
            value = $urandom();
            writeAgent(AGENT2, addr, value);
            readAgent(AGENT1, addr, request, collision);
            `ASSERT((request === value), "Error! Should fetch a beef...");
            `ASSERT((collision === 0), "Expect collision is equal 0 for agent 1");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 6 ------")

        `INFO("Parse randomly the memory with random agent pair");

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
            readAgent(rix, addr, request, collision);
            `ASSERT((request === value), "Don't read expected value");
            `ASSERT((collision === 0), "Expect collision is equal 0 for agent 1");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 7 ------")

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

    `UNIT_TEST("------ TEST 9 ------")

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

    `UNIT_TEST("------ TEST 10 ------")

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

    `UNIT_TEST("------ TEST 12 ------")

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
            `ASSERT((collision === 0), "Expect collision is equal 0 for agent 1");
            readAgent(AGENT2, addr2, request2, collision);
            `ASSERT((value2 === request2), "Failed to read correct agent 2 value");
            `ASSERT((collision === 0), "Expect collision is equal 0 for agent 2");
        end

    `UNIT_TEST_END

    `UNIT_TEST("------ TEST 13 ------")

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

endmodule

`resetall
