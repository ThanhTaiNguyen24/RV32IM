`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 01:06:19 PM
// Design Name: 
// Module Name: def_pkg
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


package RV32_PKG;

    // =================================================================
    // SIZE DEFINE
    // =================================================================
    localparam int NUM_WORDS        = 512;
    localparam int REG_SIZE         = 32;
    localparam int INST_SIZE        = 32;
    localparam int OPCODE_SIZE      = 7;
    localparam int ALU_CTRL_SIZE    = 5;
    localparam int BRANCH_TYPE_SIZE = 3;
    localparam int STORE_TYPE_SIZE  = 3;
    localparam int LOAD_TYPE_SIZE   = 3;

    localparam int DIVIDER_STAGES   = 8;

    // =================================================================
    // INSTRUCTION DEFINE
    // =================================================================

    // OPCODES
    localparam logic [OPCODE_SIZE-1:0] OP_LOAD    = 7'b00_000_11;
    localparam logic [OPCODE_SIZE-1:0] OP_STORE   = 7'b01_000_11;
    localparam logic [OPCODE_SIZE-1:0] OP_BRANCH  = 7'b11_000_11;
    localparam logic [OPCODE_SIZE-1:0] OP_JALR    = 7'b11_001_11;
    localparam logic [OPCODE_SIZE-1:0] OP_MISCMEM = 7'b00_011_11;
    localparam logic [OPCODE_SIZE-1:0] OP_JAL     = 7'b11_011_11;

    localparam logic [OPCODE_SIZE-1:0] OP_REGIMM  = 7'b00_100_11;
    localparam logic [OPCODE_SIZE-1:0] OP_REGREG  = 7'b01_100_11;
    localparam logic [OPCODE_SIZE-1:0] OP_ENVIRON = 7'b11_100_11;

    localparam logic [OPCODE_SIZE-1:0] OP_AUIPC   = 7'b00_101_11;
    localparam logic [OPCODE_SIZE-1:0] OP_LUI     = 7'b01_101_11;

    // ALU CONTROL
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_AND          = 5'b00000;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_OR           = 5'b00001;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_ADD          = 5'b00010;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_SUB          = 5'b00011;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_LSHIFT_LEFT  = 5'b00100;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_LSHIFT_RIGHT = 5'b00101;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_ASHIFT_RIGHT = 5'b00110;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_XOR          = 5'b00111;   
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_MUL          = 5'b01000;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_MULH         = 5'b01001;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_MULSU        = 5'b01010;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_MULU         = 5'b01011;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_DIV          = 5'b01100;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_DIVU         = 5'b01101;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_REM          = 5'b01110;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_REMU         = 5'b01111;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_SLT          = 5'b10000;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_SLTU         = 5'b10001;
    localparam logic [ALU_CTRL_SIZE-1:0] ALU_NOP          = 5'b11111;

    // BRANCH TYPES
    localparam logic [BRANCH_TYPE_SIZE-1:0] BEQ  = 3'b001;
    localparam logic [BRANCH_TYPE_SIZE-1:0] BNE  = 3'b010;
    localparam logic [BRANCH_TYPE_SIZE-1:0] BLT  = 3'b011;
    localparam logic [BRANCH_TYPE_SIZE-1:0] BGE  = 3'b100;
    localparam logic [BRANCH_TYPE_SIZE-1:0] BLTU = 3'b101;
    localparam logic [BRANCH_TYPE_SIZE-1:0] BGEU = 3'b110;

    // STORE TYPES
    localparam logic [STORE_TYPE_SIZE-1:0] SB = 3'b001;
    localparam logic [STORE_TYPE_SIZE-1:0] SH = 3'b010;
    localparam logic [STORE_TYPE_SIZE-1:0] SW = 3'b100;

    // JUMP TYPES 
    localparam logic JAL  = 1'b0;
    localparam logic JALR = 1'b1;

    // LOAD TYPES
    localparam logic [LOAD_TYPE_SIZE-1:0] LB  = 3'b000;
    localparam logic [LOAD_TYPE_SIZE-1:0] LH  = 3'b001;
    localparam logic [LOAD_TYPE_SIZE-1:0] LW  = 3'b010;
    localparam logic [LOAD_TYPE_SIZE-1:0] LBU = 3'b011;
    localparam logic [LOAD_TYPE_SIZE-1:0] LHU = 3'b100;

endpackage
