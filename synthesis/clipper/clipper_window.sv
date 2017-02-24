/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2017/2/4 下午1:37:17
madified:
***********************************************/
`timescale 1ns/1ps
module clipper_window (
	input					pclk			,
	input					prst_n          ,
	input					invsync         ,
	input					inhsync         ,
	input					inde            ,
	//---coeff---
	input[11:0] 			clipper_top     ,
	input[11:0] 			clipper_left    ,
	input[11:0] 			clipper_width   ,
	input[11:0] 			clipper_height  ,
	//----------
	output					outvsync        ,
	output					outhsync        ,
	output					outde           ,
    output logic            origin_de
);


reg	[11:0]				xcnt,ycnt;

always@(posedge pclk,negedge prst_n)
	if(~prst_n)		xcnt	<= 12'd0;
	else if(inde)	xcnt	<= xcnt + 1'b1;
	else			xcnt	<= 12'd0;

wire		inde_falling;
edge_generator #(
	.MODE	("NORMAL")   // FAST NORMAL BEST
)edge_generator_inst(
	.clk		(pclk     		),
	.rst_n      (prst_n    		),
	.in         (inde    		),
	.raising    (            	),
	.falling    (inde_falling	)
);


always@(posedge pclk,negedge prst_n)
	if(~prst_n)		ycnt	<= 12'd0;
	else if(invsync)
					ycnt	<= 12'd0;
	else			ycnt	<= ycnt + inde_falling;


reg [11:0]		width_start     ;
reg [11:0]		height_start    ;
reg [11:0]		reg_width   ;
reg [11:0]		reg_height	;

always@(posedge pclk,negedge prst_n)begin
	if(~prst_n)begin
		width_start    	<=	12'h000;
        height_start   	<=	12'h000;
        reg_width  	<=	12'hFFF;
        reg_height	<=	12'hFFF;
	end else if(invsync) begin
		width_start     <=	clipper_left ;
		height_start    <=	clipper_top ;
		reg_width   <=	|clipper_width ? clipper_width-1'b1  	: 12'hFFF;
		reg_height	<=	|clipper_height? clipper_height-1'b1	: 12'hFFF;
	end else begin
		width_start     <=	width_start   ;
        height_start    <=  height_start  ;
        reg_width   <=  reg_width ;
        reg_height	<=  reg_height;
end end

reg [12:0]			width_end,height_end;

always@(posedge pclk,negedge prst_n)begin
	if(~prst_n)begin
		width_end	<= 13'h1fff;
		height_end	<= 13'h1fff;
	end else begin
		width_end	<=	width_start 	+ reg_width 	;
        height_end	<=  height_start    + reg_height    ;
end end

reg					width_yield,height_yield;
always@(posedge pclk,negedge prst_n)begin
	if(~prst_n)begin
		width_yield		<= 1'b0;
		height_yield	<= 1'b0;
	end else begin
		width_yield		<= xcnt >= width_start && xcnt <= width_end;
		height_yield	<= ycnt	>= height_start && ycnt <= height_end;
end end

wire				vs_d1,hs_d1,de_d1;

cross_clk_sync #(
	.DSIZE    	(3),
	.LAT		(1)
)cross_clk_sync_and_data(
	pclk,
	prst_n,
	{invsync,inhsync,inde},
	{vs_d1,hs_d1,de_d1}
);

reg					vs_d2,hs_d2,de_d2;

always@(posedge pclk,negedge prst_n)begin
	if(~prst_n)begin
		vs_d2  		<= 1'b0;
		hs_d2		<= 1'b0;
		de_d2		<= 1'b0;
        origin_de   <= 1'b0;
	end else begin
		vs_d2  		<= vs_d1;
        hs_d2		<= hs_d1;
        de_d2		<= de_d1 & height_yield & width_yield;
        origin_de   <= de_d1;
end end

assign	outvsync  	= vs_d2  	;
assign	outhsync    = hs_d2	    ;
assign	outde       = de_d2	    ;

endmodule
