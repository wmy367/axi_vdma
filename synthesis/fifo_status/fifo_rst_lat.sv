/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2017/2/16 下午3:54:10
madified:
***********************************************/
`timescale 1ns/1ps
module fifo_rst_lat (
    input           clock,
    input           rst_n,
    input           fifo_rst,
    output logic    invalid_moment
);

logic           fifo_rst_lat;
logic [8:0]     cnt;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cnt <= '0;
    else begin
        if(fifo_rst)
                cnt <= 9'd0;
        else begin
            if(cnt < 9'd256)
                    cnt <= cnt + 1'b1;
            else    cnt <= cnt;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  fifo_rst_lat    <= 1'b0;
    else        fifo_rst_lat    <= cnt == 9'd256;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  invalid_moment  <= 1'b1;
    else begin
        if(fifo_rst)
                invalid_moment  <= 1'b1;
        else if(fifo_rst_lat)
                invalid_moment  <= 1'b0;
        else    invalid_moment  <= invalid_moment;
    end

endmodule
