`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/14 10:13:24
// Design Name: 
// Module Name: medianfilter
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


module medianfilter(  
clk,
rst_n,
win_gen_flag,          //input-from module of windows; 
medfilt_done_flag,   //output-to top;
data_in0,            //input-from module of windows;
data_in1,
data_in2,
data_in3,
data_in4,
data_in5,
data_in6,
data_in7,
data_in8,
medfilt_data_out,
medfilt_data_out2    
);

input clk;
input rst_n;
input win_gen_flag;
input [15:0] data_in0;        
input [15:0] data_in1;
input [15:0] data_in2;
input [15:0] data_in3;
input [15:0] data_in4;
input [15:0] data_in5;
input [15:0] data_in6;
input [15:0] data_in7;
input [15:0] data_in8;

output medfilt_done_flag;
output [15:0] medfilt_data_out;
output [15:0] medfilt_data_out2;
reg [15:0] a11;
reg [15:0] a12;
reg [15:0] a13;
reg [15:0] a21;
reg [15:0] a22;
reg [15:0] a23;
reg [15:0] a31;
reg [15:0] a32;
reg [15:0] a33;

reg [15:0] b11;
reg [15:0] b12;
reg [15:0] b13;
reg [15:0] b21;
reg [15:0] b22;
reg [15:0] b23;
reg [15:0] b31;
reg [15:0] b32;
reg [15:0] b33;

reg [15:0] c11;
reg [15:0] c12;
reg [15:0] c13;
reg [15:0] c21;
reg [15:0] c22;
reg [15:0] c23;
reg [15:0] c31;
reg [15:0] c32;
reg [15:0] c33;

reg [2:0] i;
reg [15:0] medfilt_data;
reg [15:0] medfilt_data2;
reg filt_done=1'b0;

reg cal_vld;

reg [1:0]state=2'd0;

always @ ( posedge clk or negedge rst_n )
    if (!rst_n)
        begin
            a11 <= 0;
            a12 <= 0;
            a13 <= 0;
            a21 <= 0;
            a22 <= 0;
            a23 <= 0;
            a31 <= 0;
            a32 <= 0;
            a33 <= 0;
        end
    else if (win_gen_flag)
        begin
            a11 <= data_in0;
            a12 <= data_in1;
            a13 <= data_in2;
            a21 <= data_in3;
            a22 <= data_in4;
            a23 <= data_in5;
            a31 <= data_in6;
            a32 <= data_in7;
            a33 <= data_in8;
        end

always @ ( posedge clk or negedge rst_n )
    if (!rst_n)
        i <= 3'd0;
    else if( cal_vld & ( i!=3 ) )
        i <= i + 1;
    else 
        i <= 0;

always @ ( posedge clk or negedge rst_n )
    if (!rst_n)
        cal_vld <= 1'b0;
    else if( win_gen_flag )
        cal_vld <= 1'b1;
    else if( i==3'd3 )
        cal_vld <= 0;            


always @ ( posedge clk or negedge rst_n )
    if (!rst_n)
        begin
            filt_done <= 1'b0;
            b11 <= 0;
            b12 <= 0;
            b13 <= 0;
            b21 <= 0;
            b22 <= 0;
            b23 <= 0;
            b31 <= 0;
            b32 <= 0;
            b33 <= 0;
            c11 <= 0;
            c12 <= 0;
            c13 <= 0;
            c21 <= 0;
            c22 <= 0;
            c23 <= 0;
            c31 <= 0;
            c32 <= 0;
            c33 <= 0;
            medfilt_data <= 0;
        end
    else if( cal_vld )
        case(i)
            3'd0:
                begin
                    b11 <= max(a11, a21, a31); 
                    b12 <= max(a12, a22, a32); 
                    b13 <= max(a13, a23, a33);
                    b21 <= med(a11, a21, a31); 
                    b22 <= med(a12, a22, a32); 
                    b23 <= med(a13, a23, a33);
                    b31 <= min(a11, a21, a31); 
                    b32 <= min(a12, a22, a32); 
                    b33 <= min(a13, a23, a33);
                end

            3'd1:
                begin
                    c31 <= max(b31, b32, b33);
                    c22 <= med(b21, b22, b23);
                    c13 <= min(b11, b12, b13); 
                end

            3'd2:
                begin
                    if(state==2'd0)begin
                    medfilt_data <= med(c13, c22, c31);
                    state<=state+1;
                    end
                    else if(state==2'd1) begin
                    medfilt_data2 <= med(c13, c22, c31);
                    state<=state+1;
                    end
                    else if(state==2'd2)begin
                    filt_done<=1'b1;
                    state<=2'd0;
                    end
                    
                    
                end

            3'd3:
                filt_done <= 1'b0; 

            default:;

        endcase


function [15:0] max;
    input [15:0] a, b, c;
    begin
        max = (((a >= b) ? a : b) >= c ) ?  ((a >= b) ? a : b) : c;
    end
endfunction

function [15:0] med;
    input [15:0] a, b, c;
    begin
        med = a < b ? (b < c ? b : a < c ? c : a) : (b > c ? b : a > c ? c : a);
    end
endfunction

function [15:0] min;
    input [15:0] a, b, c;
    begin
        min= (((a <= b) ? a : b) <= c ) ?  ((a <= b) ? a : b) : c;
    end
endfunction


assign medfilt_data_out = medfilt_data;
assign medfilt_data_out2=medfilt_data2;
assign medfilt_done_flag = filt_done;


endmodule