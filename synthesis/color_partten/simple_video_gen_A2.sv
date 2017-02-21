/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.1.0
    only native
Version: VERA.2.0 2017/2/19 下午10:13:50
    add h v to interface
creaded: 2016/8/26 下午4:42:30
madified:2016/11/25 上午9:33:10
***********************************************/
`timescale 1ns/1ps
module simple_video_gen_A2 #(
    parameter MODE = "1080P@60",
    parameter DSIZE= 24
)(
    input       enable,
    video_native_inf.compact_out    inf

);

logic[15:0]      vactive;
logic[15:0]      hactive;

assign inf.vactive  = vactive;
assign inf.hactive  = hactive;

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
//
// bit [7:0]   div8 = 8'b0000_0001;
//
// always@(posedge inf.pclk)begin
//     if(inf.de)begin
//         div8 <= {div8[6:0],div8[7]};
//     end else begin
//         div8 <= div8;
// end end
//
wire	de_raising;
wire    de_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)de_gen_edge(
	.clk		(inf.pclk 	 ),
	.rst_n      (1'b1        ),
	.in         (inf.de      ),
	.raising    (de_raising  ),
	.falling    (de_falling  )
);

int test_data;
//
always@(posedge inf.pclk)begin:TEST_DATA_BLOCK
int tmp_data;
    // if(inf.vsync)
    //         tmp_data   <= 0;
    // else if(inf.de)
    //         tmp_data   <= tmp_data + div8[7];
    //         // tmp_data   <= tmp_data + 1'b1;
    // else    tmp_data   <= tmp_data;
    //
    // if(div8[6])
    //         test_data   <= tmp_data;
    // else    test_data   <= 0;

    if(inf.vsync)
            test_data   <= 0;
    else if(de_falling)
            test_data   <= test_data + (1<<16);
    else if(inf.de)
            test_data   <= test_data + 1'b1;
    else    test_data   <= 0;
    // else begin
    //         test_data[15:0]     <= 0;
    //         // test_data[31:16]    <= 0;
    //         test_data[31:16]    <= test_data[31:16];
    // end
end

// assign inf.data = test_data;
// // assign inf.data = 1023;

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


endmodule
