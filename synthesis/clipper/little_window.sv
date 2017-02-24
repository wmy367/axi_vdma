/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2017/2/4 下午1:37:03
madified:
***********************************************/
`timescale 1ns/1ps
import SystemPkg::*;
module little_window (
    input           pclk,
    input           prst_n,
    input           enable,
    //---coeff---
    input[11:0]     top     ,
    input[11:0]     left    ,
    input[11:0]     width   ,
    input[11:0]     height  ,

    output          vs,
    output          hs,
    output          de_1080p,
    output          de
);

wire gen_vsync;
wire gen_hsync;
wire gen_de	;

parameter MODE = (SIM=="ON"||SIM=="TRUE")? "TEST" : "1080P@60" ;

video_sync_generator_B3 #(
	.MODE		(MODE)
)video_sync_generator_inst(
/*	input			*/	.pclk 		(pclk  		),
/*	input			*/	.rst_n      (prst_n 	),
/*	input			*/	.pause		(1'b0		),
/*	input			*/	.enable     (enable		),
	//--->> Extend Sync
/*	output			*/	.vsync  	(gen_vsync      ),
/*	output			*/	.hsync      (gen_hsync      ),
/*	output			*/	.de         (gen_de		    ),
/*	output			*/	.field      (			),
/*  output          */  .ng_vs      (   ),
/*  output          */  .ng_hs      (   ),
/*  output[15:0]    */  .vactive    (    ),
/*  output[15:0]    */  .hactive    (    )
);

clipper_window clipper_inst(
	.pclk					(pclk	 		),
	.prst_n                 (prst_n         ),
	.invsync                (gen_vsync  	),
	.inhsync                (gen_hsync  	),
	.inde                   (gen_de		    ),
	//---coeff---
	.clipper_top            (top      ),
	.clipper_left           (left     ),
	.clipper_width          (width    ),
	.clipper_height         (height   ),
	//----------
	.outvsync               (vs 		),
	.outhsync               (hs         ),
	.outde                  (de         ),
    .origin_de              (de_1080p       )
);

endmodule
