`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 15:51:10
// Design Name: 
// Module Name: mux2
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


module mux2
#(parameter WIDTH=32)
(
    input[(WIDTH-1):0] a,
    input[(WIDTH-1):0] b,
    input s,
    output[(WIDTH-1):0] f
 );
 
 assign f = s ? b:a;
endmodule