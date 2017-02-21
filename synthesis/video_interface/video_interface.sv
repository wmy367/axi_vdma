/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/8/26 上午10:40:51
madified:
***********************************************/
interface video_native_inf #(
    parameter DSIZE = 24
)(
    input bit   pclk ,
    input bit   prst_n
);

logic vsync;
logic hsync;
logic de;
logic blank;
logic field;
logic[DSIZE-1:0]    data;
logic[15:0]        vactive;
logic[15:0]        hactive;

modport compact_in (
    input       pclk,
    input       prst_n,
    input       vsync,
    input       hsync,
    input       de,
    input       data,
    input       vactive,
    input       hactive
);

modport compact_out (
    input       pclk,
    input       prst_n,
    output      vsync,
    output      hsync,
    output      de,
    output      data,
    output      vactive,
    output      hactive
);

endinterface
