
module cflogmem (

// OUTPUTs
	per_dout,                       // Peripheral data output
    cflog_bd_rd_src,
    cflog_bd_rd_dest,
    prev_src,
    prev_dest,

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst,                         // Main system reset
    //
    bd_log_ptr,
    spec_upper,
    spec_lower,
    detect_active,
    active_block_cflog_addr,
    //
    cflow_logs_ptr_din,             // Control Flow: pointer to logs being modified
    cflow_src,                      // Control Flow: jump from
    cflow_dest,                     // Control Flow: jump to
    cflow_hw_wen,                   // Control Flow, write enable (only hardware can trigger)
);


// PARAMETERs
//============ 

parameter               CFLOW_LOGS_SIZE   =  16'hHEX;     // # of 16-byte words (total cflog bytes / 2)
parameter 				MEM_SIZE   =  CFLOW_LOGS_SIZE*2;       // Memory size in bytes
parameter 				ADDR_MSB   =  BITS;         // MSB of the address bus                                                          
parameter       [14:0] CFLOW_LOGS_BASE_ADDR = 14'h01b0;//METADATA_BASE_ADDR+METADATA_SIZE;    // Spans 0x1a6-0x3a6
parameter       [13:0] CFLOW_LOGS_PER_ADDR  = CFLOW_LOGS_BASE_ADDR[14:1];

// INPUTs
//============
// From MSP430
input              mclk;            // Main system clock
input       [13:0] per_addr;        // Peripheral address
input       [15:0] per_din;         // Peripheral data input
input              per_en;          // Peripheral enable (high active)
input        [1:0] per_we;          // Peripheral write enable (high active)
input              puc_rst;         // Main system reset
// From Spec-CFA
input       [15:0] bd_log_ptr;
input 		[15:0] spec_upper;
input 		[15:0] spec_lower;
input 			   detect_active;
input 		[15:0] active_block_cflog_addr;
// From ACFA
input       [15:0] cflow_logs_ptr_din;  // Control Flow: pointer to logs being modified
input       [15:0] cflow_src;           // Control Flow: jump from
input       [15:0] cflow_dest;          // Control Flow: jump to
input              cflow_hw_wen;        // Control Flow, write enable (only hardware can trigger)

// OUTPUTs
//============
// To MSP430
output      [15:0] per_dout;       // RAM data output
// To Spec-CFA
output      [15:0] cflog_bd_rd_src;
output      [15:0] cflog_bd_rd_dest;
output      [15:0] prev_src;
output      [15:0] prev_dest;

// Detect if peripheral access is to Control-Flow Log
//------------------------------  
// software read
wire  [ADDR_MSB:0] cflow_addr_reg  =  {1'b0, 1'b0, per_addr-CFLOW_LOGS_PER_ADDR};
wire               cflow_cen       = per_en & (per_addr >= CFLOW_LOGS_PER_ADDR) & (per_addr < CFLOW_LOGS_PER_ADDR+CFLOW_LOGS_SIZE);
wire  [15:0]       cflow_dout;
wire  [15:0]       cflow_rd        = cflow_dout & {16{cflow_cen & ~|per_we}};
wire  [ADDR_MSB:0] read_addr = cflow_addr_reg;        		   // Read address

// write address of CFA hardware
wire  [ADDR_MSB:0] cfa_write_addr = cflow_logs_ptr_din-16'h2;      // Write address

// write address of Spec-CFA hardware
wire  [ADDR_MSB:0] spec_write_addr = active_block_cflog_addr-16'h2;      // Write address

// Emulate RAM Block Memory 
//============
(* ram_style = "block" *) reg         [15:0] cflog [0:CFLOW_LOGS_SIZE-1]; 
reg         [ADDR_MSB:0] ram_addr_reg;

reg        [15:0] cflog_val;


// Emulate Memory Access
//============

// read next-to-last cflog entry for Block Detect module
assign cflog_bd_rd_src = cflog[bd_log_ptr];
assign cflog_bd_rd_dest = cflog[bd_log_ptr+1];

// read previous entry for repeat detection
assign prev_src = cflog[bd_log_ptr-2];
assign prev_dest = cflog[bd_log_ptr-1];

integer i;
initial 
    begin
        for(i=0; i<MEM_SIZE; i=i+1)
        begin
            cflog[i] <= 0;
        end
        ram_addr_reg <= 0;
        cflog_val <=  cflog[0];
    end

always @(posedge mclk)
    begin
        // CFA hardware writes to cflog when cflow_hw_wen enabled
        if (cflow_hw_wen & cfa_write_addr<CFLOW_LOGS_SIZE)
        begin
            cflog[cfa_write_addr]             <= cflow_src;
            cflog[cfa_write_addr+1'b1]        <= cflow_dest;
        end
        // Spec-CFA hardware writes to cflog when subpath is detect
	if (detect_active & spec_write_addr<CFLOW_LOGS_SIZE)
	begin
		cflog[spec_write_addr]             <= spec_upper;
		cflog[spec_write_addr+1'b1]        <= spec_lower;
	end        
    end

assign per_dout = cflog[read_addr] & {16{cflow_cen}};
 
endmodule // cflogmem
