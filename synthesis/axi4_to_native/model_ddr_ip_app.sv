/**********************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
descript:
author : Young
Version: VERA.0.0
creaded: 2016/10/12
madified:
***********************************************/
`timescale 1ns / 1ps
module model_ddr_ip_app #(
    parameter ADDR_WIDTH            = 27,
    parameter DATA_WIDTH            = 256
)(
    input                           clock,
    input  [ADDR_WIDTH-1:0]         app_addr,
    input  [2:0]                    app_cmd,
    input                           app_en,
    input  [DATA_WIDTH-1:0]         app_wdf_data,
    input                           app_wdf_end,
    input  [DATA_WIDTH/8-1:0]       app_wdf_mask,
    input                           app_wdf_wren,
    output logic[DATA_WIDTH-1:0]    app_rd_data,
    output logic                    app_rd_data_end,
    output logic                    app_rd_data_valid,
    output logic                    app_rdy,
    output logic                    app_wdf_rdy,
    output logic                    init_calib_complete
);

initial begin
    init_calib_complete = 0;
    #(100us);
    init_calib_complete = 1;
end

logic[ADDR_WIDTH-1:0] mbx   [$];

task automatic ramdon_signal (int  rate,ref logic data);
int     rt;
    forever begin
        rt = $urandom_range(99,0);
        if(rt < rate)begin
            data    = 1;
        end else begin
            data    = 0;
        end
        @(posedge clock);
    end
endtask:ramdon_signal

task automatic ramdon_signal_time (int t,int  rate,ref logic data);
int     rt;
int     cnt;
    cnt = 0;
    while(cnt < t) begin
        rt = $urandom_range(99,0);
        if(rt < rate)begin
            data    = 1;
            cnt ++;
        end else begin
            data    = 0;
        end
        @(posedge clock);
    end
endtask:ramdon_signal_time

task automatic cmd ();
    fork
        ramdon_signal(50,app_rdy);
    join_none
endtask:cmd

task automatic write();
    fork
        ramdon_signal(50,app_wdf_rdy);
    join_none
endtask:write

task automatic sync_wait(ref logic condition);
    forever begin
        @(posedge clock);
        if(condition)
            break;
    end
endtask:sync_wait

initial begin
    cmd();
    write();
    read_cmd();
    // read_resp_simple();
    // read_resp_direct();
end

task automatic read_cmd();
    mbx = {};
    fork
        forever begin
            forever begin
                @(negedge clock);
                if(app_en && app_rdy && app_cmd == 2'b01)
                    break;
            end
            mbx.push_back(app_addr);
            // fork
            //     read_resp(50,mbx);
            // join_none
        end
    join_none
endtask:read_cmd


task automatic read_resp(int rate,ref logic [ADDR_WIDTH-1:0] data_s [$]);
int     rt;
    forever begin
        repeat(10)
            @(posedge clock);
        while(data_s.size()!=0)begin
            rt = $urandom_range(99,0);
            if(rt < rate)begin
                // $display("APP ADDR [%h]",data_s.pop_front);
                app_rd_data_valid = 1;
            end else begin
                app_rd_data_valid = 0;
            end
            @(posedge clock);
        end
        app_rd_data_valid = 0;
    end
endtask:read_resp

task automatic read_resp_simple();
int len;
    fork
         forever begin
            forever begin
                @(posedge clock);
                if(app_en && app_rdy && app_cmd == 2'b01)
                    break;
                if(mbx.size()>0)
                    break;
            end
            repeat(15)
                @(posedge   clock);
            len = mbx.size();
            if(len > 0)begin
                ramdon_signal_time(len,50,app_rd_data_valid);
                // for(int i=0;i<len;i++)
                    // $display("APP DDR [%h]",mbx.pop_front);
            end
            app_rd_data_valid = 0;
        end
    join_none
endtask:read_resp_simple

task automatic read_resp_direct();
int len;
    fork
        forever begin
            @(posedge clock);
            if(app_en && app_rdy && app_cmd == 2'b01)begin
                    app_rd_data_valid   = 1;
            end else begin
                    app_rd_data_valid   = 0;
            end
        end
    join_none
endtask:read_resp_direct


always@(posedge clock)begin
    if(app_en && app_rdy && app_cmd == 2'b01)begin
            app_rd_data_valid   = 1;
    end else begin
            app_rd_data_valid   = 0;
    end
end



endmodule
