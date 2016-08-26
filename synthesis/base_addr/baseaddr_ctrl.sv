/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
    contrl multi vmda baseaddr
author : Young
Version: VERA.0.0
creaded: 2016/8/26 下午2:42:42
madified:
***********************************************/
`timescale 1ns/1ps
module baseaddr_ctrl (
    input               write_enable,
    vdma_baseaddr_ctrl_inf.master   write ,
    vdma_baseaddr_ctrl_inf.master   rd0 ,
    vdma_baseaddr_ctrl_inf.master   rd1 ,
    vdma_baseaddr_ctrl_inf.master   rd2
);


read_write_map_A2 #(
	.RDPORT			(2		)
)read_write_map_inst(
/*	input		*/	.wclk      	(write.clk        	    ),
/*	input		*/	.wrst_n    	(write.rst_n      	    ),
/*	input		*/	.wr_vs     	(write.vs       		),
/*  input       */  .wr_enable  (write_enable           ),
/*	            */
/*	input [2:0]	*/	.rclk    	({rd2.clk,rd1.clk,rd0.clk}    	),
/*	input [2:0]	*/	.rd_rst_n   ({rd2.rst_n,rd1.rst_n,rd0.rst_n}   ),
/*	input [2:0]	*/	.rd_vs      ({rd2.vs,rd1.vs,rd0.vs}      ),
/*              */
/*	output[2:0]	*/	.wr_base	(write.point			),
/*	output[2:0]	*/	.rd_base0	(rd0.point               ),
/*	output[2:0]	*/	.rd_base1   (rd1.point               ),
/*	output[2:0]	*/	.rd_base2	(rd2.point               )
);

endmodule
