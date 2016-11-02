/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/10 上午11:53:37
madified:
***********************************************/
`timescale 1ns/1ps
module native_out_port #(
    parameter DSIZE = 24    ,
    parameter MODE  = "ONCE"    // ONCE  LINE
)(
    input               clock                   ,
    input               rst_n                   ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               in_vsync                ,
    input               in_hsync                ,
    input               in_de                   ,

    output              out_vsync               ,
    output              out_hsync               ,
    output              out_de                  ,
    output[DSIZE-1:0]   odata                   ,

    output              falign                  ,
    output              lalign                  ,
    output              ealign                  ,
    input[DSIZE-1:0]    in_data                 ,
    output              rd_en
);

// assign out_de   = in_de;
assign odata    = in_data;
// assign out_vsync= in_vsync;
// assign out_hsync= in_hsync;
assign rd_en    = in_de;

latency #(
    .LAT        (1),
    .DSIZE      (3)
)lat_sync(
    clock,
    rst_n,
    {in_vsync,in_hsync,in_de},
    {out_vsync,out_hsync,out_de}
);

wire	in_vs_raising;
wire    in_vs_falling;
edge_generator #(
	.MODE		("BEST" 	)  // FAST NORMAL BEST
)gen_vs_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (in_vsync           ),
	.raising    (in_vs_raising      ),
	.falling    (in_vs_falling      )
);

wire	de_raising;
wire    de_falling;
edge_generator #(
	.MODE		("BEST" 	)  // FAST NORMAL BEST
)gen_de_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (in_de              ),
	.raising    (de_raising         ),
	.falling    (de_falling         )
);

assign falign   = in_vs_falling;
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
    else          frame_blk   <= lcnt == vactive;

wire	frame_blk_raising;
wire    frame_blkq_falling;
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
