`timescale 1ns/1ps

// This interface is the only pin-level connection the UVM environment needs.
interface rv32im_if(input logic clk);
    logic rst_n;
    logic [31:0] trace_pc;
    logic [31:0] trace_inst;

    // Sample after sequential logic has settled on each rising edge.
    clocking monitor_cb @(posedge clk);
        default input #1step;
        input rst_n;
        input trace_pc;
        input trace_inst;
    endclocking
endinterface

package rv32im_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class rv32im_program_item extends uvm_sequence_item;
        bit [31:0] instructions[];
        int unsigned run_cycles;
        logic [31:0] trace_pc;
        logic [31:0] trace_inst;

        `uvm_object_utils(rv32im_program_item)

        function new(string name = "rv32im_program_item");
            super.new(name);
        endfunction
    endclass

    class rv32im_sequencer extends uvm_sequencer #(rv32im_program_item);
        `uvm_component_utils(rv32im_sequencer)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    // The test sends an instruction image as one sequence item. The driver
    // deposits it into the DUT's internal ROM, resets the core, then runs it.
    class rv32im_driver extends uvm_driver #(rv32im_program_item);
        `uvm_component_utils(rv32im_driver)

        virtual rv32im_if vif;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual rv32im_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "rv32im_if was not configured")
        endfunction

        function void deposit_word(string path, bit [31:0] word_value);
            uvm_hdl_data_t value;
            value = '0;
            value[31:0] = word_value;
            if (!uvm_hdl_deposit(path, value))
                `uvm_fatal("HDL_DEPOSIT", $sformatf("Cannot deposit %s", path))
        endfunction

        task run_phase(uvm_phase phase);
            rv32im_program_item req;
            forever begin
                seq_item_port.get_next_item(req);

                // Keep the core in reset while both memories are made known.
                @(negedge vif.clk);
                vif.rst_n = 1'b0;
                for (int word_index = 0; word_index < 512; word_index++) begin
                    deposit_word(
                        $sformatf("tb_top.dut.u_memorypath.u_imem.iram[%0d]", word_index),
                        (word_index < req.instructions.size()) ? req.instructions[word_index] : 32'h00000013
                    );
                    deposit_word(
                        $sformatf("tb_top.dut.u_memorypath.u_dmem.dram[%0d]", word_index),
                        32'b0
                    );
                end

                repeat (2) @(posedge vif.clk);
                @(negedge vif.clk);
                vif.rst_n = 1'b1;
                repeat (req.run_cycles) @(posedge vif.clk);
                @(negedge vif.clk);
                seq_item_port.item_done();
            end
        endtask
    endclass

    class rv32im_monitor extends uvm_monitor;
        `uvm_component_utils(rv32im_monitor)

        virtual rv32im_if vif;
        uvm_analysis_port #(rv32im_program_item) trace_ap;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            trace_ap = new("trace_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual rv32im_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "rv32im_if was not configured")
        endfunction

        task run_phase(uvm_phase phase);
            rv32im_program_item trace;
            forever begin
                @(vif.monitor_cb);
                if (vif.monitor_cb.rst_n &&
                    vif.monitor_cb.trace_inst != 32'h00000000 &&
                    vif.monitor_cb.trace_inst != 32'h00000013) begin
                    trace = rv32im_program_item::type_id::create("trace");
                    trace.trace_pc = vif.monitor_cb.trace_pc;
                    trace.trace_inst = vif.monitor_cb.trace_inst;
                    trace_ap.write(trace);
                end
            end
        endtask
    endclass

    // The trace checker verifies every observed retirement is known and aligned.
    // Architectural result checks are made by the test using UVM backdoor reads.
    class rv32im_scoreboard extends uvm_component;
        `uvm_component_utils(rv32im_scoreboard)

        uvm_analysis_imp #(rv32im_program_item, rv32im_scoreboard) trace_export;
        int unsigned retired_count;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            trace_export = new("trace_export", this);
            retired_count = 0;
        endfunction

        function void write(rv32im_program_item trace);
            logic [31:0] pc;
            logic [31:0] instruction;
            pc = trace.trace_pc;
            instruction = trace.trace_inst;
            if ($isunknown({pc, instruction}))
                `uvm_error("TRACE_X", "Unknown value observed on retirement trace")
            if (pc[1:0] != 2'b00)
                `uvm_error("TRACE_ALIGN", $sformatf("Unaligned retirement PC %08x", pc))
            retired_count++;
        endfunction
    endclass

    class rv32im_agent extends uvm_agent;
        `uvm_component_utils(rv32im_agent)

        rv32im_sequencer sequencer;
        rv32im_driver driver;
        rv32im_monitor monitor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = rv32im_sequencer::type_id::create("sequencer", this);
            driver = rv32im_driver::type_id::create("driver", this);
            monitor = rv32im_monitor::type_id::create("monitor", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass

    class rv32im_env extends uvm_env;
        `uvm_component_utils(rv32im_env)

        rv32im_agent agent;
        rv32im_scoreboard scoreboard;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = rv32im_agent::type_id::create("agent", this);
            scoreboard = rv32im_scoreboard::type_id::create("scoreboard", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.monitor.trace_ap.connect(scoreboard.trace_export);
        endfunction
    endclass

    class rv32im_program_sequence extends uvm_sequence #(rv32im_program_item);
        bit [31:0] instructions[];
        int unsigned run_cycles;

        `uvm_object_utils(rv32im_program_sequence)

        function new(string name = "rv32im_program_sequence");
            super.new(name);
        endfunction

        task body();
            rv32im_program_item request;
            request = rv32im_program_item::type_id::create("request");
            start_item(request);
            request.instructions = instructions;
            request.run_cycles = run_cycles;
            finish_item(request);
        endtask
    endclass

    class rv32im_base_test extends uvm_test;
        `uvm_component_utils(rv32im_base_test)

        rv32im_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = rv32im_env::type_id::create("env", this);
        endfunction

        function automatic bit [31:0] enc_i(
            input bit [6:0] opcode, input int immediate,
            input bit [4:0] rs1, input bit [2:0] funct3, input bit [4:0] rd
        );
            return {immediate[11:0], rs1, funct3, rd, opcode};
        endfunction

        function automatic bit [31:0] enc_r(
            input bit [6:0] funct7, input bit [4:0] rs2,
            input bit [4:0] rs1, input bit [2:0] funct3,
            input bit [4:0] rd, input bit [6:0] opcode = 7'b0110011
        );
            return {funct7, rs2, rs1, funct3, rd, opcode};
        endfunction

        function automatic bit [31:0] enc_s(
            input int immediate, input bit [4:0] rs2,
            input bit [4:0] rs1, input bit [2:0] funct3
        );
            bit [11:0] imm;
            imm = immediate[11:0];
            return {imm[11:5], rs2, rs1, funct3, imm[4:0], 7'b0100011};
        endfunction

        function automatic bit [31:0] enc_b(
            input int immediate, input bit [4:0] rs2,
            input bit [4:0] rs1, input bit [2:0] funct3
        );
            bit [12:0] imm;
            imm = immediate[12:0];
            return {imm[12], imm[10:5], rs2, rs1, funct3,
                    imm[4:1], imm[11], 7'b1100011};
        endfunction

        function automatic bit [31:0] enc_j(input int immediate, input bit [4:0] rd);
            bit [20:0] imm;
            imm = immediate[20:0];
            return {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'b1101111};
        endfunction

        task automatic expect_reg(input int unsigned index, input bit [31:0] expected);
            uvm_hdl_data_t value;
            string path;
            path = $sformatf("tb_top.dut.u_datapath.u_id.u_rf.mem[%0d]", index);
            if (!uvm_hdl_read(path, value))
                `uvm_fatal("HDL_READ", $sformatf("Cannot read %s", path))
            if (value[31:0] !== expected)
                `uvm_error("REG_MISMATCH", $sformatf(
                    "x%0d expected %08x, got %08x", index, expected, value[31:0]))
        endtask

        task automatic run_program(rv32im_program_sequence seq_handle);
            seq_handle.start(env.agent.sequencer);
            #1ns;
            if (env.scoreboard.retired_count < 10)
                `uvm_error("TRACE_SHORT", $sformatf(
                    "Only %0d non-NOP instructions retired", env.scoreboard.retired_count))
            phase.drop_objection(this);
        endtask
    endclass

    // Directed cases: ALU forwarding, store/load, load-use stall, taken branch
    // flush, JAL link/flush, multiply, divide, and a consumer stalled on DIV.
    class rv32im_directed_test extends rv32im_base_test;
        `uvm_component_utils(rv32im_directed_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            rv32im_program_sequence program_seq;
            program_seq = rv32im_program_sequence::type_id::create("directed_sequence");
            program_seq.instructions = new[19];
            program_seq.instructions[0]  = enc_i(7'b0010011, 20, 0, 3'b000, 1); // x1 = 20
            program_seq.instructions[1]  = enc_i(7'b0010011, 6,  0, 3'b000, 2); // x2 = 6
            program_seq.instructions[2]  = enc_i(7'b0010011, 1,  1, 3'b000, 3); // forwarding: x3 = 21
            program_seq.instructions[3]  = enc_r(7'b0000000, 2, 3, 3'b000, 4);  // x4 = 27
            program_seq.instructions[4]  = enc_r(7'b0100000, 1, 4, 3'b000, 5);  // x5 = 7
            program_seq.instructions[5]  = enc_r(7'b0000000, 1, 4, 3'b111, 6);  // x6 = 16
            program_seq.instructions[6]  = enc_r(7'b0000000, 1, 4, 3'b110, 7);  // x7 = 31
            program_seq.instructions[7]  = enc_r(7'b0000000, 1, 4, 3'b100, 8);  // x8 = 15
            program_seq.instructions[8]  = enc_s(0, 4, 0, 3'b010);              // sw x4, 0(x0)
            program_seq.instructions[9]  = enc_i(7'b0000011, 0, 0, 3'b010, 10);// lw x10, 0(x0)
            program_seq.instructions[10] = enc_r(7'b0000000, 1, 10, 3'b000, 11);// load-use: x11 = 47
            program_seq.instructions[11] = enc_b(8, 0, 11, 3'b001);             // bne x11,x0,+8
            program_seq.instructions[12] = enc_i(7'b0010011, 99, 0, 3'b000, 12);// flushed, x12 stays zero
            program_seq.instructions[13] = enc_j(8, 13);                        // x13 = PC + 4
            program_seq.instructions[14] = enc_i(7'b0010011, 77, 0, 3'b000, 14);// flushed, x14 stays zero
            program_seq.instructions[15] = enc_i(7'b0010011, 42, 0, 3'b000, 15);// jump target
            program_seq.instructions[16] = enc_r(7'b0000001, 2, 1, 3'b000, 16);// mul x16,x1,x2
            program_seq.instructions[17] = enc_r(7'b0000001, 2, 1, 3'b100, 17);// div x17,x1,x2
            program_seq.instructions[18] = enc_i(7'b0010011, 1, 17, 3'b000, 18);// DIV dependency
            program_seq.run_cycles = 120;

            phase.raise_objection(this);
            run_program(program_seq);

            expect_reg(0,  32'd0);
            expect_reg(1,  32'd20);
            expect_reg(2,  32'd6);
            expect_reg(3,  32'd21);
            expect_reg(4,  32'd27);
            expect_reg(5,  32'd7);
            expect_reg(6,  32'd16);
            expect_reg(7,  32'd31);
            expect_reg(8,  32'd15);
            expect_reg(10, 32'd27);
            expect_reg(11, 32'd47);
            expect_reg(12, 32'd0);
            expect_reg(13, 32'd56);
            expect_reg(14, 32'd0);
            expect_reg(15, 32'd42);
            expect_reg(16, 32'd120);
            expect_reg(17, 32'd3);
            expect_reg(18, 32'd4);
            phase.drop_objection(this);
        endtask
    endclass
endpackage

module tb_top;
    import uvm_pkg::*;
    logic clk = 1'b0;
    rv32im_if vif(clk);

    always #5 clk = ~clk;

    riscv dut (
        .clk(clk),
        .rst_n(vif.rst_n),
        .trace_pc(vif.trace_pc),
        .trace_inst(vif.trace_inst)
    );

    initial begin
        vif.rst_n = 1'b0;
        uvm_config_db#(virtual rv32im_if)::set(null, "*", "vif", vif);
        run_test();
    end
endmodule