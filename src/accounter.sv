// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// Accounter monitors the write operations to store which master agent
// last accessed a memory row. When a read agent accesses a memory row,
// the accounter uses this information to control the multiplexer and
// choose the right memory bank.
// Internally, the accounter uses FFDs to store this information.

`timescale 1 ns / 100 ps
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
        // Enable write collision support
        parameter WRITE_COLLISION = 1,
        // Width of the read selector to use output mux
        parameter SELECT_WIDTH = NB_WRAGENT == 1 ?
                                 1 + WRITE_COLLISION :
                                 $clog2(NB_WRAGENT) + WRITE_COLLISION
    )(
        input  wire                             aclk,
        input  wire                             aresetn,
        input  wire [           NB_WRAGENT-1:0] wren,
        input  wire [NB_WRAGENT*ADDR_WIDTH-1:0] wraddr,
        input  wire                             rden,
        input  wire [           ADDR_WIDTH-1:0] rdaddr,
        output wire [         SELECT_WIDTH-1:0] bank_select
    );

    logic [SELECT_WIDTH*RAM_DEPTH-1:0] cells;
    logic [             RAM_DEPTH-1:0] cells_collision;

    generate if (WRITE_COLLISION) begin
        genvar cix;
        for (cix=0;cix<RAM_DEPTH; cix=cix+1) begin
            write_collision #(
                .ADDR_WIDTH     (ADDR_WIDTH),
                .NB_WRAGENT     (NB_WRAGENT)
            ) collision_inst (
                .aclk       (aclk),
                .aresetn    (aresetn),
                .cell_addr  (cix[ADDR_WIDTH-1:0]),
                .wren       (wren),
                .wraddr     (wraddr),
                .collision  (cells_collision[cix])
            );
        end
    end
    endgenerate

    // Write monitoring to store for each row the last agent
    // which updated the address
    always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == 1'b0) begin
            cells <= {SELECT_WIDTH*RAM_DEPTH{1'b0}};
        end else begin
            // Parse all active write agents and store into the cell
            // the one accessing the memory row. Write collision are not
            // addressed and last one parsed is considered as the winner.
            for (int cix=0;cix<RAM_DEPTH;cix=cix+1) begin
                for (int wix=0;wix<NB_WRAGENT;wix=wix+1) begin
                    if (wren[wix] == 1'b1 &&
                        wraddr[ADDR_WIDTH*wix+:ADDR_WIDTH] == cix[ADDR_WIDTH-1:0])
                        // Assign into the cells the write agent index
                        // if its address matches the cell index
                        if (WRITE_COLLISION)
                            cells[SELECT_WIDTH*cix+:SELECT_WIDTH] <= {cells_collision[cix], wix[SELECT_WIDTH-2:0]};
                        else
                            cells[SELECT_WIDTH*cix+:SELECT_WIDTH] <= wix[SELECT_WIDTH-1:0];
                end
            end
        end
    end
    // Drives bank_select with last agent index.
    assign bank_select = cells[SELECT_WIDTH*rdaddr+:SELECT_WIDTH];

endmodule

`resetall
