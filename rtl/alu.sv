`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 03:00:57 PM
// Design Name: 
// Module Name: alu
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
module alu(
    input logic  [REG_SIZE - 1:0]   srca_alu, srcb_alu,
    input logic  [4:0]              alu_ctrl_e,
    output logic [REG_SIZE - 1:0]   d_result_e,
    output logic                    zero_flag,
    output logic                    less_flag,
    output logic                    less_u_flag
    );
    
    logic [REG_SIZE - 1:0] and_result;
    logic [REG_SIZE - 1:0] or_result;
    logic [REG_SIZE - 1:0] add_result;
    logic [REG_SIZE - 1:0] sub_result;
    logic [REG_SIZE - 1:0] xor_result;
    logic [REG_SIZE - 1:0] lls_result;
    logic [REG_SIZE - 1:0] lrs_result;
    logic [REG_SIZE - 1:0] ars_result;
    logic [REG_SIZE - 1:0] mul_result;
    logic cout;
    
    cla cla_inst (
        .a(srca_alu),
        .b(srcb_alu),
        .cin(1'b0),
        .sum(add_result)
    );

    mul mul_inst (
        .a(srca_alu),
        .b(srcb_alu),
        .alu_ctrl_e(alu_ctrl_e),
        .result(mul_result)
    );
    
    assign and_result = srca_alu & srcb_alu;
    assign or_result  = srca_alu | srcb_alu;
    assign xor_result = srca_alu ^ srcb_alu;

    assign lls_result = srca_alu << srcb_alu[4:0];
    assign lrs_result = srca_alu >> srcb_alu[4:0];
    assign ars_result = $signed(srca_alu) >>> srcb_alu[4:0];

    assign {cout, sub_result} = {1'b0, srca_alu} + ~{1'b0, srcb_alu} + 1'b1;

    assign less_flag  = ($signed(srca_alu) <  $signed(srcb_alu));
    assign less_u_flag = (srca_alu < srcb_alu);
    assign zero_flag = (sub_result == '0);

    always @(*) begin
        case(alu_ctrl_e)
            ALU_AND:           d_result_e = and_result;
            ALU_OR:            d_result_e = or_result;
            ALU_ADD:           d_result_e = add_result;
            ALU_XOR:           d_result_e = xor_result;
            ALU_SUB:           d_result_e = sub_result;
            ALU_LSHIFT_LEFT:   d_result_e = lls_result;
            ALU_LSHIFT_RIGHT:  d_result_e = lrs_result;
            ALU_ASHIFT_RIGHT:  d_result_e = ars_result;
            ALU_SLT:           d_result_e = {31'b0, less_flag};
            ALU_SLTU:          d_result_e = {31'b0, less_u_flag};
            ALU_MUL,
            ALU_MULH,
            ALU_MULSU,
            ALU_MULU:          d_result_e = mul_result;
            default:            d_result_e = '0;
        endcase
    end
endmodule
