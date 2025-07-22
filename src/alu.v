module alu (
    input wire [63:0] a,        // Changed to 64-bit for RV64I
    input wire [63:0] b,        // Changed to 64-bit for RV64I
    input wire [2:0] funct3,    // Changed to 3 bits (was 4)
    input wire [6:0] funct7,
    output reg [63:0] result,   // Must be reg for always block
    output wire zero
);

    always @* begin
        case (funct3)
            3'b000: begin
                case (funct7)
                    7'b0000000: result = a + b;                    // ADD
                    7'b0100000: result = a - b;                    // SUB
                    default:    result = a + b;                    // Default to ADD
                endcase
            end
            3'b100: result = a ^ b;                                // XOR
            3'b110: result = a | b;                                // OR
            3'b111: result = a & b;                                // AND
            3'b001: result = a << b[5:0];                          // SLL (only lower 6 bits for RV64I)
            3'b101: begin
                case (funct7)
                    7'b0000000: result = a >> b[5:0];              // SRL (logical right shift)
                    7'b0100000: result = $signed(a) >>> b[5:0];    // SRA (arithmetic right shift)
                    default:    result = a >> b[5:0];              // Default to SRL
                endcase
            end
            3'b010: result = ($signed(a) < $signed(b)) ? 64'h1 : 64'h0;    // SLT (signed)
            3'b011: result = (a < b) ? 64'h1 : 64'h0;                      // SLTU (unsigned)
            default: result = 64'h0;                               // Default case
        endcase
    end

    assign zero = (result == 64'h0);

endmodule