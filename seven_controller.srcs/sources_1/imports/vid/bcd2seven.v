`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2017 03:52:07 PM
// Design Name: 
// Module Name: bcd2seven
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


module bcd2seven(
    input [3:0] bcd,
    output [6:0] segments
    );
    
    assign segments = (bcd == 4'h0) ? 7'h3f :
                      (bcd == 4'h1) ? 7'h06 :
                      (bcd == 4'h2) ? 7'h5b :
                      (bcd == 4'h3) ? 7'h4f :
                      (bcd == 4'h4) ? 7'h66 :
                      (bcd == 4'h5) ? 7'h6d :
                      (bcd == 4'h6) ? 7'h7d :
                      (bcd == 4'h7) ? 7'h07 :
                      (bcd == 4'h8) ? 7'h7f :
                      (bcd == 4'h9) ? 7'h67 :
                      (bcd == 4'ha) ? 7'h77 :
                      (bcd == 4'hb) ? 7'h7c :
                      (bcd == 4'hc) ? 7'h39 :
                      (bcd == 4'hd) ? 7'h5e :
                      (bcd == 4'he) ? 7'h79 : 7'h71;
                      
endmodule
