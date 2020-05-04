// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// BramBank instantiates all necessary banks associated
// to every single write agent.

`default_nettype none

module BramBank

    #(
    // Number of write agent, thus number of bank
    parameter NB_WRAGENT = 2,
    // Addr Width in bits
    parameter ADDR_WIDTH = 8,
    // RAM depth
    parameter RAM_DEPTH = 2**ADDR_WIDTH,
    // Data Width in bits
    parameter DATA_WIDTH = 32
    )(
    // Write Port
    input  wire                             wrclk,
    input  wire [           NB_WRAGENT-1:0] wren,
    input  wire [ADDR_WIDTH*NB_WRAGENT-1:0] wraddr,
    input  wire [DATA_WIDTH*NB_WRAGENT-1:0] wrdata,
    // Read  Port
    input  wire                             rdclk,
    input  wire [           NB_WRAGENT-1:0] rden,
    input  wire [ADDR_WIDTH*NB_WRAGENT-1:0] rdaddr,
    output wire [DATA_WIDTH*NB_WRAGENT-1:0] rddata
    );

    generate
        genvar i;
        for (i=0;i<NB_WRAGENT;i=i+1) begin : RAMS_INST

            Bram 
            #(
            .ADDR_WIDTH (ADDR_WIDTH),
            .RAM_DEPTH  (RAM_DEPTH),
            .DATA_WIDTH (DATA_WIDTH)
            ) bank_inst (
            .wrclk    (wrclk),
            .wren     (wren[i]),
            .wraddr   (wraddr[ADDR_WIDTH*i+:ADDR_WIDTH]),
            .wrdata   (wrdata[DATA_WIDTH*i+:DATA_WIDTH]),
            .rdclk    (rdclk),
            .rden     (rden[i]),
            .rdaddr   (rdaddr[ADDR_WIDTH*i+:ADDR_WIDTH]),
            .rddata   (rddata[DATA_WIDTH*i+:DATA_WIDTH])
            );
        end
    endgenerate

endmodule

`resetall
