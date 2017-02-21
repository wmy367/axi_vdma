/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERB.0.0 2017/2/18 上午10:06:58
    cut axis and baseaddr ctrl
creaded: 2016/10/27 下午3:46:03
madified:
***********************************************/
`timescale 1ns/1ps
module multiports_vdma_wrap_verb #(
    parameter   ASIZE       = 29,
    parameter   AXI_DSIZE   = 256
)(
    input               axi_aclk                ,
    input               axi_resetn              ,
    //--->> channal  <<-------
    // input [15:0]        ch_vactive           [7:0]  ,
    // input [15:0]        ch_hactive           [7:0]  ,
    input               ch_rev_enable        [7:0]  ,
    input [ASIZE-1:0]   test_wr_addr,
    input [ASIZE-1:0]   test_rd_addr,
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

logic[ASIZE-1:0]   wr_baseaddr          [7:0]  ;
logic[ASIZE-1:0]   rd_baseaddr          [7:0]  ;
/*
    one line burst = 1920*PIX_DSIZE/256 == 180
    Addr Low bit mark 8bit
    line mode 1080p a frame [{180->256}*8*1080]-->[PIX_DSIZE==24]
    once mode 1080p a frame [{180->180}*8*1080]-->[PIX_DSIZE==24]
*/

localparam  A_FRAME_ADDR_STEP_ONCE = 180*8*1080;
localparam  A_FRAME_ADDR_STEP_LINE = 256*8*1080;

// assign wr_baseaddr[0]   = 0;
// assign rd_baseaddr[0]   = 0 + A_FRAME_ADDR_STEP_LINE/2;
assign wr_baseaddr[0] = test_wr_addr;
assign rd_baseaddr[0] = test_rd_addr;
assign wr_baseaddr[1]   = A_FRAME_ADDR_STEP_LINE;
assign rd_baseaddr[1]   = A_FRAME_ADDR_STEP_LINE;
assign wr_baseaddr[2]   = 0;
assign rd_baseaddr[2]   = 0;
assign wr_baseaddr[3]   = 0;
assign rd_baseaddr[3]   = 0;

assign wr_baseaddr[4]   = 0;
assign rd_baseaddr[4]   = 0;
assign wr_baseaddr[5]   = 0;
assign rd_baseaddr[5]   = 0;
assign wr_baseaddr[6]   = 0;
assign rd_baseaddr[6]   = 0;
assign wr_baseaddr[7]   = 0;
assign rd_baseaddr[7]   = 0;

multiports_vdma_verb #(
    .ASIZE                 (ASIZE       ),
    .AXI_DSIZE             (AXI_DSIZE   ),
    //--->> channal 0 <<--------------
    .CH0_STORAGE_MODE      ("ONCE"          ),
    .CH0_EX_SYNC           ("ON"           ),    //external sync
    .CH0_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH0_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //---<< channal 0 >>--------------
    //--->> channal 1 <<--------------
    .CH1_STORAGE_MODE      ("LINE"          ),
    .CH1_EX_SYNC           ("OFF"           ),    //external sync
    .CH1_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH1_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //---<< channal 1 >>--------------
    //--->> channal 2 <<--------------
    .CH2_STORAGE_MODE      ("ONCE"          ),
    .CH2_EX_SYNC           ("OFF"           ),    //external sync
    .CH2_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH2_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //---<< channal 2 >>--------------
    //--->> channal 3 <<--------------
    .CH3_STORAGE_MODE      ("ONCE"          ),
    .CH3_EX_SYNC           ("OFF"           ),    //external sync
    .CH3_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH3_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //---<< channal 3 >>--------------
    //--->> channal 4 <<--------------
    .CH4_STORAGE_MODE      ("ONCE"          ),
    .CH4_EX_SYNC           ("OFF"           ),    //external sync
    .CH4_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH4_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //---<< channal 4 >>--------------
    //--->> channal 5 <<--------------
    .CH5_STORAGE_MODE      ("ONCE"          ),
    .CH5_EX_SYNC           ("OFF"           ),    //external sync
    .CH5_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH5_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //---<< channal 5 >>--------------
    //--->> channal 6 <<--------------
    .CH6_STORAGE_MODE      ("ONCE"          ),
    .CH6_EX_SYNC           ("OFF"           ),    //external sync
    .CH6_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH6_PORT_MODE         ("BOTH"          ),       //READ WRITE BOTH
    //---<< channal 6 >>--------------
    //--->> channal 7 <<--------------
    .CH7_STORAGE_MODE      ("ONCE"          ),
    .CH7_EX_SYNC           ("OFF"           ),    //external sync
    .CH7_VIDEO_FORMAT      ("1080P@60"      ),   //just for read of vdma and internal sync
    .CH7_PORT_MODE         ("BOTH"          )      //READ WRITE BOTH
    //---<< channal 7 >>--------------
)multiports_vdma_inst(
    .axi_aclk              (axi_aclk        ),
    .axi_resetn            (axi_resetn      ),

    // .ch_vactive            (ch_vactive     ),
    // .ch_hactive            (ch_hactive     ),
    .ch_rev_enable         (ch_rev_enable  ),
    .wr_baseaddr           (wr_baseaddr    ),
    .rd_baseaddr           (rd_baseaddr    ),
    .ch0_vin               (ch0_vin         ),   //native input port
    .ch0_vex               (ch0_vex         ),   //native output ex driver
    .ch0_vout              (ch0_vout        ),   //native output

    .ch1_vin               (ch1_vin         ),   //native input port
    .ch1_vex               (ch1_vex         ),   //native output ex driver
    .ch1_vout              (ch1_vout        ),   //native output

    .ch2_vin               (ch2_vin         ),   //native input port
    .ch2_vex               (ch2_vex         ),   //native output ex driver
    .ch2_vout              (ch2_vout        ),   //native output

    .ch3_vin               (ch3_vin         ),   //native input port
    .ch3_vex               (ch3_vex         ),   //native output ex driver
    .ch3_vout              (ch3_vout        ),   //native output

    .ch4_vin               (ch4_vin         ),   //native input port
    .ch4_vex               (ch4_vex         ),   //native output ex driver
    .ch4_vout              (ch4_vout        ),   //native output

    .ch5_vin               (ch5_vin         ),   //native input port
    .ch5_vex               (ch5_vex         ),   //native output ex driver
    .ch5_vout              (ch5_vout        ),   //native output

    .ch6_vin               (ch6_vin         ),   //native input port
    .ch6_vex               (ch6_vex         ),   //native output ex driver
    .ch6_vout              (ch6_vout        ),   //native output

    .ch7_vin               (ch7_vin         ),   //native input port
    .ch7_vex               (ch7_vex         ),   //native output ex driver
    .ch7_vout              (ch7_vout        ),   //native output

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
