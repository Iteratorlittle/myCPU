`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 15:50:47
// Design Name: 
// Module Name: signext
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


module signext(
    input wire [15:0] a,
    input wire [1:0] type,
    output wire [31:0] y
    );
    
    assign y = (type == 2'b11)?{{16{1'b0}},a} : {{16{a[15]}},a};

endmodule
