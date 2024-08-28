module  speccfa (

    // INPUTS
    clk,
    pc,
    data_en,
    data_wr,
    data_addr,
    
    dma_addr,
    dma_en,

    total_blocks,
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
    cflog_bd_rd_src,
    cflog_bd_rd_dest,
    prev_src,
    prev_dest,

    // OUTPUTS
    block_ptr,
    bd_log_ptr,
    block_base,
    spec_upper,
    spec_lower,
    detect_repeat,
    detect_active,
    active_block_id,
    active_block_cflog_addr,
    next_base,

    write_cached,
    cached_src,
    cached_dest,

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

input       [15:0] total_blocks;
input       [15:0] SPECCFA_BLOCKS_min;   // First address of entire Spec-CFA block data
input       [15:0] SPECCFA_BLOCKS_max;   // Last address of entire Spec-CFA block data
input       [15:0] block_entry_src;
input       [15:0] block_entry_dest;
input       [7:0] block_len;
input       [7:0] block_id;
input       [15:0] cflog_bd_rd_src;
input       [15:0] cflog_bd_rd_dest;
input       [15:0] prev_src;
input       [15:0] prev_dest;

// OUTPUTS
//============
output      [15:0] block_ptr;
output      [15:0] bd_log_ptr;
output      [15:0] block_base;
//
output      [15:0] spec_upper;
output      [15:0] spec_lower;
//
output             reset;
output             detect_active;
output       [7:0] active_block_id;         // id of the active block
output      [15:0] active_block_cflog_addr; // addr in the CF-Log where the block was detected
output      [15:0] next_base;
output             detect_repeat;
//
output write_cached;
output [15:0] cached_src;
output [15:0] cached_dest;

// block_ptr 2-byte index
wire [15:0] block_ptr_out;
wire [15:0] active_block_cflog_addr_out;
block_detect block_detect_0(
    //inputs    
    .clk                     (clk),
    .pc                      (pc),
    
    .cflow_hw_wen            (cflow_hw_wen),
    .cflow_log_ptr           (cflow_log_ptr),

    .total_blocks            (total_blocks),
    .block_entry_src         (block_entry_src),
    .block_entry_dest        (block_entry_dest),
    .block_len               (block_len),
    .block_id                (block_id),
    .cflog_bd_rd_src         (cflog_bd_rd_src),
    .cflog_bd_rd_dest        (cflog_bd_rd_dest),

    //outputs
    .block_ptr               (block_ptr_out),
    .bd_log_ptr              (bd_log_ptr),
    .idle                    (idle),
    .detect_active           (detect_active),
    .fetch_next              (fetch_next),
    .active_block_id         (active_block_id),
    .active_block_cflog_addr (active_block_cflog_addr_out)
);
// convert to byte index
assign block_ptr = 2*block_ptr_out;
wire fetch_next;
wire [15:0] BLOCKMEM_size = (SPECCFA_BLOCKS_max-SPECCFA_BLOCKS_min)/2;
block_fetch block_fetch_0(
    //inputs
    .clk                (clk),
    .pc                 (pc),

    .cflow_hw_wen       (cflow_hw_wen),
    // .cflow_src          (cflow_src),
    // .cflow_dest         (cflow_dest),
    
    .BLOCKMEM_size      (BLOCKMEM_size),
    .block_entry_src    (block_entry_src),
    .block_entry_dest   (block_entry_dest),
    .block_len          (block_len),
    .block_id           (block_id),
    .fetch_bd           (detect_active | fetch_next),
    
    //outputs
    .block_base         (block_base),
    .next_base          (next_base)
);

parameter MIN_CTR_VAL = 2;
reg [31:0] spec_ctr = MIN_CTR_VAL;
reg [15:0] last_spec_addr = 0;
reg [7:0] last_spec_id = 0;
reg [15:0] last_id_addr = 0;

reg [1:0] first = 0;
reg [1:0] repeat_state = 0;

wire check1 = (spec_ctr > 2);
wire check2 = (cflog_bd_rd_src == 16'h1111);
wire check3 = cflog_bd_rd_dest[7:0] == last_spec_id;
// wire detect_repeat_spec = check1 & check2 & check3;
reg detect_repeat_spec;

wire repeat_start = detect_active & last_spec_id == block_id;
wire repeat_done = detect_active & block_id != last_spec_id;
reg [15:0] first_addr;
always @(posedge clk)
begin
    if (detect_active & spec_ctr == 1)
    begin
        last_spec_id <= block_id;
        last_id_addr <= cflow_log_ptr - (block_len << 1) + 16'h4;
    end
    // else if (detect_active & spec_ctr == 2)
        // last_id_addr <= first_addr + 16'h2; 
end

always @(posedge clk)
begin
    if (repeat_done)
        detect_repeat_spec <= 1'b0;
    else if (spec_ctr > 2)
        detect_repeat_spec <= 1'b1;
    else
        detect_repeat_spec <= 1'b0;
end

always @(posedge clk)
begin
    if (repeat_start)
        spec_ctr <= spec_ctr + 1;
    else if (repeat_done)
        spec_ctr <= 1;
end

// always @(posedge clk)
// begin
//     if ((idle | detect_active) & spec_ctr <= 1)
//         last_id_addr <= (cflow_log_ptr - (block_len << 1) + 16'h4);

//     if(detect_active & (last_spec_id != block_id))
//     begin
//         spec_ctr <= MIN_CTR_VAL;
//         last_spec_id <= block_id;
//         repeat_state <= 1;
//     end
//     else if(detect_active) // reaches here if detect active & repeat occurred, so increment ctr
//     begin
//         spec_ctr <= spec_ctr + 1;
//         repeat_state <= 2;
//     end 
// end

//=============================================================================
// Buffer to triage CF-Log entries that occur during speculation
//=============================================================================
parameter FIFO_DATA_WIDTH = 32;
parameter FIFO_BUFFER_SIZE = 8;
parameter FIFO_ADDR_WIDTH = 3; //log2(buffer_size)

wire [FIFO_DATA_WIDTH-1:0] fifo_out;
wire [FIFO_ADDR_WIDTH-1:0] fifo_occupancy;
wire fifo_read = ~detect_active & ~cflow_hw_wen & (fifo_occupancy > {FIFO_ADDR_WIDTH{1'h0}});
fifo_buffer #(
    .DATA_WIDTH  (FIFO_DATA_WIDTH),
    .BUFFER_SIZE (FIFO_BUFFER_SIZE),
    .ADDR_WIDTH  (FIFO_ADDR_WIDTH)
) fifo_o 
(
    .clk         (clk),
    .reset       (reset),
    .write_en    (detect_active & cflow_hw_wen),
    .read_en     (fifo_read),
    .data_in     ({cflow_src , cflow_dest}),

    .data_out    (fifo_out),
    .occupancy   (fifo_occupancy)
);

wire write_cached = fifo_read;
wire [15:0] cached_src = fifo_out[31:16];
wire [15:0] cached_dest = fifo_out[15:0];

//========================
// Assign outputs
//========================
assign active_block_cflog_addr = ({16{~detect_repeat_spec}} & active_block_cflog_addr_out) | ({16{detect_repeat_spec}} & (last_id_addr));
assign spec_upper  = ({16{~detect_repeat_spec}} & 16'h1111) | ({16{detect_repeat_spec}} & spec_ctr[31:16]); 
assign spec_lower  = ({16{~detect_repeat_spec}} & {8'h0000, active_block_id}) | ({16{detect_repeat_spec}} & spec_ctr[15:0]);
assign detect_repeat = detect_repeat_spec;

endmodule //speccfa