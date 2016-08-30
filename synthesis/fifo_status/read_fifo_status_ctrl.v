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
    parameter   BURST_LEN = 100,
    parameter   LSIZE     = 9,
    parameter   WR_RD     = "READ"     // READ WRITE FIFO STATUS
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

reg [3:0]           nstate,cstate;
localparam          W_A_RST     =   4'd7,       //wait addr reset
                    IDLE        =   4'd0,
                    NEED_RD     =   4'd1,
                    WAIT_DONE   =   4'd2,
                    RD_FSH      =   4'd3,
                    TAIL_FSH    =   4'd5,
                    W_T_DONE    =   4'd6,
                    RD_TAIL     =   4'd4;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

//--->> TRIGGER <<--------------------

reg         trigger_req;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  trigger_req <= 1'b0;
    else begin
        if(WR_RD == "READ")
            trigger_req <= enable && ((FULL_LEN - THRESHOLD) > count);
        else if(WR_RD == "WRITE")
            trigger_req <= enable && ((THRESHOLD) < count);
    end

//---<< TRIGGER >>--------------------
reg     rcnt_done;

always@(*)
    case(cstate)
    W_A_RST:
        if(rcnt_done)
                nstate = IDLE;
        else    nstate = W_A_RST;
    IDLE:
        if(fsync)
            nstate = W_A_RST;
        else if(trigger_req)begin
            if(!tail_status)
                    nstate = NEED_RD;
            else    nstate = RD_TAIL;
        end else    nstate = IDLE;
    NEED_RD:
        if(resp)
                nstate = WAIT_DONE;
        else    nstate = NEED_RD;
    WAIT_DONE:
        if(done)
                nstate = RD_FSH;
        else    nstate = WAIT_DONE;
    RD_FSH:     nstate = IDLE;
    RD_TAIL:
        if(resp)
                nstate = W_T_DONE;
        else    nstate = RD_TAIL;
    W_T_DONE:
        if(done)
                nstate = TAIL_FSH;
        else    nstate = W_T_DONE;
    TAIL_FSH:   nstate = IDLE;
    default:    nstate = IDLE;
    endcase

//--->> WAIT ADDR RESET <<-------
always@(posedge clock,negedge rst_n)begin:WAIT_ADDR_RST_BLOCK
reg [4:0]       rcnt;
    if(~rst_n)begin
        rcnt        <= 5'd0;
        rcnt_done   <= 1'b0;
    end else begin
        case(nstate)
        W_A_RST:    rcnt <= rcnt + !fsync;
        default:    rcnt <= 5'd0;
        endcase

        if(!fsync)
                rcnt_done   <= rcnt > 5'd30;
        else    rcnt_done   <= 1'b0;
end end

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
        NEED_RD:length   <= BURST_LEN;
        RD_TAIL:length   <= tail_len;
        default:length   <= length;
        endcase

assign req_len  = length;
//---<< length >>---------------
//--->> DONE SIGNAL <<----------
reg         burst_done_reg;
reg         tail_done_reg;

always@(posedge clock,negedge rst_n)begin
    if(~rst_n)begin
        burst_done_reg  <= 1'b0;
        tail_done_reg   <= 1'b0;
    end else begin
        case(nstate)
        RD_FSH: burst_done_reg  <= 1'b1;
        default:burst_done_reg  <= 1'b0;
        endcase

        case(nstate)
        TAIL_FSH:
                tail_done_reg   <= 1'b1;
        default:tail_done_reg   <= 1'b0;
        endcase
end end

assign burst_done   = burst_done_reg;
assign tail_done    = tail_done_reg;
//---<< DONE SIGNAL >>----------

endmodule
