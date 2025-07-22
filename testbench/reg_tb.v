`timescale 1ns/1ps

module reg_tb;
    parameter XLEN = 64;
    parameter REGNUM = 32;

    reg clk;
    reg rst;
    reg we;
    reg [4:0] waddr;
    reg [XLEN-1:0] wdata;
    reg [4:0] raddr1, raddr2;
    wire [XLEN-1:0] rdata1, rdata2;

    // Instantiate the register file
    regfile #(XLEN, REGNUM) uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        $display("--- RV64I Register File Testbench ---");
        rst = 1; we = 0; waddr = 0; wdata = 0; raddr1 = 0; raddr2 = 0;
        #12;
        rst = 0;
        #10;

        // Test: Write to all registers except x0
        for (i = 1; i < REGNUM; i = i + 1) begin
            we = 1; waddr = i[4:0]; wdata = i * 64'h10;
            @(negedge clk);
        end
        we = 0;
        #10;

        // Test: Read all registers
        for (i = 0; i < REGNUM; i = i + 1) begin
            raddr1 = i[4:0]; raddr2 = i[4:0];
            #2;
            $display("Read r[%0d]=%h, r[%0d]=%h", raddr1, rdata1, raddr2, rdata2);
        end

        // Test: Write to x0 (should have no effect)
        we = 1; waddr = 0; wdata = 64'hDEADBEEFDEADBEEF;
        @(negedge clk);
        we = 0;
        raddr1 = 0;
        #2;
        $display("After write to x0: r[0]=%h (should be 0)", rdata1);

        // Test: Bypass/forwarding (write and read same reg in same cycle)
        we = 1; waddr = 5; wdata = 64'hCAFEBABECAFEBABE;
        raddr1 = 5; raddr2 = 0;
        @(negedge clk);
        we = 0;
        #2;
        $display("Bypass test: r[5]=%h (should be CAFEBABECAFEBABE)", rdata1);

        // Test: Reset clears all except x0
        rst = 1;
        @(negedge clk);
        rst = 0;
        #2;
        for (i = 0; i < REGNUM; i = i + 1) begin
            raddr1 = i[4:0];
            #2;
            $display("After reset: r[%0d]=%h", raddr1, rdata1);
        end

        $display("--- Testbench Complete ---");
        $finish;
    end
endmodule 