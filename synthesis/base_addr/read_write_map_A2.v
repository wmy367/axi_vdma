/**********************************************
______________________________________________
_______  ___   ___          ___   __   _    _
_______ |     |   | |\  /| |___  |  \  |   /_\
_______ |___  |___| | \/ | |___  |__/  |  /   \
_______________________________________________
descript:
author : Young
Version: VERA.2.0 : 2016/7/20 上午10:44:13
    add wr_vs enable
creaded: 2015/5/26 16:43:01
madified:
***********************************************/
`timescale 1ns/1ps
module read_write_map_A2 #(
	parameter		RDPORT	= 3
)(
	input		wclk        ,
	input		wrst_n      ,
	input		wr_vs       ,
    input       wr_enable   ,

	input [2:0]	rclk        ,
	input [2:0]	rd_rst_n    ,
	input [2:0]	rd_vs       ,

	output[2:0]	wr_base		,
	output[2:0]	rd_base0    ,
	output[2:0]	rd_base1    ,
	output[2:0]	rd_base2
);

wire [3*5-1:0]	rd_curr_point ;
wire [4:0]		last_next_point;
wire [4:0]		wr_current_point;

baseaddr_loop_A2 baseaddr_loop_inst(
	.wclk       		(wclk 					),
	.wrst_n       		(wrst_n   				),
	.wr_vs          	(wr_vs      			),
    .enable             (wr_enable              ),

	.rd0_curr_point	   	(rd_curr_point[4:0]   	),
	.rd1_curr_point	    (rd_curr_point[9:5]  	),
	.rd2_curr_point	    (rd_curr_point[14:10]   ),

    .wr_current_point	(wr_current_point		),
	.last_next_point 	(last_next_point		)


);


wire [3*5-1:0]	curr_point;
wire [3*3-1:0]	read_base;
genvar II;
generate
for(II=0;II<3;II=II+1)begin:GEN_READ_BASE
rd_base_loop rd_base_loop_inst(
	.rclk               (rclk[II]               ),
	.rd_rst_n           (rd_rst_n[II]           ),
	.vsync              (rd_vs[II]              ),
	.last_next_point    (last_next_point        ),
	.rd_curr_point 		(curr_point[II*5+:5]	)
);
end

if(RDPORT == 3)begin
	assign	  rd_curr_point[4:0]  	= curr_point[4:0];
	assign	  rd_curr_point[9:5]  	= curr_point[9:5];
	assign	  rd_curr_point[14:10]	= curr_point[14:10];
end else if(RDPORT == 2)begin
	assign	  rd_curr_point[4:0]  	= curr_point[4:0];
	assign	  rd_curr_point[9:5]  	= curr_point[9:5];
	assign	  rd_curr_point[14:10]	= 5'b00000;
end else if(RDPORT == 1)begin
	assign	  rd_curr_point[4:0]  	= curr_point[4:0];
	assign	  rd_curr_point[9:5]  	= 5'b00000;
	assign	  rd_curr_point[14:10]	= 5'b00000;
end

for(II=0;II<3;II=II+1)begin:GEN_BIT_ENCODE
bit5_encode bit5_encode_inst(
	.clk    	(rclk[II]	        ),
	.rst_n  	(rd_rst_n[II]	    ),
	.code   	(rd_curr_point[II*5+:5]	),
	.op			(read_base[II*3+:3]	)
);
end

endgenerate

bit5_encode bit5_wr_encode_inst(
	.clk    	(wclk	        	),
	.rst_n  	(wrst_n	    		),
	.code   	(wr_current_point	),
	.op			(wr_base			)
);

assign	rd_base0	= read_base[2:0]    ;
assign	rd_base1	= read_base[5:3]    ;
assign	rd_base2	= read_base[8:6]	;


endmodule
