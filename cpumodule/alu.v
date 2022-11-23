`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/01 18:09:16
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
`include "E:/eeic/eeic3A/cpu/b3exp/cpumodule/define.vh"

module alu(
    input clk, nrst,
    input wire [5:0] alucode,       // 演算種別
    input wire [31:0] op1,          // 入力データ1
    input wire [31:0] op2,          // 入力データ2\
    output reg [31:0] alu_result,   // 演算結果
    output br_taken             // 分岐の有無
);
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            alu_result <= 0;
        end else begin
            alu_result <= alu(alucode, op1, op2);
        end
    end
    assign br_taken = br(alucode, op1, op2);
    function [31:0] alu;
        input [5:0] alucode;
        input [31:0] op1;
        input [31:0] op2;
        case (alucode)
            `ALU_ADD: alu = op1 + op2;
            `ALU_SUB: alu = op1 - op2;
            `ALU_SLT: alu = ($signed(op1) < $signed(op2)) ? 1 : 0;
            `ALU_SLTU: alu = (op1 < op2) ? 1 : 0;
            `ALU_XOR: alu = op1 ^ op2;
            `ALU_OR: alu = op1 | op2;
            `ALU_AND: alu = op1 & op2;
            `ALU_SLL: alu = op1 << op2[4:0];
            `ALU_SRL: alu = op1 >> op2[4:0];
            `ALU_SRA: alu = $signed(op1) >>> op2[4:0];
            `ALU_LUI: alu = op2;
            `ALU_JALR: alu = op2 + 4;
            `ALU_JAL: alu = op2 + 4;
            `ALU_BEQ, `ALU_BNE, `ALU_BLT, `ALU_BGE, `ALU_BLTU, `ALU_BGEU: alu = 32'b0;
            `ALU_SB, `ALU_SH, `ALU_SW: alu = op1 + op2;
            `ALU_LB, `ALU_LBU, `ALU_LH, `ALU_LHU, `ALU_LW: alu = op1 + op2;
            default: alu = 32'b0;
        endcase
    endfunction

    function br;
        input [5:0] alucode;
        input [31:0] op1, op2;
        br = (((alucode == `ALU_BEQ) && (op1 == op2)) ||
             ((alucode == `ALU_BNE) && (op1 != op2)) ||
             ((alucode == `ALU_BLT) && ($signed(op1) < $signed(op2))) ||
             ((alucode == `ALU_BGE) && ($signed(op1) >= $signed(op2))) ||
             ((alucode == `ALU_BLTU) && (op1 < op2)) ||
             ((alucode == `ALU_BGEU) && (op1 >= op2)) || (alucode == `ALU_JAL) || (alucode == `ALU_JALR)) ? `ENABLE : `DISABLE;
    endfunction

endmodule

    