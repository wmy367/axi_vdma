/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
    contrl multi vmda baseaddr interface
author : Young
Version: VERA.0.0
creaded: 2016/8/26 下午2:42:27
madified:
***********************************************/
interface vdma_baseaddr_ctrl_inf (
);
logic					clk        	;
logic					rst_n      	;
logic					vs       	;
logic[2:0]              point       ;


modport master(
input       clk,
input       rst_n,
input       vs,
output      point
);

modport slaver(
output      clk,
output      rst_n,
output      vs,
input      point
);
endinterface:vdma_baseaddr_ctrl_inf
