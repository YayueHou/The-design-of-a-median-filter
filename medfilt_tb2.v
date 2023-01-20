`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/01 13:14:49
// Design Name: 
// Module Name: medfilt_tb2
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


module medfilt_tb2(

    );
           wire [15:0]medfilt_data_out,medfilt_data_out2;
           reg clk=0,rst_n=1;
           wire medfilt_done_flag;
           reg nxt_data_flag=0;
           reg [63:0]four_pixel1=64'h1111222233334444;
           reg [63:0]four_pixel2=64'h5555888866667777;   
           reg [63:0]four_pixel3=64'h9999AAAABBBBCCCC;   
           wire data_get_flag;
           
      initial begin
          #20 nxt_data_flag<=1;
         // #20 nxt_data_flag<=0;
          end
      
      initial begin
      #170 four_pixel1<=64'h1111222233334444;
      four_pixel2<=64'h1111222233334444;
      four_pixel3<=64'h1111222233334444;
      #340 four_pixel1<=64'h9999AAAABBBBCCCC;
      four_pixel2<=64'h9999AAAABBBBCCCC;
      four_pixel3<=64'h9999AAAABBBBCCCC;
      end
           always@*
           begin
            #10 clk<=~clk;
           end
    median_top uut(
    .clk(clk),
    .rst_n(rst_n),
    .four_pixel1(four_pixel1),
    .four_pixel2(four_pixel2),  
    .four_pixel3(four_pixel3),  
    .nxt_data_flag(nxt_data_flag),
    .medfilt_data_out(medfilt_data_out),
    .medfilt_data_out2(medfilt_data_out2),
    .medfilt_done_flag(medfilt_done_flag),
    .data_get_flag(data_get_flag)
        );
        
        
        
endmodule
