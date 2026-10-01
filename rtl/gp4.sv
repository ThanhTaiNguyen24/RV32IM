`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 04:02:29 PM
// Design Name: 
// Module Name: gp4
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
/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits internally would generate a carry-out (independent of cin)
 * @param pout whether these 4 bits internally would propagate an incoming carry from cin
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(
        input logic [3:0] gin, pin,
        input logic cin,
        output logic gout, pout,
        output logic [2:0] cout
    );
    assign cout[0] = gin[0] | (pin[0] & cin);
    assign cout[1] = gin[1] | (pin[1] & cout[0]);
    assign cout[2] = gin[2] | (pin[2] & cout[1]);

    assign pout = &pin;
    assign gout = gin[3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | (pin[3] & pin[2] & pin[1] & gin[0]);
endmodule
