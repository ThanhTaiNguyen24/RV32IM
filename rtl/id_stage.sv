`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:18:14 PM
// Design Name: 
// Module Name: id_stage
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
module id_stage(
    input logic                             clk,
    input logic                             rst_n,
    input logic [REG_SIZE - 1:0]            f_inst,
    input logic [REG_SIZE - 1:0]            c_pc,
    input logic                             flush,
    
    //Input from WB
    input logic                             reg_we_w,
    input logic [4:0]                       rd_w,
    input logic [REG_SIZE - 1:0]            d_rd_w,
    
    //Output for Hazard Unit
    output logic [4:0]                      rs1_d, rs2_d,
    output logic                            is_div_op_d,
    output logic                            mem_write_d,
    
    //Output to EX
    output logic [REG_SIZE - 1:0]           c_pc_e,
    output logic [REG_SIZE - 1:0]           inst_e,
    output logic [REG_SIZE - 1:0]           d_rs1_e,
    output logic [REG_SIZE - 1:0]           d_rs2_e,
    output logic [REG_SIZE - 1:0]           imm_e,
    output logic [4:0]                      rd_addr_e,
    output logic [4:0]                      rs1_addr_e,
    output logic [4:0]                      rs2_addr_e,
    
    output logic                            is_div_op_e,
    output logic [ALU_CTRL_SIZE - 1:0]      alu_ctrl_e,
    output logic                            alu_src_e,
    output logic                            mem_write_e,
    output logic                            mem_read_e,
    output logic [STORE_TYPE_SIZE-1:0]      store_type_e,
    output logic [LOAD_TYPE_SIZE-1:0]       load_type_e,
    output logic                            reg_write_e,
    output logic                            mem_to_reg_e,
    output logic                            branch_e,
    output logic                            jal_e,
    output logic                            jalr_e,
    output logic [BRANCH_TYPE_SIZE - 1:0]   branch_type_e,
    output logic                            auipc_e,
    output logic                            lui_e
    
    );
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
    
    logic [REG_SIZE - 1:0] d_rd;
    logic [REG_SIZE - 1:0] d_rs1;
    logic [REG_SIZE - 1:0] d_rs2;
    
    // =================================================================
    // CONTROL UNIT SIGNAL
    // =================================================================
    logic is_div_op;
    
    //Control Signal for ALU
    logic [ALU_CTRL_SIZE - 1:0] alu_ctrl; 
    logic                       alu_src;
    
    //Data Memory Control
    logic                           mem_write, mem_read;
    logic [STORE_TYPE_SIZE-1:0]     store_type;
    logic [LOAD_TYPE_SIZE-1:0]      load_type;
    
    //Register File Control
    logic reg_write, mem_to_reg;
    
    //Branch, Jump
    logic                           branch, jal, jalr;
    logic [BRANCH_TYPE_SIZE - 1:0]  branch_type;
    
    //U-type
    logic auipc, lui;
    
    //Exceptions
    logic illegal_inst, halt;
    // =================================================================
    //INST DECODE
    // =================================================================
    assign funct7 = f_inst [31:25];
    assign rs2     = f_inst[24:20];
    assign rs1     = f_inst[19:15];
    assign funct3  = f_inst [14:12];
    assign rd      = f_inst[11:7];
    assign opcode  = f_inst [6:0];
    // =================================================================
    //IMMEDIATE GENERATE SIGNAL
    // =================================================================
    logic [REG_SIZE - 1:0] imm_out_w;
    
    // =================================================================
    //ASSIGN FOR HAZARD UNIT
    // =================================================================
    assign rs1_d = rs1;
    assign rs2_d = rs2;
    assign is_div_op_d = is_div_op;
    assign mem_write_d = mem_write;
    // =================================================================
    //REG FILE INSTANCE
    // =================================================================
    reg_file u_rf (
        .clk,
        .rst_n,
        .w_e(reg_we_w),
        .rd(rd_w),
        .d_rd(d_rd_w),
        .rs1,
        .d_rs1,
        .rs2,
        .d_rs2
    );
    
    // =================================================================
    //CONTROL UNIT INSTANCE
    // =================================================================
    control_unit u_cu(
        .opcode,
        .funct3,
        .funct7,
        .is_div_op,
        .alu_ctrl,
        .alu_src,
        .mem_write,
        .mem_read,
        .store_type,
        .load_type,
        .reg_write,
        .mem_to_reg,
        .branch,
        .branch_type,
        .jal,
        .jalr,
        .auipc,
        .lui,
        .illegal_inst,
        .halt
    );
    
    // =================================================================
    //IMMEDIATE GENERATE INSTANCE
    // =================================================================
    imm_gen u_imm(
        .funct7,
        .rs2,
        .rs1,
        .funct3,
        .rd,
        .opcode,
        .imm_out(imm_out_w)
    );
    
    // =================================================================
    // PIPELINE REGISTERS: ID/EX
    // =================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c_pc_e         <= '0;
            inst_e         <= '0;
            d_rs1_e        <= '0;
            d_rs2_e        <= '0;
            imm_e          <= '0;
            rd_addr_e      <= '0;
            rs1_addr_e     <= '0;
            rs2_addr_e     <= '0;
            is_div_op_e    <= '0;
            alu_ctrl_e     <= '0;
            alu_src_e      <= '0;
            mem_write_e    <= '0;
            mem_read_e     <= '0;
            store_type_e   <= '0;
            load_type_e    <= '0;
            reg_write_e    <= '0;
            mem_to_reg_e   <= '0;
            branch_e       <= '0;
            jal_e          <= '0;
            jalr_e         <= '0;
            branch_type_e  <= '0;
            auipc_e        <= '0;
            lui_e          <= '0;
        end 
        else if (flush || illegal_inst) begin
            c_pc_e         <= '0;
            inst_e         <= '0;
            d_rs1_e        <= '0;
            d_rs2_e        <= '0;
            imm_e          <= '0;
            rd_addr_e      <= '0;
            rs1_addr_e     <= '0;
            rs2_addr_e     <= '0;
            is_div_op_e    <= '0;
            alu_ctrl_e     <= ALU_NOP; 
            alu_src_e      <= '0;
            mem_write_e    <= '0;
            mem_read_e     <= '0;
            store_type_e   <= '0;
            load_type_e    <= '0;
            reg_write_e    <= '0;
            mem_to_reg_e   <= '0;
            branch_e       <= '0;
            jal_e          <= '0;
            jalr_e         <= '0;
            branch_type_e  <= '0;
            auipc_e        <= '0;
            lui_e          <= '0;
        end 
        else begin
            c_pc_e         <= c_pc;
            inst_e         <= f_inst;
            imm_e          <= imm_out_w;
            rd_addr_e      <= rd;
            
            // =====================================================
            //  WD Bypass 
            // =====================================================
            if (reg_we_w && rd_w != 0 && rd_w == rs1) begin
                d_rs1_e <= d_rd_w;
            end else begin
                d_rs1_e <= d_rs1;
            end
            if (reg_we_w && rd_w != 0 && rd_w == rs2) begin
                d_rs2_e <= d_rd_w;
            end else begin
                d_rs2_e <= d_rs2;
            end
           
            rs1_addr_e     <= rs1;
            rs2_addr_e     <= rs2;

            is_div_op_e    <= is_div_op;
            alu_ctrl_e     <= alu_ctrl;
            alu_src_e      <= alu_src;
            mem_write_e    <= mem_write;
            mem_read_e     <= mem_read;
            store_type_e   <= store_type;
            load_type_e    <= load_type;
            reg_write_e    <= reg_write;
            mem_to_reg_e   <= mem_to_reg;
            branch_e       <= branch;
            jal_e          <= jal;
            jalr_e         <= jalr;
            branch_type_e  <= branch_type;
            auipc_e        <= auipc;
            lui_e          <= lui;
        end
    end
endmodule
