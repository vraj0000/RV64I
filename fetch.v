module fetch (
    input wire clk,
    input wire rst,
    input wire [31:0] pc_next,   // Next PC (from branch/jump logic)
    input wire pc_sel,           // 0: PC+4, 1: pc_next
    output reg [31:0] pc,
    output wire [31:0] instr
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 0;
        else if (pc_sel)
            pc <= pc_next;
        else
            pc <= pc + 4;
    end

    assign instr = imem[pc[ADDR_WIDTH-1:2]]; // Instruction memory access
endmodule
