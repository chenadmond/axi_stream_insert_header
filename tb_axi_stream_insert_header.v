


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 12:17:29
// Design Name: 
// Module Name: tb_axi_stream_insert_header
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


module tb_axi_stream_insert_header(

    );
parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);
parameter T = 10;

reg                         clk;
reg                         rst_n;

reg                         valid_in;
reg [DATA_WD-1 : 0]         data_in;
reg [DATA_BYTE_WD-1 : 0]    keep_in;
reg                         last_in;

wire                        ready_in;

wire                        valid_out;
wire [DATA_WD-1 : 0]        data_out;
wire [DATA_BYTE_WD-1 : 0]   keep_out;
wire                        last_out;
reg                         ready_out;

reg                         valid_insert;
reg [DATA_WD-1 : 0]         data_insert;
reg [DATA_BYTE_WD-1 : 0]    keep_insert;
reg [BYTE_CNT_WD-1 : 0]     byte_insert_cnt;
wire                        ready_insert;

initial begin
    clk             <=  1'b1;
    rst_n           <=  1'b0;
    valid_in        <=  1'b0;
    data_in         <=  32'b0;
    keep_in         <=  4'b0;
    last_in         <=  1'b0;
    ready_out       <=  1'b0;
    valid_insert    <=  1'b0;
    data_insert     <=  32'b0;
    keep_insert     <=  4'b0;
    byte_insert_cnt <=  2'b0;
    



    #(T)        rst_n           <=  1'b1;
                  
    #(T)        valid_in        <=  1'b1;
                
              
                valid_insert    <=  1'b1;
    #(T)        data_in         <=  32'b11111110_11000011_11110000_00001100;
                data_insert     <=  32'b11111111_11111111_11110000_11110000;   
                keep_insert     <=  4'b0001;
                byte_insert_cnt <=  2'b01;
                
    #(T)        data_in         <=  32'b00001111_00000000_11111111_11110000;
                ready_out       <=  1'b1;
                keep_insert     <=  4'b0000;  
    #T          data_in         <=  32'b11111110_11000011_11110000_00111100;
    #T          data_in         <=  32'b11111110_11000011_11100011_00111100;
    #T          data_in         <=  32'b11111110_11000011_11100011_00111100;
    #T          data_in         <=  32'b11111110_11000011_11110000_00111100;
                last_in         <=  1'b1;
                keep_in         <=  4'b1110;
    #(T)        
                last_in         <=  1'b0;
                data_in         <=  32'b0;
                valid_in        <=  1'b0;
  
               
                
                   
end


always #(T/2) clk = ~clk;


axi_stream_insert_header u1(
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .keep_in(keep_in),
    .last_in(last_in),
    .ready_in(ready_in),
    .valid_out(valid_out),
    .data_out(data_out),
    .keep_out(keep_out),
    .last_out(last_out),
    .ready_out(ready_out),
    .valid_insert(valid_insert),
    .data_insert(data_insert),
    .keep_insert(keep_insert),
    .byte_insert_cnt(byte_insert_cnt),
    .ready_insert(ready_insert)
);

endmodule
