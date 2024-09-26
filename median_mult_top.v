`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2024 01:55:39
// Design Name: 
// Module Name: median_mult_top
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
//Deigned by Poornima Varshney

module median_mult_top(
    input  axi_clk,
 input  axi_reset_n,
 
 //slave interface
             
             input   i_data_valid,
             input  [7:0] i_data1,
             input  [7:0] i_data2,
             input  [7:0] i_data3,
             input  [7:0] i_data4,
                  output  [7:0]o_data_final,

//master interface

output  o_data_valid,
input   i_data_ready,
 //interrupt
output  o_intr
);
wire[7:0] out1;
wire[7:0] out2;
wire[7:0] out3;
wire[7:0] out4;
//==============================
reg[7:0] o_data1;


//===============================
wire [71:0] pixel_data1;
wire [71:0] pixel_data2;
wire [71:0] pixel_data3;
wire [71:0] pixel_data4;
wire pixel_data_valid;
wire axis_prog_full;
wire med_data_valid;
reg [1:0]count;

control_signal IC(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data1(i_data1),
    .i_pixel_data2(i_data2),
    .i_pixel_data3(i_data3),
    .i_pixel_data4(i_data4),
    .i_pixel_data_valid(i_data_valid),
    .o_pixel_data1(pixel_data1),
    .o_pixel_data2(pixel_data2),
    .o_pixel_data3(pixel_data3),
    .o_pixel_data4(pixel_data4),
    .o_pixel_data_valid(pixel_data_valid),
    .o_intr(o_intr)
    );    
  
  median med1(.rst(!axi_reset_n),
     .i_clk(axi_clk),
     .i_pixel_data(pixel_data1),
     .i_pixel_data_valid(pixel_data_valid),
     .med(out1),
     .o_med_data_valid(med_data_valid)
      ); 
      
 median med2(.rst(!axi_reset_n),
     .i_clk(axi_clk),
     .i_pixel_data(pixel_data2),
     .i_pixel_data_valid(pixel_data_valid),
     .med(out2),
     .o_med_data_valid(med_data_valid)
      );
 median med3(.rst(!axi_reset_n),
     .i_clk(axi_clk),
     .i_pixel_data(pixel_data3),
     .i_pixel_data_valid(pixel_data_valid),
     .med(out3),
     .o_med_data_valid(med_data_valid)
     );
 median med4(.rst(!axi_reset_n),
     .i_clk(axi_clk),
     .i_pixel_data(pixel_data4),
     .i_pixel_data_valid(pixel_data_valid),
     .med(out4),
     .o_med_data_valid(med_data_valid)
    );
 
  always @(posedge axi_clk)begin
 
   if(!axi_reset_n)begin
    //o_data1<=0;
   count<=0;
  end
 
   else if(o_intr)begin //intr--0 
  
   count<=count+1;
 
   end
 end
 //======================================================================
always @(posedge axi_clk)begin
if (!axi_reset_n)
    o_data1 <= 8'b00000000;
    else begin
            case(count)
            0:begin
            o_data1<=out1;
            end
            1:begin
            o_data1<=out2;
            end
            2:begin
            o_data1<=out3;
            end
            3:begin
            o_data1<=out4;
          end
          endcase
            
   end
  end
  
  //================================================================================
 
 fifo_generator_0  ppt(
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_reset_n),            // input wire s_aresetn
  .s_axis_tvalid(med_data_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(o_data1),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
  .m_axis_tready(i_data_ready),    // input wire m_axis_tready
  .m_axis_tdata(o_data_final),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);
 //=================================================================================

endmodule
