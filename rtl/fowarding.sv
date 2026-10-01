`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: forwarding
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


module forwarding(
    input logic         rst_n,
    input logic         reg_write_m, reg_write_w,
    input logic [4:0]   rd_addr_m, rd_addr_w, rs1_addr_e, rs2_addr_e,
    output logic [1:0]  sel_a_forward, sel_b_forward
    );
    
    //EX/MEM first priority, then MEM/WB
    assign sel_a_forward = (!rst_n) ? '0 : ((reg_write_m) & (rd_addr_m != 0) & (rd_addr_m == rs1_addr_e)) ? 2'b10 : ((reg_write_w) & (rd_addr_w != 0) & (rd_addr_w == rs1_addr_e)) ? 2'b01 : 2'b00;
    assign sel_b_forward = (!rst_n) ? '0 : ((reg_write_m) & (rd_addr_m != 0) & (rd_addr_m == rs2_addr_e)) ? 2'b10 : ((reg_write_w) & (rd_addr_w != 0) & (rd_addr_w == rs2_addr_e)) ? 2'b01 : 2'b00;
    
endmodule
