/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/10 下午3:45:02
madified:
***********************************************/
`timescale 1ns/1ps
module read_line_len_sum #(
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
    output[LSIZE-1:0]   tail_len                ,
    output              tail_leave              ,
    output              frame_tail_leave
);

wire	burst_done_raising;
wire    burst_done_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_burst_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (burst_done          ),
	.raising    (burst_done_raising  ),
	.falling    (burst_done_falling  )
);

wire	tail_done_raising;
wire    tail_done_falling;
edge_generator #(
	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
)gen_tail_edge(
	.clk		(clock				),
	.rst_n      (rst_n              ),
	.in         (tail_done           ),
	.raising    (tail_done_raising   ),
	.falling    (tail_done_falling   )
);


reg [23:0]            int_len;
reg [23:0]            mod_len;
reg [23:0]            num_of_AXID;
reg [23:0]            num_of_AXID_frame;
reg                   last_or_no;
wire[31:0]            all_bits;
wire[31:0]            frame_all_bits;

assign  all_bits        = MODE=="LINE"? hactive : (MODE=="ONCE"? vactive*hactive : 0);
assign  frame_all_bits  = vactive*hactive;
always@(posedge clock)begin:FALSE_PATH
    int_len     <= all_bits*DSIZE/(AXI_DSIZE*NOR_BURST_LEN);
    num_of_AXID <= all_bits*DSIZE/AXI_DSIZE + last_or_no;
    mod_len     <= num_of_AXID - int_len*NOR_BURST_LEN;
    last_or_no  <= (all_bits*DSIZE & (AXI_DSIZE-1)) != 0;

    num_of_AXID_frame   <= frame_all_bits*DSIZE/AXI_DSIZE + last_or_no;
end

reg [31:0]          len_count;

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)      len_count   <= 32'hFFFF_FFFF;
    else begin
        if(fsync)   len_count   <= num_of_AXID;
        // else if(burst_done_raising)
        else if(burst_done_falling)
                    len_count   <= len_count - NOR_BURST_LEN;
        // else if(tail_done_raising)
        else if(tail_done_falling)
                    len_count   <= num_of_AXID;
        else        len_count   <= len_count;
end end

//--->> frame count <<----------------------
(* dont_touch = "true" *)
reg [31:0]          frame_len_count;

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)      frame_len_count   <= 32'hFFFF_FFFF;
    else begin
        if(fsync)   frame_len_count   <= num_of_AXID_frame;
        // else if(burst_done_raising)
        else if(burst_done_falling)
                    frame_len_count   <= frame_len_count - NOR_BURST_LEN;
        // else if(tail_done_raising)
        else if(tail_done_falling)
                    frame_len_count   <= frame_len_count - tail_len;
        else        frame_len_count   <= frame_len_count;
end end
(* dont_touch = "true" *)
reg     frame_tail_leave_reg;

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  frame_tail_leave_reg    <= 1'b0;
    else begin
        // if(tail_done_falling)
                frame_tail_leave_reg    <= frame_len_count <= tail_len;
        // else    frame_tail_leave_reg    <= frame_tail_leave_reg;
    end
end

assign frame_tail_leave = frame_tail_leave_reg;
//---<< frame count >>----------------------
reg         status_reg;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  status_reg  <= 1'b0;
    else begin
        if(len_count < NOR_BURST_LEN)
                status_reg  <= 1'b1;
        else    status_reg  <= 1'b0;
    end

assign tail_status  = status_reg;
assign tail_len     = (mod_len==0)? NOR_BURST_LEN : mod_len;

reg         tail_leave_reg;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  tail_leave_reg  <= 1'b0;
    else begin
        // tail_leave_reg = len_count <= NOR_BURST_LEN;
        tail_leave_reg = len_count < NOR_BURST_LEN;
    end

assign tail_leave   = tail_leave_reg;

endmodule
