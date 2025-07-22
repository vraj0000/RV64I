module load_store (
    input wire clk,
    input wire rst,
    input wire isLoad,
    input wire isStore,
    input wire [2:0] funct3,
    input wire [63:0] rs1,
    input wire [63:0] rs2,
    input wire [63:0] imm,
    
    // Memory interface
    output reg [63:0] mem_addr,
    output reg [63:0] mem_wdata,
    output reg [7:0] mem_we,
    input wire [63:0] mem_rdata,
    
    output reg [63:0] result
);

    // Address calculation
    wire [63:0] effective_addr = rs1 + imm;

    always @* begin
        // Default values
        mem_addr = effective_addr;
        mem_wdata = 64'h0;
        mem_we = 8'h00;
        result = 64'h0;
        
        if (isLoad) begin
            case (funct3)
                3'b000: result = {{56{mem_rdata[7]}}, mem_rdata[7:0]};   // LB
                3'b001: result = {{48{mem_rdata[15]}}, mem_rdata[15:0]}; // LH
                3'b010: result = {{32{mem_rdata[31]}}, mem_rdata[31:0]}; // LW
                3'b011: result = mem_rdata;                              // LD
                3'b100: result = {56'h0, mem_rdata[7:0]};               // LBU
                3'b101: result = {48'h0, mem_rdata[15:0]};              // LHU
                3'b110: result = {32'h0, mem_rdata[31:0]};              // LWU
                default: result = 64'h0;
            endcase
        end else if (isStore) begin
            case (funct3)
                3'b000: begin  // SB (Store Byte)
                    mem_wdata = {8{rs2[7:0]}};  // Replicate to all byte lanes
                    mem_we = 8'h01 << effective_addr[2:0];  // Single byte enable
                end
                3'b001: begin  // SH (Store Halfword)
                    mem_wdata = {4{rs2[15:0]}};  // Replicate to all halfword lanes
                    // FIXED: Halfword must be aligned, so addr[0] should be 0
                    mem_we = 8'h03 << {effective_addr[2:1], 1'b0};  
                end
                3'b010: begin  // SW (Store Word)
                    mem_wdata = {2{rs2[31:0]}};  // Replicate to both word lanes
                    // FIXED: Word must be aligned, so addr[1:0] should be 00
                    mem_we = 8'h0F << {effective_addr[2], 2'b00};
                end
                3'b011: begin  // SD (Store Doubleword)
                    mem_wdata = rs2;
                    mem_we = 8'hFF;  // All bytes (address must be 8-byte aligned)
                end
                default: begin
                    mem_wdata = 64'h0;
                    mem_we = 8'h00;
                end
            endcase
        end
    end
endmodule