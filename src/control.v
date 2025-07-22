//==============================================================================
// Simple Control Unit - Connects Fetch and Memory
//==============================================================================

module control #(
    parameter ADDR_WIDTH = 10,
    parameter MEM_DEPTH = 1024,
    parameter MEM_WIDTH = 64,
    parameter MEM_INIT_FILE = "memory.hex"
)(
    // Clock and Reset
    input  wire                    clk,
    input  wire                    rst_n,           // Active-low reset
    
    // PC Control
    input  wire [63:0]            pc_next,         // Jump/branch target
    input  wire                   pc_sel,          // 0: PC+4, 1: use pc_next
    
    // Outputs
    output wire [63:0]            pc,              // Current program counter
    output wire [31:0]            instr            // Current instruction
);

    //==========================================================================
    // Internal Connections
    //==========================================================================
    
    wire [ADDR_WIDTH-1:0]         mem_addr;        // Memory address
    wire                          mem_re;          // Memory read enable
    wire [MEM_WIDTH-1:0]          mem_rdata;       // Memory read data
    reg  [31:0]                   i_instr;
    assign i_instr = instr;
    

    //==========================================================================
    // Internal Connections
    //==========================================================================
    wire [4:0] RS1;
    wire [4:0] RS2;
    wire [4:0] RD;
    wire [6:0] OPCODE;
    wire [2:0] FUNCT3;
    wire [6:0] FUNCT7;
    wire [31:0] IMM;
    
    //==========================================================================
    // Fetch Unit Instance
    //==========================================================================
    
    fetch #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) i_fetch (
        .clk        (clk),
        .rst        (~rst_n),           // Convert to active-high for fetch
        .pc_next    (pc_next),
        .pc_sel     (pc_sel),
        .pc         (pc),
        .instr      (instr),
        .mem_addr   (mem_addr),
        .mem_re     (mem_re),
        .mem_rdata  (mem_rdata)
    );
    
    //==========================================================================
    // Memory Instance
    //==========================================================================
    decode decode_unit(
        .instr(instr),
        .RS1(RS1),
        .RS2(RS2),
        .RD(RD),
        .OPCODE(OPCODE),
        .FUNCT3(FUNCT3),
        .FUNCT7(FUNCT7),
        .IMM(IMM)   
    );
    
    memory #(
        .DEPTH(MEM_DEPTH),
        .WIDTH(MEM_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE(MEM_INIT_FILE)
    ) i_memory (
        .clk        (clk),
        .rst        (~rst_n),           // Convert to active-high for memory
        .addr       (mem_addr),
        .wdata      (64'h0),            // No writes in fetch-only mode
        .we         (8'h0),             // No write enables
        .re         (mem_re),
        .rdata      (mem_rdata)
    );
    
endmodule