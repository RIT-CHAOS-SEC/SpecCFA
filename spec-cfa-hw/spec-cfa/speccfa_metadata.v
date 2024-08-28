module  speccfa_metadata (

// OUTPUTs
    per_dout,                       // Peripheral data output
    block_entry_src,
    block_entry_dest,
    block_len,
    block_id,
    block_entry_src2,
    block_entry_dest2,
    block_len2,
    block_id2,
    block_entry_src3,
    block_entry_dest3,
    block_len3,
    block_id3,
    block_entry_src4,
    block_entry_dest4,
    block_len4,
    block_id4,
    block_entry_src5,
    block_entry_dest5,
    block_len5,
    block_id5,
    block_entry_src6,
    block_entry_dest6,
    block_len6,
    block_id6,
    block_entry_src7,
    block_entry_dest7,
    block_len7,
    block_id7,
    block_entry_src8,
    block_entry_dest8,
    block_len8,
    block_id8,

// INPUTs
    block_ptr,
    block_ptr2,
    block_ptr3,
    block_ptr4,
    block_ptr5,
    block_ptr6,
    block_ptr7,
    block_ptr8,
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
output [15:0] block_entry_src;
output [15:0] block_entry_dest;
output [7:0] block_len;
output [7:0] block_id;
output [15:0] block_entry_src2;
output [15:0] block_entry_dest2;
output [7:0] block_len2;
output [7:0] block_id2;
output [15:0] block_entry_src3;
output [15:0] block_entry_dest3;
output [7:0] block_len3;
output [7:0] block_id3;
output [15:0] block_entry_src4;
output [15:0] block_entry_dest4;
output [7:0] block_len4;
output [7:0] block_id4;
output [15:0] block_entry_src5;
output [15:0] block_entry_dest5;
output [7:0] block_len5;
output [7:0] block_id5;
output [15:0] block_entry_src6;
output [15:0] block_entry_dest6;
output [7:0] block_len6;
output [7:0] block_id6;
output [15:0] block_entry_src7;
output [15:0] block_entry_dest7;
output [7:0] block_len7;
output [7:0] block_id7;
output [15:0] block_entry_src8;
output [15:0] block_entry_dest8;
output [7:0] block_len8;
output [7:0] block_id8;

// INPUTs
//=========
input        [15:0] block_ptr;
input        [15:0] block_ptr2;
input        [15:0] block_ptr3;
input        [15:0] block_ptr4;
input        [15:0] block_ptr5;
input        [15:0] block_ptr6;
input        [15:0] block_ptr7;
input        [15:0] block_ptr8;
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

parameter              BLOCKMEM_SIZE  =  512; 
parameter              BLOCKMEM_ADDR_MSB   = 8; // ADDR_MSB = LOG2(SIZE)-1
   
parameter       [13:0] BLOCKMEM_PER_ADDR  = BASE_ADDR[14:1];   

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
    .block_entry_src2      (block_entry_src2),               
    .block_entry_dest2     (block_entry_dest2),              
    .block_len2            (block_len2),                  
    .block_id2             (block_id2),
    .block_entry_src3      (block_entry_src3),               
    .block_entry_dest3     (block_entry_dest3),              
    .block_len3            (block_len3),                  
    .block_id3             (block_id3),
    .block_entry_src4      (block_entry_src4),               
    .block_entry_dest4     (block_entry_dest4),              
    .block_len4            (block_len4),                  
    .block_id4             (block_id4),
    .block_entry_src5      (block_entry_src5),               
    .block_entry_dest5     (block_entry_dest5),              
    .block_len5            (block_len5),                  
    .block_id5             (block_id5),
    .block_entry_src6      (block_entry_src6),               
    .block_entry_dest6     (block_entry_dest6),              
    .block_len6            (block_len6),                  
    .block_id6             (block_id6),
    .block_entry_src7      (block_entry_src7),               
    .block_entry_dest7     (block_entry_dest7),              
    .block_len7            (block_len7),                  
    .block_id7             (block_id7),
    .block_entry_src8      (block_entry_src8),               
    .block_entry_dest8     (block_entry_dest8),              
    .block_len8            (block_len8),                  
    .block_id8             (block_id8),

    // INPUTs
    .block_ptr          (block_ptr),
    .block_ptr2          (block_ptr2),
    .block_ptr3          (block_ptr3),
    .block_ptr4          (block_ptr4),
    .block_ptr5          (block_ptr5),
    .block_ptr6          (block_ptr6),
    .block_ptr7          (block_ptr7),
    .block_ptr8          (block_ptr8),
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
