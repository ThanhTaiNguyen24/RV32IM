`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:18:14 PM
// Design Name: 
// Module Name: ex_stage
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
module ex_stage(
    input logic                             clk,
    input logic                             rst_n,
    //D/EX Registers
    input logic [REG_SIZE - 1:0]            inst_e,
    input logic [REG_SIZE - 1:0]            c_pc_e,
    input logic [REG_SIZE - 1:0]            d_rs1_e,
    input logic [REG_SIZE - 1:0]            d_rs2_e,
    input logic [REG_SIZE - 1:0]            imm_e,
    input logic [4:0]                       rd_addr_e,
    input logic [4:0]                       rs2_addr_e,
    
    input logic                             is_div_op_e,
    input logic [ALU_CTRL_SIZE - 1:0]       alu_ctrl_e,
    input logic                             alu_src_e,
    input logic                             mem_write_e,
    input logic                             mem_read_e,
    input logic [STORE_TYPE_SIZE-1:0]       store_type_e,
    input logic [LOAD_TYPE_SIZE-1:0]        load_type_e,
    input logic                             reg_write_e,
    input logic                             mem_to_reg_e,
    input logic                             branch_e,
    input logic                             jal_e,
    input logic                             jalr_e,
    input logic [BRANCH_TYPE_SIZE - 1:0]    branch_type_e,
    input logic                             auipc_e,
    input logic                             lui_e,
    //Fowarding signals from Forwarding Unit
    input logic [1:0]                       sel_a_forward,
    input logic [1:0]                       sel_b_forward,
    //Fowarding signals from MEM
    input logic [REG_SIZE - 1:0]            d_rd_w,
    
    //Fowarding signals from WB
  
    
    //Output signals to Fetch Stage
    output logic [REG_SIZE - 1:0]           t_pc,
    output logic                            pc_sel,
    //Divider Control Signals
    output logic [6:0]                      div_stage_0, div_stage_1, div_stage_2, div_stage_3, div_stage_4, div_stage_5, div_stage_6, div_stage_7,
    output logic [REG_SIZE - 1:0]           div_pc_end, quotient, remainder,
    output logic [INST_SIZE - 1:0]          div_inst_end,
    //EX/MEM Registers
    output logic [REG_SIZE - 1:0]           d_result_m,
    output logic [REG_SIZE - 1:0]           c_pc_m,
    output logic [REG_SIZE - 1:0]           inst_m,
    output logic [REG_SIZE - 1:0]           d_rs2_m, //for load & store inst
    output logic [4:0]                      rd_addr_m, //for Forwarding and WB
    output logic [4:0]                      rs2_addr_m, //for WM bypassing
    output logic                            mem_write_m,
    output logic                            mem_read_m,
    output logic [STORE_TYPE_SIZE-1:0]      store_type_m,
    output logic [LOAD_TYPE_SIZE-1:0]       load_type_m,
    output logic                            reg_write_m,
    output logic                            mem_to_reg_m
    );
    
    //ALU data
    logic [REG_SIZE - 1:0] srca_tmp_alu, srca_alu, srcb_tmp_alu, srcb_alu;
    logic [REG_SIZE - 1:0] d_result_e;
    //Signal for PCUpdate
    logic zero_flag, less_flag, less_u_flag;
    mux_3x1 srca_mux (
        .a(d_rs1_e),
        .b(d_rd_w),
        .c(d_result_m),
        .sel(sel_a_forward),
        .d_out(srca_tmp_alu)
    );
    
    always_comb begin
        if (lui_e) srca_alu = '0;
        else if (auipc_e) srca_alu = c_pc_e;
        else srca_alu = srca_tmp_alu;
    end
    mux_3x1 srcb_mux (
        .a(d_rs2_e),
        .b(d_rd_w),
        .c(d_result_m),
        .sel(sel_b_forward),
        .d_out(srcb_tmp_alu)
    );
    
    mux_2x1 alu_mux (
        .a(srcb_tmp_alu),
        .b(imm_e),
        .sel(alu_src_e),
        .d_out(srcb_alu)
    );
    
    alu u_alu (
        .srca_alu,
        .srcb_alu,
        .alu_ctrl_e,
        .d_result_e,
        .zero_flag,
        .less_flag,
        .less_u_flag
    );
    
    div_unit u_div (
        .clk,
        .rst_n,
        .alu_ctrl_e,
        .dividend(srca_alu),
        .divisor(srcb_alu),
        .rd_addr_e,
        .c_pc_e,
        .inst_e,
        .div_stage_0,
        .div_stage_1,
        .div_stage_2,
        .div_stage_3,
        .div_stage_4,
        .div_stage_5,
        .div_stage_6,
        .div_stage_7,
        .div_pc_end,
        .div_inst_end,
        .quotient,
        .remainder
    );
    
    pc_update u_pcupdate(
        .srca_alu,
        .c_pc_e,
        .imm_e,
        .branch_e,
        .jal_e,
        .jalr_e,
        .branch_type_e,
        .zero_flag,
        .less_flag,
        .less_u_flag,
        .t_pc,
        .pc_sel
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_write_m <= '0;
            mem_write_m <= '0;
            mem_to_reg_m <= '0;
            mem_read_m <= '0;
            store_type_m <= '0;
            load_type_m <= '0;
            rd_addr_m <= '0;
            rs2_addr_m <= '0;
            d_rs2_m <= '0;
            c_pc_m <= '0;
            inst_m <= '0;
            d_result_m <= '0;
        end else begin
            reg_write_m <= (is_div_op_e) ? '0 : reg_write_e;
            mem_write_m <= mem_write_e;
            mem_to_reg_m <= mem_to_reg_e;
            mem_read_m <= mem_read_e;
            store_type_m <= store_type_e;
            load_type_m <= load_type_e;
            rd_addr_m <= rd_addr_e;
            rs2_addr_m <= rs2_addr_e;
            d_rs2_m <= d_rs2_e;
            c_pc_m <= c_pc_e;
            inst_m <= inst_e;
            //Save address
            if (jal_e || jalr_e) begin
                d_result_m <= c_pc_e + 32'd4;
            end else begin
                d_result_m <= d_result_e;
            end
        end
    end

endmodule
