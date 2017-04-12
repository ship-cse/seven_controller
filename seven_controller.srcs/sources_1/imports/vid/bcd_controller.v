`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2017 03:42:15 PM
// Design Name: 
// Module Name: bcd_controller
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


module bcd_controller(
    input wire clk,
    input wire reset,
    
    input wire [15:0] bcd_values,
    
    output wire [5:0] kathodes,
    output wire [8:0] anodes
    );
    
     parameter DIV = 19;
     parameter ADJ = 5;
      
     reg [DIV+ADJ:0] count = 0;
     reg [15:0] digit = 0;
      
     always @(posedge clk) begin
          count <= count + 1;
     end
      
     wire [1:0] ksel;
     assign ksel = count[DIV+1:DIV];
     assign kathodes[3:0] = ksel == 2'd0 ? 4'b0001 :
                            ksel == 2'd1 ? 4'b0010 :
                            ksel == 2'd2 ? 4'b0100 : 4'b1000;
      
     assign kathodes[5:4] = 2'b0;
    
     always @(posedge count[DIV+ADJ]) begin
         digit = digit + 1;
     end
      
     wire [3:0] bcd;
     assign bcd  = ksel == 2'd0 ? bcd_values[15:12] :
                   ksel == 2'd1 ? bcd_values[11:8] :
                   ksel == 2'd2 ? bcd_values[7:4] : bcd_values[3:0];
                                 
          
      wire [6:0] segment;
      bcd2seven uut( .bcd(bcd), .segments(segment) );
      
      assign anodes[6:0] = segment;
      assign anodes[8:7] = 2'b0;
    
endmodule
