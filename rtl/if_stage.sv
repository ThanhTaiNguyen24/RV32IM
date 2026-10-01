`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: if_stage
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
module if_stage(
    input   logic                   clk,
    input   logic                   rst_n,
    input   logic                   pc_en,
    input   logic                   pc_sel,
    input   logic [REG_SIZE - 1:0]  t_pc,
    output  logic [REG_SIZE - 1:0]  c_pc
    );

    logic [REG_SIZE - 1:0] n_pc;
    
    mux_2x1 u_mux (
        .a(c_pc + 32'd4),
        .b(t_pc),
        .sel(pc_sel),
        .d_out(n_pc)
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) c_pc <= '0;
        else if (pc_en) c_pc <= n_pc;
        else c_pc <= c_pc;
    end    
endmodule