`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2024 02:12:42
// Design Name: 
// Module Name: median
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


// median filter code written by Poornima
 module median(
  input        i_clk,
  input        rst,
  input [71:0] i_pixel_data,
  input i_pixel_data_valid,
  output reg [7:0] med,
  output reg o_med_data_valid );

reg [7:0] a1, a2, a3, a4, a5, a6, a7, a8, a9;

reg [7:0] l1, l2, l3;

 // Function to find the median of three numbers
 function [7:0] median1;
  input [7:0] x, y, z;
  begin
    if ((x >= y && x <= z) || (x >= z && x <= y))
      median1 = x;
    else if (( y>= x && y <= z) || (y >= z && y <= x))
      median1 = y;
    else
      median1 = z;
  end
endfunction
reg [3:0] i;

reg [23:0]line1;
reg [23:0]line2;
reg [23:0]line3;

//====================================
 always @(posedge i_clk)
 begin
    if(rst==1 || i==2)
        i<= 0;
    else 
        i<= i+1;
 end

// Function to find the median of nine numbers

  function [7:0] median2;
   input [7:0] a1, a2, a3, a4, a5, a6, a7, a8, a9;
   reg [7:0] l1, l2, l3;
   begin
    l1 = median1(a1, a2, a3);
    l2 = median1(a4, a5, a6);
    l3 = median1(a7, a8, a9);
    median2 = median1(l1, l2, l3);
  end
endfunction

//====================================

always @(posedge i_clk) begin
      if (rst) begin
     line1<=0;
     line2<=0;
     line3<=0;
   end
 else
     line1<=i_pixel_data[8*i+:8];
     line2<=i_pixel_data[8*(i+2)+:8];
     line3<=i_pixel_data[8*(i+4)+:8];
     
     
 end

//======================================//=========================================

always @(posedge i_clk) begin
 
  if (rst) begin
    a1 <= 8'b0;
    a2 <= 8'b0;
    a3 <= 8'b0;
    a4 <= 8'b0;
    a5 <= 8'b0;
    a6 <= 8'b0;
    a7 <= 8'b0;
    a8 <= 8'b0;
    a9 <= 8'b0;
    med<= 8'b0;
  end else if( i_pixel_data_valid) begin
    a1 <= line1;
    a2 <= a1;
    a3 <= a2;
    a4 <= line2;
    a5 <= a4;
    a6 <= a5;
    a7 <= line3;
    a8 <=  a7;
    a9 <=  a8;

    med <= median2(a1, a2, a3, a4, a5, a6, a7, a8, a9);
   
   end
    o_med_data_valid<=i_pixel_data_valid;
   

end

endmodule