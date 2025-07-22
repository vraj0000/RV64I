`timescale 1ns/1ps

module decode_tb;
    reg [31:0] instr;
    wire [4:0] RS1, RS2, RD;
    wire [6:0] OPCODE;
    wire [2:0] FUNCT3;
    wire [6:0] FUNCT7;
    wire [31:0] IMM;
    wire isLoad, isALUimm, isStore, isALUreg, isSYSTEM, isJAL, isJALR, isLUI, isAUIPC, isBranch;

    // Instantiate the decode module
    decode uut (
        .instr(instr),
        .RS1(RS1),
        .RS2(RS2),
        .RD(RD),
        .OPCODE(OPCODE),
        .FUNCT3(FUNCT3),
        .FUNCT7(FUNCT7),
        .IMM(IMM),
        .isLoad(isLoad),
        .isALUimm(isALUimm),
        .isStore(isStore),
        .isALUreg(isALUreg),
        .isSYSTEM(isSYSTEM),
        .isJAL(isJAL),
        .isJALR(isJALR),
        .isLUI(isLUI),
        .isAUIPC(isAUIPC),
        .isBranch(isBranch)
    );

    initial begin
        $display("--- Decode Testbench ---");

        // R-type: add x3, x1, x2 (add rd=x3, rs1=x1, rs2=x2)
        instr = 32'b0000000_00010_00001_000_00011_0110011;
        #1;
        $display("R-type: instr=%b", instr);
        $display("  OPCODE=%b RD=%d RS1=%d RS2=%d FUNCT3=%b FUNCT7=%b IMM=%h", OPCODE, RD, RS1, RS2, FUNCT3, FUNCT7, IMM);
        $display("  isALUreg=%b", isALUreg);

        // I-type: addi x5, x4, 2 (addi rd=x5, rs1=x4, imm=2)
        instr = 32'b000000000010_00100_000_00101_0010011;
        #1;
        $display("I-type: instr=%b", instr);
        $display("  OPCODE=%b RD=%d RS1=%d FUNCT3=%b IMM=%h", OPCODE, RD, RS1, FUNCT3, IMM);
        $display("  isALUimm=%b", isALUimm);

        // S-type: sw x7, 8(x6) (imm=8, rs1=x6, rs2=x7)
        instr = 32'b0000000_00111_00110_010_01000_0100011;
        #1;
        $display("S-type: instr=%b", instr);
        $display("  OPCODE=%b RS1=%d RS2=%d FUNCT3=%b IMM=%h", OPCODE, RS1, RS2, FUNCT3, IMM);
        $display("  isStore=%b", isStore);

        // B-type: beq x8, x9, -4 (imm=-4, rs1=x8, rs2=x9)
        instr = 32'b1111111_01001_01000_000_11110_1100011;
        #1;
        $display("B-type: instr=%b", instr);
        $display("  OPCODE=%b RS1=%d RS2=%d FUNCT3=%b IMM=%h", OPCODE, RS1, RS2, FUNCT3, IMM);
        $display("  isBranch=%b", isBranch);

        // U-type: lui x10, 0x12345
        instr = {20'h12345, 5'd10, 7'b0110111};
        #1;
        $display("U-type: instr=%b", instr);
        $display("  OPCODE=%b RD=%d IMM=%h", OPCODE, RD, IMM);
        $display("  isLUI=%b", isLUI);

        // J-type: jal x1, 0x8
        instr = 32'b00000000100000000000000011101111;
        #1;
        $display("J-type: instr=%b", instr);
        $display("  OPCODE=%b RD=%d IMM=%h", OPCODE, RD, IMM);
        $display("  isJAL=%b", isJAL);

        $display("--- Testbench Complete ---");
        $finish;
    end
endmodule
