// RV64I Register File
// Parameterized, with synchronous reset and write bypass/forwarding
// x0 (regs[0]) is always hardwired to zero

module regfile #(
    parameter XLEN = 64,           // Register width
    parameter REGNUM = 32         // Number of registers
) (
    input wire clk,
    input wire rst,               // Synchronous reset
    input wire we,                // Write enable
    input wire [4:0] waddr,       // Write address
    input wire [XLEN-1:0] wdata,  // Write data
    input wire [4:0] raddr1,      // Read address 1
    input wire [4:0] raddr2,      // Read address 2
    output wire [XLEN-1:0] rdata1,// Read data 1
    output wire [XLEN-1:0] rdata2 // Read data 2
);

    // Register array
    reg [XLEN-1:0] regs[REGNUM-1:0];

    integer i;

    // Synchronous reset and write logic
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < REGNUM; i = i + 1) begin
                regs[i] <= {XLEN{1'b0}};
            end
        end else if (we && waddr != 5'b00000) begin
            // Only write to non-zero registers
            regs[waddr] <= wdata;
        end
        // x0 is always zero - no explicit assignment needed since we never write to it
    end

    // Write bypass/forwarding for read-after-write hazard
    wire bypass1 = (we && waddr == raddr1 && waddr != 5'b00000);
    wire bypass2 = (we && waddr == raddr2 && waddr != 5'b00000);

    // Asynchronous read with bypass and x0 hardwired to zero
    assign rdata1 = (raddr1 == 5'b00000) ? {XLEN{1'b0}} : (bypass1 ? wdata : regs[raddr1]);
    assign rdata2 = (raddr2 == 5'b00000) ? {XLEN{1'b0}} : (bypass2 ? wdata : regs[raddr2]);

    // Synthesis-time assertion: x0 is never written (for tools that support it)
    // synopsys translate_off
    always @(posedge clk) begin
        if (we && waddr == 5'b00000) begin
            $display("[WARNING] Attempt to write to x0 (register 0) at time %t - write ignored", $time);
        end
    end
    // synopsys translate_on

endmodule

/*
--- RV64I Register File Testbench ---
Read r[0]=0000000000000000, r[0]=0000000000000000
Read r[1]=0000000000000010, r[1]=0000000000000010
Read r[2]=0000000000000020, r[2]=0000000000000020
Read r[3]=0000000000000030, r[3]=0000000000000030
Read r[4]=0000000000000040, r[4]=0000000000000040
Read r[5]=0000000000000050, r[5]=0000000000000050
Read r[6]=0000000000000060, r[6]=0000000000000060
Read r[7]=0000000000000070, r[7]=0000000000000070
Read r[8]=0000000000000080, r[8]=0000000000000080
Read r[9]=0000000000000090, r[9]=0000000000000090
Read r[10]=00000000000000a0, r[10]=00000000000000a0
Read r[11]=00000000000000b0, r[11]=00000000000000b0
Read r[12]=00000000000000c0, r[12]=00000000000000c0
Read r[13]=00000000000000d0, r[13]=00000000000000d0
Read r[14]=00000000000000e0, r[14]=00000000000000e0
Read r[15]=00000000000000f0, r[15]=00000000000000f0
Read r[16]=0000000000000100, r[16]=0000000000000100
Read r[17]=0000000000000110, r[17]=0000000000000110
Read r[18]=0000000000000120, r[18]=0000000000000120
Read r[19]=0000000000000130, r[19]=0000000000000130
Read r[20]=0000000000000140, r[20]=0000000000000140
Read r[21]=0000000000000150, r[21]=0000000000000150
Read r[22]=0000000000000160, r[22]=0000000000000160
Read r[23]=0000000000000170, r[23]=0000000000000170
Read r[24]=0000000000000180, r[24]=0000000000000180
Read r[25]=0000000000000190, r[25]=0000000000000190
Read r[26]=00000000000001a0, r[26]=00000000000001a0
Read r[27]=00000000000001b0, r[27]=00000000000001b0
Read r[28]=00000000000001c0, r[28]=00000000000001c0
Read r[29]=00000000000001d0, r[29]=00000000000001d0
Read r[30]=00000000000001e0, r[30]=00000000000001e0
Read r[31]=00000000000001f0, r[31]=00000000000001f0
[ERROR] Attempt to write to x0 (register 0) at time               405000
After write to x0: r[0]=0000000000000000 (should be 0)
Bypass test: r[5]=cafebabecafebabe (should be CAFEBABECAFEBABE)
After reset: r[0]=0000000000000000
After reset: r[1]=0000000000000000
After reset: r[2]=0000000000000000
After reset: r[3]=0000000000000000
After reset: r[4]=0000000000000000
After reset: r[5]=0000000000000000
After reset: r[6]=0000000000000000
After reset: r[7]=0000000000000000
After reset: r[8]=0000000000000000
After reset: r[9]=0000000000000000
After reset: r[10]=0000000000000000
After reset: r[11]=0000000000000000
After reset: r[12]=0000000000000000
After reset: r[13]=0000000000000000
After reset: r[14]=0000000000000000
After reset: r[15]=0000000000000000
After reset: r[16]=0000000000000000
After reset: r[17]=0000000000000000
After reset: r[18]=0000000000000000
After reset: r[19]=0000000000000000
After reset: r[20]=0000000000000000
After reset: r[21]=0000000000000000
After reset: r[22]=0000000000000000
After reset: r[23]=0000000000000000
After reset: r[24]=0000000000000000
After reset: r[25]=0000000000000000
After reset: r[26]=0000000000000000
After reset: r[27]=0000000000000000
After reset: r[28]=0000000000000000
After reset: r[29]=0000000000000000
After reset: r[30]=0000000000000000
After reset: r[31]=0000000000000000
--- Testbench Complete ---
*/