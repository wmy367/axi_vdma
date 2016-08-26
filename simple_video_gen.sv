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
    parameter MODE = "1080P@60"
)(
    input       enable,
    video_native_inf.compact_out    inf,
    axi_stream_inf.master           axis
);

video_sync_generator_B2 #(
	.MODE		(MODE)
)video_sync_generator_inst(
/*	input			*/	.pclk 		(inf.pclk  		),
/*	input			*/	.rst_n      (inf.prst_n 	),
/*	input			*/	.pause		(1'b0		),
/*	input			*/	.enable     (enable		),
	//--->> Extend Sync
/*	output			*/	.vsync  	(inf.vsync  ),
/*	output			*/	.hsync      (inf.hsync  ),
/*	output			*/	.de         (inf.de		),
/*	output			*/	.field      (			),
/*  output          */  .ng_vs      (ng_vsync   ),
/*  output          */  .ng_hs      (ng_hsync   )
);

int test_data;

always@(posedge inf.pclk)begin
    if(inf.vsync)
            test_data   <= 0;
    else if(inf.de)
            test_data   <= test_data + 1;
    else    test_data   <= 0;
end

assign inf.data = test_data;

native_to_axis #(
    .DSIZE          (inf.DSIZE  ),
    .FRAME_SYNC     ("OFF"      )     //OFF ON
)native_to_axis_inst(
/*  input              */ .clock                   (inf.pclk    ),
/*  input              */ .rst_n                   (inf.prst_n  ),
/*  input              */ .enable                  (enable      ),
/*  input              */ .vsync                   (ng_vsync    ),
/*  input              */ .hsync                   (ng_hsync    ),
/*  input              */ .de                      (inf.de      ),
/*  input [DSIZE-1:0]  */ .idata                   (test_data[inf.DSIZE-1:0]),
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
