`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:25:53 PM
// Design Name: 
// Module Name: mux_3x1
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

import RV32_PKG::*;
module mux_3x1(
    input logic [REG_SIZE - 1:0]    a, b, c,
    input logic [1:0]               sel,
    output logic [REG_SIZE - 1:0]   d_out    
);
assign d_out = (sel == '0) ? a : (sel == 2'b01) ? b : (sel == 2'b10) ? c : '0;
endmodule
