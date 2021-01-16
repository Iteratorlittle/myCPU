`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 15:53:46
// Design Name: 
// Module Name: flopenrc
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

module flopenrc #(parameter WIDTH = 8)(
	input wire clk,rst,en,clr,
	input wire [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q
	);
	always @(posedge clk,posedge rst)
	begin
	if(rst) begin
		q <= 0;
		end
	else if(clr) begin
		q <= 0;
	end
	else if(en) begin
		q <= d;
	end
	end	
	
endmodule
