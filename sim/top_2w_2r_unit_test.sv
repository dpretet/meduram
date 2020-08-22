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

    // `include "sequential_suite.sv"

    `include "concurrent_suite.sv"

endmodule

`resetall
