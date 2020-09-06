// copyright damien pretet 2020
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 100 ps
`default_nettype none

module axi4l_write

    #(
        // Number of max requests accepted
        parameter MAX_OR = 8,
        // Addr Width in bits
        parameter ADDR_WIDTH = 3,
        // Data Width in bits
        parameter DATA_WIDTH = 8
    )(
        input  wire                    aclk,
        input  wire                    aresetn,
        input  wire                    awvalid,
        output wire                    awready,
        input  wire [  ADDR_WIDTH-1:0] awaddr,
        input  wire [           2-1:0] awprot,
        input  wire                    wvalid,
        output wire                    wready,
        input  wire [  DATA_WIDTH-1:0] wdata,
        input  wire [DATA_WIDTH/8-1:0] wstrb,
        output wire                    bvalid,
        input  wire                    bready,
        output wire [           2-1:0] bresp,
        input  wire                    aclk_core,
        input  wire                    aresetn_core,
        output wire                    wren,
        output wire [  ADDR_WIDTH-1:0] wraddr,
        output wire [  DATA_WIDTH-1:0] wrdata
    );
    
    localparam DEPTH = $clog2(MAX_OR);

    logic awc_winc;
    logic awc_full;
    logic awc_rinc;
    logic awc_empty;

    logic dwc_winc;
    logic dwc_full;
    logic dwc_rinc;
    logic dwc_empty;

    logic [DEPTH:0] or_cnt;
    logic [    1:0] bready_cdc;
    logic           bready_core;
    logic [    1:0] bvalid_cdc;
    logic           bvalid_core;

    // Address Write Channel

    assign awready = ~awc_full;
    assign awc_winc = awvalid & awready;

    async_fifo #(
    .ASIZE  (DEPTH),
    .DSIZE  (ADDR_WIDTH)
    ) address_channel (
    .wclk    (aclk         ),
    .wrst_n  (aresetn      ),
    .winc    (awc_winc     ),
    .wdata   (awaddr       ),
    .wfull   (awc_full     ),
    .awfull  (             ),
    .rclk    (aclk_core    ),
    .rrst_n  (aresetn_core ),
    .rinc    (awc_rinc     ),
    .rdata   (wraddr       ),
    .rempty  (awc_empty    ),
    .arempty (             )
    );

    assign wready = ~dwc_full;
    assign dwc_winc = wvalid & wready;

    // Data Write Channel

    async_fifo #(
    .ASIZE  (DEPTH),
    .DSIZE  (DATA_WIDTH)
    ) data_channel (
    .wclk    (aclk         ),
    .wrst_n  (aresetn      ),
    .winc    (dwc_winc     ),
    .wdata   (wdata        ),
    .wfull   (dwc_full     ),
    .awfull  (             ),
    .rclk    (aclk_core    ),
    .rrst_n  (aresetn_core ),
    .rinc    (dwc_rinc     ),
    .rdata   (wrdata       ),
    .rempty  (dwc_empty    ),
    .arempty (             )
    );

    // Write Completion Channel

    // We translate first bready to the core clock space
    // for outstanding request trackerc
    always @ (posedge aclk_core or negedge aresetn_core) begin
        if (aresetn_core == 1'b0)
            bready_cdc <= 2'b0;
        else
            bready_cdc <= {bready_cdc[0], bready};
    end
    
    assign bready_core = bready_cdc[1];

    // Outstanding request counter, tracking completion to 
    // release once the agent is active
    // FIXME: Add assertion to check overflow and underflow
    always @ (posedge aclk_core or negedge aresetn_core) begin
        if (aresetn_core == 1'b0)
            or_cnt <= MAX_OR[DEPTH:0];
        else if (wren)
            or_cnt <= or_cnt - 1'b1;
        else if (bready_core)
            or_cnt <= or_cnt + 1'b1;
    end
    
    assign bvalid_core = (or_cnt < MAX_OR);

    always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == 1'b0)
            bvalid_cdc <= 2'b0;
        else
            bvalid_cdc <= {bvalid_cdc[0], bvalid_core};
    end
    
    assign bvalid = bvalid_cdc[1];
    assign bresp = 2'b00;

    // Interface to the RAM, address and data are connected
    // directly to the FIFO output
    assign wren = ~awc_empty & ~dwc_empty;
    assign awc_rinc = wren;
    assign dwc_rinc = wren;

endmodule

`resetall
