/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/26 下午3:16:31
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_interconnet_with_ddr_tb;
localparam VIDEO_FORMAT     = "TEST";
localparam  WR_THRESHOLD    = 100,
            RD_THRESHOLD    = 100,
            THRESHOLD       = 100,
            ASIZE           = 29,
            PIX_DSIZE       = 32,
            AXI_DSIZE       = 256,
            STO_MODE        = "ONCE",
            FRAME_SYNC      = "OFF",        //only for axi_stream
            DATA_TYPE       = "AXIS",     //NATIVE AXIS
            BURST_LEN_SIZE  = 8 ;
//----->> CLOCK RST <<-------------------
bit         axi_aclk;
bit         axi_resetn;

bit         aclk;
bit         aresetn;

bit         pclk;
bit         prst_n;

bit         clk_50M ;
bit         clk_200M;

bit         ui_clk  ;
bit         ui_rst  ;

assign      axi_aclk    = ui_clk;
assign      axi_resetn  = !ui_rst;

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

AXI4_INFCNT AXI4_INFCNT_inst(
/*  input          */   .INTERCONNECT_ACLK               (axi_aclk                   ),
/*  input          */   .INTERCONNECT_ARESETN            (axi_resetn                 ),
/*  output         */   .S00_AXI_ARESET_OUT_N            (                           ),
/*  input          */   .S00_AXI_ACLK                    (axi_s00_inf.axi_aclk       ),
/*  input [0:0]    */   .S00_AXI_AWID                    (axi_s00_inf.axi_awid       ),
/*  input [28:0]   */   .S00_AXI_AWADDR                  (axi_s00_inf.axi_awaddr     ),
/*  input [7:0]    */   .S00_AXI_AWLEN                   (axi_s00_inf.axi_awlen      ),
/*  input [2:0]    */   .S00_AXI_AWSIZE                  (axi_s00_inf.axi_awsize     ),
/*  input [1:0]    */   .S00_AXI_AWBURST                 (axi_s00_inf.axi_awburst    ),
/*  input          */   .S00_AXI_AWLOCK                  (axi_s00_inf.axi_awlock     ),
/*  input [3:0]    */   .S00_AXI_AWCACHE                 (axi_s00_inf.axi_awcache    ),
/*  input [2:0]    */   .S00_AXI_AWPROT                  (axi_s00_inf.axi_awprot     ),
/*  input [3:0]    */   .S00_AXI_AWQOS                   (axi_s00_inf.axi_awqos      ),
/*  input          */   .S00_AXI_AWVALID                 (axi_s00_inf.axi_awvalid    ),
/*  output         */   .S00_AXI_AWREADY                 (axi_s00_inf.axi_awready    ),
/*  input [255:0]  */   .S00_AXI_WDATA                   (axi_s00_inf.axi_wdata      ),
/*  input [31:0]   */   .S00_AXI_WSTRB                   (axi_s00_inf.axi_wstrb      ),
/*  input          */   .S00_AXI_WLAST                   (axi_s00_inf.axi_wlast      ),
/*  input          */   .S00_AXI_WVALID                  (axi_s00_inf.axi_wvalid     ),
/*  output         */   .S00_AXI_WREADY                  (axi_s00_inf.axi_wready     ),
/*  output [0:0]   */   .S00_AXI_BID                     (axi_s00_inf.axi_bid        ),
/*  output [1:0]   */   .S00_AXI_BRESP                   (axi_s00_inf.axi_bresp      ),
/*  output         */   .S00_AXI_BVALID                  (axi_s00_inf.axi_bvalid     ),
/*  input          */   .S00_AXI_BREADY                  (axi_s00_inf.axi_bready     ),
/*  input [0:0]    */   .S00_AXI_ARID                    (axi_s00_inf.axi_arid       ),
/*  input [28:0]   */   .S00_AXI_ARADDR                  (axi_s00_inf.axi_araddr     ),
/*  input [7:0]    */   .S00_AXI_ARLEN                   (axi_s00_inf.axi_arlen      ),
/*  input [2:0]    */   .S00_AXI_ARSIZE                  (axi_s00_inf.axi_arsize     ),
/*  input [1:0]    */   .S00_AXI_ARBURST                 (axi_s00_inf.axi_arburst    ),
/*  input          */   .S00_AXI_ARLOCK                  (axi_s00_inf.axi_arlock     ),
/*  input [3:0]    */   .S00_AXI_ARCACHE                 (axi_s00_inf.axi_arcache    ),
/*  input [2:0]    */   .S00_AXI_ARPROT                  (axi_s00_inf.axi_arprot     ),
/*  input [3:0]    */   .S00_AXI_ARQOS                   (axi_s00_inf.axi_arqos      ),
/*  input          */   .S00_AXI_ARVALID                 (axi_s00_inf.axi_arvalid    ),
/*  output         */   .S00_AXI_ARREADY                 (axi_s00_inf.axi_arready    ),
/*  output [0:0]   */   .S00_AXI_RID                     (axi_s00_inf.axi_rid        ),
/*  output [255:0] */   .S00_AXI_RDATA                   (axi_s00_inf.axi_rdata      ),
/*  output [1:0]   */   .S00_AXI_RRESP                   (axi_s00_inf.axi_rresp      ),
/*  output         */   .S00_AXI_RLAST                   (axi_s00_inf.axi_rlast      ),
/*  output         */   .S00_AXI_RVALID                  (axi_s00_inf.axi_rvalid     ),
/*  input          */   .S00_AXI_RREADY                  (axi_s00_inf.axi_rready     ),
/*  output S01_AXI_*/   .S01_AXI_ARESET_OUT_N            (),
/*  input          */   .S01_AXI_ACLK                    (axi_s01_inf.axi_aclk       ),
/*  input [0:0]    */   .S01_AXI_AWID                    (axi_s01_inf.axi_awid       ),
/*  input [28:0]   */   .S01_AXI_AWADDR                  (axi_s01_inf.axi_awaddr     ),
/*  input [7:0]    */   .S01_AXI_AWLEN                   (axi_s01_inf.axi_awlen      ),
/*  input [2:0]    */   .S01_AXI_AWSIZE                  (axi_s01_inf.axi_awsize     ),
/*  input [1:0]    */   .S01_AXI_AWBURST                 (axi_s01_inf.axi_awburst    ),
/*  input          */   .S01_AXI_AWLOCK                  (axi_s01_inf.axi_awlock     ),
/*  input [3:0]    */   .S01_AXI_AWCACHE                 (axi_s01_inf.axi_awcache    ),
/*  input [2:0]    */   .S01_AXI_AWPROT                  (axi_s01_inf.axi_awprot     ),
/*  input [3:0]    */   .S01_AXI_AWQOS                   (axi_s01_inf.axi_awqos      ),
/*  input          */   .S01_AXI_AWVALID                 (axi_s01_inf.axi_awvalid    ),
/*  output         */   .S01_AXI_AWREADY                 (axi_s01_inf.axi_awready    ),
/*  input [255:0]  */   .S01_AXI_WDATA                   (axi_s01_inf.axi_wdata      ),
/*  input [31:0]   */   .S01_AXI_WSTRB                   (axi_s01_inf.axi_wstrb      ),
/*  input          */   .S01_AXI_WLAST                   (axi_s01_inf.axi_wlast      ),
/*  input          */   .S01_AXI_WVALID                  (axi_s01_inf.axi_wvalid     ),
/*  output         */   .S01_AXI_WREADY                  (axi_s01_inf.axi_wready     ),
/*  output [0:0]   */   .S01_AXI_BID                     (axi_s01_inf.axi_bid        ),
/*  output [1:0]   */   .S01_AXI_BRESP                   (axi_s01_inf.axi_bresp      ),
/*  output         */   .S01_AXI_BVALID                  (axi_s01_inf.axi_bvalid     ),
/*  input          */   .S01_AXI_BREADY                  (axi_s01_inf.axi_bready     ),
/*  input [0:0]    */   .S01_AXI_ARID                    (axi_s01_inf.axi_arid       ),
/*  input [28:0]   */   .S01_AXI_ARADDR                  (axi_s01_inf.axi_araddr     ),
/*  input [7:0]    */   .S01_AXI_ARLEN                   (axi_s01_inf.axi_arlen      ),
/*  input [2:0]    */   .S01_AXI_ARSIZE                  (axi_s01_inf.axi_arsize     ),
/*  input [1:0]    */   .S01_AXI_ARBURST                 (axi_s01_inf.axi_arburst    ),
/*  input          */   .S01_AXI_ARLOCK                  (axi_s01_inf.axi_arlock     ),
/*  input [3:0]    */   .S01_AXI_ARCACHE                 (axi_s01_inf.axi_arcache    ),
/*  input [2:0]    */   .S01_AXI_ARPROT                  (axi_s01_inf.axi_arprot     ),
/*  input [3:0]    */   .S01_AXI_ARQOS                   (axi_s01_inf.axi_arqos      ),
/*  input          */   .S01_AXI_ARVALID                 (axi_s01_inf.axi_arvalid    ),
/*  output         */   .S01_AXI_ARREADY                 (axi_s01_inf.axi_arready    ),
/*  output [0:0]   */   .S01_AXI_RID                     (axi_s01_inf.axi_rid        ),
/*  output [255:0] */   .S01_AXI_RDATA                   (axi_s01_inf.axi_rdata      ),
/*  output [1:0]   */   .S01_AXI_RRESP                   (axi_s01_inf.axi_rresp      ),
/*  output         */   .S01_AXI_RLAST                   (axi_s01_inf.axi_rlast      ),
/*  output         */   .S01_AXI_RVALID                  (axi_s01_inf.axi_rvalid     ),
/*  input          */   .S01_AXI_RREADY                  (axi_s01_inf.axi_rready     ),
/*  output         */   .M00_AXI_ARESET_OUT_N            (),
/*  input          */   .M00_AXI_ACLK                    (axi_m00_inf.axi_aclk           ),
/*  output [3:0]   */   .M00_AXI_AWID                    (axi_m00_inf.axi_awid           ),
/*  output [28:0]  */   .M00_AXI_AWADDR                  (axi_m00_inf.axi_awaddr         ),
/*  output [7:0]   */   .M00_AXI_AWLEN                   (axi_m00_inf.axi_awlen          ),
/*  output [2:0]   */   .M00_AXI_AWSIZE                  (axi_m00_inf.axi_awsize         ),
/*  output [1:0]   */   .M00_AXI_AWBURST                 (axi_m00_inf.axi_awburst        ),
/*  output         */   .M00_AXI_AWLOCK                  (axi_m00_inf.axi_awlock         ),
/*  output [3:0]   */   .M00_AXI_AWCACHE                 (axi_m00_inf.axi_awcache        ),
/*  output [2:0]   */   .M00_AXI_AWPROT                  (axi_m00_inf.axi_awprot         ),
/*  output [3:0]   */   .M00_AXI_AWQOS                   (axi_m00_inf.axi_awqos          ),
/*  output         */   .M00_AXI_AWVALID                 (axi_m00_inf.axi_awvalid        ),
/*  input          */   .M00_AXI_AWREADY                 (axi_m00_inf.axi_awready        ),
/*  output [255:0] */   .M00_AXI_WDATA                   (axi_m00_inf.axi_wdata          ),
/*  output [31:0]  */   .M00_AXI_WSTRB                   (axi_m00_inf.axi_wstrb          ),
/*  output         */   .M00_AXI_WLAST                   (axi_m00_inf.axi_wlast          ),
/*  output         */   .M00_AXI_WVALID                  (axi_m00_inf.axi_wvalid         ),
/*  input          */   .M00_AXI_WREADY                  (axi_m00_inf.axi_wready         ),
/*  input [3:0]    */   .M00_AXI_BID                     (axi_m00_inf.axi_bid            ),
/*  input [1:0]    */   .M00_AXI_BRESP                   (axi_m00_inf.axi_bresp          ),
/*  input          */   .M00_AXI_BVALID                  (axi_m00_inf.axi_bvalid         ),
/*  output         */   .M00_AXI_BREADY                  (axi_m00_inf.axi_bready         ),
/*  output [3:0]   */   .M00_AXI_ARID                    (axi_m00_inf.axi_arid           ),
/*  output [28:0]  */   .M00_AXI_ARADDR                  (axi_m00_inf.axi_araddr         ),
/*  output [7:0]   */   .M00_AXI_ARLEN                   (axi_m00_inf.axi_arlen          ),
/*  output [2:0]   */   .M00_AXI_ARSIZE                  (axi_m00_inf.axi_arsize         ),
/*  output [1:0]   */   .M00_AXI_ARBURST                 (axi_m00_inf.axi_arburst        ),
/*  output         */   .M00_AXI_ARLOCK                  (axi_m00_inf.axi_arlock         ),
/*  output [3:0]   */   .M00_AXI_ARCACHE                 (axi_m00_inf.axi_arcache        ),
/*  output [2:0]   */   .M00_AXI_ARPROT                  (axi_m00_inf.axi_arprot         ),
/*  output [3:0]   */   .M00_AXI_ARQOS                   (axi_m00_inf.axi_arqos          ),
/*  output         */   .M00_AXI_ARVALID                 (axi_m00_inf.axi_arvalid        ),
/*  input          */   .M00_AXI_ARREADY                 (axi_m00_inf.axi_arready        ),
/*  input [3:0]    */   .M00_AXI_RID                     (axi_m00_inf.axi_rid            ),
/*  input [255:0]  */   .M00_AXI_RDATA                   (axi_m00_inf.axi_rdata          ),
/*  input [1:0]    */   .M00_AXI_RRESP                   (axi_m00_inf.axi_rresp          ),
/*  input          */   .M00_AXI_RLAST                   (axi_m00_inf.axi_rlast          ),
/*  input          */   .M00_AXI_RVALID                  (axi_m00_inf.axi_rvalid         ),
/*  output         */   .M00_AXI_RREADY                  (axi_m00_inf.axi_rready         )
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
/*  input bit */  .aclken       (1'b1   )
);

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
/*    input       */    .enable (1'b1       ),
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
    .THRESHOLD         (THRESHOLD     ),
    .ASIZE             (29      ),
    .BURST_LEN_SIZE    (9       ),
    .PIX_DSIZE         (PIX_DSIZE      ),
    .AXI_DSIZE         (256     ),
    .IDSIZE            (1       ),
    .ID                (0       ),
    .STORAGE_MODE      ("ONCE"  ),   //ONCE LINE
    .IN_DATA_TYPE      ("AXIS"  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     ("AXIS"  ),
    .IN_FRAME_SYNC     ("OFF"   ), //OFF ON
    .OUT_FRAME_SYNC    ("OFF"   ), //OFF ON
    //-->> JUST FOR OUT <<------
    .EX_SYNC           ("OFF"   ),     //OFF ON
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
/*    input       */    .enable (1'b1       ),
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
    .THRESHOLD         (THRESHOLD     ),
    .ASIZE             (29      ),
    .BURST_LEN_SIZE    (9       ),
    .PIX_DSIZE         (PIX_DSIZE      ),
    .AXI_DSIZE         (256     ),
    .IDSIZE            (1       ),
    .ID                (0       ),
    .STORAGE_MODE      ("ONCE"  ),   //ONCE LINE
    .IN_DATA_TYPE      ("AXIS"  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     ("AXIS"  ),
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
DDR3_IP_CORE_WITH_MODE DDR3_IP_CORE_WITH_MODE_inst(
// Inputs
      // Single-ended system clock
/*    input                         */               .sys_clk_i                 (clk_50M        ),
      // Single-ended iodelayctrl clk (reference clock)
/*    input                         */               .clk_ref_i                 (clk_200M       ),
      // user interface signals
/*    output                        */               .ui_clk                    (ui_clk         ),
/*    output                        */               .ui_clk_sync_rst           (ui_rst         ),
/*    output                        */               .mmcm_locked               (               ),

/*    input                         */               .aresetn                   (1'b1           ),
/*    output                        */               .app_sr_active             (),
/*    output                        */               .app_ref_ack               (),
/*    output                        */               .app_zq_ack                (),
      // Slave Interface Write Address Ports
/*    input  [C_S_AXI_ID_WIDTH-1:0]  */              .s_axi_awid                (axi_m00_inf.axi_awid    ),
/*    input  [C_S_AXI_ADDR_WIDTH-1:0]*/              .s_axi_awaddr              (axi_m00_inf.axi_awaddr  ),
/*    input  [7:0]                   */              .s_axi_awlen               (axi_m00_inf.axi_awlen   ),
/*    input  [2:0]                   */              .s_axi_awsize              (axi_m00_inf.axi_awsize  ),
/*    input  [1:0]                   */              .s_axi_awburst             (axi_m00_inf.axi_awburst ),
/*    input  [0:0]                   */              .s_axi_awlock              (axi_m00_inf.axi_awlock  ),
/*    input  [3:0]                   */              .s_axi_awcache             (axi_m00_inf.axi_awcache ),
/*    input  [2:0]                   */              .s_axi_awprot              (axi_m00_inf.axi_awprot  ),
/*    input  [3:0]                   */              .s_axi_awqos               (axi_m00_inf.axi_awqos   ),
/*    input                          */              .s_axi_awvalid             (axi_m00_inf.axi_awvalid ),
/*    output                         */              .s_axi_awready             (axi_m00_inf.axi_awready ),
      // Slave Interface Write Data Ports
/*    input  [C_S_AXI_DATA_WIDTH-1:0]     */         .s_axi_wdata               (axi_m00_inf.axi_wdata   ),
/*    input  [(C_S_AXI_DATA_WIDTH/8)-1:0] */         .s_axi_wstrb               (axi_m00_inf.axi_wstrb   ),
/*    input                               */         .s_axi_wlast               (axi_m00_inf.axi_wlast   ),
/*    input                               */         .s_axi_wvalid              (axi_m00_inf.axi_wvalid  ),
/*    output                              */         .s_axi_wready              (axi_m00_inf.axi_wready  ),
      // Slave Interface Write Response Ports
/*    input                               */         .s_axi_bready              (axi_m00_inf.axi_bready  ),
/*    output [C_S_AXI_ID_WIDTH-1:0]       */         .s_axi_bid                 (axi_m00_inf.axi_bid     ),
/*    output [1:0]                        */         .s_axi_bresp               (axi_m00_inf.axi_bresp   ),
/*    output                              */         .s_axi_bvalid              (axi_m00_inf.axi_bvalid  ),
      // Slave Interface Read Address Ports
/*    input  [C_S_AXI_ID_WIDTH-1:0]       */         .s_axi_arid                (axi_m00_inf.axi_arid     ),
/*    input  [C_S_AXI_ADDR_WIDTH-1:0]     */         .s_axi_araddr              (axi_m00_inf.axi_araddr   ),
/*    input  [7:0]                        */         .s_axi_arlen               (axi_m00_inf.axi_arlen    ),
/*    input  [2:0]                        */         .s_axi_arsize              (axi_m00_inf.axi_arsize   ),
/*    input  [1:0]                        */         .s_axi_arburst             (axi_m00_inf.axi_arburst  ),
/*    input  [0:0]                        */         .s_axi_arlock              (axi_m00_inf.axi_arlock   ),
/*    input  [3:0]                        */         .s_axi_arcache             (axi_m00_inf.axi_arcache  ),
/*    input  [2:0]                        */         .s_axi_arprot              (axi_m00_inf.axi_arprot   ),
/*    input  [3:0]                        */         .s_axi_arqos               (axi_m00_inf.axi_arqos    ),
/*    input                               */         .s_axi_arvalid             (axi_m00_inf.axi_arvalid  ),
/*    output                              */         .s_axi_arready             (axi_m00_inf.axi_arready  ),
      // Slave Interface Read Data Ports
/*    input                               */         .s_axi_rready              (axi_m00_inf.axi_rready   ),
/*    output [C_S_AXI_ID_WIDTH-1:0]       */         .s_axi_rid                 (axi_m00_inf.axi_rid      ),
/*    output [C_S_AXI_DATA_WIDTH-1:0]     */         .s_axi_rdata               (axi_m00_inf.axi_rdata    ),
/*    output [1:0]                        */         .s_axi_rresp               (axi_m00_inf.axi_rresp    ),
/*    output                              */         .s_axi_rlast               (axi_m00_inf.axi_rlast    ),
/*    output                              */         .s_axi_rvalid              (axi_m00_inf.axi_rvalid   ),
/*    output                              */         .init_calib_complete       (init_calib_complete     )
);

defparam DDR3_IP_CORE_WITH_MODE_inst.mem_rnk[0].gen_mem[0].u_comp_ddr3.DEBUG = 0;
defparam DDR3_IP_CORE_WITH_MODE_inst.mem_rnk[0].gen_mem[1].u_comp_ddr3.DEBUG = 0;
defparam DDR3_IP_CORE_WITH_MODE_inst.mem_rnk[0].gen_mem[2].u_comp_ddr3.DEBUG = 0;
defparam DDR3_IP_CORE_WITH_MODE_inst.mem_rnk[0].gen_mem[3].u_comp_ddr3.DEBUG = 0;
`else

clock_rst_verb #(
	.ACTIVE			(1			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100      	)
)clock_rst_axi4(
	.clock			(ui_clk	),
	.rst_x			(ui_rst	)
);

axi_slaver #(
    .ASIZE  (ASIZE         ),
    .DSIZE  (AXI_DSIZE     ),
    .LSIZE  (BURST_LEN_SIZE),
    .ID     (0          ),
    .ADDR_STEP  (8*8    )
)axi_slaver_inst(
    .inf        (axi_m00_inf)
);

initial begin
    axi_slaver_inst.slaver_recieve_burst(1000);
    axi_slaver_inst.slaver_transmit_busrt(1000);
end

initial begin
    rev_enable0 = 0;
    rev_enable1 = 0;
    axi_slaver_inst.wait_rev_enough_data(238*2);
    // axi_slaver_inst.save_cache_data(PIX_DSIZE);
    rev_enable0 = 1;
    rev_enable1 = 1;
end

`endif

endmodule
