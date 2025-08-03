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

    // Load/Store connections
    wire [MEM_WIDTH-1:0] data_mem_addr, data_mem_wdata, data_mem_rdata;
    wire [MEM_WIDTH/8-1:0] data_mem_we;
    wire [MEM_WIDTH-1:0] load_data;

    
    //==========================================================================
    // Instruction Type Decode Signals (Only ALU operations)
    //==========================================================================
    wire isALUimm  = (OPCODE[6:2] == 5'b00100);  // rd <- rs1 OP Iimm  
    wire isALUreg  = (OPCODE[6:2] == 5'b01100);  // rd <- rs1 OP rs2
    wire isLUI     = (OPCODE[6:2] == 5'b01101);  // rd <- Uimm
    wire isAUIPC   = (OPCODE[6:2] == 5'b00101);  // rd <- PC + Uimm
    wire isBranch  = (OPCODE[6:2] == 5'b11000);
    wire isLoad    = (OPCODE[6:2] == 5'b00000); // rd <- mem[rs1+Iimm]
    wire isStore   = (OPCODE[6:2] == 5'b01000);
    
    //==========================================================================
    // Control Signal Generation
    //==========================================================================
    
    // ALU source selection: 1 = immediate, 0 = register
    wire alu_src = isALUimm | isAUIPC;
    
    // Register write enable (include load operations)
    wire reg_we = isALUimm | isALUreg | isLUI | isAUIPC | isLoad;
    
    // Register file write data selection
    wire [MEM_WIDTH-1:0] reg_wdata = isLoad ? load_data : alu_result;
    
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
        .rs1(RS1),
        .rs2(RS2),
        .rd(RD),
        .opcode(OPCODE),
        .funct3(FUNCT3),
        .funct7(FUNCT7),
        .imm(IMM)   
    );
    
    //==========================================================================
    // Load/Store Unit Instance
    //==========================================================================
    load_store #(
        .WIDTH(MEM_WIDTH)
    ) i_load_store (
        .isLoad(isLoad),
        .isStore(isStore),
        .funct3(FUNCT3),
        .rs1_data(a),
        .rs2_data(b_reg),
        .imm(imm_64),
        .mem_rdata(data_mem_rdata),
        .mem_we(data_mem_we),
        .mem_addr(data_mem_addr),
        .mem_wdata(data_mem_wdata),
        .load_data(load_data)
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
        .we         (reg_we),           // Include loads in write enable
        .waddr      (RD),   
        .wdata      (reg_wdata),        // MUX between ALU result and load data
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
    // Data Memory Instance
    //==========================================================================
    data_memory #(
        .DEPTH(MEM_DEPTH),
        .WIDTH(MEM_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("data.hex")
    ) i_data_memory (
        .clk(clk),
        .rst(~rst_n),
        .d_addr(data_mem_addr[ADDR_WIDTH-1:0]),
        .d_wdata(data_mem_wdata),
        .d_we(data_mem_we),
        .d_re(isLoad),
        .d_rdata(data_mem_rdata)
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