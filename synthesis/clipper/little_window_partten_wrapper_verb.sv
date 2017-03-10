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
module little_window_partten_wrapper_verb #(
    parameter LAT_1080P   = 1
)(
    input           enable,
    //---coeff---
    input[11:0]                     top     ,
    input[11:0]                     left    ,
    input[11:0]                     width   ,
    input[11:0]                     height  ,
    video_native_inf.compact_out    inf,
    video_native_inf.compact_out    inf_1080p_sync
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

// assign inf.vactive  = {4'b0000,height};
// assign inf.hactive  = {4'b0000,width};

always@(posedge inf.pclk,negedge inf.prst_n)
    if(~inf.prst_n) inf.vactive     <= '0;
    else begin
        if(inf.vs_raising)
                inf.vactive <= inf.v_index;
        else    inf.vactive <= inf.vactive;
    end

always@(posedge inf.pclk,negedge inf.prst_n)
    if(~inf.prst_n) inf.hactive     <= '0;
    else begin
        if(inf.de_falling)
                inf.hactive <= inf.h_index;
        else    inf.hactive <= inf.hactive;
    end

latency #(
    .LAT        (LAT_1080P+2  ),
    .DSIZE      (3          )
)latency_inst(
    inf.pclk    ,
    inf.prst_n  ,
    {inf.vsync,inf.hsync,de_1080p},
    {inf_1080p_sync.vsync,inf_1080p_sync.hsync,inf_1080p_sync.de}
);

assign inf_1080p_sync.vactive  = {4'b0000,height};
assign inf_1080p_sync.hactive  = {4'b0000,width};

endmodule
