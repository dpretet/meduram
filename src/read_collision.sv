// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// This module checks if multiple read agents access
// the same memory bank at the same moment to detect
// read collision

`timescale 1 ns / 100 ps
`default_nettype none

module ReadCollision

    #(
        parameter NB_RDAGENT = 2,
        parameter WRITE_COLLISION = 1,
        parameter SELECT_WIDTH = 4,
        parameter SELECT_RANGE = 4
    )(
        input  wire                               aclk,
        input  wire                               aresetn,
        input  wire [     $clog2(NB_RDAGENT)-1:0] rdid,
        input  wire [NB_RDAGENT*SELECT_WIDTH-1:0] bank_select,
        input  wire [             NB_RDAGENT-1:0] m_rden,
        output wire                               collision
    );

    logic [NB_RDAGENT-1:0] collisions;

    always @ (posedge aclk or negedge aresetn) begin

        if (aresetn == 1'b0) begin
            collisions <= {NB_RDAGENT{1'b0}};
        end else begin
            for (int i=0; i<NB_RDAGENT; i=i+1) begin
                if (i != rdid) begin
                    if (m_rden[i] && 
                        bank_select[i*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[i] <= 1'b1;
                end else begin
                    collisions[i] <= 1'b0;
                end
            end
        end
    end

    assign collision = |collisions;

endmodule

