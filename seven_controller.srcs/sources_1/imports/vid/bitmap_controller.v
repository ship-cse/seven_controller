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


module bitmap_controller(
    input wire clk,
    input wire reset,
    input wire [14:0] bitmap,
    
    output wire [5:0] kathodes,
    output wire [8:0] anodes
    );
    
    assign kathodes = bitmap[5:0];
    assign anodes = bitmap[14:6];
    
endmodule
