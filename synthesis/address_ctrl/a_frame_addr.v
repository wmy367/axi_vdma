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
    parameter BURST_MAP_ADDR    = 200*8*8
)(
    input               clock,
    input               rst_n,
    input               new_base,
    input[ASIZE-1:0]    baseaddr,
    input[ASIZE-1:0]    line_increate_addr,
    input               burst_req,
    input               tail_req,
    output[ASIZE-1:0]   out_addr
);


wire	burst_req_raising;
wire    burst_req_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_burst_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (burst_req          ),
	.raising    (burst_req_raising  ),
	.falling    (burst_req_falling  )
);

wire	tail_req_raising;
wire    tail_req_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_tail_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (tail_req           ),
	.raising    (tail_req_raising   ),
	.falling    (tail_req_falling   )
);


reg [ASIZE-1:0]     curr_addr;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_addr   <= {ASIZE{1'b0}};
    else begin
        if(new_base)
                curr_addr   <= baseaddr;
        else if(burst_req_falling)
                curr_addr   <= curr_addr + BURST_MAP_ADDR;
        else if(tail_req_falling)
                curr_addr   <= curr_addr + line_increate_addr;
        else    curr_addr   <= curr_addr;
    end

assign out_addr = curr_addr;

endmodule
