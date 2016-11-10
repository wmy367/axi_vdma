/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/11/2 上午10:06:55
madified:
***********************************************/
`timescale 1ns/1ps
module ac701_test_top (
    input             sysclk_p,
    input             sysclk_n,
    inout [63:0]      ddr3_dq,
    inout [7:0]       ddr3_dqs_n,
    inout [7:0]       ddr3_dqs_p,
    output[13:0]      ddr3_addr,
    output[2:0]       ddr3_ba,
    output            ddr3_ras_n,
    output            ddr3_cas_n,
    output            ddr3_we_n,
    output            ddr3_reset_n,
    output[0:0]       ddr3_ck_p,
    output[0:0]       ddr3_ck_n,
    output[0:0]       ddr3_cke,
    output[0:0]       ddr3_cs_n,
    output[7:0]       ddr3_dm,
    output[0:0]       ddr3_odt,

    output              hdmi_vs,
    output              hdmi_hs,
    output              hdmi_de,
    output[23:0]        hdmi_data,
    output              hdmi_clk,
    output              LED_0
//    input [23:0]        test_in
);
//----->> CLOCK RST <<---------------
wire        app_clk;
wire        app_sync_rst;
wire        axi_aclk;
wire        axi_resetn;

assign      axi_aclk    = app_clk;
assign      axi_resetn  = !app_sync_rst;

wire        pclk,prst_n;
wire        clk_200M,sys_rst;
wire        mmcm_locked;

system_mmcm system_mmcm_inst
(
    // Clock in ports
/*   input   */    .clk_in1_p   (sysclk_p   ),
/*   input   */    .clk_in1_n   (sysclk_n   ),
     // Clock out ports
/*   output  */    .clk_out1    (clk_200M   ),
/*   output  */    .clk_out2    (pclk       ),
     // Status and control signals
/*   output  */    .locked      (mmcm_locked)
);

assign  prst_n  = mmcm_locked;
assign  sys_rst = mmcm_locked;
//-----<< CLOCK RST >>---------------
localparam
                PIX_DSIZE_0    =   24,
                PIX_DSIZE_1    =   24,
                VIDEO_FORMAT_0 =   "1080P@60",
                VIDEO_FORMAT_1 =   "1080P@60";

localparam      ADDR_WIDTH  = 28,
                DATA_WIDTH  = 512;

//--->> interface define <<-------------------
`include "/home/young/work/axi_vdma/multiports_vdma_tb_1028_inf_def.svi"
// `include "C:/Users/wmy367/Documents/GitHub/axi_vdma/multiports_vdma_tb_1028_inf_def.svi"
//---<< interface define >>-------------------
//--->> TEST COLOR PARTTEN <<-----------------
logic[15:0]     vactive0;
logic[15:0]     hactive0;

logic[15:0]     vactive1;
logic[15:0]     hactive1;

logic           video_gen_0_en,video_gen_1_en;

simple_video_gen #(
    .MODE   (VIDEO_FORMAT_0   ),
    .DSIZE  (PIX_DSIZE_0      )
)simple_video_gen_inst0(
/*    input       */    .enable     (video_gen_0_en     ),
/*    video_native_inf.compact_out */
                        .inf        (video_native_in0   ),
/*    axi_stream_inf.master*/
                        .axis       (axi_stream_in0     ),
/*  output[15:0]    */  .vactive    (vactive0    ),
/*  output[15:0]    */  .hactive    (hactive0    )
);

