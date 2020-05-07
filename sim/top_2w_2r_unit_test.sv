`include "svut_h.sv"

`timescale 1 ns / 100 ps
`default_nettype none

module top_2w_2r_unit_test;

    `SVUT_SETUP

    parameter ADDR_WIDTH = 8;
    parameter RAM_DEPTH = 2**ADDR_WIDTH;
    parameter DATA_WIDTH = 32;

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
    reg                   rden2;
    reg  [ADDR_WIDTH-1:0] rdaddr2;
    wire [DATA_WIDTH-1:0] rddata2;

    integer               request;

    `include "functions.sv"

    top
    #(
    ADDR_WIDTH,
    RAM_DEPTH,
    DATA_WIDTH
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
    rden2,
    rdaddr2,
    rddata2
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
    end
    endtask

    task teardown(msg="");
    begin
        wren1 = 1'b0;
        wren2 = 1'b0;
        rden1 = 1'b0;
        rden2 = 1'b0;
    end
    endtask

    `TEST_SUITE("BASIC SUITE")

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

    // `UNIT_TEST

    // `UNIT_TEST_END

    `TEST_SUITE_END

endmodule

`resetall
