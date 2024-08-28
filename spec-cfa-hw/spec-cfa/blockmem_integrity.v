
module  blockmem_integrity (
    clk,
    pc,
    data_addr,
    w_en,
    dma_addr,
    dma_en,

    reset
);

input           clk;
input   [15:0]  pc;
input   [15:0]  data_addr;
input           w_en;
input   [15:0]  dma_addr;
input           dma_en;

output          reset;

// MACROS OVERWRITTEN BY EXTERNAL VALUES ///////////////////////////////////////////
parameter       [14:0] SPECDATA_BASE   = 15'h0400;
parameter SPECDATA_SIZE = 16'h0106;

parameter TCB_BASE = 16'h0010;
parameter TCB_SIZE = 16'h0010;
parameter SMEM_BASE = 16'hA000;
parameter SMEM_SIZE = 16'h4000;


parameter RESET_HANDLER = 16'h0000;
parameter RUN  = 1'b0, KILL = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             key_res;
//

initial
    begin
        state = KILL;
        key_res = 1'b1;
    end
wire pc_not_in_tcb = (pc < TCB_BASE) || (pc > (TCB_BASE + TCB_SIZE - 2));
wire pc_not_in_swatt = (pc < SMEM_BASE) || (pc > (SMEM_BASE + SMEM_SIZE - 2));
wire cpu_protected_access = (data_addr >= SPECDATA_BASE) && (data_addr < (SPECDATA_BASE + SPECDATA_SIZE)) && w_en & pc_not_in_tcb && pc_not_in_swatt;
wire dma_protected_access = (dma_addr >= SPECDATA_BASE) && (dma_addr < (SPECDATA_BASE + SPECDATA_SIZE)) && dma_en;



always @(posedge clk)
if( state == RUN && (cpu_protected_access || dma_protected_access))
    state <= KILL;
else if (state == KILL && pc == RESET_HANDLER && !cpu_protected_access && !dma_protected_access)
    state <= RUN;
else state <= state;

always @(posedge clk)
if (state == RUN && (cpu_protected_access || dma_protected_access))
    key_res <= 1'b1;
else if (state == KILL && pc == RESET_HANDLER && !cpu_protected_access && !dma_protected_access)
    key_res <= 1'b0;
else if (state == KILL)
    key_res <= 1'b1;
else if (state == RUN)
    key_res <= 1'b0;
else key_res <= 1'b0;

assign reset = key_res;

endmodule
