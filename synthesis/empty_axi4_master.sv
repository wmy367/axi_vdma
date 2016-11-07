/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/11/4 下午3:41:58
madified:
***********************************************/
`timescale 1ns/1ps
module empty_axi4_master #(
    parameter MODE = "BOTH"     //WRITE READ BOTH
)(
    axi_inf.master inf
);

generate
if(MODE=="BOTH" || MODE=="WRITE")begin
assign     inf.axi_awid     = 0;
assign     inf.axi_awaddr   = 0;
assign     inf.axi_awlen    = 0;
assign     inf.axi_awsize   = 5;
assign     inf.axi_awburst  = 2'b01;
assign     inf.axi_awlock   = 0;
assign     inf.axi_awcache  = 0;
assign     inf.axi_awprot   = 0;
assign     inf.axi_awqos    = 0;
assign     inf.axi_awvalid  = 0;

assign     inf.axi_wdata    = 0;
assign     inf.axi_wstrb    = 0;
assign     inf.axi_wlast    = 0;
assign     inf.axi_wvalid   = 0;

assign     inf.axi_bready   = 1;
end
endgenerate

generate
if(MODE=="BOTH" || MODE=="READ")begin
assign     inf.axi_arid     = 0;
assign     inf.axi_araddr   = 0;
assign     inf.axi_arlen    = 0;
assign     inf.axi_arsize   = 05;
assign     inf.axi_arburst  = 2'b01;
assign     inf.axi_arlock   = 0;
assign     inf.axi_arcache  = 0;
assign     inf.axi_arprot   = 0;
assign     inf.axi_arqos    = 0;
assign     inf.axi_arvalid  = 0;
assign     inf.axi_rready   = 1;
end
endgenerate
endmodule
