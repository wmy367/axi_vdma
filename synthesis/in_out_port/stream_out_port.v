/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/10 下午1:38:00
madified:
***********************************************/
`timescale 1ns/1ps
module stream_out_port #(
    parameter DSIZE = 24    ,
    parameter MODE  = "ONCE"    ,// ONCE  LINE
    parameter FRAME_SYNC = "OFF" // OFF ON
)(
    input               clock                   ,
    input               rst_n                   ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               in_vsync                ,
    input               in_hsync                ,
    input               in_de                   ,
    input               first_vld_byte          ,
    //-- axi stream
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
    output              falign                  ,
    output              lalign                  ,
    output              ealign                  ,
    input[DSIZE-1:0]    in_data                 ,
    output              rd_en
);

wire    first_vld_byte_lat1;

latency #(
    .LAT    (2),
    .DSIZE  (2)
)lat_2_clock(
    clock,
    rst_n,
    {rd_en,first_vld_byte},
    {axi_tvalid,first_vld_byte_lat1}
);

latency #(
    .LAT    (1),
    .DSIZE  (DSIZE)
)lat_1_clock(
    clock,
    rst_n,
    {in_data},
    {axi_tdata}
);

assign  aclk        = clock;
assign  aresetn     = rst_n;
assign  aclken      = 1'b1;

// assign  axi_tvalid  = rd_en;
// assign  axi_tdata   = in_data;

assign  rd_en       = in_de && axi_tready;

assign axi_tuser    = FRAME_SYNC=="OFF"? first_vld_byte_lat1 : axi_fsync;

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
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_de_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (in_de              ),
	.raising    (de_raising         ),
	.falling    (de_falling         )
);

assign falign   = in_vs_falling;
assign lalign   = MODE=="LINE"? de_falling : 1'b0;
assign axi_fsync= in_vs_raising;

assign axi_tlast= de_falling;

reg [15:0]      lcnt;

always@(posedge aclk,negedge aresetn)
    if(~aresetn)  lcnt    <= 16'd0;
    else begin
        if(falign)
            lcnt    <= 16'd0;
        else if(lalign)
            lcnt    <= lcnt + 1'b1;
        else
            lcnt    <= lcnt;
    end

reg frame_blk;

always@(posedge aclk,negedge aresetn)
    if(~aresetn)    frame_blk   <=1'd0;
    else            frame_blk   <= lcnt == vactive;

wire	frame_blk_raising;
wire    frame_blkq_falling;
edge_generator #(
	.MODE		("BEST" 	)  // FAST NORMAL BEST
)gen_edge(
	.clk		(aclk				),
	.rst_n      (aresetn            ),
	.in         (frame_blk          ),
	.raising    (frame_blk_raising  ),
	.falling    (frame_blk_falling  )
);

assign ealign   = frame_blk_raising;

endmodule
