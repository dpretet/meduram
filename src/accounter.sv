// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// Accounter monitors the write operations to store which master agent
// last accessed a memory row. When a read agent accesses a memory row,
// the accounter uses this information to control the multiplexer and
// choose the right memory bank.
// Internally, the accounter uses a bram to store this information, a bram
// with the same depth than wr agent memory bank.

`default_nettype none

module Accounter

    #(
        // Write/Read address width
        parameter ADDR_WIDTH = 8,
        // RAM depth
        parameter RAM_DEPTH = 2**ADDR_WIDTH,
        // Number of write agent
        parameter NB_WRAGENT = 2,
        // Number of read agent
        parameter NB_RDAGENT = 2,
        // Width of the read selector to use output mux
        parameter SELECT_WIDTH = $clog2(NB_WRAGENT)
    )(
        input  wire                               aclk,
        input  wire                               aresetn,
        input  wire [             NB_WRAGENT-1:0] wren,
        input  wire [  NB_WRAGENT*ADDR_WIDTH-1:0] wraddr,
        input  wire                               rden,
        input  wire [             ADDR_WIDTH-1:0] rdaddr,
        output wire [           SELECT_WIDTH-1:0] rdselect
    );

    logic [SELECT_WIDTH*RAM_DEPTH-1:0] cells;

    // assign rdselect = {SELECT_WIDTH{1'b0}};

    // Write monitoring to store for each row the last agent
    // which updated the address
    always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == 1'b0) begin
            cells <= {SELECT_WIDTH*RAM_DEPTH{1'b0}};
        end else begin
            // Parse all active write agents and store into the cell
            // the one accessing the memory row. Write collision are not
            // addressed and last one parsed is considered as the winner.
            for (int ix=0;ix<RAM_DEPTH-1;ix=ix+1) begin
                for (int i=0;i<NB_WRAGENT;i=i+1) begin
                    if (wren[i] == 1'b1 &&
                        wraddr[ADDR_WIDTH*i+:ADDR_WIDTH] == ix[ADDR_WIDTH-1:0])
                        cells[ix] <= i[SELECT_WIDTH-1:0];
                end
            end
        end
    end
    // Drives rdselect with last agent index.
    assign rdselect = cells[SELECT_WIDTH*rdaddr+:SELECT_WIDTH];

endmodule

`resetall