module control_tb;
    
    // Parameters
    localparam CLK_PERIOD = 10;
    
    // Signals
    reg                 clk;
    reg                 rst_n;
    reg  [63:0]        pc_next;
    reg                pc_sel;
    wire [63:0]        pc;
    wire [31:0]        instr;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // DUT
    control #(
        .ADDR_WIDTH(10),
        .MEM_DEPTH(1024),
        .MEM_WIDTH(64),
        .MEM_INIT_FILE("memory.hex")
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .pc_next    (pc_next),
        .pc_sel     (pc_sel),
        .pc         (pc),
        .instr      (instr)
    );
    
    // Test sequence
    initial begin
        $display("=== Control Unit Test ===");
        
        // Reset
        rst_n = 0;
        pc_sel = 0;
        pc_next = 64'h0;
        
        repeat(3) @(posedge clk);
        rst_n = 1;
        
        // Sequential fetch
        $display("\n--- Sequential Fetch ---");
        repeat(12) begin
            @(posedge clk);
            #1;
            // $display("PC: 0x%08h | Instruction: 0x%08h", pc, instr);
        end
        
        // Test jump
        $display("\n--- Jump Test ---");
        pc_next = 64'h100;
        pc_sel = 1;
        
        @(posedge clk);
        #1;
        $display("JUMP -> PC: 0x%08h | Instruction: 0x%08h", pc, instr);
        
        // Back to sequential
        pc_sel = 0;
        repeat(4) begin
            @(posedge clk);
            #1;
            $display("PC: 0x%08h | Instruction: 0x%08h", pc, instr);
        end
        
        $display("\n=== Test Complete ===");
        $finish;
    end
    
endmodule