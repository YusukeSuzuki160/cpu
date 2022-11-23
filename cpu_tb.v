`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/07 16:11:30
// Design Name: 
// Module Name: cpu_tb
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

module cpu_tb;
    reg sysclk;
    reg cpu_resetn;
    wire uart_tx;
    parameter CYCLE = 100;

    always #(CYCLE/2) sysclk = ~sysclk;

    neocpu cpu0(
       .sysclk(sysclk),
       .cpu_resetn(cpu_resetn),
       .uart_tx(uart_tx)
    );

    initial begin
        #10     sysclk     = 1'd0;
                cpu_resetn    = 1'd0;
        #(CYCLE) cpu_resetn = 1'd1;
        #(10000000 * CYCLE)
        #(10000000 * CYCLE) $finish;
    end
endmodule
