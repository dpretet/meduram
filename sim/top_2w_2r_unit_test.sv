// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"

`timescale 1 ns / 1 ps

module top_2w_2r_unit_test;

    `SVUT_SETUP

    parameter ADDR_WIDTH = 9;
    parameter RAM_DEPTH = 2**ADDR_WIDTH;
    parameter DATA_WIDTH = 64;

    reg                   aclk;
    reg                   arstn;
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

    top
    #(
    ADDR_WIDTH,
    RAM_DEPTH,
    DATA_WIDTH
    )
    dut
    (
    aclk,
    arstn,
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

    // An example to create a clock
    initial aclk = 0;
    always #2 aclk <= ~aclk;

    // An example to dump data for visualization
    initial $dumpvars(0, top_2w_2r_unit_test);

    task setup();
    begin
        // setup() runs when a test begins
    end
    endtask

    task teardown();
    begin
        // teardown() runs when a test ends
    end
    endtask

    `TEST_SUITE("BASIC SUITE")

        /* Available macros:

               - `INFO("message"); Print a grey message
               - `SUCCESS("message"); Print a green message
               - `WARNING("message"); Print an orange message and increment warning counter
               - `CRITICAL("message"); Print an pink message and increment critical counter
               - `ERROR("message"); Print a red message and increment error counter
               - `FAIL_IF(aSignal); Increment error counter if evaluaton is positive
               - `FAIL_IF_NOT(aSignal); Increment error coutner if evaluation is false
               - `FAIL_IF_EQUAL(aSignal, 23); Increment error counter if evaluation is equal
               - `FAIL_IF_NOT_EQUAL(aSignal, 45); Increment error counter if evaluation is not equal
        */

        /* Available flag:

               - `LAST_STATUS: tied to 1 is last macros has been asserted, else tied to 0
        */

    `UNIT_TEST("BASIC TEST")

        `INFO("Start BASIC TEST");

        // Describe here the testcase scenario

        `INFO("Test done");

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule

