`include "svut_h.sv"

`timescale 1 ns / 100 ps
`default_nettype none

module top_2w_2r_unit_test;

    `SVUT_SETUP

    parameter ADDR_WIDTH = 8;
    parameter RAM_DEPTH = 2**ADDR_WIDTH;
    parameter DATA_WIDTH = 32;

    parameter AGENT1 = 1;
    parameter AGENT2 = 2;

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

    // An example to create a clock
    initial aclk = 0;
    always #2 aclk <= ~aclk;

    // An example to dump data for visualization
    // 1 because we want only signals in level 1
    // of hierarchy, the design under test
    // initial $dumpvars(0, top_2w_2r_unit_test);

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

    task checkAgent(input integer agent);
        // Finish simulation if don't use a correct index
        if (agent > 2) begin
            `ERROR("No more than 2 agents are supported in this testbench");
            $finish;
        end
    endtask

    task writeAgent(input integer agent, input integer addr, input integer data);
    begin
        string msg;
        $sformat(msg, "Write access start with agent %0d", agent);
        `INFO(msg);
        checkAgent(agent);

        // Wait for posedge and write a data into memory
        @ (posedge aclk);
        if (agent == AGENT1) begin
            wren1 = 1'b1;
            wraddr1 = addr;
            wrdata1 = data;
        end else if (agent == AGENT2) begin
            wren2 = 1'b1;
            wraddr2 = addr;
            wrdata2 = data;
        end

        // Deassert the xfer after one cycle
        @ (posedge aclk);
        if (agent == AGENT1) wren1 = 1'b0;
        else if (agent == AGENT2) wren2 = 1'b0;
        `INFO("Write access done");
    end
    endtask

    task readAgent(input integer agent, input integer addr, output integer value);
    begin
        string msg;
        $sformat(msg, "Read access start with agent %d", agent);
        `INFO(msg);
        checkAgent(agent);

        // Wait for posedge and read a memory address
        @ (posedge aclk);
        if (agent == AGENT1) begin
            rden1 = 1'b1;
            rdaddr1 = addr;
        end else if (agent == AGENT2) begin
            rden2 = 1'b1;
            rdaddr2 = addr;
        end

        // Deassert the request and read data
        @ (posedge aclk);
        if (agent == AGENT1) begin
            rden1 = 1'b0;
            value = rddata1;
        end else if (agent == AGENT2) begin
            rden2 = 1'b0;
            value = rddata2;
        end
        `INFO("Read access done");
    end
    endtask

    `TEST_SUITE("BASIC SUITE")

    `UNIT_TEST("Write then Read a BEEF")

        writeAgent(AGENT2, 100, 32'hBEEF);
        readAgent(AGENT2, 100, request);
        @(posedge aclk);
        // string msg = {"Request: %x", request};
        `ASSERT(request == 32'hBEEF, "Error! Should fetch a beef...");

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule

`resetall
