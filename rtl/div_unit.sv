`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 03:04:26 PM
// Design Name: 
// Module Name: div_unit
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
module div_unit(
    input logic                     clk, rst_n,
    input logic [4:0]               alu_ctrl_e,
    input logic [REG_SIZE - 1:0]    dividend, divisor,
    input logic [4:0]               rd_addr_e,           
    input logic [REG_SIZE - 1:0]    c_pc_e,   
    input logic [INST_SIZE - 1:0]   inst_e,        
    
    output logic [6:0]              div_stage_0, div_stage_1, div_stage_2, div_stage_3, div_stage_4, div_stage_5, div_stage_6, div_stage_7,
    output logic [REG_SIZE - 1:0]   div_pc_end,
    output logic [INST_SIZE - 1:0]  div_inst_end,
    
    output logic [REG_SIZE - 1:0]   quotient,
    output logic [REG_SIZE - 1:0]   remainder
    
);
    logic is_signed; 
    logic is_rem; 
    logic is_div;
    
    // Div instruction data pipe
    logic [REG_SIZE - 1:0] div_pc [0:7]; //save PC address of Div 
    logic [INST_SIZE - 1:0] div_inst [0:7]; //save Inst address of Div 
    logic [6:0] div_busy [0:7]; //busy flag of Div
    integer j;
    
    assign is_signed = (alu_ctrl_e == ALU_DIV) | (alu_ctrl_e == ALU_REM);
    assign is_rem = (alu_ctrl_e == ALU_REM) | (alu_ctrl_e == ALU_REMU);
    assign is_div = (alu_ctrl_e == ALU_DIV) | (alu_ctrl_e == ALU_DIVU)|(alu_ctrl_e == ALU_REM) | (alu_ctrl_e == ALU_REMU);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for(j=0; j<8; j=j+1) begin
                div_busy[j] <= 0;
                div_pc[j] <= 0;
                div_inst[j] <= 0;
            end
        end else begin
            for(j=1; j<8; j=j+1) begin
                div_busy[j] <= div_busy[j-1];
                div_pc[j] <= div_pc[j-1];
                div_inst[j] <= div_inst[j-1];
            end
            //Current divider_inst at EX
            div_busy[0] <= {is_div, is_rem, rd_addr_e};
            div_pc[0] <= c_pc_e;   
            div_inst[0] <= inst_e; 
        end
    end

    always @(*) begin
        div_stage_0 = div_busy[0]; 
        div_stage_1 = div_busy[1];
        div_stage_2 = div_busy[2]; 
        div_stage_3 = div_busy[3];
        div_stage_4 = div_busy[4]; 
        div_stage_5 = div_busy[5];
        div_stage_6 = div_busy[6]; 
        div_stage_7 = div_busy[7];
        
        //Output Trace
        div_pc_end = div_pc[7];   
        div_inst_end = div_inst[7];
    end
   
    
// Divider pipeline instance
div_pipelined divider_inst (
    .clk,
    .rst_n,
    .is_signed,   
    .i_dividend  (dividend),
    .i_divisor   (divisor),
    .o_remainder (remainder),
    .o_quotient  (quotient)
);

endmodule
