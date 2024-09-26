`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2024 02:14:31
// Design Name: 
// Module Name: control_signal
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
// control singal code
//written by Poornima
//////////////////////////////////////////////////////////////////////////////////


module control_signal(

//===============================================
//control signal
 input H_start,
 input V_start,
 input H_end,
 input V_end,
 
 //===============================================

input                    i_clk,
input                    i_rst,
input [7:0]              i_pixel_data1,
input [7:0]              i_pixel_data2,
input [7:0]              i_pixel_data3,
input [7:0]              i_pixel_data4,

output reg [71:0]        o_pixel_data1,
output reg [71:0]        o_pixel_data2,
output reg [71:0]        o_pixel_data3,
output reg [71:0]        o_pixel_data4,
output                   o_pixel_data_valid,
output reg               o_intr

);

parameter column=512; 

reg i_pixel_data_valid;
reg [9:0] pixelCounter;
reg [1:0] currentWrLineBuffer;
reg [3:0] lineBuffDataValid;
reg [3:0] lineBuffRdData;
reg [1:0]currentRdLineBuffer;
wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;
reg [8:0] rdCounter;
reg  rd_line_buffer;
reg [11:0] totalPixelCounter;
reg rdState;
reg [11:0]v_count;
 
//==============assign control signal by H_start &V_start&(H_end &V_end)======================






     always @(posedge i_clk) begin
      if (i_rst||V_end)
      v_count <= 0;
     else if(pixelCounter ==512 && H_start)
      v_count <= v_count+1;
     end
     //=======================
      always @(posedge i_clk) begin
       if (i_rst)
        i_pixel_data_valid <= 0;
    
        else if (pixelCounter == 0||pixelCounter <511)
          i_pixel_data_valid <=1;
    
        else if(v_count==511 || H_end || pixelCounter==511) 
          i_pixel_data_valid <=0;
    
       else 
          i_pixel_data_valid <=0;
         
         end
 
  //==========================

    localparam IDLE = 'b0, RD_BUFFER = 'b1;
 
  assign o_pixel_data_valid = rd_line_buffer;
 
      always @(posedge i_clk)
     
     begin
     
      if(i_rst)
           totalPixelCounter <= 0;
   
       else
   
    begin
   
        if(i_pixel_data_valid &!rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
            
            
        else if(!i_pixel_data_valid & rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
      
        
     end
  
end


 always @(posedge i_clk)
  begin
     if(i_rst)
     begin
        rdState <= IDLE;
        rd_line_buffer <= 1'b0;
        o_intr <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE:begin
               o_intr <= 1'b0;
               if(totalPixelCounter >= 1536)
               begin
                   rd_line_buffer <= 1'b1;
                   rdState <= RD_BUFFER;
               end
            end
            RD_BUFFER:begin
                if(rdCounter == 511)
                begin
                    rdState <= IDLE;
                    rd_line_buffer <= 1'b0;
                    o_intr <= 1'b1;
                end
            end
            
                        
        endcase
    end
end
 
always @(posedge i_clk)
begin
    if(i_rst||H_start||V_start||pixelCounter==512)
   
        pixelCounter <= 0;
   
     else 

    begin
         
         pixelCounter <= pixelCounter + 1;
    
    end
    
 end


always @(posedge i_clk)
begin
    if(i_rst)
        currentWrLineBuffer <= 0;
    else
    begin
        if(pixelCounter == 511 & i_pixel_data_valid)
            currentWrLineBuffer <= currentWrLineBuffer+1;
    end
end


always @(*)
begin
    lineBuffDataValid = 4'h0;
    lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
end

always @(posedge i_clk)
begin
    if(i_rst)
        rdCounter <= 0;
    else 
    begin
        if(rd_line_buffer)
            rdCounter <= rdCounter + 1;
    end
end

always @(posedge i_clk)
begin
    if(i_rst)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 511 & rd_line_buffer)
            currentRdLineBuffer <= currentRdLineBuffer + 1;
            
    end
end

/// output data
always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
         o_pixel_data1 = {lb2data,lb1data,lb0data};
         o_pixel_data2=1'b0;
         o_pixel_data3=1'b0;
         o_pixel_data4=1'b0;
         
         
        end
        1:begin
            o_pixel_data2 = {lb3data,lb2data,lb1data};
            o_pixel_data1=1'b0;
            o_pixel_data3=1'b0;
            o_pixel_data4=1'b0;
        end
        2:begin
            o_pixel_data3 = {lb0data,lb3data,lb2data};
            o_pixel_data1=1'b0;
            o_pixel_data2=1'b0;
            o_pixel_data4=1'b0;
        end
        3:begin
            o_pixel_data4 = {lb1data,lb0data,lb3data};
            o_pixel_data1=1'b0;
            o_pixel_data2=1'b0;
            o_pixel_data3=1'b0;
        end
    endcase
end





always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            lineBuffRdData[0] = rd_line_buffer;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = 1'b0;
        end
       1:begin
            lineBuffRdData[0] = 1'b0;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
        end
       2:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = 1'b0;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
       end  
      3:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = 1'b0;
             lineBuffRdData[3] = rd_line_buffer;
       end        
    endcase
end
    
line_buffer  lB0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_pixel_data1),
    .i_data_valid(lineBuffDataValid[0]),
    .o_data(lb0data),
    .i_rd_data(lineBuffRdData[0])
 );  
 
 line_buffer lB1(
     .i_clk(i_clk),
     .i_rst(i_rst),
     .i_data(i_pixel_data2),
     .i_data_valid(lineBuffDataValid[1]),
     .o_data(lb1data),
     .i_rd_data(lineBuffRdData[1])
  ); 
  
  line_buffer lB2(
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(i_pixel_data3),
      .i_data_valid(lineBuffDataValid[2]),
      .o_data(lb2data),
      .i_rd_data(lineBuffRdData[2])
   ); 
   
   line_buffer lB3(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data4),
       .i_data_valid(lineBuffDataValid[3]),
       .o_data(lb3data),
       .i_rd_data(lineBuffRdData[3])
 );        
 
endmodule
