/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/10 下午2:12:41
madified:
***********************************************/
`timescale 1ns/1ps
module out_port #(
    parameter DSIZE     = 24,
    parameter MODE      = "ONCE",   //ONCE LINE
    parameter DATA_TYPE = "AXIS",    //AXIS NATIVE
    parameter FRAME_SYNC= "OFF",    //OFF ON
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
    //-- axi_stream
    output              aclk                    ,
    output              aclken                  ,
    output              aresetn                 ,
    output[DSIZE-1:0]   axi_tdata               ,
    output              axi_tvalid              ,
    input               axi_tready              ,
    output              axi_tuser               ,
    output              axi_tlast               ,
    output              axi_fsync               ,
    //-- axi stream
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
    output              rd_en
);

wire        gen_vsync,gen_hsync,gen_de;
wire        ng_vsync,ng_hsync;

reg         pause;
always@(axi_tready ,fifo_empty)begin
    if(axi_tready == 1'b0 && fifo_empty == 1'b1)
            pause = 1'b1;
    else    pause = 1'b0;
end

generate
if(EX_SYNC=="OFF")begin
video_sync_generator_B2 #(
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
/*  output          */  .ng_hs      (ng_hsync   )
);
end else begin
assign gen_vsync    = in_vsync;
assign gen_hsync    = in_hsync;
assign gen_de       = in_de;
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

always@(posedge clock,negedge rst_n)begin : FIRST_BYTE_BLOCK
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


generate
if(DATA_TYPE=="AXIS")begin
stream_out_port #(
    .DSIZE      (DSIZE      ),
    .MODE       (MODE       ),// ONCE  LINE
    .FRAME_SYNC (FRAME_SYNC ) // OFF ON
)stream_out_port_inst(
/*  input              */ .clock                (clock              ),
/*  input              */ .rst_n                (rst_n              ),
/*  input [15:0]       */ .vactive              (vactive            ),
/*  input [15:0]       */ .hactive              (hactive            ),
/*  input              */ .in_vsync             (c_vs               ),
/*  input              */ .in_hsync             (c_hs               ),
/*  input              */ .in_de                (c_de               ),
/*  input              */ .first_vld_byte       (first_vld_byte     ),
    //-- axi stream
/*  output             */ .aclk                 (aclk                ),
/*  output             */ .aclken               (aclken              ),
/*  output             */ .aresetn              (aresetn             ),
/*  output[DSIZE-1:0]  */ .axi_tdata            (axi_tdata           ),
/*  output             */ .axi_tvalid           (axi_tvalid          ),
/*  input              */ .axi_tready           (axi_tready          ),
/*  output             */ .axi_tuser            (axi_tuser           ),
/*  output             */ .axi_tlast            (axi_tlast           ),
/*  output             */ .axi_fsync            (axi_fsync           ),
    //-- axi stream
/*  output             */ .falign               (falign              ),
/*  output             */ .lalign               (lalign              ),
/*  output             */ .ealign               (ealign              ),
/*  input[DSIZE-1:0]   */ .in_data              (in_data             ),
/*  output             */ .rd_en                (rd_en                )
);
end else if(DATA_TYPE=="NATIVE") begin
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
end
endgenerate

endmodule
