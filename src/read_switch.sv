// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// This module aims to switch the different banks' output 
// to the read agents.

`timescale 1 ns / 100 ps
`default_nettype none

module ReadSwitch

    #(
        // Write/Read address width
        parameter ADDR_WIDTH = 8,
        // Data Width in bits
        parameter DATA_WIDTH = 32,
        // Number of write agent, thus number of bank
        parameter NB_WRAGENT = 2,
        // Number of read agent
        parameter NB_RDAGENT = 2,
        // Width of the read selector to use output mux
        parameter SELECT_WIDTH = NB_WRAGENT == 1 ? 1 : $clog2(NB_WRAGENT)
    )(
        input  wire                               aclk,
        input  wire                               aresetn,
        output wire [             NB_RDAGENT-1:0] s_rden,
        output wire [  NB_WRAGENT*ADDR_WIDTH-1:0] s_rdaddr,
        input  wire [  NB_WRAGENT*DATA_WIDTH-1:0] s_rddata,
        input  wire [NB_RDAGENT*SELECT_WIDTH-1:0] rdselect,
        input  wire [             NB_RDAGENT-1:0] m_rden,
        input  wire [  NB_RDAGENT*ADDR_WIDTH-1:0] m_rdaddr,
        output wire [  NB_RDAGENT*DATA_WIDTH-1:0] m_rddata
    );

    genvar wrid, rdid;

    // Round robin arbiter to select the appropriate address 
    // to route to a memory bank
    function [SELECT_WIDTH:0] selectAgent;

        input [SELECT_WIDTH-1:0] idx;   // Agent id
        input [NB_RDAGENT-1:0] en;      // All enable gathered
        input [NB_RDAGENT*SELECT_WIDTH-1:0] select; //  All select gathered 

        selectAgent = {SELECT_WIDTH+1{1'b0}};
        for (int i=0;i<NB_RDAGENT;i=i+1) begin

            if (en[i] == 1'b1 && 
                select[SELECT_WIDTH*i+:SELECT_WIDTH] == idx[SELECT_WIDTH-1:0])
                // Assert MSB to signify an agent has been selected. Else
                // we can't be sure it's not the default value 0.
                selectAgent = {1'b1, i[SELECT_WIDTH-1:0]};
        end

    endfunction

    // Drives the address bus of bram banks based on selected agent request.
    // We need here an arbitration to select the appropriate source because
    // two agents can select the same bank at the same time.
    for (wrid=0; wrid<NB_WRAGENT; wrid=wrid+1) begin : ADDR_SWITCHS
        // Select the agent to drive the bram bank
        // MSB indicates the bram needs to be activated, LSBs are the agent id
        wire [SELECT_WIDTH:0] agtSel;
        assign agtSel = selectAgent(wrid, m_rden, rdselect);
        // Switch enable and address. Enable only if is really selected
        assign s_rden[wrid] = agtSel[SELECT_WIDTH] & m_rden[agtSel[SELECT_WIDTH-1:0]];
        assign s_rdaddr[ADDR_WIDTH*wrid+:ADDR_WIDTH] = 
            m_rdaddr[ADDR_WIDTH*agtSel[SELECT_WIDTH-1:0]+:ADDR_WIDTH];
    end

    // Drives the read data to the agent based on selected bank by accounter
    for (rdid=0; rdid<NB_RDAGENT; rdid=rdid+1) begin : DATA_SWITCHS

        // Pipeline the selector while BRAM banks uses a FFDed output
        logic [SELECT_WIDTH-1:0] dataSel;
        always @ (posedge aclk or negedge aresetn) begin
            if (aresetn == 1'b0)
                dataSel <= {SELECT_WIDTH{1'b0}};
            else
                dataSel <= rdselect[SELECT_WIDTH*rdid+:SELECT_WIDTH];
        end
        // Simply select the part to transmit to the agent. Pipelining is
        // applied in upper layer of the hierarchy.
        assign m_rddata[DATA_WIDTH*rdid+:DATA_WIDTH] = 
            s_rddata[DATA_WIDTH*dataSel+:DATA_WIDTH];
    end

endmodule

`resetall
