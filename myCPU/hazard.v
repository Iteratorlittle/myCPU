`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 15:54:07
// Design Name: 
// Module Name: hazard
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

module hazard(
		//fetch stage
		output wire stallF,
		output wire flushF,
		//decode stage
		input wire [4:0] rsD,rtD,
		input wire branchD,
		//new add use in branch
		input wire balD,jumpD,
		output reg [1:0] forwardaD,forwardbD,
		output wire stallD,
		output wire flushD,
		//execute stage
		input wire [4:0] rsE,rtE,writeregE,rdE,
		input wire regwriteE,memtoregE,
		output reg [1:0] forwardaE,forwardbE,
		input wire stall_divE,
		output wire flushE,
		output wire stallE,
		output wire forwardcp0E,
		//mem stage
		input wire [4:0] rdM,
		input wire [4:0] writeregM,
		input wire regwriteM,memtoregM,
		input wire cp0weM,
		input wire [31:0] excepttypeM,
		//input wire [31:0] excepttypeW,
		input wire [31:0] epc_o,
		output wire flushM,
		output wire [31:0] pcnewM,
		//write back stage
		input wire [4:0] writeregW,
		input wire regwriteW,
		output wire flushW,
		output wire longest_stall,
		input wire i_stall,d_stall,
		output wire stallM,stallW,
		output flush_except
		//use in div
		//input wire stall_divE,
		//output wire stallE
		);

//data hazard
always @(*) begin
    if((rsD != 1'b0) && (rsD == writeregM) && regwriteM)     
        forwardaD <= 2'b10;
	else if ((rsD != 1'b0) && (rsD == writeregE) && regwriteE) 
        forwardaD <= 2'b01;
	else forwardaD <= 2'b00;
end
always @(*) begin
    if((rtD != 1'b0) && (rtD == writeregM) && regwriteM)     
        forwardbD <= 2'b10;
	else if ((rtD != 1'b0) && (rtD == writeregE) && regwriteE) 
        forwardbD <= 2'b01;
	else forwardbD <= 2'b00;
end



always @(*) begin
    if((rsE != 1'b0) && (rsE == writeregM) && regwriteM)     
        forwardaE <= 2'b10;
	else if ((rsE != 1'b0) && (rsE == writeregW) && regwriteW) 
        forwardaE <= 2'b01;
	else forwardaE <= 2'b00;
end
always @(*) begin
    if((rtE != 1'b0) && (rtE == writeregM) && regwriteM)     
        forwardbE <= 2'b10;
	else if ((rtE != 1'b0) && (rtE == writeregW) && regwriteW) 
        forwardbE <= 2'b01;
	else forwardbE <= 2'b00;
end

	assign forwardcp0E = ((rdE!=0)&(rdE == rdM)&(cp0weM))?1'b1:1'b0;

	wire flush_except,flush_except2;;
	assign flush_except = (excepttypeM != 32'b0);
	assign flush_except2 = (excepttypeM == 32'h00000000) ? 0:1;

//stop
    wire lwstallD;
    assign lwstallD = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
	//assign stallF = stallD = flushE = lwstall;
	//new branch 
	wire branchflushD;
	assign branchflushD = branchD && !balD;
	
//forward logic
  //  assign forwardaD = (rsD !=0) && (rsD == writeregM) && regwriteM;
	//assign forwardbD = (rtD !=0) && (rtD == writeregM) && regwriteM;
//	assign forwardaD = ((rsD != 0) && (rsD == writeregM) && regwriteM)?2'b10:((rsD!=0)&&(rsD == writeregE)&& regwriteE)?2'b01:2'b00;
//	assign forwardbD = ((rtD != 0) && (rtD == writeregM) && regwriteM)?2'b10:((rtD!=0)&&(rtD == writeregE)&& regwriteE)?2'b01:2'b00;

//stalling logic
 //   assign branchstall = branchD && ((regwriteE && 
 //                  (writeregE == rsD || writeregE == rtD))||
  //                 (memtoregM && (writeregM == rsD || writeregM == rtD)));
	wire branchstall;
	assign branchstall = ((branchD||jumpD) && regwriteE && (writeregE == rsD || writeregE == rtD) || (branchD||jumpD) && memtoregM && (writeregM == rsD || writeregM == rtD));

	//assign flushF = 1'b0;
	//assign flushF = ~(i_stall |d_stall) & (flush_except|flush_except2);
	//assign flushD = ~(i_stall |d_stall)& (flush_except|flush_except2);
	//assign flushE = ~(i_stall |d_stall)& (lwstallD ||jumpD||branchstall||flush_except|flush_except2);
	//assign flushM = ~(i_stall |d_stall)& (stall_divE|flush_except|flush_except2);

	assign flushF = ~(i_stall |d_stall) & (flush_except);
	assign flushD = ~(i_stall |d_stall)& (flush_except);
	assign flushE = ~(i_stall |d_stall)& (lwstallD ||jumpD||branchstall||flush_except);
	assign flushM = ~(i_stall |d_stall)& (stall_divE|flush_except);
	assign flushW = ~(i_stall |d_stall) & flush_except;
	//assign flushW = 1'b0;

	assign stallF = (i_stall |d_stall) | (flush_except?1'b0:(lwstallD|stall_divE|branchstall));
    assign stallD = (i_stall |d_stall) |(lwstallD | branchstall | stall_divE|i_stall |d_stall);
	assign stallE = (i_stall |d_stall) |(stall_divE|branchstall);
	assign stallM = (i_stall |d_stall) ;
	assign stallW = (i_stall |d_stall) ;
	assign longest_stall = stall_divE| i_stall |d_stall;

	//assign pcnewM = (excepttypeM != 32'b0)?( (excepttypeM==32'h0000_000e)?epc_o:32'hbfc0_0380) :32'h0;
	assign pcnewM = (excepttypeM == 32'h0000_0001) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_0004) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_0005) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_0008) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_0009) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_000a) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_000c) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_000d) ? 32'hBFC00380:
					(excepttypeM == 32'h0000_000e) ? epc_o:
					pcnewM;
endmodule