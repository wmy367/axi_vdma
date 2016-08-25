/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/25 下午1:46:31
madified:
***********************************************/
`timescale 1ns/1ps
module write_fifo_status_ctrl #(
    parameter   THRESHOLD = 200,        //  THRESHOLD
    parameter   FULL_LEN  = 256,
    parameter   LSIZE     = 9
)(
    input                   clock,
    input                   rst_n,
    input                   enable,
    input [9:0]             count,
    input                   fsync,
    input                   tail_status,
    input [LSIZE-1:0]       tail_len,

    output                  burst_req,
    output                  tail_req,
    output                  burst_done,
    output                  tail_done,
    input                   resp,
    input                   done,
    output[LSIZE-1:0]       req_len
);


read_fifo_status_ctrl #(
    .THRESHOLD  (THRESHOLD      ),// EMPTY THRESHOLD
    .FULL_LEN   (FULL_LEN       ),
    .LSIZE      (LSIZE          ),
    .WR_RD      ("WRITE"        )
)read_fifo_status_ctrl_inst(
/*  input                */   .clock            (clock            ),
/*  input                */   .rst_n            (rst_n            ),
/*  input                */   .enable           (enable           ),
/*  input                */   .fsync            (fsync            ),
/*  input [8:0]          */   .count            (count            ),
/*  input                */   .tail_status      (tail_status      ),
/*  input [LSIZE-1:0]    */   .tail_len         (tail_len         ),
/*  output               */   .burst_req        (burst_req        ),
/*  output               */   .tail_req         (tail_req         ),
/*  output               */   .burst_done       (burst_done       ),
/*  output               */   .tail_done        (tail_done        ),
/*  input                */   .resp             (resp             ),
/*  input                */   .done             (done             ),
/*  output[LSIZE-1:0]    */   .req_len          (req_len          )
);

endmodule
