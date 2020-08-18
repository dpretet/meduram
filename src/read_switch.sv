// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

// This module aims to switch the different banks' output 
// and drives them to the read agents.

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
        // Enable write collision support
        parameter WRITE_COLLISION = 1,
        // Enable read collision support
        parameter READ_COLLISION = 1,
        // Width of the read selector to use output mux
        parameter SELECT_WIDTH = NB_WRAGENT == 1 ? 
                                 1 + WRITE_COLLISION : 
                                 $clog2(NB_WRAGENT) + WRITE_COLLISION
    )(
        input  wire                               aclk,
        input  wire                               aresetn,
        output wire [             NB_RDAGENT-1:0] s_rden,
        output wire [  NB_WRAGENT*ADDR_WIDTH-1:0] s_rdaddr,
        input  wire [  NB_WRAGENT*DATA_WIDTH-1:0] s_rddata,
        input  wire [NB_RDAGENT*SELECT_WIDTH-1:0] bank_select,
        input  wire [             NB_RDAGENT-1:0] m_rden,
        input  wire [  NB_RDAGENT*ADDR_WIDTH-1:0] m_rdaddr,
        output wire [  NB_RDAGENT*DATA_WIDTH-1:0] m_rddata,
        output wire [           NB_RDAGENT*2-1:0] m_rdcollision
    );

    genvar wrid, rdid;

    // Paramter to select the effective bank to select while MSB of bank select
    // determine if a write collision occured.  Mostly used in this module to
    // avoid cofusion when reading code and make it straight forward whatever
    // the collision mode activated.
    localparam SELECT_RANGE = WRITE_COLLISION ? 
                              SELECT_WIDTH-1 : SELECT_WIDTH;

    // This function used into the address switching circuit returns
    // the agent allowed to read a BRAM bank. The highest index
    // is the selected one when multiple agents try a concurrent access
    function [SELECT_RANGE:0] selectAgent;

        input [           SELECT_RANGE-1:0] idx; // Agent id
        input [             NB_RDAGENT-1:0] en; // Enable gathered
        input [NB_RDAGENT*SELECT_RANGE-1:0] select; // Select gathered 

        selectAgent = {SELECT_RANGE+1{1'b0}};

        for (int i=0;i<NB_RDAGENT;i=i+1) begin

            if (en[i] == 1'b1 && 
                select[SELECT_RANGE*i+:SELECT_RANGE] == idx[SELECT_RANGE-1:0])
                // Assert MSB to signify an agent has been selected. Else
                // we can't be sure it's not the default value 0.
                selectAgent = {1'b1, i[SELECT_RANGE-1:0]};
        end

    endfunction

    //-------------------------------------------------------------------------
    // ADDRESS SWITCHS:
    // Drives the address bus of bram banks based on selected agent request.
    // We need here an arbitration to select the appropriate source because
    // two agents can select the same bank at the same time.
    //-------------------------------------------------------------------------
    for (wrid=0; wrid<NB_WRAGENT; wrid=wrid+1) begin : ADDR_SWITCHS

        wire [SELECT_RANGE:0] agtSel;

        // Select the agent to drive the bram bank
        // MSB indicates the bram needs to be activated, LSBs are the agent id
        assign agtSel = selectAgent(wrid, m_rden, bank_select[0+:SELECT_RANGE]);

        // Switch enable and address. Enable only if is really selected
        assign s_rden[wrid] = agtSel[SELECT_RANGE] & 
                              m_rden[agtSel[SELECT_RANGE-1:0]];

        assign s_rdaddr[ADDR_WIDTH*wrid+:ADDR_WIDTH] = 
            m_rdaddr[ADDR_WIDTH*agtSel[SELECT_RANGE-1:0]+:ADDR_WIDTH];
    end

    //-------------------------------------------------------------------------
    // DATA SWITCHS:
    // Drives the read data to the agent, based on selected bank by accounter
    //-------------------------------------------------------------------------
    for (rdid=0; rdid<NB_RDAGENT; rdid=rdid+1) begin : DATA_SWITCHS

        logic [SELECT_WIDTH-1:0] dataSel;

        // Pipeline the selector while BRAM banks uses a FFDed output
        always @ (posedge aclk or negedge aresetn) begin
            if (aresetn == 1'b0)
                dataSel <= {SELECT_WIDTH{1'b0}};
            else
                // Select the bank select range associated to the read agent
                // and shrink up the bank index, thus remove the collision flag
                dataSel <= bank_select[SELECT_WIDTH*rdid+:SELECT_RANGE];
        end

        // Simply select the part to transmit to the agent.
        assign m_rddata[DATA_WIDTH*rdid+:DATA_WIDTH] = 
            s_rddata[DATA_WIDTH*dataSel[SELECT_RANGE-1:0]+:DATA_WIDTH];

        // Bit 0 propagates write collision flag
        if (WRITE_COLLISION) 
            assign m_rdcollision[rdid*2+0] = dataSel[SELECT_WIDTH-1];
        else 
            assign m_rdcollision[rdid*2+0] = 1'b0;

        // Bit 1 propagates read collision flag
        if (READ_COLLISION)
            assign m_rdcollision[rdid*2+1] = 1'b0;
        else
            assign m_rdcollision[rdid*2+1] = 1'b0;
    end

endmodule

`resetall
