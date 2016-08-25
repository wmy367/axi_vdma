/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/12 上午9:34:45
madified:
***********************************************/
`timescale 1ns/1ps
module axi_mm_tb;
localparam MODE         = "TEST";
localparam  WR_THRESHOLD    = 100,
            RD_THRESHOLD    = 100,
            PIX_DSIZE       = 32,
            STO_MODE        = "LINE",
            FRAME_SYNC      = "OFF",        //only for axi_stream
            DATA_TYPE       = "AXIS";     //NATIVE AXIS

bit         axi_aclk;
bit         axi_resetn;

bit         aclk;
bit         aresetn;

bit         pclk;
bit         prst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100      	)
)clock_rst_axi_mm(
	.clock			(axi_aclk	),
	.rst_x			(axi_resetn	)
);

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100      	)
)clock_rst_axi_stream(
	.clock			(aclk	),
	.rst_x			(aresetn	)
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

wire ng_vsync,ng_hsync;
wire gen_vsync,gen_hsync,gen_de;

video_sync_generator_B2 #(
	.MODE		(MODE)
)video_sync_generator_inst(
/*	input			*/	.pclk 		(pclk  		),
/*	input			*/	.rst_n      (prst_n 	),
/*	input			*/	.pause		(1'b0		),
/*	input			*/	.enable     (1'b1		),
	//--->> Extend Sync
/*	output			*/	.vsync  	(gen_vsync  ),
/*	output			*/	.hsync      (gen_hsync  ),
/*	output			*/	.de         (gen_de		),
/*	output			*/	.field      (			),
/*  output          */  .ng_vs      (ng_vsync   ),
/*  output          */  .ng_hs      (ng_hsync   )
);

int hactive,vactive;

assign hactive = video_sync_generator_inst.H_ACTIVE;
assign vactive = video_sync_generator_inst.V_ACTIVE;

int         test_data;
always@(posedge pclk)begin
    if(gen_vsync)
            test_data   <= 0;
    else if(gen_de)
            test_data   <= test_data + 1;
    else    test_data   <= test_data;
end

wire                  tans_aclk       ;
wire                  tans_aclken     ;
wire                  tans_aresetn    ;
wire[PIX_DSIZE-1:0]   tans_axi_tdata  ;
wire                  tans_axi_tvalid ;
wire                  tans_axi_tready ;
wire                  tans_axi_tuser  ;
wire                  tans_axi_tlast  ;

native_to_axis #(
    .DSIZE          (PIX_DSIZE  ),
    .FRAME_SYNC     (FRAME_SYNC )     //OFF ON
)native_to_axis_inst(
/*  input              */ .clock                   (pclk                ),
/*  input              */ .rst_n                   (prst_n              ),
/*  input              */ .enable                  (1'b1                ),
/*  input              */ .vsync                   (gen_vsync           ),
/*  input              */ .hsync                   (gen_hsync           ),
/*  input              */ .de                      (gen_de		        ),
/*  input [DSIZE-1:0]  */ .idata                   (test_data[PIX_DSIZE-1:0]    ),
    //-- axi stream ---
/*  output             */ .aclk                    (tans_aclk           ),
/*  output             */ .aclken                  (tans_aclken         ),
/*  output             */ .aresetn                 (tans_aresetn        ),
/*  output [DSIZE-1:0] */ .axi_tdata               (tans_axi_tdata      ),
/*  output             */ .axi_tvalid              (tans_axi_tvalid     ),
/*  input              */ .axi_tready              (tans_axi_tready     ),
/*  output             */ .axi_tuser               (tans_axi_tuser      ),
/*  output             */ .axi_tlast               (tans_axi_tlast      )
);

axi_inf #(
    .IDSIZE    (4               ),
    .ASIZE     (29              ),
    .LSIZE     (9               ),
    .DSIZE     (256             )
)axi_mm_inf(axi_aclk,axi_resetn);

mm_tras #(
    .THRESHOLD      (WR_THRESHOLD  ),
    .ASIZE          (29         ),
    .BURST_LEN_SIZE (9          ),
    .DSIZE          (PIX_DSIZE  ),
    .AXI_DSIZE      (256        ),
    .IDSIZE         (4          ),
    .ID             (0          ),
    .MODE           (STO_MODE       ),   //ONCE LINE
    .DATA_TYPE      (DATA_TYPE      ),    //AXIS NATIVE
    .FRAME_SYNC     (FRAME_SYNC     )//OFF ON
)mm_tras_inst(
/*  input             */  .clock                   (pclk            ),
/*  input             */  .rst_n                   (prst_n          ),
/*  input [15:0]      */  .vactive                 (vactive            ),
/*  input [15:0]      */  .hactive                 (hactive            ),
/*  input             */  .vsync                   (gen_vsync       ),
/*  input             */  .hsync                   (gen_hsync       ),
/*  input             */  .de                      (gen_de          ),
/*  input [DSIZE-1:0] */  .idata                   (test_data[PIX_DSIZE-1:0]       ),
/*  input             */  .fsync                   (0               ),
/*  output            */  .fifo_almost_full        (                ),
    //-- AXI
    //-- axi stream ---
/*  input             */  .aclk                    (tans_aclk       ),
/*  input             */  .aclken                  (tans_aclken     ),
/*  input             */  .aresetn                 (tans_aresetn    ),
/*  input [DSIZE-1:0] */  .axi_tdata               (tans_axi_tdata  ),
/*  input             */  .axi_tvalid              (tans_axi_tvalid ),
/*  output            */  .axi_tready              (tans_axi_tready ),
/*  input             */  .axi_tuser               (tans_axi_tuser  ),
/*  input             */  .axi_tlast               (tans_axi_tlast  ),
    //-- axi stream
/*  input             */  .axi_aclk                (axi_aclk        ),
/*  input             */  .axi_resetn              (axi_resetn      ),
    //--->> addr write <<-------
/*  input[IDSIZE-1:0] */  .axi_awid                (axi_mm_inf.axi_awid             ),
/*  input[ASIZE-1:0]  */  .axi_awaddr              (axi_mm_inf.axi_awaddr           ),
/*  input[LSIZE-1:0]  */  .axi_awlen               (axi_mm_inf.axi_awlen            ),
/*  input[2:0]        */  .axi_awsize              (axi_mm_inf.axi_awsize           ),
/*  input[1:0]        */  .axi_awburst             (axi_mm_inf.axi_awburst          ),
/*  input[0:0]        */  .axi_awlock              (axi_mm_inf.axi_awlock           ),
/*  input[3:0]        */  .axi_awcache             (axi_mm_inf.axi_awcache          ),
/*  input[2:0]        */  .axi_awprot              (axi_mm_inf.axi_awprot           ),
/*  input[3:0]        */  .axi_awqos               (axi_mm_inf.axi_awqos            ),
/*  input             */  .axi_awvalid             (axi_mm_inf.axi_awvalid          ),
/*  output            */  .axi_awready             (axi_mm_inf.axi_awready          ),
    //--->> Response <<---------
/*  output            */  .axi_bready              (axi_mm_inf.axi_bready           ),
/*  input[IDSIZE-1:0] */  .axi_bid                 (axi_mm_inf.axi_bid              ),
/*  input[1:0]        */  .axi_bresp               (axi_mm_inf.axi_bresp            ),
/*  input             */  .axi_bvalid              (axi_mm_inf.axi_bvalid           ),
    //---<< Response >>---------
    //--->> data write <<-------
/*  output[DSIZE-1:0]  */ .axi_wdata               (axi_mm_inf.axi_wdata            ),
/*  output[DSIZE/8-1:0]*/ .axi_wstrb               (axi_mm_inf.axi_wstrb            ),
/*  output             */ .axi_wlast               (axi_mm_inf.axi_wlast            ),
/*  output             */ .axi_wvalid              (axi_mm_inf.axi_wvalid           ),
/*  input              */ .axi_wready              (axi_mm_inf.axi_wready           )
    //---<< data write >>-------
);

bit         enable_s_to_mm = 0;

mm_rev #(
    .THRESHOLD      (RD_THRESHOLD   ),
    .ASIZE          (29             ),
    .BURST_LEN_SIZE (9              ),
    .IDSIZE         (4              ),
    .ID             (0              ),
    .DSIZE          (PIX_DSIZE      ),
    .AXI_DSIZE      (256            ),
    .MODE           (STO_MODE       ),   //ONCE LINE
    .DATA_TYPE      (DATA_TYPE      ),    //AXIS NATIVE
    .FRAME_SYNC     (FRAME_SYNC     ),    //OFF ON
    .EX_SYNC        ("OFF"          ),     //OFF ON
    .VIDEO_FORMAT   ("1080P@60"     )
)mm_rev_inst(
/*  input              */ .clock                   (pclk                ),
/*  input              */ .rst_n                   (prst_n              ),
/*  input              */ .enable                  (enable_s_to_mm      ),
/*  input [15:0]       */ .vactive                 (vactive                ),
/*  input [15:0]       */ .hactive                 (hactive                ),
/*  input              */ .in_vsync                (gen_vsync           ),
/*  input              */ .in_hsync                (gen_hsync           ),
/*  input              */ .in_de                   (gen_de              ),
/*  output             */ .fifo_almost_empty       (                    ),
    //-- AXI
    //-- axi stream ---
/*  output             */ .aclk                    (                ),
/*  output             */ .aclken                  (                ),
/*  output             */ .aresetn                 (                ),
/*  output[DSIZE-1:0]  */ .axi_tdata               (                    ),
/*  output             */ .axi_tvalid              (                    ),
/*  input              */ .axi_tready              (1'b1                ),
/*  output             */ .axi_tuser               (                    ),
/*  output             */ .axi_tlast               (                    ),
    //-- axi stream
/*  input              */ .axi_aclk                (axi_aclk            ),
/*  input              */ .axi_resetn              (axi_resetn          ),
    //-- axi read
    //-- addr read
/*  output[IDSIZE-1:0] */ .axi_arid                (axi_mm_inf.axi_arid         ),
/*  output[ASIZE-1:0]  */ .axi_araddr              (axi_mm_inf.axi_araddr       ),
/*  output[BURST_LEN_SIZE-1:0]*/
                          .axi_arlen               (axi_mm_inf.axi_arlen        ),
/*  output[2:0]        */ .axi_arsize              (axi_mm_inf.axi_arsize       ),
/*  output[1:0]        */ .axi_arburst             (axi_mm_inf.axi_arburst      ),
/*  output[0:0]        */ .axi_arlock              (axi_mm_inf.axi_arlock       ),
/*  output[3:0]        */ .axi_arcache             (axi_mm_inf.axi_arcache      ),
/*  output[2:0]        */ .axi_arprot              (axi_mm_inf.axi_arprot       ),
/*  output[3:0]        */ .axi_arqos               (axi_mm_inf.axi_arqos        ),
/*  output             */ .axi_arvalid             (axi_mm_inf.axi_arvalid      ),
/*  input              */ .axi_arready             (axi_mm_inf.axi_arready      ),
    //-- data read
/*  output             */ .axi_rready              (axi_mm_inf.axi_rready       ),
/*  input[IDSIZE-1:0]  */ .axi_rid                 (axi_mm_inf.axi_rid          ),
/*  input[DSIZE-1:0]   */ .axi_rdata               (axi_mm_inf.axi_rdata        ),
/*  input[1:0]         */ .axi_rresp               (axi_mm_inf.axi_rresp        ),
/*  input              */ .axi_rlast               (axi_mm_inf.axi_rlast        ),
/*  input              */ .axi_rvalid              (axi_mm_inf.axi_rvalid       ),
    //-- native
/*  output             */ .out_vsync               (                            ),
/*  output             */ .out_hsync               (                            ),
/*  output             */ .out_de                  (                            ),
/*  output[DSIZE-1:0]  */ .odata                   (                            )
);

axi_slaver #(
    .ASIZE  (29         ),
    .DSIZE  (256        ),
    .LSIZE  (9          ),
    .ID     (0          ),
    .ADDR_STEP  (8*8    )
)axi_slaver_inst(
    .inf        (axi_mm_inf)
);


initial begin
    axi_slaver_inst.slaver_recieve_burst(1000);
//    axi_slaver_inst.slaver_transmit_busrt(1000);
end

initial begin
    axi_slaver_inst.wait_rev_enough_data(238*2);
    axi_slaver_inst.save_cache_data(PIX_DSIZE);
    enable_s_to_mm  = 1;
end

//--->> destruct data array test <<-------------
logic[PIX_DSIZE-1:0] ds_data_array [256/PIX_DSIZE+(256%PIX_DSIZE != 0) -1 :0];
assign ds_data_array    = {>>{mm_rev_inst.destruct_data_inst.idata}};
//---<< destruct data array test >>-------------
//--->> combin_data array <<--------------------
logic[PIX_DSIZE-1:0]    cb_data_array [256/PIX_DSIZE+(256%PIX_DSIZE != 0) -1 :0];
assign cb_data_array    = {>>{mm_tras_inst.axi_wdata}};
//---<< combin_data array >>--------------------

//--->> 24bit <<--------------------------------
logic[255:0]    matrix_cb [2:0];
logic[PIX_DSIZE-1:0]    cb_data_array_2 [256*3/PIX_DSIZE-1:0];

assign cb_data_array_2  = {>>{matrix_cb[0],matrix_cb[1],matrix_cb[2]}};

always@(posedge mm_tras_inst.combin_data_inst.iwr_en)begin
    while(mm_tras_inst.combin_data_inst.iwr_en)begin
        @(posedge mm_tras_inst.combin_data_inst.owr_en);
        @(negedge axi_aclk);
        matrix_cb[0]    = mm_tras_inst.combin_data_inst.odata;
        @(posedge mm_tras_inst.combin_data_inst.owr_en);
        @(negedge axi_aclk);
        matrix_cb[1]    = mm_tras_inst.combin_data_inst.odata;
        @(posedge mm_tras_inst.combin_data_inst.owr_en);
        @(negedge axi_aclk);
        matrix_cb[2]    = mm_tras_inst.combin_data_inst.odata;
    end
end

endmodule
