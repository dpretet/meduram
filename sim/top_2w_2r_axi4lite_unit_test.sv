// copyright damien pretet 2020
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

/// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"

`timescale 1 ns / 100 ps

module top_2w_2r_axi4lite_unit_test();

    `SVUT_SETUP

    parameter ADDR_WIDTH = 3;
    parameter RAM_DEPTH = 2**ADDR_WIDTH;
    parameter DATA_WIDTH = 8;
    parameter WRITE_COLLISION = 1;
    parameter READ_COLLISION = 1;

    reg                     aclk_core;
    reg                     aresetn_core;
    reg                     aclk_wr1;
    reg                     aresetn_wr1;
    reg                     awvalid1;
    wire                    awready1;
    reg  [  ADDR_WIDTH-1:0] awaddr1;
    reg  [           2-1:0] awprot1;
    reg                     wvalid1;
    wire                    wready1;
    reg  [  DATA_WIDTH-1:0] wdata1;
    reg  [DATA_WIDTH/8-1:0] wstrb1;
    wire                    bvalid1;
    reg                     bready1;
    wire [           2-1:0] bresp1;
    reg                     aclk_wr2;
    reg                     aresetn_wr2;
    reg                     awvalid2;
    wire                    awready2;
    reg  [  ADDR_WIDTH-1:0] awaddr2;
    reg  [           2-1:0] awprot2;
    reg                     wvalid2;
    wire                    wready2;
    reg  [  DATA_WIDTH-1:0] wdata2;
    reg  [DATA_WIDTH/8-1:0] wstrb2;
    wire                    bvalid2;
    reg                     bready2;
    wire [           2-1:0] bresp2;
    reg                     aclk_rd1;
    reg                     aresetn_rd1;
    reg                     arvalid1;
    wire                    arready1;
    reg  [  ADDR_WIDTH-1:0] araddr1;
    reg  [           2-1:0] arprot1;
    wire                    rvalid1;
    reg                     rready1;
    wire [  DATA_WIDTH-1:0] rdata1;
    wire [           2-1:0] rresp1;
    reg                     aclk_rd2;
    reg                     aresetn_rd2;
    reg                     arvalid2;
    wire                    arready2;
    reg  [  ADDR_WIDTH-1:0] araddr2;
    reg  [           2-1:0] arprot2;
    wire                    rvalid2;
    reg                     rready2;
    wire [  DATA_WIDTH-1:0] rdata2;
    wire [           2-1:0] rresp2;

    integer addr;
    integer data;
    integer rdata;
    integer resp;

    initial begin
        $dumpfile("top_2w_2r_axi4lite_unit_test.vcd");
        $dumpvars(0, top_2w_2r_axi4lite_unit_test);
    end

    `include "amba_tasks.sv"

    top_axi4lite
    #(
    ADDR_WIDTH,
    RAM_DEPTH,
    DATA_WIDTH,
    WRITE_COLLISION,
    READ_COLLISION
    )
    dut
    (
    aclk_core,
    aresetn_core,
    aclk_wr1,
    aresetn_wr1,
    awvalid1,
    awready1,
    awaddr1,
    awprot1,
    wvalid1,
    wready1,
    wdata1,
    wstrb1,
    bvalid1,
    bready1,
    bresp1,
    aclk_wr2,
    aresetn_wr2,
    awvalid2,
    awready2,
    awaddr2,
    awprot2,
    wvalid2,
    wready2,
    wdata2,
    wstrb2,
    bvalid2,
    bready2,
    bresp2,
    aclk_rd1,
    aresetn_rd1,
    arvalid1,
    arready1,
    araddr1,
    arprot1,
    rvalid1,
    rready1,
    rdata1,
    rresp1,
    aclk_rd2,
    aresetn_rd2,
    arvalid2,
    arready2,
    araddr2,
    arprot2,
    rvalid2,
    rready2,
    rdata2,
    rresp2
    );

    initial begin
        aclk_core = 0;
        aclk_wr1 = 0;
        aclk_wr2 = 0;
        aclk_rd1 = 0;
        aclk_rd2 = 0;
    end

    always #2 aclk_core <= ~aclk_core;
    always #2 aclk_wr1 <= ~aclk_wr1;
    always #2 aclk_wr2 <= ~aclk_wr2;
    always #2 aclk_rd1 <= ~aclk_rd1;
    always #2 aclk_rd2 <= ~aclk_rd2;

    /// An example to dump data for visualization
    /// initial begin
    ///     $dumpfile("waveform.vcd");
    ///     $dumpvars(0, top_axi4lite_testbench);
    /// end

    task setup(msg="");
    begin
        aresetn_core = 0;
        aresetn_wr1 = 0;
        aresetn_wr2 = 0;
        aresetn_rd1 = 0;
        aresetn_rd2 = 0;
        awvalid1 = 0;
        awaddr1 = 0;
        awprot1 = 0;
        wvalid1 = 0;
        wdata1 = 0;
        wstrb1 = 0;
        bready1 = 0;
        awvalid2 = 0;
        awaddr2 = 0;
        awprot2 = 0;
        wvalid2 = 0;
        wdata2 = 0;
        wstrb2 = 0;
        bready2 = 0;
        arvalid1 = 0;
        araddr1 = 0;
        arprot1 = 0;
        rready1 = 0;
        arvalid2 = 0;
        araddr2 = 0;
        arprot2 = 0;
        rready2 = 0;
        #10;
        aresetn_core = 1;
        aresetn_wr1 = 1;
        aresetn_wr2 = 1;
        aresetn_rd1 = 1;
        aresetn_rd2 = 1;
        #10;
    end
    endtask

    task teardown(msg="");
    begin
        `INFO("Testcase finished");
        #10;
    end
    endtask

    `TEST_SUITE("AXI4-lite Testsuite")

    ///    Available macros:"
    ///
    ///    - `INFO("message"):      Print a grey message
    ///    - `SUCCESS("message"):   Print a green message
    ///    - `WARNING("message"):   Print an orange message and increment warning counter
    ///    - `CRITICAL("message"):  Print an pink message and increment critical counter
    ///    - `ERROR("message"):     Print a red message and increment error counter
    ///
    ///    - `FAIL_IF(aSignal):                 Increment error counter if evaluaton is true
    ///    - `FAIL_IF_NOT(aSignal):             Increment error coutner if evaluation is false
    ///    - `FAIL_IF_EQUAL(aSignal, 23):       Increment error counter if evaluation is equal
    ///    - `FAIL_IF_NOT_EQUAL(aSignal, 45):   Increment error counter if evaluation is not equal
    ///    - `ASSERT(aSignal):                  Increment error counter if evaluation is not true
    ///    - `ASSERT((aSignal == 0)):           Increment error counter if evaluation is not true
    ///
    ///    Available flag:
    ///
    ///    - `LAST_STATUS: tied to 1 is last macro did experience a failure, else tied to 0

    `UNIT_TEST("Write into port 1 then read")

        addr = $urandom();
        data = $urandom();

        @(posedge aclk_wr1);
        fork
            begin
                write_address(AGENT1, addr);
            end
            begin
                write_data(AGENT1, data);
            end
        join

        @(posedge aclk_wr1);

        disable_write_address(AGENT1);
        disable_write_data(AGENT1);

        @(posedge aclk_wr1);
        #10;

        @(posedge aclk_rd1);
        read_address(AGENT1, addr);

        @(posedge aclk_rd1);
        disable_read_address(AGENT1);

        wait(rvalid1);
        read_data(AGENT1, rdata, resp);
        `ASSERT(rdata === data);
        `ASSERT(resp === 0);
        @(posedge aclk_rd1);
        disable_read_data(AGENT1);
        #10;


    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
