/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/26 下午3:09:53
madified:
***********************************************/
`timescale 1ns/1ps
module in_port #(
    parameter DSIZE     = 24,
    parameter MODE      = "ONCE",   //ONCE LINE
    parameter DATA_TYPE = "AXIS",    //AXIS NATIVE
    parameter FRAME_SYNC= "OFF"    //OFF ON
)(
    input               clock                   ,
    input               rst_n                   ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               vsync                   ,
    input               hsync                   ,
    input               de                      ,
    input [DSIZE-1:0]   idata                   ,
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

reg     chk_fifo_empty;

generate
if(DATA_TYPE == "AXIS")begin
stream_in_port #(
    .DSIZE      (DSIZE      ),
    .MODE       (MODE       ),// ONCE  LINE
    .FRAME_SYNC (FRAME_SYNC ) // OFF ON
)stream_in_port_inst(
/*    input [15:0]   */     .vactive                 (vactive                 ),
/*    input [15:0]   */     .hactive                 (hactive                 ),
/*    input          */     .fsync                   (fsync                   ),
/*    input          */     .fifo_almost_full        (fifo_almost_full        ),
    //-- axi stream ---
/*    input             */  .aclk                    (aclk                    ),
/*    input             */  .aclken                  (aclken                  ),
/*    input             */  .aresetn                 (aresetn                 ),
/*    input [DSIZE-1:0] */  .axi_tdata               (axi_tdata               ),
/*    input             */  .axi_tvalid              (axi_tvalid              ),
/*    output            */  .axi_tready              (axi_tready              ),
/*    input             */  .axi_tuser               (axi_tuser               ),
/*    input             */  .axi_tlast               (axi_tlast               ),
    //-- axi stream
/*    output            */  .falign                  (falign                  ),
/*    output            */  .lalign                  (lalign                  ),
/*    output            */  .ealign                  (ealign                  ),
/*    output            */  .odata_vld               (odata_vld               ),
/*    output[DSIZE-1:0] */  .odata                   (odata                   )
);
end else if(DATA_TYPE == "NATIVE")begin
native_in_port #(
    .DSIZE      (DSIZE  ),
    .MODE       (MODE   ),// ONCE  LINE
    .FRAME_SYNC (FRAME_SYNC)// OFF ON
)native_in_port_inst(
/*    input             */  .clock                   (clock                   ),
/*    input             */  .rst_n                   (rst_n                   ),
/*    input [15:0]      */  .vactive                 (vactive                 ),
/*    input [15:0]      */  .hactive                 (hactive                 ),
/*    input             */  .vsync                   (vsync                   ),
/*    input             */  .hsync                   (hsync                   ),
/*    input             */  .de                      (de                      ),
/*    input [DSIZE-1:0] */  .idata                   (idata                   ),

/*    output            */  .falign                  (falign                  ),
/*    output            */  .lalign                  (lalign                  ),   // not last data of line
/*    output            */  .ealign                  (ealign                  ),
/*    output            */  .odata_vld               (odata_vld               ),
/*    output[DSIZE-1:0] */  .odata                   (odata                   )
);
end
endgenerate

endmodule