simple_video_gen #(
    .MODE   (VIDEO_FORMAT_1   ),
    .DSIZE  (PIX_DSIZE_1      )
)simple_video_gen_inst1(
/*    input       */    .enable     (/*video_gen_1_en*/0    ),
/*    video_native_inf.compact_out */
                        .inf        (video_native_in1),
/*    axi_stream_inf.master*/
                        .axis       (axi_stream_in1),
/*  output[15:0]    */  .vactive    (vactive1    ),
/*  output[15:0]    */  .hactive    (hactive1    )
);
//---<< TEST COLOR PARTTEN >>-----------------
//---->> axi4 vdma to native for ddr3 <<-------------------
// user interface signals
logic[ADDR_WIDTH-1:0]                       app_addr;
logic[2:0]                                  app_cmd;
logic                                       app_en;
logic[DATA_WIDTH-1:0]                       app_wdf_data;
logic                                       app_wdf_end;
logic[(DATA_WIDTH/8)-1:0]                   app_wdf_mask;
logic                                       app_wdf_wren;
logic [DATA_WIDTH-1:0]                      app_rd_data;
logic                                       app_rd_data_end;
logic                                       app_rd_data_valid;
logic                                       app_rdy;
logic                                       app_wdf_rdy;
logic                                       app_sr_req;
logic                                       app_ref_req;
logic                                       app_zq_req;
logic                                       app_sr_active;
logic                                       app_ref_ack;
logic                                       app_zq_ack;
wire                                        init_calib_complete;
//---->> axi4 vdma to native for ddr3 <<-------------------
bit         ch0_rev_enable,ch1_rev_enable;
assign  ch0_rev_enable  = init_calib_complete;
assign  ch1_rev_enable  = init_calib_complete;

assign video_gen_0_en   = init_calib_complete;
assign video_gen_1_en   = init_calib_complete;

