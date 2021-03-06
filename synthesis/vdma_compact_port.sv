/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/10 上午11:24:16
madified:
***********************************************/
`timescale 1ns/1ps
module vdma_compact_port #(
    parameter WR_THRESHOLD   = 200,
    parameter RD_THRESHOLD   = 200,
    parameter FULL_LEN       = 512,
    parameter ASIZE          = 29,
    parameter BURST_LEN_SIZE = 8,
    parameter PIX_DSIZE      = 24,
    parameter AXI_DSIZE      = 256,
    parameter IDSIZE         = 1,
    parameter ID             = 0,
    parameter STORAGE_MODE  = "ONCE",   //ONCE LINE
    parameter IN_DATA_TYPE  = "AXIS",    //AXIS NATIVE
    parameter OUT_DATA_TYPE = "AXIS",
    parameter IN_FRAME_SYNC = "OFF",    //OFF ON
    parameter OUT_FRAME_SYNC= "OFF",   //OFF ON
    //-->> JUST FOR OUT <<------
    parameter EX_SYNC       = "OFF",     //OFF ON
    parameter VIDEO_FORMAT  = "1080P@60",
    //--<< JUST FOR OUT >>------
    parameter PORT_MODE = "BOTH",   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    parameter BASE_ADDR_0 = 0,
    parameter BASE_ADDR_1 = 0,
    parameter BASE_ADDR_2 = 0,
    parameter BASE_ADDR_3 = 0,
    parameter BASE_ADDR_4 = 0,
    parameter BASE_ADDR_5 = 0,
    parameter BASE_ADDR_6 = 0,
    parameter BASE_ADDR_7 = 0
    //--<< BASEADDRE LIST >>----
)(
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               in_fsync                ,
    input               rev_enable              ,
    input               trs_enable              ,
    //native input port
    video_native_inf.compact_in vin             ,
    //native output ex driver
    video_native_inf.compact_in vex             ,
    //native output
    video_native_inf.compact_out vout           ,
    // axis in
    axi_stream_inf.slaver  axis_in              ,
    // axi out
    axi_stream_inf.master  axis_out             ,
    // axi4 master
    axi_inf.master axi4_m                       ,
    // baseaddr ctrl inf
    vdma_baseaddr_ctrl_inf.slaver       ex_ba_ctrl,
    vdma_baseaddr_ctrl_inf.master       ctrl_ex_ba0,
    vdma_baseaddr_ctrl_inf.master       ctrl_ex_ba1,
    vdma_baseaddr_ctrl_inf.master       ctrl_ex_ba2
);

logic   axi4_inf_err_rst = '0;


// always@(posedge axi4_m.axi_aclk)
//     // axi4_inf_err_rst <= (axi4_m.axi_wevld && axi4_m.axi_weresp!=4'b000) || (axi4_m.axi_revld && axi4_m.axi_reresp!=4'b000);
//     axi4_inf_err_rst <= axi4_m.axi_wevld  || axi4_m.axi_revld ;

logic pend_rev_trs;
logic pend_trs_rev;

logic rev_pclk,rev_prst_n;

logic[ASIZE-1:0]    wr_baseaddr,rd_baseaddr;

vdma_baseaddr_ctrl_inf base_addr_inf();
vdma_baseaddr_ctrl_inf inter_base_addr_inf();

assign base_addr_inf.clk = vin.pclk;
assign base_addr_inf.rst_n = vin.prst_n;
assign base_addr_inf.vs =   (IN_DATA_TYPE=="NATIVE")? vin.vsync  :
                            (IN_DATA_TYPE=="AXIS")? (IN_FRAME_SYNC=="OFF"? axis_in.axis_tuser : in_fsync) : 1'b0;

//--->> INTRE BASE LINK <<----------
generate
if(PORT_MODE == "WRITE")begin
baseaddr_ctrl baseaddr_ctrl_inst(
    .write_enable   (1'b1           ),
    .write          (base_addr_inf  ),
    .rd0            (ctrl_ex_ba0    ),
    .rd1            (ctrl_ex_ba1    ),
    .rd2            (ctrl_ex_ba2    )
);
end else if(PORT_MODE == "BOTH")begin
baseaddr_ctrl baseaddr_ctrl_inst(
    .write_enable   (1'b1           ),
    .write          (base_addr_inf  ),
    .rd0            (inter_base_addr_inf    ),
    .rd1            (ctrl_ex_ba0    ),
    .rd2            (ctrl_ex_ba1    )
);
end
endgenerate

//-->> read port base intf
logic   intf_clk;
logic   intf_rst_n;
logic   intf_vs;

assign intf_clk   = rev_pclk;
assign intf_rst_n = rev_prst_n;
assign intf_vs    =  (OUT_DATA_TYPE=="NATIVE")? vout.vsync  :
                     (OUT_DATA_TYPE=="AXIS")?   axis_out.axis_tuser : 1'b0;

generate
/**/if(PORT_MODE == "BOTH")begin
/**/always@(*) begin
/**/    case(inter_base_addr_inf.point)
/**/    0:  rd_baseaddr = BASE_ADDR_0;
/**/    1:  rd_baseaddr = BASE_ADDR_1;
/**/    2:  rd_baseaddr = BASE_ADDR_2;
/**/    3:  rd_baseaddr = BASE_ADDR_3;
/**/    4:  rd_baseaddr = BASE_ADDR_4;
/**/    5:  rd_baseaddr = BASE_ADDR_5;
/**/    6:  rd_baseaddr = BASE_ADDR_6;
/**/    7:  rd_baseaddr = BASE_ADDR_7;
/**/    default:
/**/        rd_baseaddr = BASE_ADDR_0;
/**/    endcase
/**/end

/**/assign inter_base_addr_inf.clk   = intf_clk  ;
/**/assign inter_base_addr_inf.rst_n = intf_rst_n;
/**/assign inter_base_addr_inf.vs    = intf_vs   ;

end else if(PORT_MODE == "READ")begin
    always@(*) begin
        case(ex_ba_ctrl.point)
        0:  rd_baseaddr = BASE_ADDR_0;
        1:  rd_baseaddr = BASE_ADDR_1;
        2:  rd_baseaddr = BASE_ADDR_2;
        3:  rd_baseaddr = BASE_ADDR_3;
        4:  rd_baseaddr = BASE_ADDR_4;
        5:  rd_baseaddr = BASE_ADDR_5;
        6:  rd_baseaddr = BASE_ADDR_6;
        7:  rd_baseaddr = BASE_ADDR_7;
        default:
            rd_baseaddr = BASE_ADDR_0;
        endcase
    end

    assign ex_ba_ctrl.clk   = intf_clk  ;
    assign ex_ba_ctrl.rst_n = intf_rst_n;
    assign ex_ba_ctrl.vs    = intf_vs   ;
end
endgenerate

generate
if(PORT_MODE == "WRITE" || PORT_MODE == "BOTH")begin
//===============================================================//
mm_tras #(
    .THRESHOLD      (WR_THRESHOLD  ),
    .ASIZE          (ASIZE      ),
    .BURST_LEN_SIZE (BURST_LEN_SIZE ),
    .DSIZE          (PIX_DSIZE  ),
    .AXI_DSIZE      (AXI_DSIZE  ),
    .IDSIZE         (IDSIZE     ),
    .ID             (ID         ),
    .MODE           (STORAGE_MODE   ),   //ONCE LINE
    .DATA_TYPE      (IN_DATA_TYPE      ),    //AXIS NATIVE
    .FRAME_SYNC     (IN_FRAME_SYNC     )//OFF ON
)mm_tras_inst(
/*  input             */  .clock                   (vin.pclk            ),
/*  input             */  .rst_n                   (vin.prst_n  && !axi4_inf_err_rst     ),
// /*  input             */  .rst_n                   (vin.prst_n          ),
/*  input             */  .enable                  (trs_enable          ),
/*  input             */  .baseaddr                (wr_baseaddr         ),
/*  input [15:0]      */  .vactive                 (vactive         ),
/*  input [15:0]      */  .hactive                 (hactive         ),
/*  input             */  .vsync                   (vin.vsync       ),
/*  input             */  .hsync                   (vin.hsync       ),
/*  input             */  .de                      (vin.de          ),
/*  input [DSIZE-1:0] */  .idata                   (vin.data /*hactive*/      ),
/*  output            */  .fifo_almost_full        (                ),
/*  input             */  .pend_in                 (pend_rev_trs    ),
/*  output            */  .pend_out                (pend_trs_rev    ),
    //-- AXI
    //-->> axi stream ---
/*  input             */  .fsync                   (in_fsync           ),
/*  input             */  .aclk                    (axis_in.aclk       ),
/*  input             */  .aclken                  (axis_in.aclken     ),
/*  input             */  .aresetn                 (axis_in.aresetn && !axi4_inf_err_rst   ),
/*  input [DSIZE-1:0] */  .axi_tdata               (axis_in.axis_tdata  ),
/*  input             */  .axi_tvalid              (axis_in.axis_tvalid ),
/*  output            */  .axi_tready              (axis_in.axis_tready ),
/*  input             */  .axi_tuser               (axis_in.axis_tuser  ),
/*  input             */  .axi_tlast               (axis_in.axis_tlast  ),
    //--<< axi stream
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

always@(*) begin
    case(base_addr_inf.point)
    0:  wr_baseaddr = BASE_ADDR_0;
    1:  wr_baseaddr = BASE_ADDR_1;
    2:  wr_baseaddr = BASE_ADDR_2;
    3:  wr_baseaddr = BASE_ADDR_3;
    4:  wr_baseaddr = BASE_ADDR_4;
    5:  wr_baseaddr = BASE_ADDR_5;
    6:  wr_baseaddr = BASE_ADDR_6;
    7:  wr_baseaddr = BASE_ADDR_7;
    default:
        wr_baseaddr = BASE_ADDR_0;
    endcase
end

end else begin//===========================================//
assign pend_trs_rev = 1'b0;

always@(*) begin
    case(ex_ba_ctrl.point)
    0:  rd_baseaddr = BASE_ADDR_0;
    1:  rd_baseaddr = BASE_ADDR_1;
    2:  rd_baseaddr = BASE_ADDR_2;
    3:  rd_baseaddr = BASE_ADDR_3;
    4:  rd_baseaddr = BASE_ADDR_4;
    5:  rd_baseaddr = BASE_ADDR_5;
    6:  rd_baseaddr = BASE_ADDR_6;
    7:  rd_baseaddr = BASE_ADDR_7;
    default:
        rd_baseaddr = BASE_ADDR_0;
    endcase
end
end//=============================================//
endgenerate

generate
if(PORT_MODE=="READ" || PORT_MODE=="BOTH")begin:MM_REV_BLOCK

assign rev_pclk     = (EX_SYNC=="ON")? vex.pclk : vout.pclk;
assign rev_prst_n   = (EX_SYNC=="ON")? vex.prst_n : vout.prst_n;

mm_rev #(
    .THRESHOLD      (RD_THRESHOLD      ),
    .FULL_LEN       (FULL_LEN       ),
    .ASIZE          (ASIZE          ),
    .BURST_LEN_SIZE (BURST_LEN_SIZE ),
    .IDSIZE         (IDSIZE         ),
    .ID             (ID             ),
    .DSIZE          (PIX_DSIZE      ),
    .AXI_DSIZE      (AXI_DSIZE      ),
    .MODE           (STORAGE_MODE   ),   //ONCE LINE
    .DATA_TYPE      (OUT_DATA_TYPE      ),    //AXIS NATIVE
    .FRAME_SYNC     (OUT_FRAME_SYNC     ),    //OFF ON
    .EX_SYNC        (EX_SYNC        ),     //OFF ON
    .VIDEO_FORMAT   (VIDEO_FORMAT   )
)mm_rev_inst(
/*  input              */ .clock                   (rev_pclk            ),
/*  input              */ .rst_n                   (rev_prst_n && !axi4_inf_err_rst         ),
// /*  input              */ .rst_n                   (rev_prst_n          ),
/*  input              */ .enable                  (rev_enable          ),
/*  input             */  .baseaddr                (rd_baseaddr         ),
/*  input [15:0]       */ .vactive                 (vactive             ),
/*  input [15:0]       */ .hactive                 (hactive             ),
/*  input              */ .in_vsync                (vex.vsync           ),
/*  input              */ .in_hsync                (vex.hsync           ),
/*  input              */ .in_de                   (vex.de              ),
/*  output             */ .fifo_almost_empty       (                    ),
/*  input              */ .pend_in                 (pend_trs_rev        ),
/*  output             */ .pend_out                (pend_rev_trs        ),
    //-- AXI
    //-->> axi stream ---
/*  output             */ .aclk                    (                    ),
/*  output             */ .aclken                  (                    ),
/*  output             */ .aresetn                 (                    ),
/*  output[DSIZE-1:0]  */ .axi_tdata               (axis_out.axis_tdata  ),
/*  output             */ .axi_tvalid              (axis_out.axis_tvalid ),
/*  input              */ .axi_tready              (axis_out.axis_tready ),
/*  output             */ .axi_tuser               (axis_out.axis_tuser  ),
/*  output             */ .axi_tlast               (axis_out.axis_tlast  ),
    //--<< axi stream
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
