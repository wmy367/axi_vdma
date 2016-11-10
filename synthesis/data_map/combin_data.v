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
    parameter OSIZE = 256,
    parameter DATA_TYPE  = "AXIS",    //AXIS NATIVE
    parameter MODE      = "ONCE"   //ONCE LINE
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

//--->> MINI COMBIN <<---
localparam  CNUM =  OSIZE%ISIZE     == 0 ? 1 :
                    OSIZE*3%ISIZE   == 0 ? 3 :
                    OSIZE*5%ISIZE   == 0 ? 5 :
                    OSIZE*7%ISIZE   == 0 ? 7 :
                    OSIZE*9%ISIZE   == 0 ? 9 :
                    OSIZE*11%ISIZE  == 0 ? 11 :
                    OSIZE*13%ISIZE  == 0 ? 13 :
                    OSIZE*15%ISIZE  == 0 ? 15 :
                    OSIZE*17%ISIZE  == 0 ? 17 :
                    OSIZE*19%ISIZE  == 0 ? 19 :
                    OSIZE*21%ISIZE  == 0 ? 21 :
                    OSIZE*23%ISIZE  == 0 ? 23 :
                    OSIZE*25%ISIZE  == 0 ? 25 : 0;
//--->> MINI COMBIN <<---

localparam  OVER_BITS =  (OSIZE%ISIZE)==0? 0 : ISIZE - (OSIZE%ISIZE);
localparam  LAST_BITS =  (OSIZE%ISIZE);
localparam  O_L = OVER_BITS > LAST_BITS ? 1 : 0;


reg [ISIZE-1:0]     map_data [MSIZE-1:0];
reg [ISIZE-1:0]     map_data_ex ;

reg [6:0]           point;
reg [6:0]           loint;

