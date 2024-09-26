`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2024 02:25:06
// Design Name: 
// Module Name: tb
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


  `define headerSize 1080
  `define imageSize 512*512
     module tb();
     
     //contol signal
   reg H_start;
   reg V_start;
   reg H_end;
   reg V_end;
     
     reg clk;
     reg reset;
     reg [7:0] imgData;
     reg  [7:0]i_data[0:3];
     integer file,file1,i;
    
     integer sentSize;
     wire intr;
     wire outDataValid;
     integer receivedData=0;
     wire [7:0]outdata;
     reg [9:0]pixel_count;   
     reg [1:0]wr_count;
 
      //outpput control signal
 
     wire outH_start;
     wire outV_start;
     wire outH_end;
     wire outV_end;
     
          initial
         begin
            clk = 1'b0;
            forever
            begin
                #5
                clk = ~clk;
            
             end
         
         end
 
 ///initialize control signal
       
       initial 
         begin
           
           H_start=0;
           H_end=0;
          
         end
         initial begin
         V_start=0;
         V_end=0;
         #20
         V_start=0;
         V_end=0;
         #100;
         end
         
         
     
 
  
      always @(posedge clk)begin
      
       if(!reset||pixel_count==512)
       
       pixel_count<=0;
       
       else begin
       
        pixel_count<=pixel_count+1;
      
       end
       
     end
   
     always @(posedge clk)
      begin
      if (pixel_count ==512)
        begin 
        H_start <= 1'b1;
        H_end<=1'b0;
        end
         else if (pixel_count == 511)begin
        H_end <= 1'b1;
        H_start<=1'b0;
        end
         else if(pixel_count==0)begin
          H_start<=1'b1;
          H_end <=1'b0;
         end
          else 
         begin
         
        H_start <= 1'b0;
        H_end <= 1'b0;
        end
        end
        
          
      always @(posedge clk)begin
      if(!reset)begin
       wr_count<=0;
       end
       
       else if(pixel_count==511)
        wr_count<=wr_count+1;
        end
      initial
       begin
        
      reset = 0;
      sentSize = 0;
     
      #100;
      reset = 1; 
      #100;
      
     file = $fopen("lena_poor.bmp","rb");
    
     file1 = $fopen("img_Lena_filtered.bmp","wb");
    
     for(i=0;i<`headerSize;i=i+1)
     begin
        $fscanf(file,"%c",imgData);
        $fwrite(file1,"%c",imgData);
     end
 
     for(i=0;i<4*512;i=i+1)
      begin
      @(posedge clk);
         i_data[wr_count] <= imgData;
        $fscanf(file,"%c", imgData);
         //H_start <= 1'b0;
         //H_end<=1'b1;
     end
    sentSize = 4*512;
    
    @(posedge clk);
   // H_start <= 1'b1;
  //  H_end<=1'b0;
    while(sentSize<`imageSize)
    
    begin
        @(posedge intr);
        for(i=0;i<512;i=i+1)
        begin
            @(posedge clk);
            i_data[wr_count] <= imgData;
            $fscanf(file,"%c",imgData);
           // H_start <= 1'b0;
           // H_end<=1'b1;    
        end 
        @(posedge clk);
       // H_start <= 1'b1;
       // H_end<=1'b0;
        sentSize = sentSize+512;
    end
       @(posedge clk);
      //  H_start <= 1'b1;
       // H_end<=1'b0;
      @(posedge intr);
       for(i=0;i<512;i=i+1)
    begin
        @(posedge clk);
       i_data[wr_count] <=0;
       // H_start <= 1'b0;
        //H_end<=1'b1;    
     end
    @(posedge clk);
    //H_start<= 1'b1;
    //H_end<=1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
    
        @(posedge clk);
        i_data[wr_count]<=0;
       // H_start <= 1'b0;
       // H_end<=1'b0;    
     end
   // @(posedge clk);
   // H_start <= 1'b1;
   // H_end<=1'b0;
    $fclose(file);
 end


  always @(posedge clk)
    begin
     if(outDataValid)
     begin
      
     $fwrite(file1,"%c",outdata);
      receivedData = receivedData+1;
      
     end 
     
     if(receivedData == `imageSize)
     begin
        $fclose(file1);
        $stop;
     end
     
 end
 
 
   hstart_end_top dut(
   
   // input control signal
    .H_start(H_start),
    .V_start(V_start),
    .H_end(H_end),
    .V_end(V_end),
    .axi_clk(clk),
    .axi_reset_n(reset),
    //slave interface
   
    .i_data1(i_data[0]),
    .i_data2(i_data[1]),
    .i_data3(i_data[2]),
    .i_data4(i_data[3]),
    
    
    //.o_data_ready(),
    //master interface
    .o_data_valid(outDataValid),
    .o_data_final(outdata),
    .i_data_ready(1'b1),
    //interrupt
    .o_intr(intr),
    
    //control
     .outH_start(outH_start),
     .outV_start(outV_start),
     .outH_end(outH_end),
     .outV_end(outV_end)
   );   
    
    
    
  endmodule
  