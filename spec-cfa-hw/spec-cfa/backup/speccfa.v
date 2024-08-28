module  speccfa (

    // INPUTS
    clk,
    pc,
    data_en,
    data_wr,
    data_addr,
    
    dma_addr,
    dma_en,

    SPECCFA_BLOCKS_min,         // From METADATA, block memory address boundaries (min, max)
    SPECCFA_BLOCKS_max,       

    cflow_hw_wen,               // ACFA hardware write signal
    cflow_log_ptr,              // Current addr in CF-Log
    cflow_src,                  // Current log entry
    cflow_dest,  

    block_entry_src,
    block_entry_dest,
    block_len,
    block_id,

    // OUTPUTS
    block_ptr,
    block_base,

    detect_active,
    active_block_id,
    active_block_cflog_addr,
    next_base,
    reset
);

// INPUTS
//============
input              clk;
input       [15:0] pc;
input              data_en;
input              data_wr;
input       [15:0] data_addr;
input       [15:0] dma_addr;
input              dma_en;
input              cflow_hw_wen;
input       [15:0] cflow_log_ptr;
input       [15:0] cflow_src;
input       [15:0] cflow_dest;

input       [15:0] SPECCFA_BLOCKS_min;   // First address of entire Spec-CFA block data
input       [15:0] SPECCFA_BLOCKS_max;   // Last address of entire Spec-CFA block data
input       [15:0] block_entry_src;
input       [15:0] block_entry_dest;
input       [7:0] block_len;
input       [7:0] block_id;

// OUTPUTS
//============
output      [15:0] block_ptr;
output      [15:0] block_base;
output             reset;
output             detect_active;
output       [7:0] active_block_id;         // id of the active block
output      [15:0] active_block_cflog_addr; // addr in the CF-Log where the block was detected
output      [15:0] next_base;

// block_ptr 2-byte index
wire [15:0] block_ptr_out;
block_detect block_detect_0(
    //inputs    
    .clk                     (clk),
    .pc                      (pc),
    
    .cflow_hw_wen            (cflow_hw_wen),
    .cflow_log_ptr           (cflow_log_ptr),
    .cflow_src               (cflow_src),
    .cflow_dest              (cflow_dest),

    .block_entry_src         (block_entry_src),
    .block_entry_dest        (block_entry_dest),
    .block_len               (block_len),
    .block_id                (block_id),
    
    //outputs
    .block_ptr               (block_ptr_out),
    .detect_active           (detect_active),
    .detect_mismatch         (detect_mismatch),
    .active_block_id         (active_block_id),
    .active_block_cflog_addr (active_block_cflog_addr)
);
// convert to byte index
assign block_ptr = 2*block_ptr_out;
wire detect_mismatch;
wire [15:0] BLOCKMEM_size = (SPECCFA_BLOCKS_max-SPECCFA_BLOCKS_min)/2;
block_fetch block_fetch_0(
    //inputs
    .clk                (clk),
    .pc                 (pc),

    .cflow_hw_wen       (cflow_hw_wen),
    .cflow_src          (cflow_src),
    .cflow_dest         (cflow_dest),
    
    .BLOCKMEM_size      (BLOCKMEM_size),
    .block_entry_src    (block_entry_src),
    .block_entry_dest   (block_entry_dest),
    .block_len          (block_len),
    .block_id           (block_id),
    .fetch_bd           (detect_active | detect_mismatch),
    
    //outputs
    .block_base         (block_base),
    .next_base          (next_base)
);

endmodule //speccfa