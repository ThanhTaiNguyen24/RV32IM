# RV32IM UVM Testbench

## What Is Included

`rv32im_uvm_tb.sv` contains a small UVM agent and one self-checking directed test. The program-loading driver uses UVM HDL backdoor access because the DUT exposes no external instruction or data memory ports. The monitor samples the retirement trace; the scoreboard checks that retired instructions have known values and aligned PCs. The test also checks architectural registers through a backdoor read.

The driver replaces every instruction word with a NOP and clears every data-memory word before releasing reset. `imem.mem` and `dmem.mem` are startup placeholders for the RTL `$readmemh` calls; the UVM driver supplies the actual test contents.

## Directed Test Coverage

Run `rv32im_directed_test` to exercise:

| Case | Stimulus / expected result |
| --- | --- |
| Reset and fetch | PC starts at zero and retires valid instructions |
| Integer ALU | ADDI, ADD, SUB, AND, OR, XOR and architectural register results |
| Forwarding | An immediately dependent ADDI/ADD pair computes x3 and x4 correctly |
| Store/load | SW followed by LW returns the stored word |
| Load-use hazard | An ADD consumes the immediately preceding LW result |
| Branch flush | A taken BNE skips a write to x12 |
| JAL flush/link | JAL skips a write to x14 and writes the return PC to x13 |
| M extension | MUL and signed DIV produce x16=120 and x17=3 |
| Divider dependency | An instruction consuming x17 waits and then writes x18=4 |
| x0 invariant | x0 remains zero |

Additional recommended tests, not yet encoded in this starter test, are listed below. Add each as a separate `uvm_test` or sequence and check final architectural state as well as the trace.

- Arithmetic corner cases: signed overflow, negative operands, shift amounts 0 and 31, SLT versus SLTU, and writes targeting x0.
- Load/store formats: LB/LBU, LH/LHU, SB/SH, byte offsets 0 through 3, and read-after-write behavior.
- Control flow: not-taken BEQ/BNE/BLT/BGE/BLTU/BGEU, negative branch offsets, JALR target alignment, and consecutive redirects.
- Divider: DIVU/REM/REMU, negative operands, divisor zero, minimum signed integer divided by -1, and back-to-back independent divides.
- Hazards: both source operands dependent on a load, stores dependent on a load base/data, multiple forwarding sources, and ALU/divider writeback collisions.
- Robustness: reset asserted while the pipeline/divider is active, illegal instruction handling, and behavior near the 512-word memory boundary.

## Questa Example

Compile and run with a Questa installation that provides the UVM library. Run from this directory so the RTL memory-image paths resolve:

```powershell
vlog -sv -L uvm -f rtl_files.f rv32im_uvm_tb.sv
vsim -c -voptargs=+acc tb_top +UVM_TESTNAME=rv32im_directed_test -do "run -all; quit -f"
```

The design uses hierarchical UVM HDL access, so retain signal visibility (`+acc`). For another simulator, compile `rtl_files.f` in order, enable its UVM library and HDL access support, and set the simulation working directory to `tb/uvm`.