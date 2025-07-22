module fetch #(
    parameter ADDR_WIDTH = 10
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [63:0]           pc_next,
    input  wire                  pc_sel,
    output reg  [63:0]           pc,
    output wire [31:0]           instr,
    output wire [ADDR_WIDTH-1:0] mem_addr,
    output wire                  mem_re,
    input  wire [63:0]           mem_rdata
);

    always @(posedge clk) begin
        if (rst) begin
            pc <= 64'h0;                             // Reset to 0x00000000
        end else begin
            if (pc_sel) begin
                pc <= {pc_next[63:2], 2'b00};
            end else begin
                pc <= pc + 64'h4;                    // First cycle: 0x0 -> 0x4
            end
        end
    end
    
    assign mem_addr = pc[ADDR_WIDTH+2:3];
    assign mem_re = 1'b1;
    wire [31:0] raw_word = pc[2] ? mem_rdata[31:0] : mem_rdata[63:32];
    assign instr = {raw_word[7:0], raw_word[15:8], raw_word[23:16], raw_word[31:24]};

     always @(*) begin
        $display("Fetch Debug - PC: 0x%08h, Instruction: 0x%08h", pc, instr);
        end

endmodule

/*
=== Control Unit Test ===
Fetch Debug - PC: 0x00000000, Instruction: 0x00000000
Fetch Debug - PC: 0x00000000, Instruction: 0x00000000
Fetch Debug - PC: 0x00000000, Instruction: 0x00000000

--- Sequential Fetch ---
Fetch Debug - PC: 0x00000004, Instruction: 0x11111111
Fetch Debug - PC: 0x00000008, Instruction: 0xaaaaaaaa
Fetch Debug - PC: 0x0000000c, Instruction: 0x22222222
Fetch Debug - PC: 0x00000010, Instruction: 0xbbbbbbbb
Fetch Debug - PC: 0x00000014, Instruction: 0x33333333
Fetch Debug - PC: 0x00000018, Instruction: 0xcccccccc
Fetch Debug - PC: 0x0000001c, Instruction: 0x44444444
Fetch Debug - PC: 0x00000020, Instruction: 0xdddddddd
Fetch Debug - PC: 0x00000024, Instruction: 0x55555555
Fetch Debug - PC: 0x00000028, Instruction: 0xeeeeeeee
Fetch Debug - PC: 0x0000002c, Instruction: 0x66666666
Fetch Debug - PC: 0x00000030, Instruction: 0xffffffff
Fetch Debug - PC: 0x00000034, Instruction: 0x77777777

--- Jump Test ---
Fetch Debug - PC: 0x00000100, Instruction: 0x11111111
JUMP -> PC: 0x00000100 | Instruction: 0x11111111
Fetch Debug - PC: 0x00000104, Instruction: 0x00000000
PC: 0x00000104 | Instruction: 0x00000000
Fetch Debug - PC: 0x00000108, Instruction: 0x00000000
PC: 0x00000108 | Instruction: 0x00000000
Fetch Debug - PC: 0x0000010c, Instruction: 0x00000000
PC: 0x0000010c | Instruction: 0x00000000
Fetch Debug - PC: 0x00000110, Instruction: 0x00000000
PC: 0x00000110 | Instruction: 0x00000000

=== Test Complete ===
*/