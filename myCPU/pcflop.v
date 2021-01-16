`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 15:57:35
// Design Name: 
// Module Name: pcflop
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

module pcflop # (parameter WIDTH = 8) (
    input clk, rst,en,clr,
    input [WIDTH-1:0] d,
    input [WIDTH-1:0] t,
    output reg [WIDTH-1:0] q
);

always @ (posedge clk,posedge rst)
begin
    if(rst)
    begin
        q <= 32'hbfc0_0000;
    end else if (clr) 
    begin
        q <= t;
    end else if (en)
    begin
        q <= d;
    end
end
endmodule
