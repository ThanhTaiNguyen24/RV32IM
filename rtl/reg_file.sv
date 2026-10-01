`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:44:15 PM
// Design Name: 
// Module Name: reg_file
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
module reg_file #(
    parameter NUM_REG = 32
    )(
    input logic                     clk, rst_n,
    
    input logic                     w_e,
    
    input logic [4:0]               rd,
    input logic [REG_SIZE - 1:0]    d_rd,
    
    input logic [4:0]               rs1,
    output logic [REG_SIZE - 1:0]   d_rs1
    ,
    input logic [4:0]               rs2,
    output logic [REG_SIZE - 1:0]   d_rs2
    );
    
    logic [REG_SIZE - 1:0] mem [0:NUM_REG - 1];
    integer i;
    
    always_comb begin
        d_rs1 = (rs1 == '0) ? '0 : mem[rs1];
        d_rs2 = (rs2 == '0) ? '0 : mem[rs2];
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_REG; i = i + 1) begin
                mem[i] <= 0;
            end     
        end else if (w_e) begin
            if (rd != '0) mem[rd] <= d_rd;
        end
    end

endmodule