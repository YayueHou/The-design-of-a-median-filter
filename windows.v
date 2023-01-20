`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/29 09:30:43
// Design Name: 
// Module Name: windows
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


module windows(
 input clk,
 input rst_n,
 input nxt_data_flag,// from apb and memory    

 input [63:0]data1,
 input [63:0]data2,
 input [63:0]data3,

 input medfilt_done_flag,//from medfilt

 output reg[15:0]out1,
 output reg[15:0]out2,
 output reg[15:0]out3,
 output reg[15:0]out4,
 output reg[15:0]out5,
 output reg[15:0]out6,
 output reg[15:0]out7,
 output reg[15:0]out8,
 output reg[15:0]out9,
 output  data_get_flag,
 output  win_gen_flag
  );
  reg [1:0]state=2'd2;
  reg data_get=1'b0;
  reg win_gen=1'b0;
  reg [63:0]data1_reg;
  reg [63:0]data2_reg;
  reg [63:0]data3_reg;
  
  reg ini=1;
  
  reg nxt_data_d=1'b0;
  reg medfilt_done_d=1'b0;
  wire nxt_data_rising;
  wire medfilt_done_rising;
  
    always @ (posedge clk or negedge rst_n)   
     if (!rst_n)
         nxt_data_d <= 0;
      else 
         nxt_data_d <= nxt_data_flag;
   
   assign nxt_data_rising = nxt_data_flag & (~nxt_data_d); 
   
   always @ (posedge clk or negedge rst_n)   
    if (!rst_n)
        medfilt_done_d <= 0;
     else 
        medfilt_done_d <= medfilt_done_flag;
  
  assign medfilt_done_rising = medfilt_done_flag & (~medfilt_done_d); 
 
 always@(posedge clk or negedge rst_n)//get data
  begin
  if(~rst_n)
  begin
  data1_reg<=0;
  data2_reg<=0;
  data3_reg<=0;
  out1<=16'b0;
  out2<=16'b0;
  out3<=16'b0;
  out4<=16'b0;
  out5<=16'b0;
  out6<=16'b0;
  out7<=16'b0;
  out8<=16'b0;
  out9<=16'b0;
  end
  else begin
  if(nxt_data_flag && state==2)begin
  state<=0;
  data1_reg<=data1;
  data2_reg<=data2;
  data3_reg<=data3;
  end
  else if(nxt_data_flag&&(state==1||state==0))begin
  data1_reg<=data1;
  data2_reg<=data2;
  data3_reg<=data3;
  end
  
   if(medfilt_done_flag || ini) begin
   
    if(state==0) begin
   
    out1<=data1_reg[15:0];
    out2<=data1_reg[31:16];
    out3<=data1_reg[47:32];
    
    out4<=data2_reg[15:0];
    out5<=data2_reg[31:16];
    out6<=data2_reg[47:32];
    
    out7<=data3_reg[15:0];
    out8<=data3_reg[31:16];
    out9<=data3_reg[47:32];
    
    state<=state+1;
    end
    else if(state==1)begin
     out1<=data1_reg[31:16];
     out2<=data1_reg[47:32];
     out3<=data1_reg[63:48];
     
     out4<=data2_reg[31:16];
     out5<=data2_reg[47:32];
     out6<=data2_reg[63:48];
     
     out7<=data3_reg[31:16];
     out8<=data3_reg[47:32];
     out9<=data3_reg[63:48];
     state<=state+1;
     
    end
  end
  end
   end
 always @ ( posedge clk or negedge rst_n )
     if ( ~rst_n )
           win_gen<= 1'b0;
      else if ( state==2'd1 ||state==2'd0 )  
            win_gen <= 1'b1;
      else 
             win_gen <= 1'b0;
  
  always @ ( posedge clk or negedge rst_n )
            if (~rst_n )
                data_get<= 1'b0;
            else if ( state==2'd2 )  
                  data_get <= 1'b1;
            else 
                  data_get <= 1'b0;
             
  assign data_get_flag=data_get;
  assign win_gen_flag=win_gen;
endmodule
