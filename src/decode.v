module decode(
    input wire [31:0] instr,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,
    output wire [6:0] opcode,
    output wire [2:0] funct3,
    output wire [6:0] funct7,
    output wire [31:0] imm
);

    // Direct bit extraction - these positions NEVER change in RISC-V!
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];
    
    // Immediate formats (computed in parallel)
    wire [31:0] imm_I = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_U = {instr[31:12], 12'b0};
    wire [31:0] imm_J = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    
    // Instruction type detection
    wire is_I_type = (opcode == 7'b0010011) | (opcode == 7'b0000011) | 
                     (opcode == 7'b1100111) | (opcode == 7'b1110011);
    wire is_S_type = (opcode == 7'b0100011);
    wire is_B_type = (opcode == 7'b1100011);
    wire is_U_type = (opcode == 7'b0110111) | (opcode == 7'b0010111);
    wire is_J_type = (opcode == 7'b1101111);
    
    // Select immediate (FemtoRV32 style OR pattern)
    assign imm = (is_I_type ? imm_I : 32'b0) |
                 (is_S_type ? imm_S : 32'b0) |
                 (is_B_type ? imm_B : 32'b0) |
                 (is_U_type ? imm_U : 32'b0) |
                 (is_J_type ? imm_J : 32'b0);

`ifdef DEBUG
    always @(instr) begin
        $display("Decode - Instr: 0x%08h", instr);
        $display("OPCODE: 0x%02h, RS1: %0d, RS2: %0d, RD: %0d, IMM: 0x%08h", 
                 opcode, rs1, rs2, rd, imm);
        $display("FUNCT3: 0x%01h, FUNCT7: 0x%02h", funct3, funct7);
        $display("");
    end
`endif

endmodule