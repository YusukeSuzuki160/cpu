`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/06 18:27:58
// Design Name: 
// Module Name: register_file
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


module register_file(
    input clk, nrst,
    input we,
    input [4:0] r_addr1, r_addr2, w_addr,
    input [31:0] w_data,    
    input state1, state2,
    output [31:0] r_data1, r_data2
);

    reg [31:0] mem [0:31];
    initial begin
       mem[0] <= 0;
    end
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            mem[0] <= 0;
        end else if (state2 == `ENABLE) begin
            if (we) begin
                mem[w_addr] <= w_data;
            end
        end else begin
            mem[0] <= mem[0];
        end
    end
    assign r_data1 = mem[r_addr1];
    assign r_data2 = mem[r_addr2];
endmodule
