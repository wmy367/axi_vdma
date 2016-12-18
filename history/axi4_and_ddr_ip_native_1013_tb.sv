/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/10/13 上午8:58:07
madified:
***********************************************/
`timescale 1ns/1ps
`define USE_DDR3_IP_CORE
module axi4_and_ddr_ip_native_1013_tb;
localparam VIDEO_FORMAT     = "TEST";
localparam  WR_THRESHOLD    = 100,
            RD_THRESHOLD    = 100,
            THRESHOLD       = 100,
            ASIZE           = 29,
            PIX_DSIZE       = 16,
            AXI_DSIZE       = 256,
            STO_MODE        = "ONCE",   //ONCE LINE
            STORAGE_MODE    = STO_MODE,
            FRAME_SYNC      = "OFF",        //only for axi_stream
            DATA_TYPE       = "AXIS",     //NATIVE AXIS
            IN_DATA_TYPE    = "NATIVE",
            OUT_DATA_TYPE   = "NATIVE",
            BURST_LEN_SIZE  = 8 ,
            VDMA_PORT0_EN   = 1,
            VDMA_PORT1_EN   = 1;
//----->> CLOCK RST <<-------------------
bit         init_calib_complete;
bit         video_gen_0_en = 0;
bit         video_gen_1_en = 0;

bit         axi_aclk;
bit         axi_resetn;

bit         aclk;
bit         aresetn;

bit         pclk;
bit         prst_n;

bit         clk_50M ;
bit         clk_200M;

bit         app_clk  ;
bit         app_sync_rst  ;

assign      axi_aclk    = app_clk;
assign      axi_resetn  = !app_sync_rst;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(50      	)
)clock_rst_axi_mm(
	.clock			(clk_50M	),
	.rst_x			(	)
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
//------<< CLOCK RST >>-----------------------

axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (29              ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (256             )
)axi_s00_inf(axi_aclk,axi_resetn);

axi_inf #(
    .IDSIZE    (1               ),
    .ASIZE     (29              ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (256             )
)axi_s01_inf(axi_aclk,axi_resetn);

axi_inf #(
    .IDSIZE    (4               ),
    .ASIZE     (29              ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (256             )
)axi_m00_inf(axi_aclk,axi_resetn);

axi4_interconnect_wrap axi4_interconnect_wrap_inst(
/*    input          */  .INTERCONNECT_ACLK    (axi_aclk            ),
/*    input          */  .INTERCONNECT_ARESETN (axi_resetn          ),
/*    output         */  .S00_AXI_ARESET_OUT_N (                    ),
/*    output         */  .S01_AXI_ARESET_OUT_N (                    ),
/*    output         */  .M00_AXI_ARESET_OUT_N (                    ),
/*    axi_inf.slaver */  .s00_inf              (axi_s00_inf         ),
/*    axi_inf.slaver */  .s01_inf              (axi_s01_inf         ),
/*    axi_inf.master */  .m00_inf              (axi_m00_inf         )
);
//---->> INTERFACE DEFINE <<----------------
video_native_inf #(
    .DSIZE  (PIX_DSIZE)
)video_native_inf0(
    .pclk       (pclk   ),
    .prst_n     (prst_n )
);

axi_stream_inf #(
    .DSIZE  (PIX_DSIZE)
)axi_stream_inf0(
/*  input bit */  .aclk         (pclk   ),
/*  input bit */  .aresetn      (prst_n ),
/*  input bit */  .aclken       (1'b1   )
);

video_native_inf #(
    .DSIZE  (PIX_DSIZE)
)video_native_ex0(
    .pclk       (pclk   ),
    .prst_n     (prst_n )
);

video_native_inf #(
    .DSIZE  (PIX_DSIZE)
)video_native_out0(
    .pclk       (pclk   ),
    .prst_n     (prst_n )
);

axi_stream_inf #(
    .DSIZE  (PIX_DSIZE)
)axi_stream_ex0(
/*  input bit */  .aclk         (pclk   ),
/*  input bit */  .aresetn      (prst_n ),
/*  input bit */  .aclken       (VDMA_PORT0_EN   )
);
assign axi_stream_ex0.axi_tready    = 1'b1;

