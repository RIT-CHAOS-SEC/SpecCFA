module  block_detect (

    // INPUTS
    clk,
    pc,

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

    detect_active,
    detect_mismatch,
    active_block_id,
    active_block_cflog_addr
);


// INPUTS
//============
input           clk;
input   [15:0]  pc;

input           cflow_hw_wen;
input   [15:0]  cflow_log_ptr;
input   [15:0]  cflow_src;
input   [15:0]  cflow_dest;
input   [15:0]  block_entry_src;
input   [15:0]  block_entry_dest;
input    [7:0]  block_len;
input    [7:0]  block_id;

// OUTPUTS
//============
output   [15:0] block_ptr;

// Active (Detected) Block
output          detect_active;
output          detect_mismatch;
output    [7:0] active_block_id;         // id of the active block
output   [15:0] active_block_cflog_addr; // addr in the CF-Log where the block was detected

// STATE VARIABLES
//===========
// detect states
parameter IDLE = 2'b00;
parameter MONITOR = 2'b01;
parameter DETECT = 2'b10;

reg     [1:0] detect_state;

initial
begin
    detect_state = IDLE;
end

// BLOCK DETECTION
// Detect when first entry of any block (start with 1) has been written to CFLog
// When first is detected, Monitor writes (by hw) to CFLog after this to determine if subpath has occurred
// Push Block ID, Log_ptr to "spec_stack" when block has occurred & activate Log Manager
//=========
reg [15:0] block_ptr_reg = 16'h0000;
// reg detect_active_reg = 1'b0;

wire cmp_src = cflow_src == block_entry_src;
wire cmp_dest = cflow_dest == block_entry_dest;
wire bptr_last = block_ptr_reg == block_len-16'h1;
wire bptr_inter = block_ptr_reg < block_len-16'h1;

wire valid_intermed_xfer = cflow_hw_wen && cmp_src && cmp_dest && bptr_inter;
wire valid_last_xfer = cflow_hw_wen && cmp_src && cmp_dest && bptr_last;
wire valid_xfer = valid_intermed_xfer || valid_last_xfer;
wire invalid_xfer = cflow_hw_wen && (~cmp_src || ~cmp_dest);

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
    endcase
end

// update block ptr on state transition and in state
always @(posedge clk)
begin
    if(valid_xfer) // valid transfer in any state causes increment
        block_ptr_reg <= block_ptr_reg + 16'h0001;
    else if(invalid_xfer || detect_state == IDLE) // invalid transfer in any state OR currently detecting causes counter reset
        block_ptr_reg <= 16'h0000;
    else
        block_ptr_reg <= block_ptr_reg;
end

// internal registers for active block
reg    [7:0] active_block_id_reg = 8'h00;
reg   [15:0] active_block_cflog_addr_reg = 16'h0000;
always @(posedge clk)
begin
    if(detect_state == IDLE && valid_intermed_xfer)
        active_block_cflog_addr_reg <= cflow_log_ptr;
    else if(detect_state == MONITOR && valid_last_xfer)
        active_block_id_reg <= block_id;
end

// Tie regs to output
//=========
//
assign block_ptr = block_ptr_reg;
//
assign detect_mismatch = invalid_xfer;
assign detect_active = (detect_state == DETECT);
assign active_block_id = active_block_id_reg; 
assign active_block_cflog_addr = active_block_cflog_addr_reg;

endmodule //block_detect