/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/26 下午2:46:51
madified:
***********************************************/
`timescale 1ns/1ps
module native_in_port #(
    parameter DSIZE = 24    ,
    parameter MODE  = "ONCE"    ,// ONCE  LINE
    parameter FRAME_SYNC = "OFF" // OFF ON
)(
    input               clock                   ,
    input               rst_n                   ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               vsync                   ,
    input               hsync                   ,
    input               de                      ,
    input [DSIZE-1:0]   idata                   ,

    output              falign                  ,
    output              lalign                  ,   // not last data of line
    output              ealign                  ,
    output              odata_vld               ,
    output[DSIZE-1:0]   odata
);

assign odata_vld = de;
assign odata     = idata;

wire	vs_raising;
wire    vs_falling;
edge_generator #(
	.MODE		("BEST" 	)  // FAST NORMAL BEST
)gen_vs_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (vsync              ),
	.raising    (vs_raising         ),
	.falling    (vs_falling         )
);

wire	de_raising;
wire    de_falling;
edge_generator #(
	.MODE		("BEST" 	)  // FAST NORMAL BEST
)gen_de_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (de                 ),
	.raising    (de_raising         ),
	.falling    (de_falling         )
);

assign falign   = vs_falling;
assign lalign   = MODE=="LINE"? de_falling : 1'b0;

reg [15:0]      lcnt;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  lcnt    <= 16'd0;
    else begin
        if(falign)
            lcnt    <= 16'd0;
        else if(lalign)
            lcnt    <= lcnt + 1'b1;
        else
            lcnt    <= lcnt;
    end

reg frame_blk;

always@(posedge clock,negedge rst_n)
    if(~rst_n)    frame_blk   <=1'd0;
    else            frame_blk   <= lcnt == vactive;

wire	frame_blk_raising;
wire    frame_blk_falling;
edge_generator #(
	.MODE		("BEST" 	)  // FAST NORMAL BEST
)gen_blk_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (frame_blk          ),
	.raising    (frame_blk_raising  ),
	.falling    (frame_blk_falling  )
);

assign ealign   = frame_blk_raising;

endmodule
