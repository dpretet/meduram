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
        parameter SELECT_RANGE = 3
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

            if (NB_RDAGENT == 1) begin
                collisions[0] <= 1'b0;
            end

            if (NB_RDAGENT == 2) begin

                if (rdid != 0 && m_rden[0] &&
                    bank_select[0*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[0] <= 1'b1;
                else
                    collisions[0] <= 1'b0;

                if (rdid != 1 && m_rden[1] &&
                    bank_select[1*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[1] <= 1'b1;
                else
                    collisions[1] <= 1'b0;

            end

            if (NB_RDAGENT == 3) begin

                if (rdid != 0 && m_rden[0] &&
                    bank_select[0*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[0] <= 1'b1;
                else
                    collisions[0] <= 1'b0;

                if (rdid != 1 && m_rden[1] &&
                    bank_select[1*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[1] <= 1'b1;
                else
                    collisions[1] <= 1'b0;

                if (rdid != 2 && m_rden[2] &&
                    bank_select[2*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[2] <= 1'b1;
                else
                    collisions[2] <= 1'b0;
            end

            if (NB_RDAGENT == 4) begin

                if (rdid != 0 && m_rden[0] &&
                    bank_select[0*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[0] <= 1'b1;
                else
                    collisions[0] <= 1'b0;

                if (rdid != 1 && m_rden[1] &&
                    bank_select[1*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[1] <= 1'b1;
                else
                    collisions[1] <= 1'b0;

                if (rdid != 2 && m_rden[2] &&
                    bank_select[2*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[2] <= 1'b1;
                else
                    collisions[2] <= 1'b0;

                if (rdid != 3 && m_rden[3] &&
                    bank_select[3*SELECT_WIDTH+:SELECT_RANGE] == bank_select[rdid*SELECT_WIDTH+:SELECT_RANGE])
                        collisions[3] <= 1'b1;
                else
                    collisions[3] <= 1'b0;
            end

        end
    end

    assign collision = |collisions;

endmodule

