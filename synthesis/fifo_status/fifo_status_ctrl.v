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
    parameter   BURST_LEN = 100,
    parameter   LSIZE     = 9,
    parameter   MODE      = "LINE"  //LINE ONCE
)(
    input                   clock,
    input                   rst_n,
    input                   enable,
    input                   f_rst_status,
    input [9:0]             count,
    input                   line_tail,
    input                   frame_tail,
    input [LSIZE-1:0]       tail_len,
    input                   fifo_empty,

    output                  burst_req,
    output                  tail_req,
    output                  burst_done,
    output                  tail_done,
    input                   resp,
    input                   done,
    output[LSIZE-1:0]       req_len,
    output reg              rst_chain
);

reg [3:0]           nstate,cstate;
localparam          IDLE        =   4'd0,
                    NEED_WR     =   4'd1,
                    WAIT_DONE   =   4'd2,
                    FSH         =   4'd3,
                    WR_TAIL     =   4'd4,
                    TAIL_DONE   =   4'd5,
                    TAIL_FSH    =   4'd6,
                    TIME_ERR    =   4'd7,
                    RESET_CHAIN =   4'd8;


always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cstate <= IDLE;
    else  begin
        if(f_rst_status)
                cstate <= IDLE;
        else    cstate <= nstate;
    end

reg     burst_exec,tail_exec;
reg     timeout;

always@(*)
    case(cstate)
    IDLE:
        if(!enable)
                nstate = IDLE;
        else if(tail_exec && !fifo_empty)
                nstate = WR_TAIL;
        else if(burst_exec && !fifo_empty)
                nstate = NEED_WR;
        else    nstate = IDLE;
    NEED_WR:
        if(timeout)
                nstate  = TIME_ERR;
        else if(resp)
                nstate = WAIT_DONE;
        else    nstate = NEED_WR;
    WAIT_DONE:
        if(timeout)
                nstate  = TIME_ERR;
        else if(done)
                nstate = FSH;
        else    nstate = WAIT_DONE;
    FSH:        nstate = IDLE;
    //------------//
    WR_TAIL:
        if(timeout)
                nstate  = TIME_ERR;
        else if(resp)
                nstate = TAIL_DONE;
        else    nstate = WR_TAIL;
    TAIL_DONE:
        if(timeout)
                nstate  = TIME_ERR;
        else if(done)
                nstate = TAIL_FSH;
        else    nstate = TAIL_DONE;
    TAIL_FSH:   nstate = IDLE;
    TIME_ERR:   nstate = RESET_CHAIN;
    RESET_CHAIN:
        if(fifo_empty)
                nstate = IDLE;
        else    nstate = RESET_CHAIN;
    default:    nstate = IDLE;
    endcase

reg     require_reg;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  require_reg <= 1'b0;
    else
        case(nstate)
        NEED_WR:
                require_reg <= 1'b1;
        default:require_reg <= 1'b0;
        endcase

reg     tail_require_reg;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  tail_require_reg <= 1'b0;
    else
        case(nstate)
        WR_TAIL:
                tail_require_reg <= 1'b1;
        default:tail_require_reg <= 1'b0;
        endcase

assign burst_req    = require_reg;
assign tail_req     = tail_require_reg;

//--->> EXECUTE? <<-----
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  burst_exec  <= 1'b0;
    else begin
        burst_exec <= count >= THRESHOLD;
    end

reg         burst_idle;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  burst_idle  <= 1'b0;
    else
        case(nstate)
        IDLE:   burst_idle  <= 1'b1;
        default:burst_idle  <= 1'b0;
        endcase

reg [3:0]       tnstate,tcstate;
localparam  TIDLE   = 4'd0,
            CATCHT  = 4'd1,
            TAP_1   = 4'd4,
            EXECT   = 4'd2,
            TFSH    = 4'd3;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  tcstate     <= TIDLE;
    else        tcstate     <= tnstate;

wire	line_tail_raising;
wire    line_tail_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_line_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (line_tail          ),
	.raising    (line_tail_raising  ),
	.falling    (line_tail_falling  )
);

wire	frame_tail_raising;
wire    frame_tail_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_frame_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (frame_tail          ),
	.raising    (frame_tail_raising  ),
	.falling    (frame_tail_falling  )
);

always@(*)
    case(tcstate)
    TIDLE:
        if(
            ((MODE=="LINE")&&line_tail_raising) ||
            ((MODE=="ONCE")&&frame_tail_raising) )
                tnstate = CATCHT;
        else    tnstate = TIDLE;

    CATCHT:
        if(timeout)
                tnstate  = TIDLE;
        else if(burst_idle)begin
            if(count != 10'd0)
                    tnstate = TAP_1;
            else    tnstate = TIDLE;
        end else
                tnstate = CATCHT;
    TAP_1:      tnstate = EXECT;
    EXECT:
        if(timeout)
                tnstate  = TIDLE;
        else if(done)
                tnstate = TFSH;
        else    tnstate = EXECT;
    TFSH:       tnstate = TIDLE;
    default:    tnstate = TIDLE;
    endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  tail_exec   <= 1'b0;
    else
        case(tnstate)
        EXECT:  tail_exec   <= 1'b1;
        default:tail_exec   <= 1'b0;
        endcase


// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)  tail_exec   <= 1'b0;
//     else begin
//         if(count != 9'd0 && !done)begin
//             if(tail_exec == 1'b0)
//                     tail_exec   <= tail;
//             else    tail_exec   <= tail_exec;       //clause
//         end else    tail_exec   <= 1'b0;
//     end
//---<< EXECUTE? >>-----
//--->> length <<------
reg [LSIZE-1:0]   len_reg;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  len_reg     <= {LSIZE{1'd0}};
    else
        case(nstate)
        NEED_WR:    len_reg <= BURST_LEN;
        WR_TAIL:    len_reg <= tail_len;
        WAIT_DONE:  len_reg <= len_reg;
        // default:    len_reg <= {LSIZE{1'd0}};
        default:    len_reg <= len_reg;
        endcase

assign  req_len = len_reg;
//---<< length >>------
//--->> DONE SIGNAL <<-------
reg     burst_done_reg,tail_done_reg;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  burst_done_reg  <= 1'b0;
    else
        case(nstate)
        FSH:    burst_done_reg  <= 1'b1;
        default:burst_done_reg  <= 1'b0;
        endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  tail_done_reg  <= 1'b0;
    else
        case(nstate)
        TAIL_FSH:
                tail_done_reg  <= 1'b1;
        default:tail_done_reg  <= 1'b0;
        endcase

assign burst_done   = burst_done_reg;
assign tail_done    = tail_done_reg;
//---<< DONE SIGNAL >>-------
//--->> timeout <<-----------
reg [23:0]      tcnt;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  tcnt    <= 24'd0;
    else
        case(nstate)
        IDLE:   tcnt    <= 24'd0;
        // default:tcnt    <= tcnt + 1'b1;
        default:tcnt    <= 24'd0;
        endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  timeout    <= 1'd0;
    else begin
        case(nstate)
        IDLE,TIME_ERR,RESET_CHAIN:
                timeout <= 1'b0;
        default:timeout <= tcnt > 24'hFFF_000;
        endcase
    end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  rst_chain    <= 1'd0;
    else
        case(nstate)
        TIME_ERR:
                rst_chain    <= 1'b1;
        default:rst_chain    <= 1'b0;
        endcase
        // rst_chain   <= 1'b0;

//---<< timeout >>-----------
endmodule
