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
    parameter ADDR_WIDTH = 0,
    // RAM depth
    parameter RAM_DEPTH = 2**ADDR_WIDTH,
    // Number of write agent
    parameter NB_WRAGENT = 2,
    // Width of the read selector to use output mux
    parameter SELECT_WIDTH = $clog2(NB_WRAGENT)
    )(
    input  wire                    aclk,
    input  wire                    aresetn,
    input  wire                    wren,
    input  wire [  ADDR_WIDTH-1:0] wraddr,
    input  wire                    rden,
    input  wire [  ADDR_WIDTH-1:0] rdaddr,
    output wire [SELECT_WIDTH-1:0] rdselect
    );

    assign rdselect = {SELECT_WIDTH{1'b0}};

endmodule

`resetall
