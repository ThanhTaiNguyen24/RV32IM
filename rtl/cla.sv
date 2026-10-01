`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 04:02:29 PM
// Design Name: 
// Module Name: cla
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

module cla (
    input logic [31:0]  a, b,
    input logic         cin,
    output logic [31:0] sum
);

    logic [31:0] g, p;
    logic [7:0] g4, p4;

    logic [31:0] c_in_full;
    logic [7:0] cin_gp4;

    logic [6:0] cout_gp8;


    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_gp1
            gp1 gp1_inst (
                .a(a[i]), 
                .b(b[i]), 
                .g(g[i]), 
                .p(p[i])
            );
        end
    endgenerate

    gp8 gp8_top (
        .gin(g4), 
        .pin(p4), 
        .cin(cin),
        .gout(),         
        .pout(),         
        .cout(cout_gp8)  
    );

    assign cin_gp4[0] = cin;          
    assign cin_gp4[7:1] = cout_gp8; 

    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : gen_gp4
            gp4 gp4_inst (
                .gin(g[(j*4) +: 4]),
                .pin(p[(j*4) +: 4]), 
                .cin(cin_gp4[j]),
                .gout(g4[j]),         
                .pout(p4[j]),         
                .cout(c_in_full[4*j+3 : 4*j+1]) 
            );
        end
    endgenerate

    assign c_in_full[0]    = cin;
    assign c_in_full[4]    = cout_gp8[0]; 
    assign c_in_full[8]    = cout_gp8[1]; 
    assign c_in_full[12]   = cout_gp8[2]; 
    assign c_in_full[16]   = cout_gp8[3]; 
    assign c_in_full[20]   = cout_gp8[4]; 
    assign c_in_full[24]   = cout_gp8[5]; 
    assign c_in_full[28]   = cout_gp8[6]; 

    assign sum = a ^ b ^ c_in_full;

endmodule
