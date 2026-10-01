`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 04:02:29 PM
// Design Name: 
// Module Name: gp1
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


module gp1(
        input logic a,b,
        output logic g,p
    );
    assign g = a & b;
    assign p = a | b;   
endmodule
