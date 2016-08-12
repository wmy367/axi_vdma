/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/5 下午3:17:25
madified:
***********************************************/
`timescale 1ns/1ps
module read_fifo_status_ctrl #(
    parameter   THRESHOLD = 200,        // EMPTY THRESHOLD
    parameter   FULL_LEN  = 256,
    parameter   FRAME_SYNC= "OFF",    //OFF ON
    parameter   LSIZE     = 9
)(
    input                   clock,
    input                   rst_n,
    input                   enable,
    input [8:0]             count,
    input                   tail_status,
    input [LSIZE-1:0]       tail_len,

    output                  burst_req,
    output                  tail_req,
    input                   resp,
    input                   done,
    output[LSIZE-1:0]       req_len
);

reg [3:0]           nstate,cstate;
localparam          IDLE        =   4'd0,
                    NEED_RD     =   4'd1,
                    WAIT_DONE   =   4'd2,
                    FSH         =   4'd3,
                    RD_TAIL     =   4'd4;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

//--->> TRIGGER <<--------------------
// wire	trail_raising;
// wire    trail_falling;
// edge_generator #(
// 	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
// )gen_tail_edge(
// 	.clk		(clock				),
// 	.rst_n      (rst_n              ),
// 	.in         (tail               ),
// 	.raising    (tail_raising       ),
// 	.falling    (tail_falling       )
// );

reg         trigger_req;
// reg         trigger_tail;
// reg         tail_exec;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  trigger_req <= 1'b0;
    else        trigger_req <= enable && ((FULL_LEN - THRESHOLD) > count);

// always@posedge clock,negedge rst_n)begin:NEED_TAIL_PROC
// reg     tail_req_record;
//     if(~rst_n)begin
//         trigger_tail    <= 1'b0;
//         tail_req_record <= 1'b0;
//     end else begin
//         if(tail_raising)
//                 tail_req_record <= 1'b1;
//         else if(tail_exec)
//                 tail_req_record <= 1'b0;
//         else    tail_req_record <= tail_req_record;
//
//         if(enable)begin
//                 trigger_tail    <= ((FULL_LEN - THRESHOLD) > count) && tail_req_record;
//         end else if(tail_exec)
//                 trigger_tail    <= 1'b0;
//         else    trigger_tail    <= trigger_tail;
// end end

always@(*)
    case(cstate)
    IDLE:
        if(trigger_req)begin
            if(!tail_status)
                    nstate = NEED_RD;
            else    nstate = RD_TAIL;
        end else    nstate = IDLE;
    NEED_RD:
        if(resp)
                nstate = WAIT_DONE;
        else    nstate = NEED_RD;
    RD_TAIL:
        if(resp)
                nstate = WAIT_DONE;
        else    nstate = RD_TAIL;
    WAIT_DONE:
        if(done)
                nstate = FSH;
        else    nstate = WAIT_DONE;
    FSH:        nstate = IDLE;
    default:    nstate = IDLE;
    endcase

//----->> STATE MCH <<-------------------
reg     tail_exec;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  tail_exec   <= 1'b0;
    else
        case(nstate)
        RD_TAIL:tail_exec   <= 1'b1;
        default:tail_exec   <= 1'b0;
        endcase

//--->> BURST REQUIRE <<--------
reg         burst_req_reg;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  burst_req_reg   <= 1'b0;
    else
        case(nstate)
        NEED_RD:
                burst_req_reg   <= 1'b1;
        default:burst_req_reg   <= 1'b0;
        endcase

reg         tail_req_reg;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  tail_req_reg    <= 1'b0;
    else
        case(nstate)
        RD_TAIL:
                tail_req_reg    <= 1'b1;
        default:tail_req_reg    <= 1'b0;
        endcase

assign burst_req    = burst_req_reg;
assign tail_req     = tail_req_reg;
//---<< BURST REQUIRE >>--------
//--->> length <<---------------
reg [LSIZE-1:0]     length;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  length   <= {LSIZE{1'b0}};
    else
        case(nstate)
        NEED_RD:length   <= THRESHOLD;
        RD_TAIL:length   <= tail_len;
        default:length   <= length;
        endcase

assign req_len  = length;
//---<< length >>---------------

endmodule
