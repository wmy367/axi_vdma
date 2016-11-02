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
module multiports_vdma_wrap #(
    parameter   ASIZE       = 29,
    parameter   AXI_DSIZE   = 256
)(
    input                           axi_aclk                ,
    input                           axi_resetn              ,
    //--->> channal 0 <<-------
    input [15:0]                    ch0_vactive             ,
    input [15:0]                    ch0_hactive             ,
    input                           ch0_in_fsync            ,
    input                           ch0_rev_enable          ,
    video_native_inf.compact_in     ch0_vin         ,   //native input port
    video_native_inf.compact_in     ch0_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch0_vout        ,   //native output
    axi_stream_inf.slaver           ch0_axis_in     ,   // axis in
    axi_stream_inf.master           ch0_axis_out    ,   // axi out
    //---<< channal 0 >>-------
    //--->> channal 1 <<-------
    input [15:0]                    ch1_vactive             ,
    input [15:0]                    ch1_hactive             ,
    input                           ch1_in_fsync            ,
    input                           ch1_rev_enable          ,
    video_native_inf.compact_in     ch1_vin         ,   //native input port
    video_native_inf.compact_in     ch1_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch1_vout        ,   //native output
    axi_stream_inf.slaver           ch1_axis_in     ,   // axis in
    axi_stream_inf.master           ch1_axis_out    ,   // axi out
    //---<< channal 1 >>-------
    //--->> channal 2 <<-------
    input [15:0]                    ch2_vactive             ,
    input [15:0]                    ch2_hactive             ,
    input                           ch2_in_fsync            ,
    input                           ch2_rev_enable          ,
    video_native_inf.compact_in     ch2_vin         ,   //native input port
    video_native_inf.compact_in     ch2_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch2_vout        ,   //native output
    axi_stream_inf.slaver           ch2_axis_in     ,   // axis in
    axi_stream_inf.master           ch2_axis_out    ,   // axi out
    //---<< channal 2 >>-------
    //--->> channal 3 <<-------
    input [15:0]                    ch3_vactive             ,
    input [15:0]                    ch3_hactive             ,
    input                           ch3_in_fsync            ,
    input                           ch3_rev_enable          ,
    video_native_inf.compact_in     ch3_vin         ,   //native input port
    video_native_inf.compact_in     ch3_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch3_vout        ,   //native output
    axi_stream_inf.slaver           ch3_axis_in     ,   // axis in
    axi_stream_inf.master           ch3_axis_out    ,   // axi out
    //---<< channal 3 >>-------
    //--->> channal 4 <<-------
    input [15:0]                    ch4_vactive             ,
    input [15:0]                    ch4_hactive             ,
    input                           ch4_in_fsync            ,
    input                           ch4_rev_enable          ,
    video_native_inf.compact_in     ch4_vin         ,   //native input port
    video_native_inf.compact_in     ch4_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch4_vout        ,   //native output
    axi_stream_inf.slaver           ch4_axis_in     ,   // axis in
    axi_stream_inf.master           ch4_axis_out    ,   // axi out
    //---<< channal 4 >>-------
    //--->> channal 5 <<-------
    input [15:0]                    ch5_vactive             ,
    input [15:0]                    ch5_hactive             ,
    input                           ch5_in_fsync            ,
    input                           ch5_rev_enable          ,
    video_native_inf.compact_in     ch5_vin         ,   //native input port
    video_native_inf.compact_in     ch5_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch5_vout        ,   //native output
    axi_stream_inf.slaver           ch5_axis_in     ,   // axis in
    axi_stream_inf.master           ch5_axis_out    ,   // axi out
    //---<< channal 5 >>-------
    //--->> channal 6 <<-------
    input [15:0]                    ch6_vactive             ,
    input [15:0]                    ch6_hactive             ,
    input                           ch6_in_fsync            ,
    input                           ch6_rev_enable          ,
    video_native_inf.compact_in     ch6_vin         ,   //native input port
    video_native_inf.compact_in     ch6_vex         ,   //native output ex driver
    video_native_inf.compact_out    ch6_vout        ,   //native output
    axi_stream_inf.slaver           ch6_axis_in     ,   // axis in
    axi_stream_inf.master           ch6_axis_out    ,   // axi out
    //---<< channal 6 >>-------
    //--->> channal 7 <<-------
    input [15:0]                    ch7_vactive             ,
    input [15:0]                    ch7_hactive             ,
    input                           ch7_in_fsync            ,
    input                           ch7_rev_enable          ,
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

multiports_vdma #(
    .ASIZE                 (ASIZE       ),
    .AXI_DSIZE             (AXI_DSIZE   ),
    .CH0_ENABLE            (1      ),
    .CH1_ENABLE            (1      ),
    .CH2_ENABLE            (0      ),
    .CH3_ENABLE            (0      ),
    .CH4_ENABLE            (0      ),
    .CH5_ENABLE            (0      ),
    .CH6_ENABLE            (0      ),
    .CH7_ENABLE            (0      ),
    //--->> channal 0 <<--------------
    .CH0_PIX_DSIZE         (24              ),
    .CH0_STORAGE_MODE      ("LINE"          ),
    .CH0_IN_DATA_TYPE      ("NATIVE"        ),
    .CH0_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH0_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH0_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH0_EX_SYNC           ("OFF"           ),    //external sync
    .CH0_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH0_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array               //1080P 24bit :: 1920*1080*PIX_DSIZE/AXI_DSIZE*8
    .CH0_BASE_ADDR_0       (0               ),            //1:w---0:R
    .CH0_BASE_ADDR_1       (0               ),            //1:w---0:R
    .CH0_BASE_ADDR_2       (0               ),            //1:w---1:R
    .CH0_BASE_ADDR_3       (0               ),            //1:w---2:R
    .CH0_BASE_ADDR_4       (0               ),            //1:w---3:R
    .CH0_BASE_ADDR_5       (0               ),            //1:w---4:R
    .CH0_BASE_ADDR_6       (0               ),            //1:w---5:R
    .CH0_BASE_ADDR_7       (0               ),            //1:w---6:R
    //---<< channal 0 >>--------------
    //--->> channal 1 <<--------------
    .CH1_PIX_DSIZE         (24              ),
    .CH1_STORAGE_MODE      ("LINE"          ),
    .CH1_IN_DATA_TYPE      ("NATIVE"        ),
    .CH1_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH1_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH1_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH1_EX_SYNC           ("OFF"           ),    //external sync
    .CH1_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH1_PORT_MODE         ("WRITE"          ),       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array
    .CH1_BASE_ADDR_0       (0               ),            //1:w---0:R
    .CH1_BASE_ADDR_1       (0               ),            //1:w---0:R
    .CH1_BASE_ADDR_2       (0               ),            //1:w---1:R
    .CH1_BASE_ADDR_3       (0               ),            //1:w---2:R
    .CH1_BASE_ADDR_4       (0               ),            //1:w---3:R
    .CH1_BASE_ADDR_5       (0               ),            //1:w---4:R
    .CH1_BASE_ADDR_6       (0               ),            //1:w---5:R
    .CH1_BASE_ADDR_7       (0               ),            //1:w---6:R
    //---<< channal 1 >>--------------
    //--->> channal 2 <<--------------
    .CH2_PIX_DSIZE         (24              ),
    .CH2_STORAGE_MODE      ("ONCE"          ),
    .CH2_IN_DATA_TYPE      ("NATIVE"        ),
    .CH2_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH2_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH2_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH2_EX_SYNC           ("OFF"           ),    //external sync
    .CH2_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH2_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array
    .CH2_BASE_ADDR_0       (0               ),            //1:w---0:R
    .CH2_BASE_ADDR_1       (0               ),            //1:w---0:R
    .CH2_BASE_ADDR_2       (0               ),            //1:w---1:R
    .CH2_BASE_ADDR_3       (0               ),            //1:w---2:R
    .CH2_BASE_ADDR_4       (0               ),            //1:w---3:R
    .CH2_BASE_ADDR_5       (0               ),            //1:w---4:R
    .CH2_BASE_ADDR_6       (0               ),            //1:w---5:R
    .CH2_BASE_ADDR_7       (0               ),            //1:w---6:R
    //---<< channal 2 >>--------------
    //--->> channal 3 <<--------------
    .CH3_PIX_DSIZE         (24              ),
    .CH3_STORAGE_MODE      ("ONCE"          ),
    .CH3_IN_DATA_TYPE      ("NATIVE"        ),
    .CH3_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH3_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH3_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH3_EX_SYNC           ("OFF"           ),    //external sync
    .CH3_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH3_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //parameter  CH0_BIND_MASTER      = "CH0"         //just effective when MODE=="READ"
    //write read relative address array
    .CH3_BASE_ADDR_0       (0               ),            //1:w---0:R
    .CH3_BASE_ADDR_1       (0               ),            //1:w---0:R
    .CH3_BASE_ADDR_2       (0               ),            //1:w---1:R
    .CH3_BASE_ADDR_3       (0               ),            //1:w---2:R
    .CH3_BASE_ADDR_4       (0               ),            //1:w---3:R
    .CH3_BASE_ADDR_5       (0               ),            //1:w---4:R
    .CH3_BASE_ADDR_6       (0               ),            //1:w---5:R
    .CH3_BASE_ADDR_7       (0               ),            //1:w---6:R
    //---<< channal 3 >>--------------
    //--->> channal 4 <<--------------
    .CH4_PIX_DSIZE         (24              ),
    .CH4_STORAGE_MODE      ("ONCE"          ),
    .CH4_IN_DATA_TYPE      ("NATIVE"        ),
    .CH4_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH4_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH4_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH4_EX_SYNC           ("OFF"           ),    //external sync
    .CH4_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH4_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //parameter  CH4_BIND_MASTER      = "CH4"         //just effective when MODE=="READ"
    //write read relative address array
    .CH4_BASE_ADDR_0       (0               ),            //1:w---0:R
    .CH4_BASE_ADDR_1       (0               ),            //1:w---0:R
    .CH4_BASE_ADDR_2       (0               ),            //1:w---1:R
    .CH4_BASE_ADDR_3       (0               ),            //1:w---2:R
    .CH4_BASE_ADDR_4       (0               ),            //1:w---3:R
    .CH4_BASE_ADDR_5       (0               ),            //1:w---4:R
    .CH4_BASE_ADDR_6       (0               ),            //1:w---5:R
    .CH4_BASE_ADDR_7       (0               ),            //1:w---6:R
    //---<< channal 4 >>--------------
    //--->> channal 5 <<--------------
    .CH5_PIX_DSIZE         (24              ),
    .CH5_STORAGE_MODE      ("ONCE"          ),
    .CH5_IN_DATA_TYPE      ("NATIVE"        ),
    .CH5_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH5_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH5_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH5_EX_SYNC           ("OFF"           ),    //external sync
    .CH5_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH5_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //parameter  CH5_BIND_MASTER      = "CH5"         //just effective when MODE=="READ"
    //write read relative address array
    .CH5_BASE_ADDR_0        (0              ),            //1:w---0:R
    .CH5_BASE_ADDR_1        (0              ),            //1:w---0:R
    .CH5_BASE_ADDR_2        (0              ),            //1:w---1:R
    .CH5_BASE_ADDR_3        (0              ),            //1:w---2:R
    .CH5_BASE_ADDR_4        (0              ),            //1:w---3:R
    .CH5_BASE_ADDR_5        (0              ),            //1:w---4:R
    .CH5_BASE_ADDR_6        (0              ),            //1:w---5:R
    .CH5_BASE_ADDR_7        (0              ),            //1:w---6:R
    //---<< channal 5 >>--------------
    //--->> channal 6 <<--------------
    .CH6_PIX_DSIZE         (24              ),
    .CH6_STORAGE_MODE      ("ONCE"          ),
    .CH6_IN_DATA_TYPE      ("NATIVE"        ),
    .CH6_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH6_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH6_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH6_EX_SYNC           ("OFF"           ),    //external sync
    .CH6_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH6_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //parameter  CH6_BIND_MASTER      = "CH6"         //just effective when MODE=="READ"
    //write read relative address array
    .CH6_BASE_ADDR_0       (0               ),            //1:w---0:R
    .CH6_BASE_ADDR_1       (0               ),            //1:w---0:R
    .CH6_BASE_ADDR_2       (0               ),            //1:w---1:R
    .CH6_BASE_ADDR_3       (0               ),            //1:w---2:R
    .CH6_BASE_ADDR_4       (0               ),            //1:w---3:R
    .CH6_BASE_ADDR_5       (0               ),            //1:w---4:R
    .CH6_BASE_ADDR_6       (0               ),            //1:w---5:R
    .CH6_BASE_ADDR_7       (0               ),            //1:w---6:R
    //---<< channal 6 >>--------------
    //--->> channal 7 <<--------------
    .CH7_PIX_DSIZE         (24              ),
    .CH7_STORAGE_MODE      ("ONCE"          ),
    .CH7_IN_DATA_TYPE      ("NATIVE"        ),
    .CH7_OUT_DATA_TYPE     ("NATIVE"        ),
    .CH7_IN_FRAME_SYNC     ("OFF"           ),    //just for axis
    .CH7_OUT_FRAME_SYNC    ("OFF"           ),    //just for axis
    .CH7_EX_SYNC           ("OFF"           ),    //external sync
    .CH7_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH7_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //parameter  CH7_BIND_MASTER      = "CH7"         //just effective when MODE=="READ"
    //write read relative address array
    .CH7_BASE_ADDR_0       (0               ),            //1:w---0:R
    .CH7_BASE_ADDR_1       (0               ),            //1:w---0:R
    .CH7_BASE_ADDR_2       (0               ),            //1:w---1:R
    .CH7_BASE_ADDR_3       (0               ),            //1:w---2:R
    .CH7_BASE_ADDR_4       (0               ),            //1:w---3:R
    .CH7_BASE_ADDR_5       (0               ),            //1:w---4:R
    .CH7_BASE_ADDR_6       (0               ),            //1:w---5:R
    .CH7_BASE_ADDR_7       (0               )             //1:w---6:R
    //---<< channal 7 >>--------------
)multiports_vdma_inst(
    .axi_aclk              (axi_aclk        ),
    .axi_resetn            (axi_resetn      ),

    .ch0_vactive           (ch0_vactive     ),
    .ch0_hactive           (ch0_hactive     ),
    .ch0_in_fsync          (ch0_in_fsync    ),
    .ch0_rev_enable        (ch0_rev_enable  ),
    .ch0_vin               (ch0_vin         ),   //native input port
    .ch0_vex               (ch0_vex         ),   //native output ex driver
    .ch0_vout              (ch0_vout        ),   //native output
    .ch0_axis_in           (ch0_axis_in     ),   // axis in
    .ch0_axis_out          (ch0_axis_out    ),   // axi out


    .ch1_vactive           (ch1_vactive     ),
    .ch1_hactive           (ch1_hactive     ),
    .ch1_in_fsync          (ch1_in_fsync    ),
    .ch1_rev_enable        (ch1_rev_enable  ),
    .ch1_vin               (ch1_vin         ),   //native input port
    .ch1_vex               (ch1_vex         ),   //native output ex driver
    .ch1_vout              (ch1_vout        ),   //native output
    .ch1_axis_in           (ch1_axis_in     ),   // axis in
    .ch1_axis_out          (ch1_axis_out    ),   // axi out

    .ch2_vactive           (ch2_vactive     ),
    .ch2_hactive           (ch2_hactive     ),
    .ch2_in_fsync          (ch2_in_fsync    ),
    .ch2_rev_enable        (ch2_rev_enable  ),
    .ch2_vin               (ch2_vin         ),   //native input port
    .ch2_vex               (ch2_vex         ),   //native output ex driver
    .ch2_vout              (ch2_vout        ),   //native output
    .ch2_axis_in           (ch2_axis_in     ),   // axis in
    .ch2_axis_out          (ch2_axis_out    ),   // axi out


    .ch3_vactive           (ch3_vactive     ),
    .ch3_hactive           (ch3_hactive     ),
    .ch3_in_fsync          (ch3_in_fsync    ),
    .ch3_rev_enable        (ch3_rev_enable  ),
    .ch3_vin               (ch3_vin         ),   //native input port
    .ch3_vex               (ch3_vex         ),   //native output ex driver
    .ch3_vout              (ch3_vout        ),   //native output
    .ch3_axis_in           (ch3_axis_in     ),   // axis in
    .ch3_axis_out          (ch3_axis_out    ),   // axi out

    .ch4_vactive           (ch4_vactive     ),
    .ch4_hactive           (ch4_hactive     ),
    .ch4_in_fsync          (ch4_in_fsync    ),
    .ch4_rev_enable        (ch4_rev_enable  ),
    .ch4_vin               (ch4_vin         ),   //native input port
    .ch4_vex               (ch4_vex         ),   //native output ex driver
    .ch4_vout              (ch4_vout        ),   //native output
    .ch4_axis_in           (ch4_axis_in     ),   // axis in
    .ch4_axis_out          (ch4_axis_out    ),   // axi out


    .ch5_vactive           (ch5_vactive     ),
    .ch5_hactive           (ch5_hactive     ),
    .ch5_in_fsync          (ch5_in_fsync    ),
    .ch5_rev_enable        (ch5_rev_enable  ),
    .ch5_vin               (ch5_vin         ),   //native input port
    .ch5_vex               (ch5_vex         ),   //native output ex driver
    .ch5_vout              (ch5_vout        ),   //native output
    .ch5_axis_in           (ch5_axis_in     ),   // axis in
    .ch5_axis_out          (ch5_axis_out    ),   // axi out

    .ch6_vactive           (ch6_vactive     ),
    .ch6_hactive           (ch6_hactive     ),
    .ch6_in_fsync          (ch6_in_fsync    ),
    .ch6_rev_enable        (ch6_rev_enable  ),
    .ch6_vin               (ch6_vin         ),   //native input port
    .ch6_vex               (ch6_vex         ),   //native output ex driver
    .ch6_vout              (ch6_vout        ),   //native output
    .ch6_axis_in           (ch6_axis_in     ),   // axis in
    .ch6_axis_out          (ch6_axis_out    ),   // axi out


    .ch7_vactive           (ch7_vactive     ),
    .ch7_hactive           (ch7_hactive     ),
    .ch7_in_fsync          (ch7_in_fsync    ),
    .ch7_rev_enable        (ch7_rev_enable  ),
    .ch7_vin               (ch7_vin         ),   //native input port
    .ch7_vex               (ch7_vex         ),   //native output ex driver
    .ch7_vout              (ch7_vout        ),   //native output
    .ch7_axis_in           (ch7_axis_in     ),   // axis in
    .ch7_axis_out          (ch7_axis_out    ),   // axi out


    .app_addr              (app_addr             ),
    .app_cmd               (app_cmd              ),
    .app_en                (app_en               ),
    .app_wdf_data          (app_wdf_data         ),
    .app_wdf_end           (app_wdf_end          ),
    .app_wdf_mask          (app_wdf_mask         ),
    .app_wdf_wren          (app_wdf_wren         ),
    .app_rd_data           (app_rd_data          ),
    .app_rd_data_end       (app_rd_data_end      ),
    .app_rd_data_valid     (app_rd_data_valid    ),
    .app_rdy               (app_rdy              ),
    .app_wdf_rdy           (app_wdf_rdy          ),
    .init_calib_complete   (init_calib_complete  )
);

endmodule
