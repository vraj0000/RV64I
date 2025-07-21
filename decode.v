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
    output reg [31:0] IMM,

// FemtoQuark Verilog
    output reg isLoad,      
    output reg isALUimm,    
    output reg isStore,     
    output reg isALUreg,    
    output reg isSYSTEM,    
    output reg isJAL,       
    output reg isJALR,      
    output reg isLUI,    
    output reg isAUIPC,     
    output reg isBranch  
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
        // FemtoQuark Verilog
        isLoad    = 1'b0;
        isALUimm  = 1'b0; 
        isStore   = 1'b0; 
        isALUreg  = 1'b0; 
        isSYSTEM  = 1'b0; 
        isJAL     = 1'b0; 
        isJALR    = 1'b0; 
        isLUI     = 1'b0; 
        isAUIPC   = 1'b0; 
        isBranch  = 1'b0; 
        
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

        isLoad    =  (instr[6:2] == 5'b00000); // rd <- mem[rs1+Iimm]
        isALUimm  =  (instr[6:2] == 5'b00100); // rd <- rs1 OP Iimm
        isStore   =  (instr[6:2] == 5'b01000); // mem[rs1+Simm] <- rs2
        isALUreg  =  (instr[6:2] == 5'b01100); // rd <- rs1 OP rs2
        isSYSTEM  =  (instr[6:2] == 5'b11100); // rd <- cycles
        isJAL     =  instr[3]; // (instr[6:2] == 5'b11011); // rd <- PC+4; PC<-PC+Jimm
        isJALR    =  (instr[6:2] == 5'b11001); // rd <- PC+4; PC<-rs1+Iimm
        isLUI     =  (instr[6:2] == 5'b01101); // rd <- Uimm
        isAUIPC   =  (instr[6:2] == 5'b00101); // rd <- PC + Uimm
        isBranch  =  (instr[6:2] == 5'b11000); // if(rs1 OP rs2) PC<-PC+Bimm
    end
endmodule
/*
R-type: instr=00000000001000001000000110110011
  OPCODE=0110011 RD= 3 RS1= 1 RS2= 2 FUNCT3=000 FUNCT7=0000000 IMM=00000000
I-type: instr=00000001000000100000001010010011
  OPCODE=0010011 RD= 5 RS1= 4 FUNCT3=000 IMM=00000010
S-type: instr=00000000011100110010010000100011
  OPCODE=0100011 RS1= 6 RS2= 7 FUNCT3=010 IMM=00000008
B-type: instr=11111110100101000000111101100011
  OPCODE=1100011 RS1= 8 RS2= 9 FUNCT3=000 IMM=fffff7fe
U-type: instr=00010010001101000101010100110111
  OPCODE=0110111 RD=10 IMM=12345000
J-type: instr=00000000100000000000000011101111
  OPCODE=1101111 RD= 1 IMM=00000008
*/