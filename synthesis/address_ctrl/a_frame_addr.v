/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/26 上午10:58:28
madified:
***********************************************/
`timescale 1ns/1ps
module a_frame_addr #(
    parameter ASIZE             = 29,
    parameter BURST_MAP_ADDR    = 200*8*8,
    parameter LASIZE            = 16
)(
    input               clock,
    input               rst_n,
    input               new_base,
    input[ASIZE-1:0]    baseaddr,
    input[ASIZE-1:0]    line_increate_addr,
    input               burst_done,
    input               tail_done,
    output[ASIZE-1:0]   out_addr
);


wire	burst_done_raising;
wire    burst_done_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_burst_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (burst_done          ),
	.raising    (burst_done_raising  ),
	.falling    (burst_done_falling  )
);

wire	tail_done_raising;
wire    tail_done_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_tail_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (tail_done           ),
	.raising    (tail_done_raising   ),
	.falling    (tail_done_falling   )
);


reg [ASIZE-1:0]     curr_addr;

// always@(posedge clock/*,negedge rst_n*/)
always@(posedge clock)
    if(~rst_n)  curr_addr   <= {ASIZE{1'b0}};
    else begin
        if(new_base)
                curr_addr   <= baseaddr;
        else if(burst_done_raising)
                curr_addr   <= curr_addr + BURST_MAP_ADDR;
        // else if(tail_done_raising)
        //         curr_addr   <= {curr_addr[ASIZE-1:LASIZE],{LASIZE{1'b0}}} + line_increate_addr;
        else    curr_addr   <= curr_addr;
    end

assign out_addr = curr_addr;

endmodule
