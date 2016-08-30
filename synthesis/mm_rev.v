/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/10 上午11:24:16
madified:
***********************************************/
`timescale 1ns/1ps
module mm_rev #(
    parameter THRESHOLD  = 200,
    parameter FULL_LEN   = 512,
    parameter ASIZE      = 29,
    parameter BURST_LEN_SIZE = 9,
    parameter IDSIZE     = 4,
    parameter ID         = 0,
    parameter DSIZE      = 24,
    parameter AXI_DSIZE  = 256,
    parameter MODE      = "ONCE",   //ONCE LINE
    parameter DATA_TYPE = "AXIS",    //AXIS NATIVE
    parameter FRAME_SYNC= "OFF",    //OFF ON
    parameter EX_SYNC   = "OFF",     //OFF ON
    parameter VIDEO_FORMAT= "1080P@60",
    parameter INC_ADDR_STEP=1024
)(
    input               clock                   ,
    input               rst_n                   ,
    input [ASIZE-1:0]   baseaddr                ,
    input               enable                  ,
    input [15:0]        vactive                 ,
    input [15:0]        hactive                 ,
    input               in_vsync                ,
    input               in_hsync                ,
    input               in_de                   ,
    output              fifo_almost_empty       ,
    input               pend_in                 ,
    output              pend_out                ,
    //-- AXI
    //-- axi stream ---
    output              aclk                    ,
    output              aclken                  ,
    output              aresetn                 ,
    output[DSIZE-1:0]   axi_tdata               ,
    output              axi_tvalid              ,
    input               axi_tready              ,
    output              axi_tuser               ,
    output              axi_tlast               ,
    //-- axi stream
    input               axi_aclk                ,
    input               axi_resetn              ,
    //-- axi read
    //-- addr read
    output[IDSIZE-1:0]  axi_arid                ,
    output[ASIZE-1:0]   axi_araddr              ,
    output[BURST_LEN_SIZE-1:0]
                        axi_arlen               ,
    output[2:0]         axi_arsize              ,
    output[1:0]         axi_arburst             ,
    output[0:0]         axi_arlock              ,
    output[3:0]         axi_arcache             ,
    output[2:0]         axi_arprot              ,
    output[3:0]         axi_arqos               ,
    output              axi_arvalid             ,
    input               axi_arready             ,
    //-- data read
    output              axi_rready              ,
    input[IDSIZE-1:0]   axi_rid                 ,
    input[AXI_DSIZE-1:0]
                        axi_rdata               ,
    input[1:0]          axi_rresp               ,
    input               axi_rlast               ,
    input               axi_rvalid              ,
    //-- native
    output              out_vsync               ,
    output              out_hsync               ,
    output              out_de                  ,
    output[DSIZE-1:0]   odata
);
localparam LSIZE        = BURST_LEN_SIZE;
localparam BURST_LEN    = THRESHOLD;
//--->> OUT PORT INTERFACE <<----------
wire            out_port_falign     ;
wire            out_port_lalign     ;
wire            out_port_ealign     ;
wire            out_port_rd_en      ;
wire[DSIZE-1:0] out_port_idata      ;
wire            fifo_empty          ;

out_port #(
    .DSIZE        (DSIZE        ),
    .MODE         (MODE         ),        //ONCE LINE
    .DATA_TYPE    (DATA_TYPE    ),         //AXIS NATIVE
    .FRAME_SYNC   (FRAME_SYNC   ),        //OFF ON
    .EX_SYNC      (EX_SYNC      ),         //OFF ON
    .VIDEO_FORMAT (VIDEO_FORMAT )
)out_port_inst(
/*  input              */ .clock         (clock                ),
/*  input              */ .rst_n         (rst_n                ),
/*  input [15:0]       */ .vactive       (vactive              ),//for blank ealign, now is't unused
/*  input [15:0]       */ .hactive       (hactive              ),//unused
/*  input              */ .in_vsync      (in_vsync             ),
/*  input              */ .in_hsync      (in_hsync             ),
/*  input              */ .in_de         (in_de                ),
/*  input              */ .fifo_empty    (fifo_empty           ),
/*  input              */ .enable_inner_sync    (enable        ),
    //-- axi_stream
/*  output             */ .aclk          (aclk                 ),
/*  output             */ .aclken        (aclken               ),
/*  output             */ .aresetn       (aresetn              ),
/*  output[DSIZE-1:0]  */ .axi_tdata     (axi_tdata            ),
/*  output             */ .axi_tvalid    (axi_tvalid           ),
/*  input              */ .axi_tready    (axi_tready           ),
/*  output             */ .axi_tuser     (axi_tuser            ),
/*  output             */ .axi_tlast     (axi_tlast            ),
/*  output             */ .axi_fsync     (axi_fsync            ),
    //-- axi stream
    //-- native
/*  output             */ .out_vsync     (out_vsync            ),
/*  output             */ .out_hsync     (out_hsync            ),
/*  output             */ .out_de        (out_de               ),
/*  output[DSIZE-1:0]  */ .odata         (odata                ),
    //-- native
/*  output             */ .falign        (out_port_falign      ),
/*  output             */ .lalign        (out_port_lalign      ),
/*  output             */ .ealign        (out_port_ealign      ),
/*  input[DSIZE-1:0]   */ .in_data       (out_port_idata       ),
/*  output             */ .rd_en         (out_port_rd_en       )
);

wire out_port_falign_bc;

broaden_and_cross_clk #(
	.PHASE	    ("POSITIVE"  ),  //POSITIVE NEGATIVE
	.LEN		(4           ),
	.LAT		(2           )
)broaden_and_cross_clk_inst(
/*	input			*/    .rclk          (axi_aclk           ),
/*	input			*/    .rd_rst_n      (axi_resetn         ),
/*	input			*/    .wclk          (clock              ),
/*	input			*/    .wr_rst_n      (rst_n              ),
/*	input			*/    .d             (out_port_falign     ),
/*	output			*/    .q             (out_port_falign_bc  )
);

//---<< OUT PORT INTERFACE >>----------

wire[AXI_DSIZE-1:0]     ds_data;
wire                    ds_rd_en;
wire                    ds_wr_last_en;

destruct_data #(
    .ISIZE      (AXI_DSIZE  ),
    .OSIZE      (DSIZE      )
)destruct_data_inst(
/*  input               */  .clock       (clock                     ),
/*  input               */  .rst_n       (rst_n                     ),
/*  input               */  .force_rd    (out_port_lalign           ),   //force read out next data
/*  input               */  .ialign      (out_port_falign           ),
/*  output              */  .ird_en      (ds_rd_en                  ),
/*  input [ISIZE-1:0]   */  .idata       (ds_data                   ),
/*  input               */  .ord_en      (out_port_rd_en            ),
/*  output              */  .olast_en    (                          ),
/*  output[OSIZE-1:0]   */  .odata       (out_port_idata            ),
/*  output              */  .ovalid      (                          ),
/*  output[OSIZE/8-1:0] */  .omask       (                          )
);

wire[9:0]       rd_data_count;
wire[9:0]       wr_data_count;


vdma_stream_fifo stream_fifo_inst (
/*  input               */     .rst               (out_port_falign_bc || !rst_n    ),
/*  input               */     .wr_clk            (axi_aclk                     ),
/*  input               */     .rd_clk            (clock                        ),
/*  input [DSIZE-1:0]   */     .din               (axi_rdata                    ),
/*  input               */     .wr_en             (axi_rvalid                   ),
/*  input               */     .rd_en             (ds_rd_en                     ),
/*  output [DSIZE-1:0]  */     .dout              (ds_data                      ),
/*  output              */     .full              (   ),
/*  output              */     .almost_full       (fifo_almost_full             ),
/*  output              */     .empty             (fifo_empty                   ),
/*  output              */     .almost_empty      (fifo_almost_empty            ),
/*  output[9:0]         */     .rd_data_count     (rd_data_count                ),
/*  output[9:0]         */     .wr_data_count     (wr_data_count                )
);


wire            tail_status;
wire[LSIZE-1:0] tail_len;
wire            burst_req;
wire            tail_req;
wire            req_resp;
wire            req_done;
wire[LSIZE-1:0] req_len;
wire            burst_done ;
wire            tail_done  ;

read_fifo_status_ctrl #(
    .THRESHOLD  (THRESHOLD      ),// EMPTY THRESHOLD
    .BURST_LEN  (BURST_LEN      ),
    .FULL_LEN   (FULL_LEN       ),
    .LSIZE      (LSIZE          )
)read_fifo_status_ctrl_inst(
/*  input                */   .clock            (axi_aclk               ),
/*  input                */   .rst_n            (axi_resetn             ),
/*  input                */   .enable           (enable                 ),
/*  input                */   .fsync            (out_port_falign_bc     ),
/*  input [8:0]          */   .count            (wr_data_count          ),
/*  input                */   .tail_status      (tail_status            ),
/*  input [LSIZE-1:0]    */   .tail_len         (tail_len               ),
/*  output               */   .burst_req        (burst_req              ),
/*  output               */   .tail_req         (tail_req               ),
/*  output               */   .burst_done       (burst_done             ),
/*  output               */   .tail_done        (tail_done              ),
/*  input                */   .resp             (req_resp               ),
/*  input                */   .done             (req_done               ),
/*  output[LSIZE-1:0]    */   .req_len          (req_len                )
);

read_line_len_sum #(
    .NOR_BURST_LEN    (BURST_LEN    ),
    .MODE             (MODE         ),   //ONCE LINE
    .AXI_DSIZE        (AXI_DSIZE    ),
    .DSIZE            (DSIZE        ),
    .LSIZE            (LSIZE        )
)read_line_len_sum_inst(
/*  input             */ .clock                 (axi_aclk           ),
/*  input             */ .rst_n                 (axi_resetn         ),
/*  input [15:0]      */ .vactive               (vactive            ),//calculate line length
/*  input [15:0]      */ .hactive               (hactive            ),//calculate line length
/*  input             */ .fsync                 (tail_req || out_port_falign_bc      ),
/*  input             */ .burst_done            (burst_done         ),
/*  input             */ .tail_done             (tail_done          ),
/*  output            */ .tail_status           (tail_status        ),
/*  output[LSIZE-1:0] */ .tail_len              (tail_len           )
);

wire[ASIZE-1:0]         curr_address;

a_frame_addr #(
    .ASIZE             (ASIZE          ),
    .BURST_MAP_ADDR    (BURST_LEN*32      )
)a_frame_addr_inst(
/*  input             */  .clock                    (axi_aclk           ),
/*  input             */  .rst_n                    (axi_resetn         ),
/*  input             */  .new_base                 (out_port_falign_bc ),
/*  input[ASIZE-1:0]  */  .baseaddr                 (baseaddr           ),
/*  input[ASIZE_1:0]  */  .line_increate_addr       ( INC_ADDR_STEP*8*8 ),
/*  input             */  .burst_done               (burst_done         ),
/*  input             */  .tail_done                (tail_done          ),
/*  output[ASIZE-1:0] */  .out_addr                 (curr_address       )
);

axi_inf_read_state_core #(
    .IDSIZE         (IDSIZE         ),
    .ID             (ID             ),
    .LSIZE          (LSIZE          ),
    .ASIZE          (ASIZE          )
)axi_inf_read_state_core_inst(
/*  input             */.read_req           (burst_req || tail_req      ),
/*  output            */.req_resp           (req_resp                   ),
/*  output            */.req_done           (req_done                   ),
/*  input [LSIZE-1:0] */.req_len            (req_len                    ),
/*  input [ASIZE-1:0] */.req_addr           (curr_address               ),
/*  output            */.push_data_en       (                           ),
/*  input             */.pend_in            (pend_in                    ),
/*  output            */.pend_out           (pend_out                   ),
/*  input             */.axi_aclk           (axi_aclk                   ),
/*  input             */.axi_resetn         (axi_resetn                 ),
    //-- address read signals
/*  output[IDSIZE-1:0]*/.axi_arid           (axi_arid                   ),
/*  output[ASIZE-1:0] */.axi_araddr         (axi_araddr                 ),
/*  output[LSIZE-1:0] */.axi_arlen          (axi_arlen                  ),
/*  output[2:0]       */.axi_arsize         (axi_arsize                 ),
/*  output[1:0]       */.axi_arburst        (axi_arburst                ),
/*  output[0:0]       */.axi_arlock         (axi_arlock                 ),
/*  output[3:0]       */.axi_arcache        (axi_arcache                ),
/*  output[2:0]       */.axi_arprot         (axi_arprot                 ),
/*  output[3:0]       */.axi_arqos          (axi_arqos                  ),
/*  output            */.axi_arvalid        (axi_arvalid                ),
/*  output            */.axi_arready        (axi_arready                ),
    //-- data read signals
/*  output            */.axi_rready         (axi_rready                 ),
/*  input [IDSIZE-1:0]*/.axi_rid            (axi_rid                    ),
// /*  input [DSIZE-1:0] */.axi_rdata          (axi_rdata                  ),
/*  input [1:0]       */.axi_rresp          (axi_rresp                  ),
/*  input             */.axi_rlast          (axi_rlast                  ),
/*  input             */.axi_rvalid         (axi_rvalid                 )
);

endmodule
