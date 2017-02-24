/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/22 上午11:05:34
madified:
***********************************************/
`timescale 1ns/1ps
module axi_inf_write_state_core #(
    parameter IDSIZE    = 3,
    parameter ID        = 0,
    parameter LSIZE     = 10,
    parameter ASIZE     = 32
)(
        input              write_req     ,
        output             req_resp      ,
        output             req_done      ,
        input [LSIZE-1:0]  req_len       ,
        input [ASIZE-1:0]  req_addr      ,
        output logic       pull_data_en  ,
        input              pend_in       ,
        output             pend_out      ,
        input              fifo_empty    ,
        input              axi_aclk      ,
        input              axi_resetn    ,
        //-- addr write signals
        output[IDSIZE-1:0] axi_awid      ,
        output[ASIZE-1:0]  axi_awaddr    ,
        output[LSIZE-1:0]  axi_awlen     ,
        output[2:0]        axi_awsize    ,
        output[1:0]        axi_awburst   ,
        output[0:0]        axi_awlock    ,
        output[3:0]        axi_awcache   ,
        output[2:0]        axi_awprot    ,
        output[3:0]        axi_awqos     ,
        output             axi_awvalid   ,
        input              axi_awready   ,
        //-- response signals
        output             axi_bready    ,
        input [IDSIZE-1:0] axi_bid       ,
        input [1:0]        axi_bresp     ,
        input              axi_bvalid    ,
        //-- data write signals
        output             axi_wlast     ,
        input              axi_wvalid    ,
        input              axi_wready
);
//--->> RV signals <<-------
assign  axi_awid    = ID;
assign  axi_awaddr  = req_addr;
// assign  axi_awlen   = req_len;
assign  axi_awsize  = 3'b101;
assign  axi_awburst = 2'b01;
assign  axi_awlock  = 1'b0;
assign  axi_awcache = 4'b0000;
assign  axi_awprot  = 3'b000;
assign  axi_awqos   = 4'b0000;
reg [LSIZE-1:0]     awlen_reg;
assign axi_awlen = awlen_reg;
always@(posedge axi_aclk)
    if(req_len != {LSIZE{1'b0}})
            awlen_reg   <= req_len -1'b1;
    else    awlen_reg   <= {LSIZE{1'b0}};
// assign  axi_awvalid = 1'b0;
//---<< RV signals >>-------

typedef enum {  IDLE       ,
                PEND       ,
                SET_VLD    ,
                WAIT_LAST  ,
                SET_BRDY   ,
                DONE       ,
                BERR       } STATUS;

STATUS       nstate,cstate;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) cstate  <= IDLE;
    else            cstate  <= nstate;

always@(*)
    case(cstate)
    IDLE:
        if(write_req)begin
            if(pend_in)
                    nstate = PEND;
            else    nstate  = SET_VLD;
        end else    nstate  = IDLE;
    PEND:
        if(write_req && !pend_in && axi_awready)
                nstate  = SET_VLD;
        else    nstate  = PEND;
    SET_VLD:
        if(axi_awready)
                nstate  = WAIT_LAST;
        else    nstate  = SET_VLD;
    WAIT_LAST:
        if(axi_wready&axi_wvalid&axi_wlast)
                nstate  = SET_BRDY;
        else    nstate  = WAIT_LAST;
    SET_BRDY:
        // if(axi_bvalid && (axi_bid==ID))begin
        //     if(axi_bresp == 2'b00)
        //             nstate  = DONE;
        //     else    nstate  = BERR;
        // end else    nstate  = SET_BRDY;
        if(axi_bvalid)
                nstate  = DONE;
        else    nstate  = SET_BRDY;
    DONE:   nstate = IDLE;
    BERR:   nstate = IDLE;
    default:nstate = IDLE;
    endcase

//--->> addr write valid <<-------
reg         aw_valid_reg;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) aw_valid_reg    <= 1'b0;
    else
        case(nstate)
        SET_VLD:    aw_valid_reg    <= 1'b1;
        default:    aw_valid_reg    <= 1'b0;
        endcase
assign axi_awvalid  = aw_valid_reg;
//---<< addr write valid >>-------
//--->> Response ready <<---------
reg         b_ready_reg;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) b_ready_reg <= 1'b0;
    else
        case(nstate)
        SET_BRDY:   b_ready_reg <= 1'b1;
        default:    b_ready_reg <= 1'b0;
        endcase
assign axi_bready   = b_ready_reg;
//--->> Response ready <<---------
//--->> LAST DATA <<-------------
reg [LSIZE-1:0]     length;
reg [LSIZE-1:0]     len_sub_2,len_sub_1;

always@(posedge axi_aclk/*,negedge axi_resetn*/)begin
    if(~axi_resetn)begin
        length      <= {LSIZE{1'b1}};
        len_sub_1   <= {LSIZE{1'b1}};
        len_sub_2   <= {LSIZE{1'b1}};
    end else if(write_req)begin
            length      <= req_len;
            if(req_len>0)
                    len_sub_1   <= req_len-2'd1;
            else    len_sub_1   <= {LSIZE{1'b0}};
            if(req_len>1)
                    len_sub_2   <= req_len-2'd2;
            else    len_sub_2   <= {LSIZE{1'b0}};
    end else begin
        length      <= length;
        len_sub_1   <= len_sub_1;
        len_sub_2   <= len_sub_2;
end end

reg [LSIZE-1:0]     lcnt;

always@(posedge axi_aclk/*,negedge axi_resetn*/)begin
    if(~axi_resetn) lcnt    <= {LSIZE{1'b0}};
    else begin
        if(aw_valid_reg)
            lcnt    <= {LSIZE{1'b0}};
        else if(axi_wvalid && axi_wlast && axi_wready)
            lcnt    <= {LSIZE{1'b0}};
        else begin
            if(axi_wready && axi_wvalid)
                    lcnt <= lcnt + 1'b1;
            else    lcnt <= lcnt;
end end end

reg             last_reg;
always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) last_reg    <= 1'b0;
    else begin
        if(axi_wvalid && axi_wlast && axi_wready)
                last_reg    <= 1'b0;
        else begin
            last_reg    <= ((lcnt == len_sub_2) && (axi_wvalid && axi_wready)) || (lcnt == len_sub_1);
            // last_reg    <= (lcnt == len_sub_2);
    end end

assign axi_wlast    = last_reg;
//---<< LAST DATA >>-------------
//--->> enable pull data <<------
reg         pull_en;
always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) pull_en <= 1'b0;
    else
        case(nstate)
        WAIT_LAST:  pull_en <= 1'b1;
        default:    pull_en <= 1'b0;
        endcase

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) pull_data_en    <= 1'b0;
    else     pull_data_en <= pull_en;

// assign pull_data_en = pull_en;
//---<< enable pull data >>------
//--->> resp done <<-------------
reg     resp_reg,done_reg;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) resp_reg    <= 1'b0;
    else
        case(nstate)
        SET_VLD:    resp_reg    <= 1'b1;
        default:    resp_reg    <= 1'b0;
        endcase

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) done_reg    <= 1'b0;
    else
        case(nstate)
        DONE:       done_reg    <= 1'b1;
        default:    done_reg    <= 1'b0;
        endcase

assign req_resp = resp_reg;
assign req_done = done_reg;
//---<< resp done >>-------------
//--->> pending <<---------------
reg     pend_reg;
always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) pend_reg    <= 1'b0;
    else
        case(nstate)
        IDLE,DONE,BERR:
                    pend_reg    <= 1'b0;
        default:    pend_reg    <= 1'b1;
        endcase

assign  pend_out    = pend_reg;
//---<< pending >>---------------

endmodule

module axi_inf_read_state_core #(
    parameter IDSIZE    = 3,
    parameter ID        = 0,
    parameter LSIZE     = 10,
    parameter ASIZE     = 32,
    parameter DSIZE     = 256
)(
    input               fsync        ,
    input               read_req     ,
    output              req_resp     ,
    output              req_done     ,
    input [LSIZE-1:0]   req_len      ,
    input [ASIZE-1:0]   req_addr     ,
    output              push_data_en ,
    input               pend_in       ,
    output              pend_out      ,
    input               fifo_full     ,
    input               axi_aclk      ,
    input               axi_resetn    ,
    //-- address read signals
    output[IDSIZE-1:0]  axi_arid      ,
    output[ASIZE-1:0]   axi_araddr    ,
    output[LSIZE-1:0]   axi_arlen     ,
    output[2:0]         axi_arsize    ,
    output[1:0]         axi_arburst   ,
    output[0:0]         axi_arlock    ,
    output[3:0]         axi_arcache   ,
    output[2:0]         axi_arprot    ,
    output[3:0]         axi_arqos     ,
    output              axi_arvalid   ,
    input               axi_arready   ,
    //-- data read signals
    output              axi_rready    ,
    input [IDSIZE-1:0]  axi_rid       ,
    // input [DSIZE-1:0]   axi_rdata     ,
    input [1:0]         axi_rresp     ,
    input               axi_rlast     ,
    input               axi_rvalid
);
//--->> RV <<-------------
assign axi_arid     = ID;
assign axi_araddr   = req_addr;
// assign axi_arlen    = req_len-1'b1;
assign axi_arsize   = 3'b101;
assign axi_arburst  = 2'b01;
assign axi_arlock   = 1'b0;
assign axi_arcache  = 4'b0000;
assign axi_arprot   = 3'b000;
assign axi_arqos    = 4'b0000;
reg [LSIZE-1:0] arlen_reg;
assign axi_arlen = arlen_reg;

always@(posedge axi_aclk)
    if(|req_len)
            arlen_reg   <= req_len-1'b1;
    else    arlen_reg   <= arlen_reg;
//---<< RV >>-------------
// assign axi_arvalid
// assign axi_arready

typedef enum {  IDLE       ,
                SET_VLD    ,
                WAIT_LAST  ,
                DONE       ,
                PEND       ,
                WAIT_FSYNC } STATUS ;
STATUS      cstate,nstate;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) cstate <= IDLE;
    else            cstate <= nstate;

(*  dont_touch = "true" *)
logic         timeout;

always@(*)
    case(cstate)
    IDLE:
        if(read_req)begin
            if(pend_in)
                    nstate = PEND;
            else    nstate = SET_VLD;
        end else    nstate = IDLE;
    PEND:
        /*if(fsync)
            nstate = IDLE;
        else */if(read_req && !pend_in && axi_arready)
                nstate = SET_VLD;
        else    nstate = PEND;
    SET_VLD:
        /*if(fsync)
            nstate = IDLE;
        else */if(axi_arready && axi_arvalid)
                nstate = WAIT_LAST;
        // else if(timeout)
        //         nstate = WAIT_FSYNC;
        else    nstate = SET_VLD;
    WAIT_LAST:
        /*if(fsync)
            nstate = IDLE;
        // else if(axi_rready && axi_rlast && axi_rvalid && (axi_rid==ID))
        // else if(axi_rready && axi_rlast && axi_rvalid)
        else*/ if(axi_rready && axi_rlast && axi_rvalid)
                nstate = DONE;
        else if(timeout)
                nstate = WAIT_FSYNC;
        else    nstate = WAIT_LAST;
    DONE:       nstate = IDLE;
    WAIT_FSYNC:
        if(fsync)
                nstate = IDLE;
        else    nstate = WAIT_FSYNC;
    default:    nstate = IDLE;
    endcase

//--->> address read valid <<------------
reg     ar_valid_reg;
always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) ar_valid_reg    <= 1'b0;
    else
        case(nstate)
        SET_VLD:    ar_valid_reg    <= 1'b1;
        default:    ar_valid_reg    <= 1'b0;
        endcase
assign axi_arvalid  = ar_valid_reg;
//---<< address read valid >>------------
//--->> push data enable <<--------------
reg     push_en;
always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) push_en     <= 1'b0;
    else
        case(nstate)
        WAIT_LAST:  push_en     <= 1'b1;
        default:    push_en     <= 1'b0;
        endcase
// assign push_data_en = push_en;
// assign axi_rready   = push_en;

assign push_data_en = 1'b1;
assign axi_rready   = 1'b1;
// assign axi_rready   = !fifo_full;
//---<< push data enable >>--------------
//--->> resp done <<-------------
reg     resp_reg,done_reg;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) resp_reg    <= 1'b0;
    else
        case(nstate)
        SET_VLD:    resp_reg    <= 1'b1;
        default:    resp_reg    <= 1'b0;
        endcase

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) done_reg    <= 1'b0;
    else
        case(nstate)
        DONE:       done_reg    <= 1'b1;
        default:    done_reg    <= 1'b0;
        endcase

assign req_resp = resp_reg;
assign req_done = done_reg;
//---<< resp done >>-------------
//--->> pending <<---------------
reg     pend_reg;
always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) pend_reg    <= 1'b0;
    else
        case(nstate)
        IDLE,DONE:
                    pend_reg    <= 1'b0;
        default:    pend_reg    <= 1'b1;
        endcase

assign  pend_out    = pend_reg;
//---<< pending >>---------------
//--->> TIMEOOUT <<--------------
reg            tenable;
reg [23:0]      tcnt;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) tcnt    <= 24'd0;
    else begin
        if(tenable)
                tcnt    <= tcnt + 1'b1;
        else    tcnt    <= 24'd0;
    end

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) tenable <= 1'd0;
    else begin
        if(axi_arvalid && axi_arready)
                tenable     <= 1'b1;
        else if(axi_rvalid && axi_rready && axi_rlast)
                tenable     <= 1'b0;
        else if(timeout)
                tenable     <= 1'b0;
        else    tenable     <= tenable;
    end

// always@(posedge axi_aclk/*,negedge axi_resetn*/)
//     if(~axi_resetn) timeout     <= 1'b0;
//     else            timeout     <= tcnt == 24'hFFF_FFF;

assign timeout = 1'b0;
//---<< TIMEOOUT >>--------------
//-->> READ CNT <<--------------
(* dont_touch = "true" *)
reg [8:0]       rcnt;

always@(posedge axi_aclk/*,negedge axi_resetn*/)
    if(~axi_resetn) rcnt <= 9'd0;
    else begin
        if(axi_arvalid && axi_arready)
                rcnt     <= 9'd0;
        else if(axi_rvalid && axi_rready)
                rcnt     <= rcnt + 1'b1;
        else    rcnt     <= rcnt;
    end

endmodule
