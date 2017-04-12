`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2017 04:17:07 PM
// Design Name: 
// Module Name: timekeeper
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


module timekeeper(
    // input clock and reset signal
    input wire clk,             
    input wire reset,

    input wire set_time,    // update current time when set
    input wire time12or24,  // time in 12 or 24 hours
    
    // periods for a second and colon blink rate
    input wire [31:0] seconds_period,   
    input wire [31:0] colon_period,
    
    // BCD input for hours, minutes, and seconds
    input wire [7:0] hours_in,
    input wire [7:0] minutes_in,
    input wire [7:0] seconds_in,
    
    // BCD output for hours, minutes, and seconds
    output wire [7:0] hours_out,
    output reg [7:0] minutes_out,
    output reg [7:0] seconds_out,
    
    output wire colon_out
    );
    
    // internal registers
    reg [31:0] seconds_count;   // seconds counter
    reg [31:0] colon_count;     // colon counter
    reg [7:0] hours24;          // internal hours in 24 hours

    // internal signals
    wire clock_enable;
    assign clock_enable = ((set_time == 1) || (seconds_period == 32'd0)) ? 0 : 1;
    
    // drive the seconds clock
    reg seconds_clock;
    always @(posedge clk) begin
        if ((reset == 1) || (~clock_enable)) begin
            seconds_count <= 32'd0;
            seconds_clock <= 0;
        end 
        else if (seconds_count == seconds_period) begin
            seconds_count <= 32'd0;
            seconds_clock <= ~seconds_clock;
        end
        else 
            seconds_count <= seconds_count + 1;
    end
       
    // drive the seconds clock
    reg colon_clock;
    always @(posedge clk) begin
        if ((reset == 1) || (~clock_enable)) begin
            colon_count <= 32'd0;
            colon_clock <= 0;
        end 
        else if (colon_count == colon_period) begin
            colon_count <= 32'd0;
            colon_clock <= ~colon_clock;
        end
        else 
            colon_count <= colon_count + 1;
    end          
    
    reg last_seconds_clock = 0;
    reg carry_seconds;
    
    always @(posedge clk) begin
        if (reset == 1) begin
            seconds_out <= 8'h0; 
            last_seconds_clock <= 0;
            carry_seconds <= 0;
        end 
        else if (set_time == 1) begin
            seconds_out <= seconds_in;
            last_seconds_clock <= seconds_clock;
            carry_seconds <= 0;
        end
        else if ((clock_enable) && (last_seconds_clock != seconds_clock)) begin
            last_seconds_clock <= seconds_clock;
            carry_seconds <= 0;
            
            // handle carries through seconds
            if (seconds_out[3:0] >= 4'd9) begin
                if (seconds_out[7:4] >= 4'd5) begin
                    carry_seconds <= 1;
                    seconds_out <= 8'd0;
                end
                else begin
                    seconds_out[7:4] <= seconds_out[7:4] + 1;
                end
            end
            else begin
                seconds_out[3:0] <= seconds_out[3:0] + 1;
            end 
        end
    end

    reg carry_minutes = 0;
    reg last_carry_seconds = 0;
    always @(posedge clk) begin
        if (reset == 1) begin
            minutes_out <= 8'd0;
            carry_minutes <= 0;
            last_carry_seconds <= 0;
        end
        else if (set_time == 1'b1) begin
            minutes_out <= minutes_in;
            carry_minutes <= 0;
            last_carry_seconds <= 0;
        end
        else if ((last_carry_seconds == 1'b0) && (carry_seconds == 1'b1)) begin
            carry_minutes <= 0;
            if (minutes_out[3:0] >= 4'd9) begin
                minutes_out[3:0] <= 4'd0;
                
                if (minutes_out[7:4] >= 4'd5) begin
                    minutes_out[7:4] <= 4'd0;
                    carry_minutes <= 1;
               end
               else begin
                    minutes_out[7:4] <= minutes_out[7:4] + 1;
               end
            end
            else begin
                minutes_out[3:0] <= minutes_out[3:0] + 1;
            end           
        end    
        last_carry_seconds <= carry_seconds;            
      end
            
    reg last_carry_minutes = 0;
    always @(posedge clk) begin
        if (reset == 1) begin
            hours24 <= 8'd0;
            last_carry_minutes <= 0;
        end
        else if (set_time == 1) begin
             hours24 <= hours_in;
             last_carry_minutes <= 0;
        end
        else if ((last_carry_minutes == 0) && (carry_minutes == 1)) begin
            if (hours24 == 8'h09) 
                hours24 <= 8'h10;
            else if (hours24 == 8'h19)
                hours24 <= 8'h20;
            else if (hours24 == 8'h23)
                hours24 <= 8'h00;
            else
                hours24 <= hours24 + 1;
        end
        last_carry_minutes <= carry_minutes;        
   end
       
            
     assign hours_out = (time12or24 == 1) ?  hours24 :
                ((hours24 == 8'h0) || (hours24 == 8'h12)) ? 8'h12 :
                (hours24 > 8'h12) ? hours24 - 8'h12 : hours24;
                

     assign colon_out = colon_clock;     
endmodule
