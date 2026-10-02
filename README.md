# RISC-V 32-bit 5-Stage Pipelined CPU Core

This repository contains a 32-bit RISC-V CPU core implemented in SystemVerilog. The system utilizes a standard 5-stage pipeline architecture (Fetch, Decode, Execute, Memory, and Write Back) to optimize computational performance, the arithmetic execution core is enhanced with the integration of a custom Carry-Lookahead Adder.
![RISC-V 5-Stage Pipeline Architecture](assets/riscv_datapath_arch.png)
For a more detailed interactive view, the architecture is further described in the [draw.io schematic file](assets/riscv_architecture.drawio) located in the `assets` directory.
## Key Features

* **5-Stage Pipeline:** Implements standard instruction processing stages for optimized throughput.
* **Advanced Arithmetic Units:** Integrates a Carry-Lookahead Adder (CLA) for accelerated addition.
* **Data Forwarding:** Uses a bypass network to route computed data from later pipeline stages directly back to the arithmetic logic unit, resolving data dependencies without unnecessary stalling.
* **8-Stages Divider Integration:** Features a hardware divider that operates in parallel with the main instruction pipeline.
* **Hazard Management:** Detects and resolves control hazards, load-use data hazards, and structural writeback collisions.

## Special Architecture

### Hazard Detection Unit
The hazard management system controls pipeline stalls and flushes to maintain instruction integrity under many operational conditions.

* **Control Hazards:** Halts the program counter and flushes invalid instructions from the pipeline whenever a branch or jump alters the expected execution flow.
* **Load-Use Hazards:** Detects when an instruction in the decode phase requires data that is currently being fetched from memory by a preceding instruction. The system automatically inserts a wait state (stall) until the required data is safely retrieved.
* **Writeback Collisions:** Prevents structural conflicts by stalling the pipeline if a standard single-cycle arithmetic instruction and a multi-cycle division instruction attempt to write their results to the register file at the exact same clock cycle.

### 8-Stage Pipelined Divider
The divider unit handles operations that require multiple clock cycles without blocking independent instructions from executing, maximizing overall CPU efficiency.

* **Execution Tracking:** The core uses an internal shift mechanism to track the divider's active status, its target destination register, and its associated program counter across the multiple clock cycles required for computation.
* **Dependency Stalls:** The hazard system continuously monitors the active stages of the divider. If a decoded instruction requires a register that is currently being computed by the active division process, the system stalls the pipeline. However, independent instructions that do not rely on the division result are allowed to bypass the divider and execute normally.
* **Instruction Pass-through:** When a division instruction enters the execution phase, its original control flags are dynamically modified to disable immediate register writing. This allows the empty "shell" of the instruction to pass harmlessly through the remaining pipeline stages without corrupting the register file with incomplete data.
* **Write-back Override:** When the multi-cycle division is completed, the memory stage logic recognizes the finished computation, overrides the standard pipeline control flow, restores the write permissions, and safely routes the final quotient or remainder to the write-back stage to be saved.
