module  block_fetch (

    // INPUTS
    clk,
    pc,

    // SPECCFA_BLOCKS_min,         // From METADATA, block memory address boundaries (min, max)
    // SPECCFA_BLOCKS_max,       

    cflow_hw_wen,               // ACFA hardware write signal
    cflow_src,                  // Current log entry
    cflow_dest,  

    BLOCKMEM_size,

    block_entry_src,
    block_entry_dest,
    block_len,
    block_id, //unused

    //from block_detect
    fetch_bd,

    // OUTPUTS
    block_base,
    next_base
);


// INPUTS
//============
input           clk;
input   [15:0]  pc;

input           cflow_hw_wen;
input   [15:0]  cflow_src;
input   [15:0]  cflow_dest;

input       [15:0] BLOCKMEM_size;        // Block mem size
input       [15:0] block_entry_src;
input       [15:0] block_entry_dest;
input       [7:0] block_len;
input       [7:0] block_id;

input             fetch_bd;

// OUTPUTS
//============
output   [15:0] next_base;
output   [15:0] block_base;

// STATE VARIABLES
//===========
// fetch states
parameter WAIT = 1'b0;
parameter FETCH = 1'b1;

reg        fetch_state;

// INTERNAL REGISTERS
// care about block skip when in ER
wire block_mismatch = cflow_hw_wen & (cflow_src != block_entry_src) | (pc > block_entry_src);

reg [15:0] block_base_reg;

initial
begin
    fetch_state = WAIT;
    block_base_reg = 16'h0000;
end
//===========

// BLOCK FETCH LOGIC
//===========
// Interface with memory
// Monitor pc to fetch the next upcoming subpaths
// Fetch when signal recevied from block_detect
//===========

always @(posedge clk)
begin
    case (fetch_state)
        WAIT:
            if (fetch_bd)
                fetch_state <= FETCH;
            else
                fetch_state <= fetch_state;
        FETCH:
            if (~fetch_bd)
                fetch_state <= WAIT;
            else
                fetch_state <= fetch_state;
    endcase
end

always @(posedge clk)
begin
    // if next_base is out of block_mem bounds or next_base has overflowed the 16bit bounds
    if(fetch_bd && (next_base >= BLOCKMEM_size || block_base_reg > next_base))
        block_base_reg <= 16'h0;
    else if(fetch_bd) // && next_base != 16'h0 ; need != 0 for verification
        block_base_reg <= next_base;
    else
        block_base_reg <= block_base_reg;
end

// Tie regs to output
//=========
assign block_base = block_base_reg; 
assign next_base = block_base_reg + 2*block_len + 16'h1;
//

endmodule //block_fetch