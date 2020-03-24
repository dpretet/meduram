// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// A dual port block RAM inference core. Both write and read port
// use an independent clock.

`default_nettype none

module Bram

    #(
    // Addr Width in bits
    parameter ADDR_WIDTH = 9,
    // RAM depth
    parameter RAM_DEPTH = 2**ADDR_WIDTH,
    // Data Width in bits
    parameter DATA_WIDTH = 8,
    // Specify number of output FFD (0 or 1) for read channel
    parameter READ_NB_FFD = 1
    )(
    input  wire                   wrclk,
    input  wire                   wren,
    input  wire  [ADDR_WIDTH-1:0] wraddr,
    input  wire  [DATA_WIDTH-1:0] wrdata,
    input  wire                   rdclk,
    input  wire                   rden,
    input  wire  [ADDR_WIDTH-1:0] rdaddr,
    output logic [DATA_WIDTH-1:0] rddata
    );

    logic [DATA_WIDTH-1:0] ram [0:RAM_DEPTH-1];

    always @ (posedge wrclk) begin
        if (wren == 1'b1) begin
            ram[wraddr] <= wrdata;
        end
    end

    generate
        if (READ_NB_FFD == 0) 
            assign rddata = ram[rdaddr];
        else if (READ_NB_FFD == 1) 
            always @ (posedge rdclk) begin
                if (rden == 1'b1) begin
                    rddata <= ram[rdaddr];
                end
            end
        `ifdef FORMAL
        else
            // Can't support biggest number of FFD
            assert property (READ_NB_FFD <= 1);
        `endif 
    endgenerate

endmodule

`resetall
