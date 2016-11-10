/**********************************************
______________________________________________
_______  ___   ___          ___   __   _    _
_______ |     |   | |\  /| |___  |  \  |   /_\
_______ |___  |___| | \/ | |___  |__/  |  /   \
_______________________________________________
descript:
author : Young
Version: VERA.0.0
creaded: 2015/5/26 16:34:42
madified:
***********************************************/
`timescale 1ns/1ps
module rd_base_loop (
	input				rclk               ,
	input				rd_rst_n            ,
	input				vsync               ,
	input[4:0]			last_next_point     ,
	output reg[4:0]		rd_curr_point   	
);

wire			rd_vs_raising,rd_vs_falling;

edge_generator #(
	.MODE	("NORMAL")   // FAST NORMAL BEST
)edge_rd_vsync_inst(
	.clk		(rclk         ),
	.rst_n      (rd_rst_n     ),
	.in         (vsync	      ),
	.raising    (rd_vs_raising),
	.falling    (rd_vs_falling)
);

always@(posedge rclk/*,negedge rd_rst_n*/)
	if(~rd_rst_n)	rd_curr_point		<= 5'b00010;
	else if(rd_vs_raising)
					rd_curr_point		<= last_next_point;
	else			rd_curr_point		<= rd_curr_point;


endmodule

