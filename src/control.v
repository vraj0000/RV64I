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
    wire [MEM_WIDTH-1:0]               imm_64;
    
    // Decode signals
    wire [4:0] RS1;
    wire [4:0] RS2;
    wire [4:0] RD;
    wire [6:0] OPCODE;
    wire [2:0] FUNCT3;
    wire [6:0] FUNCT7;
    wire [31:0] IMM;

    // Register file and ALU connections
    wire [MEM_WIDTH-1:0] a;        // A input to ALU (from register file)
    wire [MEM_WIDTH-1:0] b_reg;    // B register value from regfile
    wire [MEM_WIDTH-1:0] b_imm;    // B immediate value (sign-extended)
    wire [MEM_WIDTH-1:0] b;        // B input to ALU (after mux)
    wire [MEM_WIDTH-1:0] alu_result; // ALU result
    
    wire zero;                     // Zero output from ALU

    
    //==========================================================================
    // Instruction Type Decode Signals (Only ALU operations)
    //==========================================================================
    wire isALUimm  = (OPCODE[6:2] == 5'b00100);  // rd <- rs1 OP Iimm  
    wire isALUreg  = (OPCODE[6:2] == 5'b01100);  // rd <- rs1 OP rs2
    wire isLUI     = (OPCODE[6:2] == 5'b01101);  // rd <- Uimm
    wire isAUIPC   = (OPCODE[6:2] == 5'b00101);  // rd <- PC + Uimm
    wire isBranch  = (OPCODE[6:2] == 5'b11000);
    
    //==========================================================================
    // Control Signal Generation
    //==========================================================================
    
    // ALU source selection: 1 = immediate, 0 = register
    wire alu_src = isALUimm | isAUIPC;
    
    // Register write enable (only for ALU operations)
    wire reg_we = isALUimm | isALUreg | isLUI | isAUIPC;
    
    //==========================================================================
    // Data Path Connections
    //==========================================================================
    
    // Sign-extend 32-bit immediate to 64-bit
    assign imm_64 = {{32{IMM[31]}}, IMM};
    assign b_imm = imm_64;
    
    // ALU source MUX: select between register and immediate
    assign b = alu_src ? b_imm : b_reg;
    
    // Branch wires
    // PC control signals for fetch
    wire pc_sel;
    wire [MEM_WIDTH-1:0] branch_target;
    wire branch_taken;
    assign pc_sel = (isBranch & branch_taken) ? 1'b1 : 1'b0;  // Select branch target

    //==========================================================================
    // Fetch Unit Instance
    //==========================================================================
    
    fetch #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) i_fetch (
        .clk        (clk),
        .rst        (~rst_n),           // Convert to active-high for fetch
        .pc_next    (branch_target),
        .pc_sel     (pc_sel),
        .pc         (pc),
        .instr      (instr),
        .mem_addr   (mem_addr),
        .mem_re     (mem_re),
        .mem_rdata  (mem_rdata)
    );
    
    //==========================================================================
    // Decode Unit Instance
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
    
    //==========================================================================
    // Register File Instance
    //==========================================================================
    regfile #(
        .XLEN(64),
        .REGNUM(32)
    ) i_regfile (
        .clk        (clk),
        .rst        (~rst_n),           // Convert to active-high for regfile
        .we         (reg_we), // Use pipelined write enable
        .waddr      (RD),   // Use pipelined write address
        .wdata      (alu_result),   // Use pipelined write data
        .raddr1     (RS1),
        .raddr2     (RS2),
        .rdata1     (a),
        .rdata2     (b_reg)             
    );
    
    //==========================================================================
    // ALU Instance
    //==========================================================================
    alu #(
        .XLEN(64)
    ) i_alu_unit(
        .a(a),
        .b(b),                          // MUX output: register or immediate
        .funct3(FUNCT3),
        .funct7(FUNCT7),
        .result(alu_result),            
        .zero(zero)
    );

    //==========================================================================
    // Branch Unit Instance
    //==========================================================================    
    branch #(
        .XLEN(64)
    ) branch_unit (
        .funct3(FUNCT3),
        .a(a),
        .b(b_reg),           // Register value (not immediate for branches)
        .imm(imm_64),        // Sign-extended branch offset
        .pc(pc),
        .pc_target(branch_target),
        .branch_taken(branch_taken)
    );
    
    //==========================================================================
    // Memory Instance (For instruction fetch only)
    //==========================================================================
    memory #(
        .DEPTH(MEM_DEPTH),
        .WIDTH(MEM_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE(MEM_INIT_FILE)
    ) i_memory (
        .clk        (clk),
        .rst        (~rst_n),           // Convert to active-high for memory
        .addr       (mem_addr),
        .wdata      (64'h0),            // No data writes
        .we         (8'h0),             // No memory writes
        .re         (mem_re),
        .rdata      (mem_rdata)
    );
    
endmodule