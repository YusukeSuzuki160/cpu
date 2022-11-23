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

module load_store(
    input clk, nrst,
    input [31:0] address,
    input [5:0] alucode,
    input [31:0] w_data,
    input is_load, is_store, state,
    output [31:0] r_data,
    output uart_tx
    );

    wire [31:0] add_word;
    reg [31:0] add_reg;
    wire is_signed;
    reg is_load_reg, is_signed_reg;
    wire [1:0] add_mod4;
    reg [1:0] reg_mod4;
    wire [3:0] we, re;
    reg [3:0] re_reg;
    wire [31:0] r_data_raw, r_data_selected, loaded_r_data;
    wire [31:0] w_data_selected;
    wire [7:0] uart_IN_data;
    wire uart_we;
    wire uart_OUT_data;

    assign is_signed = (alucode == `ALU_LB || alucode == `ALU_LH) ? `ENABLE : `DISABLE; // load signed
    assign re = (alucode == `ALU_LB || alucode == `ALU_LBU) ? 4'b0001 : ((alucode == `ALU_LH || alucode == `ALU_LHU) ? 4'b0011 : ((alucode == `ALU_LW) ? 4'b1111 : 4'b0000)); // load signed
    assign add_word = address >> 2;
    assign add_mod4 = address[1:0];
    assign we = gen_we(alucode, add_mod4);
    assign r_data_selected = select_data_r(r_data_raw, add_mod4);
    assign loaded_r_data = load_data(r_data_selected, add_mod4, re, is_signed);
    assign r_data = (is_load) ? loaded_r_data : 32'b0;
    assign w_data_selected = select_data_w(w_data, add_mod4);
    assign uart_IN_data = w_data[7:0];  // ストアするデータをモジュールへ入力
    assign uart_we = ((address + 32'h10000 == `UART_ADDR) && (is_store == `ENABLE)) ? 1'b1 : 1'b0;  // シリアル通信用アドレスへのストア命令実行時に送信開始信号をアサート
    assign uart_tx = uart_OUT_data;  // モジュールからの出力をシリアル通信用出力へ出力


    /*always @(posedge clk) begin
        re_reg <= re;
        add_reg <= add_word;
        reg_mod4 <= add_mod4;
        is_load_reg <= is_load;
        is_signed_reg <= is_signed;
    end*/
    
    memory_data dm1(
        .clk(clk),
        .r_addr(add_word),
        .w_addr(add_word),
        .w_data(w_data_selected),
        .we(we),
        .state(state),
        .r_data(r_data_raw)
    );
    

    uart uart0(
        .uart_tx(uart_OUT_data),
        .uart_wr_i(uart_we),
        .uart_dat_i(uart_IN_data),
        .sys_clk_i(clk),
        .sys_rstn_i(nrst)
    );


    function [3:0] gen_we;
        input [5:0] alucode;
        input [1:0] addr_4;
        begin
            case (addr_4) 
                2'b00: begin
                    case (alucode) 
                        `ALU_SB: gen_we = 4'b0001;
                        `ALU_SH: gen_we = 4'b0011;
                        `ALU_SW: gen_we = 4'b1111;
                        default: gen_we = 4'b0000;
                    endcase
                end
                2'b01: begin
                    case (alucode) 
                        `ALU_SB: gen_we = 4'b0010;
                        `ALU_SH: gen_we = 4'b0110;
                        `ALU_SW: gen_we = 4'b1111;
                        default: gen_we = 4'b0000;
                    endcase
                end
                2'b10: begin
                    case (alucode) 
                        `ALU_SB: gen_we = 4'b0100;
                        `ALU_SH: gen_we = 4'b1100;
                        `ALU_SW: gen_we = 4'b1111;
                        default: gen_we = 4'b0000;
                    endcase
                end
                2'b11: begin
                    case (alucode) 
                        `ALU_SB: gen_we = 4'b1000;
                        `ALU_SH: gen_we = 4'b1111;
                        `ALU_SW: gen_we = 4'b1111;
                        default: gen_we = 4'b0000;
                    endcase
                end
            endcase
        end
    endfunction

    function [31:0] select_data_r;
        input [31:0] data;
        input [1:0] addr_4;
        case (addr_4)
            2'b00: select_data_r = data;
            2'b01: select_data_r = {8'b0, data[31:8]};
            2'b10: select_data_r = {16'b0, data[31:16]};
            2'b11: select_data_r = {24'b0, data[31:24]};
        endcase
    endfunction

    function [31:0] select_data_w;
        input [31:0] data;
        input [1:0] addr_4;
        case (addr_4)
            2'b00: select_data_w = data;
            2'b01: select_data_w = {data[23:0], 8'b0};
            2'b10: select_data_w = {data[15:0], 16'b0};
            2'b11: select_data_w = {data[7:0], 24'b0};
        endcase
    endfunction

    function [31:0] load_data;
        input [31:0] r_data_in;
        input [1:0] r_addr_4;
        input [3:0] re;
        input is_signed;
        begin
            if (is_signed) begin
                case (re)
                    4'b0001: load_data = {{24{r_data_in[7]}}, r_data_in[7:0]};
                    4'b0011: load_data = {{16{r_data_in[15]}}, r_data_in[15:0]};
                    4'b1111: load_data = r_data_in;
                    default: load_data = 32'b0;
                endcase
            end else begin
                case (re)
                    4'b0001: load_data = {24'b0, r_data_in[7:0]};
                    4'b0011: load_data = {16'b0, r_data_in[15:0]};
                    4'b1111: load_data = r_data_in;
                    default: load_data = 32'b0;
                endcase
            end
        end
    endfunction
endmodule