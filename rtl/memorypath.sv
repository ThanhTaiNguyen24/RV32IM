`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: memorypath
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

module memorypath (
    input  logic                   clk,
    
    // Signals from/to IF
    input  logic [REG_SIZE - 1:0]  c_pc_f,
    output logic [INST_SIZE - 1:0] f_inst,
    
    // Signals from/to M
    input  logic [REG_SIZE - 1:0]  store_addr_dmem,
    input  logic [3:0]             store_we_dmem,
    input  logic [REG_SIZE - 1:0]  d_store_dmem_m,
    output logic [REG_SIZE - 1:0]  d_load_dmem
);

    // =================================================================
    // INSTANTIATION MEMORY BLOCKS
    // =================================================================
    
    imem u_imem (
        .c_pc_f,
        .f_inst
    );

    dmem u_dmem (
        .clk,
        .store_we_dmem,
        .store_addr_dmem,
        .d_store_dmem_m,
        .d_load_dmem
    );

endmodule
