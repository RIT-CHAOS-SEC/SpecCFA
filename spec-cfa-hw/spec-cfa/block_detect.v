module  block_detect (

    // INPUTS
    clk,
    pc,

    cflow_hw_wen,               // ACFA hardware write signal
    cflow_log_ptr,              // Current addr in CF-Log
    cflow_src,                  // Current log entry
    cflow_dest,  

    //total_blocks,

    block_entry_src,
    block_entry_dest,
    block_len,
    block_id,
    cflog_bd_rd_src,
    cflog_bd_rd_dest,

    detect_mux,

    // OUTPUTS
    block_ptr,
    bd_log_ptr,
    detect_active,
//    active_block_id,
    active_block_cflog_addr

    // detect_repeat,
    // spec_ctr
);


// INPUTS
//============
input           clk;
input   [15:0]  pc;

input           cflow_hw_wen;
input   [15:0]  cflow_log_ptr;
input   [15:0]  cflow_src;
input   [15:0]  cflow_dest;

//input   [15:0]  total_blocks;

input   [15:0]  block_entry_src;
input   [15:0]  block_entry_dest;
input    [7:0]  block_len;
input    [7:0]  block_id;
input   [15:0]  cflog_bd_rd_src;
input   [15:0]  cflog_bd_rd_dest;

input           detect_mux;

// OUTPUTS
//============
output   [15:0] block_ptr;
output   [15:0] bd_log_ptr;

// Active (Detected) Block
//output          idle;
output          detect_active;
//output    [7:0] active_block_id;         // id of the active block
output   [15:0] active_block_cflog_addr; // addr in the CF-Log where the block was detected

// output          detect_repeat;
// output   [31:0] spec_ctr;

// STATE VARIABLES
//===========
// detect states
parameter IDLE = 2'b00;
parameter MONITOR = 2'b10;
parameter DETECT = 2'b11;

reg     [1:0] detect_state;

reg   [15:0] block_ptr_reg = 16'h0000; // pointer in blockmem w.r.t. subpath that is being monitored (block index)

initial
begin
    detect_state = IDLE;
end

// Internals
//==================================
wire in_app_PMEM = (cflow_src > 16'he000) & (cflow_src < 16'hffff) & (cflow_dest > 16'he000) & (cflow_dest < 16'hffff);

wire cmp_src = (cflow_src == block_entry_src) & in_app_PMEM;
wire cmp_dest = (cflow_dest == block_entry_dest) & in_app_PMEM;
wire bptr_last = block_ptr_reg == block_len-16'h1;
wire bptr_inter = block_ptr_reg < block_len-16'h1;

wire inter_xfer = cflow_hw_wen & cmp_src & cmp_dest & bptr_inter;
wire last_xfer = cflow_hw_wen & cmp_src & cmp_dest & bptr_last;
wire valid_xfer = cflow_hw_wen & (inter_xfer | last_xfer);
wire invalid_xfer = cflow_hw_wen & ~inter_xfer & ~last_xfer;
//==================================

// control (src, dest) pair
reg   [15:0] bd_log_ptr_reg = 0;        // pointer in cf-log for purpose of detecting subpaths
always @(posedge clk)
begin
    bd_log_ptr_reg <= cflow_log_ptr - 16'h2;
end

// Logic
//==================================
// detection state machine
always @(posedge clk)
begin
    case (detect_state)
        IDLE:
            if(last_xfer) // potential case for length 1 subpath
                detect_state <= DETECT;
            else if(valid_xfer)
                detect_state <= MONITOR;
            else
                detect_state <= IDLE;
            
        MONITOR:
            if (last_xfer)
                detect_state <= DETECT;
            else if(invalid_xfer | detect_mux) // if invalid transfer occurred OR another one was detected, return to idle
                detect_state <= IDLE;
            else // hw_wen and (src, dest) = block[bptr] and bptr < len or state=monitor and !hw_wen
                detect_state <= MONITOR;

        DETECT:
            // the next block is fetched during the first cycle of "DETECT", logic determines transition on the second cycle
            if (last_xfer) // potential case for length 1 subpath
                detect_state <= DETECT;
            else if (inter_xfer)
                detect_state <= MONITOR;
            else
                detect_state <= IDLE;
    endcase
end

// update block ptr on state transition and in state
always @(posedge clk)
begin
    if(valid_xfer & cflow_hw_wen) // valid transfer in any state causes increment
        block_ptr_reg <= block_ptr_reg + 16'h0001;
    else if(detect_state == IDLE || detect_state == DETECT) // invalid transfer in any state OR currently detecting causes counter reset
        block_ptr_reg <= 16'h0000;
    else
        block_ptr_reg <= block_ptr_reg;
end

// internal registers for active block
//reg    [7:0] active_block_id_reg = 8'h00;
reg   [15:0] active_block_cflog_addr_reg = 16'h0000;
always @(posedge clk)
begin
    if(cflow_log_ptr == 16'h0) // need to reset active_block_cflog_addr_reg 
        active_block_cflog_addr_reg <= 16'h0;
    // else if(repeat_spec)
        // active_block_cflog_addr_reg <= repeat_spec_addr_reg;
    else if((detect_state == MONITOR || detect_state == IDLE) && last_xfer) // whe block len == 1, last_xfr occurs during IDLE
    begin
//        active_block_id_reg <= block_id;
        // if(repeat_ctr == MIN_CTR_VAL)
        // begin
        active_block_cflog_addr_reg <= cflow_log_ptr - (block_len << 1) + 16'h2;
            // repeat_spec_addr_reg <= last_spec_addr+2;
        // end
    end
end

// // repeat detection
// parameter MIN_CTR_VAL = 2;
// reg   [15:0] last_spec_addr = 16'h0;
// wire         first_repeat   = (last_spec_addr+16'h2 == active_block_cflog_addr_reg) & (repeat_ctr == MIN_CTR_VAL);
// wire         subsec_repeat  = (last_spec_addr == active_block_cflog_addr_reg) & (repeat_ctr > MIN_CTR_VAL);
// wire         repeat_spec    = detect_active & (first_repeat | subsec_repeat);
// reg   [31:0] repeat_ctr     = MIN_CTR_VAL;
// reg   [15:0] repeat_spec_addr_reg = 16'h0;

// always @(posedge clk)
// begin
//     if(detect_state == IDLE)
//         last_spec_addr <= active_block_cflog_addr_reg;
// end

// always @(posedge clk)
// begin
//     if((detect_mux & detect_state != DETECT) || invalid_xfer) // if some other block is detected, reset the counter
//         repeat_ctr <= MIN_CTR_VAL;
//     else if(detect_state == DETECT && repeat_spec) // if detected block and is a repeat, increment the counter
//         repeat_ctr <= repeat_ctr + 1;
// end

// Tie regs to output
//=========
//
assign block_ptr = block_ptr_reg;
assign detect_active = (detect_state == DETECT);
//assign active_block_id = active_block_id_reg; 
assign active_block_cflog_addr = active_block_cflog_addr_reg;

// assign detect_repeat = 1'b0; //repeat_spec;
// assign spec_ctr = 32'h0;//repeat_ctr;
//==================================

assign bd_log_ptr = bd_log_ptr_reg;

endmodule //block_detect
