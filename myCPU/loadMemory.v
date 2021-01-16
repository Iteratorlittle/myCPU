`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 12:32:20
// Design Name: 
// Module Name: loadMemory
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

`include "defines.vh"
module loadMemory(
    input wire [31:0] pc,
    input wire [31:0] addr,
    input wire [5:0] op,
    input wire [31:0] readdata, //从数据存储器中读出的值
    input wire [31:0] writedata,//要写入数据存储器的值
    output reg [31:0] final_readd,//经过字节选择后最终写入regfile的值
    output reg [31:0] final_writed,//经过字节选择后最终要写入data_ram的值
    output reg [3:0] memsel,
    output wire adesM,adelM,
    output wire [31:0] bad_addr //不存在的地址
    );


assign adesM = ((op==`EXE_SH)&&(addr[0]!=0))?1'b1:
                ((op==`EXE_SW)&&(addr[1:0]!=2'b00))?1'b1:
                1'b0; 

assign adelM = ((op==`EXE_LH|op==`EXE_LHU)&&(addr[0]!=0))?1'b1:
                ((op==`EXE_LW)&&(addr[1:0]!=2'b00))?1'b1:
                1'b0; 

assign bad_addr = ((op==`EXE_LH|op==`EXE_LHU|op==`EXE_SH)&&(addr[0]!=0))?addr:
                    ((op==`EXE_LW|op==`EXE_SW)&&(addr[1:0]!=2'b00))?addr:
                    pc; 

always @(*) begin
    case (op)
        `EXE_SW: memsel <= 4'b1111;
        `EXE_SB: 
            case(addr[1:0])
                2'b11: memsel <= 4'b1000;
                2'b10: memsel <= 4'b0100;
                2'b01: memsel <= 4'b0010;
                2'b00: memsel <= 4'b0001;
            endcase
        `EXE_SH:
            case (addr[1:0])
                2'b10: memsel <= 4'b1100;
                2'b00: memsel <= 4'b0011;
                default: memsel <= 4'b0000;
            endcase
        default: memsel <= 4'b0000;
    endcase
end



always @(*) begin
    case (op)
        `EXE_SB: final_writed <= {4{writedata[7:0]}};
        `EXE_SH: final_writed <= {2{writedata[15:0]}};
        `EXE_SW: final_writed <= writedata;
        default: final_writed <= writedata;
    endcase
end

always @(*) begin
    case (op)
        `EXE_LB:
            case (addr[1:0])
                2'b00: final_readd <={{24{readdata[7]}},readdata[7:0]};
                2'b01: final_readd <={{24{readdata[15]}},readdata[15:8]};
                2'b10: final_readd <={{24{readdata[23]}},readdata[23:16]};
                2'b11: final_readd <={{24{readdata[31]}},readdata[31:24]};
                default: final_readd <= readdata;
            endcase
        `EXE_LBU:
            case (addr[1:0])
                2'b00: final_readd <={{24{1'b0}},readdata[7:0]};
                2'b01: final_readd <={{24{1'b0}},readdata[15:8]};
                2'b10: final_readd <={{24{1'b0}},readdata[23:16]};
                2'b11: final_readd <={{24{1'b0}},readdata[31:24]};
                default: final_readd <= readdata;
            endcase
        `EXE_LH:
            case (addr[1:0])
                2'b00: final_readd <={{16{readdata[15]}},readdata[15:0]};
                2'b10: final_readd <={{16{readdata[31]}},readdata[31:16]};
                default: final_readd <= readdata;
            endcase
        `EXE_LHU:
            case (addr[1:0])
                2'b00: final_readd <={{16{1'b0}},readdata[15:0]};
                2'b10: final_readd <={{16{1'b0}},readdata[31:16]};
                default: final_readd <= readdata;
            endcase
        `EXE_LW:
            final_readd <= readdata;
        default: final_readd <= readdata;
    endcase
end
endmodule
