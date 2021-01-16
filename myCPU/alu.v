`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/03 15:49:59
// Design Name: 
// Module Name: alu
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

module alu(
    input wire clk,rst,
    input wire [31:0] srca,srcb,
    input wire [7:0] op,
    input wire [4:0] sa,
    input wire [63:0] hilo_in,
    input wire [31:0] cp0data,
    output reg [31:0] result,
    output reg [63:0] hilo_out,
    output wire overflow,
    output reg stall_div
    );


    reg [31:0] temp_srcb;
    reg [31:0] temp_result;

    //乘法相关
    wire [31:0] mult_a,mult_b;
    wire [63:0] hilo_temp;
    wire [63:0] div_result;
    assign mult_a = ((op==`EXE_MULT_OP)&&(srca[31]==1'b1))?(~srca+1):srca;
    assign mult_b = ((op==`EXE_MULT_OP)&&(srcb[31]==1'b1))?(~srcb+1):srcb;
    assign hilo_temp = ((op==`EXE_MULT_OP)&&(srca[31]^srcb[31] == 1'b1)) ? ~(mult_a*mult_b)+1 : mult_a*mult_b;


    //除法相关
    reg signed_div;
    reg start_div;
    wire div_ready;
    div module_div (
        .clk(clk),
        .rst(rst),
        .signed_div_i(signed_div),
        .opdata1_i(srca),
        .opdata2_i(srcb),
        .start_i(start_div),
        .annul_i(1'b0),
        .result_o(div_result),
        .ready_o(div_ready)
        );
    always @(*) begin
        case(op)
            `EXE_DIV_OP: begin
                if(div_ready == 1'b0) begin
                    start_div <= 1'b1;
                    signed_div <= 1'b1;
                    stall_div <=1'b1;
                end
                else if (div_ready == 1'b1) begin
                    start_div <= 1'b0;
                    signed_div <= 1'b1;
                    stall_div <=1'b0;
                end
                else begin
                    start_div <= 1'b0;
                    signed_div <= 1'b0;
                    stall_div <=1'b0;
                end
            end
            `EXE_DIVU_OP: begin
                if(div_ready == 1'b0) begin
                    start_div <= 1'b1;
                    signed_div <= 1'b0;
                    stall_div <=1'b1;
                end
                else if (div_ready == 1'b1) begin
                    start_div <= 1'b0;
                    signed_div <= 1'b0;
                    stall_div <=1'b0;
                end
                else begin
                    start_div <= 1'b0;
                    signed_div <= 1'b0;
                    stall_div <=1'b0;
                end
            end
            default:begin
                start_div <= 1'b0;
                signed_div <= 1'b0;
                stall_div <=1'b0;
            end
    endcase
    end
    

    //hilo_out的输出
    always @(*) begin
        case(op)
            `EXE_MTHI_OP: hilo_out <= {srca[31:0],{hilo_in[31:0]}};
            `EXE_MTLO_OP: hilo_out <= {{hilo_in[63:32]},srca[31:0]};
            `EXE_MULT_OP: hilo_out <= hilo_temp;
            `EXE_MULTU_OP: hilo_out <= srca * srcb;
            `EXE_DIV_OP: hilo_out <= div_result;
            `EXE_DIVU_OP: hilo_out <= div_result;
        default: hilo_out <= 64'b0;
        endcase
    end



    always @(*) begin
        case(op)

            //exception 
            `EXE_MFC0_OP:result <= cp0data;
            `EXE_MTC0_OP:result <= srcb;
            //logic inst
            `EXE_AND_OP: result <= srca & srcb;
            `EXE_OR_OP: result <= srca | srcb;
            `EXE_XOR_OP: result <= srca ^ srcb;
            `EXE_NOR_OP: result <= ~(srca|srcb);
            `EXE_ANDI_OP: result <= srca & srcb;
            `EXE_ORI_OP: result <= srca | srcb;
            `EXE_XORI_OP: result <= srca ^ srcb;
            `EXE_LUI_OP: result <= {srcb[15:0],16'b0};

            //shift inst
            `EXE_SLL_OP: result <= srcb << sa;
            `EXE_SLLV_OP: result <= srcb << srca[4:0];
            `EXE_SRL_OP: result <= srcb >> sa;
            `EXE_SRLV_OP: result <= srcb >> srca[4:0];
            `EXE_SRA_OP: result <= ({32{srcb[31]}} << (6'd32-{1'b0,sa})) | srcb >> sa;
            `EXE_SRAV_OP: result <= ({32{srcb[31]}} << (6'd32-{1'b0,srca[4:0]})) | srcb >> srca[4:0];

            //move inst
            `EXE_MFHI_OP: result <= hilo_in[63:32];
            `EXE_MFLO_OP: result <= hilo_in[31:0];
            `EXE_MTHI_OP: result <= srcb;
            `EXE_MTLO_OP: result <= srcb;


            //load and store inst
            `EXE_LB_OP: result <= srca + srcb;
            `EXE_LBU_OP: result <= srca + srcb;
            `EXE_LH_OP: result <= srca + srcb;
            `EXE_LHU_OP: result <= srca + srcb;
            `EXE_LW_OP: result <= srca + srcb;
            `EXE_SB_OP: result <= srca + srcb;
            `EXE_SH_OP: result <= srca + srcb;
            `EXE_SW_OP: result <= srca + srcb;

            //arithmetic inst
            `EXE_ADD_OP: result <= srca + srcb;
            `EXE_ADDU_OP: result <= srca + srcb;
            `EXE_ADDI_OP: result <= srca + srcb;
            `EXE_ADDIU_OP: result <= srca + srcb;
            `EXE_SUB_OP: result <= srca - srcb;
            `EXE_SUBU_OP: result <= srca - srcb;
            `EXE_SLTI_OP: /*begin
                temp_srcb <= ~srcb + 1'b1;
                temp_result <= srca + temp_srcb;
                if(temp_result[31]==0)
                    result <= 0;
                else
                    result <= 1;
            end*/
                begin 
                    if(srca[31]==0)begin
                        if(srcb[31]==1)begin
                            result <= 0;
                        end
                        else if(srca < srcb)begin
                            result <= 1;
                        end
                        else begin
                            result<=0;
                        end
                    end
                    else 
                        begin
                        if(srcb[31]==0)begin
                            result<=1;
                        end
                        else if(srca<srcb)begin
                            result<=1;
                        end
                        else begin
                            result<=0;
                        end
                        end
                end
            `EXE_SLTIU_OP: begin
                if(srca < srcb)
                    result <= 1;
                else
                    result <= 0;
            end
            `EXE_SLT_OP: /*begin
                temp_srcb <= ~srcb + 1'b1;
                temp_result <= srca + temp_srcb;
                if(temp_result[31]==0)
                    result <= 0;
                else
                    result <= 1;
            end*/
            begin 
                    if(srca[31]==0)begin
                        if(srcb[31]==1)begin
                            result <= 0;
                        end
                        else if(srca < srcb)begin
                            result <= 1;
                        end
                        else begin
                            result<=0;
                        end
                    end
                    else 
                        begin
                        if(srcb[31]==0)begin
                            result<=1;
                        end
                        else if(srca<srcb)begin
                            result<=1;
                        end
                        else begin
                            result<=0;
                        end
                        end
                end
            `EXE_SLTU_OP: begin
                if(srca<srcb)
                    result <= 1;
                else
                    result <= 0;
            end
            
        default: result <= 32'h00000000;
    endcase

    end

   //只有add,addi,sub考虑溢出
assign overflow = ((op==`EXE_ADD_OP)|(op==`EXE_ADDI_OP))?((srca[31] & srcb[31] & ~result[31] )|( ~srca[31] & ~srcb[31] & result[31])):
                    (op==`EXE_SUB_OP)?((srca[31] & ~srcb[31]& ~result[31])| (~srca[31] & srcb[31] & result[31])):
                    1'b0;

endmodule



/*wire[31:0] s,bout;
	assign bout = op[2] ? ~srcb : srcb;    //如果为减法，则srcb取反
	assign s = srca + bout + op[2];
    
    always @(*) begin 
            case(op)
                3'b000:result = srca & srcb;
                3'b001:result = srca | srcb;
                3'b010:result = srca + srcb;
                3'b100:result = srca & ~srcb;
                3'b101:result = srca | ~srcb;
                3'b110:result = srca - srcb;
                3'b111:result = (srca < srcb) ? 1:0;
                default:result = 32'b0;
            endcase
        end
    assign zero = (srca == srcb) ? 1 : 0;
    
    always @(*) begin
        case (op[2:1])
			2'b01:overflow <= srca[31] & srcb[31] & ~s[31] |
							~srca[31] & ~srcb[31] & s[31];
			2'b11:overflow <= srca[31] & srcb[31] & ~s[31] |
							~srca[31] & ~srcb[31] & s[31];
			default : overflow <= 1'b0;
		endcase
	end*/
