# RV64I RISC-V Processor

Complete 64-bit RISC-V processor in Verilog. Executes real RV64I assembly programs.

STATUS: WORKING

## Architecture

- 64-bit Harvard architecture (separate instruction/data memory)
- Single-cycle execution
- Modular design
- RV64I instruction set

## Modules

- control.v       - Top-level control unit
- fetch.v         - Instruction fetch + PC
- decode.v        - Instruction decode
- regfile.v       - 32x64-bit register file
- alu.v           - Arithmetic logic unit
- load_store.v    - Memory operations
- memory.v        - Instruction memory
- data_memory.v   - Data memory

## Features

- [✓] Instruction fetch and decode
- [✓] 32 registers (x0 hardwired to 0)
- [✓] ALU operations (add, sub, and, or, xor, sll, srl, sra, slt, sltu)
- [✓] Load/store operations (LB/LH/LW/LD/LBU/LHU/LWU/SB/SH/SW/SD)
- [✓] Memory subsystem with hex file loading
- [✓] Complete datapath integration

## Usage

1. Assemble RISC-V code to machine code
2. Put instructions in memory.hex
3. Put data in data.hex (optional)
4. Run simulation

## Test Program

```
.section .text
.global _start

_start:

     # First, store some test data to memory
    addi x5, x0, 100        # x5 = 100 (first operand)
    addi x6, x0, 50         # x6 = 50 (second operand)
    
    # Store the operands to memory
    sd x5, 0(x0)            # Store 100 to address 0
    sd x6, 8(x0)            # Store 50 to address 8
    
    # Now read the data back from memory
    ld x7, 0(x0)            # x7 = load from address 0 (should be 100)
    ld x8, 8(x0)            # x8 = load from address 8 (should be 50)
    
    # Perform ALU operations on the loaded data
    add x9, x7, x8          # x9 = 100 + 50 = 150
    sub x10, x7, x8         # x10 = 100 - 50 = 50
    
    # Store ALU results back to memory
    sd x9, 16(x0)           # Store sum (150) to address 16
    sd x10, 24(x0)          # Store difference (50) to address 24
    
    # Load back the results to verify
    ld x11, 16(x0)          # x11 = 150 (verify sum)
    ld x12, 24(x0)          # x12 = 50 (verify difference)
    
    # End
    nop
    nop
```

Results: Successfully stores, loads, computes, and verifies data.

## TODO

Pipeline Implementation (6 stages):
- Stage 1: Fetch
- Stage 2: Decode  
- Stage 3: Execute (ALU/Branch/Load-Store)
- Stage 4: Memory
- Stage 5: Writeback
- Stage 6: Commit

Pipeline additions needed:
- Pipeline registers between stages
- Hazard detection unit
- Data forwarding network
- Branch prediction
- Stall/flush control

Current: Single-cycle processor
Target: Pipelined processor with ~1 IPC
