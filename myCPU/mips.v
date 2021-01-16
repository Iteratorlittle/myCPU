`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 17:45:07
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,//,writedataM,
	output wire[31:0] final_writedM,
	output wire [3:0] memsel,
	input wire[31:0] readdataM,
	output wire [4:0] rsD,rtD,writeregW,
	output wire hilo_writeM,
	output wire stallE,//,signed_divE,start_divE,div_readyE
	output wire jalD,jrD,balD,
	output wire [31:0] scra2D,
	output wire [1:0] forwardaD,
	output wire memenM
    );
	
	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire [7:0] alucontrolE;
	wire flushE,equalD;

	wire stall_divM;

	wire jalE,jrE,balE;

	//wire hilo_writeM;
	controller c(
		clk,rst,
		//decode stage
		opD,functD,
		rtD,
		pcsrcD,branchD,equalD,jumpD,
		
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,

		//mem stage
		memtoregM,memwriteM,
		regwriteM,
		//write back stage
		memtoregW,regwriteW,

		hilo_writeM,
		stallE,
		stall_divM,
		jalE,jrE,balE,
		jalD,jrD,balD,
		memenM
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		equalD,
		opD,functD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		flushE,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM,//writedataM,
		final_writedM,
		memsel,
		readdataM,
		//writeback stage
		memtoregW,
		regwriteW,
		rsD,
		rtD,
		writeregW,
		hilo_writeM,
		hi_inE,
		lo_inE,
		hi_outM,
		lo_outM,
		stallE,
		stall_divM,
		jalE,jrE,balE,
		jalD,jrD,balD,scra2D,
		forwardaD
	//	signed_divE,
	//	start_divE,
	//	div_readyE
		);
	
endmodule