reg                 speciel_line;
reg                 last_line;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  speciel_line    <= 1'b0;
    else begin
        if(O_L)begin
            speciel_line    <= (loint == 7'd1) || loint == (CNUM-1);
        end else begin
            speciel_line    <= loint == (CNUM-1);
        end
    end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  last_line    <= 1'b0;
    else        last_line    <= loint == (CNUM-1);
    // else           last_line    <= ~last_line;  //test


always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  point   <= 7'd0;
    else begin
        if(ialign)begin
            if(iwr_en)
                    point   <= 7'd1;
            else    point   <= 7'd0;
        end else if(ilast && MODE == "LINE")
            if(DATA_TYPE == "NATIVE")
                    point   <= 7'd0;
            else    point   <= iwr_en? 7'd0 : point;
        else if(iwr_en)begin
            if(/**/ (point == (MSIZE-1)) ||
                    (point == (NSIZE-1) && /* loint == (CNUM-1)*/ speciel_line)
            )begin
            // if(point == (MSIZE-1))begin //test
                    point   <= 7'd0;
            end else begin
                    point   <= point + 1'b1;
            end
        end else    point   <= point;
    end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  loint   <= 7'd0;
    else begin
        if(ialign)
            loint   <= 7'd0;
        else if(ilast && MODE=="LINE")begin
            if(DATA_TYPE=="NATIVE")
                    loint <= 7'd0;
            else    loint <= iwr_en? 7'd0 : loint;
        end if(iwr_en)begin
            // if(point == (MSIZE-1) && loint != (CNUM-1) )
            if(point == (MSIZE-1) && !speciel_line )
                if(loint != (CNUM-1))
                        loint <= loint + 1'b1;
                else    loint <= 7'd0;
            // else if (point == (NSIZE-1) && loint == (CNUM-1))
                    // loint <= 7'd0;
            else if (point == (NSIZE-1) && speciel_line)
                if(loint != (CNUM-1))
                        loint <= loint + 1'b1;
                else    loint <= 7'd0;
            else    loint <= loint;
        end else
            loint <= loint;
    end
end



always@(posedge clock/*,negedge rst_n*/)begin:MAP_DATA_BLOCK
integer KK;
    if(~rst_n)begin
        for(KK=0;KK<MSIZE;KK=KK+1)
            map_data[KK]    <= {ISIZE{1'b0}};
    end else begin
        if(iwr_en)
                map_data[point] <= idata;
        else    map_data[point] <= map_data[point];
end end


reg     owr_reg;

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  owr_reg <= 1'b0;
    else begin
        // if(loint != (CNUM-1))begin
        // if((loint != (CNUM-1) && O_L==0) ||
        //    (loint != (1     ) && O_L==1)   )begin
        if(!speciel_line)begin
            if(point == (MSIZE-1) && iwr_en)
                    owr_reg  <= 1'b1;
            else    owr_reg  <= 1'b0;
        end else begin
            if(point == (NSIZE-1) && iwr_en)
                    owr_reg  <= 1'b1;
            else    owr_reg  <= 1'b0;
        end
    end
end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  map_data_ex <= {ISIZE{1'b0}};
    else begin
        if(owr_en )
            if(!speciel_line)
                    map_data_ex <= map_data[MSIZE-1];
            else    map_data_ex <= map_data[NSIZE-1];
        else    map_data_ex <= map_data_ex;
    end

reg     owr_last_reg;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  owr_last_reg    <= 1'b0;
    else begin
        if(ilast && iwr_en && MODE=="LINE")
                owr_last_reg    <= 1'b1;
        else    owr_last_reg    <= 1'b0;
    end


reg [MSIZE-1:0] mask_reg;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   mask_reg   <= {(MSIZE){1'b0}};
    else begin
        if(ialign)
                mask_reg   <= {(MSIZE){1'b0}};
        else if(iwr_en)begin
            // if (point == (MSIZE-1)  || (point==(NSIZE-1) && loint == (CNUM-1)))
            if (point == (MSIZE-1)  || (point==(NSIZE-1) && speciel_line))
                    mask_reg   <= {(MSIZE){1'b0}};
            else    mask_reg   <= {mask_reg[MSIZE-2:0],1'b1};
        end else    mask_reg   <= mask_reg;
    end

// assign omask = mask_reg;
assign omask = {(MSIZE){1'b0}};

reg [OSIZE-1:0]     out_reg;


//--->> OSIZE%ISIZE != 0 <<------------
reg     owr_reg_lat,owr_last_reg_lat;
always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)begin
        owr_reg_lat     <= 1'b0;
        owr_last_reg_lat<= 1'b0;
    end else begin
        owr_reg_lat     <= owr_reg;
        owr_last_reg_lat<= owr_last_reg;
    end
end

reg [6:0]   loint_lat;
always@(posedge clock)
    loint_lat   <= loint;

/*
               LAST_BITS>|    |<OVER_BITS
                        _|  | |
|____|____|____|____|____|____| <- combin idata length
|___________________________|  <- AXI BITS LENGTH
*/

generate
if(EX_EX)begin
//=============================================================================//
always@(*)begin:GEN_OUT_REG_BLOCK_EX
integer KK;
    // out_reg[OSIZE-1-:OVER_BITS*loint]   = map_data_ex[ISIZE-1-:OVER_BITS*loint];
    // out_reg[ISIZE-1:0]   = map_data_ex;
    // for(KK=0;KK<NSIZE;KK=KK+1)
    //     out_reg[OVER_BITS*loint+KK*ISIZE+:ISIZE] = map_data[KK];
    //
    // out_reg[OSIZE-1-:ISIZE]   = map_data_ex << (LAST_BITS*loint);
    // for(KK=0;KK<NSIZE;KK=KK+1)
    //     out_reg[OSIZE-(OVER_BITS*loint)-KK*ISIZE-:ISIZE] = map_data[KK];

    if(O_L)begin
        /*
        out_reg[OSIZE-1-:ISIZE] = map_data_ex << (LAST_BITS*loint_lat);

        out_reg[ISIZE-1:0]  = map_data[MSIZE-1]>>(OSIZE%ISIZE-LAST_BITS*loint);

        for(KK=0;KK<NSIZE;KK=KK+1)
            out_reg[OSIZE-1-(ISIZE-LAST_BITS*loint_lat)-KK*ISIZE-:ISIZE]  = map_data[KK];
        */
        //just for [512 256] -> [24]
        if(loint_lat==0)begin
            for(KK=0;KK<NSIZE;KK=KK+1)
                out_reg[OSIZE-1-KK*ISIZE-:ISIZE]  = map_data[KK];
            out_reg[0+:LAST_BITS]  =   map_data[MSIZE-1][ISIZE-1-:LAST_BITS];
        end else if(loint_lat==1)begin
            out_reg[OSIZE-1-:OVER_BITS] = map_data_ex[ISIZE-1-LAST_BITS-:OVER_BITS];
            for(KK=0;KK<NSIZE-1;KK=KK+1)
                out_reg[OSIZE-1-OVER_BITS-KK*ISIZE-:ISIZE]  = map_data[KK];
            out_reg[0+:OVER_BITS]  =   map_data[NSIZE-1][ISIZE-1-:OVER_BITS];
        end else if(loint_lat==2)begin
            out_reg[OSIZE-1-:LAST_BITS] = map_data_ex[ISIZE-1-OVER_BITS-:LAST_BITS];
            for(KK=0;KK<NSIZE;KK=KK+1)
                out_reg[OSIZE-1-LAST_BITS-KK*ISIZE-:ISIZE]  = map_data[KK];
        end

        // for(KK=0;KK<NSIZE;KK=KK+1)
        //      out_reg[OSIZE-1-KK*ISIZE-:ISIZE] = map_data[KK];
    end else begin
        out_reg[OSIZE-1-:ISIZE] = map_data_ex << (ISIZE-(OVER_BITS*loint_lat));

        out_reg[ISIZE-1:0]  = map_data[MSIZE-1] >> (OVER_BITS*loint);

        for(KK=0;KK<NSIZE;KK=KK+1)
            out_reg[OSIZE-1-(OVER_BITS*loint_lat)-KK*ISIZE-:ISIZE]  = map_data[KK];
    end
end
assign owr_en = owr_reg;
assign olast_en = owr_last_reg;

// assign owr_en = owr_reg_lat;
// assign olast_en = owr_last_reg_lat;
//=============================================================================//
end else begin
//=============================================================================//
always@(*)begin:GEN_OUT_REG_BLOCK
integer KK;
    for(KK=0;KK<NSIZE;KK=KK+1)
         out_reg[OSIZE-1-KK*ISIZE-:ISIZE] = map_data[KK];
end
assign owr_en = owr_reg;
assign olast_en = owr_last_reg;
//=============================================================================//
end
endgenerate
//---<< OSIZE%ISIZE != 0 >>------------


assign odata    = out_reg;
// //--->>test <<--------------
// reg [23:0]  tmp_data    = 0;
//
// always@(posedge clock)begin
//     tmp_data    <= tmp_data + 1;
// end
// //---<<test >>--------------
//
// assign odata = {tmp_data,last_line,point,loint,ilast,ialign,iwr_en,idata}; //test

endmodule
