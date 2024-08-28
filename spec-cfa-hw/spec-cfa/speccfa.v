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
    cflog_bd_rd_src,
    cflog_bd_rd_dest,
    prev_src,
    prev_dest,

    // OUTPUTS
    block_ptr,
    block_ptr2,
    block_ptr3,
    block_ptr4,
    block_ptr5,
    block_ptr6,
    block_ptr7,
    block_ptr8,
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

input       [15:0] block_entry_src;
input       [15:0] block_entry_dest;
input       [7:0] block_len;
input       [7:0] block_id;
input       [15:0] block_entry_src2;
input       [15:0] block_entry_dest2;
input       [7:0] block_len2;
input       [7:0] block_id2;
input       [15:0] block_entry_src3;
input       [15:0] block_entry_dest3;
input       [7:0] block_len3;
input       [7:0] block_id3;
input       [15:0] block_entry_src4;
input       [15:0] block_entry_dest4;
input       [7:0] block_len4;
input       [7:0] block_id4;
input       [15:0] block_entry_src5;
input       [15:0] block_entry_dest5;
input       [7:0] block_len5;
input       [7:0] block_id5;
input       [15:0] block_entry_src6;
input       [15:0] block_entry_dest6;
input       [7:0] block_len6;
input       [7:0] block_id6;
input       [15:0] block_entry_src7;
input       [15:0] block_entry_dest7;
input       [7:0] block_len7;
input       [7:0] block_id7;
input       [15:0] block_entry_src8;
input       [15:0] block_entry_dest8;
input       [7:0] block_len8;
input       [7:0] block_id8;
input       [15:0] cflog_bd_rd_src;
input       [15:0] cflog_bd_rd_dest;
input       [15:0] prev_src;
input       [15:0] prev_dest;

// OUTPUTS
//============
output      [15:0] block_ptr;
output      [15:0] block_ptr2;
output      [15:0] block_ptr3;
output      [15:0] block_ptr4;
output      [15:0] block_ptr5;
output      [15:0] block_ptr6;
output      [15:0] block_ptr7;
output      [15:0] block_ptr8;
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
wire detect_mux = detect_active1 | detect_active2 | detect_active3 | detect_active4 | detect_active5 | detect_active6 | detect_active7 | detect_active8;

// BLOCK DETECT MODULES

// wire        detect_repeat1;
// wire [31:0] spec_ctr1;
wire [15:0] block_ptr_out;
wire detect_active1;
//wire [7:0] active_block_id1;
wire [15:0] active_block_cflog_addr_out1;
block_detect block_detect_1(
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
    .cflog_bd_rd_src         (cflog_bd_rd_src),
    .cflog_bd_rd_dest        (cflog_bd_rd_dest),

    .detect_mux              (detect_mux),

    //outputs
    .block_ptr               (block_ptr_out),
    .bd_log_ptr              (bd_log_ptr),
    .detect_active           (detect_active1),
//    .active_block_id         (active_block_id1),
    .active_block_cflog_addr (active_block_cflog_addr_out1)

    // .detect_repeat (detect_repeat1),
    // .spec_ctr (spec_ctr1)
);

// wire        detect_repeat2;
// wire [31:0] spec_ctr2;
wire [15:0] block_ptr_out2;
wire detect_active2;
//wire [7:0] active_block_id2;
wire [15:0] active_block_cflog_addr_out2;
 block_detect block_detect_2(
     //inputs    
     .clk                     (clk),
     .pc                      (pc),
    
     .cflow_hw_wen            (cflow_hw_wen),
     .cflow_log_ptr           (cflow_log_ptr),
     .cflow_src               (cflow_src),
     .cflow_dest              (cflow_dest),

  
     .block_entry_src         (block_entry_src2),
     .block_entry_dest        (block_entry_dest2),
     .block_len               (block_len2),
     .block_id                (block_id2),
     .cflog_bd_rd_src         (cflog_bd_rd_src),
     .cflog_bd_rd_dest        (cflog_bd_rd_dest),

     .detect_mux              (detect_mux),

     //outputs
     .block_ptr               (block_ptr_out2),
     .bd_log_ptr              (bd_log_ptr),
     .detect_active           (detect_active2),
//     .active_block_id         (active_block_id2),
     .active_block_cflog_addr (active_block_cflog_addr_out2)

     // .detect_repeat (detect_repeat2),
     // .spec_ctr (spec_ctr2)

 );

