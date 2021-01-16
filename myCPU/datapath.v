`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 15:49:37
// Design Name: 
// Module Name: datapath
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

module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire [4:0] rsD,rtD,
	input wire jalD,jrD,balD,
	input wire invalidD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[7:0] alucontrolE,
	output wire flushE,
	output wire stallE,
	input wire jalE,jrE,balE,
	//mem stage
	input wire cp0weM,
	input wire memtoregM,
	input wire regwriteM,
	output wire flushM,
	output wire[31:0] aluoutM,//writedataM,
	output wire [31:0] final_writedM,
	output wire [3:0] memsel,
	input wire[31:0] readdataM,
	input wire hilo_writeM,
	input wire stall_divM,
	output wire [31:0] excepttypeM,
	output wire [31:0] excepttypeW,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire flushW,

	output wire [31:0] pcW,
	output wire [4:0] writeregW,
	output wire [31:0] resultW,
	output wire longest_stall,
	input wire i_stall,d_stall,
	output wire stallM,stallW,
	output flush_except
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	//pcjump
	wire [31:0] pcjump;
	//decode stage
	wire [31:0] pcplus4D,instrD;
	wire [31:0] pcplus8D;
	wire [1:0] forwardaD,forwardbD;
	wire [4:0] rdD;
	wire [4:0] saD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [31:0] pcD;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] saE;
	wire [4:0] writeregE,writereg2E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E;
	wire [31:0] pcplus8E;
	wire [63:0] hilo_inE;
	wire [5:0] opE;
	wire [31:0] pcE;
	//mem stage
	wire [4:0] writeregM;
	wire [63:0] hilo_inM;
	wire [63:0] hilo_outM;
	wire [5:0] opM;
	wire [31:0] pcM;
	wire [31:0] writedataM,final_readdM;
	wire stallM;
	//writeback stage
	wire [31:0] aluoutW,readdataW;
	//use in div
	wire stall_divE;
	wire stallW;
	
		
//exception
	wire [31:0] data_o,count_o,compare_o,status_o,cause_o,epc_o, config_o,prid_o,badvaddr;
	wire timer_int_o;
	wire [31:0] cp0dataE,cp0data2E;
	wire forwardcp0E;
	wire [4:0] rdM;
	wire [7:0] exceptF,exceptD,exceptE,exceptM;
	wire is_in_delayslotF,is_in_delayslotD,is_in_delayslotE,is_in_delayslotM;
	wire syscallD,breakD,eretD;
	wire overflowE;
	wire [31:0] bad_addrM;
	wire adesM,adelM;
	wire flushF;
	wire [31:0] pcnewM;

	//hazard detection
	hazard h(
		//fetch stage
		.stallF(stallF),
		.flushF(flushF),
		//decode stage
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD),
		.balD(balD),
		.jumpD(jumpD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),
		.flushD(flushD),
		//execute stage
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.rdE(rdE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.stall_divE(stall_divE),
		.flushE(flushE),
		.stallE(stallE),
		.forwardcp0E(forwardcp0E),
		//mem stage
		.rdM(rdM),
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		.cp0weM(cp0weM),
		.excepttypeM(excepttypeM),
		.epc_o(epc_o),
		.flushM(flushM),
		.pcnewM(pcnewM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		.flushW(flushW),
		.longest_stall(longest_stall),
		.i_stall(i_stall),
		.d_stall(d_stall),
		.stallM(stallM),
		.stallW(stallW),
		.flush_except(flush_except)
		);

	//next PC logic (operates in fetch an decode)
	adder pcadd1(pcF,32'b100,pcplus4F);
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD|jalD,pcjump);
	mux2 #(32) pcjr(pcjump,srca2D,jrD,pcnextFD);

	pcflop #(32) pcf(clk,rst,~stallF,flushF,pcnextFD,pcnewM,pcF);

	//regfile (operates in decode and writeback)
	regfile rf(~clk,regwriteW & ~i_stall & ~d_stall ,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//fetch stage logic
	//flopenr #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	
	assign exceptF = (pcF[1:0] == 2'b00) ? 8'b00000000 : 8'b10000000;
	assign is_in_delayslotF = (jumpD|jalD|jrD|branchD);
	
	
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(8) r4D(clk,rst,~stallD,flushD,exceptF,exceptD);
	flopenrc #(1) r5D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	
	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	//mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	//mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	mux3 #(32) forwardamux(srcaD,aluoutE,aluoutM,forwardaD,srca2D);
	mux3 #(32) forwardbmux(srcbD,aluoutE,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);
	//pc+8
	adder pcadd3(pcplus4D,32'b100,pcplus8D);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];

	assign syscallD = (opD == `EXE_SPECIAL_INST && functD == `EXE_SYSCALL);
	assign breakD = (opD == `EXE_SPECIAL_INST && functD == `EXE_BREAK);
	assign eretD = (instrD == `EXE_ERET);


	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	//移位指令导致sa也需要存下来到exe阶段
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	//pc+8
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	flopenrc #(32) r9E(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(6) r10E(clk,rst,~stallE,flushE,opD,opE);

	flopenrc #(1) r11E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);

	flopenrc #(8) r12E(clk,rst,~stallE,flushE,
		{exceptD[7],syscallD,breakD,eretD,invalidD,exceptD[2:0]},
		exceptE);
	
	mux2 #(32) forwardcp0mux(cp0dataE,aluoutM,forwardcp0E,cp0data2E);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	//alu中直接把hilo_outM当成input，得到的hiloinE是要输入进hiloreg的值
	alu alu(
		.clk(clk),
		.rst(rst),
		.srca(srca2E),
		.srcb(srcb3E),
		.op(alucontrolE),
		.sa(saE),
		.hilo_in(hilo_outM),
		.cp0data(cp0data2E),
		.result(aluoutE),
		.hilo_out(hilo_inE),
		.overflow(overflowE),
		.stall_div(stall_divE)
		);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	mux2 #(5) wrmux2(writeregE,5'b11111,jalE|balE,writereg2E);
	mux2 #(32) wrmux3(aluoutE,pcplus8E,jalE|jrE|balE,aluout2E);



	//mem stage
	flopenrc#(32) r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallM,flushM,aluout2E,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallM,flushM,writereg2E,writeregM);
	//Excute阶段的要传给Memory阶段，以便在memory进行holo的写入
	flopenrc #(64) r4M(clk,rst,~stallM,flushM,hilo_inE,hilo_inM);
	flopenrc #(32) r5M(clk,rst,~stallM,flushM,pcE,pcM);
	flopenrc #(6) r6M(clk,rst,~stallM,flushM,opE,opM);
	flopenrc #(6) r7M(clk,rst,~stallM,flushM,rdE,rdM);
	flopenrc #(1) r8M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
	flopenrc #(8) r9M(clk,rst,~stallM,flushM,{exceptE[7:3],overflowE,exceptE[1:0]},exceptM);


	//把hilo的写放在memory阶段
	hilo_reg hilo(.clk(~clk),.rst(rst),.we(hilo_writeM&~stall_divM),.hi(hilo_inM[63:32]),.lo(hilo_inM[31:0]),.hi_o(hilo_outM[63:32]),.lo_o(hilo_outM[31:0]));

	loadMemory lm(
		.pc(pcM),
		.addr(aluoutM),
		.op(opM),
		.readdata(readdataM),
		.writedata(writedataM),
		.final_readd(final_readdM),
		.final_writed(final_writedM),
		.memsel(memsel),
		.adesM(adesM),
		.adelM(adelM),
		.bad_addr(bad_addrM)
	);

	exception exp(
		.rst(rst),
		.except(exceptM),
		.ades(adesM),
		.adel(adelM),
		.cp0_status(status_o),
		.cp0_cause(cause_o),
		.excepttype(excepttypeM)
	);

	cp0_reg CP0(
		.clk(clk),.rst(rst),.we_i(cp0weM & ~i_stall & ~d_stall),.waddr_i(rdM),.raddr_i(rdE),
		.data_i(aluoutM), .stall(i_stall | d_stall),
		.int_i(6'b000000),.excepttype_i(excepttypeM),
        .current_inst_addr_i(pcM),.is_in_delayslot_i(is_in_delayslotM),.bad_addr_i(bad_addrM),
        .data_o(data_o),.count_o(count_o),.compare_o(compare_o),.status_o(status_o),.cause_o(cause_o),
        .epc_o(epc_o),.config_o(config_o),.prid_o(prid_o),.badvaddr(badvaddr),.timer_int_o(timer_int_o));
    assign cp0dataE = data_o;




	//writeback stage
	flopenrc #(32) r1W(clk,rst,~stallW,flushW,aluoutM,aluoutW);
	//flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopenrc #(32) r2W(clk,rst,~stallW,flushW,final_readdM,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
	flopenrc #(32) r4W(clk,rst,~stallW,flushW,pcM,pcW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	flopenrc #(32) r5W(clk,rst,~stallW,flushW,excepttypeM,excepttypeW);

endmodule