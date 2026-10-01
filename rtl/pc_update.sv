`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 03:16:02 PM
// Design Name: 
// Module Name: pc_update
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
module pc_update(
    input logic [REG_SIZE - 1:0] srca_alu,
    input logic [REG_SIZE - 1:0] c_pc_e,
    input logic [REG_SIZE - 1:0] imm_e,
    input logic branch_e,
    input logic jal_e,
    input logic jalr_e,
    input logic [2:0] branch_type_e,
    input logic zero_flag,
    input logic less_flag,
    input logic less_u_flag,
    
    output logic [REG_SIZE - 1:0] t_pc,
    output logic pc_sel 
);

    logic branch;
    
    always_comb begin
        unique case (branch_type_e)
            BEQ  : branch =  zero_flag;
            BNE  : branch = ~zero_flag;
            BLT  : branch =  less_flag;
            BGE  : branch = ~less_flag;
            BLTU : branch =  less_u_flag;
            BGEU : branch = ~less_u_flag;
            default: branch = '0;
        endcase
    end

    always_comb begin
        pc_sel = '0;
        t_pc = '0;
        if (jal_e) begin
            t_pc = c_pc_e + imm_e;
            pc_sel = '1;
        end else if (jalr_e) begin
            t_pc = srca_alu + imm_e;
            pc_sel = '1;
        end else if (branch_e && branch) begin
            t_pc = c_pc_e + imm_e;
            pc_sel = '1;
        end

    end
endmodule
