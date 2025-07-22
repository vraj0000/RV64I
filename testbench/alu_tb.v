`timescale 1ns/1ps

module alu_tb;
    reg [63:0] a, b;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire [63:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .funct3(funct3),
        .funct7(funct7),
        .result(result),
        .zero(zero)
    );

    initial begin
        $display("--- ALU Testbench ---");

        // ADD
        a = 64'd10; b = 64'd20; funct3 = 3'b000; funct7 = 7'b0000000;
        #1;
        $display("ADD: %d + %d = %d (result=%h, zero=%b)", a, b, result, result, zero);

        // SUB
        a = 64'd30; b = 64'd10; funct3 = 3'b000; funct7 = 7'b0100000;
        #1;
        $display("SUB: %d - %d = %d (result=%h, zero=%b)", a, b, result, result, zero);

        // AND
        a = 64'hFF00FF00FF00FF00; b = 64'h0F0F0F0F0F0F0F0F; funct3 = 3'b111; funct7 = 7'b0000000;
        #1;
        $display("AND: %h & %h = %h (zero=%b)", a, b, result, zero);

        // OR
        a = 64'hFF00FF00FF00FF00; b = 64'h0F0F0F0F0F0F0F0F; funct3 = 3'b110; funct7 = 7'b0000000;
        #1;
        $display("OR: %h | %h = %h (zero=%b)", a, b, result, zero);

        // XOR
        a = 64'hFF00FF00FF00FF00; b = 64'h0F0F0F0F0F0F0F0F; funct3 = 3'b100; funct7 = 7'b0000000;
        #1;
        $display("XOR: %h ^ %h = %h (zero=%b)", a, b, result, zero);

        // SLL
        a = 64'h1; b = 64'd8; funct3 = 3'b001; funct7 = 7'b0000000;
        #1;
        $display("SLL: %h << %d = %h (zero=%b)", a, b[5:0], result, zero);

        // SRL
        a = 64'h8000000000000000; b = 64'd4; funct3 = 3'b101; funct7 = 7'b0000000;
        #1;
        $display("SRL: %h >> %d = %h (zero=%b)", a, b[5:0], result, zero);

        // SRA
        a = 64'hF000000000000000; b = 64'd4; funct3 = 3'b101; funct7 = 7'b0100000;
        #1;
        $display("SRA: %h >>> %d = %h (zero=%b)", a, b[5:0], result, zero);

        // SLT (signed)
        a = -5; b = 3; funct3 = 3'b010; funct7 = 7'b0000000;
        #1;
        $display("SLT: %d < %d = %d (result=%h, zero=%b)", a, b, result, result, zero);
        a = 5; b = -3; funct3 = 3'b010; funct7 = 7'b0000000;
        #1;
        $display("SLT: %d < %d = %d (result=%h, zero=%b)", a, b, result, result, zero);

        // SLTU (unsigned)
        a = 64'hFFFFFFFFFFFFFFFF; b = 1; funct3 = 3'b011; funct7 = 7'b0000000;
        #1;
        $display("SLTU: %h < %h = %d (result=%h, zero=%b)", a, b, result, result, zero);
        a = 1; b = 64'hFFFFFFFFFFFFFFFF; funct3 = 3'b011; funct7 = 7'b0000000;
        #1;
        $display("SLTU: %h < %h = %d (result=%h, zero=%b)", a, b, result, result, zero);

        $display("--- Testbench Complete ---");
        $finish;
    end
endmodule 