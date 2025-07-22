`timescale 1ns/1ps

module fetch_tb;
    parameter ADDR_WIDTH = 4;
    reg clk, rst, pc_sel;
    reg [63:0] pc_next;
    wire [63:0] pc;
    wire [31:0] instr;
    wire [ADDR_WIDTH-1:0] mem_addr;
    wire mem_re;
    reg [63:0] mem_rdata;

    // Simple instruction memory (4 x 64-bit words = 8 instructions)
    reg [63:0] imem [0:(1<<ADDR_WIDTH)-1];

    // Instantiate fetch
    fetch #(.ADDR_WIDTH(ADDR_WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_sel(pc_sel),
        .pc(pc),
        .instr(instr),
        .mem_addr(mem_addr),
        .mem_re(mem_re),
        .mem_rdata(mem_rdata)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize instruction memory with 8 instructions (2 per 64-bit word)
        // imem[0] = {instr1, instr0}, imem[1] = {instr3, instr2}, ...
        imem[0] = {32'hDEADBEEF, 32'h00000013}; // instr1, instr0
        imem[1] = {32'h00008067, 32'h00100093}; // instr3, instr2
        imem[2] = {32'h00200113, 32'h003081B3}; // instr5, instr4
        imem[3] = {32'h00410133, 32'h005181B3}; // instr7, instr6

        rst = 1; pc_sel = 0; pc_next = 0;
        #12;
        rst = 0;

        repeat (6) begin
            @(negedge clk);
            mem_rdata = imem[mem_addr];
            @(posedge clk);
            $display("PC=%h, mem_addr=%h, instr=%h", pc, mem_addr, instr);
        end

        // Simulate a jump to address 0x10 (4th 32-bit instruction, i.e., instr4)
        pc_sel = 1; pc_next = 64'h10;
        @(negedge clk);
        mem_rdata = imem[mem_addr];
        @(posedge clk);
        $display("Jump: PC=%h, mem_addr=%h, instr=%h", pc, mem_addr, instr);
        pc_sel = 0;

        // Fetch a couple more instructions after jump
        repeat (2) begin
            @(negedge clk);
            mem_rdata = imem[mem_addr];
            @(posedge clk);
            $display("PC=%h, mem_addr=%h, instr=%h", pc, mem_addr, instr);
        end

        $display("--- Fetch Testbench Complete ---");
        $finish;
    end
endmodule