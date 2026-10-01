`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 03:05:20 PM
// Design Name: 
// Module Name: div_pipelined
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


module div_pipelined (
    input logic         clk,     
    input logic         rst_n, 
    input logic         is_signed,  
    input logic [31:0]  i_dividend,
    input logic [31:0]  i_divisor,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);

    logic sign_dividend;
    logic sign_divisor;
    logic [31:0] abs_dividend;
    logic [31:0] abs_divisor;
    logic negate_quot_in;
    logic negate_rem_in;

    assign sign_dividend = is_signed & i_dividend[31];
    assign sign_divisor  = is_signed & i_divisor[31];
    assign abs_dividend  = sign_dividend ? -i_dividend : i_dividend;
    assign abs_divisor   = sign_divisor  ? -i_divisor  : i_divisor;
    assign negate_quot_in = sign_dividend ^ sign_divisor;
    assign negate_rem_in  = sign_dividend;

    logic [31:0] p_divisor   [0:7]; 
    logic [31:0] p_remainder [0:7]; 
    logic [31:0] p_quotient  [0:7]; 
    logic [31:0] p_dividend  [0:7]; 
    
    logic p_neg_quot [0:7]; 
    logic p_neg_rem  [0:7]; 

    logic [31:0] stage_div_out  [0:7];
    logic [31:0] stage_rem_out  [0:7];
    logic [31:0] stage_quot_out [0:7];

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_stages
            logic [31:0] temp_div  [0:4];
            logic [31:0] temp_rem  [0:4];
            logic [31:0] temp_quot [0:4];

            if (i == 0) begin
                assign temp_div[0]  = abs_dividend;
                assign temp_rem[0]  = '0;
                assign temp_quot[0] = '0;
            end else begin
                assign temp_div[0]  = p_dividend[i-1];
                assign temp_rem[0]  = p_remainder[i-1];
                assign temp_quot[0] = p_quotient[i-1];
            end

            for (j = 0; j < 4; j = j + 1) begin : gen_iters
                divu_1iter u_iter (
                    .i_dividend (temp_div[j]),
                    .i_divisor  (i == 0 ? abs_divisor : p_divisor[i-1]),
                    .i_remainder(temp_rem[j]),
                    .i_quotient (temp_quot[j]),
                    .o_dividend (temp_div[j+1]),
                    .o_remainder(temp_rem[j+1]),
                    .o_quotient (temp_quot[j+1])
                );
            end

            assign stage_div_out[i]  = temp_div[4];
            assign stage_rem_out[i]  = temp_rem[4];
            assign stage_quot_out[i] = temp_quot[4];
        end
    endgenerate

    integer k;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < 8; k = k + 1) begin
                p_dividend[k] <= 0; p_divisor[k] <= 0;
                p_remainder[k]<= 0; p_quotient[k]<= 0;
                p_neg_quot[k] <= 0; p_neg_rem[k] <= 0;
            end
        end else begin
            p_dividend[0]  <= stage_div_out[0];
            p_remainder[0] <= stage_rem_out[0];
            p_quotient[0]  <= stage_quot_out[0];
            p_divisor[0]   <= abs_divisor;     
            p_neg_quot[0]  <= negate_quot_in;  
            p_neg_rem[0]   <= negate_rem_in;

            for (k = 1; k < 8; k = k + 1) begin
                p_dividend[k]  <= stage_div_out[k];
                p_remainder[k] <= stage_rem_out[k];
                p_quotient[k]  <= stage_quot_out[k];
                p_divisor[k]   <= p_divisor[k-1]; 
                p_neg_quot[k]  <= p_neg_quot[k-1];
                p_neg_rem[k]   <= p_neg_rem[k-1];
            end
        end
    end
    
    always @* begin
        o_remainder <= p_neg_rem[7]  ? -p_remainder[7] : p_remainder[7];
        o_quotient  <= p_neg_quot[7] ? -p_quotient[7]  : p_quotient[7];
    end
endmodule


