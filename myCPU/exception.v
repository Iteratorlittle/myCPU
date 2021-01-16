`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/04 08:17:46
// Design Name: 
// Module Name: exception
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


module exception(
    input wire rst,
    input wire [7:0] except,
    input wire ades,adel,
    input wire [31:0] cp0_status,cp0_cause,
    output reg [31:0] excepttype
    );

    always @(*) begin
        if(rst) begin
            excepttype <= 32'b0;
        end
        else begin
            excepttype <= 32'b0;
            if ( ((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&
                    (cp0_status[1] == 1'b0 ) && (cp0_status[0]==1'b1) ) begin

                excepttype <= 32'h0000_0001;
                end
            else if(except[7]==1'b1 || adel) begin
                excepttype <= 32'h0000_0004;//取指或取数据地址错意外,adel,
            end
            else if(ades) begin//Data address error
                excepttype <= 32'h0000_0005;//写数据地址错意外，ades
            end
            else if(except[6]==1'b1) begin
                excepttype <= 32'h0000_0008;//系统调用例外
            end
            else if (except[5]==1'b1) begin
                excepttype <= 32'h0000_0009;//断点例外,break
            end
            else if (except[4]==1'b1) begin
                excepttype <= 32'h0000_000e;//eret
            end
            else if (except[3]==1'b1) begin//RI(Invalid)
                excepttype <= 32'h0000_000a;//保留指令例外
            end
            else if (except[2]==1'b1) begin//overflow
                excepttype <= 32'h0000_000c;//整型溢出例外
            end
        end
    end
endmodule
