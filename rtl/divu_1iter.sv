`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 03:06:40 PM
// Design Name: 
// Module Name: divu_1iter
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


module divu_1iter (
    input logic [31:0] i_dividend,
    input logic [31:0] i_divisor,
    input logic [31:0] i_remainder,
    input logic [31:0] i_quotient,
    output logic [31:0] o_dividend,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);

    logic [31:0] partial_rem;
    assign partial_rem = {i_remainder[30:0], i_dividend[31]};

    always @(*) begin
        o_dividend = i_dividend << 1; 
        
        if (partial_rem >= i_divisor) begin
            o_remainder = partial_rem - i_divisor; 
            o_quotient  = (i_quotient << 1) | 1'b1; 
        end else begin
            o_remainder = partial_rem;             
            o_quotient  = (i_quotient << 1) | 1'b0; 
        end
    end

endmodule