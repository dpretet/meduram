// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// This module aims to switch the different banks' output 
// to the read agents.

`default_nettype none

module ReadSwitch

    #(
    // Write/Read address width
    parameter ADDR_WIDTH = 8,
    // Data Width in bits
    parameter DATA_WIDTH = 64,
    // Number of write agent, thus number of bank
    parameter NB_WRAGENT = 2,
    // Number of read agent
    parameter NB_RDAGENT = 2,
    // Width of the read selector to use output mux
    parameter SELECT_WIDTH = 1 ? 1 : $clog2(NB_WRAGENT)
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

    genvar wr, rd;
    
    // Round robin arbiter to select the appropriate address 
    // to route to a memory bank
    function [SELECT_WIDTH:0] selectAgent;
        
        input [SELECT_WIDTH-1:0] idx;   // Agent id
        input [NB_RDAGENT-1:0] en;      // All enable gathered
        input [NB_RDAGENT*SELECT_WIDTH-1:0] select; //  All select gathered 

        selectAgent = 0;
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
    // two agents can select the same bank at the same time. The collision
    // is not handled here but at AXI level.
    for (wr=0; wr<NB_WRAGENT; wr=wr+1) begin : ADDR_SWITCHS
        // Select the agent to drive the bram bank
        wire [SELECT_WIDTH:0] agtSel;
        assign agtSel = selectAgent(wr, m_rden, rdselect);
        // Switch enable and address
        assign s_rden[wr] = agtSel[SELECT_WIDTH] & m_rden[agtSel[SELECT_WIDTH-1:0]];
        assign s_rdaddr[ADDR_WIDTH*wr+:ADDR_WIDTH] = 
            m_rdaddr[ADDR_WIDTH*agtSel+:ADDR_WIDTH];
    end

    // Drives the read data to the agent based on selected bank by accounter
    for (rd=0; rd<NB_RDAGENT; rd=rd+1) begin : DATA_SWITCHS
        
        // Pipeline the selector while BRAM banks uses a FFDed output
        logic [SELECT_WIDTH-1:0] dataSel;
        always @ (posedge aclk or negedge aresetn) begin
            if (aresetn == 1'b0)
                dataSel <= {SELECT_WIDTH{1'b0}};
            else
                dataSel <= rdselect[SELECT_WIDTH*rd+:SELECT_WIDTH];
        end
        // Simply select the part to transmit to the agent. Pipelining is
        // applied in upper layer of the hierarchy.
        assign m_rddata[DATA_WIDTH*rd+:DATA_WIDTH] = 
            s_rddata[DATA_WIDTH*dataSel+:DATA_WIDTH];
    end
    
endmodule

`resetall
