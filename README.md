# RV64I Processor Modules

This repository contains Verilog modules for a simple RV64I processor, designed to implement key components of the RISC-V RV64I instruction set architecture. The project is a work in progress, and additional features will be added over time.

## Project Progress Checklist

- ✅ **Fetch Unit**: Handles program counter updates and instruction fetching.
- ✅ **Memory Module**: Simulates memory with read and write capabilities.
- ✅ **Register File**: Implements 32 registers with write bypassing and hardwired `x0`.
- ✅ **ALU**: Supports arithmetic, logical, shift, and comparison operations.
- ✅ **Decode Unit**: Decodes RISC-V instructions into their components.
- 🌌 **Load/Store Unit**: To handle memory operations (`LOAD` and `STORE` instructions).
- 🌌 **Branch Unit**: To evaluate branch conditions and update the program counter.
- 🌌 **Integration**: Connect ALU to Decode Unit and complete the processor pipeline.

---

## Current Features

- **ALU**: Supports arithmetic, logical, shift, and comparison operations.
- **Register File**: Implements 32 registers with write bypassing and hardwired `x0`.
- **Fetch Unit**: Handles program counter updates and instruction fetching with Little-Endian map out.
- **Decode Unit**: Decodes RISC-V instructions into their components.
- **Memory Module**: Simulates memory with read and write capabilities form memory.hex file and dumps the interneal hex file ones sim is done.
- **Control Unit**: Connects all modules and manages instruction flow.

## Planned Features

- **Load/Store Unit**: To handle memory operations (`LOAD` and `STORE` instructions).
- **Branch Unit**: To evaluate branch conditions and update the program counter.
- **Integration**: Connecting all modules into a complete RV64I processor pipeline.

## Repository Structure

## Repository Structure
```
rv64i-processor/
├── src/                # Source files
│   ├── alu.v           # ALU module
│   ├── regfile.v       # Register file module
│   ├── fetch.v         # Fetch unit
│   ├── decode.v        # Decode unit
│   ├── memory.v        # Memory module
│   ├── control.v       # Control unit
├── testbench/          # Testbench files
│   ├── alu_tb.v        # ALU testbench
│   ├── reg_tb.v        # Register file testbench
|   ├── control_tb.v    # Control file testbench
|   ├── decode_tb.v     # Decode file testbench
|   ├── fetch_tb.v      # Fetch file testbench
|   ├── memory_tb.v     # Memory file testbench
├── memory.hex          # Memory initialization file
└── README.txt          # Project documentation
```
## How It Works

The fetch-decode stage is responsible for fetching instructions from memory and decoding them into their components. The `control` module combines the fetch, decode, and memory modules to simulate this process.

### Example Simulation Output

The following output shows the fetch-decode stage in action:

```
--- Sequential Fetch ---

addi x2, x1, 10\
Fetch Debug - PC: 0x00000004, Instruction: 0x00a08113\
Decode - Instr: 0x00a08113\
OPCODE: 0x13, RS1: 1, RS2: 0, RD: 2, IMM: 0x0000000a\
FUNCT3: 0x0, FUNCT7: 0x00

add x3, x1, x2\
Fetch Debug - PC: 0x00000008, Instruction: 0x002081b3\
Decode - Instr: 0x002081b3\
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 3, IMM: 0x00000000\
FUNCT3: 0x0, FUNCT7: 0x00

sub x4, x3, x1\
Fetch Debug - PC: 0x0000000c, Instruction: 0x40118233\
Decode - Instr: 0x40118233\
OPCODE: 0x33, RS1: 3, RS2: 1, RD: 4, IMM: 0x00000000\
FUNCT3: 0x0, FUNCT7: 0x20
```

