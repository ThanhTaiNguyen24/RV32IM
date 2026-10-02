`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2026 06:25:20 PM
// Design Name: 
// Module Name: tb_riscv
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

module tb_riscv();
    logic clk;
    logic rst_n;
    logic [REG_SIZE - 1:0]  trace_pc;
    logic [INST_SIZE - 1:0] trace_inst;

    riscv u_dut (
        .clk,
        .rst_n,
        .trace_pc,
        .trace_inst
    );

    always #5 clk = ~clk;

    initial begin
        $display("=== BEGIN ===");

        clk = 0;
        rst_n = 0;

        #20;
        rst_n = 1;

        repeat(100) @(posedge clk);
        
        $display("=== END ===");
        $finish;
    end

    // =================================================================
    // MONITOR
    // =================================================================
    always_ff @(posedge clk) begin
        if (rst_n) begin
            
            // 1. HAZARD & STALL MONITORING
            if (!u_dut.u_datapath.u_hazard.pc_en) begin
                $display("[Time: %0t ns] [STALL]   Inst [%h] in Decode is waiting for data.", 
                          $time, u_dut.u_datapath.u_id.inst_e);
            end

            if (u_dut.u_datapath.u_hazard.flush) begin
                $display("[Time: %0t ns] [FLUSH]   Flushed Inst [%h] in Decode to NOP.", 
                          $time, u_dut.u_datapath.u_id.f_inst);
            end

            // 2. CONTROL FLOW (BRANCH/JUMP) MONITORING
            if (u_dut.u_datapath.u_ex.pc_sel) begin
                $display("[Time: %0t ns] [JUMP]    Branch/Jump Taken! Target PC: %h", 
                          $time, u_dut.u_datapath.u_ex.t_pc);
            end

            // 3. MULTI-CYCLE DIVIDER MONITORING
            if (u_dut.u_datapath.u_ex.is_div_op_e) begin
                $display("[Time: %0t ns] [DIV_IN]  Divider started for Inst [%h]", 
                          $time, u_dut.u_datapath.u_ex.inst_e);
            end

            if (u_dut.u_datapath.u_ex.div_stage_7[6] == 1'b1) begin
                $display("[Time: %0t ns] [DIV_OUT] Divider completed [%h] | Result = %0d", 
                          $time, 
                          u_dut.u_datapath.u_ex.div_inst_end,
                          (u_dut.u_datapath.u_ex.div_stage_7[5]) ? u_dut.u_datapath.u_ex.remainder : u_dut.u_datapath.u_ex.quotient);
            end

            // 4. WRITEBACK & INSTRUCTION COMPLETION MONITORING
            if (u_dut.u_datapath.u_wb.inst_w != 32'h00000013 && u_dut.u_datapath.u_wb.inst_w != 32'h00000000) begin
                
                logic [6:0] opcode = u_dut.u_datapath.u_wb.inst_w[6:0];
                
                // ALU, Load, Jump
                if (u_dut.u_datapath.u_wb.reg_we_w && u_dut.u_datapath.u_wb.rd_w != 0) begin
                    $display("[Time: %0t ns] [WB]      PC: %h | INST: %h | Write: x%0d = %0d", 
                              $time, u_dut.u_datapath.u_wb.c_pc_w, u_dut.u_datapath.u_wb.inst_w,
                              u_dut.u_datapath.u_wb.rd_w, u_dut.u_datapath.u_wb.d_rd_w);
                end 
                
                // DIV (Opcode ALU: 0110011 with reg_write = 0)
                else if (opcode == 7'b0110011 && u_dut.u_datapath.u_wb.reg_we_w == 0) begin
                    $display("[Time: %0t ns] [WB]      PC: %h | INST: %h | (Divider Shell - Wait for DIV_OUT)", 
                              $time, u_dut.u_datapath.u_wb.c_pc_w, u_dut.u_datapath.u_wb.inst_w);
                end
                
                // Store(Opcode Store: 0100011)
                else if (opcode == 7'b0100011) begin
                    $display("[Time: %0t ns] [WB]      PC: %h | INST: %h | (Store to Memory)", 
                              $time, u_dut.u_datapath.u_wb.c_pc_w, u_dut.u_datapath.u_wb.inst_w);
                end
                
                // Branch (Opcode Branch: 1100011)
                else if (opcode == 7'b1100011) begin
                    $display("[Time: %0t ns] [WB]      PC: %h | INST: %h | (Branch evaluation passed)", 
                              $time, u_dut.u_datapath.u_wb.c_pc_w, u_dut.u_datapath.u_wb.inst_w);
                end
                
                       else begin
                    $display("[Time: %0t ns] [WB]      PC: %h | INST: %h | (No write operation)", 
                              $time, u_dut.u_datapath.u_wb.c_pc_w, u_dut.u_datapath.u_wb.inst_w);
                end
            end
            
        end
    end

endmodule
