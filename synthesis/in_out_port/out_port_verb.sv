/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERB.0.0 2017/2/17 下午8:23:03
    cut axis
creaded: 2016/8/10 下午2:12:41
madified:
***********************************************/
`timescale 1ns/1ps
module out_port_verb #(
    parameter DSIZE     = 24,
    parameter MODE      = "ONCE",   //ONCE LINE
    parameter EX_SYNC   = "OFF",     //OFF ON
    parameter VIDEO_FORMAT= "1080P@60"
)(
    input               clock                   ,
    input               rst_n                   ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               in_vsync                ,
    input               in_hsync                ,
    input               in_de                   ,
    input               fifo_empty              ,
    input               enable_inner_sync       ,
    //-- native
    output              out_vsync               ,
    output              out_hsync               ,
    output              out_de                  ,
    output[DSIZE-1:0]   odata                   ,
    //-- native
    output              falign                  ,
    output              lalign                  ,
    output              ealign                  ,
    input[DSIZE-1:0]    in_data                 ,
    output              rd_en                   ,
    output[15:0]        out_vactive             ,
    output[15:0]        out_hactive
);

wire        gen_vsync,gen_hsync,gen_de;
wire        ng_vsync,ng_hsync;

logic       pause;

assign pause = fifo_empty;


generate
if(EX_SYNC=="OFF")begin
video_sync_generator_B3 #(
	.MODE		(VIDEO_FORMAT)
)video_sync_generator_inst(
/*	input			*/	.pclk 		(clock		),
/*	input			*/	.rst_n      (rst_n 	    ),
/*	input			*/	.pause		(pause      ),
/*	input			*/	.enable     (enable_inner_sync		),
	//--->> Extend Sync
/*	output			*/	.vsync  	(gen_vsync  ),
/*	output			*/	.hsync      (gen_hsync  ),
/*	output			*/	.de         (gen_de		),
/*	output			*/	.field      (			),
/*  output          */  .ng_vs      (ng_vsync   ),
/*  output          */  .ng_hs      (ng_hsync   ),
/*  output[15:0]    */  .vactive    (out_vactive    ),
/*  output[15:0]    */  .hactive    (out_hactive    )
);
end else begin
assign gen_vsync    = in_vsync;
assign gen_hsync    = in_hsync;
assign gen_de       = in_de;
assign out_vactive  = vactive;
assign out_hactive  = hactive;
end
endgenerate

//--->> FIRTS BYTE <<--------------
wire	de_raising;
wire    de_falling;
edge_generator #(
	.MODE		("FAST" 	)  // FAST NORMAL BEST
)gen_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (gen_de             ),
	.raising    (de_raising  ),
	.falling    (de_falling  )
);

reg     first_vld_byte;

always@(posedge clock/*,negedge rst_n*/)begin : FIRST_BYTE_BLOCK
reg     frame_in;
    if(~rst_n)begin
        frame_in        <= 1'b0;
        first_vld_byte  <= 1'b0;
    end else begin
        if(falign)
                frame_in    <= 1'b0;
        else if(first_vld_byte)
                frame_in    <= 1'b1;
        else    frame_in    <= frame_in;

        if(frame_in == 1'b0)
                first_vld_byte  <= de_raising;
        else    first_vld_byte  <= 1'b0;
end end
//---<< FIRTS BYTE >>--------------

wire        c_vs,c_hs,c_de;

latency #(
    .LAT        (1),
    .DSIZE      (3)
)lat_sync(
    clock,
    rst_n,
    {gen_vsync,gen_hsync,gen_de},
    {c_vs,c_hs,c_de}
);


native_out_port #(
    .DSIZE      (DSIZE  ),
    .MODE       (MODE   )// ONCE  LINE
)native_out_port_inst(
/*  input              */ .clock                (clock              ),
/*  input              */ .rst_n                (rst_n              ),
/*  input [15:0]       */ .vactive              (vactive            ),
/*  input [15:0]       */ .hactive              (hactive            ),
/*  input              */ .in_vsync             (c_vs               ),
/*  input              */ .in_hsync             (c_hs               ),
/*  input              */ .in_de                (c_de               ),
/*  output             */ .out_vsync            (out_vsync          ),
/*  output             */ .out_hsync            (out_hsync          ),
/*  output             */ .out_de               (out_de             ),
/*  output[DSIZE-1:0]  */ .odata                (odata              ),
/*  output             */ .falign               (falign             ),
/*  output             */ .lalign               (lalign             ),
/*  output             */ .ealign               (ealign             ),
/*  input[DSIZE-1:0]   */ .in_data              (in_data            ),
/*  output             */ .rd_en                (rd_en              )
);

endmodule
