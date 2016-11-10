/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/26 下午1:33:56
madified:
***********************************************/
`timescale 1ns/1ps
module stream_in_port #(
    parameter DSIZE = 24    ,
    parameter MODE  = "ONCE"    ,// ONCE  LINE
    parameter FRAME_SYNC = "OFF" // OFF ON
)(
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               fsync                   ,
    input               fifo_almost_full        ,
    //-- axi stream ---
    input               aclk                    ,
    input               aclken                  ,
    input               aresetn                 ,
    input [DSIZE-1:0]   axi_tdata               ,
    input               axi_tvalid              ,
    output              axi_tready              ,
    input               axi_tuser               ,
    input               axi_tlast               ,
    //-- axi stream
    output              falign                  ,
    output              lalign                  ,
    output              ealign                  ,
    output              odata_vld               ,
    output[DSIZE-1:0]   odata
);

assign  axi_tready = fifo_almost_full;

// wire [DSIZE-1:0]   tip_axi_tdata  ;
// wire               tip_axi_tvalid ;
wire               tip_axi_tuser  ;
// wire               tip_axi_tlast  ;

generate
if(FRAME_SYNC == "OFF")begin
assign tip_axi_tuser = axi_tuser;
end else begin
assign tip_axi_tuser = fsync;
end
endgenerate

assign  falign      = tip_axi_tuser;
assign  lalign      = MODE=="LINE"? axi_tlast : 1'b0;
assign  odata_vld   = axi_tvalid;
assign  odata       = axi_tdata;


reg [15:0]      lcnt;

always@(posedge aclk/*,negedge aresetn*/)
    if(~aresetn)  lcnt    <= 16'd0;
    else begin
        if(falign)
            lcnt    <= 16'd0;
        else if(lalign)
            lcnt    <= lcnt + 1'b1;
        else
            lcnt    <= lcnt;
    end

reg frame_blk;

always@(posedge aclk/*,negedge aresetn*/)
    if(~aresetn)    frame_blk   <=1'd0;
    else            frame_blk   <= lcnt == vactive;

wire	frame_blk_raising;
wire    frame_blk_falling;
edge_generator #(
	.MODE		("BEST" 	)  // FAST NORMAL BEST
)gen_edge(
	.clk		(aclk				),
	.rst_n      (aresetn            ),
	.in         (frame_blk          ),
	.raising    (frame_blk_raising  ),
	.falling    (frame_blk_falling  )
);

assign ealign   = frame_blk_raising;

endmodule
