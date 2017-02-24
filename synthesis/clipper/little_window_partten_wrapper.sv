/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2017/2/19 下午10:16:24
madified:
***********************************************/
module little_window_partten_wrapper (
    input           enable,
    //---coeff---
    input[11:0]                     top     ,
    input[11:0]                     left    ,
    input[11:0]                     width   ,
    input[11:0]                     height  ,
    video_native_inf.compact_out    inf,
    output                          de_1080p
);

little_window_partten little_window_partten_inst(
/*    input         */  .pclk          (inf.pclk        ),
/*    input         */  .prst_n        (inf.prst_n      ),
/*    input         */  .enable        (enable          ),
    //---coeff---
/*    input[11:0]   */  .top           (top             ),
/*    input[11:0]   */  .left          (left            ),
/*    input[11:0]   */  .width         (width           ),
/*    input[11:0]   */  .height        (height          ),
/*    output        */  .vs            (inf.vsync       ),
/*    output        */  .hs            (inf.hsync       ),
/*    output        */  .de_1080p      (de_1080p        ),
/*    output        */  .de            (inf.de          ),
/*    output [23:0] */  .data          (inf.data        ),
/*    output[15:0]  */  .vactive       (/*inf.vactive */    ),
/*    output[15:0]  */  .hactive       (/*inf.hactive */    )
);

assign inf.vactive  = {4'b0000,height};
assign inf.hactive  = {4'b0000,width};
endmodule
