`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 09:38:47
// Design Name: 
// Module Name: AXI_Stream
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
    input clk,
    input rst_n,

// AXI Stream input original data
    input   valid_in,
    input   [DATA_WD-1 : 0] data_in,
    input   [DATA_BYTE_WD-1 : 0] keep_in,
    input   last_in,
    output  ready_in,

// AXI Stream output with header inserted
    output  valid_out,
    output  [DATA_WD-1 : 0] data_out,
    output  [DATA_BYTE_WD-1 : 0] keep_out,
    output  last_out,
    input   ready_out,

// The header to be inserted to AXI Stream input

    input valid_insert,
    input [DATA_WD-1 : 0] data_insert,
    input [DATA_BYTE_WD-1 : 0] keep_insert,
    input [BYTE_CNT_WD-1 : 0] byte_insert_cnt,
    output ready_insert
    
);




wire [DATA_WD-1 : 0]        data_in         ;
wire                        clk             ;
wire                        rst_n           ;
wire                        valid_in        ;
wire [3:0]                  keep_in         ;
wire                        last_in         ;
wire [BYTE_CNT_WD-1 : 0]    byte_insert_cnt ;
                        

reg                         ready_in        ;                
reg                         valid_out       ;                 
reg [DATA_WD-1 : 0]         data_out        ;


          
reg [3:0]                   keep_out        ;
reg                         last_out        ;
reg                         ready_insert    ;


reg [DATA_WD-1 : 0]         data_out_reg  ;
reg [DATA_BYTE_WD-1 : 0]    keep_insert_delay;


reg[7:0] data_regs[DATA_WD-1:0];//数据存储器
reg[2:0] data_cnt;//数据拍数计数器
reg[7:0] data_out_cnt;//输出字节计数器
reg[5:0] data_out_clap_cnt;//输出拍数寄存器
reg[DATA_WD-1:0] data_in_delay;
reg              last_in_delay;
reg              ready_insert_delay;
reg[3:0]              keep_out_cnt   ; //最后一拍有效计数  
reg[2:0] data_out_cnt_1;//数据拍数计数器

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        data_in_delay <=    0;
    end
    else if(ready_in && valid_in) begin
        data_in_delay <= data_in;
    end
    else begin
        data_in_delay <= data_in_delay;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        last_in_delay <= 0;
    end
    else  begin
        last_in_delay <= last_in;
    end
end

//insert信号保持指示
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ready_insert_delay <= 0;
    end
    else if(valid_insert && ready_insert) begin
        ready_insert_delay <= 1'b1;
    end
    else if(valid_out && ready_out)begin
        ready_insert_delay <= ready_insert_delay;
    end
    else if(last_in)begin
         ready_insert_delay <= 1'b0;
    end
end


/*
//输出字节中，表头所占空间
always @(posedge clk or negedge rst_n)begin
    if((!valid_out)&&(!data_out))begin
        data_begin <= 0;
    end
    else if(valid_insert && ready_insert)begin
        data_begin <= data_begin + DATA_BYTE_WD-byte_insert_cnt;
    end
        else begin
            data_begin <= data_begin;
        end
end
*/




//可以接收
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
    begin
        ready_in <= 1'b0;
    end
    else if(valid_in)begin
        ready_in <= 1'b1;
    end
end

//可以发送
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
    begin
        valid_out <=    1'b0;
    end
    else if(ready_out)begin
    valid_out   <=   1'b1;
    end
end

//keep_out
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        keep_out <=    4'b1111;
    end
    else 
        keep_out <=keep_in;//后面修改，需要考虑进位
    
end

//last_in
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        last_out <=    1'b0;
    end
    else if(last_in)begin
        last_out <= 1'b1;//后面修改，需要考虑进位
    end
end

//ready_insert
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        ready_insert <=    1'b0;
    end
    else if(valid_insert)begin
        ready_insert <= 1'b1;
    end
end








//传输拍数计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
begin
    data_cnt <= 3'b0;
end
    if(valid_in && ready_in)begin
        data_cnt <= data_cnt + 3'b1;
    end
    else if(last_in)begin
        data_cnt <= 3'b0;
    end  
    else begin
        data_cnt <= 3'b0;
    end 
end

always @(posedge clk or negedge rst_n)begin
		if(valid_in && ready_in)begin
			case(byte_insert_cnt)
                2'b00:begin  
                        data_regs[4*data_cnt]   <=  data_in[7:0]	;
                        data_regs[4*data_cnt+1] <=  data_in[15:8]	;
                        data_regs[4*data_cnt+2] <=  data_in[23:16]	;
                        data_regs[4*data_cnt+3] <=  data_in[31:24]	;
                end
                2'b10:begin 
                        data_regs[0]            <=       data_insert[7:0];
                        data_regs[1]            <=       data_insert[15:8];
                        data_regs[4*data_cnt+2] <=       data_in[7:0]	;
                        data_regs[4*data_cnt+3] <=       data_in[15:8]	;
                        data_regs[4*data_cnt+4] <=       data_in[23:16]	;
                        data_regs[4*data_cnt+5] <=       data_in[31:24]	;
                end
                2'b01:begin
                        data_regs[0]            <=  data_insert[7:0]	;
                        data_regs[4*data_cnt+1] <=  data_in[7:0]	    ;
                        data_regs[4*data_cnt+2] <=  data_in[15:8]	;
                        data_regs[4*data_cnt+3] <=  data_in[23:16]	;
                        data_regs[4*data_cnt+4] <=  data_in[31:24]	;
                end
                //default:begin
                //    data_regs <=    data_regs;
                //end
        endcase
        end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        keep_insert_delay <= 0;
    end
    else if(keep_insert!=0)begin
        keep_insert_delay <= keep_insert;
    end
        else if(ready_in || ready_insert)begin
            keep_insert_delay <=keep_insert_delay;
        end
        else if(last_in)begin
            keep_insert_delay <=keep_insert;
        end
        else begin
            keep_insert_delay <=keep_insert;
        end
end     

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)begin   
        data_out_cnt <=0;
  end
  if(last_in && ready_in)begin
        case(keep_in)
            4'b1111:begin
                data_out_cnt        = 8'd4+data_cnt*4+byte_insert_cnt;
                data_out_clap_cnt   <= data_out_cnt/4;
                keep_out_cnt        <= data_out_cnt%4;
            end                    
            4'b1110:begin
                data_out_cnt        = 8'd3+data_cnt*4+byte_insert_cnt;
                data_out_clap_cnt   <= data_out_cnt/4;
                keep_out_cnt        <= data_out_cnt%4;
            end
            4'b1100:begin
                data_out_cnt        = 8'd2+data_cnt*4+byte_insert_cnt;
                data_out_clap_cnt   <= data_out_cnt/4;
                keep_out_cnt        <= data_out_cnt%4;
            end
            4'b1000:begin
                data_out_cnt        = 8'd1+data_cnt*4+byte_insert_cnt;
                data_out_clap_cnt   <= data_out_cnt/4;
                keep_out_cnt        <= data_out_cnt%4;
            end
            default:begin
                data_out_cnt <=data_out_cnt;
            end
  endcase
  end

end                                              




//输出
always @(posedge clk or negedge rst_n) begin
 if(!rst_n)begin   
       data_out <= 0;
       data_out_cnt_1 <= 3'b0;
 end
 if(valid_out && ready_out && (data_out_cnt_1<data_out_clap_cnt))begin
    data_out <= {data_regs[data_out_cnt_1*4+3'd3],data_regs[data_out_cnt_1*4+3'd2],data_regs[data_out_cnt_1*4+3'd1],data_regs[data_out_cnt_1*4]};
    data_out_cnt_1 <= data_out_cnt_1 +1;
 end
end
        
			


// Your code here
endmodule











































































































































