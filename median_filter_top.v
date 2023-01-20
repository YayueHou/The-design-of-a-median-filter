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

module median_filter_top(
input pclk,
input prstn,
input [15:0] frame_width,
input [15:0] frame_height,

output reg [63:0]result
    );


reg read_start=1;
wire write_finish=0;
reg [7:0] wen;
wire [15:0] dataout1;
wire [15:0] dataout2;
wire [63:0] data1;
wire [63:0] data2;
wire [63:0] data3;

reg [20:0] block_adr=0;
//reg [20:0] w_adr,
reg right_edge=0;
wire read_finish=0;
wire ave_finish=0;
reg nxt_flag=1;
//reg [63:0]result;
reg [20:0]w_adr=21'd1097152;
integer len=2,wid=0;

PixelRead u_t2(
.wen(wen),
.pclk(pclk),
.prstn(prstn),
.w_adr(w_adr),
.block_adr(block_adr), 
//.nxt_pixel(nxt_pixel),
.read_start(read_start),
.frame_width(frame_width),
.frame_height(frame_hight),
.read_finish(read_finish),
.write_finish(write_finish),
.right_edge(right_edge),
.result(result),
.out1(data1),
.out2(data2),
.out3(data3)
);

median_top median(
.clk(pclk),
.rst_n(prstn),
.four_pixel1(data1),
.four_pixel2(data2),  
.four_pixel3(data3),  
.nxt_data_flag(nxt_flag),
.medfilt_data_out(dataout1),
.medfilt_data_out2(dataout2),
.medfilt_done_flag(ave_finish),
.data_get_flag(data_get)
    );


reg t1=0;
reg t2=0;
reg q=0;
always@(posedge pclk or negedge prstn)begin
  t1<=ave_finish;
  t2<=t1;
if((t1!=t2)&&(t1==1))begin
    read_start<=1;
     wen<=0;
    q<=~q;
    if(q==1)
    begin
       result[47:32]<=dataout1;
       result[63:48]<=dataout2;
      
    end
    else
    begin
       result[15:0]<=dataout1;
       result[31:16]<=dataout2;
    end
    if(len<frame_width-2)begin
     right_edge<=0;
     len<=len+2;
     if((len%4==0)&&(len>2))begin
        block_adr<=block_adr+1;
     end
    end
    else
    begin
      len<=2;
      right_edge<=1;
      if(wid<frame_height-2)begin
        wid<=wid+1;
        block_adr<=block_adr+1;
      end
      else begin
        read_start<=0;
      end    
     end
end
end

reg t4=0;
reg t3=0;
always@(posedge pclk or negedge prstn)
begin
  t3<=read_finish;
  
  t4<=t3;
  if((t3!=t4)&&(t3!=0))begin
    read_start<=0;
    if(q==1)begin
    wen<=1;
    w_adr<= w_adr+1;
    end
  end
end




endmodule