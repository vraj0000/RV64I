module data_memory #(
    parameter DEPTH = 1024,           // Number of memory locations
    parameter WIDTH = 64,             // Data width in bits
    parameter ADDR_WIDTH = 10,        // Address width
    parameter INIT_FILE = "data.hex"  // Initialization file
)(
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:0] d_addr,
    input wire [WIDTH-1:0] d_wdata,
    input wire [WIDTH/8-1:0] d_we,      // Byte write enables
    input wire d_re,                    // Read enable
    output reg [WIDTH-1:0] d_rdata
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
    
    // Memory read logic - combinational
    always @(*) begin
        if (d_re) begin
            d_rdata = mem[d_addr];  // Address is already constrained by width
        end else begin
            d_rdata = {WIDTH{1'b0}};
        end
    end   
            
    // Memory write logic - clocked
    always @(posedge clk) begin
        if (!rst && |d_we) begin  // Address is already constrained by width
            if (d_we[0]) mem[d_addr][7:0]   <= d_wdata[7:0];
            if (d_we[1]) mem[d_addr][15:8]  <= d_wdata[15:8];
            if (d_we[2]) mem[d_addr][23:16] <= d_wdata[23:16];
            if (d_we[3]) mem[d_addr][31:24] <= d_wdata[31:24];
            if (WIDTH > 32) begin
                if (d_we[4]) mem[d_addr][39:32] <= d_wdata[39:32];
                if (d_we[5]) mem[d_addr][47:40] <= d_wdata[47:40];
                if (d_we[6]) mem[d_addr][55:48] <= d_wdata[55:48];
                if (d_we[7]) mem[d_addr][63:56] <= d_wdata[63:56];
            end
        end
    end
endmodule