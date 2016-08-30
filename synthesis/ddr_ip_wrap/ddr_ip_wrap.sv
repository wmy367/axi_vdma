/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
    add write read lock,use interface
author : Young
Version: VERA.0.0
creaded: 2016/8/29 下午2:15:01
madified:
***********************************************/
`timescale 1ns/1ps
module ddr_ip_wrap #(
    parameter BANK_WIDTH            = 3,
    parameter CK_WIDTH              = 1,
    parameter CS_WIDTH              = 1,
    parameter nCS_PER_RANK          = 1,
    parameter CKE_WIDTH             = 1,
    parameter DM_WIDTH              = 4,
    parameter DQ_WIDTH              = 32,
    parameter DQS_WIDTH             = 4,
    parameter ROW_WIDTH             = 14,
    parameter ODT_WIDTH             = 1,
    parameter C_S_AXI_ID_WIDTH      = 4,
    parameter C_S_AXI_ADDR_WIDTH    = 29,
    parameter C_S_AXI_DATA_WIDTH    = 256,
    parameter SIMULATION            = "FALSE"
)(
    // Inouts
   inout [DQ_WIDTH-1:0]                         ddr3_dq,
   inout [DQS_WIDTH-1:0]                        ddr3_dqs_n,
   inout [DQS_WIDTH-1:0]                        ddr3_dqs_p,
   // Outputs
   output [ROW_WIDTH-1:0]                       ddr3_addr,
   output [BANK_WIDTH-1:0]                      ddr3_ba,
   output                                       ddr3_ras_n,
   output                                       ddr3_cas_n,
   output                                       ddr3_we_n,
   output                                       ddr3_reset_n,
   output [CK_WIDTH-1:0]                        ddr3_ck_p,
   output [CK_WIDTH-1:0]                        ddr3_ck_n,
   output [CKE_WIDTH-1:0]                       ddr3_cke,
   output [(CS_WIDTH*nCS_PER_RANK)-1:0]         ddr3_cs_n,
   output [DM_WIDTH-1:0]                        ddr3_dm,
   output [ODT_WIDTH-1:0]                       ddr3_odt,
   // Single-ended system clock
   input                                        sys_clk_i,
   input                                        sys_rst,
   // Single-ended iodelayctrl clk (reference clock)
   input                                        clk_ref_i,
   // user interface signals
   output                                       ui_clk,
   output                                       ui_clk_sync_rst,
   output                                       mmcm_locked,

   output                                       init_calib_complete,
   axi_inf.slaver                               axi4_inf

);

logic                app_sr_active;
logic                app_ref_ack;
logic                app_zq_ack;

logic               pend_wr;
logic               pend_rd;

logic               ddr_axi_awready;
logic               ddr_axi_arready;

DDR3_IP_CORE
u_ip_top(
     .ddr3_dq              (ddr3_dq             ),
     .ddr3_dqs_n           (ddr3_dqs_n          ),
     .ddr3_dqs_p           (ddr3_dqs_p          ),
     .ddr3_addr            (ddr3_addr           ),
     .ddr3_ba              (ddr3_ba             ),
     .ddr3_ras_n           (ddr3_ras_n          ),
     .ddr3_cas_n           (ddr3_cas_n          ),
     .ddr3_we_n            (ddr3_we_n           ),
     .ddr3_reset_n         (ddr3_reset_n        ),
     .ddr3_ck_p            (ddr3_ck_p           ),
     .ddr3_ck_n            (ddr3_ck_n           ),
     .ddr3_cke             (ddr3_cke            ),
     .ddr3_cs_n            (ddr3_cs_n           ),
     .ddr3_dm              (ddr3_dm             ),
     .ddr3_odt             (ddr3_odt            ),

     .init_calib_complete (init_calib_complete),
//     .tg_compare_error    (tg_compare_error),
     .sys_rst             (sys_rst),
       // Inputs
       // Single-ended system clock
/*     input            */                          .sys_clk_i          (sys_clk_i      ),
       // Single-ended iodelayctrl clk (reference clock)
/*     input            */                          .clk_ref_i          (clk_ref_i      ),
       // user interface signals
/*     output           */                          .ui_clk             (ui_clk          ),
/*     output           */                          .ui_clk_sync_rst    (ui_clk_sync_rst ),
/*     output           */                          .mmcm_locked        (mmcm_locked     ),
/*     input            */                          .aresetn            (axi4_inf.axi_resetn      ),
/*     input            */                          .app_sr_req         (1'b0  ),
/*     input            */                          .app_ref_req        (1'b0  ),
/*     input            */                          .app_zq_req         (1'b0  ),
/*     output           */                          .app_sr_active      (app_sr_active   ),
/*     output           */                          .app_ref_ack        (app_ref_ack     ),
/*     output           */                          .app_zq_ack         (app_zq_ack      ),
       // Slave Interface Write Address Ports
/*     input  [C_S_AXI_ID_WIDTH-1:0]     */         .s_axi_awid         (axi4_inf.axi_awid      ),
/*     input  [C_S_AXI_ADDR_WIDTH-1:0]   */         .s_axi_awaddr       (axi4_inf.axi_awaddr    ),
/*     input  [7:0]                      */         .s_axi_awlen        (axi4_inf.axi_awlen     ),
/*     input  [2:0]                      */         .s_axi_awsize       (axi4_inf.axi_awsize    ),
/*     input  [1:0]                      */         .s_axi_awburst      (axi4_inf.axi_awburst   ),
/*     input  [0:0]                      */         .s_axi_awlock       (axi4_inf.axi_awlock    ),
/*     input  [3:0]                      */         .s_axi_awcache      (axi4_inf.axi_awcache   ),
/*     input  [2:0]                      */         .s_axi_awprot       (axi4_inf.axi_awprot    ),
/*     input  [3:0]                      */         .s_axi_awqos        (axi4_inf.axi_awqos     ),
/*     input                             */         .s_axi_awvalid      (axi4_inf.axi_awvalid && !pend_wr   ),
/*     output                            */         .s_axi_awready      (ddr_axi_awready   ),
       // Slave Interface Write Data Ports
/*     input  [C_S_AXI_DATA_WIDTH-1:0]    */        .s_axi_wdata        (axi4_inf.axi_wdata     ),
/*     input  [(C_S_AXI_DATA_WIDTH/8)-1:0]*/        .s_axi_wstrb        (axi4_inf.axi_wstrb     ),
/*     input                              */        .s_axi_wlast        (axi4_inf.axi_wlast     ),
/*     input                              */        .s_axi_wvalid       (axi4_inf.axi_wvalid    ),
/*     output                             */        .s_axi_wready       (axi4_inf.axi_wready    ),
       // Slave Interface Write Response Ports
/*     input                              */        .s_axi_bready       (axi4_inf.axi_bready    ),
/*     output [C_S_AXI_ID_WIDTH-1:0]      */        .s_axi_bid          (axi4_inf.axi_bid       ),
/*     output [1:0]                       */        .s_axi_bresp        (axi4_inf.axi_bresp     ),
/*     output                             */        .s_axi_bvalid       (axi4_inf.axi_bvalid    ),
       // Slave Interface Read Address Ports
/*     input  [C_S_AXI_ID_WIDTH-1:0]      */        .s_axi_arid         (axi4_inf.axi_arid      ),
/*     input  [C_S_AXI_ADDR_WIDTH-1:0]    */        .s_axi_araddr       (axi4_inf.axi_araddr    ),
/*     input  [7:0]                       */        .s_axi_arlen        (axi4_inf.axi_arlen     ),
/*     input  [2:0]                       */        .s_axi_arsize       (axi4_inf.axi_arsize    ),
/*     input  [1:0]                       */        .s_axi_arburst      (axi4_inf.axi_arburst   ),
/*     input  [0:0]                       */        .s_axi_arlock       (axi4_inf.axi_arlock    ),
/*     input  [3:0]                       */        .s_axi_arcache      (axi4_inf.axi_arcache   ),
/*     input  [2:0]                       */        .s_axi_arprot       (axi4_inf.axi_arprot    ),
/*     input  [3:0]                       */        .s_axi_arqos        (axi4_inf.axi_arqos     ),
/*     input                              */        .s_axi_arvalid      (axi4_inf.axi_arvalid && !pend_rd  ),
/*     output                             */        .s_axi_arready      (ddr_axi_arready   ),
       // Slave Interface Read Data Ports
/*     input                              */        .s_axi_rready       (axi4_inf.axi_rready    ),
/*     output [C_S_AXI_ID_WIDTH-1:0]      */        .s_axi_rid          (axi4_inf.axi_rid       ),
/*     output [C_S_AXI_DATA_WIDTH-1:0]    */        .s_axi_rdata        (axi4_inf.axi_rdata     ),
/*     output [1:0]                       */        .s_axi_rresp        (axi4_inf.axi_rresp     ),
/*     output                             */        .s_axi_rlast        (axi4_inf.axi_rlast     ),
/*     output                             */        .s_axi_rvalid       (axi4_inf.axi_rvalid    )
);

write_read_lock write_read_lock_inst(
/*    input        */   .clock            (axi4_inf.axi_aclk                ),
/*    input        */   .rst_n            (axi4_inf.axi_resetn              ),
/*    input        */   .wr_req           (axi4_inf.axi_awvalid && axi4_inf.axi_awready ),
/*    input        */   .rd_req           (axi4_inf.axi_arvalid && axi4_inf.axi_arready ),
/*    input        */   .wr_done          (axi4_inf.axi_bvalid              ),
/*    input        */   .rd_done          (axi4_inf.axi_rlast && axi4_inf.axi_rvalid ),
/*    output logic */   .pend_wr          (pend_wr                          ),
/*    output logic */   .pend_rd          (pend_rd                          )
);

assign axi4_inf.axi_awready = !pend_wr && ddr_axi_awready;
assign axi4_inf.axi_arready = !pend_rd && ddr_axi_arready;

endmodule
