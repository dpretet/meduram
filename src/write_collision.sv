// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// This module monitors two agents access the same address at the same time.
// It's a recursive module, instanciating new level until reaching a two inputs
// only configuration.

// Collision output is asserted when both agents are active and write the
// same address

`timescale 1 ns / 100 ps
`default_nettype none

module write_collision

    #(
        // Write/Read address width
        parameter ADDR_WIDTH = 8,
        // Number of write agent
        parameter NB_WRAGENT = 2
    )(
        input  wire                             aclk,
        input  wire                             aresetn,
        input  wire [           ADDR_WIDTH-1:0] cell_addr,
        input  wire [           NB_WRAGENT-1:0] wren,
        input  wire [NB_WRAGENT*ADDR_WIDTH-1:0] wraddr,
        output wire                             collision
    );

    logic collision0, collision1;

    generate

        if (NB_WRAGENT==2) begin

            assign collision0 = (wren[0] == 1'b1 &&
                                 wraddr[0+:ADDR_WIDTH] == cell_addr) ?
                                 1'b1 : 1'b0;

            assign collision1 = (wren[1] == 1'b1 &&
                                 wraddr[ADDR_WIDTH+:ADDR_WIDTH] == cell_addr) ?
                                 1'b1 : 1'b0;

            assign collision = collision0 & collision1;

        end else if (NB_WRAGENT % 2 != 0) begin

            assign collision0 = (wren[0] == 1'b1 &&
                                 wraddr[0+:ADDR_WIDTH] == cell_addr) ?
                                 1'b1 : 1'b0;

            write_collision #(
                ADDR_WIDTH,
                NB_WRAGENT-1
            ) inst1 (
                aclk,
                aresetn,
                cell_addr,
                wren[1+:NB_WRAGENT-1],
                wraddr[1*ADDR_WIDTH+:(NB_WRAGENT-1)*ADDR_WIDTH],
                collision1
            );

            assign collision = collision0 & collision1;

        end else begin

            write_collision #(
                ADDR_WIDTH,
                NB_WRAGENT/2
            ) inst0 (
                aclk,
                aresetn,
                cell_addr,
                wren[0+:NB_WRAGENT/2],
                wraddr[0+:(NB_WRAGENT/2)*ADDR_WIDTH],
                collision0
            );

            write_collision #(
                ADDR_WIDTH,
                NB_WRAGENT/2
            ) inst1 (
                aclk,
                aresetn,
                cell_addr,
                wren[NB_WRAGENT/2+:NB_WRAGENT/2],
                wraddr[(NB_WRAGENT/2)*ADDR_WIDTH+:(NB_WRAGENT/2)*ADDR_WIDTH],
                collision1
            );

            assign collision = collision0 & collision1;
        end
    endgenerate

endmodule

`resetall
