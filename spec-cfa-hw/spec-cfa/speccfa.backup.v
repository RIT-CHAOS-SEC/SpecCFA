module  speccfa (

    // INPUTS
    clk,
    pc,
    data_en,
    data_wr,
    data_addr,
    
    dma_addr,
    dma_en,

    total_blocks,               // From METADATA, total blocks
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

    reset
);


// INPUTS
//============
input           clk;
input   [15:0]  pc;
input           data_en;
input           data_wr;
input   [15:0]  data_addr;
input   [15:0]  dma_addr;
input           dma_en;
input           cflow_hw_wen;
input   [15:0]  cflow_log_ptr;
input   [15:0]  cflow_src;
input   [15:0]  cflow_dest;
input       [15:0] total_blocks;   // Total speculation blocks
input       [15:0] SPECCFA_BLOCKS_min;   // First address of entire Spec-CFA block data
input       [15:0] SPECCFA_BLOCKS_max;   // Last address of entire Spec-CFA block data
input [15:0] block_entry_src;
input [15:0] block_entry_dest;
input [7:0] block_len;
input [7:0] block_id;

// OUTPUTS
//============
output   [15:0] block_ptr;
output   [15:0] block_base;
output          reset;

// Active (Detected) Block
output          detect_active;
output    [7:0] active_block_id;         // id of the active block
wire    [7:0] active_block_len;        // len of the active block 
output   [15:0] active_block_cflog_addr; // addr in the CF-Log where the block was detected
wire   [15:0] active_block_mem_addr;   // base addr of the block in blockmem

// Internal Wires
//===========
wire [15:0] BLOCKMEM_SIZE = SPECCFA_BLOCKS_max-SPECCFA_BLOCKS_min;

// STATE VARIABLES
//===========
// detect states
parameter IDLE = 2'b00;
parameter MONITOR = 2'b01;
parameter DETECT = 2'b10;
// fetch states
parameter WAIT = 1'b0;
parameter FETCH = 1'b1;

parameter ER_min = 16'he14e;
parameter ER_max = 16'he21c;

reg     [1:0] detect_state;
reg     fetch_state;

initial
begin
    detect_state = IDLE;
    fetch_state = WAIT;
end

// BLOCK FETCH
// Interface with memory and monitor pc to pre-fetch the next upcoming subpaths
//===========

reg [15:0] block_base_reg = 16'h0000;
wire pc_in_ER = pc >= ER_min && pc <= ER_max;
wire block_mismatch_other_dest = cflow_hw_wen && cflow_src == block_entry_src && cflow_dest != block_entry_dest;
wire block_mismatch_wrong_block  = cflow_src > block_entry_src && pc_in_ER;
wire block_mismatch = block_mismatch_other_dest || block_mismatch_wrong_block;

always @(posedge clk)
begin
    case (fetch_state)
        WAIT:
            if (detect_active_reg || block_mismatch)
                fetch_state <= FETCH;
            else
                fetch_state <= WAIT;
        FETCH:
            if (~detect_active_reg & ~block_mismatch)
                fetch_state <= WAIT;
            else
                fetch_state <= FETCH;
    endcase
end

always @(posedge clk)
begin
    if(fetch_state == FETCH)
        block_base_reg <= block_base_reg + (block_len<<1) + 16'h0001;

    if(block_base_reg >= BLOCKMEM_SIZE)
        block_base_reg <= 16'h0000;
end

// MEMORY PROTECTION
// Monitor block data to ensure no unauthorized SW writes
//=========
wire mcu_write_detect = data_wr && (data_addr >= SPECCFA_BLOCKS_min) && (data_addr <= SPECCFA_BLOCKS_max);
wire dma_write_detect = dma_en && (dma_addr >= SPECCFA_BLOCKS_min) && (dma_addr <= SPECCFA_BLOCKS_max);
wire memory_violation = mcu_write_detect || dma_write_detect;

