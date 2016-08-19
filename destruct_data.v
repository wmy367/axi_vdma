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
// localparam  RSIZE = ISIZE%OSIZE;        //16
// localparam  LNUM  = (RSIZE!=0)? OSIZE/RSIZE : 1;
// localparam  TNUM  = LNUM*MSIZE;

//--->> MINI COMBIN <<---
localparam  CNUM =  ISIZE%OSIZE     == 0 ? 1 :
                    ISIZE*3%OSIZE   == 0 ? 3 :
                    ISIZE*5%OSIZE   == 0 ? 5 :
                    ISIZE*7%OSIZE   == 0 ? 7 :
                    ISIZE*9%OSIZE   == 0 ? 9 :
                    ISIZE*11%OSIZE  == 0 ? 11 :
                    ISIZE*13%OSIZE  == 0 ? 13 :
                    ISIZE*15%OSIZE  == 0 ? 15 :
                    ISIZE*17%OSIZE  == 0 ? 17 :
                    ISIZE*19%OSIZE  == 0 ? 19 :
                    ISIZE*21%OSIZE  == 0 ? 21 :
                    ISIZE*23%OSIZE  == 0 ? 23 :
                    ISIZE*25%OSIZE  == 0 ? 25 : 0;
//--->> MINI COMBIN <<---

reg [6:0]          point;
reg [6:0]          loint;
reg [OSIZE-1:0]    data_reg;
reg [OSIZE-1:0]    ex_data;
// reg [OSIZE-1:0]    bk_data;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  point   <= 7'd0;
    else begin
        if(ialign || force_rd)begin
            point   <= 7'd0;
        end else if(ord_en)begin
            // if(/**/ (point == (MSIZE-1) && ex_flag != 2'b00)/**/ || (point==(NSIZE-1) && ex_flag == 2'b00))
            if(/**/
                (
                    point == (MSIZE-1)
                )
                ||
                (
                    point == (NSIZE-1)
                    &&
                    loint == (CNUM-1)
                )
            )begin
                    point   <= 7'd0;
            end else
                    point   <= point + 1'b1;
        end else    point   <= point;
    end

always@(posedge clock,negedge rst_n)begin
    if(~rst_n)  loint   <= 7'd0;
    else begin
        if(ialign || force_rd)begin
            loint   <= 7'd0;
        end if(ord_en)begin
            if(point == (MSIZE-1) && loint != (CNUM-1) )
                    loint <= loint + 1'b1;
            else if (point == (NSIZE-1) && loint == (CNUM-1))
                    loint <= 7'd0;
            else    loint <= loint;
        end else
            loint <= loint;
    end
end

reg         read_en;

localparam  READ_MMT = EX_EX? (NSIZE-1-2) : (NSIZE-1-1);

always@(posedge clock,negedge rst_n)begin
    if(~rst_n)  read_en <= 1'b0;
    else begin
        if(loint != (CNUM-1))begin
            if(point == (MSIZE-1-2) && ord_en)
                    read_en  <= 1'b1;
            else    read_en  <= 1'b0;
        end else begin
            if(point == READ_MMT && ord_en)
                    read_en  <= 1'b1;
            else    read_en  <= 1'b0;
        end
    end
end

assign ird_en   = read_en;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  ex_data <= {OSIZE{1'b0}};
    else begin
        if(read_en)
                ex_data <= idata[OSIZE-1:0];
        else    ex_data <= ex_data;
    end


//---->> MAP CORE <<-------------------------
/*
               LAST_BITS>|    |<OVER_BITS
                        _|  | |
|____|____|____|____|____|____| <- combin idata length
|___________________________|  <- AXI BITS LENGTH
*/
reg [6:0]   ex_shift;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  ex_shift  <= 7'd0;
    else begin
        if(loint == (CNUM-1))
                ex_shift  <= 7'd0;
        else    ex_shift  <= loint+1'b1;
    end

localparam  OVER_BITS =  (ISIZE%OSIZE)==0? 0 : OSIZE - (ISIZE%OSIZE);
localparam  LAST_BITS =  (ISIZE%OSIZE);
localparam  O_L = OVER_BITS > LAST_BITS ? 1 : 0;
generate
if(EX_EX)begin
always@(posedge clock,negedge rst_n)begin:DATA_MAP_BLOCK
reg     moment_ex;
    if(~rst_n)begin
        data_reg    <= {OSIZE{1'b0}};
        moment_ex   <= 1'b0;
    end else begin
        moment_ex   <= read_en;
        if(O_L==0)begin
            if(moment_ex)
                data_reg    <= (ex_data<<(OVER_BITS*ex_shift)) | (idata[ISIZE-1-:OSIZE]>>(OSIZE-OVER_BITS*ex_shift));
            else
                data_reg    <= idata[ISIZE-1-(OVER_BITS*loint)-(point*OSIZE)-:OSIZE];
        end else begin
            if(moment_ex)
                data_reg    <= (ex_data<<(OSIZE-LAST_BITS*ex_shift)) | (idata[ISIZE-1-:OSIZE]>>(LAST_BITS*ex_shift));
            else
                data_reg    <= idata[ISIZE-1-(OSIZE-LAST_BITS*loint)-(point*OSIZE)-:OSIZE];
        end
    end
end
end else begin
always@(posedge clock,negedge rst_n)begin:DATA_MAP_BLOCK
    if(~rst_n)  data_reg    <= {OSIZE{1'b0}};
    else begin
        data_reg    <= idata[ISIZE-1-OSIZE*point-:OSIZE];
    end
end
end
endgenerate

assign odata = data_reg;

endmodule
