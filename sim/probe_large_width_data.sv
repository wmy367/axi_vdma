/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/10/24 上午11:24:59
madified:
***********************************************/
`timescale 1ns/1ps
module probe_large_width_data #(
    parameter DSIZE = 256,
    parameter PSIZE = 24
)(
    input               clock,
    input               rst,
    input [DSIZE-1:0]   data,
    input               valid,
    input               sync,
    input               sync_negedge,
    input               sync_posedge
);


logic [DSIZE-1:0]       data_tap [2:0];
logic                   vld_tap [2:0];

always@(posedge clock,posedge rst)begin : TAP_BLOCK
int KK;
    if(rst)begin
        for(KK=0;KK<3;KK++)begin
            data_tap[KK]    <= {DSIZE{1'b0}};
            vld_tap[KK]     <= 1'b0;
        end
    end else begin
        // data_tap[0]     <= valid? data : data_tap[0];
        data_tap[0]     <= data;
        vld_tap[0]      <= valid;
        for(KK=1;KK<3;KK++)begin
            data_tap[KK]    <= data_tap[KK-1];
            vld_tap[KK]     <= vld_tap[KK-1];
        end
end end


int cnt;

always@(posedge clock,posedge rst)begin
    if(rst)     cnt <= 0;
    else begin
        if(vld_tap[1])
            if(cnt < 2)
                    cnt <= cnt + 1;
            else    cnt <= 0;
        else    cnt <= cnt;
end end

always@(sync,negedge sync_negedge,posedge sync_posedge)begin :RST_BLOCK
int KK;
    cnt = 0;
    for(KK=0;KK<3;KK++)begin
        data_tap[KK]    = {DSIZE{1'b0}};
        vld_tap[KK]     = 1'b0;
    end
end

localparam EXSIZE = DSIZE/PSIZE+(DSIZE%PSIZE != 0);
localparam  MSIZE = DSIZE%PSIZE;
logic [EXSIZE*PSIZE-1:0]    tmp_data;

always@(*)begin
    if(DSIZE==256)begin
        case(cnt)
        0:  tmp_data    = {data_tap[1],data_tap[0][DSIZE-1-:8]};
        1:  tmp_data    = {data_tap[1][DSIZE-1-8:0],data_tap[0][DSIZE-1-:16]};
        2:  tmp_data    = {data_tap[1][DSIZE-1-16:0],data_tap[0][DSIZE-1-:24]};
        default:;
        endcase
    end else if(DSIZE==512)begin
        case(cnt)
        0:  tmp_data    = {data_tap[1],data_tap[0][DSIZE-1-:16]};
        1:  tmp_data    = {data_tap[1][DSIZE-1-16:0],data_tap[0][DSIZE-1-:8]};
        2:  tmp_data    = {data_tap[1][DSIZE-1-8:0],data_tap[0][DSIZE-1-:24]};
        default:;
        endcase
    end
end

//--->> destruct data array test <<-------------
logic[PSIZE-1:0] ds_data_array [0:EXSIZE-1];
assign ds_data_array    = {>>{tmp_data}};
//---<< destruct data array test >>-------------

endmodule
