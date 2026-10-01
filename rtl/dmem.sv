`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2026 12:54:36 PM
// Design Name: 
// Module Name: dmem
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
module dmem(
    input  logic                   clk,
    input  logic [3:0]             store_we_dmem,
    input  logic [REG_SIZE - 1:0]  store_addr_dmem,
    
    input  logic [3:0][7:0]        d_store_dmem_m,
    output logic [3:0][7:0]        d_load_dmem
);

    localparam int addr_msb = $clog2(NUM_WORDS);
    localparam int addr_lsb = 2;
    // Packed Array
    logic [3:0][7:0] dram [0:NUM_WORDS-1];

    initial begin
        $readmemh("dmem.mem", dram);
    end

    // Async read
    assign d_load_dmem = dram[store_addr_dmem[addr_msb + 1 : addr_lsb]];

    // Sync write
    always_ff @(posedge clk) begin
        for (int i = 0; i < 4; i++) begin
            if (store_we_dmem[i]) begin
                dram[store_addr_dmem[addr_msb + 1 : addr_lsb]][i] <= d_store_dmem_m[i];
            end
        end
    end

endmodule