`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/01 13:19:54
// Design Name: 
// Module Name: decoder
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
`include "E:/eeic/eeic3A/cpu/b3exp/cpumodule/define.vh"

module execute (
    input clk, nrst,
    input [5:0] alucode,
    input [31:0] op1, op2, imm, pc,
    output [31:0] alu_result,
    output [31:0] nextpc
    );
    wire br_taken;
    alu alu1(
        .clk(clk),
        .nrst(nrst),
        .alucode(alucode),
        .op1(op1),
        .op2(op2),
        .alu_result(alu_result),
        .br_taken(br_taken)
    );
    reg [5:0] alucode_reg;
    reg [31:0] op1_reg, imm_reg, pc_reg;
    always @(posedge clk) begin
        if (!nrst) begin
            alucode_reg <= 6'b0;
            op1_reg <= 32'b0;
            imm_reg <= 32'b0;
            pc_reg <= 32'h08000;
        end
        else begin
            alucode_reg <= alucode;
            op1_reg <= op1;
            imm_reg <= imm;
            pc_reg <= pc;
        end
    end
    
    assign nextpc = (br_taken == `ENABLE && alucode_reg == `ALU_JALR) ? op1_reg + imm_reg : ((br_taken == `ENABLE ? pc_reg + imm_reg : pc_reg + 4));
    
endmodule