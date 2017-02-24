/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version:
creaded: 2016/9/22 下午2:19:02
madified:
***********************************************/
interface data_inf #(
    parameter DSIZE = 8
)(

);

logic                   valid   ;
logic                   ready   ;
logic[DSIZE-1:0]        data    ;

modport master (
output  valid,
output  data,
input   ready
);

modport slaver (
input   valid,
input   data,
output  ready
);

endinterface
