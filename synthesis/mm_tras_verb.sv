/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERB.0.0 2017/2/17 下午8:35:08
creaded: 2016/7/25 下午4:59:23
madified:
***********************************************/
`timescale 1ns/1ps
module mm_tras_verb #(
    parameter THRESHOLD  = 200,
    parameter ASIZE      = 29,
    parameter BURST_LEN_SIZE = 9,
    parameter DSIZE     = 24,
    parameter AXI_DSIZE = 256,
    parameter IDSIZE    = 4,
    parameter ID        = 0,
    parameter MODE      = "ONCE",   //ONCE LINE
    parameter INC_ADDR_STEP = 1920
)(
    input               clock                   ,
    input               rst_n                   ,
    input               enable                  ,
    input [ASIZE-1:0]   baseaddr                ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               vsync                   ,
    input               hsync                   ,
    input               de                      ,
    input [DSIZE-1:0]   idata                   ,
    output              fifo_almost_full        ,
    input               pend_in                 ,
    output              pend_out                ,
    //-- AXI
    input             axi_aclk      ,
    input             axi_resetn    ,
    //--->> addr write <<-------
    output[IDSIZE-1:0] axi_awid      ,
    output[ASIZE-1:0]  axi_awaddr    ,
    output[BURST_LEN_SIZE-1:0]
                       axi_awlen     ,
    output[2:0]        axi_awsize    ,
    output[1:0]        axi_awburst   ,
    output[0:0]        axi_awlock    ,
    output[3:0]        axi_awcache   ,
    output[2:0]        axi_awprot    ,
    output[3:0]        axi_awqos     ,
    output             axi_awvalid   ,
    input              axi_awready   ,
    //--->> Response <<---------
    output            axi_bready    ,
    input[IDSIZE-1:0] axi_bid       ,
    input[1:0]        axi_bresp     ,
    input             axi_bvalid    ,
    //---<< Response >>---------
    //--->> data write <<-------
    output[AXI_DSIZE-1:0]   axi_wdata     ,
    output[AXI_DSIZE/8-1:0] axi_wstrb     ,
    output              axi_wlast     ,
    output              axi_wvalid    ,
    input               axi_wready
    //---<< data write >>-------
);

localparam  BURST_LEN = THRESHOLD;

assign axi_wstrb    = {(AXI_DSIZE/8){1'b1}};

wire        rd_clk;
wire        rd_rst_n;
wire        wr_clk;
wire        wr_rst_n;
wire        rst_chain;

assign rd_clk   = axi_aclk;
assign rd_rst_n = axi_resetn;

assign wr_clk   = clock;
assign wr_rst_n = rst_n;

//--->> RESET CONTRL <<---------------
wire        in_port_rstn;

broaden_and_cross_clk #(
	.PHASE	    ("NEGATIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_in_port_rst(
/*	input			*/    .rclk          (wr_clk             ),
/*	input			*/    .rd_rst_n      (wr_rst_n           ),
/*	input			*/    .wclk          (axi_aclk           ),
/*	input			*/    .wr_rst_n      (axi_resetn         ),
/*	input			*/    .d             (!rst_chain         ),
/*	output			*/    .q             (in_port_rstn       )
);

wire    combin_rstn;
wire    in_port_fifo_rst;

broaden_and_cross_clk #(
	.PHASE	    ("NEGATIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_combin_rst(
/*	input			*/    .rclk          (wr_clk             ),
/*	input			*/    .rd_rst_n      (wr_rst_n           ),
/*	input			*/    .wclk          (axi_aclk           ),
/*	input			*/    .wr_rst_n      (axi_resetn         ),
/*	input			*/    .d             (!rst_chain  && !in_port_fifo_rst       ),
/*	output			*/    .q             (combin_rstn        )
);

wire            fifo_rst;
broaden_and_cross_clk #(
	.PHASE	    ("POSITIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_fifo_rst(
/*	input			*/    .rclk          (wr_clk             ),
/*	input			*/    .rd_rst_n      (wr_rst_n           ),
/*	input			*/    .wclk          (axi_aclk           ),
/*	input			*/    .wr_rst_n      (axi_resetn         ),
/*	input			*/    .d             (rst_chain || in_port_fifo_rst        ),
/*	output			*/    .q             (fifo_rst        )
);

wire        line_sum_rstn;

// assign      line_sum_rstn   = rd_rst_n && !rst_chain;
// assign      line_sum_rstn   = rd_rst_n;
broaden_and_cross_clk #(
	.PHASE	    ("NEGATIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_line_sum_rst(
/*	input			*/    .rclk          (axi_aclk           ),
/*	input			*/    .rd_rst_n      (axi_resetn         ),
/*	input			*/    .wclk          (axi_aclk           ),
/*	input			*/    .wr_rst_n      (axi_resetn         ),
/*	input			*/    .d             (!rst_chain && !in_port_fifo_rst         ),
/*	output			*/    .q             (line_sum_rstn      )
);

wire        frame_addr_rstn;

// assign      frame_addr_rstn = rd_rst_n && !rst_chain;
// assign      frame_addr_rstn = rd_rst_n;
broaden_and_cross_clk #(
	.PHASE	    ("NEGATIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_frame_addr_rst(
/*	input			*/    .rclk          (axi_aclk           ),
/*	input			*/    .rd_rst_n      (axi_resetn         ),
/*	input			*/    .wclk          (axi_aclk           ),
/*	input			*/    .wr_rst_n      (axi_resetn         ),
/*	input			*/    .d             (!rst_chain && !in_port_fifo_rst        ),
/*	output			*/    .q             (frame_addr_rstn    )
);
wire        axi_core_rstn;

// assign      axi_core_rstn   = rd_rst_n && !rst_chain;
// assign      axi_core_rstn   = rd_rst_n;
broaden_and_cross_clk #(
	.PHASE	    ("NEGATIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_axi_core_rst(
/*	input			*/    .rclk          (axi_aclk           ),
/*	input			*/    .rd_rst_n      (axi_resetn         ),
/*	input			*/    .wclk          (axi_aclk           ),
/*	input			*/    .wr_rst_n      (axi_resetn         ),
/*	input			*/    .d             (!rst_chain && !in_port_fifo_rst        ),
/*	output			*/    .q             (axi_core_rstn      )
);

wire        fifo_status_rstn;
broaden_and_cross_clk #(
	.PHASE	    ("NEGATIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_fifo_status_rst(
/*	input			*/    .rclk          (axi_aclk           ),
/*	input			*/    .rd_rst_n      (axi_resetn         ),
/*	input			*/    .wclk          (wr_clk             ),
/*	input			*/    .wr_rst_n      (wr_rst_n           ),
/*	input			*/    .d             (!in_port_fifo_rst    ),
/*	output			*/    .q             (fifo_status_rstn     )
);
//---<< RESET CONTRL >>---------------
//--->> IN PORT INTERFACE <<----------
wire            in_port_falign     ;
wire            in_port_lalign     ;
wire            in_port_ealign     ;
wire            in_port_odata_vld  ;
(* dont_touch = "true" *)
wire[DSIZE-1:0] in_port_odata      ;
// wire            fifo_almost_full   ;

in_port_verb #(
    .DSIZE     (DSIZE     ),
    .MODE      (MODE      )   //ONCE LINE
)in_port_inst(
/*  input              */ .clock                   (clock                   ),
/*  input              */ .rst_n                   (in_port_rstn            ),
/*  input [15:0]       */ .vactive                 (vactive                 ),//for blank ealign, now is't unused
/*  input [15:0]       */ .hactive                 (hactive                 ),//unused
/*  input              */ .vsync                   (vsync                   ),
/*  input              */ .hsync                   (hsync                   ),
/*  input              */ .de                      (de                      ),
/*  input [DSIZE-1:0]  */ .idata                   (idata                   ),
/*  input              */ .fifo_almost_full        (fifo_almost_full        ),
/*  output             */ .falign                  (in_port_falign          ),
/*  output             */ .lalign                  (in_port_lalign          ),
/*  output             */ .ealign                  (in_port_ealign          ),
/*  output             */ .odata_vld               (in_port_odata_vld       ),
/*  output[DSIZE-1:0]  */ .odata                   (in_port_odata           )
);

wire in_port_falign_bc;
wire in_port_lalign_bc;

broaden_and_cross_clk #(
	.PHASE	    ("POSITIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)f_broaden_and_cross_clk_inst(
/*	input			*/    .rclk          (rd_clk             ),
/*	input			*/    .rd_rst_n      (rd_rst_n           ),
/*	input			*/    .wclk          (wr_clk             ),
/*	input			*/    .wr_rst_n      (wr_rst_n           ),
/*	input			*/    .d             (in_port_falign     ),
/*	output			*/    .q             (in_port_falign_bc  )
);

broaden_and_cross_clk #(
	.PHASE	    ("POSITIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)l_broaden_and_cross_clk_inst(
/*	input			*/    .rclk          (rd_clk             ),
/*	input			*/    .rd_rst_n      (rd_rst_n           ),
/*	input			*/    .wclk          (wr_clk             ),
/*	input			*/    .wr_rst_n      (wr_rst_n           ),
/*	input			*/    .d             (in_port_lalign     ),
/*	output			*/    .q             (in_port_lalign_bc  )
);

parameter CBSIZE    = DSIZE*(AXI_DSIZE/DSIZE);

wire[AXI_DSIZE-1:0]     cb_data;
wire                    cb_wr_en;
wire                    cb_wr_last_en;

combin_data #(
    .ISIZE      (DSIZE        ),
    .OSIZE      (CBSIZE    ),
    .DATA_TYPE  ("NATIVE"    ),
    .MODE       (MODE         )
)combin_data_inst(
/*    input               */ .clock       (wr_clk    ),
// /*    input               */ .clock       (clock    ),  //test
/*    input               */ .rst_n       (combin_rstn  ),
/*    input               */ .iwr_en      (in_port_odata_vld  ),
/*    input [ISIZE-1:0]   */ .idata       (in_port_odata      ),
/*    input               */ .ialign      (in_port_falign     ),
/*    input               */ .ilast       (in_port_lalign     ),
/*    output              */ .owr_en      (cb_wr_en         ),
/*    output              */ .olast_en    (cb_wr_last_en    ),
/*    output[OSIZE-1:0]   */ .odata       (cb_data[CBSIZE-1:0]          ),
/*    output[OSIZE/8-1:0] */ .omask       (  )
);

wire[9:0]       rd_data_count;
wire[9:0]       wr_data_count;

wire            fifo_empty;
wire            pull_data_en;

assign  in_port_fifo_rst    = in_port_falign;
// assign  fifo_rst    = 1'b0;


// always@(posedge wr_clk)begin
//     fifo_rst    <= ~fifo_rst;

//--->> TEST VSYNC <<------------------
wire vsync_cc;
cross_clk_sync #(
	.DSIZE    	(1),
	.LAT		(3)
)cross_clk_sync_false_path(
	rd_clk,
	rd_rst_n,
	vsync,
	vsync_cc
);
//---<< TEST VSYNC >>------------------
// end
(* dont_touch = "true" *)
wire    wr_fifo_en;
(* dont_touch = "true" *)
wire    rd_fifo_en;

assign  wr_fifo_en  = cb_wr_en || cb_wr_last_en ;
assign  rd_fifo_en  = (pull_data_en && axi_wready )|| vsync_cc;

generate
if(AXI_DSIZE != 512)begin
vdma_stream_fifo stream_fifo_inst (
/*  input               */     .rst               (/*fifo_rst*/ 1'b0                    ),
/*  input               */     .wr_clk            (wr_clk                       ),
/*  input               */     .rd_clk            (rd_clk                       ),
/*  input [DSIZE-1:0]   */     .din               (cb_data                      ),
/*  input               */     .wr_en             (/*cb_wr_en || cb_wr_last_en */wr_fifo_en   ),
/*  input               */     .rd_en             (/*pull_data_en && axi_wready*/rd_fifo_en   ),
/*  output [DSIZE-1:0]  */     .dout              (axi_wdata                    ),
/*  output              */     .full              (   ),
/*  output              */     .almost_full       (fifo_almost_full             ),
/*  output              */     .empty             (fifo_empty                   ),
/*  output              */     .almost_empty      (   ),
/*  output[9:0]         */     .rd_data_count     (rd_data_count[9:0]                ),
/*  output[9:0]         */     .wr_data_count     (wr_data_count[9:0]                )
);

// assign rd_data_count[9] = 1'b0;
// assign wr_data_count[9] = 1'b0;
// end else if(AXI_DSIZE == 512)begin
// vdma_stream_fifo_512 stream_fifo_inst (
// // /*  input               */     .rst               (!wr_rst_n ||  fifo_rst       ),
// // /*  input               */     .rst               (fifo_rst      ),
// /*  input               */     .wr_rst               (fifo_rst     ),
// /*  input               */     .rd_rst               (1'b0      ),
// /*  input               */     .wr_clk            (wr_clk                       ),
// /*  input               */     .rd_clk            (rd_clk                       ),
// /*  input [DSIZE-1:0]   */     .din               (cb_data/* idata*/                     ),
// /*  input               */     .wr_en             (cb_wr_en || cb_wr_last_en    ),
// /*  input               */     .rd_en             (pull_data_en && axi_wready   ),
// /*  output [DSIZE-1:0]  */     .dout              (axi_wdata                    ),
// /*  output              */     .full              (   ),
// /*  output              */     .almost_full       (fifo_almost_full             ),
// /*  output              */     .empty             (fifo_empty                   ),
// /*  output              */     .almost_empty      (   ),
// /*  output[9:0]         */     .rd_data_count     (rd_data_count                ),
// /*  output[9:0]         */     .wr_data_count     (wr_data_count                )
// );
// end

end else begin
vdma_stream_fifo_512 stream_fifo_inst (
/*  input               */     .rst               (fifo_rst                     ),
// /*  input               */     .wr_rst            (!wr_rst_n ||  fifo_rst                     ),
// /*  input               */     .rd_rst            (!wr_rst_n ||  fifo_rst                     ),
/*  input               */     .wr_clk            (wr_clk                       ),
/*  input               */     .rd_clk            (rd_clk                       ),
/*  input [DSIZE-1:0]   */     .din               (cb_data                      ),
/*  input               */     .wr_en             (cb_wr_en || cb_wr_last_en    ),
/*  input               */     .rd_en             (pull_data_en && axi_wready   ),
/*  output [DSIZE-1:0]  */     .dout              (axi_wdata                    ),
/*  output              */     .full              (   ),
/*  output              */     .almost_full       (fifo_almost_full             ),
/*  output              */     .empty             (fifo_empty                   ),
/*  output              */     .almost_empty      (   ),
/*  output[9:0]         */     .rd_data_count     (rd_data_count                ),
/*  output[9:0]         */     .wr_data_count     (wr_data_count                )
);
end

endgenerate

assign axi_wvalid   = pull_data_en;
// assign axi_wvalid   = pull_data_en && !fifo_empty;

wire    burst_req    ;
wire    tail_req     ;
wire    req_resp     ;
wire    req_done     ;
wire[BURST_LEN_SIZE-1:0]    req_length;

wire[BURST_LEN_SIZE-1:0]    tail_len;
wire    burst_done,tail_done;
wire    tail_leave;

wire frame_tail;

assign frame_tail   = tail_leave && in_port_lalign_bc ;


fifo_status_ctrl #(
    .THRESHOLD      (THRESHOLD  ),
    .BURST_LEN      (BURST_LEN  ),
    .LSIZE          (BURST_LEN_SIZE),
    .MODE           (MODE       )
)fifo_status_ctrl_inst(
/*  input             */    .clock             (rd_clk              ),
/*  input             */    .rst_n             (/*rd_rst_n*/fifo_status_rstn            ),
/*  input             */    .enable            (enable              ),
/*  input             */    .f_rst_status      (fifo_rst            ),
/*  input             */    .fifo_empty        (fifo_empty          ),
/*  input [9:0]       */    .count             (rd_data_count       ),
/*  input             */    .line_tail         (in_port_lalign_bc   ),      // not frame tail
/*  input             */    .frame_tail        (in_port_falign_bc   ),      //self count ,and tail leave
/*  input             */    .tail_leave        (tail_leave          ),      // not frame tail
/*  input [LSIZE-1:0] */    .tail_len          (tail_len            ),
/*  output            */    .burst_req         (burst_req           ),
/*  output            */    .tail_req          (tail_req            ),      //line tail
/*  output            */    .burst_done        (burst_done          ),
/*  output            */    .tail_done         (tail_done           ),
/*  input             */    .resp              (req_resp            ),
/*  input             */    .done              (req_done            ),
/*  output[LSIZE-1:0] */    .req_len           (req_length          ),
/*  output            */    .rst_chain         (rst_chain           )
);

write_line_len_sum #(
    .NOR_BURST_LEN      (BURST_LEN  ),
    .MODE               (MODE       ),   //ONCE LINE
    .AXI_DSIZE          (/*AXI_DSIZE*/CBSIZE  ),
    .DSIZE              (DSIZE      ),
    .LSIZE              (BURST_LEN_SIZE)
)write_line_len_sum_inst(
/*  input             */  .clock                (rd_clk              ),
/*  input             */  .rst_n                (rd_rst_n/*line_sum_rstn*/            ),
/*  input [15:0]      */  .vactive              (vactive             ), //calculate line length
/*  input [15:0]      */  .hactive              (hactive             ), //calculate line length
/*  input             */  .fsync                (in_port_falign_bc || tail_req ),
/*  input             */  .burst_done           (burst_done          ),
/*  input             */  .tail_done            (tail_done           ),
/*  output            */  .tail_status          (                    ),
/*  output[LSIZE-1:0] */  .tail_len             (tail_len            ),
/*  output            */  .tail_leave           (tail_leave          )
);

wire[ASIZE-1:0]         curr_address;

localparam INC_ADDR_STEP_REAL = 2**($clog2(INC_ADDR_STEP*DSIZE/AXI_DSIZE)+0)*8;
localparam BURST_MOVE = (16-$clog2(AXI_DSIZE));     //axi_dsize=128->13

a_frame_addr #(
    .ASIZE             (ASIZE          ),
    // .BURST_MAP_ADDR    (BURST_LEN*(2**BURST_MOVE)      ),
    .BURST_MAP_ADDR    (BURST_LEN*256     ),
    .LASIZE            ($clog2(INC_ADDR_STEP_REAL))
)a_frame_addr_inst(
/*  input             */  .clock                    (rd_clk             ),
/*  input             */  .rst_n                    (/*rd_rst_n*/frame_addr_rstn           ),
/*  input             */  .new_base                 (in_port_falign_bc  ),
/*  input[ASIZE-1:0]  */  .baseaddr                 (baseaddr           ),
/*  input[ASIZE_1:0]  */  .line_increate_addr       ( /*INC_ADDR_STEP*8*8*/ INC_ADDR_STEP_REAL),      //[180->256]*8 @ 1920@1080p
/*  input             */  .burst_done               (burst_done         ),
/*  input             */  .tail_done                (tail_done          ),
/*  output[ASIZE-1:0] */  .out_addr                 (curr_address       )
);

axi_inf_write_state_core #(
    .IDSIZE     (IDSIZE    ),
    .ID         (ID        ),
    .LSIZE      (BURST_LEN_SIZE     ),
    .ASIZE      (ASIZE     )
)axi_inf_write_state_core_inst(
/*      input             */  .write_req            (burst_req || tail_req      ),
/*      output            */  .req_resp             (req_resp                   ),
/*      output            */  .req_done             (req_done                   ),
/*      input [LSIZE-1:0] */  .req_len              (req_length                 ),
/*      input [ASIZE-1:0] */  .req_addr             (curr_address               ),
/*      output            */  .pull_data_en         (pull_data_en               ),
/*      input             */  .pend_in              (pend_in                    ),
/*      output            */  .pend_out             (pend_out                   ),
/*      input             */  .fifo_empty           (fifo_empty                 ),
// -- AXI
/*      input             */   .axi_aclk            (axi_aclk                   ),
/*      input             */   .axi_resetn          (/*axi_resetn*/axi_core_rstn                 ),
        //-- addr write signals
/*      output[IDSIZE-1:0]*/   .axi_awid            (axi_awid                   ),
/*      output[ASIZE-1:0] */   .axi_awaddr          (axi_awaddr                 ),
/*      output[LSIZE-1:0] */   .axi_awlen           (axi_awlen                  ),
/*      output[2:0]       */   .axi_awsize          (axi_awsize                 ),
/*      output[1:0]       */   .axi_awburst         (axi_awburst                ),
/*      output[0:0]       */   .axi_awlock          (axi_awlock                 ),
/*      output[3:0]       */   .axi_awcache         (axi_awcache                ),
/*      output[2:0]       */   .axi_awprot          (axi_awprot                 ),
/*      output[3:0]       */   .axi_awqos           (axi_awqos                  ),
/*      output            */   .axi_awvalid         (axi_awvalid                ),
/*      input             */   .axi_awready         (axi_awready                ),
        //-- response signals
/*      output            */   .axi_bready          (axi_bready                 ),
/*      input [IDSIZE-1:0]*/   .axi_bid             (axi_bid                    ),
/*      input [1:0]       */   .axi_bresp           (axi_bresp                  ),
/*      input             */   .axi_bvalid          (axi_bvalid                 ),
        //-- data write signals
/*      output            */   .axi_wlast           (axi_wlast                  ),
/*      input             */   .axi_wvalid          (axi_wvalid                 ),
/*      input             */   .axi_wready          (axi_wready                 )
);

endmodule
