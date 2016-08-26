/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/25 下午1:51:37
madified:
***********************************************/
`timescale 1ns/1ps
module write_line_len_sum #(
    parameter NOR_BURST_LEN     = 200,
    parameter MODE      = "ONCE",   //ONCE LINE
    parameter AXI_DSIZE = 256,
    parameter DSIZE     = 24,
    parameter LSIZE     = 9
)(
    input               clock                   ,
    input               rst_n                   ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               fsync                   ,
    input               burst_done               ,
    input               tail_done                ,
    output              tail_status             ,
    output[LSIZE-1:0]   tail_len
);

read_line_len_sum #(
    .NOR_BURST_LEN    (NOR_BURST_LEN),
    .MODE             (MODE         ),   //ONCE LINE
    .AXI_DSIZE        (AXI_DSIZE    ),
    .DSIZE            (DSIZE        ),
    .LSIZE            (LSIZE        )
)read_line_len_sum_inst(
/*  input             */ .clock                 (clock         ),
/*  input             */ .rst_n                 (rst_n         ),
/*  input [15:0]      */ .vactive               (vactive       ),
/*  input [15:0]      */ .hactive               (hactive       ),
/*  input             */ .fsync                 (fsync         ),
/*  input             */ .burst_done            (burst_done    ),
/*  input             */ .tail_done             (tail_done     ),
/*  output            */ .tail_status           (tail_status   ),
/*  output[LSIZE-1:0] */ .tail_len              (tail_len      )
);

endmodule
