`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2026 12:16:08 PM
// Design Name: 
// Module Name: control_unit
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

module control_unit (
    input  logic [OPCODE_SIZE-1:0]      opcode,
    input  logic [2:0]                  funct3,
    input  logic [6:0]                  funct7,
    
    output logic                        is_div_op,
    //Control Signal for ALU
    output logic [ALU_CTRL_SIZE-1:0]    alu_ctrl,
    output logic                        alu_src, //select between rs2 and immediate
    //Data Memory Control
    output logic                        mem_write, //mem write enable (SB,SH,SW)
    output logic                        mem_read, //mem read enable (LB, LH, LW)
    
    output logic [STORE_TYPE_SIZE-1:0]  store_type, //select between SB, SH, SW
    output logic [LOAD_TYPE_SIZE-1:0]   load_type, //select between load type
    
    //Reg File Control
    output logic                        reg_write, //write result to rd (R-type, I-type, Load, U-type, Jump); except Store and Branch
    output logic                        mem_to_reg, //control MUX in WB stage (1: Data Memory (load) to rd; 2: ALU to rd)
    
    //Branch & Jump
    output logic                        branch,
    output logic [BRANCH_TYPE_SIZE-1:0] branch_type, //branch type (BEQ, BNE, BGE, BLT,...)
    output logic                        jal, //Jump and Link (PC Target = PC + Immediate)
    output logic                        jalr, //Jump and Link Register (PC Target = rs1 + immediate) (Save cur_pc + 4 to rd)
    
    //U-type (Immediate 20-bit)
    output logic                        auipc, lui,

    //Exceptions
    output logic                        illegal_inst, //Active when not found in Opcode, Funct3 or Funct7
    output logic                        halt
);

    logic inst_lui;
    logic inst_auipc;
    logic inst_jal;
    logic inst_jalr;
    
    logic inst_beq;
    logic inst_bne;
    logic inst_blt;
    logic inst_bge;
    logic inst_bltu;
    logic inst_bgeu;
    
    logic inst_lb;
    logic inst_lh;
    logic inst_lw;
    logic inst_lbu;
    logic inst_lhu;
    
    logic inst_sb;
    logic inst_sh;
    logic inst_sw;
    
    logic inst_addi;
    logic inst_slti;
    logic inst_sltiu;
    logic inst_xori;
    logic inst_ori;
    logic inst_andi;
    
    logic inst_slli;
    logic inst_srli;
    logic inst_srai;
    
    logic inst_add;
    logic inst_sub;
    logic inst_sll;
    logic inst_slt;
    logic inst_sltu;
    logic inst_xor;
    logic inst_srl;
    logic inst_sra;
    logic inst_or;
    logic inst_and;
    
    logic inst_mul;
    logic inst_mulh;
    logic inst_mulhsu;
    logic inst_mulhu;
    logic inst_div;
    logic inst_divu;
    logic inst_rem;
    logic inst_remu;
    
    logic inst_ecall;
    logic inst_fence;
    // =================================================================
    // INSTRUCTION DECODE
    // =================================================================
    assign inst_lui    = (opcode == OP_LUI);
    assign inst_auipc  = (opcode == OP_AUIPC);
    assign inst_jal    = (opcode == OP_JAL);
    assign inst_jalr   = (opcode == OP_JALR);
    
    assign inst_beq    = (opcode == OP_BRANCH)  & (funct3 == 3'b000);
    assign inst_bne    = (opcode == OP_BRANCH)  & (funct3 == 3'b001);
    assign inst_blt    = (opcode == OP_BRANCH)  & (funct3 == 3'b100);
    assign inst_bge    = (opcode == OP_BRANCH)  & (funct3 == 3'b101);
    assign inst_bltu   = (opcode == OP_BRANCH)  & (funct3 == 3'b110);
    assign inst_bgeu   = (opcode == OP_BRANCH)  & (funct3 == 3'b111);
    
    assign inst_lb     = (opcode == OP_LOAD)    & (funct3 == 3'b000);
    assign inst_lh     = (opcode == OP_LOAD)    & (funct3 == 3'b001);
    assign inst_lw     = (opcode == OP_LOAD)    & (funct3 == 3'b010);
    assign inst_lbu    = (opcode == OP_LOAD)    & (funct3 == 3'b100);
    assign inst_lhu    = (opcode == OP_LOAD)    & (funct3 == 3'b101);
    
    assign inst_sb     = (opcode == OP_STORE)   & (funct3 == 3'b000);
    assign inst_sh     = (opcode == OP_STORE)   & (funct3 == 3'b001);
    assign inst_sw     = (opcode == OP_STORE)   & (funct3 == 3'b010);
    
    assign inst_addi   = (opcode == OP_REGIMM)  & (funct3 == 3'b000);
    assign inst_slti   = (opcode == OP_REGIMM)  & (funct3 == 3'b010);
    assign inst_sltiu  = (opcode == OP_REGIMM)  & (funct3 == 3'b011);
    assign inst_xori   = (opcode == OP_REGIMM)  & (funct3 == 3'b100);
    assign inst_ori    = (opcode == OP_REGIMM)  & (funct3 == 3'b110);
    assign inst_andi   = (opcode == OP_REGIMM)  & (funct3 == 3'b111);
    
    assign inst_slli   = (opcode == OP_REGIMM)  & (funct3 == 3'b001) & (funct7 == 7'd0);
    assign inst_srli   = (opcode == OP_REGIMM)  & (funct3 == 3'b101) & (funct7 == 7'd0);
    assign inst_srai   = (opcode == OP_REGIMM)  & (funct3 == 3'b101) & (funct7 == 7'b0100000);
    
    assign inst_add    = (opcode == OP_REGREG)  & (funct3 == 3'b000) & (funct7 == 7'd0);
    assign inst_sub    = (opcode == OP_REGREG)  & (funct3 == 3'b000) & (funct7 == 7'b0100000);
    assign inst_sll    = (opcode == OP_REGREG)  & (funct3 == 3'b001) & (funct7 == 7'd0);
    assign inst_slt    = (opcode == OP_REGREG)  & (funct3 == 3'b010) & (funct7 == 7'd0);
    assign inst_sltu   = (opcode == OP_REGREG)  & (funct3 == 3'b011) & (funct7 == 7'd0);
    assign inst_xor    = (opcode == OP_REGREG)  & (funct3 == 3'b100) & (funct7 == 7'd0);
    assign inst_srl    = (opcode == OP_REGREG)  & (funct3 == 3'b101) & (funct7 == 7'd0);
    assign inst_sra    = (opcode == OP_REGREG)  & (funct3 == 3'b101) & (funct7 == 7'b0100000);
    assign inst_or     = (opcode == OP_REGREG)  & (funct3 == 3'b110) & (funct7 == 7'd0);
    assign inst_and    = (opcode == OP_REGREG)  & (funct3 == 3'b111) & (funct7 == 7'd0);
    
    assign inst_mul    = (opcode == OP_REGREG)  & (funct3 == 3'b000) & (funct7 == 7'd1);
    assign inst_mulh   = (opcode == OP_REGREG)  & (funct3 == 3'b001) & (funct7 == 7'd1);
    assign inst_mulhsu = (opcode == OP_REGREG)  & (funct3 == 3'b010) & (funct7 == 7'd1);
    assign inst_mulhu  = (opcode == OP_REGREG)  & (funct3 == 3'b011) & (funct7 == 7'd1);
    assign inst_div    = (opcode == OP_REGREG)  & (funct3 == 3'b100) & (funct7 == 7'd1);
    assign inst_divu   = (opcode == OP_REGREG)  & (funct3 == 3'b101) & (funct7 == 7'd1);
    assign inst_rem    = (opcode == OP_REGREG)  & (funct3 == 3'b110) & (funct7 == 7'd1);
    assign inst_remu   = (opcode == OP_REGREG)  & (funct3 == 3'b111) & (funct7 == 7'd1);
    
    assign inst_ecall  = (opcode == OP_ENVIRON) & (funct3 == 3'b000) & (funct7 == 7'd0);
    assign inst_fence  = (opcode == OP_MISCMEM);

    // =================================================================
    // CONTROL LOGIC
    // =================================================================
    always_comb begin
        illegal_inst = '0;
        halt         = '0;
        alu_ctrl      = ALU_NOP;
        mem_write     = '0;
        reg_write     = '0;
        mem_to_reg     = '0;
        alu_src       = '0;
        jal          = '0;
        jalr         = '0;
        lui          = '0;
        auipc        = '0;
        branch       = '0;
        branch_type   = '0;
        mem_read      = '0;
        store_type    = '0;
        load_type     = '0;
        is_div_op    = (inst_div | inst_divu | inst_rem | inst_remu);

        case (opcode)
            // -----------------------------------------------------
            // R-type
            // -----------------------------------------------------
            OP_REGREG: begin
                reg_write = 1'b1;
                if      (inst_add)    alu_ctrl = ALU_ADD;
                else if (inst_sub)    alu_ctrl = ALU_SUB;
                else if (inst_sll)    alu_ctrl = ALU_LSHIFT_LEFT;
                else if (inst_slt)    alu_ctrl = ALU_SLT;    
                else if (inst_sltu)   alu_ctrl = ALU_SLTU;   
                else if (inst_xor)    alu_ctrl = ALU_XOR;
                else if (inst_srl)    alu_ctrl = ALU_LSHIFT_RIGHT;
                else if (inst_sra)    alu_ctrl = ALU_ASHIFT_RIGHT;
                else if (inst_or)     alu_ctrl = ALU_OR;
                else if (inst_and)    alu_ctrl = ALU_AND;
                else if (inst_mul)    alu_ctrl = ALU_MUL;
                else if (inst_mulh)   alu_ctrl = ALU_MULH;
                else if (inst_mulhsu) alu_ctrl = ALU_MULSU;
                else if (inst_mulhu)  alu_ctrl = ALU_MULU;
                else if (inst_div)    alu_ctrl = ALU_DIV;
                else if (inst_divu)   alu_ctrl = ALU_DIVU;
                else if (inst_rem)    alu_ctrl = ALU_REM;
                else if (inst_remu)   alu_ctrl = ALU_REMU;
                else                  illegal_inst = 1'b1;
            end

            // -----------------------------------------------------
            // I-type arithmetic
            // -----------------------------------------------------
            OP_REGIMM: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                if      (inst_addi)  alu_ctrl = ALU_ADD;
                else if (inst_slti)  alu_ctrl = ALU_SLT;
                else if (inst_sltiu) alu_ctrl = ALU_SLTU;
                else if (inst_xori)  alu_ctrl = ALU_XOR;
                else if (inst_ori)   alu_ctrl = ALU_OR;
                else if (inst_andi)  alu_ctrl = ALU_AND;
                else if (inst_slli)  alu_ctrl = ALU_LSHIFT_LEFT;
                else if (inst_srli)  alu_ctrl = ALU_LSHIFT_RIGHT;
                else if (inst_srai)  alu_ctrl = ALU_ASHIFT_RIGHT;
                else                 illegal_inst = 1'b1;
            end

            // -----------------------------------------------------
            // Load
            // -----------------------------------------------------
            OP_LOAD: begin
                alu_ctrl  = ALU_ADD;
                reg_write = 1'b1;
                mem_to_reg = 1'b1;
                alu_src   = 1'b1;
                mem_read  = 1'b1;
            
                case(funct3)
                    3'b000: load_type = LB;
                    3'b001: load_type = LH;
                    3'b010: load_type = LW;
                    3'b100: load_type = LBU;
                    3'b101: load_type = LHU;
                    default: illegal_inst = 1'b1;
                endcase
            end

            // -----------------------------------------------------
            // Store
            // -----------------------------------------------------
            OP_STORE: begin
                alu_ctrl  = ALU_ADD;
                mem_write = 1'b1;
                alu_src   = 1'b1;
            
                case(funct3)
                    3'b000: store_type = SB;
                    3'b001: store_type = SH;
                    3'b010: store_type = SW;
                    default: illegal_inst = 1'b1;
                endcase
            end

            // -----------------------------------------------------
            // Branch
            // -----------------------------------------------------
            OP_BRANCH: begin
                alu_ctrl = ALU_SUB;
                branch  = 1'b1;
            
                case(funct3)
                    3'b000: branch_type = BEQ;
                    3'b001: branch_type = BNE;
                    3'b100: branch_type = BLT;
                    3'b101: branch_type = BGE;
                    3'b110: branch_type = BLTU;
                    3'b111: branch_type = BGEU;
                    default: illegal_inst = 1'b1;
                endcase
            end

            // -----------------------------------------------------
            // Jump & Link (jal / jalR)
            // -----------------------------------------------------
            OP_JAL: begin
                jal      = 1'b1;
                reg_write = 1'b1;
                alu_ctrl  = ALU_NOP;
            end
        
            OP_JALR: begin
                jalr     = 1'b1;
                reg_write = 1'b1;
                alu_ctrl  = ALU_NOP;            
            end
            
            // -----------------------------------------------------
            // AUIPC / lui
            // -----------------------------------------------------
            OP_AUIPC: begin
                auipc    = 1'b1;
                reg_write = 1'b1;
                alu_ctrl  = ALU_ADD;             // rd = PC + immU
                alu_src   = 1'b1;
            end 
        
            OP_LUI: begin
                lui      = 1'b1;
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = ALU_ADD;             // rd = imm << 12
            end        

            // -----------------------------------------------------
            // Environment (ECALL)
            // -----------------------------------------------------
            OP_ENVIRON: begin
                halt = 1'b1;
            end 
        
            default: begin
                illegal_inst = 1'b1;
            end
        endcase
    end
endmodule
