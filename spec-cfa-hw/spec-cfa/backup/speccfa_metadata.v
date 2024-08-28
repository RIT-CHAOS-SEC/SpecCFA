module  speccfa_metadata (

// OUTPUTs
    per_dout,                       // Peripheral data output
    total_blocks,
    SPECCFA_BLOCKS_min,
    SPECCFA_BLOCKS_max,
    block_entry_src,
    block_entry_dest,
    block_len,
    block_id,

// INPUTs
    block_ptr,
    block_base,
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst                         // Main system reset
);

// OUTPUTs
//=========
output       [15:0] per_dout;       // Peripheral data output
output       [15:0] total_blocks;   // Total speculation blocks
output       [15:0] SPECCFA_BLOCKS_min;   // First address of Spec-CFA block data
output       [15:0] SPECCFA_BLOCKS_max;   // Last address of Spec-CFA block data
//from block_mem
output [15:0] block_entry_src;
output [15:0] block_entry_dest;
output [7:0] block_len;
output [7:0] block_id;

// INPUTs
//=========
input        [15:0] block_ptr;
input        [15:0] block_base;
input               mclk;           // Main system clock
input        [13:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_we;         // Peripheral write enable (high active)
input               puc_rst;        // Main system reset


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0400;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  4;

// Register addresses offset
parameter [DEC_WD-1:0] TOTAL         = 'h0,
                       BLOCK_MIN     = 'h1,
                       BLOCK_MAX     = 'h2;

// Register one-hot decoder utilities
parameter              DEC_SZ      =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] TOTAL_D        = (BASE_REG << TOTAL),
                       BLOCK_MIN_D    = (BASE_REG << BLOCK_MIN),
                       BLOCK_MAX_D    = (BASE_REG << BLOCK_MAX);

parameter METADATA_SIZE = 6;

// Block Memory Interface
//----------------- 
// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BLOCKMEM_BASE_ADDR   = BASE_ADDR + METADATA_SIZE;
 
parameter              BLOCKMEM_SIZE  =  256; 
parameter              BLOCKMEM_ADDR_MSB   = 7; // ADDR_MSB = LOG2(SIZE)-1
   
parameter       [13:0] BLOCKMEM_PER_ADDR  = BLOCKMEM_BASE_ADDR[14:1];   

wire   [BLOCKMEM_ADDR_MSB:0] blockmem_addr_reg = per_addr-BLOCKMEM_PER_ADDR; 
wire                     blockmem_cen      = per_en & per_addr >= BLOCKMEM_PER_ADDR & per_addr < BLOCKMEM_PER_ADDR+BLOCKMEM_SIZE;
wire    [15:0]           blockmem_dout;
wire    [1:0]            blockmem_wen      = per_we & {2{per_en}};

blockmem #(BLOCKMEM_ADDR_MSB, BLOCKMEM_SIZE)
blocks (  

    // OUTPUTs
    .ram_dout             (blockmem_dout),       // Program Memory data output
    .block_entry_src      (block_entry_src),               
    .block_entry_dest     (block_entry_dest),              
    .block_len            (block_len),                  
    .block_id             (block_id),

    // INPUTs
    .block_ptr          (block_ptr),
    .block_base          (block_base),
    .ram_addr    (blockmem_addr_reg),   // Program Memory address
    .ram_cen     (~blockmem_cen),       // Program Memory chip enable (low active)
    .ram_clk     (mclk),                // Program Memory clock
    .ram_din     (per_din),             // Program Memory data input
    .ram_wen     (~blockmem_wen)        // Program Memory write enable (low active)
);
wire [15:0]           blockmem_rd = blockmem_dout & {16{blockmem_cen & ~|per_we}};

//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec   =  (TOTAL_D  &  {DEC_SZ{(reg_addr == TOTAL )}})  |
                               (BLOCK_MIN_D  &  {DEC_SZ{(reg_addr == BLOCK_MIN )}})  |
                               (BLOCK_MAX_D  &  {DEC_SZ{(reg_addr == BLOCK_MAX )}});//  |

// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {512{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {512{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// TOTAL Register
//-----------------   
reg  [15:0] tot_blocks;

wire        tot_blocks_wr = reg_wr[TOTAL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        tot_blocks <=  16'h0000;
  else if (tot_blocks_wr) tot_blocks <=  per_din;

   
// BLOCK_MIN Register
//-----------------   
reg  [15:0] blockmin;

wire        blockmin_wr = reg_wr[BLOCK_MIN];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        blockmin <=  16'h0000;
  else if (blockmin_wr) blockmin <=  per_din;

   
// BLOCK_MAX Register
//-----------------   
reg  [15:0] blockmax;

wire        blockmax_wr = reg_wr[BLOCK_MAX];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        blockmax <=  16'h0000;
  else if (blockmax_wr) blockmax <=  per_din;

//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] totblock_rd  = tot_blocks  & {16{reg_rd[TOTAL]}};
wire [15:0] blockmin_rd  = blockmin  & {16{reg_rd[BLOCK_MIN]}};
wire [15:0] blockmax_rd  = blockmax  & {16{reg_rd[BLOCK_MAX]}};

wire [15:0] per_dout   =  totblock_rd  |
                          blockmin_rd  |
                          blockmax_rd  |
                          blockmem_rd;
                        
assign total_blocks = tot_blocks;
assign SPECCFA_BLOCKS_min = blockmin;
assign SPECCFA_BLOCKS_max = blockmax;

endmodule // speccfa_metadata
