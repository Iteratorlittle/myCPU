`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 15:48:18
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,
	input wire [4:0] rsD,rtD,
	output wire pcsrcD,branchD,
	input wire equalD,
	output wire jumpD,
	output wire jalD,jrD,balD,
	output wire invalidD,
	//execute stage
	input wire flushE,
	input wire stallE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[7:0] alucontrolE,
	output wire jalE,jrE,balE,
	//mem stage
	input wire flushM,
	output wire memtoregM,regwriteM,
	output wire stall_divM,
	output wire hilo_writeM,
	output wire memenM,
	output wire cp0weM,
	//write back stage
	input wire flushW,
	output wire memtoregW,regwriteW,
	input wire stallM,stallW
    );
	
	//decode stage
	/*wire[1:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire[2:0] alucontrolD;
	*/

	wire [7:0] alucontrolD;
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire hilo_writeD;
	wire memenD;
	//execute stage
	wire memwriteE;
	wire hilo_writeE;
	wire memenE;
	wire cp0weD,cp0weE;
	wire memwriteM;
	maindec md(
		.op(opD),
		.funct(functD),
		.rs(rsD),
		.rt(rtD),
		.memtoreg(memtoregD),
		.memwrite(memwriteD),
		.branch(branchD),
		.alusrc(alusrcD),
		.regdst(regdstD),
		.regwrite(regwriteD),
		.jump(jumpD),
		.hilo_write(hilo_writeD),
		.jal(jalD),
		.jr(jrD),
		.bal(balD),
		.memen(memenD),
		.cp0we(cp0weD),
		.invalid(invalidD)
		);
	aludec ad(
		.op(opD),
		.funct(functD),
		.rs(rsD),
		.alucontrol(alucontrolD)
		);

	assign pcsrcD = branchD && equalD;

	//pipeline registers
	/*floprc #(8) regE(
		clk,
		rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
		);
	flopr #(3) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
		);
	flopr #(2) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);*/

		flopenrc #(19) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,hilo_writeD,jalD,jrD,balD,memenD,cp0weD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,hilo_writeE,jalE,jrE,balE,memenE,cp0weE}
		);
		flopenrc #(7) regM(
		clk,rst,~stallM,flushM,
		{memtoregE,memwriteE,regwriteE,hilo_writeE,stallE,memenE,cp0weE},
		{memtoregM,memwriteM,regwriteM,hilo_writeM,stall_divM,memenM,cp0weM}
		);
		flopenrc #(2) regW(
		clk,rst,~stallW,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);

	
endmodule
