/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/25 下午4:59:23
madified:
***********************************************/
`timescale 1ns/1ps
module fifo_status_ctrl #(
    parameter   THRESHOLD = 200,
    parameter   LSIZE     = 9
)(
    input                   clock,
    input                   rst_n,
    input [8:0]             count,
    input                   tail,
    input                   fifo_empty,

    output                  burst_req,
    output                  tail_req,
    input                   resp,
    input                   done,
    output[LSIZE-1:0]       req_len
);

reg [3:0]           nstate,cstate;
localparam          IDLE        =   4'd0,
                    NEED_WR     =   4'd1,
                    WAIT_DONE   =   4'd2,
                    FSH         =   4'd3,
                    WR_TAIL     =   4'd4;


always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate <= IDLE;
    else        cstate <= nstate;

always@(*)
    case(cstate)
    IDLE:
        if(burst_exec && !fifo_empty)
                nstate = NEED_WR;
        else if(tail_exec && !fifo_empty)
                nstate = WR_TAIL;
        else    nstate = IDLE;
    NEED_WR:
        if(resp)
                nstate = WAIT_DONE;
        else    nstate = NEED_WR;
    WR_TAIL:
        if(resp)
                nstate = WAIT_DONE;
        else    nstate = WR_TAIL;
    WAIT_DONE:
        if(done)
                nstate = FSH;
        else    nstate = WAIT_DONE;
    FSHL:       nstate = IDLE;
    default:    nstate = IDLE;
    endcase

reg     require_reg;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  require_reg <= 1'b0;
    else
        case(nstate)
        NEED_WR,WR_TAIL:
                require_reg <= 1'b1;
        default:require_reg <= 1'b0;
        endcase

//--->> EXECUTE? <<-----
always@(posedge clock,negedge rst_n)
    if(~rst_n)  burst_exec  <= 1'b0;
    else begin
        burst_exec <= count > THRESHOLD;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  tail_exec   <= 1'b0;
    else begin
        if(count != 9'd0 && !done)begin
            if(tail_exec == 1'b0)
                    tail_exec   <= tail;
            else    tail_exec   <= tail_exec;       //clause
        end else    tail_exec   <= 1'b0;
    end
//---<< EXECUTE? >>-----
//--->> length <<------
reg [LSIZE-1:0]   len_reg;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  len_reg     <= {LSIZE{1'd0}};
    else
        case(nstate)
        NEED_WR:    len_reg <= THRESHOLD;
        WR_TAIL:    len_reg <= count;
        default:    len_reg <= {LSIZE{1'd0}};
        endcase

assign  req_len = len_reg;
//---<< length >>------



endmodule
