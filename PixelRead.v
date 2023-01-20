`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/30 16:15:10
// Design Name: 
// Module Name: test2
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

module PixelRead #(parameter DW = 64, BW=8, AW = 21, DEPTH = 2097152,WMEM=1097152)
(
input clk,
input pclk,
input prstn,
input read_start,
input[BW-1:0] wen,
//input Mode,
input [20:0] block_adr, 
input [20:0]w_adr,
//input nxt_pixel,
input[15:0] frame_width,
input[15:0] frame_height,
input[63:0] result,
input right_edge,
output reg read_finish,
output reg[63:0]out1,
output reg[63:0]out2,
output reg[63:0]out3,
output reg write_finish
);
//reg [63:0] data1;
//reg[63:0] data2;
//reg[63:0] data3;
//reg[63:0] data4;
//reg[63:0] data5;
//reg[63:0] data6;
reg mem_csn=0;
reg [20:0]mem_adr;
reg [63:0]mem_di;
wire [63:0]mem_do;
wire finish_sig;

reg Mode=0;  
integer j=0,i=0;
sram_2Mx64 u_mem(
.clk(pclk),
.csn(mem_csn),
.adri(mem_adr),
.adro(w_adr),
.wen(wen),
.din(result),
.dout(mem_do),
.finish_sig(finish_sig)
);

always@(posedge pclk or negedge pclk)
begin
  if(read_start)begin
   
     case(j)
         0:begin
           mem_adr<=block_adr;
           read_finish<=0;
         end
         1:begin 
        //   mem_adr<=block_adr;
           mem_adr<=(block_adr+(frame_width>>2));
          // data1<=mem_do;
           if(~right_edge)begin
              if(Mode==0)begin
                out1<=mem_do;
              end
              else if(Mode==1)begin
                out1[31:0]<=mem_do[63:32];
              end
           end
           else begin
              mem_adr<=(block_adr+(frame_width>>2));
              out1<=mem_do;
           end
         end
         2:begin
          // mem_adr<=block_adr+frame_width>>2;
           mem_adr<=(block_adr+(2*(frame_width>>2)));
          // data2<=mem_do;
           if(~right_edge)begin
              if(Mode==0)begin
                out2<=mem_do;
              end
              else if(Mode==1)begin
                out2[31:0]<=mem_do[63:32];
              end
           end
           else begin
              mem_adr<=(block_adr+(2*(frame_width>>2)));
              out2<=mem_do;
           end
         end
         3:begin
         //  mem_adr<=block_adr+2*frame_width>>2;
           mem_adr<=block_adr+1;
        //   data3<=mem_do;
           if(~right_edge)begin
             if(Mode==0)begin
               out3<=mem_do;
             end
             else if(Mode==1)begin
               out3[31:0]<=mem_do[63:32];
             end
           end
           else begin
              mem_adr<=block_adr;
              out3<=mem_do;
           end
         end
         4:begin
         //  mem_adr<=block_adr+1;
           mem_adr<=block_adr+1+(frame_width>>2);
         //  data4<=mem_do;
          // if(Mode==0)begin
          //   out1<=out1;
         //  end
          // else 
           if(~right_edge)begin
              if(Mode==1)begin
                 out1[63:32]<=mem_do[31:0];
              end
            end
        end
         5:begin
         //  mem_adr<=block_adr+1+frame_width>>2;
           mem_adr<=block_adr+1+(2*(frame_width>>2));
         //  data5<=mem_do;
         //   if(Mode==0)begin
         //    out2<=out2;
         //  end
         //  else
            if(~right_edge)begin
              if(Mode==1)begin
                out2[63:32]<=mem_do[31:0];
              end
            end
         end
         6:begin
           mem_adr<=block_adr;
          // data6<=mem_do;
          //  if(Mode==0)begin
          //   out3<=out3;
          // end
          // else 
          if(~right_edge)begin
            if(Mode==1)begin
              out3[63:32]<=mem_do[31:0];
            end
          end
         end
         default:;
      endcase
   //   mem_adr<=mem_adr+1;
      j<=j+1;
    //  mode<=1;
    end
end

always@(posedge pclk or negedge pclk)
begin
  if(read_start)begin
    if(j>=6)begin
      j<=0;
     if(~right_edge)begin
       Mode=~Mode;
      end
     read_finish<=1;
    
  end
  end
 write_finish<=0;
end


endmodule

      