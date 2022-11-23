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
module neocpu(
    input sysclk, cpu_resetn,
    output uart_tx
    );
    reg [31:0] pc;
    reg start;
    reg [1:0] p_wait;
    assign uart_tx = uart_OUT_data;

    // for fetch //
    reg [31:0] pc_fetch;
    wire [31:0] inst;
    reg [31:0] inst_reg;
    reg state_fetch, state_fetch_saved;

    // for decode //
    reg [31:0] pc_decode;
    reg [4:0] rd_addr_reg, r1_addr_reg, r2_addr_reg;
    wire [4:0] r1_addr, r2_addr, rd_addr;
    reg [5:0] alucode_reg;
    wire [5:0] alucode;
    reg [1:0] type1_reg, type2_reg;
    wire [1:0] aluop1_type, aluop2_type;
    reg p_reg_we, p_is_load, p_is_store, p_is_halt;
    wire reg_we, is_load, is_store, is_halt;
    reg [31:0] r1_reg, r2_reg, imm_reg;
    wire [31:0] imm, r1_data, r2_data;
    reg state_decode, state_decode_saved, is_halt_saved;

    // for execute //
    reg [31:0] pc_execute;
    reg [31:0] r2_execute;
    wire [31:0] op1, op2;
    wire [31:0] alu_result;
    wire [31:0] nextpc;
    reg reg_we_execute, is_load_execute, is_store_execute;
    reg [5:0] alucode_execute;
    reg [4:0] rd_addr_execute;
    reg state_execute, state_execute_saved;
    // forwarding //
    reg [31:0] data_back1, data_back2, data_back3;
    reg [4:0] addr_back1, addr_back2, addr_back3;
    wire [31:0] data_back_execute;
    wire [4:0] addr_back_execute;
    wire [31:0] r1_forward, r2_forward;
    assign addr_back_execute = (reg_we_execute) ? rd_addr_execute : 5'b0;
    assign data_back_execute = alu_result;

    assign r1_forward = (addr_back1 == r1_addr_reg && addr_back1 !== 5'b0) ? data_back1 : ((addr_back2 == r1_addr_reg && addr_back2 !== 5'b0) ? data_back2 : r1_reg);
    assign r2_forward = (addr_back1 == r2_addr_reg && addr_back1 !== 5'b0) ? data_back1 : ((addr_back2 == r2_addr_reg && addr_back2 !== 5'b0) ? data_back2 : r2_reg);

    assign op1 = (type1_reg == `OP_TYPE_REG) ? r1_forward : ((type1_reg == `OP_TYPE_IMM) ? imm_reg : (type1_reg == `OP_TYPE_PC ? pc_decode : 32'b0)); //op switcher
    assign op2 = (type2_reg == `OP_TYPE_REG) ? r2_forward : ((type2_reg == `OP_TYPE_IMM) ? imm_reg : (type2_reg == `OP_TYPE_PC ? pc_decode : 32'b0)); //op switcher

    // for memory //
    reg [31:0] pc_memory;
    reg is_load_memory;
    wire [31:0] mem_address;
    wire [31:0] mem_w_data;
    wire [31:0] mem_r_data, load_value, hc_OUT_data;
    wire uart_OUT_data;
    reg reg_we_memory;
    reg [5:0] alucode_memory;
    reg [31:0] alu_result_memory;
    reg [4:0] rd_addr_memory;
    assign mem_address = alu_result - 32'h10000;
    assign mem_w_data = r2_execute;
    reg state_memory;
    wire [31:0] result_data;
    wire [31:0] data_back_memory;
    wire [4:0] addr_back_memory;
    assign addr_back_memory = (reg_we_execute) ? rd_addr_execute : 5'b0;
    assign data_back_memory = result_data;
    assign load_value = ((alucode_execute == `ALU_LW) && (alu_result == `HARDWARE_COUNTER_ADDR)) ? hc_OUT_data : mem_r_data;
    assign result_data = (is_load_execute) ? load_value : alu_result;

    // for writeback //
    wire [31:0] wb_data;
    reg state_writeback;
    assign wb_data = result_data;


    // for fetch //
    memory_fetch fetch1(
        .clk(sysclk),
        .nrst(cpu_resetn),
        .r_addr(pc),
        .state(state_fetch),
        .r_data(inst)
    );

    // for decode //
    decoder decoder1(
        .ir(inst),
        .srcreg1_num(r1_addr),
        .srcreg2_num(r2_addr),
        .dstreg_num(rd_addr),
        .imm(imm),
        .alucode(alucode),
        .aluop1_type(aluop1_type),
        .aluop2_type(aluop2_type),
        .reg_we(reg_we),
        .is_load(is_load),
        .is_store(is_store),
        .is_halt(is_halt)
    );

    register_file regfile1(
        .clk(sysclk),
        .nrst(cpu_resetn),
        .we(reg_we_execute),
        .r_addr1(r1_addr),
        .r_addr2(r2_addr),
        .w_addr(rd_addr_execute),
        .w_data(wb_data),
        .state1(state_decode),
        .state2(state_writeback),
        .r_data1(r1_data),
        .r_data2(r2_data)
    );

    // for execute //
    execute execute1(
        .clk(sysclk),
        .nrst(cpu_resetn),
        .alucode(alucode_reg),
        .op1(op1),
        .op2(op2),
        .imm(imm_reg),
        .pc(pc_fetch),
        .alu_result(alu_result),
        .nextpc(nextpc)
    );

    // for memory //
    load_store memory(
        .clk(sysclk),
        .nrst(cpu_resetn),
        .address(mem_address),
        .alucode(alucode_execute),
        .w_data(mem_w_data),
        .is_load(is_load_execute),
        .is_store(is_store_execute),
        .state(state_execute),
        .r_data(mem_r_data),
        .uart_tx(uart_OUT_data)
    );

    hardware_counter hardware_counter0(
        .CLK_IP(sysclk),
        .RSTN_IP(cpu_resetn),
        .COUNTER_OP(hc_OUT_data)
    );
    
    always @(posedge sysclk or negedge cpu_resetn) begin
        if (!cpu_resetn) begin
            inst_reg <= 32'b0;
            rd_addr_reg <= 5'b0;
            alucode_reg <= 6'b0;
            type1_reg <= 2'b0;
            type2_reg <= 2'b0;
            p_reg_we <= 1'b0;
            p_is_load <= 1'b0;
            p_is_store <= 1'b0;
            r1_reg <= 32'b0;
            r2_reg <= 32'b0;
            imm_reg <= 32'b0;
            r1_addr_reg <= 5'b0;
            r2_addr_reg <= 5'b0;
            reg_we_execute <= 1'b0;
            is_load_execute <= 1'b0;
            is_store_execute <= 1'b0;
            alucode_execute <= 6'b0;
            rd_addr_execute <= 5'b0;
            reg_we_memory <= 1'b0;
            rd_addr_memory <= 5'b0;
            alucode_memory <= 6'b0;
            alu_result_memory <= 32'b0;
            start <= 1'b0;
        end else begin
            start <= 1'b1;
            if (state_fetch == `ENABLE) begin
                inst_reg <= inst;
            end
            // decode //
            if (state_execute == `ENABLE) begin
                rd_addr_reg <= rd_addr;
                alucode_reg <= alucode;
                type1_reg <= aluop1_type;
                type2_reg <= aluop2_type;
                p_reg_we <= reg_we;
                p_is_load <= is_load;
                p_is_store <= is_store;
                r1_reg <= r1_data;
                r2_reg <= r2_data;
                r1_addr_reg <= r1_addr;
                r2_addr_reg <= r2_addr;
                imm_reg <= imm;
            end
            // execute //
            if (state_memory == `ENABLE) begin
                reg_we_execute <= p_reg_we;
                is_load_execute <= p_is_load;
                is_store_execute <= p_is_store;
                alucode_execute <= alucode_reg;
                rd_addr_execute <= rd_addr_reg;
                r2_execute <= r2_forward;
                //result_data <= (is_load_execute) ? load_value : alu_result;
            end
            
            // memory //
            //if (state_writeback == `ENABLE) begin
                reg_we_memory <= reg_we_execute;
                rd_addr_memory <= rd_addr_execute;   
                alucode_memory <= alucode_execute;
                alu_result_memory <= alu_result;
                is_load_memory <= is_load_execute;      
            //end
        end
    end

    always @(negedge sysclk or negedge cpu_resetn) begin
        if (!cpu_resetn) begin
            state_fetch <= `ENABLE;
            state_decode <= `ENABLE;
            state_execute <= `ENABLE;
            state_memory <= `ENABLE;
            state_writeback <= `ENABLE;
            state_fetch_saved <= `ENABLE;
            state_decode_saved <= `ENABLE;
            state_execute_saved <= `ENABLE;

            pc <= 32'h08000;
            pc_fetch <= 32'h08000;
            pc_decode <= 32'h08000;
            pc_execute <= 32'h08000;
            pc_memory <= 32'h08000;
            p_wait <= 2'b0;
            //l_wait <= 1'b0;
            is_halt_saved <= `DISABLE;
            addr_back1 <= 5'h0;
            addr_back2 <= 5'h0;
            addr_back3 <= 5'h0;
            data_back1 <= 32'h0;
            data_back2 <= 32'h0;
            data_back3 <= 32'h0;
        end else begin
            if (start == 1'b1) begin
                if (state_fetch == `ENABLE && is_halt == `ENABLE) begin
                    p_wait <= 2'b1;
                    state_fetch <= `DISABLE;
                    state_execute <= `ENABLE;
                    pc <= pc;
                end else if (p_wait == 2'b1) begin
                    p_wait <= 2'd2;
                    state_fetch <= state_fetch;
                    state_execute <= state_execute;
                    pc <= pc;
                end else if (p_wait == 2'd2) begin
                    p_wait <= 2'b0;
                    state_fetch <= `ENABLE;
                    //state_decode <= `DISABLE;
                    state_execute <= `DISABLE;
                    pc <= nextpc;
                end else begin
                    state_fetch <=`ENABLE;
                    state_execute <= state_fetch;
                    pc <= pc + 4;
                end
                state_memory <= state_execute;
                state_writeback <= state_execute;
                // forwarding //
                if (state_execute == `ENABLE) begin
                    addr_back1 <= (is_load_execute) ? addr_back_memory : addr_back_execute;
                    addr_back2 <= addr_back1;
                    //addr_back3 <= addr_back2;
                    data_back1 <= (is_load_execute) ? data_back_memory : data_back_execute;
                    data_back2 <= data_back1;
                    //data_back3 <= data_back2;
                end
                if (state_fetch == `ENABLE) begin
                    pc_fetch <= pc;
                end
                if (state_decode == `ENABLE) begin
                    pc_decode <= pc_fetch;
                end
                if (state_execute == `ENABLE) begin
                    pc_execute <= pc_decode;
                end
                if (state_memory == `ENABLE) begin
                    pc_memory <= pc_execute;
                end
            end
            

        end
    end
   


endmodule
