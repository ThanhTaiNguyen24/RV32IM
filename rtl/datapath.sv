`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: datapath
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

module datapath(
    input  logic                   clk,
    input  logic                   rst_n,
    
    // Giao tiếp IMEM
    output logic [REG_SIZE - 1:0]  c_pc_f,
    input  logic [REG_SIZE - 1:0]  f_inst,
    
    // Giao tiếp DMEM
    output logic [REG_SIZE - 1:0]  store_addr_dmem, 
    output logic [3:0]             store_we_dmem,
    output logic [REG_SIZE - 1:0]  d_store_dmem_m,
    input  logic [REG_SIZE - 1:0]  d_load_dmem,
    
    // Output Debug/Trace
    output logic [REG_SIZE - 1:0]  trace_pc,
    output logic [INST_SIZE - 1:0] trace_inst
);


    // Control & Hazard signals
    logic pc_en;
    logic pc_sel;
    logic flush;
    logic [1:0] sel_a_forward;
    logic [1:0] sel_b_forward;

    // IF signals
    logic [REG_SIZE - 1:0] t_pc;
    logic [REG_SIZE - 1:0] c_pc;

    // ID signals
    logic [4:0] rs1_d;
    logic [4:0] rs2_d;
    logic is_div_op_d;
    logic mem_write_d;
    logic [REG_SIZE - 1:0] c_pc_e;
    logic [REG_SIZE - 1:0] inst_e;
    logic [REG_SIZE - 1:0] d_rs1_e;
    logic [REG_SIZE - 1:0] d_rs2_e;
    logic [REG_SIZE - 1:0] imm_e;
    logic [4:0] rd_addr_e;
    logic [4:0] rs1_addr_e;
    logic [4:0] rs2_addr_e;
    logic is_div_op_e;
    logic alu_src_e;
    logic mem_write_e;
    logic mem_read_e;
    logic reg_write_e;
    logic mem_to_reg_e;
    logic branch_e;
    logic jal_e;
    logic jalr_e;
    logic auipc_e;
    logic lui_e;
    logic [ALU_CTRL_SIZE - 1:0] alu_ctrl_e;
    logic [STORE_TYPE_SIZE-1:0] store_type_e;
    logic [LOAD_TYPE_SIZE-1:0]  load_type_e;
    logic [BRANCH_TYPE_SIZE-1:0] branch_type_e;

    // EX signals
    logic [6:0] div_stage_0;
    logic [6:0] div_stage_1;
    logic [6:0] div_stage_2;
    logic [6:0] div_stage_3;
    logic [6:0] div_stage_4;
    logic [6:0] div_stage_5;
    logic [6:0] div_stage_6;
    logic [6:0] div_stage_7;
    logic [REG_SIZE - 1:0] div_pc_end;
    logic [REG_SIZE - 1:0] quotient;
    logic [REG_SIZE - 1:0] remainder;
    logic [INST_SIZE - 1:0] div_inst_end;
    logic [REG_SIZE - 1:0] d_result_m;
    logic [REG_SIZE - 1:0] c_pc_m;
    logic [REG_SIZE - 1:0] inst_m;
    logic [REG_SIZE - 1:0] d_rs2_m;
    logic [4:0] rd_addr_m;
    logic [4:0] rs2_addr_m;
    logic mem_write_m;
    logic mem_read_m;
    logic reg_write_m;
    logic mem_to_reg_m;
    logic [STORE_TYPE_SIZE-1:0] store_type_m;
    logic [LOAD_TYPE_SIZE-1:0]  load_type_m;

    // MEM signals
    logic [REG_SIZE - 1:0] d_result_w;
    logic [REG_SIZE - 1:0] c_pc_w;
    logic [REG_SIZE - 1:0] inst_w;
    logic [REG_SIZE - 1:0] d_load_dmem_w;
    logic [4:0] rd_addr_w;
    logic reg_write_w;
    logic mem_to_reg_w;

    // WB signals
    logic [REG_SIZE - 1:0] d_rd_w;
    logic [4:0] rd_w;
    logic reg_we_w;

    // =================================================================
    // IMEM ADDRESS
    // =================================================================
    assign c_pc_f = c_pc;

    // =================================================================
    // MODULE INSTANTIATIONS 
    // =================================================================

    if_stage u_if (
        .clk,
        .rst_n,
        .pc_en,
        .pc_sel,
        .t_pc,
        .c_pc
    );

    id_stage u_id (
        .clk,
        .rst_n,
        .f_inst,
        .c_pc,
        .flush,
        .reg_we_w,
        .rd_w,
        .d_rd_w,
        .rs1_d,
        .rs2_d,
        .is_div_op_d,
        .c_pc_e,
        .inst_e,
        .d_rs1_e,
        .d_rs2_e,
        .imm_e,
        .rd_addr_e,
        .rs1_addr_e,
        .rs2_addr_e,
        .is_div_op_e,
        .mem_write_d,
        .alu_ctrl_e,
        .alu_src_e,
        .mem_write_e,
        .mem_read_e,
        .store_type_e,
        .load_type_e,
        .reg_write_e,
        .mem_to_reg_e,
        .branch_e,
        .jal_e,
        .jalr_e,
        .branch_type_e,
        .auipc_e,
        .lui_e
    );

    ex_stage u_ex (
        .clk,
        .rst_n,
        .inst_e,
        .c_pc_e,
        .d_rs1_e,
        .d_rs2_e,
        .imm_e,
        .rd_addr_e,
        .rs2_addr_e,
        .is_div_op_e,
        .alu_ctrl_e,
        .alu_src_e,
        .mem_write_e,
        .mem_read_e,
        .store_type_e,
        .load_type_e,
        .reg_write_e,
        .mem_to_reg_e,
        .branch_e,
        .jal_e,
        .jalr_e,
        .branch_type_e,
        .auipc_e,
        .lui_e,
        .sel_a_forward,
        .sel_b_forward,
        .d_rd_w,
        .t_pc,
        .pc_sel,
        .div_stage_0,
        .div_stage_1,
        .div_stage_2,
        .div_stage_3,
        .div_stage_4,
        .div_stage_5,
        .div_stage_6,
        .div_stage_7,
        .div_pc_end,
        .quotient,
        .remainder,
        .div_inst_end,
        .d_result_m,
        .c_pc_m,
        .inst_m,
        .d_rs2_m,
        .rd_addr_m,
        .rs2_addr_m,
        .mem_write_m,
        .mem_read_m,
        .store_type_m,
        .load_type_m,
        .reg_write_m,
        .mem_to_reg_m
    );

    mem_stage u_mem (
        .clk,
        .rst_n,
        .div_pc_end,
        .quotient,
        .remainder,
        .div_inst_end,
        .div_stage_7,
        .d_result_m,
        .c_pc_m,
        .inst_m,
        .d_rs2_m,
        .rs2_addr_m,
        .rd_addr_m,
        .mem_write_m,
        .mem_read_m,
        .store_type_m,
        .load_type_m,
        .reg_write_m,
        .mem_to_reg_m,
        .d_rd_w,
        .rd_w,
        .reg_we_w,
        .d_load_dmem,
        .store_addr_dmem,
        .store_we_dmem,
        .d_store_dmem_m,
        .d_result_w,
        .c_pc_w,
        .inst_w,
        .rd_addr_w,
        .reg_write_w,
        .mem_to_reg_w,
        .d_load_dmem_w
    );

    wb_stage u_wb (
        .d_result_w,
        .d_load_dmem_w,
        .rd_addr_w,
        .reg_write_w,
        .mem_to_reg_w,
        .c_pc_w,
        .inst_w,
        .d_rd_w,
        .rd_w,
        .reg_we_w,
        .trace_pc,
        .trace_inst
    );

    hazard_detection u_hazard (
        .rst_n,
        .rs1_addr_d(rs1_d),
        .rs2_addr_d(rs2_d),
        .is_div_op_d,
        .mem_write_d,
        .is_div_op_e,
        .mem_read_e,
        .pc_sel,
        .rd_addr_e,
        .div_stage_0,
        .div_stage_1,
        .div_stage_2,
        .div_stage_3,
        .div_stage_4,
        .div_stage_5,
        .div_stage_6,
        .div_stage_7,
        .flush,
        .pc_en
    );

    forwarding u_forwarding (
        .rst_n,
        .reg_write_m,
        .reg_write_w(reg_we_w),
        .rd_addr_m,
        .rd_addr_w(rd_w),
        .rs1_addr_e,
        .rs2_addr_e,
        .sel_a_forward,
        .sel_b_forward
    );

endmodule