/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERB.0.0
    cut axis
creaded: 2016/10/27 下午3:46:03
madified:
***********************************************/
`timescale 1ns/1ps
import SystemPkg::*;
module multiports_vdma_verb #(
    parameter   ASIZE           = 27,
    parameter   AXI_DSIZE       = 256,
    //--->> channal 0 <<--------------
    parameter  CH0_ENABLE           = 1,
    parameter  CH0_STORAGE_MODE     = "ONCE",
    parameter  CH0_EX_SYNC          = "OFF",    //external sync
    parameter  CH0_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH0_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //---<< channal 0 >>--------------
    //--->> channal 1 <<--------------
    parameter  CH1_ENABLE           = 1,
    parameter  CH1_STORAGE_MODE     = "ONCE",
    parameter  CH1_EX_SYNC          = "OFF",    //external sync
    parameter  CH1_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH1_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //---<< channal 1 >>--------------
    //--->> channal 2 <<--------------
    parameter  CH2_ENABLE           = 0,
    parameter  CH2_STORAGE_MODE     = "ONCE",
    parameter  CH2_EX_SYNC          = "OFF",    //external sync
    parameter  CH2_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH2_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //---<< channal 2 >>--------------
    //--->> channal 3 <<--------------
    parameter  CH3_ENABLE           = 0,
    parameter  CH3_STORAGE_MODE     = "ONCE",
    parameter  CH3_EX_SYNC          = "OFF",    //external sync
    parameter  CH3_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH3_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //---<< channal 3 >>--------------
    //--->> channal 4 <<--------------
    parameter  CH4_ENABLE           = 0,
    parameter  CH4_STORAGE_MODE     = "ONCE",
    parameter  CH4_EX_SYNC          = "OFF",    //external sync
    parameter  CH4_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH4_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //---<< channal 4 >>--------------
    //--->> channal 5 <<--------------
    parameter  CH5_ENABLE           = 0,
    parameter  CH5_STORAGE_MODE     = "ONCE",
    parameter  CH5_EX_SYNC          = "OFF",    //external sync
    parameter  CH5_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH5_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //---<< channal 5 >>--------------
    //--->> channal 6 <<--------------
    parameter  CH6_ENABLE           = 0,
    parameter  CH6_STORAGE_MODE     = "ONCE",
    parameter  CH6_EX_SYNC          = "OFF",    //external sync
    parameter  CH6_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH6_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //---<< channal 6 >>--------------
    //--->> channal 7 <<--------------
    parameter  CH7_ENABLE           = 0,
    parameter  CH7_STORAGE_MODE     = "ONCE",
    parameter  CH7_EX_SYNC          = "OFF",    //external sync
    parameter  CH7_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH7_PORT_MODE        = "BOTH"       //READ WRITE BOTH
    //---<< channal 7 >>--------------
)(
    input               axi_aclk                ,
    input               axi_resetn              ,
    //--->> channal  <<-------
    // input [15:0]        ch_vactive           [7:0]  ,
    // input [15:0]        ch_hactive           [7:0]  ,
    input               ch_rev_enable        [7:0]  ,
    input [ASIZE-1:0]   wr_baseaddr          [7:0]  ,
    input [ASIZE-1:0]   rd_baseaddr          [7:0]  ,
    video_native_inf.compact_in     ch0_vin  ,   //native input port
    video_native_inf.compact_in     ch0_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch0_vout ,   //native output
    video_native_inf.compact_in     ch1_vin  ,   //native input port
    video_native_inf.compact_in     ch1_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch1_vout ,   //native output
    video_native_inf.compact_in     ch2_vin  ,   //native input port
    video_native_inf.compact_in     ch2_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch2_vout ,   //native output
    video_native_inf.compact_in     ch3_vin  ,   //native input port
    video_native_inf.compact_in     ch3_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch3_vout ,   //native output
    video_native_inf.compact_in     ch4_vin  ,   //native input port
    video_native_inf.compact_in     ch4_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch4_vout ,   //native output
    video_native_inf.compact_in     ch5_vin  ,   //native input port
    video_native_inf.compact_in     ch5_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch5_vout ,   //native output
    video_native_inf.compact_in     ch6_vin  ,   //native input port
    video_native_inf.compact_in     ch6_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch6_vout ,   //native output
    video_native_inf.compact_in     ch7_vin  ,   //native input port
    video_native_inf.compact_in     ch7_vex  ,   //native output ex driver
    video_native_inf.compact_out    ch7_vout ,   //native output
    //---<< channal  >>-------
    //--->> DDR IP APP <<------
    output logic[ASIZE-1:0]         app_addr,
    output logic[2:0]               app_cmd,
    output logic                    app_en,
    output logic[AXI_DSIZE-1:0]     app_wdf_data,
    output logic                    app_wdf_end,
    output logic[AXI_DSIZE/8-1:0]   app_wdf_mask,
    output logic                    app_wdf_wren,
    input  [AXI_DSIZE-1:0]          app_rd_data,
    input                           app_rd_data_end,
    input                           app_rd_data_valid,
    input                           app_rdy,
    input                           app_wdf_rdy,
    input                           init_calib_complete
);

// cross_clk_sync #(
// 	.LAT       (2      ),
// 	.DSIZE	   (1      )
// )cross_clk_sync_inst(
// /*	input				*/	.clk         (),
// /*	input				*/	.rst_n,
// /*	input [DSIZE-1:0]	*/	.d,
// /*	output[DSIZE-1:0]	*/	.q
// );

localparam  WR_THRESHOLD    = 128,
            RD_THRESHOLD    = 128,
            BURST_LEN_SIZE  = 8;

//----->> port 0 <<------------------
axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_slaver_inf [7:0](axi_aclk,axi_resetn);

generate
if(CH0_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (1       ),
    // .ID                (0       ),
    .STORAGE_MODE      (CH0_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH0_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH0_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH0_PORT_MODE     )   // READ WRITE BOTH
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst0(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [0]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [0]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[0]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[0]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[0]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch0_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch0_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch0_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[0]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst0(
/*  axi_inf.master */   .inf    (axi_slaver_inf[0])
);
end
endgenerate
//-----<< port 0 >>------------------
//----->> port 1 <<------------------
generate
if(CH1_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (1       ),
    .STORAGE_MODE      (CH1_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH1_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH1_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH1_PORT_MODE     )   // READ WRITE BOTH
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst1(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [1]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [1]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[1]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[1]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[1]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch1_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch1_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch1_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[1]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst1(
/*  axi_inf.master */   .inf    (axi_slaver_inf[1])
);
end
endgenerate
//-----<< port 1 >>------------------
//----->> port 2 <<------------------
generate
if(CH2_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (2       ),
    .STORAGE_MODE      (CH2_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH2_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH2_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH2_PORT_MODE     )   // READ WRITE BOTH
)vdma_compact_port_inst2(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [2]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [2]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[2]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[2]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[2]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch2_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch2_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch2_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[2]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst2(
/*  axi_inf.master */   .inf    (axi_slaver_inf[2])
);
end
endgenerate
//-----<< port 2 >>------------------
//----->> port 3 <<------------------
generate
if(CH3_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (3       ),
    .STORAGE_MODE      (CH3_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH3_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH3_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH3_PORT_MODE     )   // READ WRITE BOTH
)vdma_compact_port_inst3(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [3]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [3]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[3]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[3]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[3]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch3_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch3_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch3_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[3]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst3(
/*  axi_inf.master */   .inf    (axi_slaver_inf[3])
);
end
endgenerate
//-----<< port 3 >>------------------
//----->> port 4 <<------------------
generate
if(CH4_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (4       ),
    .STORAGE_MODE      (CH4_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH4_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH4_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH4_PORT_MODE     )   // READ WRITE BOTH
)vdma_compact_port_inst4(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [4]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [4]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[4]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[4]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[4]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch4_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch4_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch4_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[4]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst4(
/*  axi_inf.master */   .inf    (axi_slaver_inf[4])
);
end
endgenerate
//-----<< port 4 >>------------------
//----->> port 5 <<------------------
generate
if(CH5_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (5       ),
    .STORAGE_MODE      (CH5_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH5_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH5_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH5_PORT_MODE     )   // READ WRITE BOTH
)vdma_compact_port_inst5(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [5]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [5]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[5]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[5]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[5]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch5_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch5_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch5_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[5]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst5(
/*  axi_inf.master */   .inf    (axi_slaver_inf[5])
);
end
endgenerate
//-----<< port 5 >>------------------
//----->> port 6 <<------------------
generate
if(CH6_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (6       ),
    .STORAGE_MODE      (CH6_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH6_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH6_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH6_PORT_MODE     )   // READ WRITE BOTH
)vdma_compact_port_inst6(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [6]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [6]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[6]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[5]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[5]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch6_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch6_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch6_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[6]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst6(
/*  axi_inf.master */   .inf    (axi_slaver_inf[6])
);
end
endgenerate
//-----<< port 6 >>------------------
//----->> port 7 <<------------------

generate
if(CH7_ENABLE)begin
vdma_compact_port_verb #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (7       ),
    .STORAGE_MODE      (CH7_STORAGE_MODE  ),   //ONCE LINE
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH7_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH7_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH7_PORT_MODE     )   // READ WRITE BOTH
)vdma_compact_port_inst7(
// /*  input [15:0]   */   .vactive                (   ch_vactive   [7]  ),
// /*  input [15:0]   */   .hactive                (   ch_hactive   [7]  ),
/*  input          */   .rev_enable             (   ch_rev_enable[7]  ),
/*  input          */   .trs_enable             (init_calib_complete),
/*  input [ASIZE-1:0]*/ .wr_baseaddr            (wr_baseaddr[7]       ),
/*  input [ASIZE-1:0]*/ .rd_baseaddr            (rd_baseaddr[7]       ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch7_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch7_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch7_vout  ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_slaver_inf[7]    )
);
end else begin
empty_axi4_master empty_axi4_master_inst7(
/*  axi_inf.master */   .inf    (axi_slaver_inf[7])
);
end
endgenerate
//-----<< port 7 >>------------------
axi_inf #(
    .IDSIZE    (4              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_m00_inf(axi_aclk,axi_resetn);

axi4_interconnect_wrap #(
    .AXI_DSIZE      (AXI_DSIZE  )
)axi4_interconnect_wrap_inst(
/*    input          */  .INTERCONNECT_ACLK    (axi_aclk            ),
// /*    input          */  .INTERCONNECT_ARESETN (axi_resetn && !axi_m00_inf.axi_wevld && !axi_m00_inf.axi_revld),
/*    input          */  .INTERCONNECT_ARESETN (axi_resetn          ),
/*    axi_inf.slaver */  .s00_inf              (axi_slaver_inf[0]         ),
/*    axi_inf.slaver */  .s01_inf              (axi_slaver_inf[1]         ),
/*    axi_inf.slaver */  .s02_inf              (axi_slaver_inf[2]         ),
/*    axi_inf.slaver */  .s03_inf              (axi_slaver_inf[3]         ),
/*    axi_inf.slaver */  .s04_inf              (axi_slaver_inf[4]         ),
/*    axi_inf.slaver */  .s05_inf              (axi_slaver_inf[5]         ),
/*    axi_inf.slaver */  .s06_inf              (axi_slaver_inf[6]         ),
/*    axi_inf.slaver */  .s07_inf              (axi_slaver_inf[7]         ),

/*    axi_inf.master */  .m00_inf              (axi_m00_inf         )
);

// axi4_error_chk #(
//     .DELAY      (24'hFFF_000    )
// )axi4_error_chk_m00(
//     .inf        (axi_m00_inf)
// );

// axi4_error_chk #(
//     .DELAY      (24'hFFF_000    )
// )axi4_error_chk_s00(
//     .inf        (axi_s00_inf)
// );

// assign axi_m00_inf.axi_wevld    = 1'b0;
// assign axi_m00_inf.axi_revld    = 1'b0;
//
// assign axi_slaver_inf[0].axi_wevld    = 1'b0;
// assign axi_slaver_inf[0].axi_revld    = 1'b0;

generate
// if(SIM == "OFF" || SIM == "FALSE")begin:AXI_SIM_SW
if(1)begin:AXI_SIM_SW
//------------------------------------------------------------------------------
axi4_to_native_for_ddr_ip #(
    .ADDR_WIDTH     (ASIZE         ),
    .DATA_WIDTH     (AXI_DSIZE     )
)axi4_to_native_for_ddr_ip_inst(
/*  axi_inf.slaver     */ .axi_inf                   (axi_m00_inf /*axi_s00_inf */         ),
/*  output logic[26:0] */ .app_addr                  (app_addr              ),
/*  output logic[2:0]  */ .app_cmd                   (app_cmd               ),
/*  output logic       */ .app_en                    (app_en                ),
/*  output logic[255:0]*/ .app_wdf_data              (app_wdf_data          ),
/*  output logic       */ .app_wdf_end               (app_wdf_end           ),
/*  output logic[31:0] */ .app_wdf_mask              (app_wdf_mask          ),
/*  output logic       */ .app_wdf_wren              (app_wdf_wren          ),
/*  input  [255:0]     */ .app_rd_data               (app_rd_data           ),
/*  input              */ .app_rd_data_end           (app_rd_data_end       ),
/*  input              */ .app_rd_data_valid         (app_rd_data_valid     ),
/*  input              */ .app_rdy                   (app_rdy               ),
/*  input              */ .app_wdf_rdy               (app_wdf_rdy           ),
/*  input              */ .init_calib_complete       (init_calib_complete   )
);
//==============================================================================
end else begin
//------------------------------------------------------------------------------
axi_slaver #(
    .ASIZE      (ASIZE      ),
    .DSIZE      (AXI_DSIZE  ),
    .LSIZE      (8          ),
    .ID         (0          ),
    .LOCK_ID    ("OFF"      ),
    .ADDR_STEP  (16         ),
    .MUTEX_WR_RD("OFF"      )
)axi_slaver_inst(
/*    axi_inf.slaver */ .inf        (axi_m00_inf    )
);

initial begin
    repeat(100) @(posedge axi_m00_inf.axi_aclk);
    fork
        axi_slaver_inst.slaver_recieve_burst(1000);
        axi_slaver_inst.slaver_transmit_busrt(1000);
    join
end
//==============================================================================
end
endgenerate



endmodule
