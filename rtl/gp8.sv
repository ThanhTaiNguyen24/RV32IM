`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 04:02:29 PM
// Design Name: 
// Module Name: gp8
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


module gp8(
    input logic [7:0] gin, pin,
    input logic cin,
    output logic gout, pout,
    output logic [6:0] cout);
    
    logic gout_low, pout_low;
    logic [2:0] cout_low; // carry C1, C2, C3
    logic gout_high, pout_high;
    logic [2:0] cout_high; // carry C5, C6, C7

    logic c4;
    
    gp4 low_4b (
        .gin(gin[3:0]), 
        .pin(pin[3:0]), 
        .cin(cin),
        .gout(gout_low), 
        .pout(pout_low),
        .cout(cout_low)     
    ); 
    
    assign c4 = gout_low | (pout_low & cin);
    
    gp4 high_4b (
        .gin(gin[7:4]),
        .pin(pin[7:4]),
        .cin(c4),          
        .gout(gout_high),
        .pout(pout_high),
        .cout(cout_high)    
    );
    
    assign cout[2:0] = cout_low;  
    assign cout[3]   = c4;        
    assign cout[6:4] = cout_high; 
   
    assign pout = pout_high & pout_low;
    assign gout = gout_high | (pout_high & gout_low);
     
endmodule
