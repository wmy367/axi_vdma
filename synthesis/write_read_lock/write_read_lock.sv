/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
    axi4 write read lock ,pend each other
author : Young
Version: VERA.0.0
creaded: 2016/8/29 下午1:15:44
madified:
***********************************************/
`timescale 1ns/1ps
module write_read_lock (
    input           clock,
    input           rst_n,
    input           wr_req,
    input           rd_req,
    input           wr_done,
    input           rd_done,
    output logic    pend_wr,
    output logic    pend_rd
);

typedef enum {WR_IDLE,RD_IDLE,EXEC_WR,WR_FSH,EXEC_RD,RD_FSH} Lock_M;

Lock_M nstate,cstate;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cstate <= WR_IDLE;
    else        cstate <= nstate;

always@(*)
    case(cstate)
    WR_IDLE:
        if(wr_req)
                nstate = EXEC_WR;
        else if(rd_req)
                nstate = EXEC_RD;
        else    nstate = WR_IDLE;
    RD_IDLE:
        if(rd_req)
                nstate = EXEC_RD;
        else if(wr_req)
                nstate = EXEC_WR;
        else    nstate = RD_IDLE;
    EXEC_WR:
        if(wr_done)
                nstate = RD_IDLE;
        else    nstate = EXEC_WR;
    EXEC_RD:
        if(rd_done)
                nstate = WR_IDLE;
        else    nstate = EXEC_RD;
    default:    nstate = WR_IDLE;
    endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  pend_wr <= 1'b0;
    else
        case(nstate)
        EXEC_RD:pend_wr <= 1'b1;
        default:pend_wr <= 1'b0;
        endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  pend_rd <= 1'b0;
    else
        case(nstate)
        EXEC_WR:pend_rd <= 1'b1;
        default:pend_rd <= 1'b0;
        endcase

endmodule
