`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 17:34:06
// Design Name: 
// Module Name: eqcmp
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


`include"defines.vh"

module eqcmp(
	input wire [31:0] a,b,
	input wire [5:0] op,
	input wire [4:0] rt,
	output wire y
    );

	assign y = (op==`EXE_BEQ)?(a==b):
				(op==`EXE_BNE)?(a!=b):
				(op==`EXE_BGTZ)?((a[31]==1'b0)&&(a!=`ZeroWord)):
				(op==`EXE_BLEZ)?((a[31]==1'b1)||(a==`ZeroWord)):
				((op==`EXE_REGIMM_INST) && ((rt==`EXE_BGEZ)||(rt==`EXE_BGEZAL)) )?( (a[31]==1'b0) || (a==`ZeroWord) ):
				((op==`EXE_REGIMM_INST) && ((rt==`EXE_BLTZ)||(rt==`EXE_BLTZAL)) )?( (a[31]==1'b1)):
				1'b0;
endmodule