/**/
// wire        detect_repeat3;
// wire [31:0] spec_ctr3;
wire [15:0] block_ptr_out3;
wire detect_active3;
//wire [7:0] active_block_id3;
wire [15:0] active_block_cflog_addr_out3;
 block_detect block_detect_3(
     //inputs    
     .clk                     (clk),
     .pc                      (pc),
    
     .cflow_hw_wen            (cflow_hw_wen),
     .cflow_log_ptr           (cflow_log_ptr),
     .cflow_src               (cflow_src),
     .cflow_dest              (cflow_dest),

     .block_entry_src         (block_entry_src3),
     .block_entry_dest        (block_entry_dest3),
     .block_len               (block_len3),
     .block_id                (block_id3),
     .cflog_bd_rd_src         (cflog_bd_rd_src),
     .cflog_bd_rd_dest        (cflog_bd_rd_dest),

     .detect_mux              (detect_mux),

     //outputs
     .block_ptr               (block_ptr_out3),
     .bd_log_ptr              (bd_log_ptr),
     .detect_active           (detect_active3),
//     .active_block_id         (active_block_id3),
     .active_block_cflog_addr (active_block_cflog_addr_out3)

     // .detect_repeat (detect_repeat3),
     // .spec_ctr (spec_ctr3)
 );
/**/
// wire        detect_repeat4;
// wire [31:0] spec_ctr4;
wire [15:0] block_ptr_out4;
wire detect_active4;
//wire [7:0] active_block_id4;
wire [15:0] active_block_cflog_addr_out4;
block_detect block_detect_4(
     //inputs    
     .clk                     (clk),
     .pc                      (pc),
    
     .cflow_hw_wen            (cflow_hw_wen),
     .cflow_log_ptr           (cflow_log_ptr),
     .cflow_src               (cflow_src),
     .cflow_dest              (cflow_dest),

     .block_entry_src         (block_entry_src4),
     .block_entry_dest        (block_entry_dest4),
     .block_len               (block_len4),
     .block_id                (block_id4),
     .cflog_bd_rd_src         (cflog_bd_rd_src),
     .cflog_bd_rd_dest        (cflog_bd_rd_dest),

     .detect_mux              (detect_mux),

     //outputs
     .block_ptr               (block_ptr_out4),
     .bd_log_ptr              (bd_log_ptr),
     .detect_active           (detect_active4),
//     .active_block_id         (active_block_id4),
     .active_block_cflog_addr (active_block_cflog_addr_out4)

     // .detect_repeat (detect_repeat4),
     // .spec_ctr (spec_ctr4)
 );
/**/
// wire        detect_repeat5;
// wire [31:0] spec_ctr5;
wire [15:0] block_ptr_out5;
wire detect_active5;
//wire [7:0] active_block_id5;
wire [15:0] active_block_cflog_addr_out5;
block_detect block_detect_5(
     //inputs    
     .clk                     (clk),
     .pc                      (pc),
    
     .cflow_hw_wen            (cflow_hw_wen),
     .cflow_log_ptr           (cflow_log_ptr),
     .cflow_src               (cflow_src),
     .cflow_dest              (cflow_dest),

     .block_entry_src         (block_entry_src5),
     .block_entry_dest        (block_entry_dest5),
     .block_len               (block_len5),
     .block_id                (block_id5),
     .cflog_bd_rd_src         (cflog_bd_rd_src),
     .cflog_bd_rd_dest        (cflog_bd_rd_dest),

     .detect_mux              (detect_mux),

     //outputs
     .block_ptr               (block_ptr_out5),
     .bd_log_ptr              (bd_log_ptr),
     .detect_active           (detect_active5),
//     .active_block_id         (active_block_id5),
     .active_block_cflog_addr (active_block_cflog_addr_out5)

 //    .detect_repeat (detect_repeat5),
 //    .spec_ctr (spec_ctr5)
 );
/**/
// wire        detect_repeat6;
// wire [31:0] spec_ctr6;
wire [15:0] block_ptr_out6;
wire detect_active6;
//wire [7:0] active_block_id6;
wire [15:0] active_block_cflog_addr_out6;
block_detect block_detect_6(
//     //inputs    
     .clk                     (clk),
     .pc                      (pc),
    
     .cflow_hw_wen            (cflow_hw_wen),
     .cflow_log_ptr           (cflow_log_ptr),
     .cflow_src               (cflow_src),
     .cflow_dest              (cflow_dest),

     .block_entry_src         (block_entry_src6),
     .block_entry_dest        (block_entry_dest6),
     .block_len               (block_len6),
     .block_id                (block_id6),
     .cflog_bd_rd_src         (cflog_bd_rd_src),
     .cflog_bd_rd_dest        (cflog_bd_rd_dest),

     .detect_mux              (detect_mux),

     //outputs
     .block_ptr               (block_ptr_out6),
     .bd_log_ptr              (bd_log_ptr),
     .detect_active           (detect_active6),
//     .active_block_id         (active_block_id6),
     .active_block_cflog_addr (active_block_cflog_addr_out6)
 
     // .detect_repeat (detect_repeat6),
     // .spec_ctr (spec_ctr6)
 );
