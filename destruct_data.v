/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/25 上午9:38:18
madified:
***********************************************/
module destruct_data #(
    parameter ISIZE = 256,
    parameter OSIZE = 24
)(
    input               clock       ,
    input               rst_n       ,
    input               force_rd    ,   //force read out next data
    input               ialign      ,
    output              ird_en      ,
    input [ISIZE-1:0]   idata       ,
    input               ord_en      ,
    output              olast_en    ,
    output[OSIZE-1:0]   odata       ,
    output              ovalid      ,
    output[OSIZE/8-1:0] omask
);

localparam  NSIZE = ISIZE/OSIZE;
localparam  MSIZE = ISIZE/OSIZE+(ISIZE%OSIZE != 0);
localparam  EX_EX = (ISIZE%OSIZE != 0);
localparam  RSIZE = ISIZE%OSIZE;        //16
localparam  LNUM  = (RSIZE!=0)? OSIZE/RSIZE : 1;
localparam  TNUM  = LNUM*MSIZE;

reg [6:0]          point;
reg [6:0]          roint;
reg [LNUM-1:0]     loint;
reg [OSIZE-1:0]    data_reg;
reg [OSIZE-1:0]    ex_data;
reg [OSIZE-1:0]    bk_data;


always@(posedge clock,negedge rst_n)
    if(~rst_n)  point   <= 7'd0;
    else begin
        if(ialign || force_rd)
                point   <= 7'd0;
        else if(ord_en)begin
            if(point <(MSIZE -1))
                    point <= point + 1'b1;
            else    point <= 7'd0;
        end else    point <= point;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  loint <= {LNUM{1'b0}};
    else begin
        if(ialign || force_rd)
                loint <= {LNUM{1'b0}};
        else begin
            if(ord_en && point == (MSIZE-1))begin
                if(loint < (LNUM-1))
                        loint <= loint + 1'b1;
                else    loint <= {LNUM{1'b0}};
            end else    loint <= loint;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  roint   <= MSIZE-1;
    else begin
        if(ialign || force_rd)
                roint   <= MSIZE-1;
        else if(ord_en)begin
            if(roint == 0)
                    roint <= MSIZE-1;
            else    roint <= roint - 1'b1;
        end else    roint <= roint;
    end


always@(posedge clock,negedge rst_n)
    if(~rst_n)  read_en     <= 1'b0;
    else begin
        if(ialign)
            read_en     <= 1'b0;
        else if(force_rd)
            read_en     <= 1'b1;
        else begin
            if(ird_en)begin
                if(point == (NSIZE-1) )
                        read_en     <= 1'b1;
                else    read_en     <= 1'b0;
            end else    read_en     <= 1'b0;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  ex_data <= {OSIZE{1'b0}};
    else begin
        if(read_en)
                ex_data <= idata[OSIZE-1:0];
        else    ex_data <= ex_data;
    end


generate
if(EX_EX)begin
always@(posedge clock,negedge rst_n)begin:DATA_MAP_BLOCK
    if(~rst_n)  data_reg    <= {OSIZE{1'b0}};
    else begin
        case(loint)
        0:begin
            if(roint != 0)
                    data_reg    <= idata[roint*OSIZE+RSIZE+:OSIZE];
            else    data_reg    <= {ex_data[RSIZE-1:0],idata[ISIZE-1-:(OSIZE-RSIZE)]};
        end
        1:begin
            if(roint != 0)
                    data_reg    <= idata[ISIZE-1-(OSIZE-RSIZE)-point*OSIZE-:OSIZE];
            else    data_reg    <= {ex_data[(OSIZE-RSIZE)-1:0],idata[ISIZE-1-:(OSIZE-RSIZE)]};
        end
        2:begin
                data_reg    <= idata[roint*OSIZE+:OSIZE];
        end
        default:;
        endcase
    end
end else begin
always@(posedge clock,negedge rst_n)begin:DATA_MAP_BLOCK
    if(~rst_n)  data_reg    <= {OSIZE{1'b0}};
    else begin
        data_reg    <= idata[roint*OSIZE+:OSIZE];
    end
end
endgenerate

endmodule
