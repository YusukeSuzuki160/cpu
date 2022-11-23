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
`include "E:/eeic/eeic3A/cpu/b3exp/cpumoduleneo/define.vh"

module decoder(
    input  wire [31:0]  ir,           // 機械語命令列
    output wire  [4:0]	srcreg1_num,  // ソースレジスタ1番号
    output wire  [4:0]	srcreg2_num,  // ソースレジスタ2番号
    output wire  [4:0]	dstreg_num,   // デスティネーションレジスタ番号
    output wire [31:0]	imm,          // 即値
    output wire   [5:0]	alucode,      // ALUの演算種別
    output wire   [1:0]	aluop1_type,  // ALUの入力タイプ
    output wire   [1:0]	aluop2_type,  // ALUの入力タイプ
    output wire	     	reg_we,       // レジスタ書き込みの有無
    output wire		is_load,      // ロード命令判定フラグ
    output wire		is_store,     // ストア命令判定フラグ
    output wire          is_halt
);
    wire [6:0] op_code;
    wire [2:0] in_op_type;
    
    
    assign dstreg_num = (op_code == `BRANCH || op_code == `STORE) ? 0 : ir[11:7];
    assign srcreg1_num = (op_code == `LUI || op_code == `AUIPC || op_code == `JAL) ? 0 : ir[19:15];
    assign srcreg2_num = (op_code == `OPIMM || op_code == `LUI || op_code == `AUIPC || op_code == `JAL || op_code == `JALR || op_code == `LOAD) ? 0 : ir[24:20];
    assign op_code = ir[6:0];
    assign in_op_type = ir[14:12];
    assign imm = gen_imm(ir, in_op_type, op_code);
    
    assign alucode = gen_alucode(ir, op_code, in_op_type);
    assign reg_we = (op_code == `BRANCH || op_code == `STORE || (op_code == `JAL && dstreg_num == 0) || (op_code == `JALR && dstreg_num == 0) || dstreg_num == 0) ? `DISABLE : `ENABLE;
    assign is_load = (op_code == `LOAD) ? `ENABLE : `DISABLE;
    assign is_store = (op_code == `STORE) ? `ENABLE : `DISABLE;
    assign is_halt = (op_code == `BRANCH || op_code == `JAL || op_code == `JALR) ? `ENABLE : `DISABLE;
    assign aluop1_type = (op_code == `OP || op_code == `OPIMM || op_code == `JALR || op_code == `BRANCH || op_code == `STORE || op_code == `LOAD) ? `OP_TYPE_REG : (op_code == `AUIPC ? `OP_TYPE_IMM : `OP_TYPE_NONE);
    assign aluop2_type = (op_code == `OP || op_code == `BRANCH) ? `OP_TYPE_REG : ((op_code == `OPIMM || op_code == `LOAD || op_code == `LUI || op_code == `STORE) ? `OP_TYPE_IMM : ((op_code == `AUIPC || op_code == `JAL || op_code == `JALR) ? `OP_TYPE_PC : `OP_TYPE_NONE));
    
    
    function [31:0] gen_imm;
        input [31:0] ir;
        input [2:0] in_op_type;
        input [6:0] op_code;
        case (op_code)
            `OPIMM: begin
                if (in_op_type == 3'b000 || in_op_type == 3'b010 || in_op_type == 3'b011 || in_op_type == 3'b100 || in_op_type == 3'b110 || in_op_type == 3'b111) begin
                    gen_imm = {{20{ir[31]}}, ir[31:20]};
                end else begin
                    gen_imm = {27'd0, ir[24:20]};
                end
            end
            `LUI, `AUIPC: begin
                gen_imm = {ir[31:12], 12'd0};
            end
            `JAL: begin
                gen_imm = {{11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0};
            end
            `JALR: begin
                gen_imm = {{20{ir[31]}}, ir[31:20]};
            end
            `BRANCH: begin
                gen_imm = {{19{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8], 1'b0};
            end
            `STORE: begin
                gen_imm = {{20{ir[31]}}, ir[31:25], ir[11:7]};
            end
            `LOAD: begin
                gen_imm = {{20{ir[31]}}, ir[31:20]};
            end
            default: begin
                gen_imm = 32'd0;
            end
        endcase
    endfunction


    function [5:0] gen_alucode;
        input [31:0] ir;
        input [6:0] op_code;
        input [2:0] in_op_type;
        case (op_code)
            `OPIMM: begin
                if (in_op_type == 3'b000) begin
                    gen_alucode = `ALU_ADD;
                end else if (in_op_type == 3'b010) begin
                    gen_alucode = `ALU_SLT;
                end else if (in_op_type == 3'b011) begin
                    gen_alucode = `ALU_SLTU;
                end else if (in_op_type == 3'b100) begin
                    gen_alucode = `ALU_XOR;
                end else if (in_op_type == 3'b110) begin
                    gen_alucode = `ALU_OR;
                end else if (in_op_type == 3'b111) begin
                    gen_alucode = `ALU_AND;
                end else if (in_op_type == 3'b001) begin
                    gen_alucode = `ALU_SLL;
                end else if (in_op_type == 3'b101) begin
                    if (ir[30] == 1'b0) begin
                        gen_alucode = `ALU_SRL;
                    end else begin
                        gen_alucode = `ALU_SRA;
                    end
                end else begin
                    gen_alucode = `ALU_NOP;
                end
            end
            `OP: begin
                if (in_op_type == 3'b000) begin
                    if (ir[30] == 1'b0) begin
                        gen_alucode = `ALU_ADD;
                    end else begin
                        gen_alucode = `ALU_SUB;
                    end
                end else if (in_op_type == 3'b010) begin
                    gen_alucode = `ALU_SLT;
                end else if (in_op_type == 3'b011) begin
                    gen_alucode = `ALU_SLTU;
                end else if (in_op_type == 3'b100) begin
                    gen_alucode = `ALU_XOR;
                end else if (in_op_type == 3'b110) begin
                    gen_alucode = `ALU_OR;
                end else if (in_op_type == 3'b111) begin
                    gen_alucode = `ALU_AND;
                end else if (in_op_type == 3'b001) begin
                    gen_alucode = `ALU_SLL;
                end else if (in_op_type == 3'b101) begin
                    if (ir[30] == 1'b0) begin
                        gen_alucode = `ALU_SRL;
                    end else begin
                        gen_alucode = `ALU_SRA;
                    end
                end else begin
                    gen_alucode = `ALU_NOP;
                end
            end
            `LUI: begin
                gen_alucode = `ALU_LUI;
            end
            `AUIPC: begin
                gen_alucode = `ALU_ADD;
            end
            `JAL: begin
                gen_alucode = `ALU_JAL;
            end
            `JALR: begin
                gen_alucode = `ALU_JALR;
            end
            `BRANCH: begin
                if (in_op_type == 3'b000) begin
                    gen_alucode = `ALU_BEQ;
                end else if (in_op_type == 3'b001) begin
                    gen_alucode = `ALU_BNE;
                end else if (in_op_type == 3'b100) begin
                    gen_alucode = `ALU_BLT;
                end else if (in_op_type == 3'b101) begin
                    gen_alucode = `ALU_BGE;
                end else if (in_op_type == 3'b110) begin
                    gen_alucode = `ALU_BLTU;
                end else if (in_op_type == 3'b111) begin
                    gen_alucode = `ALU_BGEU;
                end else begin
                    gen_alucode = `ALU_NOP;
                end
            end
            `STORE: begin
                if (in_op_type == 3'b000) begin
                    gen_alucode = `ALU_SB;
                end else if (in_op_type == 3'b001) begin
                    gen_alucode = `ALU_SH;
                end else if (in_op_type == 3'b010) begin
                    gen_alucode = `ALU_SW;
                end else begin
                    gen_alucode = `ALU_NOP;
                end
            end
            `LOAD: begin
                if (in_op_type == 3'b000) begin
                    gen_alucode = `ALU_LB;
                end else if (in_op_type == 3'b001) begin
                    gen_alucode = `ALU_LH;
                end else if (in_op_type == 3'b010) begin
                    gen_alucode = `ALU_LW;
                end else if (in_op_type == 3'b100) begin
                    gen_alucode = `ALU_LBU;
                end else if (in_op_type == 3'b101) begin
                    gen_alucode = `ALU_LHU;
                end else begin
                    gen_alucode = `ALU_NOP;
                end
            end
            default: begin
                gen_alucode = `ALU_NOP;
            end
        endcase
    endfunction


endmodule
