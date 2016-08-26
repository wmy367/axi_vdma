/**********************************************
______________________________________________
_______  ___   ___          ___   __   _    _
_______ |     |   | |\  /| |___  |  \  |   /_\
_______ |___  |___| | \/ | |___  |__/  |  /   \
_______________________________________________
descript:
author : Young
Version: VEAR.0.0
creaded: 2015/5/26 17:13:47
madified:
***********************************************/
`timescale 1ns/1ps
module bit5_encode (
	input			clk     ,
	input			rst_n   ,
	input [4:0]		code    ,
	output[2:0]		op		
);

reg[2:0]		outdata;

always@(posedge clk,negedge rst_n)
	if(~rst_n)	outdata		<= 3'd0;
	else
		casex(code)
		5'bxxxx1:	outdata	<= 3'd0;
        5'bxxx10:	outdata	<= 3'd1;
        5'bxx100:	outdata	<= 3'd2;
        5'bx1000:	outdata	<= 3'd3;
        5'b10000:	outdata	<= 3'd4;
		default:	outdata	<= 3'd0;
		endcase

assign	op	= outdata;


endmodule

