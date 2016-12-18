/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/11/1 下午1:40:49
madified:
***********************************************/
`timescale 1ns/1ps
module map_data_tb_1101;
localparam  DSIZE       = 24,
            MODE        = "LINE",
            DATA_TYPE   = "NATIVE",
            FRAME_SYNC  = "OFF",
            VIDEO_FORMAT= "TEST",
            AXI_DSIZE   = 512;

//----->> CLOCK <<-----------------
bit         clock;
bit         rst_n;
clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(50      	)
)clock_rst_axi_mm(
	.clock			(clock	),
	.rst_x			(rst_n	)
);
//-----<< CLOCK >>-----------------
//----->> video gen <<-----------------

video_native_inf #(
    .DSIZE  (DSIZE)
)video_native_in0(
    .pclk       (clock   ),
    .prst_n     (rst_n )
);

axi_stream_inf #(
    .DSIZE  (DSIZE)
)axi_stream_in0(
/*  input bit */  .aclk         (clock   ),
/*  input bit */  .aresetn      (rst_n ),
/*  input bit */  .aclken       (1'b1   )
);
simple_video_gen #(
    .MODE   (VIDEO_FORMAT   ),
    .DSIZE  (DSIZE      )
)simple_video_gen_inst0(
/*    input       */    .enable     (1    ),
/*    video_native_inf.compact_out */
                        .inf        (video_native_in0   ),
/*    axi_stream_inf.master*/
                        .axis       (axi_stream_in0     ),
/*  output[15:0]    */  .vactive    (    ),
/*  output[15:0]    */  .hactive    (    )
);
//-----<< video gen >>-----------------
wire            in_port_falign     ;
wire            in_port_lalign     ;
wire            in_port_ealign     ;
wire            in_port_odata_vld  ;
wire[DSIZE-1:0] in_port_odata      ;

wire            fifo_almost_full;


in_port #(
    .DSIZE     (DSIZE     ),
    .MODE      (MODE      ),   //ONCE LINE
    .DATA_TYPE (DATA_TYPE ),    //AXIS NATIVE
    .FRAME_SYNC("OFF")    //OFF ON
)in_port_inst(
/*  input              */ .clock                   (clock                   ),
/*  input              */ .rst_n                   (rst_n                   ),
/*  input [15:0]       */ .vactive                 (20                      ),//for blank ealign, now is't unused
/*  input [15:0]       */ .hactive                 (1920                    ),//unused
/*  input              */ .vsync                   (video_native_in0.vsync                   ),
/*  input              */ .hsync                   (video_native_in0.hsync                   ),
/*  input              */ .de                      (video_native_in0.de                      ),
/*  input [DSIZE-1:0]  */ .idata                   (video_native_in0.data                   ),
/*  input              */ .fsync                   (                   ),
/*  input              */ .fifo_almost_full        (fifo_almost_full        ),
    //-- axi stream ---
/*  input              */ .aclk                    (),
/*  input              */ .aclken                  (),
/*  input              */ .aresetn                 (),
/*  input [DSIZE-1:0]  */ .axi_tdata               (),
/*  input              */ .axi_tvalid              (),
/*  output             */ .axi_tready              (),
/*  input              */ .axi_tuser               (),
/*  input              */ .axi_tlast               (),
    //-- axi stream
/*  output             */ .falign                  (in_port_falign          ),
/*  output             */ .lalign                  (in_port_lalign          ),
/*  output             */ .ealign                  (in_port_ealign          ),
/*  output             */ .odata_vld               (in_port_odata_vld       ),
/*  output[DSIZE-1:0]  */ .odata                   (in_port_odata           )
);


wire[AXI_DSIZE-1:0]     cb_data;
wire                    cb_wr_en;
wire                    cb_wr_last_en;

combin_data #(
    .ISIZE      (DSIZE        ),
    .OSIZE      (AXI_DSIZE    ),
    .DATA_TYPE  (DATA_TYPE    ),
    .MODE       (MODE         )
)combin_data_inst(
/*    input               */ .clock       (clock    ),
/*    input               */ .rst_n       (rst_n  ),
/*    input               */ .iwr_en      (in_port_odata_vld  ),
/*    input [ISIZE-1:0]   */ .idata       (in_port_odata      ),
/*    input               */ .ialign      (in_port_falign     ),
/*    input               */ .ilast       (in_port_lalign     ),
/*    output              */ .owr_en      (cb_wr_en         ),
/*    output              */ .olast_en    (cb_wr_last_en    ),
/*    output[OSIZE-1:0]   */ .odata       (cb_data          ),
/*    output[OSIZE/8-1:0] */ .omask       (  )
);

//--->> OUT PORT INTERFACE <<----------
wire            out_port_falign     ;
wire            out_port_lalign     ;
wire            out_port_ealign     ;
wire            out_port_rd_en      ;
wire[DSIZE-1:0] out_port_idata      ;
wire            fifo_empty          ;
wire[15:0]      out_vactive         ;
wire[15:0]      out_hactive         ;

wire            out_de;

bit             enable_inner_sync   ;

out_port #(
    .DSIZE        (DSIZE        ),
    .MODE         (MODE         ),        //ONCE LINE
    .DATA_TYPE    (DATA_TYPE    ),         //AXIS NATIVE
    .FRAME_SYNC   (FRAME_SYNC   ),        //OFF ON
    .EX_SYNC      ("OFF"      ),         //OFF ON
    .VIDEO_FORMAT (VIDEO_FORMAT )
)out_port_inst(
/*  input              */ .clock         (clock                ),
/*  input              */ .rst_n         (rst_n                ),
/*  input [15:0]       */ .vactive       (20              ),//for blank ealign, now is't unused
/*  input [15:0]       */ .hactive       (1920              ),//unused
/*  input              */ .in_vsync      (),
/*  input              */ .in_hsync      (),
/*  input              */ .in_de         (),
/*  input              */ .fifo_empty    (fifo_empty           ),
/*  input              */ .enable_inner_sync    (enable_inner_sync        ),
    //-- axi_stream
/*  output             */ .aclk          (),
/*  output             */ .aclken        (),
/*  output             */ .aresetn       (),
/*  output[DSIZE-1:0]  */ .axi_tdata     (),
/*  output             */ .axi_tvalid    (),
/*  input              */ .axi_tready    (),
/*  output             */ .axi_tuser     (),
/*  output             */ .axi_tlast     (),
/*  output             */ .axi_fsync     (),
    //-- axi stream
    //-- native
/*  output             */ .out_vsync     (),
/*  output             */ .out_hsync     (),
/*  output             */ .out_de        (out_de),
/*  output[DSIZE-1:0]  */ .odata         (),
    //-- native
/*  output             */ .falign        (out_port_falign      ),
/*  output             */ .lalign        (out_port_lalign      ),
/*  output             */ .ealign        (out_port_ealign      ),
/*  input[DSIZE-1:0]   */ .in_data       (out_port_idata       ),
/*  output             */ .rd_en         (out_port_rd_en       ),
/*  output[15:0]       */ .out_vactive   (out_vactive          ),
/*  output[15:0]       */ .out_hactive   (out_hactive          )
);

//---<< OUT PORT INTERFACE >>----------

wire[AXI_DSIZE-1:0]     ds_data;
wire                    ds_rd_en;
wire                    ds_wr_last_en;

destruct_data #(
    .ISIZE      (AXI_DSIZE  ),
    .OSIZE      (DSIZE      )
)destruct_data_inst(
/*  input               */  .clock       (clock                     ),
/*  input               */  .rst_n       (rst_n                     ),
/*  input               */  .force_rd    (out_port_lalign           ),   //force read out next data
/*  input               */  .ialign      (out_port_falign           ),
/*  output              */  .ird_en      (ds_rd_en                  ),
/*  input [ISIZE-1:0]   */  .idata       (ds_data                   ),
/*  input               */  .ord_en      (out_port_rd_en            ),
/*  output              */  .olast_en    (                          ),
/*  output[OSIZE-1:0]   */  .odata       (out_port_idata            ),
/*  output              */  .ovalid      (                          ),
/*  output[OSIZE/8-1:0] */  .omask       (                          )
);

wire[9:0]       rd_data_count;
wire[9:0]       wr_data_count;

generate
if(AXI_DSIZE == 256)begin
vdma_stream_fifo stream_fifo_inst (
/*  input               */     .rst               (!rst_n       ),
/*  input               */     .wr_clk            (clock                       ),
/*  input               */     .rd_clk            (clock                       ),
/*  input [DSIZE-1:0]   */     .din               (cb_data                      ),
/*  input               */     .wr_en             (cb_wr_en || cb_wr_last_en    ),
/*  input               */     .rd_en             (ds_rd_en),
/*  output [DSIZE-1:0]  */     .dout              (ds_data                    ),
/*  output              */     .full              (   ),
/*  output              */     .almost_full       (fifo_almost_full             ),
/*  output              */     .empty             (fifo_empty                   ),
/*  output              */     .almost_empty      (   ),
/*  output[9:0]         */     .rd_data_count     (rd_data_count                ),
/*  output[9:0]         */     .wr_data_count     (wr_data_count                )
);
end else if(AXI_DSIZE == 512)begin
vdma_stream_fifo_512 stream_fifo_inst (
/*  input               */     .rst               (!rst_n       ),
/*  input               */     .wr_clk            (clock                       ),
/*  input               */     .rd_clk            (clock                       ),
/*  input [DSIZE-1:0]   */     .din               (cb_data                      ),
/*  input               */     .wr_en             (cb_wr_en || cb_wr_last_en    ),
/*  input               */     .rd_en             (ds_rd_en   ),
/*  output [DSIZE-1:0]  */     .dout              (ds_data                    ),
/*  output              */     .full              (   ),
/*  output              */     .almost_full       (fifo_almost_full             ),
/*  output              */     .empty             (fifo_empty                   ),
/*  output              */     .almost_empty      (   ),
/*  output[9:0]         */     .rd_data_count     (rd_data_count                ),
/*  output[9:0]         */     .wr_data_count     (wr_data_count                )
);
end
endgenerate

generate
if(DSIZE==24)begin:PROBE_BLOCK
probe_large_width_data #(
    .DSIZE      (AXI_DSIZE  )
)wr_probe_large_width_data_inst(
/*  input             */  .clock               (clock       ),
/*  input             */  .rst                 (!rst_n     ),
/*  input [DSIZE-1:0] */  .data                (cb_data       ),
/*  input             */  .valid               (cb_wr_en || cb_wr_last_en      ),
/*  input             */  .sync                (),
/*  input             */  .sync_negedge        (cb_wr_last_en),
/*  input             */  .sync_posedge        ()
);

probe_large_width_data #(
    .DSIZE      (AXI_DSIZE  )
)rd_probe_large_width_data_inst(
/*  input             */  .clock               (clock       ),
/*  input             */  .rst                 (!rst_n     ),
/*  input [DSIZE-1:0] */  .data                (ds_data       ),
/*  input             */  .valid               (ds_rd_en      ),
/*  input             */  .sync                (),
/*  input             */  .sync_negedge        (out_de),
/*  input             */  .sync_posedge        ()
);
end
endgenerate


initial begin
    enable_inner_sync = 0;
    repeat(200) @(posedge clock);
    enable_inner_sync = 1;
end

endmodule
