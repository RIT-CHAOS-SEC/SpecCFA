module  speccfa (

    // INPUTS
    clk,
    pc,
    data_en,
    data_wr,
    data_addr,
    
    dma_addr,
    dma_en,  

    cflow_hw_wen,               // ACFA hardware write signal
    cflow_log_ptr,              // Current addr in CF-Log
    cflow_src,                  // Current log entry
    cflow_dest,  

    INS
    cflog_bd_rd_src,
    cflog_bd_rd_dest,
    prev_src,
    prev_dest,

    // OUTPUTS
    OUTS
    bd_log_ptr,
    spec_upper,
    spec_lower,
    detect_repeat,
    detect_active,
    active_block_id,
    active_block_cflog_addr,
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

DEC_I
input       [15:0] cflog_bd_rd_src;
input       [15:0] cflog_bd_rd_dest;
input       [15:0] prev_src;
input       [15:0] prev_dest;

// OUTPUTS
//============
DEC_O
output      [15:0] bd_log_ptr;
//
output      [15:0] spec_upper;
output      [15:0] spec_lower;
//
output             reset;
output             detect_repeat;
output             detect_active;
output       [7:0] active_block_id;         // id of the active block
output      [15:0] active_block_cflog_addr; // addr in the CF-Log where the block was detected

// Internal wires
M_DET

// BLOCK DETECT MODULES

BLOCKS
/**/
// convert to byte index // shift up by 1 is cheaper than *2
ASSIGNS

wire blockmem_reset = 1'b0;
blockmem_integrity blockmem_integrity_0(
    .clk            (clk),
    .pc             (pc),
    .data_addr      (data_addr),
    .w_en           (data_wr),
    .dma_addr       (dma_addr),
    .dma_en         (dma_en),
    
    .reset          (blockmem_reset)
);

ADDR

ID

// repeat detection
parameter MIN_CTR_VAL = 2;
reg   [15:0] last_spec_addr = 16'h0;
reg    [7:0] last_spec_id   = 8'h0;
wire         addr_match     = (last_spec_addr+16'h2 == active_addr);
wire         id_match       = (last_spec_id == active_id);
wire         first_repeat   = addr_match & id_match & (repeat_ctr == MIN_CTR_VAL);
wire         subsec_repeat  = addr_match & id_match & (repeat_ctr > MIN_CTR_VAL);
wire         repeat_spec    = detect_mux & (first_repeat | subsec_repeat);
reg   [31:0] repeat_ctr     = MIN_CTR_VAL;
// reg   [15:0] repeat_spec_addr_reg = 16'h0;

always @(posedge clk)
begin
    if(detect_mux & ((repeat_ctr == MIN_CTR_VAL) | ((repeat_ctr > MIN_CTR_VAL) & ~addr_match)))
    begin
        last_spec_addr <= active_addr;
        last_spec_id <= active_id;
    end
end

always @(posedge clk)
begin
    if(detect_mux & !repeat_spec) // if some other block is detected, reset the counter
        repeat_ctr <= 2;
    else if(detect_mux) // if detected block and is a repeat, increment the counter
        repeat_ctr <= repeat_ctr + 1;
end

//========================
// Assign outputs
//========================
assign detect_active = detect_mux;
// assign active_block_id = ({16{detect_active1}} & active_block_id1) | ({16{detect_active2}} & active_block_id2) | ({16{detect_active3}} & active_block_id3) | ({16{detect_active4}} & active_block_id4) | ({16{detect_active5}} & active_block_id5) | ({16{detect_active6}} & active_block_id6) | ({16{detect_active7}} & active_block_id7) | ({16{detect_active8}} & active_block_id8);
assign active_block_id = active_id;

// assign active_block_cflog_addr = ({16{detect_active1}} & active_block_cflog_addr_out1) | ({16{detect_active2}} & active_block_cflog_addr_out2) | ({16{detect_active3}} & active_block_cflog_addr_out3) | ({16{detect_active4}} & active_block_cflog_addr_out4) | ({16{detect_active5}} & active_block_cflog_addr_out5) | ({16{detect_active6}} & active_block_cflog_addr_out6) | ({16{detect_active7}} & active_block_cflog_addr_out7) | ({16{detect_active8}} & active_block_cflog_addr_out8);
assign active_block_cflog_addr =  first_repeat ? last_spec_addr+16'h2 :
                                  subsec_repeat ? last_spec_addr :
                                  detect_mux ? active_addr : 16'b0;

assign spec_upper  = repeat_spec ? repeat_ctr[31:16] : 16'h1111; 
assign spec_lower  = repeat_spec ? repeat_ctr[15:0] : {8'h0000, active_block_id};
// assign spec_upper  = 16'h1111; 
// assign spec_lower  = {8'h0000, active_block_id};
assign reset = blockmem_reset;
assign detect_repeat = 1'b0; //repeat_spec;

endmodule //speccfa
