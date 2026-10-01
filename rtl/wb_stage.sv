`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: wb_stage
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


module wb_stage (
    input logic [REG_SIZE - 1:0]  d_result_w,      
    input logic [REG_SIZE - 1:0]  d_load_dmem_w,   
    input logic [4:0]             rd_addr_w,       
    input logic                   reg_write_w,     
    input logic                   mem_to_reg_w,    
    input logic [REG_SIZE - 1:0]  c_pc_w,          
    input logic [INST_SIZE - 1:0] inst_w,         

    // Output to RegFile in ID
    output logic [REG_SIZE - 1:0] d_rd_w,         
    output logic [4:0]            rd_w,     
    output logic                  reg_we_w,       

    output logic [REG_SIZE - 1:0] trace_pc,
    output logic [INST_SIZE - 1:0] trace_inst
);

    //If LOAD: (mem_to_reg = 1) --> Choose data from DMEM | else --> Data from ALU/DIV
    assign d_rd_w = (mem_to_reg_w) ? d_load_dmem_w : d_result_w;

    // Data to Data Path
    assign rd_w = rd_addr_w;
    assign reg_we_w  = reg_write_w;

    // Trace/Debug signals
    assign trace_pc   = c_pc_w;
    assign trace_inst = inst_w;

endmodule
