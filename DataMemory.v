`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/07 12:47:13
// Design Name: 
// Module Name: DataMemory
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

module memory_data(
    input clk,
    input [31:0] r_addr, w_addr,
    input [31:0] w_data,
    input [3:0] we,
    input state,
    output [31:0] r_data
);
    reg [31:0] mem [0:24575];
    initial begin 
        $readmemh("E:/eeic/eeic3A/cpu/b3exp/program_neo/data.hex", mem);
    end
    always @(posedge clk) begin
        if (we[0]) mem[w_addr][7:0] <= w_data[7:0];
        if (we[1]) mem[w_addr][15:8] <= w_data[15:8];
        if (we[2]) mem[w_addr][23:16] <= w_data[23:16];
        if (we[3]) mem[w_addr][31:24] <= w_data[31:24];
        //r_data <= mem[r_addr];
    end
    assign r_data = mem[r_addr];
endmodule
