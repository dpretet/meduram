// Copyright Damien Pretet 2020
// Distributed under the MIT License
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 100 ps
`default_nettype none

module top_axi4lite

    #(
        // Addr Width in bits
        parameter ADDR_WIDTH = 3,
        // RAM depth
        parameter RAM_DEPTH = 2**ADDR_WIDTH,
        // Data Width in bits
        parameter DATA_WIDTH = 8,
        // Enable write collision support
        parameter WRITE_COLLISION = 1,
        // Enable read collision support
        parameter READ_COLLISION = 1
    )(
        // Clock / Reset interface sourcing the core
        input  wire                    aclk_core,
        input  wire                    aresetn_core,
        // Write Agent 1 Interface
        input  wire                    aclk_wr1,
        input  wire                    aresetn_wr1,
        input  wire                    awvalid1,
        output wire                    awready1,
        input  wire [  ADDR_WIDTH-1:0] awaddr1,
        input  wire [           2-1:0] awprot1,
        input  wire                    wvalid1,
        output wire                    wready1,
        input  wire [  DATA_WIDTH-1:0] wdata1,
        input  wire [DATA_WIDTH/8-1:0] wstrb1,
        output wire                    bvalid1,
        input  wire                    bready1,
        output wire [           2-1:0] bresp1,
        // Write Agent 2 Interface
        input  wire                    aclk_wr2,
        input  wire                    aresetn_wr2,
        input  wire                    awvalid2,
        output wire                    awready2,
        input  wire [  ADDR_WIDTH-1:0] awaddr2,
        input  wire [           2-1:0] awprot2,
        input  wire                    wvalid2,
        output wire                    wready2,
        input  wire [  DATA_WIDTH-1:0] wdata2,
        input  wire [DATA_WIDTH/8-1:0] wstrb2,
        output wire                    bvalid2,
        input  wire                    bready2,
        output wire [           2-1:0] bresp2,
        // Read Agent 1 Interface
        input  wire                    aclk_rd1,
        input  wire                    aresetn_rd1,
        input  wire                    arvalid1,
        output wire                    arready1,
        input  wire [  ADDR_WIDTH-1:0] araddr1,
        input  wire [           2-1:0] arprot1,
        output wire                    rvalid1,
        input  wire                    rready1,
        output wire [  DATA_WIDTH-1:0] rdata1,
        output wire [           2-1:0] rresp1,
        // Read Agent 2 Interface
        input  wire                    aclk_rd2,
        input  wire                    aresetn_rd2,
        input  wire                    arvalid2,
        output wire                    arready2,
        input  wire [  ADDR_WIDTH-1:0] araddr2,
        input  wire [           2-1:0] arprot2,
        output wire                    rvalid2,
        input  wire                    rready2,
        output wire [  DATA_WIDTH-1:0] rdata2,
        output wire [           2-1:0] rresp2
    );

    // FIXME: Add check COLLISION vs OR and display messages

    // initial begin
        // $dumpfile("top_axi4lite.vcd");
        // $dumpvars(0, top_axi4lite);
    // end

    wire                  wren1;
    wire [ADDR_WIDTH-1:0] wraddr1;
    wire [DATA_WIDTH-1:0] wrdata1;
    wire                  wren2;
    wire [ADDR_WIDTH-1:0] wraddr2;
    wire [DATA_WIDTH-1:0] wrdata2;
    wire                  rden1;
    wire [ADDR_WIDTH-1:0] rdaddr1;
    wire [DATA_WIDTH-1:0] rddata1;
    wire [2         -1:0] rdcollision1;
    wire                  rden2;
    wire [ADDR_WIDTH-1:0] rdaddr2;
    wire [DATA_WIDTH-1:0] rddata2;
    wire [2         -1:0] rdcollision2;

    axi4l_write
    #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    )
    wragent1
    (
    .aclk         (aclk_wr1    ),
    .aresetn      (aresetn_wr1 ),
    .awvalid      (awvalid1    ),
    .awready      (awready1    ),
    .awaddr       (awaddr1     ),
    .awprot       (awprot1     ),
    .wvalid       (wvalid1     ),
    .wready       (wready1     ),
    .wdata        (wdata1      ),
    .wstrb        (wstrb1      ),
    .bvalid       (bvalid1     ),
    .bready       (bready1     ),
    .bresp        (bresp1      ),
    .aclk_core    (aclk_core   ),
    .aresetn_core (aresetn_core),
    .wren         (wren1       ),
    .wraddr       (wraddr1     ),
    .wrdata       (wrdata1     )
    );

    axi4l_write
    #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    )
    wragent2
    (
    .aclk         (aclk_wr2    ),
    .aresetn      (aresetn_wr2 ),
    .awvalid      (awvalid2    ),
    .awready      (awready2    ),
    .awaddr       (awaddr2     ),
    .awprot       (awprot2     ),
    .wvalid       (wvalid2     ),
    .wready       (wready2     ),
    .wdata        (wdata2      ),
    .wstrb        (wstrb2      ),
    .bvalid       (bvalid2     ),
    .bready       (bready2     ),
    .bresp        (bresp2      ),
    .aclk_core    (aclk_core   ),
    .aresetn_core (aresetn_core),
    .wren         (wren2       ),
    .wraddr       (wraddr2     ),
    .wrdata       (wrdata2     )
    );


    top_core
    #(
    .ADDR_WIDTH      (ADDR_WIDTH),
    .RAM_DEPTH       (RAM_DEPTH),
    .DATA_WIDTH      (DATA_WIDTH),
    .WRITE_COLLISION (WRITE_COLLISION),
    .READ_COLLISION  (READ_COLLISION)
    )
    meduram_core
    (
    .aclk         (aclk_core   ),
    .aresetn      (aresetn_core),
    .wren1        (wren1       ),
    .wraddr1      (wraddr1     ),
    .wrdata1      (wrdata1     ),
    .wren2        (wren2       ),
    .wraddr2      (wraddr2     ),
    .wrdata2      (wrdata2     ),
    .rden1        (rden1       ),
    .rdaddr1      (rdaddr1     ),
    .rddata1      (rddata1     ),
    .rdcollision1 (rdcollision1),
    .rden2        (rden2       ),
    .rdaddr2      (rdaddr2     ),
    .rddata2      (rddata2     ),
    .rdcollision2 (rdcollision2)
    );

    axi4l_read
    #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    )
    rdagent1
    (
    .aclk         (aclk_rd1    ),
    .aresetn      (aresetn_rd1 ),
    .arvalid      (arvalid1    ),
    .arready      (arready1    ),
    .araddr       (araddr1     ),
    .arprot       (arprot1     ),
    .rvalid       (rvalid1     ),
    .rready       (rready1     ),
    .rdata        (rdata1      ),
    .rresp        (rresp1      ),
    .aclk_core    (aclk_core   ),
    .aresetn_core (aresetn_core),
    .rden         (rden1       ),
    .rdaddr       (rdaddr1     ),
    .rddata       (rddata1     ),
    .rdcollision  (rdcollision1)
    );

    axi4l_read
    #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    )
    rdagent2
    (
    .aclk         (aclk_rd2    ),
    .aresetn      (aresetn_rd2 ),
    .arvalid      (arvalid2    ),
    .arready      (arready2    ),
    .araddr       (araddr2     ),
    .arprot       (arprot2     ),
    .rvalid       (rvalid2     ),
    .rready       (rready2     ),
    .rdata        (rdata2      ),
    .rresp        (rresp2      ),
    .aclk_core    (aclk_core   ),
    .aresetn_core (aresetn_core),
    .rden         (rden2       ),
    .rdaddr       (rdaddr2     ),
    .rddata       (rddata2     ),
    .rdcollision  (rdcollision2)
    );

endmodule

`resetall
