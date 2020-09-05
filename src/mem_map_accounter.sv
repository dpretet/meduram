// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// MemoryMapAccounter instantiates an accounter for each
// read agent. Each accounter monitors the write agents
// xfers to detect which one updated a row last.

`timescale 1 ns / 100 ps
`default_nettype none

module MemoryMapAccounter

    #(
        // Write/Read address width
        parameter ADDR_WIDTH = 3,
        // RAM depth
        parameter RAM_DEPTH = 2**ADDR_WIDTH,
        // Number of write agent
        parameter NB_WRAGENT = 2,
        // Number of read agent
        parameter NB_RDAGENT = 2,
        // Enable write collision support
        parameter WRITE_COLLISION = 1,
        // Width of the read selector to use output mux
        parameter SELECT_WIDTH = NB_WRAGENT == 1 ? 
                                 1 + WRITE_COLLISION : 
                                 $clog2(NB_WRAGENT) + WRITE_COLLISION
    )(
        input  wire                               aclk,
        input  wire                               aresetn,
        input  wire [             NB_WRAGENT-1:0] wren,
        input  wire [  NB_WRAGENT*ADDR_WIDTH-1:0] wraddr,
        input  wire [             NB_RDAGENT-1:0] rden,
        input  wire [  NB_RDAGENT*ADDR_WIDTH-1:0] rdaddr,
        output wire [NB_RDAGENT*SELECT_WIDTH-1:0] bank_select
    );

    genvar i;

    generate
        for (i=0; i<NB_RDAGENT; i=i+1) begin
            Accounter 
            #(
                .ADDR_WIDTH        (ADDR_WIDTH),
                .RAM_DEPTH         (RAM_DEPTH ),
                .NB_WRAGENT        (NB_WRAGENT),
                .WRITE_COLLISION   (WRITE_COLLISION),
                .SELECT_WIDTH      (SELECT_WIDTH)
            ) accounter_insts (
                .aclk        (aclk),
                .aresetn     (aresetn),
                .wren        (wren),
                .wraddr      (wraddr),
                .rden        (rden[i]),
                .rdaddr      (rdaddr[ADDR_WIDTH*i+:ADDR_WIDTH]),
                .bank_select (bank_select[SELECT_WIDTH*i+:SELECT_WIDTH])
            );
        end
    endgenerate

endmodule

`resetall
