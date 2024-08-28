module  speccfa_metadata (

// OUTPUTs
    per_dout,                       // Peripheral data output
    OUTS

// INPUTs
    INS
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

//from block_mem
DEC_O

// INPUTs
//=========
DEC_I
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


// Block Memory Interface
//----------------- 

parameter              BLOCKMEM_SIZE  =  LOG_S; 
parameter              BLOCKMEM_ADDR_MSB   = LOG_B; // ADDR_MSB = LOG2(SIZE)-1
   
parameter       [13:0] BLOCKMEM_PER_ADDR  = BASE_ADDR[14:1];   

wire   [BLOCKMEM_ADDR_MSB:0] blockmem_addr_reg = per_addr-BLOCKMEM_PER_ADDR; 
wire                     blockmem_cen      = per_en & per_addr >= BLOCKMEM_PER_ADDR & per_addr < BLOCKMEM_PER_ADDR+BLOCKMEM_SIZE;
wire    [15:0]           blockmem_dout;
wire    [1:0]            blockmem_wen      = per_we & {2{per_en}};

blockmem #(BLOCKMEM_ADDR_MSB, BLOCKMEM_SIZE)
blocks (  

    // OUTPUTs
    .ram_dout             (blockmem_dout),       // Program Memory data output
    BLOCKMEM_O

    // INPUTs
    BLOCKMEM_I
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


wire [15:0] per_dout   =  blockmem_rd;
                       

endmodule // speccfa_metadata