multiports_vdma_wrap #(
    .ASIZE          (ADDR_WIDTH     ),
    .AXI_DSIZE      (DATA_WIDTH     )
)multiports_vdma_wrap_inst(
/*  input                        */   .axi_aclk                (axi_aclk            ),
/*  input                        */   .axi_resetn              (axi_resetn          ),
    //--->> channal 0 <<-------
/*  input [15:0]                 */   .ch0_vactive             (vactive0            ),
/*  input [15:0]                 */   .ch0_hactive             (hactive0            ),
/*  input                        */   .ch0_in_fsync            (1'b0),
/*  input                        */   .ch0_rev_enable          (ch0_rev_enable      ),
/*  video_native_inf.compact_in  */   .ch0_vin                 (video_native_in0    ),   //native input port
/*  video_native_inf.compact_in  */   .ch0_vex                 (video_native_ex0    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch0_vout                (video_native_out0   ),   //native output
/*  axi_stream_inf.slaver        */   .ch0_axis_in             (axi_stream_in0      ),   // axis in
/*  axi_stream_inf.master        */   .ch0_axis_out            (axi_stream_out0     ),   // axi out
    //---<< channal 0 >>-------
    //--->> channal 1 <<-------
/*  input [15:0]                 */   .ch1_vactive             (vactive1            ),
/*  input [15:0]                 */   .ch1_hactive             (hactive1            ),
/*  input                        */   .ch1_in_fsync            (1'b0),
/*  input                        */   .ch1_rev_enable          (ch1_rev_enable      ),
/*  video_native_inf.compact_in  */   .ch1_vin                 (video_native_in1    ),   //native input port
/*  video_native_inf.compact_in  */   .ch1_vex                 (video_native_ex1    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch1_vout                (video_native_out1   ),   //native output
/*  axi_stream_inf.slaver        */   .ch1_axis_in             (axi_stream_in1      ),   // axis in
/*  axi_stream_inf.master        */   .ch1_axis_out            (axi_stream_out1     ),   // axi out
    //---<< channal 1 >>-------
    //--->> channal 2 <<-------
/*  video_native_inf.compact_in  */   .ch2_vin                 (video_native_in2    ),   //native input port
/*  video_native_inf.compact_in  */   .ch2_vex                 (video_native_ex2    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch2_vout                (video_native_out2   ),   //native output
/*  axi_stream_inf.slaver        */   .ch2_axis_in             (axi_stream_in2      ),   // axis in
/*  axi_stream_inf.master        */   .ch2_axis_out            (axi_stream_out2     ),   // axi out
    //---<< channal 2 >>-------
    //--->> channal 3 <<-------
/*  video_native_inf.compact_in  */   .ch3_vin                 (video_native_in3    ),   //native input port
/*  video_native_inf.compact_in  */   .ch3_vex                 (video_native_ex3    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch3_vout                (video_native_out3   ),   //native output
/*  axi_stream_inf.slaver        */   .ch3_axis_in             (axi_stream_in3      ),   // axis in
/*  axi_stream_inf.master        */   .ch3_axis_out            (axi_stream_out3     ),   // axi out
    //---<< channal 3 >>-------
    //--->> channal 4 <<-------
/*  video_native_inf.compact_in  */   .ch4_vin                 (video_native_in4    ),   //native input port
/*  video_native_inf.compact_in  */   .ch4_vex                 (video_native_ex4    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch4_vout                (video_native_out4   ),   //native output
/*  axi_stream_inf.slaver        */   .ch4_axis_in             (axi_stream_in4      ),   // axis in
/*  axi_stream_inf.master        */   .ch4_axis_out            (axi_stream_out4     ),   // axi out
    //---<< channal 4 >>-------
    //--->> channal 5 <<-------
/*  video_native_inf.compact_in  */   .ch5_vin                 (video_native_in5    ),   //native input port
/*  video_native_inf.compact_in  */   .ch5_vex                 (video_native_ex5    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch5_vout                (video_native_out5   ),   //native output
/*  axi_stream_inf.slaver        */   .ch5_axis_in             (axi_stream_in5      ),   // axis in
/*  axi_stream_inf.master        */   .ch5_axis_out            (axi_stream_out5     ),   // axi out
    //---<< channal 5 >>-------
    //--->> channal 6 <<-------
/*  video_native_inf.compact_in  */   .ch6_vin                 (video_native_in6    ),   //native input port
/*  video_native_inf.compact_in  */   .ch6_vex                 (video_native_ex6    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch6_vout                (video_native_out6   ),   //native output
/*  axi_stream_inf.slaver        */   .ch6_axis_in             (axi_stream_in6      ),   // axis in
/*  axi_stream_inf.master        */   .ch6_axis_out            (axi_stream_out6     ),   // axi out
    //---<< channal 6 >>-------
    //--->> channal 7 <<-------
/*  video_native_inf.compact_in  */   .ch7_vin                 (video_native_in7    ),   //native input port
/*  video_native_inf.compact_in  */   .ch7_vex                 (video_native_ex7    ),   //native output ex driver
/*  video_native_inf.compact_out */   .ch7_vout                (video_native_out7   ),   //native output
/*  axi_stream_inf.slaver        */   .ch7_axis_in             (axi_stream_in7      ),   // axis in
/*  axi_stream_inf.master        */   .ch7_axis_out            (axi_stream_out7     ),   // axi out
    //---<< channal 7 >>-------
    //--->> DDR IP APP <<------
/*  output logic[ASIZE-1:0]      */   .app_addr                (app_addr                ),
/*  output logic[2:0]            */   .app_cmd                 (app_cmd                 ),
/*  output logic                 */   .app_en                  (app_en                  ),
/*  output logic[AXI_DSIZE-1:0]  */   .app_wdf_data            (app_wdf_data            ),
/*  output logic                 */   .app_wdf_end             (app_wdf_end             ),
/*  output logic[AXI_DSIZE/8-1:0]*/   .app_wdf_mask            (app_wdf_mask            ),
/*  output logic                 */   .app_wdf_wren            (app_wdf_wren            ),
/*  input  [AXI_DSIZE-1:0]       */   .app_rd_data             (app_rd_data             ),
/*  input                        */   .app_rd_data_end         (app_rd_data_end         ),
/*  input                        */   .app_rd_data_valid       (app_rd_data_valid       ),
/*  input                        */   .app_rdy                 (app_rdy                 ),
/*  input                        */   .app_wdf_rdy             (app_wdf_rdy             ),
/*  input                        */   .init_calib_complete     (init_calib_complete     )
);
defparam multiports_vdma_wrap_inst.multiports_vdma_inst.CH0_PIX_DSIZE       = PIX_DSIZE_0;
defparam multiports_vdma_wrap_inst.multiports_vdma_inst.CH0_VIDEO_FORMAT    = VIDEO_FORMAT_0;
defparam multiports_vdma_wrap_inst.multiports_vdma_inst.CH1_PIX_DSIZE       = PIX_DSIZE_1;
defparam multiports_vdma_wrap_inst.multiports_vdma_inst.CH1_VIDEO_FORMAT    = VIDEO_FORMAT_1;
//----<< axi4 vdma to native for ddr3 >>-------------------
//---->> DDR3 IP <<----------
assign app_sr_req   = 1'b0;
assign app_ref_req  = 1'b0;
assign app_zq_req   = 1'b0;

DDR_NATIVE_512 u_DDR3_native (

    // Memory interface ports
    .ddr3_addr                      (ddr3_addr),  // output [13:0]		ddr3_addr
    .ddr3_ba                        (ddr3_ba),  // output [2:0]		ddr3_ba
    .ddr3_cas_n                     (ddr3_cas_n),  // output			ddr3_cas_n
    .ddr3_ck_n                      (ddr3_ck_n),  // output [0:0]		ddr3_ck_n
    .ddr3_ck_p                      (ddr3_ck_p),  // output [0:0]		ddr3_ck_p
    .ddr3_cke                       (ddr3_cke),  // output [0:0]		ddr3_cke
    .ddr3_ras_n                     (ddr3_ras_n),  // output			ddr3_ras_n
    .ddr3_reset_n                   (ddr3_reset_n),  // output			ddr3_reset_n
    .ddr3_we_n                      (ddr3_we_n),  // output			ddr3_we_n
    .ddr3_dq                        (ddr3_dq),  // inout [64:0]		ddr3_dq
    .ddr3_dqs_n                     (ddr3_dqs_n),  // inout [7:0]		ddr3_dqs_n
    .ddr3_dqs_p                     (ddr3_dqs_p),  // inout [7:0]		ddr3_dqs_p
    .init_calib_complete            (init_calib_complete),  // output			init_calib_complete

	.ddr3_cs_n                      (ddr3_cs_n),  // output [0:0]		ddr3_cs_n
    .ddr3_dm                        (ddr3_dm),  // output [7:0]		ddr3_dm
    .ddr3_odt                       (ddr3_odt),  // output [0:0]		ddr3_odt
    // Application interface ports
    .app_addr                       (app_addr),  // input [27:0]		app_addr
    .app_cmd                        (app_cmd),  // input [2:0]		app_cmd
    .app_en                         (app_en),  // input				app_en
    .app_wdf_data                   (app_wdf_data),  // input [512:0]		app_wdf_data
    .app_wdf_end                    (app_wdf_end),  // input				app_wdf_end
    .app_wdf_wren                   (app_wdf_wren),  // input				app_wdf_wren
    .app_rd_data                    (app_rd_data),  // output [512:0]		app_rd_data
    .app_rd_data_end                (app_rd_data_end),  // output			app_rd_data_end
    .app_rd_data_valid              (app_rd_data_valid),  // output			app_rd_data_valid
    .app_rdy                        (app_rdy),  // output			app_rdy
    .app_wdf_rdy                    (app_wdf_rdy),  // output			app_wdf_rdy
    .app_sr_req                     (app_sr_req ),  // input			app_sr_req
    .app_ref_req                    (app_ref_req),  // input			app_ref_req
    .app_zq_req                     (app_zq_req ),  // input			app_zq_req
    .app_sr_active                  (),  // output			app_sr_active
    .app_ref_ack                    (),  // output			app_ref_ack
    .app_zq_ack                     (),  // output			app_zq_ack
    .ui_clk                         (app_clk),  // output			ui_clk
    .ui_clk_sync_rst                (app_sync_rst),  // output			ui_clk_sync_rst
    .app_wdf_mask                   (app_wdf_mask),  // input [63:0]		app_wdf_mask
    // System Clock Ports
    .sys_clk_i                      (clk_200M),
    // Reference Clock Ports
    // .clk_ref_i                      (clk_200M),
    .sys_rst                        (sys_rst) // input sys_rst
);
//----<< DDR3 IP >>----------
assign  hdmi_vs   = video_native_out0.vsync;
assign  hdmi_hs   = video_native_out0.hsync;
assign  hdmi_de   = video_native_out0.de;
assign  hdmi_data = video_native_out0.data;

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
) hdmi_clk_inst (
  .Q        (hdmi_clk),   // 1-bit DDR output
  .C        (pclk),   // 1-bit clock input
  .CE       (1), // 1-bit clock enable input
  .D1       (0), // 1-bit data input (positive edge)
  .D2       (1), // 1-bit data input (negative edge)
  .R        (0),   // 1-bit reset
  .S        (0)    // 1-bit set
);

assign LED_0    = video_native_out0.vsync;

endmodule
