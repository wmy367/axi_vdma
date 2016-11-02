/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/10/31 上午10:25:14
madified:
***********************************************/
`timescale 1ns/1ps
module multiports_vdms_512bit_tb_1031(
);
localparam
            PIX_DSIZE_0    =   24,
            PIX_DSIZE_1    =   24,
            VIDEO_FORMAT_0 =   "TEST",
            VIDEO_FORMAT_1 =   "TEST",
            VDMA_PORT0_EN  =   1,
            VDMA_PORT1_EN  =   0;
//--->> PLL SIM MODEL <<---------------
bit         pclk;
bit         prst_n;

bit         clk_50M ;
bit         clk_200M;

bit         sys_rst;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(50      	)
)clock_rst_axi_mm(
	.clock			(clk_50M	),
	.rst_x			(sys_rst	)
);

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(200      	)
)clock_rst_axi_stream(
	.clock			(clk_200M	),
	.rst_x			(	)
);

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);
//---<< PLL SIM MODEL >>---------------


bit         app_clk  ;
bit         app_sync_rst  ;

assign      axi_aclk    = app_clk;
assign      axi_resetn  = !app_sync_rst;

//--->> interface define <<-------------------
`include "C:/Users/wmy367/Documents/GitHub/axi_vdma/multiports_vdma_tb_1028_inf_def.svi"
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
/*    input       */    .enable     (video_gen_1_en    ),
/*    video_native_inf.compact_out */
                        .inf        (video_native_in1),
/*    axi_stream_inf.master*/
                        .axis       (axi_stream_in1),
/*  output[15:0]    */  .vactive    (vactive1    ),
/*  output[15:0]    */  .hactive    (hactive1    )
);
//---<< TEST COLOR PARTTEN >>-----------------
localparam      ADDR_WIDTH  = 28,
                DATA_WIDTH  = 512;
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
//---->> axi4 vdma to native for ddr3 <<-------------------
bit         ch0_rev_enable,ch1_rev_enable;
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

// logic [12:0]	ddr3_addr    ;
// logic [2:0]		ddr3_ba      ;
// logic			ddr3_cas_n   ;
// logic [0:0]		ddr3_ck_n    ;
// logic [0:0]		ddr3_ck_p    ;
// logic [0:0]		ddr3_cke     ;
// logic			ddr3_ras_n   ;
// logic			ddr3_reset_n ;
// logic			ddr3_we_n    ;
// wire [31:0]		ddr3_dq      ;
// wire [3:0]		ddr3_dqs_n   ;
// wire [3:0]		ddr3_dqs_p   ;
// logic [0:0]		ddr3_cs_n    ;
// logic [3:0]		ddr3_dm      ;
// logic [0:0]		ddr3_odt     ;

wire [63:0]      ddr3_dq;
wire [7:0]       ddr3_dqs_n;
wire [7:0]       ddr3_dqs_p;
logic[13:0]      ddr3_addr;
logic[2:0]       ddr3_ba;
logic            ddr3_ras_n;
logic            ddr3_cas_n;
logic            ddr3_we_n;
logic            ddr3_reset_n;
logic[0:0]       ddr3_ck_p;
logic[0:0]       ddr3_ck_n;
logic[0:0]       ddr3_cke;
logic[0:0]       ddr3_cs_n;
logic[7:0]       ddr3_dm;
logic[0:0]       ddr3_odt;

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
    .sys_clk_i                      (clk_50M),
    // Reference Clock Ports
    .clk_ref_i                      (clk_200M),
    .sys_rst                        (sys_rst) // input sys_rst
);
//----<< DDR3 IP >>----------
//---->> DDR3 MODEL ARRAY <<-----
ddr3_dimm_model ddr3_dimm_model_inst (
/*  inout [DQ_WIDTH-1:0]        */        .ddr3_dq_fpga             (ddr3_dq                ),
/*  inout [DQS_WIDTH-1:0]       */        .ddr3_dqs_n_fpga          (ddr3_dqs_n             ),
/*  inout [DQS_WIDTH-1:0]       */        .ddr3_dqs_p_fpga          (ddr3_dqs_p             ),
/*  output[ROW_WIDTH-1:0]       */        .ddr3_addr_fpga           (ddr3_addr              ),
/*  output[3-1:0]               */        .ddr3_ba_fpga             (ddr3_ba                ),
/*  output                      */        .ddr3_ras_n_fpga          (ddr3_ras_n             ),
/*  output                      */        .ddr3_cas_n_fpga          (ddr3_cas_n             ),
/*  output                      */        .ddr3_we_n_fpga           (ddr3_we_n              ),
/*  output                      */        .ddr3_reset_n             (ddr3_reset_n           ),
/*  output[1-1:0]               */        .ddr3_ck_p_fpga           (ddr3_ck_p              ),
/*  output[1-1:0]               */        .ddr3_ck_n_fpga           (ddr3_ck_n              ),
/*  output[1-1:0]               */        .ddr3_cke_fpga            (ddr3_cke               ),
/*  output[(CS_WIDTH*1)-1:0]    */        .ddr3_cs_n_fpga           (ddr3_cs_n              ),
/*  output[DM_WIDTH-1:0]        */        .ddr3_dm_fpga             (ddr3_dm                ),
/*  output[ODT_WIDTH-1:0]       */        .ddr3_odt_fpga            (ddr3_odt               )
);
//----<< DDR3 MODEL ARRAY >>-----
//---->> SIM CONTROL <<----------
initial begin
    ch0_rev_enable = 0;
    wait(init_calib_complete);
    video_gen_0_en  = VDMA_PORT0_EN;
    repeat(2)begin
        @(negedge video_native_in0.de);
    end
    ch0_rev_enable = VDMA_PORT0_EN;
    // rev_enable0 = 0;
end

initial begin
    ch1_rev_enable = 0;
    wait(init_calib_complete);
    video_gen_1_en  = VDMA_PORT1_EN;
    repeat(2)begin
        @(negedge video_native_in1.de);
    end
    ch1_rev_enable = VDMA_PORT1_EN;
    // rev_enable0 = 0;
end
//----<< SIM CONTROL >>----------

endmodule
