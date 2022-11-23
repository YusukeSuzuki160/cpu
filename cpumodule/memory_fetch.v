`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/06 14:36:22
// Design Name: 
// Module Name: memory_fetch
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


module memory_fetch(
    input clk, nrst,
    input [31:0] r_addr,
    input state,
    output reg [31:0] r_data
);
    reg [31:0] mem [0:24575];
    initial begin 
        $readmemh("E:/eeic/eeic3A/cpu/b3exp/program_neo/code.hex", mem);
    end
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            r_data <= mem[32'h0080];
        end else if (state == `ENABLE) begin
            r_data <= mem[r_addr >> 2];
        end else begin
            r_data <= r_data;
        end
    end
endmodule