/**/
// wire        detect_repeat7;
// wire [31:0] spec_ctr7;
wire [15:0] block_ptr_out7;
wire detect_active7;
//wire [7:0] active_block_id7;
wire [15:0] active_block_cflog_addr_out7;
block_detect block_detect_7(
     //inputs    
     .clk                     (clk),
     .pc                      (pc),
    
     .cflow_hw_wen            (cflow_hw_wen),
     .cflow_log_ptr           (cflow_log_ptr),
     .cflow_src               (cflow_src),
     .cflow_dest              (cflow_dest),

     .block_entry_src         (block_entry_src7),
     .block_entry_dest        (block_entry_dest7),
     .block_len               (block_len7),
     .block_id                (block_id7),
     .cflog_bd_rd_src         (cflog_bd_rd_src),
     .cflog_bd_rd_dest        (cflog_bd_rd_dest),

     .detect_mux              (detect_mux),

     //outputs
     .block_ptr               (block_ptr_out7),
     .bd_log_ptr              (bd_log_ptr),
     .detect_active           (detect_active7),
//     .active_block_id         (active_block_id7),
     .active_block_cflog_addr (active_block_cflog_addr_out7)

     // .detect_repeat (detect_repeat7),
     // .spec_ctr (spec_ctr7)
 );

// wire        detect_repeat8;
// wire [31:0] spec_ctr8;
/**/
wire [15:0] block_ptr_out8;
wire detect_active8;
//wire [7:0] active_block_id8;
wire [15:0] active_block_cflog_addr_out8;
block_detect block_detect_8(
//     //inputs    
     .clk                     (clk),
     .pc                      (pc),
    
     .cflow_hw_wen            (cflow_hw_wen),
     .cflow_log_ptr           (cflow_log_ptr),
     .cflow_src               (cflow_src),
     .cflow_dest              (cflow_dest),

     //.total_blocks            (total_blocks),
     .block_entry_src         (block_entry_src8),
     .block_entry_dest        (block_entry_dest8),
     .block_len               (block_len8),
     .block_id                (block_id8),
     .cflog_bd_rd_src         (cflog_bd_rd_src),
     .cflog_bd_rd_dest        (cflog_bd_rd_dest),

     .detect_mux              (detect_mux),

     //outputs
     .block_ptr               (block_ptr_out8),
     .bd_log_ptr              (bd_log_ptr),
     .detect_active           (detect_active8),
     //.active_block_id         (active_block_id8),
     .active_block_cflog_addr (active_block_cflog_addr_out8)

     // .detect_repeat (detect_repeat8),
     // .spec_ctr (spec_ctr8)
 );
/**/
// convert to byte index // shift up by 1 is cheaper than *2
assign block_ptr  = (block_ptr_out  << 1); // 2*block_ptr_out;
assign block_ptr2 = (block_ptr_out2 << 1); //2*block_ptr_out2;
assign block_ptr3 = (block_ptr_out3 << 1); //2*block_ptr_out3;
assign block_ptr4 = (block_ptr_out4 << 1); //2*block_ptr_out4;
assign block_ptr5 = (block_ptr_out5 << 1); //2*block_ptr_out5;
assign block_ptr6 = (block_ptr_out6 << 1); //2*block_ptr_out6;
assign block_ptr7 = (block_ptr_out7 << 1); //2*block_ptr_out7;
assign block_ptr8 = (block_ptr_out8 << 1); //2*block_ptr_out8; /**/

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

wire [15:0] active_addr =   detect_active1 ? active_block_cflog_addr_out1 : //16'b0; 
                            detect_active2 ? active_block_cflog_addr_out2 : //16'b0; 
                            detect_active3 ? active_block_cflog_addr_out3 : //16'b0; 
                            detect_active4 ? active_block_cflog_addr_out4 : //16'b0; 
                            detect_active5 ? active_block_cflog_addr_out5 : //16'b0; 
                            detect_active6 ? active_block_cflog_addr_out6 : //16'b0; 
                            detect_active7 ? active_block_cflog_addr_out7 : //16'b0; 
                            detect_active8 ? active_block_cflog_addr_out8 : 16'b0;

wire [7:0] active_id =    detect_active1 ? block_id : //16'b0;
                          detect_active2 ? block_id2 : //16'b0;
                          detect_active3 ? block_id3 : //16'b0;
                          detect_active4 ? block_id4 : //16'b0;
                          detect_active5 ? block_id5 : //16'b0;
                          detect_active6 ? block_id6 : //16'b0;
                          detect_active7 ? block_id7 : //16'b0; 
                          detect_active8 ? block_id8 : 16'b0;

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