axi_stream_inf #(
    .DSIZE  (PIX_DSIZE)
)axi_stream_tmp_ex0(
/*  input bit */  .aclk         (pclk   ),
/*  input bit */  .aresetn      (prst_n ),
/*  input bit */  .aclken       (1'b1   )
);
vdma_baseaddr_ctrl_inf port0_ba();
vdma_baseaddr_ctrl_inf port0_ba_tmp1();
vdma_baseaddr_ctrl_inf port0_ba_tmp2();
vdma_baseaddr_ctrl_inf port0_ba_tmp3();
//----<< INTERFACE DEFINE >>----------------
logic[15:0]     vactive0;
logic[15:0]     hactive0;
simple_video_gen #(
    .MODE   (VIDEO_FORMAT   ),
    .DSIZE  (PIX_DSIZE      )
)simple_video_gen_inst0(
/*    input       */    .enable (video_gen_0_en    ),
/*    video_native_inf.compact_out */
                        .inf    (video_native_inf0),
/*    axi_stream_inf.master*/
                        .axis   (axi_stream_inf0)
);

assign vactive0 = simple_video_gen_inst0.video_sync_generator_inst.V_ACTIVE;
assign hactive0 = simple_video_gen_inst0.video_sync_generator_inst.H_ACTIVE;

logic video_native_ex0_en;

simple_video_gen #(
    .MODE   (VIDEO_FORMAT ),
    .DSIZE  (PIX_DSIZE      )
)simple_video_gen_ex0(
/*    input       */    .enable (video_native_ex0_en ),
/*    video_native_inf.compact_out */
                        .inf    (video_native_ex0),
/*    axi_stream_inf.master*/
                        .axis   (axi_stream_tmp_ex0)
);

initial begin
    video_native_ex0_en = 0;
    repeat(2)
        @(video_native_inf0.de);
    video_native_ex0_en = 1;
end

logic rev_enable0;

vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (29      ),
    .BURST_LEN_SIZE    (9       ),
    .PIX_DSIZE         (PIX_DSIZE      ),
    .AXI_DSIZE         (256     ),
    .IDSIZE            (1       ),
    .ID                (0       ),
    .STORAGE_MODE      (STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     ("OFF"   ), //OFF ON
    .OUT_FRAME_SYNC    ("OFF"   ), //OFF ON
    //-->> JUST FOR OUT <<------
    .EX_SYNC           ("OFF"   ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (VIDEO_FORMAT),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         ("BOTH"  ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (0       ),
    .BASE_ADDR_1       (0       ),
    .BASE_ADDR_2       (0       ),
    .BASE_ADDR_3       (0       ),
    .BASE_ADDR_4       (0       ),
    .BASE_ADDR_5       (0       ),
    .BASE_ADDR_6       (0       ),
    .BASE_ADDR_7       (0       )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst(
/*  input [15:0]   */   .vactive                (   vactive0),
/*  input [15:0]   */   .hactive                (   hactive0),
/*  input          */   .in_fsync               (   1'b0),
/*  input          */   .rev_enable             (   rev_enable0),
    //native input port
/*  video_native_inf.compact_in */ .vin         (video_native_inf0  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (video_native_ex0   ),
    //native output
/*  video_native_inf.compact_out */.vout        (video_native_out0  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (axi_stream_inf0),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (axi_stream_ex0 ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s00_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (port0_ba_tmp3  ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (port0_ba   ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (port0_ba_tmp1  ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (port0_ba_tmp2  )
);
generate
if(PIX_DSIZE==24)begin
probe_large_width_data wr_probe_large_width_data_inst(
/*  input             */  .clock               (axi_s00_inf.axi_aclk        ),
/*  input             */  .rst                 (!axi_s00_inf.axi_resetn     ),
/*  input [DSIZE-1:0] */  .data                (axi_s00_inf.axi_wdata       ),
/*  input             */  .valid               (axi_s00_inf.axi_wvalid      ),
/*  input             */  .sync                (axi_s00_inf.axi_bvalid && axi_s00_inf.axi_awlen==0),
/*  input             */  .sync_negedge        (),
/*  input             */  .sync_posedge        ()
);
end
endgenerate

//---->> INTERFACE DEFINE <<----------------
video_native_inf #(
    .DSIZE  (PIX_DSIZE)
)video_native_inf1(
    .pclk       (pclk   ),
    .prst_n     (prst_n )
);

axi_stream_inf #(
    .DSIZE  (PIX_DSIZE)
)axi_stream_inf1(
/*  input bit */  .aclk         (pclk   ),
/*  input bit */  .aresetn      (prst_n ),
/*  input bit */  .aclken       (1'b1   )
);

video_native_inf #(
    .DSIZE  (PIX_DSIZE)
)video_native_ex1(
    .pclk       (pclk   ),
    .prst_n     (prst_n )
);

video_native_inf #(
    .DSIZE  (PIX_DSIZE)
)video_native_out1(
    .pclk       (pclk   ),
    .prst_n     (prst_n )
);

axi_stream_inf #(
    .DSIZE  (PIX_DSIZE)
)axi_stream_ex1(
/*  input bit */  .aclk         (pclk   ),
/*  input bit */  .aresetn      (prst_n ),
/*  input bit */  .aclken       (1'b1   )
);
assign axi_stream_ex1.axi_tready    = 1'b1;

axi_stream_inf #(
    .DSIZE  (PIX_DSIZE)
)axi_stream_tmp_ex1(
/*  input bit */  .aclk         (pclk   ),
/*  input bit */  .aresetn      (prst_n ),
/*  input bit */  .aclken       (1'b1   )
);

vdma_baseaddr_ctrl_inf port1_ba_tmp1();
vdma_baseaddr_ctrl_inf port1_ba_tmp2();
vdma_baseaddr_ctrl_inf port1_ba_tmp3();
//----<< INTERFACE DEFINE >>----------------
logic[15:0] hactive1;
logic[15:0] vactive1;

simple_video_gen #(
    .MODE   (VIDEO_FORMAT ),
    .DSIZE  (PIX_DSIZE      )
)simple_video_gen_inst1(
/*    input       */    .enable (video_gen_1_en    ),
/*    video_native_inf.compact_out */
                        .inf    (video_native_inf1),
/*    axi_stream_inf.master*/
                        .axis   (axi_stream_inf1)
);

assign vactive1 = simple_video_gen_inst1.video_sync_generator_inst.V_ACTIVE;
assign hactive1 = simple_video_gen_inst1.video_sync_generator_inst.H_ACTIVE;

logic video_native_ex1_en;

simple_video_gen #(
    .MODE   (VIDEO_FORMAT ),
    .DSIZE  (PIX_DSIZE      )
)simple_video_gen_ex1(
/*    input       */    .enable (video_native_ex1_en ),
/*    video_native_inf.compact_out */
                        .inf    (video_native_ex1),
/*    axi_stream_inf.master*/
                        .axis   (axi_stream_tmp_ex1)
);

initial begin
    video_native_ex1_en = 0;
    repeat(2)
        @(video_native_inf1.de);
    video_native_ex1_en = 1;
end

logic   rev_enable1;

vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (29      ),
    .BURST_LEN_SIZE    (9       ),
    .PIX_DSIZE         (PIX_DSIZE      ),
    .AXI_DSIZE         (256     ),
    .IDSIZE            (1       ),
    .ID                (0       ),
    .STORAGE_MODE      (STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     ("OFF"   ), //OFF ON
    .OUT_FRAME_SYNC    ("OFF"   ), //OFF ON
    //-->> JUST FOR OUT <<------
    .EX_SYNC           ("OFF"   ),     //OFF ON
    .VIDEO_FORMAT      (VIDEO_FORMAT),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         ("BOTH"  ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (1024*8*8*1024       ),
    .BASE_ADDR_1       (1024*8*8*1024       ),
    .BASE_ADDR_2       (1024*8*8*1024       ),
    .BASE_ADDR_3       (1024*8*8*1024       ),
    .BASE_ADDR_4       (1024*8*8*1024       ),
    .BASE_ADDR_5       (1024*8*8*1024       ),
    .BASE_ADDR_6       (1024*8*8*1024       ),
    .BASE_ADDR_7       (1024*8*8*1024       )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst1(
/*  input [15:0]   */   .vactive                (vactive1   ),
/*  input [15:0]   */   .hactive                (hactive1   ),
/*  input          */   .in_fsync               (1'b0       ),
/*  input          */   .rev_enable             (rev_enable1   ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (video_native_inf1  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (video_native_ex1   ),
    //native output
/*  video_native_inf.compact_out */.vout        (video_native_out1  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (axi_stream_inf1),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (axi_stream_ex1 ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s01_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (port0_ba   ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (port1_ba_tmp3),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (port1_ba_tmp1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (port1_ba_tmp2)
);
`ifdef USE_DDR3_IP_CORE

DDR3_IP_NATIVE_CORE_WITH_MODE DDR3_IP_NATIVE_CORE_WITH_MODE_inst(
    // Single-ended system clock
/*    input                  */                      .sys_clk_i                 (clk_50M        ),
    // Single-ended iodelayctrl clk (reference clock)
/*    input                  */                      .clk_ref_i                 (clk_200M       ),
    // user interface signals
/*    output                 */                      .app_clk                   (app_clk        ),
/*    output                 */                      .app_sync_rst              (app_sync_rst   ),
    // Slave Interface Write Address Ports
/*    axi_inf.slaver         */                      .axi_inf                   (axi_m00_inf    ),
/*    output                 */                      .init_calib_complete       (init_calib_complete)
);

defparam DDR3_IP_NATIVE_CORE_WITH_MODE_inst.mem_rnk[0].mem.gen_mem[0].u_comp_ddr3.DEBUG = 0;
defparam DDR3_IP_NATIVE_CORE_WITH_MODE_inst.mem_rnk[0].mem.gen_mem[1].u_comp_ddr3.DEBUG = 0;
// defparam DDR3_IP_NATIVE_CORE_WITH_MODE_inst.mem_rnk[0].gen_mem[2].u_comp_ddr3.DEBUG = 0;
// defparam DDR3_IP_NATIVE_CORE_WITH_MODE_inst.mem_rnk[0].gen_mem[3].u_comp_ddr3.DEBUG = 0;

axi_mirror #(
    .ASIZE      (29     ),
    .DSIZE      (256    ),
    .IDSIZE     (4      ),
    .LSIZE      (BURST_LEN_SIZE),
    .ID         (0      ),
    .ADDR_STEP  (1      ),
    .LOCK_ID    ("OFF"  ),
    .REV_SAVE_TOTAL     (1000),
    .TRS_SAVE_TOTAL     (1000),
    .REV_SAVE_NAME      ("mirror_rev.txt"),     // slaver rev:axi_wdata
    .TRS_SAVE_NAME      ("mirror_trs.txt"),     // slaver trs:axi_rdata
    .SAVE_SPLIT         (PIX_DSIZE       )
)axi_mirror_inst(
    .inf        (axi_m00_inf)
);

initial begin
    axi_mirror_inst.slaver_recieve_burst(100);
end

initial begin
    @(posedge video_native_inf0.vsync);
    repeat(20) @(posedge video_native_inf0.pclk)
    axi_mirror_inst.slaver_transmit_busrt(100);
end

initial begin
    rev_enable0 = 0;
    wait(init_calib_complete);
    video_gen_0_en  = VDMA_PORT0_EN;
    repeat(2)begin
        @(negedge video_native_inf0.de);
    end
    rev_enable0 = VDMA_PORT0_EN;
    // rev_enable0 = 0;
end

initial begin
    rev_enable1 = 0;
    wait(init_calib_complete);
    video_gen_1_en  = VDMA_PORT1_EN;
    repeat(3)begin
        @(negedge video_native_inf1.de);
    end
    rev_enable1 = VDMA_PORT1_EN;
    //rev_enable1 = 0;
end

//--->> RECORD FIFO <<----------
int tmp_cnt;
always@(posedge  DDR3_IP_NATIVE_CORE_WITH_MODE_inst.u_ip_top.axi4_to_native_for_ddr_ip_inst.FIFO_DDR_IP_BRG_wr.wr_en)begin
    tmp_cnt <= 1;
end

always@(negedge  DDR3_IP_NATIVE_CORE_WITH_MODE_inst.u_ip_top.axi4_to_native_for_ddr_ip_inst.FIFO_DDR_IP_BRG_wr.wr_en)begin
    tmp_cnt <= 0;
end

always@(posedge app_clk)begin
    if(DDR3_IP_NATIVE_CORE_WITH_MODE_inst.u_ip_top.axi4_to_native_for_ddr_ip_inst.FIFO_DDR_IP_BRG_wr.wr_en)
        tmp_cnt <= tmp_cnt + 1;
end

`else

clock_rst_verb #(
	.ACTIVE			(1			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100      	)
)clock_rst_axi4(
	.clock			(app_clk	),
	.rst_x			(app_sync_rst	)
);

axi_slaver #(
    .ASIZE  (ASIZE         ),
    .DSIZE  (AXI_DSIZE     ),
    .LSIZE  (BURST_LEN_SIZE),
    .ADDR_STEP  (8*4    ),
    .MUTEX_WR_RD("ON")
)axi_slaver_inst(
    .inf        (axi_m00_inf)
);

initial begin
    @(posedge negedge video_native_inf0.vsync);
    repeat(20) @(posedge negedge video_native_inf0.pclk)
    axi_slaver_inst.slaver_recieve_burst(1000);
end

initial begin
    axi_slaver_inst.slaver_transmit_busrt(1000);
end

initial begin
    rev_enable0 = 0;
    rev_enable1 = 0;
    axi_slaver_inst.wait_rev_enough_data(238*2);
    // axi_slaver_inst.save_cache_data(PIX_DSIZE);
    rev_enable0 = VDMA_PORT0_EN;
    rev_enable1 = VDMA_PORT1_EN;
    axi_slaver_inst.wait_rev_enough_data(1000);
    axi_slaver_inst.save_cache_data(PIX_DSIZE);
end

initial begin
    repeat(100) @(posedge app_clk);
    video_gen_0_en  = VDMA_PORT0_EN;
end

initial begin
    repeat(100) @(posedge app_clk);
    video_gen_1_en  = VDMA_PORT1_EN;
end

`endif

// initial begin
//     @(posedge init_calib_complete);
//     $stop;
// end

endmodule
