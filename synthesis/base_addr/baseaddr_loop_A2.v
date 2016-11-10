/**********************************************
______________________________________________
_______  ___   ___          ___   __   _    _
_______ |     |   | |\  /| |___  |  \  |   /_\
_______ |___  |___| | \/ | |___  |__/  |  /   \
_______________________________________________
descript:
author : Young
Version: VERA.2.0 : 2016/7/20 上午10:41:49
    add enable
creaded: 2015/5/26 13:44:11
madified:
***********************************************/
`timescale 1ns/1ps
module baseaddr_loop_A2 (
	input			wclk        	,
	input			wrst_n          ,
    input           enable          ,
	input			wr_vs           ,

	input [4:0]		rd0_curr_point	,
	input [4:0]		rd1_curr_point	,
	input [4:0]		rd2_curr_point	,

	output reg[4:0]	wr_current_point,
	output reg[4:0]	last_next_point

);

wire			wr_vs_raising,wr_vs_falling;

edge_generator #(
	.MODE	("NORMAL")   // FAST NORMAL BEST
)edge_wr_vsync_inst(
	.clk		(wclk         ),
	.rst_n      (wrst_n     ),
	.in         (wr_vs && enable	      ),
	.raising    (wr_vs_raising),
	.falling    (wr_vs_falling)
);


reg [4:0]		wr_next_point,wr_next_point_Q;
reg [4:0]		wr0_curr_point;
reg [3:0]		prit [4:0];
reg	[4:0]		pri_point;

always@(posedge wclk/*,negedge wrst_n*/)
	if(~wrst_n)	wr_current_point	<= 5'b00001;
	else if(wr_vs_raising)
					wr_current_point	<= wr_next_point_Q;
	else			wr_current_point	<= wr_current_point;

always@(posedge wclk/*,negedge wrst_n*/)
	if(~wrst_n)	wr_next_point_Q	<= 5'b00000;
	else
		casex(wr_next_point)
		5'bxxxx1:	wr_next_point_Q	<= 5'b00001;
		5'bxxx10:	wr_next_point_Q	<= 5'b00010;
		5'bxx100:	wr_next_point_Q	<= 5'b00100;
		5'bx1000:	wr_next_point_Q	<= 5'b01000;
		5'b10000:	wr_next_point_Q	<= 5'b10000;
		default:	wr_next_point_Q	<= 5'b00001;
		endcase


always@(posedge wclk/*,negedge wrst_n*/)
	if(~wrst_n)	wr_next_point		<= 5'b00001;
	else 			wr_next_point		<= ~(	wr_current_point 	|
												rd0_curr_point		|
												rd1_curr_point		|
												rd2_curr_point		);


always@(posedge wclk/*,negedge wrst_n*/)begin:prit_BLOCK
integer II;
	if(~wrst_n)begin
		for(II=0;II<5;II=II+1)
			prit[II]	<= 4'd2;
	end else begin
		for(II=0;II<5;II=II+1)begin
			if(wr_vs_raising)
				if(wr_next_point_Q[II])
						prit[II]	<= 5'd0;
				else if(prit[II] < 4'd2)
					 	prit[II]	<= prit[II] + 1'b1;
				else 	prit[II]	<= prit[II];
			else		prit[II]	<= prit[II];
end end end

always@(posedge wclk/*,negedge wrst_n*/)begin:PRI_POINT_BLOCK
integer II;
	if(~wrst_n)	pri_point	<= 5'b00000;
	else begin
		for(II=0;II<5;II=II+1)
			pri_point[II] <= prit[II] == 5'd1;
end end

always@(posedge wclk/*,negedge wrst_n*/)begin
	if(~wrst_n)	last_next_point	<= 5'b00000;
	else
		casex(pri_point)
		5'bxxxx1:	last_next_point	<= 5'b00001;
		5'bxxx10:	last_next_point	<= 5'b00010;
		5'bxx100:	last_next_point	<= 5'b00100;
		5'bx1000:	last_next_point	<= 5'b01000;
		5'b10000:	last_next_point	<= 5'b10000;
		default:	last_next_point	<= 5'b00001;
		endcase
end



endmodule
