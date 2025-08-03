module load_store #(parameter WIDTH = 64) (
    input wire isLoad, isStore,
    input wire [2:0] funct3,
    input wire [WIDTH-1:0] rs1_data, rs2_data, imm, mem_rdata,
    output reg [WIDTH/8-1:0] mem_we,
    output reg [WIDTH-1:0] mem_addr, mem_wdata, load_data
);

    always @* begin
        mem_addr = rs1_data + imm;
    end
    
    // One-hot decode funct3
    wire [7:0] f3 = 8'b1 << funct3;
    
    // Extract data using shifts with proper bit selection
    wire [WIDTH-1:0] byte_shifted = mem_rdata >> (mem_addr[2:0] * 8);
    wire [WIDTH-1:0] half_shifted = mem_rdata >> (mem_addr[2:1] * 16);
    wire [WIDTH-1:0] word_shifted = mem_rdata >> (mem_addr[2] * 32);
    
    wire [7:0]  byte_data = byte_shifted[7:0];
    wire [15:0] half_data = half_shifted[15:0];
    wire [31:0] word_data = word_shifted[31:0];
    wire [63:0] dword_data = mem_rdata;
    
    // Sign extension logic
    wire byte_sign = byte_data[7];
    wire half_sign = half_data[15];
    wire word_sign = word_data[31];
    
    always @* begin
    // Compact load data selection
        load_data = 
            (f3[0] ? {{56{byte_sign}}, byte_data} : 64'b0) | // LB
            (f3[1] ? {{48{half_sign}}, half_data} : 64'b0) | // LH  
            (f3[2] ? {{32{word_sign}}, word_data} : 64'b0) | // LW
            (f3[3] ? dword_data                   : 64'b0) | // LD
            (f3[4] ? {56'b0, byte_data}           : 64'b0) | // LBU
            (f3[5] ? {48'b0, half_data}           : 64'b0) | // LHU
            (f3[6] ? {32'b0, word_data}           : 64'b0);  // LWU
    end
    // Write masks using bit shifts
    wire [7:0] byte_we  = 8'b00000001 << mem_addr[2:0];
    wire [7:0] half_we  = 8'b00000011 << (mem_addr[2:1] * 2);
    wire [7:0] word_we  = 8'b00001111 << (mem_addr[2] * 4);
    wire [7:0] dword_we = 8'b11111111;

    always @* begin
        mem_we = isStore ? (
            (f3[0] ? byte_we  : 8'b0) |  // SB
            (f3[1] ? half_we  : 8'b0) |  // SH
            (f3[2] ? word_we  : 8'b0) |  // SW
            (f3[3] ? dword_we : 8'b0)    // SD
        ) : 8'b0;
    end
    always @* begin
    // Write data positioning
        mem_wdata = 
            (f3[0] ? rs2_data << (mem_addr[2:0] * 8)  : 64'b0) | // SB
            (f3[1] ? rs2_data << (mem_addr[2:1] * 16) : 64'b0) | // SH
            (f3[2] ? rs2_data << (mem_addr[2] * 32)   : 64'b0) | // SW
            (f3[3] ? rs2_data                         : 64'b0);  // SD
    end
    always @(isLoad, isStore, funct3, rs1_data, rs2_data, imm, mem_rdata) begin
        #1
        $display("isLoad: %d, isStore: %d, ", isLoad, isStore);
        $display("mem_addr: 0x%08h, mem_wdata: 0x%08h, load_data: 0x%08h", mem_addr, mem_wdata, load_data);
        $display("+++");
        $display(" ");
    end


endmodule

/*
Fetch Debug - PC: 0x00000004, Instruction: 0x00003283
isLoad: 1, isStore: 0, 
mem_addr: 0x00000000, mem_wdata: 0x00000000, load_data: 0xffffffffffffffff
+++
RADDR1: 0, RADDR2: 0, WADDR: 5
RDATA1: 0x0000000000000000, RDATA2: 0x0000000000000000, WDATA: 0xffffffffffffffff

A = 0x0000000000000000, B = 0x0000000000000000, Result = 0x0000000000000000
-----------------------------------------------------------------------
Fetch Debug - PC: 0x00000008, Instruction: 0x00028333
isLoad: 0, isStore: 0, 
mem_addr: 0xffffffffffffffff, mem_wdata: 0x00000000, load_data: 0x00000000
+++
RADDR1: 5, RADDR2: 0, WADDR: 6
RDATA1: 0xffffffffffffffff, RDATA2: 0x0000000000000000, WDATA: 0xffffffffffffffff

A = 0xffffffffffffffff, B = 0x0000000000000000, Result = 0xffffffffffffffff
-----------------------------------------------------------------------
*/