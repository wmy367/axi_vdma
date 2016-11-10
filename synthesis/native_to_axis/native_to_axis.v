/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/19 上午11:26:52
madified:
***********************************************/
`timescale 1ns/1ps
module native_to_axis #(
    parameter DSIZE         = 24,
    parameter FRAME_SYNC    = "OFF"     //OFF ON
)(
    input               clock                   ,
    input               rst_n                   ,
    input               enable                  ,
    input               vsync                   ,
    input               hsync                   ,
    input               de                      ,
    input [DSIZE-1:0]   idata                   ,

    //-- axi stream ---
    output              aclk                    ,
    output              aclken                  ,
    output              aresetn                 ,
    output [DSIZE-1:0]  axi_tdata               ,
    output              axi_tvalid              ,
    input               axi_tready              ,
    output              axi_tuser               ,
    output              axi_tlast
);

assign aclk     = clock;
assign aresetn  = rst_n;
assign aclken   = enable;


wire	de_raising;
wire    de_falling;
edge_generator #(
	.MODE		("FAST" 	)  // FAST NORMAL BEST
)de_gen_edge(
	.clk		(clock 				),
	.rst_n      (rst_n              ),
	.in         (de          ),
	.raising    (de_raising  ),
	.falling    (de_falling  )
);

wire	vs_raising;
wire    vs_falling;
edge_generator #(
	.MODE		("FAST" 	)  // FAST NORMAL BEST
)vs_gen_edge(
	.clk		(clock 				),
	.rst_n      (rst_n              ),
	.in         (vs                 ),
	.raising    (vs_raising         ),
	.falling    (vs_falling         )
);

latency #(
    .LAT    (2),
    .DSIZE  (DSIZE)
)lat_data(
    clock,
    rst_n,
    idata,
    axi_tdata
);

reg     first_byte_flag;

always@(posedge clock/*,negedge rst_n*/)begin:FIRST_RECORD_BLOCK
reg     rcd;
    if(~rst_n)begin
        first_byte_flag <= 1'b0;
        rcd             <= 1'b0;
    end else begin
        if(vs_falling)
                rcd <= 1'b0;
        else if(de_falling)
                rcd <= 1'b1;
        else    rcd <= rcd;

        if(!rcd)
                first_byte_flag  <= de_raising;
        else    first_byte_flag  <= 1'b0;
end end

wire    fsync_wire;
wire    vld_wire;
wire    last_wire;

latency #(
    .LAT    (2),
    .DSIZE  (2)
)lat_2_clock(
    clock,
    rst_n,
    {vs_falling,de},
    {fsync_wire,vld_wire}
);

wire first_byte_flag_wire;

latency #(
    .LAT    (1),
    .DSIZE  (2)
)lat_1_clock(
    clock,
    rst_n,
    {first_byte_flag,de_falling},
    {first_byte_flag_wire,last_wire}
);

assign axi_tuser    = (FRAME_SYNC=="OFF")?  first_byte_flag_wire : fsync_wire;
assign axi_tvalid   = vld_wire;
assign axi_tlast    = last_wire;


endmodule
