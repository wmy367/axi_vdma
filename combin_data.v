/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/7/22 下午3:41:32
madified:
***********************************************/
module combin_data #(
    parameter ISIZE = 24,
    parameter OSIZE = 256
)(
    input               clock       ,
    input               rst_n       ,
    input               iwr_en      ,
    input [ISIZE-1:0]   idata       ,
    input               ialign      ,
    input               ilast       ,
    output              owr_en      ,
    output              olast_en    ,
    output[OSIZE-1:0]   odata       ,
    output[OSIZE/8-1:0] omask
);
localparam  NSIZE = OSIZE/ISIZE;
localparam  MSIZE = OSIZE/ISIZE+(OSIZE%ISIZE != 0);
localparam  EX_EX = (OSIZE%ISIZE != 0);

reg [ISIZE-1:0]     map_data [MSIZE-1:0];
reg [ISIZE-1:0]     map_data_ex ;

reg [6:0]           point;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  point   <= 7'd0;
    else begin
        if(ialign)begin
            if(iwr_en)
                    point   <= 7'd1;
            else    point   <= 7'd0;
        end else if(ilast && iwr_en)
                point   <= 7'd0;
        else if(iwr_en)begin
            if(/**/ (point == (MSIZE-1) && ex_flag != 2'b00)/**/ || (point==(NSIZE-1) && ex_flag == 2'b00))
                    point   <= 7'd0;
            else    point   <= point + 1'b1;
        end else    point   <= point;
    end

always@(posedge clock,negedge rst_n)begin:MAP_DATA_BLOCK
integer KK;
    if(~rst_n)begin
        for(KK=0;KK<MSIZE;KK=KK+1)
            map_data[KK]    <= {ISIZE{1'b0}};
    end else begin
        if(iwr_en)
                map_data[point] <= idata;
        else    map_data[point] <= map_data[point];
end end

reg [1:0]      ex_flag;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  ex_flag     <= 2'b00;
    else begin
        if(point == NSIZE && EX_EX && iwr_en)begin
            if(ex_flag == 1'b00)
                    ex_flag <= 3'b001;
            else    ex_flag <= {ex_flag[0:0],1'b0};
        end else    ex_flag <= ex_flag;
    end


reg     owr_reg;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  owr_reg <= 1'b0;
    else begin
        if(EX_EX == 0)begin
            if( /**/(point == (MSIZE-1))/**/ && iwr_en)
                    owr_reg <= 1'b1;
            else    owr_reg < =1'b0;
        end else begin
            if( /**/(point == (NSIZE-1))/**/ && iwr_en && ex_flag==2'b00)  // 16
                    owr_reg <= 1'b1;
            else if((point == (MSIZE-1))/**/ && iwr_en && ex_flag==2'b01)
                    owr_reg <= 1'b1;
            else if((point == (MSIZE-1))/**/ && iwr_en && ex_flag==2'b10)
                    owr_reg <= 1'b1;
            else    owr_reg <= 1'b0;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  map_data_ex <= {ISIZE{1'b0}};
    else begin
        if((point == (MSIZE-1))/**/ && iwr_en && ex_flag !=2'b00)
                map_data_ex <= map_data[MSIZE-1];
        else    map_data_ex <= map_data_ex;
    end

reg     owr_last_reg;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  owr_last_reg    <= 1'b0;
    else begin
        if(ilast && iwr_en)
                owr_last_reg    <= 1'b1;
        else    owr_last_reg    <= 1'b0;
    end

reg [MSIZE-1:0] mask_reg;

always@(posedge clcok,negedge rst_n)
    if(~rst_n)   mask_reg   <= {(MSIZE){1'b0}};
    else begin
        if(ialign)
                mask_reg   <= {(MSIZE){1'b0}};
        else if(iwr_en)begin
            if(/**/ (point == (MSIZE-1) && ex_flag != 2'b00)/**/ || (point==(NSIZE-1) && ex_flag == 2'b00))
                    mask_reg   <= {(MSIZE){1'b0}}
            else    mask_reg   <= {mask_reg[MSIZE-2:0],1'b1};
        end else    mask_reg   <= mask_reg;
    end



reg [OSIZE-1:0]     out_reg;

genvar II;
generate
if(EX_EX)begin
//--->> OSIZE%ISIZE != 0 <<------------
always@(ex_flag)begin:GEN_OUT_REG_BLOCK
integer KK;
    case(ex_flag)
    2'b00:begin
        out_reg[15:0]   = map_data_ex[ISIZE-1-:16];
        for(KK=0;KK<NSIZE;KK=KK+1)
            out_reg[KK*ISIZE+16+:ISIZE] = map_data[KK];
    end
    2'b01:begin
        out_reg[OSIZE-1-:16] = map_data[MSIZE-1][0+:16];
        for(KK=0;KK<NSIZE;KK=KK+1)
            out_reg[KK*ISIZE+:ISIZE] = map_data[KK];
    end
    2'b10:begin
        out_reg[7:0]         = map_data_ex[ISIZE-1-:8];
        out_reg[OSIZE-1-:8]  = map_data[MSIZE-1][0+:8];
        for(KK=0;KK<NSIZE;KK=KK+1)
            out_reg[KK*ISIZE+8+:ISIZE] = map_data[KK];
    end
    default:;
    endcase
end
//---<< OSIZE%ISIZE != 0 >>------------
end else begin
always@(*)begin:GEN_OUT_REG_BLOCK_ON_EX
integer KK;
    for(KK=0;KK<NSIZE;KK=KK+1)
        out_reg[(NSIZE-KK-1)*ISIZE+:ISIZE]    = map_data[KK];
end
end
endgenerate

endmodule
