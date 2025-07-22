`timescale 1ns / 1ps

module memory_read_tb;

    // Parameters for the memory module (must match the DUT's parameters)
    parameter DEPTH = 1024;
    parameter WIDTH = 64;
    parameter ADDR_WIDTH = 10;
    parameter INIT_FILE = "memory.hex"; // This is crucial for this TB's purpose

    // Testbench signals
    reg clk;
    reg rst;
    reg [ADDR_WIDTH-1:0] addr;
    reg [WIDTH-1:0] wdata; // Not used for writing in this TB, but declared for DUT interface
    reg [WIDTH/8-1:0] we;    // Not used for writing
    reg re;                  // Read enable
    wire [WIDTH-1:0] rdata; // Data read from memory

    // Instantiate the memory module under test (DUT)
    memory #(
        .DEPTH(DEPTH),
        .WIDTH(WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE(INIT_FILE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .we(we),
        .re(re),
        .rdata(rdata)
    );

    // Clock generation (needed even if not strictly synchronous for initial block to run)
    always #5 clk = ~clk; // 10 ns period

    // Test sequence to only read initialized memory
    initial begin
        // Initialize testbench signals
        clk = 0;
        rst = 1;      // Keep reset asserted initially
        addr = 0;
        wdata = 0;
        we = 0;       // Ensure no writes
        re = 0;       // Ensure no reads initially

        $display("Time %0t: Testbench started. Waiting for memory initialization.", $time);

        // Allow some time for the DUT's initial block to execute
        // The $readmemh happens at time 0, but a small delay ensures signals stabilize.
        #20; // Give two clock cycles for good measure
        rst = 0; // De-assert reset
        $display("Time %0t: Reset de-asserted. Starting memory read verification.", $time);

        // --- Read and Verify Memory Contents ---

        // Expected values from memory.hex:
        // mem[0]: 64'hDEADBEEF12345678
        // mem[1]: 64'hCAFEBABE87654321
        // mem[2]: 64'h0123456789ABCDEF
        // mem[3]: 64'h1111222233334444

        #10; // Wait for rdata to update after re goes high (one clock cycle after addr change)

        // Read and verify address 0
        addr = 10'd0;
        we = 8'hff; // <--- NEW: Enable all bytes for write
        wdata = 64'hfffffffff0000faa; // <--- NEW: Set data to all F's
        #10; // Wait one clock cycle for read data to propagate
        we = 8'h00; // <--- NEW: Disable writes after the above write cycle
        re = 1; // Enable reads for the rest of the test
        #10; // Wait one clock cycle for read data to propagate
        $display("Time %0t: Reading from addr 0x%H. Read data: 0x%H", $time, addr, rdata);
        $writememh("dumped_memory.hex", dut.mem, 0, DEPTH-1);
        $display("\n--- Testbench Finished ---");
        $finish; // End simulation

    end
    initial begin
        $dumpfile("memory_read_tb.vcd");
        $dumpvars(0, memory_read_tb);
    end

endmodule