module  repeat_detect (
    clk,
    active_id,
    active_addr,
    detect_mux,

    last_spec_addr,
    first_repeat,
    subseq_repeat,
    repeat_spec,
    repeat_ctr
);

input clk;
input [15:0] active_addr;
input  [7:0] active_id;
input        detect_mux;

output [15:0] last_spec_addr;
output first_repeat;
output subseq_repeat;
output repeat_spec;
output [31:0] repeat_ctr;

// repeat detection
parameter MIN_CTR_VAL = 2;
reg   [15:0] last_addr = 16'h0;
reg    [7:0] last_id   = 8'h0;
wire         addr_match     = (last_addr+16'h2 == active_addr);
wire         id_match       = (last_id == active_id);

wire         first            = addr_match & id_match & (ctr == MIN_CTR_VAL);
wire         subseq           = addr_match & id_match & (ctr > MIN_CTR_VAL);
wire         repeat_detect    = detect_mux & (first | subseq);
reg   [31:0] ctr     = MIN_CTR_VAL;
// reg   [15:0] repeat_spec_addr_reg = 16'h0;

always @(posedge clk)
begin
    if(detect_mux & ((ctr == MIN_CTR_VAL) | ((ctr > MIN_CTR_VAL) & ~addr_match)))
    begin
        last_addr <= active_addr;
        last_id <= active_id;
    end
end

always @(posedge clk)
begin
    if(detect_mux & !repeat_detect) // if some other block is detected, reset the counter
        ctr <= 2;
    else if(detect_mux) // if detected block and is a repeat, increment the counter
        ctr <= ctr + 1;
end

assign first_repeat = first;
assign subseq_repeat = subseq;
assign repeat_spec = repeat_detect;
assign repeat_ctr = ctr;
assign last_spec_addr = last_addr;

endmodule //repeat_detect