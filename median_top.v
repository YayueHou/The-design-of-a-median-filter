`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/29 10:52:57
// Design Name: 
// Module Name: median_top
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


module median_top(
input clk,
input rst_n,
input [63:0]four_pixel1,
input [63:0]four_pixel2,  
input [63:0]four_pixel3,  
input nxt_data_flag,
output [15:0]medfilt_data_out,
output [15:0]medfilt_data_out2,
output medfilt_done_flag,
output data_get_flag
    );
    wire win_data_flag;
    wire [15:0]data0;
    wire [15:0]data1;
    wire [15:0]data2;
    wire [15:0]data3;
    wire [15:0]data4;
    wire [15:0]data5;
    wire [15:0]data6;
    wire [15:0]data7;
    wire [15:0]data8; 
   
     
    windows windows1(
                   .clk(clk),
                   .rst_n(rst_n),
                   .nxt_data_flag(nxt_data_flag),     
                   .data1(four_pixel1),
                   .data2(four_pixel2),
                   .data3(four_pixel3),
                   .medfilt_done_flag(medfilt_done_flag),
                   .out1(data0),
                   .out2(data1),
                   .out3(data2),
                   .out4(data3),
                   .out5(data4),
                   .out6(data5),
                   .out7(data6),
                   .out8(data7),
                   .out9(data8),
                   .data_get_flag(data_get_flag),
                   .win_gen_flag(win_data_flag)
                   );
    
       medianfilter medianfilter1(
                        .clk(clk),
                        .rst_n(rst_n),
                        .win_gen_flag(win_data_flag),         
                        .medfilt_done_flag(medfilt_done_flag),   
                        .data_in0(data0),          
                        .data_in1(data1),
                        .data_in2(data2),
                        .data_in3(data3),
                        .data_in4(data4),
                        .data_in5(data5),
                        .data_in6(data6),
                        .data_in7(data7),
                        .data_in8(data8),
                        .medfilt_data_out(medfilt_data_out),
                        .medfilt_data_out2(medfilt_data_out2)
                         ); 
    
    
endmodule


