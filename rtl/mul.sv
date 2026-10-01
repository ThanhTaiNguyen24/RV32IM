`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 04:07:45 PM
// Design Name: 
// Module Name: mul
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


module mul (
    input  logic [REG_SIZE -  1:0] a,
    input  logic [REG_SIZE - 1:0] b,
    input  logic [4:0]  alu_ctrl_e,
    output logic  [REG_SIZE - 1:0] result
);

    // SIGN-EXTEND và ZERO-EXTEND
    logic signed [63:0] a_s = {{32{a[31]}}, a};
    logic signed [63:0] b_s = {{32{b[31]}}, b};

    logic [63:0]        a_u = {32'b0, a};
    logic [63:0]        b_u = {32'b0, b};

    logic signed [63:0] r_ss  = a_s * b_s;  // signed × signed
    logic signed [63:0] r_su  = a_s * b_u;  // signed × unsigned
    logic        [63:0] r_uu  = a_u * b_u;  // unsigned × unsigned

    always @(*) begin
        case (alu_ctrl_e)
            ALU_MUL:     result = r_ss[31:0];   // MUL     ? low 32 bits
            ALU_MULH:    result = r_ss[63:32];  // MULH    ? high 32 bits (signed×signed)
            ALU_MULSU:   result = r_su[63:32];  // MULHSU  ? high 32 bits (signed×unsigned)
            ALU_MULU:    result = r_uu[63:32];  // MULHU   ? high 32 bits (unsigned×unsigned)
            default:      result = '0;
        endcase
    end

endmodule
