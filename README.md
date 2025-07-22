# RV64I Processor Modules
========================

This repository contains Verilog modules for a simple RV64I processor, designed to implement key components of the RISC-V RV64I instruction set architecture. The project is a work in progress, and additional features will be added over time.

## Current Features
-----------------
- **ALU**: Supports arithmetic, logical, shift, and comparison operations.
- **Register File**: Implements 32 registers with write bypassing and hardwired `x0`.
- **Fetch Unit**: Handles program counter updates and instruction fetching.
- **Decode Unit**: Decodes RISC-V instructions into their components.
- **Memory Module**: Simulates memory with read and write capabilities.
- **Control Unit**: Connects all modules and manages instruction flow.

## Planned Features
-----------------
- **Load/Store Unit**: To handle memory operations (`LOAD` and `STORE` instructions).
- **Branch Unit**: To evaluate branch conditions and update the program counter.
- **Integration**: Connecting all modules into a complete RV64I processor pipeline.

## Repository Structure
---------------------
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
│   ├── regfile_tb.v    # Register file testbench
├── memory.hex          # Memory initialization file
└── README.txt          # Project documentation

## Getting Started
---------------
To get started with this project, follow these steps:

1. Clone the repository:

3. Run the testbenches:
Testbenches are located in the `testbench/` directory. Run them to verify the functionality of each module.

Simulation of Fetch-Decode
---------------------------
The control unit combines fetch, decode, and memory modules. The following output shows the results of the decode stage during simulation:

--- Sequential Fetch ---

**addi x2, x1, 10**
Fetch Debug - PC: 0x00000004, Instruction: 0x00a08113   
Decode - Instr: 0x00a08113
OPCODE: 0x13, RS1: 1, RS2: 0, RD: 2, IMM: 0x0000000a
FUNCT3: 0x0, FUNCT7: 0x00

**add x3, x1, x2**
Fetch Debug - PC: 0x00000008, Instruction: 0x002081b3
Decode - Instr: 0x002081b3
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 3, IMM: 0x00000000
FUNCT3: 0x0, FUNCT7: 0x00

**sub x4, x3, x1**
Fetch Debug - PC: 0x0000000c, Instruction: 0x40118233
Decode - Instr: 0x40118233
OPCODE: 0x33, RS1: 3, RS2: 1, RD: 4, IMM: 0x00000000
FUNCT3: 0x0, FUNCT7: 0x20

**and x5, x1, x2**
Fetch Debug - PC: 0x00000010, Instruction: 0x0020f2b3
Decode - Instr: 0x0020f2b3
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 5, IMM: 0x00000000
FUNCT3: 0x7, FUNCT7: 0x00

**or x6, x1, x2**
Fetch Debug - PC: 0x00000014, Instruction: 0x0020e333
Decode - Instr: 0x0020e333
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 6, IMM: 0x00000000
FUNCT3: 0x6, FUNCT7: 0x00

**xor x7, x1, x2**
Fetch Debug - PC: 0x00000018, Instruction: 0x0020c3b3
Decode - Instr: 0x0020c3b3
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 7, IMM: 0x00000000
FUNCT3: 0x4, FUNCT7: 0x00

**sll x8, x1, x2**
Fetch Debug - PC: 0x0000001c, Instruction: 0x00209433
Decode - Instr: 0x00209433
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 8, IMM: 0x00000000
FUNCT3: 0x1, FUNCT7: 0x00

**srl x9, x1, x2**
Fetch Debug - PC: 0x00000020, Instruction: 0x0020d4b3
Decode - Instr: 0x0020d4b3
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 9, IMM: 0x00000000
FUNCT3: 0x5, FUNCT7: 0x00

**nop**
Fetch Debug - PC: 0x00000024, Instruction: 0x00000013
Decode - Instr: 0x00000013
OPCODE: 0x13, RS1: 0, RS2: 0, RD: 0, IMM: 0x00000000
FUNCT3: 0x0, FUNCT7: 0x00

Future Work
-----------
1. **Load/Store Unit**:
- Handle memory operations (`LOAD` and `STORE` instructions).
- Implement sign extension for signed loads and zero extension for unsigned loads.

2. **Branch Unit**:
- Evaluate branch conditions and update the program counter.
- Support branch instructions like `BEQ`, `BNE`, `BLT`, etc.

3. **Integration**:
- Combine the ALU, register file, and control signals to create a complete execution pipeline.
- Add testbenches to verify the functionality of the integrated processor.

License
-------
This project is licensed under the MIT License. See the LICENSE file for details.

Contributing
------------
Contributions are welcome! If you’d like to contribute:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

Please ensure that your code passes all testbenches before submitting a pull request.
