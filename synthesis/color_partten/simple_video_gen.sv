/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/26 下午4:42:30
madified:
***********************************************/
`timescale 1ns/1ps
module simple_video_gen #(
    parameter MODE = "1080P@60",
    parameter DSIZE= 24
)(
    input       enable,
    video_native_inf.compact_out    inf,
    axi_stream_inf.master           axis,
    output[15:0]                    vactive,
    output[15:0]                    hactive
);

wire vsync;
wire hsync;
wire de	;

video_sync_generator_B3 #(
	.MODE		(MODE)
)video_sync_generator_inst(
/*	input			*/	.pclk 		(inf.pclk  		),
/*	input			*/	.rst_n      (inf.prst_n 	),
/*	input			*/	.pause		(1'b0		),
/*	input			*/	.enable     (enable		),
	//--->> Extend Sync
/*	output			*/	.vsync  	(vsync      ),
/*	output			*/	.hsync      (hsync      ),
/*	output			*/	.de         (de		    ),
/*	output			*/	.field      (			),
/*  output          */  .ng_vs      (ng_vsync   ),
/*  output          */  .ng_hs      (ng_hsync   ),
/*  output[15:0]    */  .vactive    (vactive    ),
/*  output[15:0]    */  .hactive    (hactive    )
);


gen_test #(
	.DSIZE     (DSIZE/3    ),
	.DEPTH     (9          ),
	.SIM	   ("FALSE"    )
)gen_test_inst(
/*	input					*/  .pclk		(inf.pclk            ),
/*	input 					*/  .prst_n     (inf.prst_n          ),
/*	input					*/  .invs		(vsync               ),
/*	input					*/  .inhs		(hsync               ),
/*	input					*/  .inde		(de                  ),
/*	output					*/  .vs         (inf.vsync           ),
/*	output					*/  .hs         (inf.hsync           ),
/*	output					*/  .de         (inf.de              ),
/*	output[DSIZE-1:0]		*/  .rdata      (inf.data[23:16]     ),
/*	output[DSIZE-1:0]		*/  .gdata      (inf.data[15:8]      ),
/*	output[DSIZE-1:0]		*/  .bdata      (inf.data[7:0]       ),
/*  output                  */  .select     (                    )
);


native_to_axis #(
    .DSIZE          (DSIZE  ),
    .FRAME_SYNC     ("OFF"      )     //OFF ON
)native_to_axis_inst(
/*  input              */ .clock                   (inf.pclk    ),
/*  input              */ .rst_n                   (inf.prst_n  ),
/*  input              */ .enable                  (enable      ),
/*  input              */ .vsync                   (ng_vsync    ),
/*  input              */ .hsync                   (ng_hsync    ),
/*  input              */ .de                      (inf.de      ),
/*  input [DSIZE-1:0]  */ .idata                   (inf.data    ),
    //-- axi stream ---
/*  output             */ .aclk                    (    ),
/*  output             */ .aclken                  (    ),
/*  output             */ .aresetn                 (    ),
/*  output [DSIZE-1:0] */ .axi_tdata               (axis.axi_tdata   ),
/*  output             */ .axi_tvalid              (axis.axi_tvalid  ),
/*  input              */ .axi_tready              (axis.axi_tready  ),
/*  output             */ .axi_tuser               (axis.axi_tuser   ),
/*  output             */ .axi_tlast               (axis.axi_tlast   )
);

endmodule
