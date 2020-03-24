// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

`default_nettype none

module top

    #(
    // Addr Width in bits
    parameter ADDR_WIDTH = 9,
    // RAM depth
    parameter RAM_DEPTH = 2**ADDR_WIDTH,
    // Data Width in bits
    parameter DATA_WIDTH = 64
    )(
    input  wire                  aclk,
    input  wire                  aresetn,
    input  wire                  wren1,
    input  wire [ADDR_WIDTH-1:0] wraddr1,
    input  wire [DATA_WIDTH-1:0] wrdata1,
    input  wire                  wren2,
    input  wire [ADDR_WIDTH-1:0] wraddr2,
    input  wire [DATA_WIDTH-1:0] wrdata2,
    input  wire                  rden1,
    input  wire [ADDR_WIDTH-1:0] rdaddr1,
    output wire [DATA_WIDTH-1:0] rddata1,
    input  wire                  rden2,
    input  wire [ADDR_WIDTH-1:0] rdaddr2,
    output wire [DATA_WIDTH-1:0] rddata2
    );

    localparam NB_WRAGENT   = 2;
    localparam NB_RDAGENT   = 2;
    localparam SELECT_WIDTH = NB_WRAGENT == 1 ? 1 : $clog2(NB_WRAGENT);

    // Interconnections on write sides of the bram banks
    wire [             NB_WRAGENT-1:0] wren;
    wire [  NB_WRAGENT*ADDR_WIDTH-1:0] wraddr;
    wire [NB_WRAGENT*DATA_WIDTH/8-1:0] wrbe;
    wire [  NB_WRAGENT*DATA_WIDTH-1:0] wrdata;
    wire [             NB_RDAGENT-1:0] rden;
    wire [  NB_RDAGENT*ADDR_WIDTH-1:0] rdaddr;
    wire [  NB_RDAGENT*DATA_WIDTH-1:0] rddata;
    wire [NB_RDAGENT*SELECT_WIDTH-1:0] rdselect;

    // Interconnections on read sides of the bram banks
    wire [             NB_WRAGENT-1:0] s_rden;
    wire [  NB_WRAGENT*ADDR_WIDTH-1:0] s_rdaddr;
    wire [  NB_WRAGENT*DATA_WIDTH-1:0] s_rddata;

    assign wren[0] = wren1;
    assign wren[1] = wren2;
    assign wraddr[0+:ADDR_WIDTH] = wraddr1;
    assign wraddr[ADDR_WIDTH+:ADDR_WIDTH] = wraddr2;
    assign wrdata[0+:DATA_WIDTH] = wrdata1;
    assign wrdata[DATA_WIDTH+:DATA_WIDTH] = wrdata2;

    assign rden[0] = rden1;
    assign rden[1] = rden2;
    assign rdaddr[0+:ADDR_WIDTH] = rdaddr1;
    assign rdaddr[ADDR_WIDTH+:ADDR_WIDTH] = rdaddr2;
    assign rddata1 = rddata[0+:DATA_WIDTH];
    assign rddata2 = rddata[DATA_WIDTH+:DATA_WIDTH];

    MemoryMapAccounter
    #(
    .ADDR_WIDTH   (ADDR_WIDTH),
    .RAM_DEPTH    (RAM_DEPTH),
    .NB_WRAGENT   (NB_WRAGENT),
    .NB_RDAGENT   (NB_RDAGENT),
    .SELECT_WIDTH (SELECT_WIDTH)
    ) mma_inst (
    .aclk       (aclk),
    .aresetn    (aresetn),
    .wren       (wren),
    .wraddr     (wraddr),
    .rden       (rden),
    .rdaddr     (rdaddr),
    .rdselect   (rdselect)
    );

    BramBank
    #(
    .NB_WRAGENT   (NB_WRAGENT),
    .ADDR_WIDTH   (ADDR_WIDTH),
    .RAM_DEPTH    (RAM_DEPTH),
    .DATA_WIDTH   (DATA_WIDTH)
    ) bb_inst (
    .wrclk      (aclk),
    .wren       (wren),
    .wraddr     (wraddr),
    .wrdata     (wrdata),
    .rdclk      (aclk),
    .rden       (s_rden),
    .rdaddr     (s_rdaddr),
    .rddata     (s_rddata)
    );

    ReadSwitch
    #(
    .ADDR_WIDTH   (ADDR_WIDTH),
    .DATA_WIDTH   (DATA_WIDTH),
    .NB_WRAGENT   (NB_WRAGENT),
    .NB_RDAGENT   (NB_RDAGENT),
    .SELECT_WIDTH (SELECT_WIDTH)
    ) rs_inst (
    .aclk     (aclk    ),
    .aresetn  (aresetn ),
    .s_rden   (s_rden  ),
    .s_rdaddr (s_rdaddr),
    .s_rddata (s_rddata),
    .rdselect (rdselect),
    .m_rden   (rden  ),
    .m_rdaddr (rdaddr),
    .m_rddata (rddata)
    );


endmodule

`resetall
