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
module mm_tras #(
    parameter THRESHOLD  = 200,
    parameter ASIZE      = 29,
    parameter BURST_LEN_SIZE = 9,
    parameter DSIZE     = 24,
    parameter AXI_DSIZE = 256,
    parameter IDSIZE    = 4,
    parameter ID        = 0,
    parameter MODE      = "ONCE",   //ONCE LINE
    parameter DATA_TYPE = "AXIS",    //AXIS NATIVE
    parameter FRAME_SYNC= "OFF",    //OFF ON
    parameter INC_ADDR_STEP = 1024
)(
    input               clock                   ,
    input               rst_n                   ,
    input [ASIZE-1:0]   baseaddr                ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               vsync                   ,
    input               hsync                   ,
    input               de                      ,
    input [DSIZE-1:0]   idata                   ,
    input               fsync                   ,
    output              fifo_almost_full        ,
    input               pend_in                 ,
    output              pend_out                ,
    //-- AXI
    //-- axi stream ---
    input               aclk                    ,
    input               aclken                  ,
    input               aresetn                 ,
    input [DSIZE-1:0]   axi_tdata               ,
    input               axi_tvalid              ,
    output              axi_tready              ,
    input               axi_tuser               ,
    input               axi_tlast               ,
    //-- axi stream
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

assign axi_wstrb    = {(AXI_DSIZE/8){1'b1}};

wire        rd_clk;
wire        rd_rst_n;
wire        wr_clk;
wire        wr_rst_n;

assign rd_clk   = axi_aclk;
assign rd_rst_n = axi_resetn;

assign wr_clk   = DATA_TYPE=="AXIS"? aclk : clock;
assign wr_rst_n = DATA_TYPE=="AXIS"? aresetn  : rst_n;

//--->> IN PORT INTERFACE <<----------
wire            in_port_falign     ;
wire            in_port_lalign     ;
wire            in_port_ealign     ;
wire            in_port_odata_vld  ;
wire[DSIZE-1:0] in_port_odata      ;
// wire            fifo_almost_full   ;

in_port #(
    .DSIZE     (DSIZE     ),
    .MODE      (MODE      ),   //ONCE LINE
    .DATA_TYPE (DATA_TYPE ),    //AXIS NATIVE
    .FRAME_SYNC(FRAME_SYNC)    //OFF ON
)in_port_inst(
/*  input              */ .clock                   (clock                   ),
/*  input              */ .rst_n                   (rst_n                   ),
/*  input [15:0]       */ .vactive                 (vactive                 ),//for blank ealign, now is't unused
/*  input [15:0]       */ .hactive                 (hactive                 ),//unused
/*  input              */ .vsync                   (vsync                   ),
/*  input              */ .hsync                   (hsync                   ),
/*  input              */ .de                      (de                      ),
/*  input [DSIZE-1:0]  */ .idata                   (idata                   ),
/*  input              */ .fsync                   (fsync                   ),
/*  input              */ .fifo_almost_full        (fifo_almost_full        ),
    //-- axi stream ---
/*  input              */ .aclk                    (aclk                    ),
/*  input              */ .aclken                  (aclken                  ),
/*  input              */ .aresetn                 (aresetn                 ),
/*  input [DSIZE-1:0]  */ .axi_tdata               (axi_tdata               ),
/*  input              */ .axi_tvalid              (axi_tvalid              ),
/*  output             */ .axi_tready              (axi_tready              ),
/*  input              */ .axi_tuser               (axi_tuser               ),
/*  input              */ .axi_tlast               (axi_tlast               ),
    //-- axi stream
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

wire[AXI_DSIZE-1:0]     cb_data;
wire            cb_wr_en;
wire            cb_wr_last_en;

combin_data #(
    .ISIZE      (DSIZE        ),
    .OSIZE      (AXI_DSIZE    )
)combin_data_inst(
/*    input               */ .clock       (wr_clk    ),
/*    input               */ .rst_n       (wr_rst_n  ),
/*    input               */ .iwr_en      (in_port_odata_vld  ),
/*    input [ISIZE-1:0]   */ .idata       (in_port_odata      ),
/*    input               */ .ialign      (in_port_falign     ),
/*    input               */ .ilast       (in_port_lalign     ),
/*    output              */ .owr_en      (cb_wr_en         ),
/*    output              */ .olast_en    (cb_wr_last_en    ),
/*    output[OSIZE-1:0]   */ .odata       (cb_data          ),
/*    output[OSIZE/8-1:0] */ .omask       (  )
);

wire[9:0]       rd_data_count;
wire[9:0]       wr_data_count;

wire            fifo_rst;
wire            fifo_empty;

assign  fifo_rst    = FRAME_SYNC=="ON"? in_port_falign : 1'b0;

vdma_stream_fifo stream_fifo_inst (
/*  input               */     .rst               (!wr_rst_n ||  fifo_rst       ),
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

assign axi_wvalid   = pull_data_en;

wire    burst_req    ;
wire    tail_req     ;
wire    req_resp     ;
wire    req_done     ;
wire[BURST_LEN_SIZE-1:0]    req_length;

wire[BURST_LEN_SIZE-1:0]    tail_len;
wire    burst_done,tail_done;

fifo_status_ctrl #(
    .THRESHOLD      (THRESHOLD  ),
    .LSIZE          (BURST_LEN_SIZE)
)fifo_status_ctrl_inst(
/*  input             */    .clock             (rd_clk              ),
/*  input             */    .rst_n             (rd_rst_n            ),
/*  input             */    .fifo_empty        (fifo_empty          ),
/*  input [9:0]       */    .count             (rd_data_count       ),
/*  input             */    .tail              (in_port_lalign_bc   ),      // not frame tail
/*  input [LSIZE-1:0] */    .tail_len          (tail_len            ),
/*  output            */    .burst_req         (burst_req           ),
/*  output            */    .tail_req          (tail_req            ),      //line tail
/*  output            */    .burst_done        (burst_done          ),
/*  output            */    .tail_done         (tail_done           ),
/*  input             */    .resp              (req_resp            ),
/*  input             */    .done              (req_done            ),
/*  output[LSIZE-1:0] */    .req_len           (req_length          )
);

write_line_len_sum #(
    .NOR_BURST_LEN      (THRESHOLD  ),
    .MODE               (MODE       ),   //ONCE LINE
    .AXI_DSIZE          (AXI_DSIZE  ),
    .DSIZE              (DSIZE      ),
    .LSIZE              (BURST_LEN_SIZE)
)write_line_len_sum_inst(
/*  input             */  .clock                (rd_clk              ),
/*  input             */  .rst_n                (rd_rst_n            ),
/*  input [15:0]      */  .vactive              (vactive             ), //calculate line length
/*  input [15:0]      */  .hactive              (hactive             ), //calculate line length
/*  input             */  .fsync                (in_port_falign_bc || tail_req ),
/*  input             */  .burst_done           (burst_done          ),
/*  input             */  .tail_done            (tail_done           ),
/*  output            */  .tail_status          (                    ),
/*  output[LSIZE-1:0] */  .tail_len             (tail_len            )
);

wire[ASIZE-1:0]         curr_address;

a_frame_addr #(
    .ASIZE             (ASIZE          ),
    .BURST_MAP_ADDR    (THRESHOLD*8*8  )
)a_frame_addr_inst(
/*  input             */  .clock                    (rd_clk             ),
/*  input             */  .rst_n                    (rd_rst_n           ),
/*  input             */  .new_base                 (in_port_falign_bc  ),
/*  input[ASIZE-1:0]  */  .baseaddr                 (baseaddr           ),
/*  input[ASIZE_1:0]  */  .line_increate_addr       ( INC_ADDR_STEP*8*8 ),
/*  input             */  .burst_req                (burst_req          ),
/*  input             */  .tail_req                 (tail_req           ),
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
// -- AXI
/*      input             */   .axi_aclk            (axi_aclk                   ),
/*      input             */   .axi_resetn          (axi_resetn                 ),
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