// BLOCK DETECTION
// Detect when first entry of any block (start with 1) has been written to CFLog
// When first is detected, Monitor writes (by hw) to CFLog after this to determine if subpath has occurred
// Push Block ID, Log_ptr to "spec_stack" when block has occurred & activate Log Manager
//=========
reg [15:0] block_ptr_reg = 16'h0000;
reg detect_active_reg = 1'b0;

wire valid_intermed_xfer = cflow_hw_wen && cflow_src == block_entry_src && cflow_dest == block_entry_dest && block_ptr_reg < block_len-16'h1;
wire valid_last_xfer = cflow_hw_wen && cflow_src == block_entry_src && cflow_dest == block_entry_dest && block_ptr_reg == block_len-16'h1;

wire valid_xfer = valid_intermed_xfer || valid_last_xfer;
wire invalid_xfer = cflow_hw_wen && (cflow_src != block_entry_src || cflow_dest != block_entry_dest);

// detection state machine
always @(posedge clk)
begin
    case (detect_state)
        IDLE:
            if (valid_intermed_xfer)
                detect_state <= MONITOR;
            else
                detect_state <= IDLE;
        MONITOR:
            if (valid_last_xfer)
                detect_state <= DETECT;
            else if(invalid_xfer)
                detect_state <= IDLE;
            else // hw_wen and (src, dest) = block[bptr] and bptr < len or state=monitor and !hw_wen
                detect_state <= MONITOR;

        DETECT:
            // the next block is fetched during the first cycle of "DETECT", logic determines transition on the second cycle
            if (valid_intermed_xfer)
                detect_state <= MONITOR;
            else
                detect_state <= IDLE;
            // else if(invalid_xfer)
                // detect_state <= IDLE;
            // else
                // detect_state <= DETECT;
    endcase
end

// update block ptr on state transition and in state
always @(posedge clk)
begin
    if((detect_state == IDLE && valid_intermed_xfer) || (detect_state == MONITOR && valid_xfer))
        block_ptr_reg <= block_ptr_reg + 16'h0001;
    else if((detect_state == MONITOR && invalid_xfer) || detect_state == DETECT)
        block_ptr_reg <= 16'h0000;
    else
        block_ptr_reg <= block_ptr_reg;
end

// update detection signal
always @(posedge clk)
begin
    if(detect_state == MONITOR && valid_last_xfer) // set signal high on the transition to MONITOR
        detect_active_reg <= 1'b1;
    else if(detect_state == MONITOR)
        detect_active_reg <= 1'b0;
    else if(detect_state == DETECT)// && (invalid_xfer || valid_intermed_xfer))
        detect_active_reg <= 1'b0; // stay in DETECT for one cycle, just to capture the block data
    else if(detect_state == IDLE)
        detect_active_reg <= 1'b0;
    else
        detect_active_reg <= detect_active_reg;
end

// internal registers for active block
reg    [7:0] active_block_id_reg = 8'h00;
reg    [7:0] active_block_len_reg = 8'h00;
reg   [15:0] active_block_cflog_addr_reg = 16'h0000;
reg   [15:0] active_block_mem_addr_reg = 16'h0000;
always @(posedge clk)
begin
    if(detect_state == IDLE && valid_xfer)
        active_block_cflog_addr_reg <= cflow_log_ptr;
    else if(detect_state == MONITOR && valid_last_xfer)
    begin
        active_block_len_reg <= block_len;
        active_block_id_reg <= block_id;
        active_block_mem_addr_reg <= block_base_reg;
    end
end

// Tie regs to output
//=========
assign reset = memory_violation;
//
assign block_ptr = (block_ptr_reg << 1);
assign block_base = block_base_reg; 
//
assign detect_active = detect_active_reg;
assign active_block_id = active_block_id_reg; 
assign active_block_len = active_block_len_reg;
assign active_block_cflog_addr = active_block_cflog_addr_reg;
assign active_block_mem_addr = active_block_cflog_addr_reg; 

endmodule //speccfa