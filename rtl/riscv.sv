`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: control_unit
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

module riscv (
    input  logic                   clk,
    input  logic                   rst_n,
    
    // Trace/Debug Log
    output logic [REG_SIZE - 1:0]  trace_pc,
    output logic [INST_SIZE - 1:0] trace_inst
);

    // =================================================================
    // WIRES
    // =================================================================
    
    // IF to IMEM
    logic [REG_SIZE - 1:0]         c_pc_f;
    logic [INST_SIZE - 1:0]        f_inst;
    
    // MEM to DMEM
    logic [REG_SIZE - 1:0]         store_addr_dmem; 
    logic [3:0]                    store_we_dmem;
    logic [REG_SIZE - 1:0]         d_store_dmem_m;
    logic [REG_SIZE - 1:0]         d_load_dmem;

    // =================================================================
    // Datapath
    // =================================================================
    (* dont_touch = "true" *)datapath u_datapath (
        .clk,
        .rst_n,
        .c_pc_f,
        .f_inst,
        .store_addr_dmem,
        .store_we_dmem,
        .d_store_dmem_m,
        .d_load_dmem,
        .trace_pc,
        .trace_inst
    );

    // =================================================================
    // Memorypath
    // =================================================================
    (* dont_touch = "true" *)memorypath u_memorypath (
        .clk,
        .c_pc_f,
        .f_inst,
        .store_addr_dmem,
        .store_we_dmem,
        .d_store_dmem_m,
        .d_load_dmem
    );

endmodule
