/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/10/27 下午3:46:03
madified:
***********************************************/
`timescale 1ns/1ps
module multiports_vdma #(
    parameter   ASIZE           = 27,
    parameter   AXI_DSIZE       = 256,
    //--->> channal 0 <<--------------
    parameter  CH0_ENABLE           = 1,
    parameter  CH0_PIX_DSIZE        = 24,
    parameter  CH0_STORAGE_MODE     = "ONCE",
    parameter  CH0_IN_DATA_TYPE     = "NATIVE",
    parameter  CH0_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH0_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH0_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH0_EX_SYNC          = "OFF",    //external sync
    parameter  CH0_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH0_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH0_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH0_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH0_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH0_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH0_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH0_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH0_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH0_BASE_ADDR_7      = 0,            //1:w---6:R
    //---<< channal 0 >>--------------
    //--->> channal 1 <<--------------
    parameter  CH1_ENABLE           = 1,
    parameter  CH1_PIX_DSIZE        = 24,
    parameter  CH1_STORAGE_MODE     = "ONCE",
    parameter  CH1_IN_DATA_TYPE     = "NATIVE",
    parameter  CH1_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH1_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH1_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH1_EX_SYNC          = "OFF",    //external sync
    parameter  CH1_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH1_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH1_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH1_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH1_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH1_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH1_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH1_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH1_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH1_BASE_ADDR_7      = 0,            //1:w---6:R
    //---<< channal 1 >>--------------
    //--->> channal 2 <<--------------
    parameter  CH2_ENABLE           = 0,
    parameter  CH2_PIX_DSIZE        = 24,
    parameter  CH2_STORAGE_MODE     = "ONCE",
    parameter  CH2_IN_DATA_TYPE     = "NATIVE",
    parameter  CH2_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH2_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH2_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH2_EX_SYNC          = "OFF",    //external sync
    parameter  CH2_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH2_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH2_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH2_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH2_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH2_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH2_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH2_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH2_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH2_BASE_ADDR_7      = 0,            //1:w---6:R
    //---<< channal 2 >>--------------
    //--->> channal 3 <<--------------
    parameter  CH3_ENABLE           = 0,
    parameter  CH3_PIX_DSIZE        = 24,
    parameter  CH3_STORAGE_MODE     = "ONCE",
    parameter  CH3_IN_DATA_TYPE     = "NATIVE",
    parameter  CH3_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH3_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH3_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH3_EX_SYNC          = "OFF",    //external sync
    parameter  CH3_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH3_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH3_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH3_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH3_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH3_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH3_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH3_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH3_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH3_BASE_ADDR_7      = 0,            //1:w---6:R
    //---<< channal 3 >>--------------
    //--->> channal 4 <<--------------
    parameter  CH4_ENABLE           = 0,
    parameter  CH4_PIX_DSIZE        = 24,
    parameter  CH4_STORAGE_MODE     = "ONCE",
    parameter  CH4_IN_DATA_TYPE     = "NATIVE",
    parameter  CH4_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH4_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH4_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH4_EX_SYNC          = "OFF",    //external sync
    parameter  CH4_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH4_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH4_BIND_MASTER      = "CH4"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH4_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH4_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH4_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH4_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH4_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH4_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH4_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH4_BASE_ADDR_7      = 0,            //1:w---6:R
    //---<< channal 4 >>--------------
    //--->> channal 5 <<--------------
    parameter  CH5_ENABLE           = 0,
    parameter  CH5_PIX_DSIZE        = 24,
    parameter  CH5_STORAGE_MODE     = "ONCE",
    parameter  CH5_IN_DATA_TYPE     = "NATIVE",
    parameter  CH5_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH5_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH5_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH5_EX_SYNC          = "OFF",    //external sync
    parameter  CH5_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH5_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH5_BIND_MASTER      = "CH5"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH5_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH5_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH5_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH5_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH5_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH5_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH5_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH5_BASE_ADDR_7      = 0,            //1:w---6:R
    //---<< channal 5 >>--------------
    //--->> channal 6 <<--------------
    parameter  CH6_ENABLE           = 0,
    parameter  CH6_PIX_DSIZE        = 24,
    parameter  CH6_STORAGE_MODE     = "ONCE",
    parameter  CH6_IN_DATA_TYPE     = "NATIVE",
    parameter  CH6_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH6_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH6_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH6_EX_SYNC          = "OFF",    //external sync
    parameter  CH6_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH6_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH6_BIND_MASTER      = "CH6"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH6_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH6_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH6_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH6_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH6_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH6_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH6_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH6_BASE_ADDR_7      = 0,            //1:w---6:R
    //---<< channal 6 >>--------------
    //--->> channal 7 <<--------------
    parameter  CH7_ENABLE           = 0,
    parameter  CH7_PIX_DSIZE        = 24,
    parameter  CH7_STORAGE_MODE     = "ONCE",
    parameter  CH7_IN_DATA_TYPE     = "NATIVE",
    parameter  CH7_OUT_DATA_TYPE    = "NATIVE",
    parameter  CH7_IN_FRAME_SYNC    = "OFF",    //just for axis
    parameter  CH7_OUT_FRAME_SYNC   = "OFF",    //just for axis
    parameter  CH7_EX_SYNC          = "OFF",    //external sync
    parameter  CH7_VIDEO_FORMAT     = "1080P@60",   //just for read of vdma and internal sync
    parameter  CH7_PORT_MODE        = "BOTH",       //READ WRITE BOTH
    //parameter  CH7_BIND_MASTER      = "CH7"         //just effective when MODE=="READ"
    //write read relative address array
    parameter  CH7_BASE_ADDR_0      = 0,            //1:w---0:R
    parameter  CH7_BASE_ADDR_1      = 0,            //1:w---0:R
    parameter  CH7_BASE_ADDR_2      = 0,            //1:w---1:R
    parameter  CH7_BASE_ADDR_3      = 0,            //1:w---2:R
    parameter  CH7_BASE_ADDR_4      = 0,            //1:w---3:R
    parameter  CH7_BASE_ADDR_5      = 0,            //1:w---4:R
    parameter  CH7_BASE_ADDR_6      = 0,            //1:w---5:R
    parameter  CH7_BASE_ADDR_7      = 0             //1:w---6:R
    //---<< channal 7 >>--------------
)(
    input               axi_aclk                ,
    input               axi_resetn              ,
    //--->> channal 0 <<-------
    input [15:0]        ch0_vactive             ,
    input [15:0]        ch0_hactive             ,
    input               ch0_in_fsync            ,
    input               ch0_rev_enable          ,
    video_native_inf.compact_in     ch0_vin         ,   //native input port
    video_native_inf.compact_in     ch0_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch0_vout        ,   //native output
    axi_stream_inf.slaver           ch0_axis_in     ,   // axis in
    axi_stream_inf.master           ch0_axis_out    ,   // axi out
    //---<< channal 0 >>-------
    //--->> channal 1 <<-------
    input [15:0]        ch1_vactive             ,
    input [15:0]        ch1_hactive             ,
    input               ch1_in_fsync            ,
    input               ch1_rev_enable          ,
    video_native_inf.compact_in     ch1_vin         ,   //native input port
    video_native_inf.compact_in     ch1_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch1_vout        ,   //native output
    axi_stream_inf.slaver           ch1_axis_in     ,   // axis in
    axi_stream_inf.master           ch1_axis_out    ,   // axi out
    //---<< channal 1 >>-------
    //--->> channal 2 <<-------
    input [15:0]        ch2_vactive             ,
    input [15:0]        ch2_hactive             ,
    input               ch2_in_fsync            ,
    input               ch2_rev_enable          ,
    video_native_inf.compact_in     ch2_vin         ,   //native input port
    video_native_inf.compact_in     ch2_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch2_vout        ,   //native output
    axi_stream_inf.slaver           ch2_axis_in     ,   // axis in
    axi_stream_inf.master           ch2_axis_out    ,   // axi out
    //---<< channal 2 >>-------
    //--->> channal 3 <<-------
    input [15:0]        ch3_vactive             ,
    input [15:0]        ch3_hactive             ,
    input               ch3_in_fsync            ,
    input               ch3_rev_enable          ,
    video_native_inf.compact_in     ch3_vin         ,   //native input port
    video_native_inf.compact_in     ch3_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch3_vout        ,   //native output
    axi_stream_inf.slaver           ch3_axis_in     ,   // axis in
    axi_stream_inf.master           ch3_axis_out    ,   // axi out
    //---<< channal 3 >>-------
    //--->> channal 4 <<-------
    input [15:0]        ch4_vactive             ,
    input [15:0]        ch4_hactive             ,
    input               ch4_in_fsync            ,
    input               ch4_rev_enable          ,
    video_native_inf.compact_in     ch4_vin         ,   //native input port
    video_native_inf.compact_in     ch4_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch4_vout        ,   //native output
    axi_stream_inf.slaver           ch4_axis_in     ,   // axis in
    axi_stream_inf.master           ch4_axis_out    ,   // axi out
    //---<< channal 4 >>-------
    //--->> channal 5 <<-------
    input [15:0]        ch5_vactive             ,
    input [15:0]        ch5_hactive             ,
    input               ch5_in_fsync            ,
    input               ch5_rev_enable          ,
    video_native_inf.compact_in     ch5_vin         ,   //native input port
    video_native_inf.compact_in     ch5_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch5_vout        ,   //native output
    axi_stream_inf.slaver           ch5_axis_in     ,   // axis in
    axi_stream_inf.master           ch5_axis_out    ,   // axi out
    //---<< channal 5 >>-------
    //--->> channal 6 <<-------
    input [15:0]        ch6_vactive             ,
    input [15:0]        ch6_hactive             ,
    input               ch6_in_fsync            ,
    input               ch6_rev_enable          ,
    video_native_inf.compact_in     ch6_vin         ,   //native input port
    video_native_inf.compact_in     ch6_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch6_vout        ,   //native output
    axi_stream_inf.slaver           ch6_axis_in     ,   // axis in
    axi_stream_inf.master           ch6_axis_out    ,   // axi out
    //---<< channal 6 >>-------
    //--->> channal 7 <<-------
    input [15:0]        ch7_vactive             ,
    input [15:0]        ch7_hactive             ,
    input               ch7_in_fsync            ,
    input               ch7_rev_enable          ,
    video_native_inf.compact_in     ch7_vin         ,   //native input port
    video_native_inf.compact_in     ch7_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch7_vout        ,   //native output
    axi_stream_inf.slaver           ch7_axis_in     ,   // axis in
    axi_stream_inf.master           ch7_axis_out    ,   // axi out
    //---<< channal 7 >>-------
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

localparam  WR_THRESHOLD    = 50,
            RD_THRESHOLD    = 50,
            BURST_LEN_SIZE  = 8;

//----->> port 0 <<------------------
vdma_baseaddr_ctrl_inf ch0_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch0_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch0_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch0_ctrl_ex_ba2  ();

axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s00_inf(axi_aclk,axi_resetn);

generate
if(CH0_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH0_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (1       ),
    // .ID                (0       ),
    .STORAGE_MODE      (CH0_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH0_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH0_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH0_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH0_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH0_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH0_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH0_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH0_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH0_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH0_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH0_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH0_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH0_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH0_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH0_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst0(
/*  input [15:0]   */   .vactive                (   ch0_vactive     ),
/*  input [15:0]   */   .hactive                (   ch0_hactive     ),
/*  input          */   .in_fsync               (   ch0_in_fsync    ),
/*  input          */   .rev_enable             (   ch0_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch0_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch0_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch0_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch0_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch0_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s00_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch0_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch0_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch0_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch0_ctrl_ex_ba2)
);
end
endgenerate
//-----<< port 0 >>------------------
//----->> port 1 <<------------------
vdma_baseaddr_ctrl_inf ch1_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch1_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch1_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch1_ctrl_ex_ba2  ();

axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s01_inf(axi_aclk,axi_resetn);

generate
if(CH1_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH1_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (1       ),
    .STORAGE_MODE      (CH1_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH1_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH1_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH1_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH1_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH1_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH1_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH1_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH1_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH1_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH1_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH1_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH1_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH1_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH1_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH1_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst1(
/*  input [15:0]   */   .vactive                (   ch1_vactive     ),
/*  input [15:0]   */   .hactive                (   ch1_hactive     ),
/*  input          */   .in_fsync               (   ch1_in_fsync    ),
/*  input          */   .rev_enable             (   ch1_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch1_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch1_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch1_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch1_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch1_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s01_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch1_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch1_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch1_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch1_ctrl_ex_ba2)
);
end
endgenerate
//-----<< port 1 >>------------------
//----->> port 2 <<------------------
vdma_baseaddr_ctrl_inf ch2_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch2_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch2_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch2_ctrl_ex_ba2  ();

axi_inf #(
    // .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s02_inf(axi_aclk,axi_resetn);
generate
if(CH2_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH2_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (2       ),
    .STORAGE_MODE      (CH2_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH2_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH2_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH2_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH2_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH2_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH2_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH2_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH2_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH2_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH2_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH2_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH2_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH2_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH2_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH2_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst2(
/*  input [15:0]   */   .vactive                (   ch2_vactive     ),
/*  input [15:0]   */   .hactive                (   ch2_hactive     ),
/*  input          */   .in_fsync               (   ch2_in_fsync    ),
/*  input          */   .rev_enable             (   ch2_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch2_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch2_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch2_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch2_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch2_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s02_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch2_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch2_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch2_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch2_ctrl_ex_ba2)
);
end
endgenerate
//-----<< port 2 >>------------------
//----->> port 3 <<------------------
vdma_baseaddr_ctrl_inf ch3_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch3_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch3_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch3_ctrl_ex_ba2  ();

axi_inf #(
    // .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s03_inf(axi_aclk,axi_resetn);

generate
if(CH3_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH3_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (3       ),
    .STORAGE_MODE      (CH3_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH3_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH3_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH3_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH3_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH3_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH3_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH3_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH3_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH3_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH3_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH3_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH3_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH3_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH3_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH3_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst3(
/*  input [15:0]   */   .vactive                (   ch3_vactive     ),
/*  input [15:0]   */   .hactive                (   ch3_hactive     ),
/*  input          */   .in_fsync               (   ch3_in_fsync    ),
/*  input          */   .rev_enable             (   ch3_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch3_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch3_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch3_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch3_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch3_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s03_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch3_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch3_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch3_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch3_ctrl_ex_ba2)
);
end
endgenerate
//-----<< port 3 >>------------------
//----->> port 4 <<------------------
vdma_baseaddr_ctrl_inf ch4_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch4_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch4_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch4_ctrl_ex_ba2  ();

axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s04_inf(axi_aclk,axi_resetn);

generate
if(CH4_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH4_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (4       ),
    .STORAGE_MODE      (CH4_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH4_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH4_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH4_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH4_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH4_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH4_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH4_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH4_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH4_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH4_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH4_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH4_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH4_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH4_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH4_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst4(
/*  input [15:0]   */   .vactive                (   ch4_vactive     ),
/*  input [15:0]   */   .hactive                (   ch4_hactive     ),
/*  input          */   .in_fsync               (   ch4_in_fsync    ),
/*  input          */   .rev_enable             (   ch4_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch4_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch4_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch4_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch4_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch4_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s04_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch4_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch4_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch4_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch4_ctrl_ex_ba2)
);
end
endgenerate
//-----<< port 4 >>------------------
//----->> port 5 <<------------------
vdma_baseaddr_ctrl_inf ch5_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch5_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch5_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch5_ctrl_ex_ba2  ();

axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s05_inf(axi_aclk,axi_resetn);

generate
if(CH5_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH5_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (5       ),
    .STORAGE_MODE      (CH5_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH5_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH5_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH5_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH5_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH5_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH5_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH5_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH5_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH5_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH5_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH5_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH5_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH5_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH5_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH5_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst5(
/*  input [15:0]   */   .vactive                (   ch5_vactive     ),
/*  input [15:0]   */   .hactive                (   ch5_hactive     ),
/*  input          */   .in_fsync               (   ch5_in_fsync    ),
/*  input          */   .rev_enable             (   ch5_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch5_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch5_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch5_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch5_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch5_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s05_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch5_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch5_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch5_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch5_ctrl_ex_ba2)
);
end
endgenerate
//-----<< port 5 >>------------------
//----->> port 6 <<------------------
vdma_baseaddr_ctrl_inf ch6_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch6_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch6_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch6_ctrl_ex_ba2  ();

axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s06_inf(axi_aclk,axi_resetn);

generate
if(CH6_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH6_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (6       ),
    .STORAGE_MODE      (CH6_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH6_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH6_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH6_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH6_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH6_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH6_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH6_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH6_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH6_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH6_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH6_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH6_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH6_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH6_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH6_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst6(
/*  input [15:0]   */   .vactive                (   ch6_vactive     ),
/*  input [15:0]   */   .hactive                (   ch6_hactive     ),
/*  input          */   .in_fsync               (   ch6_in_fsync    ),
/*  input          */   .rev_enable             (   ch6_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch6_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch6_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch6_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch6_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch6_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s06_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch6_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch6_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch6_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch6_ctrl_ex_ba2)
);
end
endgenerate
//-----<< port 6 >>------------------
//----->> port 7 <<------------------
vdma_baseaddr_ctrl_inf ch7_ex_ba_ctrl   ();
vdma_baseaddr_ctrl_inf ch7_ctrl_ex_ba0  ();
vdma_baseaddr_ctrl_inf ch7_ctrl_ex_ba1  ();
vdma_baseaddr_ctrl_inf ch7_ctrl_ex_ba2  ();

axi_inf #(
    .IDSIZE    (1              ),
    .ASIZE     (ASIZE          ),
    .LSIZE     (BURST_LEN_SIZE  ),
    .DSIZE     (AXI_DSIZE       )
)axi_s07_inf(axi_aclk,axi_resetn);

generate
if(CH7_ENABLE)begin
vdma_compact_port #(
    .WR_THRESHOLD      (WR_THRESHOLD     ),
    .RD_THRESHOLD      (RD_THRESHOLD     ),
    .ASIZE             (ASIZE            ),
    .BURST_LEN_SIZE    (BURST_LEN_SIZE   ),
    .PIX_DSIZE         (CH7_PIX_DSIZE    ),
    .AXI_DSIZE         (AXI_DSIZE        ),
    // .IDSIZE            (3       ),
    // .ID                (7       ),
    .STORAGE_MODE      (CH7_STORAGE_MODE  ),   //ONCE LINE
    .IN_DATA_TYPE      (CH7_IN_DATA_TYPE  ),    //AXIS NATIVE
    .OUT_DATA_TYPE     (CH7_OUT_DATA_TYPE ),
    .IN_FRAME_SYNC     (CH7_IN_FRAME_SYNC ), //OFF ON just for axis
    .OUT_FRAME_SYNC    (CH7_OUT_FRAME_SYNC), //OFF ON just for axis
    //-->> JUST FOR OUT <<------
    .EX_SYNC           (CH7_EX_SYNC       ),     //OFF ON :use ex sync
    .VIDEO_FORMAT      (CH7_VIDEO_FORMAT  ),
    //--<< JUST FOR OUT >>------
    .PORT_MODE         (CH7_PORT_MODE     ),   // READ WRITE BOTH
    //-->> BASEADDRE LIST <<----
    .BASE_ADDR_0       (CH7_BASE_ADDR_0   ),
    .BASE_ADDR_1       (CH7_BASE_ADDR_1   ),
    .BASE_ADDR_2       (CH7_BASE_ADDR_2   ),
    .BASE_ADDR_3       (CH7_BASE_ADDR_3   ),
    .BASE_ADDR_4       (CH7_BASE_ADDR_4   ),
    .BASE_ADDR_5       (CH7_BASE_ADDR_5   ),
    .BASE_ADDR_6       (CH7_BASE_ADDR_6   ),
    .BASE_ADDR_7       (CH7_BASE_ADDR_7   )
    //--<< BASEADDRE LIST >>----
)vdma_compact_port_inst7(
/*  input [15:0]   */   .vactive                (   ch7_vactive     ),
/*  input [15:0]   */   .hactive                (   ch7_hactive     ),
/*  input          */   .in_fsync               (   ch7_in_fsync    ),
/*  input          */   .rev_enable             (   ch7_rev_enable  ),
    //native input port
/*  video_native_inf.compact_in */ .vin         (ch7_vin  ),
    //native output ex driver
/*  video_native_inf.compact_in */ .vex         (ch7_vex   ),
    //native output
/*  video_native_inf.compact_out */.vout        (ch7_vout  ),
    // axis in
/*  axi_stream_inf.slaver  */       .axis_in    (ch7_axis_in),
    // axi out
/*  axi_stream_inf.master  */       .axis_out   (ch7_axis_out ),
    // axi4 master
/*  axi_inf.master*/                .axi4_m     (axi_s07_inf    ),
    // baseaddr ctrl inf
/*  vdma_baseaddr_ctrl_inf.slaver */.ex_ba_ctrl     (ch7_ex_ba_ctrl ),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba0    (ch7_ctrl_ex_ba0),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba1    (ch7_ctrl_ex_ba1),
/*  vdma_baseaddr_ctrl_inf.master */.ctrl_ex_ba2    (ch7_ctrl_ex_ba2)
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
/*    input          */  .INTERCONNECT_ARESETN (axi_resetn          ),

/*    axi_inf.slaver */  .s00_inf              (axi_s00_inf         ),
/*    axi_inf.slaver */  .s01_inf              (axi_s01_inf         ),
/*    axi_inf.slaver */  .s02_inf              (axi_s02_inf         ),
/*    axi_inf.slaver */  .s03_inf              (axi_s03_inf         ),
/*    axi_inf.slaver */  .s04_inf              (axi_s04_inf         ),
/*    axi_inf.slaver */  .s05_inf              (axi_s05_inf         ),
/*    axi_inf.slaver */  .s06_inf              (axi_s06_inf         ),
/*    axi_inf.slaver */  .s07_inf              (axi_s07_inf         ),

/*    axi_inf.master */  .m00_inf              (axi_m00_inf         )
);

axi4_to_native_for_ddr_ip #(
    .ADDR_WIDTH     (ASIZE         ),
    .DATA_WIDTH     (AXI_DSIZE     )
)axi4_to_native_for_ddr_ip_inst(
/*  axi_inf.slaver     */ .axi_inf                   (axi_m00_inf           ),
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

endmodule
