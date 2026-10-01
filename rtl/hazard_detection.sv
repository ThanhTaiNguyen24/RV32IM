`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: hazard_detection
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


module hazard_detection(
    input logic         rst_n, 
    //Signal from Decode Stage
    input logic [4:0]   rs1_addr_d, rs2_addr_d,  
    input logic         is_div_op_d,
    input logic         mem_write_d,
    //Signal from Execute Stage
    input logic         is_div_op_e,
    input logic         mem_read_e,
    input logic         pc_sel,             
    input logic [4:0]   rd_addr_e,              
    input logic [6:0]   div_stage_0, div_stage_1, div_stage_2, div_stage_3, div_stage_4, div_stage_5, div_stage_6, div_stage_7,
    output logic        flush,        
    output logic        pc_en            
);
     // Divider denpendency
    logic conflict_div;
    integer i;
    always @(*) begin
        //div_stage_*[4:0] = rd of previous div at * stage
        //div_stage_*[6] = is_div_op at * stage
        conflict_div = 0;
        if ((div_stage_0[6] && div_stage_0[4:0] != 0 && (div_stage_0[4:0] == rs1_addr_d || div_stage_0[4:0] == rs2_addr_d)) ||
            (div_stage_1[6] && div_stage_1[4:0] != 0 && (div_stage_1[4:0] == rs1_addr_d || div_stage_1[4:0] == rs2_addr_d)) ||
            (div_stage_2[6] && div_stage_2[4:0] != 0 && (div_stage_2[4:0] == rs1_addr_d || div_stage_2[4:0] == rs2_addr_d)) ||
            (div_stage_3[6] && div_stage_3[4:0] != 0 && (div_stage_3[4:0] == rs1_addr_d || div_stage_3[4:0] == rs2_addr_d)) ||
            (div_stage_4[6] && div_stage_4[4:0] != 0 && (div_stage_4[4:0] == rs1_addr_d || div_stage_4[4:0] == rs2_addr_d)) ||
            (div_stage_5[6] && div_stage_5[4:0] != 0 && (div_stage_5[4:0] == rs1_addr_d || div_stage_5[4:0] == rs2_addr_d)) ||
            (div_stage_6[6] && div_stage_6[4:0] != 0 && (div_stage_6[4:0] == rs1_addr_d || div_stage_6[4:0] == rs2_addr_d)) ||
            (div_stage_7[6] && div_stage_7[4:0] != 0 && (div_stage_7[4:0] == rs1_addr_d || div_stage_7[4:0] == rs2_addr_d)))
            conflict_div = 1;
        //div inst in current EX stage, will get into div_stage_0 in next cycle
        if (is_div_op_e && (rd_addr_e != 0)) begin
            if (rd_addr_e == rs1_addr_d || rd_addr_e == rs2_addr_d) begin
                conflict_div = 1;
            end
        end    
    end
    // Load Use Hazard
    logic stall_load_use;
    assign stall_load_use = (mem_read_e && ((rd_addr_e == rs1_addr_d) || (rd_addr_e == rs2_addr_d && !mem_write_d)) && (rd_addr_e != 5'd0)); // Load-Use Harzard (except Store Inst)

    //Writeback collision (DIV and ALU ops write at mem at the same time)
    logic collision_at_mem;
    assign collision_at_mem = (div_stage_5[6] == 1'b1) && (mem_write_d == 1'b1) && (is_div_op_d == '0);

    //Stall system
    assign stall_req = conflict_div || stall_load_use || collision_at_mem;

    always_comb begin
        pc_en = 1'b1;
        flush = 1'b0;
        if (!rst_n) begin
            pc_en = 1'b1;
            flush = 1'b0;
        end 
        else if (stall_req) begin  
            pc_en    = 1'b0;  
            flush    = 1'b1;  
        end else if (pc_sel) begin   // Branch instruction
            flush = 1'b1; 
            pc_en = 1'b1;
        end 
    end
    
endmodule
