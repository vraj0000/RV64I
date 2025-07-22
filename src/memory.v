module memory #(
    parameter DEPTH = 1024,           // Number of memory locations
    parameter WIDTH = 64,             // Data width in bits
    parameter ADDR_WIDTH = 10,        // Address width
    parameter INIT_FILE = "memory.hex" // Initialization file
)(
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [WIDTH-1:0] wdata,
    input wire [WIDTH/8-1:0] we,      // Byte write enables
    input wire re,                    // Read enable
    output reg [WIDTH-1:0] rdata
);

    // Memory array
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    
    // Initialize memory from file
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
            $display("Memory initialized from %s", INIT_FILE);
        end else begin
            // Initialize to zero if no file specified
            integer i;
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] = {WIDTH{1'b0}};
            end
        end
    end
    
    // Memory read/write logic
    always @(posedge clk) begin
        if (rst) begin
            rdata <= {WIDTH{1'b0}};
        end else begin
            // Read operation
            if (re) begin
                rdata <= mem[addr];
            end
            
            // Write operation (byte-wise)
            if (|we) begin // If any write enable is high
                if (we[0]) mem[addr][7:0]   <= wdata[7:0];
                if (we[1]) mem[addr][15:8]  <= wdata[15:8];
                if (we[2]) mem[addr][23:16] <= wdata[23:16];
                if (we[3]) mem[addr][31:24] <= wdata[31:24];
                if (WIDTH > 32) begin
                    if (we[4]) mem[addr][39:32] <= wdata[39:32];
                    if (we[5]) mem[addr][47:40] <= wdata[47:40];
                    if (we[6]) mem[addr][55:48] <= wdata[55:48];
                    if (we[7]) mem[addr][63:56] <= wdata[63:56];
                end
            end
        end
    end
endmodule

/*
Memory initialized from memory.hex
Time 0: Testbench started. Waiting for memory initialization.
Time 20000: Reset de-asserted. Starting memory read verification.
Time 50000: Reading from addr 0x000. Read data: 0xfffffffff0000faa

--- Testbench Finished ---
*/
