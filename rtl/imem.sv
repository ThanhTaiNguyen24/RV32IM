`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2026 01:14:37 PM
// Design Name: 
// Module Name: imem
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

module imem (
    input  logic [REG_SIZE - 1:0]  c_pc_f,
    output logic [INST_SIZE - 1:0] f_inst
);

    localparam int addr_msb = $clog2(NUM_WORDS);
    localparam int addr_lsb = 2;

    logic [INST_SIZE - 1:0] iram [0:NUM_WORDS-1];

    initial begin
        $readmemh("imem.mem", iram);
    end

    // byte address
    assign f_inst = iram[c_pc_f[addr_msb + 1 : addr_lsb]];

endmodule
