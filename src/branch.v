module branch #(
    parameter XLEN = 64
)(
    input wire [2:0] funct3,
    input wire [XLEN-1:0] a,        // First operand
    input wire [XLEN-1:0] b,        // Second operand  
    input wire [XLEN-1:0] imm,      // Branch offset (sign-extended)
    input wire [XLEN-1:0] pc,       // Current PC
    output reg [XLEN-1:0] pc_target, // Branch target address
    output reg branch_taken         // Branch taken flag
);

    always @* begin
        case (funct3)
            3'b000: begin  // BEQ - Branch if Equal
                branch_taken = (a == b);
            end
            3'b001: begin  // BNE - Branch if Not Equal  
                branch_taken = (a != b);
            end
            3'b100: begin  // BLT - Branch if Less Than (signed)
                branch_taken = ($signed(a) < $signed(b));
            end
            3'b101: begin  // BGE - Branch if Greater/Equal (signed)
                branch_taken = ($signed(a) >= $signed(b));
            end
            3'b110: begin  // BLTU - Branch if Less Than (unsigned)
                branch_taken = (a < b);
            end
            3'b111: begin  // BGEU - Branch if Greater/Equal (unsigned)
                branch_taken = (a >= b);
            end
            default: begin
                branch_taken = 1'b0;
            end
        endcase
        
        // Calculate branch target (only used if branch_taken = 1)
        pc_target = branch_taken ? (pc + imm) : {XLEN{1'bx}};
    end

endmodule