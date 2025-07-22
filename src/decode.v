// Decode the instruction
// Input: 32-bit instruction
// Output: rs1, rs2, rd, opcode, funct3, funct7, imm
/*
0000011 - LOAD    (LB, LH, LW, LBU, LHU)
0010011 - OP-IMM  (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
0100011 - STORE   (SB, SH, SW)
0110011 - OP      (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
1100011 - BRANCH  (BEQ, BNE, BLT, BGE, BLTU, BGEU)
1100111 - JALR
1101111 - JAL
0110111 - LUI
0010111 - AUIPC
1110011 - SYSTEM  (ECALL, EBREAK, CSRR*, etc.)
*/
module decode(
    input wire [31:0] instr,
    output reg [4:0] RS1,
    output reg [4:0] RS2,
    output reg [4:0] RD,
    output reg [6:0] OPCODE,
    output reg [2:0] FUNCT3,
    output reg [6:0] FUNCT7,
    output reg [31:0] IMM

);

    always @* begin
        // Extract opcode first
        OPCODE = instr[6:0];
        
        // Default assignments
        RS1 = 5'b0;
        RS2 = 5'b0;
        RD = 5'b0;
        FUNCT3 = 3'b0;
        FUNCT7 = 7'b0;
        IMM = 32'b0;
        
        case (OPCODE)
            7'b0110011: begin // R-type
                RD     = instr[11:7];
                FUNCT3 = instr[14:12];
                RS1    = instr[19:15];
                RS2    = instr[24:20];
                FUNCT7 = instr[31:25];
            end
            7'b0010011, // I-type: arithmetic immediate
            7'b0000011, // I-type: loads
            7'b1100111, // I-type: JALR
            7'b1110011: // I-type: SYSTEM
            begin
                RD     = instr[11:7];
                FUNCT3 = instr[14:12];
                RS1    = instr[19:15];
                IMM    = {{20{instr[31]}}, instr[31:20]}; // sign-extend
            end
            7'b0100011: begin // S-type
                FUNCT3 = instr[14:12];
                RS1    = instr[19:15];
                RS2    = instr[24:20];
                IMM    = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // sign-extend
            end
            7'b1100011: begin // B-type
                FUNCT3 = instr[14:12];
                RS1    = instr[19:15];
                RS2    = instr[24:20];
                IMM    = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // sign-extend
            end
            7'b0110111, // U-type: LUI
            7'b0010111: // U-type: AUIPC
            begin
                RD  = instr[11:7];
                IMM = {instr[31:12], 12'b0};
            end
            7'b1101111: begin // J-type: JAL
                RD  = instr[11:7];
                IMM = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // sign-extend
            end
            default: begin
                // Leave as default zeros
            end
        endcase
    end
    always  @(instr) begin
        $display("Decode - Instr: 0x%08h", instr);
            $display("OPCODE: 0x%02h, RS1: %0d, RS2: %0d, RD: %0d, IMM: 0x%08h", 
                     OPCODE, RS1, RS2, RD, IMM);
            $display("FUNCT3: 0x%01h, FUNCT7: 0x%02h", FUNCT3, FUNCT7);
            $display("");
    end
endmodule
/*
--- Sequential Fetch ---
Fetch Debug - PC: 0x00000004, Instruction: 0x002080b3
Decode - Instr: 0x002080b3
OPCODE: 0x33, RS1: 1, RS2: 2, RD: 1, IMM: 0x00000000
FUNCT3: 0x0, FUNCT7: 0x00

Fetch Debug - PC: 0x00000008, Instruction: 0x00000000
Fetch Debug - PC: 0x0000000c, Instruction: 0x06420293
Decode - Instr: 0x06420293
OPCODE: 0x13, RS1: 4, RS2: 0, RD: 5, IMM: 0x00000064
FUNCT3: 0x0, FUNCT7: 0x00

Fetch Debug - PC: 0x00000010, Instruction: 0x00000000
Fetch Debug - PC: 0x00000014, Instruction: 0x00832383
Decode - Instr: 0x00832383
OPCODE: 0x03, RS1: 6, RS2: 0, RD: 7, IMM: 0x00000008
FUNCT3: 0x2, FUNCT7: 0x00

Fetch Debug - PC: 0x00000018, Instruction: 0x00000000
Fetch Debug - PC: 0x0000001c, Instruction: 0x00942623
Decode - Instr: 0x00942623
OPCODE: 0x23, RS1: 8, RS2: 9, RD: 0, IMM: 0x0000000c
FUNCT3: 0x2, FUNCT7: 0x00

Fetch Debug - PC: 0x00000020, Instruction: 0x00000000
Fetch Debug - PC: 0x00000024, Instruction: 0x00b50863
Decode - Instr: 0x00b50863
OPCODE: 0x63, RS1: 10, RS2: 11, RD: 0, IMM: 0x00000010
FUNCT3: 0x0, FUNCT7: 0x00

Fetch Debug - PC: 0x00000028, Instruction: 0x00000000
Fetch Debug - PC: 0x0000002c, Instruction: 0x00000013
Decode - Instr: 0x00000013
OPCODE: 0x13, RS1: 0, RS2: 0, RD: 0, IMM: 0x00000000
FUNCT3: 0x0, FUNCT7: 0x00

Fetch Debug - PC: 0x00000030, Instruction: 0x00000000
Fetch Debug - PC: 0x00000034, Instruction: 0x00000013
*/