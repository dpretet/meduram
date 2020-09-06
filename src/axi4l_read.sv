// copyright damien pretet 2020
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 100 ps
`default_nettype none

module axi4l_read

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
        input  wire                    arvalid,
        output wire                    arready,
        input  wire [  ADDR_WIDTH-1:0] araddr,
        input  wire [           2-1:0] arprot,
        output wire                    rvalid,
        input  wire                    rready,
        output wire [  DATA_WIDTH-1:0] rdata,
        output wire [           2-1:0] rresp,
        input  wire                    aclk_core,
        input  wire                    aresetn_core,
        output wire                    rden,
        output wire [  ADDR_WIDTH-1:0] rdaddr,
        input  wire [  DATA_WIDTH-1:0] rddata,
        input  wire [             1:0] rdcollision
    );

    localparam DEPTH = $clog2(MAX_OR);

    logic arc_winc;
    logic arc_full;
    logic arc_rinc;
    logic arc_empty;

    logic rrc_winc;
    logic rrc_full;
    logic rrc_rinc;
    logic rrc_empty;
    logic [2-1:0] rresp_out;


    assign arready = ~arc_full;
    assign arc_winc = arvalid & arready;

    // Read Address Channel

    async_fifo #(
    .ASIZE  (DEPTH),
    .DSIZE  (ADDR_WIDTH)
    ) address_channel (
    .wclk    (aclk         ),
    .wrst_n  (aresetn      ),
    .winc    (arc_winc     ),
    .wdata   (araddr       ),
    .wfull   (arc_full     ),
    .awfull  (             ),
    .rclk    (aclk_core    ),
    .rrst_n  (aresetn_core ),
    .rinc    (arc_rinc     ),
    .rdata   (rdaddr       ),
    .rempty  (arc_empty    ),
    .arempty (             )
    );

    assign arc_rinc = rden;
    assign rden = ~arc_empty;

    always @ (posedge aclk_core or negedge aresetn_core) begin
        if (aresetn_core == 1'b0)
            rrc_winc <= 1'b0;
        else
            rrc_winc <= rden;
    end

    // Read Data Channel
    
    logic [DATA_WIDTH+2-1:0] rdcmpl_core, rdcmpl;
    assign rdcmpl_core = {rdcollision, rddata};
 
    async_fifo #(
    .ASIZE  (DEPTH),
    .DSIZE  (DATA_WIDTH+2)
    ) response_channel (
    .wclk    (aclk_core    ),
    .wrst_n  (aresetn_core ),
    .winc    (rrc_winc     ),
    .wdata   (rdcmpl_core  ),
    .wfull   (rrc_full     ),
    .awfull  (             ),
    .rclk    (aclk         ),
    .rrst_n  (aresetn      ),
    .rinc    (rrc_rinc     ),
    .rdata   (rdcmpl       ),
    .rempty  (rrc_empty    ),
    .arempty (             )
    );

    // We indicate available data whenever the FIFO
    // is not empty, and empty it once ready is asserted
    assign rvalid = ~rrc_empty;
    assign rrc_rinc = rvalid & rready;
    assign rdata = rdcmpl[0+:DATA_WIDTH];
    // We drive a SLVERR so signify an error condition
    // during read access
    assign rresp = rdcmpl[DATA_WIDTH+:2] ? 2'b10 : 2'b00;

endmodule

`resetall
