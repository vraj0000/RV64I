# RV64I RISC-V Processor

A complete 64-bit RISC-V processor implementation in Verilog supporting the RV64I instruction set architecture.

## Status: FULLY FUNCTIONAL

This processor successfully executes real RISC-V assembly programs with complete load/store, ALU, and memory operations.

## Architecture

- **64-bit Harvard Architecture** - Separate instruction and data memories
- **Single-cycle execution** - Instructions complete in one clock cycle
- **Modular design** - Clean separation of functional units
- **RV64I ISA compliance** - Implements RISC-V 64-bit integer instruction set

## Implemented Features

✅ **Instruction Fetch** - PC management and instruction retrieval
✅ **Instruction Decode** - Full RISC-V instruction parsing  
✅ **Register File** - 32 x 64-bit registers with x0 hardwired to zero
✅ **ALU** - Arithmetic, logical, shift, and comparison operations
✅ **Load/Store Unit** - Complete memory operations (LB/LH/LW/LD/LBU/LHU/LWU/SB/SH/SW/SD)
✅ **Memory Subsystem** - Instruction + data memories with hex file initialization
✅ **Control Unit** - Orchestrates execution across all functional units

## Module Structure
control.v       - Top-level processor control unit
fetch.v         - Instruction fetch and PC management
decode.v        - Instruction decode logic
regfile.v       - 32-register file implementation
alu.v           - Arithmetic logic unit
load_store.v    - Memory operation handling
memory.v        - Instruction memory module
data_memory.v   - Data memory module

## Verification

The processor has been verified with real RISC-V assembly programs demonstrating:
- Immediate arithmetic operations
- Memory store/load operations
- ALU operations on memory-loaded data
- Complete data flow from memory through ALU back to memory

## Usage

1. Compile RISC-V assembly to machine code
2. Initialize memory.hex with instruction codes
3. Initialize data.hex with data values (optional)
4. Run simulation with provided testbench

## Example Program
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
