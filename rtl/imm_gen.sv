`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:18:14 PM
// Design Name: 
// Module Name: imm_gen
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

module imm_gen (
    input  logic [6:0]             funct7,
    input  logic [4:0]             rs2,
    input  logic [4:0]             rs1,
    input  logic [2:0]             funct3,
    input  logic [4:0]             rd,
    input  logic [OPCODE_SIZE-1:0] opcode,
    
    output logic [REG_SIZE-1:0]    imm_out
);
    logic [11:0] imm_i;
    logic [11:0] imm_s;
    logic [12:0] imm_b;
    logic [20:0] imm_j;
    logic [REG_SIZE-1:0] imm_i_sext;
    logic [REG_SIZE-1:0] imm_s_sext;
    logic [REG_SIZE-1:0] imm_b_sext;
    logic [REG_SIZE-1:0] imm_j_sext;
    logic [REG_SIZE-1:0] imm_u_sext;
    // =================================================================
    // Collect Immediate
    // =================================================================
    
    // I-Type: imm[11:0] = {inst[31:25], inst[24:20]}
    assign imm_i = {funct7, rs2};
    
    // S-Type: imm[11:0] = {inst[31:25], inst[11:7]}
    assign imm_s = {funct7, rd};
    
    // B-Type (Branch):
    // inst[31] = funct7[6] | inst[7] = rd[0] | inst[30:25] = funct7[5:0] | inst[11:8] = rd[4:1]
    assign imm_b = {funct7[6], rd[0], funct7[5:0], rd[4:1], 1'b0};
    
    // J-Type (Jump):
    // inst[31] = funct7[6] | inst[19:12] = {rs1, funct3} | inst[20] = rs2[0] | inst[30:21] = {funct7[5:0], rs2[4:1]}
    assign imm_j = {funct7[6], rs1, funct3, rs2[0], funct7[5:0], rs2[4:1], 1'b0};
    
    // =================================================================
    // Sign Extension
    // =================================================================
    
    assign imm_i_sext = {{20{imm_i[11]}}, imm_i};
    assign imm_s_sext = {{20{imm_s[11]}}, imm_s};
    assign imm_b_sext = {{19{imm_b[12]}}, imm_b};
    assign imm_j_sext = {{11{imm_j[20]}}, imm_j};
    
    // U-Type: shift left 12 bit 
    assign imm_u_sext = {funct7, rs2, rs1, funct3, 12'd0};

    // =================================================================
    // Choose immediate based on Opcode
    // =================================================================
    always_comb begin
        imm_out = '0; 
        
        case (opcode)
            OP_REGIMM, OP_LOAD, OP_JALR: begin
                imm_out = imm_i_sext;
            end
            
            OP_STORE: begin
                imm_out = imm_s_sext;
            end
            
            OP_BRANCH: begin
                imm_out = imm_b_sext;
            end
            
            OP_LUI, OP_AUIPC: begin
                imm_out = imm_u_sext;
            end
            
            OP_JAL: begin
                imm_out = imm_j_sext;
            end
            
            default: begin
                imm_out = '0;
            end
        endcase
    end 
endmodule
