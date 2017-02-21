/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERB.0.0
    cut axis
creaded: 2016/8/10 上午11:24:16
madified:
***********************************************/
`timescale 1ns/1ps
module vdma_compact_port_verb #(
    parameter WR_THRESHOLD   = 200,
    parameter RD_THRESHOLD   = 200,
    parameter FULL_LEN       = 512,
    parameter ASIZE          = 29,
    parameter BURST_LEN_SIZE = 8,
    parameter AXI_DSIZE      = 256,
    parameter IDSIZE         = 1,
    parameter ID             = 0,
    parameter STORAGE_MODE  = "ONCE",   //ONCE LINE
    //-->> JUST FOR OUT <<------
    parameter EX_SYNC       = "OFF",     //OFF ON
    parameter VIDEO_FORMAT  = "1080P@60",
    //--<< JUST FOR OUT >>------
    parameter PORT_MODE = "BOTH"   // READ WRITE BOTH
)(
    // input [15:0]        vactive                 ,
    // input [15:0]        hactive                 ,
    input               rev_enable              ,
    input               trs_enable              ,
    input [ASIZE-1:0]   wr_baseaddr             ,
    input [ASIZE-1:0]   rd_baseaddr             ,
    //native input port
    video_native_inf.compact_in vin             ,
    //native output ex driver
    video_native_inf.compact_in vex             ,
    //native output
    video_native_inf.compact_out vout           ,
    // axi4 master
    axi_inf.master axi4_m
);

logic   axi4_inf_err_rst = '0;


// always@(posedge axi4_m.axi_aclk)
//     // axi4_inf_err_rst <= (axi4_m.axi_wevld && axi4_m.axi_weresp!=4'b000) || (axi4_m.axi_revld && axi4_m.axi_reresp!=4'b000);
//     axi4_inf_err_rst <= axi4_m.axi_wevld  || axi4_m.axi_revld ;

logic pend_rev_trs;
logic pend_trs_rev;


generate
if(PORT_MODE == "WRITE" || PORT_MODE == "BOTH")begin
//===============================================================//
mm_tras_verb #(
    .THRESHOLD      (WR_THRESHOLD  ),
    .ASIZE          (ASIZE      ),
    .BURST_LEN_SIZE (BURST_LEN_SIZE ),
    .DSIZE          (vin.DSIZE  ),
    .AXI_DSIZE      (AXI_DSIZE  ),
    .IDSIZE         (IDSIZE     ),
    .ID             (ID         ),
    .MODE           (STORAGE_MODE   )   //ONCE LINE
)mm_tras_inst(
/*  input             */  .clock                   (vin.pclk            ),
/*  input             */  .rst_n                   (vin.prst_n  && !axi4_inf_err_rst     ),
// /*  input             */  .rst_n                   (vin.prst_n          ),
/*  input             */  .enable                  (trs_enable          ),
/*  input [ASIZE-1:0] */  .baseaddr                (wr_baseaddr         ),
/*  input [15:0]      */  .vactive                 (vin.vactive         ),
/*  input [15:0]      */  .hactive                 (vin.hactive         ),
/*  input             */  .vsync                   (vin.vsync       ),
/*  input             */  .hsync                   (vin.hsync       ),
/*  input             */  .de                      (vin.de          ),
/*  input [DSIZE-1:0] */  .idata                   (vin.data /*hactive*/      ),
/*  output            */  .fifo_almost_full        (                ),
/*  input             */  .pend_in                 (pend_rev_trs    ),
/*  output            */  .pend_out                (pend_trs_rev    ),
    //-- AXI
/*  input             */  .axi_aclk                (axi4_m.axi_aclk        ),
/*  input             */  .axi_resetn              (axi4_m.axi_resetn      ),
    //--->> addr write <<-------
/* output[IDSIZE-1:0] */  .axi_awid                (axi4_m.axi_awid             ),
/* output[ASIZE-1:0]  */  .axi_awaddr              (axi4_m.axi_awaddr           ),
/* output[LSIZE-1:0]  */  .axi_awlen               (axi4_m.axi_awlen            ),
/* output[2:0]        */  .axi_awsize              (axi4_m.axi_awsize           ),
/* output[1:0]        */  .axi_awburst             (axi4_m.axi_awburst          ),
/* output[0:0]        */  .axi_awlock              (axi4_m.axi_awlock           ),
/* output[3:0]        */  .axi_awcache             (axi4_m.axi_awcache          ),
/* output[2:0]        */  .axi_awprot              (axi4_m.axi_awprot           ),
/* output[3:0]        */  .axi_awqos               (axi4_m.axi_awqos            ),
/* output             */  .axi_awvalid             (axi4_m.axi_awvalid          ),
/* inpuy              */  .axi_awready             (axi4_m.axi_awready          ),
    //--->> Response <<---------
/*  output            */  .axi_bready              (axi4_m.axi_bready           ),
/*  input[IDSIZE-1:0] */  .axi_bid                 (axi4_m.axi_bid              ),
/*  input[1:0]        */  .axi_bresp               (axi4_m.axi_bresp            ),
/*  input             */  .axi_bvalid              (axi4_m.axi_bvalid           ),
    //---<< Response >>---------
    //--->> data write <<-------
/*  output[DSIZE-1:0]  */ .axi_wdata               (axi4_m.axi_wdata            ),
/*  output[DSIZE/8-1:0]*/ .axi_wstrb               (axi4_m.axi_wstrb            ),
/*  output             */ .axi_wlast               (axi4_m.axi_wlast            ),
/*  output             */ .axi_wvalid              (axi4_m.axi_wvalid           ),
/*  input              */ .axi_wready              (axi4_m.axi_wready           )
    //---<< data write >>-------
);
end else begin
assign pend_trs_rev = 1'b0;
end
endgenerate

generate
if(PORT_MODE=="READ" || PORT_MODE=="BOTH")begin:MM_REV_BLOCK

assign rev_pclk     = (EX_SYNC=="ON")? vex.pclk : vout.pclk;
assign rev_prst_n   = (EX_SYNC=="ON")? vex.prst_n : vout.prst_n;

mm_rev_verb #(
    .THRESHOLD      (RD_THRESHOLD      ),
    .FULL_LEN       (FULL_LEN       ),
    .ASIZE          (ASIZE          ),
    .BURST_LEN_SIZE (BURST_LEN_SIZE ),
    .IDSIZE         (IDSIZE         ),
    .ID             (ID             ),
    .DSIZE          (vout.DSIZE     ),
    .AXI_DSIZE      (AXI_DSIZE      ),
    .MODE           (STORAGE_MODE   ),   //ONCE LINE
    .EX_SYNC        (EX_SYNC        ),     //OFF ON
    .VIDEO_FORMAT   (VIDEO_FORMAT   )
)mm_rev_inst(
/*  input              */ .clock                   (rev_pclk            ),
/*  input              */ .rst_n                   (rev_prst_n && !axi4_inf_err_rst         ),
// /*  input              */ .rst_n                   (rev_prst_n          ),
/*  input              */ .enable                  (rev_enable          ),
/*  input             */  .baseaddr                (rd_baseaddr         ),
/*  input [15:0]       */ .vactive                 (vex.vactive         ),
/*  input [15:0]       */ .hactive                 (vex.hactive         ),
/*  input              */ .in_vsync                (vex.vsync           ),
/*  input              */ .in_hsync                (vex.hsync           ),
/*  input              */ .in_de                   (vex.de              ),
/*  output             */ .fifo_almost_empty       (                    ),
/*  input              */ .pend_in                 (pend_trs_rev        ),
/*  output             */ .pend_out                (pend_rev_trs        ),
    //-- AXI
/*  input              */ .axi_aclk                (axi4_m.axi_aclk            ),
/*  input              */ .axi_resetn              (axi4_m.axi_resetn && !axi4_inf_err_rst         ),
    //-- axi read
    //-- addr read
/*  output[IDSIZE-1:0] */ .axi_arid                (axi4_m.axi_arid         ),
/*  output[ASIZE-1:0]  */ .axi_araddr              (axi4_m.axi_araddr       ),
/*  output[BURST_LEN_SIZE-1:0]*/
                          .axi_arlen               (axi4_m.axi_arlen        ),
/*  output[2:0]        */ .axi_arsize              (axi4_m.axi_arsize       ),
/*  output[1:0]        */ .axi_arburst             (axi4_m.axi_arburst      ),
/*  output[0:0]        */ .axi_arlock              (axi4_m.axi_arlock       ),
/*  output[3:0]        */ .axi_arcache             (axi4_m.axi_arcache      ),
/*  output[2:0]        */ .axi_arprot              (axi4_m.axi_arprot       ),
/*  output[3:0]        */ .axi_arqos               (axi4_m.axi_arqos        ),
/*  output             */ .axi_arvalid             (axi4_m.axi_arvalid      ),
/*  input              */ .axi_arready             (axi4_m.axi_arready      ),
    //-- data read
/*  output             */ .axi_rready              (axi4_m.axi_rready       ),
/*  input[IDSIZE-1:0]  */ .axi_rid                 (axi4_m.axi_rid          ),
/*  input[DSIZE-1:0]   */ .axi_rdata               (axi4_m.axi_rdata        ),
/*  input[1:0]         */ .axi_rresp               (axi4_m.axi_rresp        ),
/*  input              */ .axi_rlast               (axi4_m.axi_rlast        ),
/*  input              */ .axi_rvalid              (axi4_m.axi_rvalid       ),
    //-- native
/*  output             */ .out_vsync               (vout.vsync              ),
/*  output             */ .out_hsync               (vout.hsync              ),
/*  output             */ .out_de                  (vout.de                 ),
/*  output[DSIZE-1:0]  */ .odata                   (vout.data               )
);
end else begin
assign pend_rev_trs = 1'b0;
end
endgenerate

generate
if(PORT_MODE=="WRITE")begin
assign     axi4_m.axi_arid     = 0;
assign     axi4_m.axi_araddr   = 0;
assign     axi4_m.axi_arlen    = 0;
assign     axi4_m.axi_arsize   = 05;
assign     axi4_m.axi_arburst  = 2'b01;
assign     axi4_m.axi_arlock   = 0;
assign     axi4_m.axi_arcache  = 0;
assign     axi4_m.axi_arprot   = 0;
assign     axi4_m.axi_arqos    = 0;
assign     axi4_m.axi_arvalid  = 0;
assign     axi4_m.axi_rready   = 1;
// assign     pend_rev_trs        = 1'b0;
end
endgenerate

generate
if(PORT_MODE=="READ")begin
assign     axi4_m.axi_awid     = 0;
assign     axi4_m.axi_awaddr   = 0;
assign     axi4_m.axi_awlen    = 0;
assign     axi4_m.axi_awsize   = 5;
assign     axi4_m.axi_awburst  = 2'b01;
assign     axi4_m.axi_awlock   = 0;
assign     axi4_m.axi_awcache  = 0;
assign     axi4_m.axi_awprot   = 0;
assign     axi4_m.axi_awqos    = 0;
assign     axi4_m.axi_awvalid  = 0;
assign     axi4_m.axi_wdata    = 0;
assign     axi4_m.axi_wstrb    = 0;
assign     axi4_m.axi_wlast    = 0;
assign     axi4_m.axi_wvalid   = 0;
assign     axi4_m.axi_bready   = 1;
// assign     pend_trs_rev        = 1'b0;
end
endgenerate

endmodule
