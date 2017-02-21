/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERB.0.0 2017/2/17 下午8:21:20
    cut axis
creaded: 2016/7/26 下午3:09:53
madified:
***********************************************/
`timescale 1ns/1ps
module in_port_verb #(
    parameter DSIZE     = 24,
    parameter MODE      = "ONCE"   //ONCE LINE
)(
    input               clock                   ,
    input               rst_n                   ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               vsync                   ,
    input               hsync                   ,
    input               de                      ,
    input [DSIZE-1:0]   idata                   ,
    input               fifo_almost_full        ,
    //-- axi stream
    output              falign                  ,
    output              lalign                  ,
    output              ealign                  ,
    (* dont_touch = "true" *)
    output              odata_vld               ,
    (* dont_touch = "true" *)
    output[DSIZE-1:0]   odata
);

native_in_port #(
    .DSIZE      (DSIZE  ),
    .MODE       (MODE   )// ONCE  LINE
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

endmodule
