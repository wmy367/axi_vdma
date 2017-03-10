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
module little_window_partten (
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
    output          de,
    output [23:0]   data,
    output[15:0]    vactive,
    output[15:0]    hactive
);

assign vactive  = height;
assign hactive  = width ;

import SystemPkg::*;

logic   lw_vs      ;
logic   lw_hs      ;
logic   lw_de_1080p;
logic   lw_de      ;

little_window little_window_inst(
/*    input     */      .pclk           (pclk       ),
/*    input     */      .prst_n         (prst_n     ),
/*	  input     */      .enable         (enable		),
//---coeff---
/*    input[11:0]*/     .top            (top           ),
/*    input[11:0]*/     .left           (left          ),
/*    input[11:0]*/     .width          (width         ),
/*    input[11:0]*/     .height         (height        ),
/*    output    */      .vs             (lw_vs         ),
/*    output    */      .hs             (lw_hs         ),
/*    output    */      .de_1080p       (lw_de_1080p   ),
/*    output    */      .de             (lw_de         )
);


gen_test #(
	.DSIZE     (24/3    ),
	.DEPTH     (9          ),
	.SIM	   (SIM   )
)gen_test_inst(
/*	input					*/  .pclk		(pclk                ),
/*	input 					*/  .prst_n     (prst_n              ),
/*	input					*/  .invs		(lw_vs               ),
/*	input					*/  .inhs		(lw_hs               ),
/*	input					*/  .inde		(lw_de               ),
/*	output					*/  .vs         (          ),
/*	output					*/  .hs         (          ),
/*	output					*/  .de         (          ),
/*	output[DSIZE-1:0]		*/  .rdata      (data[23:16]         ),
/*	output[DSIZE-1:0]		*/  .gdata      (data[15:8]          ),
/*	output[DSIZE-1:0]		*/  .bdata      (data[7:0]           ),
/*  output                  */  .select     (                    )
);

// assign  vs          = lw_vs      ;
// assign  hs          = lw_hs      ;
// assign  de_1080p    = lw_de_1080p;
// assign  de          = lw_de      ;

latency #(
    .LAT        (1  ),
    .DSIZE      (4          )
)latency_inst(
    pclk    ,
    prst_n  ,
    {lw_vs,lw_hs,lw_de_1080p,lw_de},
    {vs,   hs,   de_1080p,   de}
);

endmodule
