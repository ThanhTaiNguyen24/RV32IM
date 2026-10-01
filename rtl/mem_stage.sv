`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: mem_stage
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


module mem_stage(
    //Divider Control Signals
    input logic                         clk, rst_n,
    input logic [REG_SIZE - 1:0]        div_pc_end, quotient, remainder,
    input logic [INST_SIZE - 1:0]       div_inst_end,
    input logic [6:0]                   div_stage_7,
    //EX/MEM Registers
    input logic [REG_SIZE - 1:0]        d_result_m,
    input logic [REG_SIZE - 1:0]        c_pc_m,
    input logic [REG_SIZE - 1:0]        inst_m,
    input logic [REG_SIZE - 1:0]        d_rs2_m, //for load & store inst
    input logic [4:0]                   rs2_addr_m, //for WM bypassing
    input logic [4:0]                   rd_addr_m, //for Forwarding and WB
    input logic                         mem_write_m,
    input logic                         mem_read_m,
    input logic [STORE_TYPE_SIZE-1:0]   store_type_m,
    input logic [LOAD_TYPE_SIZE-1:0]    load_type_m,
    input logic                         reg_write_m,
    input logic                         mem_to_reg_m,
    //Signals from WB stage for WM bypassing
    input logic [REG_SIZE - 1:0]        d_rd_w,         
    input logic [4:0]                   rd_w,     
    input logic                         reg_we_w,       
    //Signals from DMEM
    input logic [REG_SIZE - 1:0]        d_load_dmem,
    output logic [REG_SIZE - 1:0]       store_addr_dmem,
    output logic [3:0]                  store_we_dmem,
    output logic [REG_SIZE - 1:0]       d_store_dmem_m,
    
    //MEM/WB Registers
    output logic [REG_SIZE - 1:0]       d_result_w,
    output logic [REG_SIZE - 1:0]       c_pc_w,
    output logic [REG_SIZE - 1:0]       inst_w,
    output logic [4:0]                  rd_addr_w, //for Forwarding and WB
    output logic                        reg_write_w,
    output logic                        mem_to_reg_w,
    output logic [REG_SIZE - 1:0]       d_load_dmem_w
    
    );
    logic [1:0]     byte_offset;
    logic [7:0]     load_byte;
    logic [15:0]    load_half;
    logic [REG_SIZE - 1:0] d_load_dmem_m;
    logic [REG_SIZE - 1:0] d_store_tmp;
    //Signals for Div control
    logic div_valid;
    logic div_rem;
    logic [4:0] div_addr_m;
    
    assign div_valid = div_stage_7[6];
    assign div_rem = div_stage_7[5];
    assign div_addr_m = div_stage_7[4:0];
    
    always@(*) begin
        //WM bypassing
        if (reg_we_w && (rd_w != 0) && (rd_w == rs2_addr_m)) begin
            d_store_tmp = d_rd_w;
        end else begin
            d_store_tmp = d_rs2_m;
        end
        
        d_store_dmem_m = d_store_tmp;
        store_addr_dmem  = d_result_m;
        byte_offset = d_result_m [1:0];
        load_byte = d_load_dmem >> (byte_offset * 8);
        load_half = d_load_dmem >> (byte_offset * 8);
        store_we_dmem   = '0;
        d_load_dmem_m = '0;
        
        //LOAD
        if (mem_read_m) begin
            case (load_type_m)
                LB:  d_load_dmem_m = {{24{load_byte[7]}},  load_byte};
                LBU: d_load_dmem_m = {24'd0,               load_byte};
                LH:  d_load_dmem_m = {{16{load_half[15]}}, load_half};
                LHU: d_load_dmem_m = {16'd0,               load_half};
                LW:  d_load_dmem_m = d_load_dmem;
                default: d_load_dmem_m = '0;
            endcase
        end 
        
        // STORE
        if (mem_write_m) begin
            case (store_type_m)
                SB: begin
                    store_we_dmem = 4'b0001 << byte_offset;
                    d_store_dmem_m = {4{d_store_tmp[7:0]}};
                end
                SH: begin
                    store_we_dmem = (byte_offset[1]) ? 4'b1100 : 4'b0011;
                    d_store_dmem_m = {2{d_store_tmp[15:0]}};
                end
                SW: store_we_dmem = 4'b1111;
                default: store_we_dmem = '0;
            endcase
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c_pc_w <= '0;
            inst_w <= '0;
            d_load_dmem_w <= '0;
            d_result_w <= '0;
            rd_addr_w  <= '0;
            mem_to_reg_w  <= '0;
            reg_write_w  <= '0;
        end else begin
            //DIV take Mem stage
            if (div_valid) begin
                c_pc_w <= div_pc_end;
                inst_w <= div_inst_end;
                d_load_dmem_w <= d_load_dmem_m;
                d_result_w <= (div_rem) ? remainder : quotient;
                rd_addr_w  <= div_addr_m;
                mem_to_reg_w  <= '0;
                reg_write_w  <= '1;
            end else begin
                c_pc_w <= c_pc_m;
                inst_w <= inst_m;
                d_load_dmem_w <= d_load_dmem_m;
                d_result_w <= d_result_m;
                rd_addr_w  <= rd_addr_m;
                mem_to_reg_w  <= mem_to_reg_m;
                reg_write_w  <= reg_write_m;
            end
        end
    end
endmodule
