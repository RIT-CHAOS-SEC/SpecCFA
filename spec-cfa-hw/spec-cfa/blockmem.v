//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
// 
// *File Name: ram.v
// 
// *Module Description:
//                      Scalable RAM model
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------

module blockmem (

// OUTPUTs
    ram_dout,                      // RAM data output
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

// INPUTs
    block_ptr,
    block_ptr2,
    block_ptr3,
    block_ptr4,
    block_ptr5,
    block_ptr6,
    block_ptr7,
    block_ptr8,
    ram_addr,                      // RAM address
    ram_cen,                       // RAM chip enable (low active)
    ram_clk,                       // RAM clock
    ram_din,                       // RAM data input
    ram_wen                        // RAM write enable (low active)
);

// PARAMETERs
//============
parameter ADDR_MSB   =  7;         // MSB of the address bus
parameter MEM_SIZE   =  512;       // Memory size in bytes


// OUTPUTs
//============
output      [15:0] ram_dout;       // RAM data output
output [15:0] block_entry_src;
output [15:0] block_entry_dest;
output [7:0] block_len;
output [7:0] block_id;
output [15:0] block_entry_src2;
output [15:0] block_entry_dest2;
output [7:0] block_len2;
output [7:0] block_id2;
output [15:0] block_entry_src3;
output [15:0] block_entry_dest3;
output [7:0] block_len3;
output [7:0] block_id3;
output [15:0] block_entry_src4;
output [15:0] block_entry_dest4;
output [7:0] block_len4;
output [7:0] block_id4;
output [15:0] block_entry_src5;
output [15:0] block_entry_dest5;
output [7:0] block_len5;
output [7:0] block_id5;
output [15:0] block_entry_src6;
output [15:0] block_entry_dest6;
output [7:0] block_len6;
output [7:0] block_id6;
output [15:0] block_entry_src7;
output [15:0] block_entry_dest7;
output [7:0] block_len7;
output [7:0] block_id7;
output [15:0] block_entry_src8;
output [15:0] block_entry_dest8;
output [7:0] block_len8;
output [7:0] block_id8;

//============
input         [15:0] block_ptr;
input         [15:0] block_ptr2;
input         [15:0] block_ptr3;
input         [15:0] block_ptr4;
input         [15:0] block_ptr5;
input         [15:0] block_ptr6;
input         [15:0] block_ptr7;
input         [15:0] block_ptr8;
input [ADDR_MSB:0] ram_addr;       // RAM address
input              ram_cen;        // RAM chip enable (low active)
input              ram_clk;        // RAM clock
input       [15:0] ram_din;        // RAM data input
input        [1:0] ram_wen;        // RAM write enable (low active)
//


// RAM
//============
(* ram_style = "block" *) reg         [15:0] blockmem [0:(MEM_SIZE/2)-1];
reg         [ADDR_MSB:0] ram_addr_reg;
wire        [15:0] mem_val = blockmem[ram_addr];

reg [7:0] block_base = 16'h0000;
reg [15:0] block_base2 = 16'h0000;
reg [15:0] block_base3 = 16'h0000;
reg [15:0] block_base4 = 16'h0000;
reg [15:0] block_base5 = 16'h0000;
reg [15:0] block_base6 = 16'h0000;
reg [15:0] block_base7 = 16'h0000;
reg [15:0] block_base8 = 16'h0000;
//for debug
wire         [ADDR_MSB:0] block_src_addr = block_base+block_ptr+1;
wire         [ADDR_MSB:0] block_dest_addr = block_base+block_ptr+2;
wire         [ADDR_MSB:0] block_src_addr2 = block_base2+block_ptr2+1;
wire         [ADDR_MSB:0] block_dest_addr2 = block_base2+block_ptr2+2;
wire         [ADDR_MSB:0] block_src_addr3 = block_base3+block_ptr3+1;
wire         [ADDR_MSB:0] block_dest_addr3 = block_base3+block_ptr3+2;
wire         [ADDR_MSB:0] block_src_addr4 = block_base4+block_ptr4+1;
wire         [ADDR_MSB:0] block_dest_addr4 = block_base4+block_ptr4+2;
wire         [ADDR_MSB:0] block_src_addr5 = block_base5+block_ptr5+1;
wire         [ADDR_MSB:0] block_dest_addr5 = block_base5+block_ptr5+2;
wire         [ADDR_MSB:0] block_src_addr6 = block_base6+block_ptr6+1;
wire         [ADDR_MSB:0] block_dest_addr6 = block_base6+block_ptr6+2;
wire         [ADDR_MSB:0] block_src_addr7 = block_base7+block_ptr7+1;
wire         [ADDR_MSB:0] block_dest_addr7 = block_base7+block_ptr7+2;
wire         [ADDR_MSB:0] block_src_addr8 = block_base8+block_ptr8+1;
wire         [ADDR_MSB:0] block_dest_addr8 = block_base8+block_ptr8+2;

assign block_id = blockmem[block_base][15:8];
assign block_len = blockmem[block_base][7:0];
assign block_entry_src = blockmem[block_src_addr];
assign block_entry_dest = blockmem[block_dest_addr];
assign block_id2 = blockmem[block_base2][15:8];
assign block_len2 = blockmem[block_base2][7:0];
assign block_entry_src2 = blockmem[block_src_addr2];
assign block_entry_dest2 = blockmem[block_dest_addr2];
assign block_id3 = blockmem[block_base3][15:8];
assign block_len3 = blockmem[block_base3][7:0];
assign block_entry_src3 = blockmem[block_src_addr3];
assign block_entry_dest3 = blockmem[block_dest_addr3];
assign block_id4 = blockmem[block_base4][15:8];
assign block_len4 = blockmem[block_base4][7:0];
assign block_entry_src4 = blockmem[block_src_addr4];
assign block_entry_dest4 = blockmem[block_dest_addr4];
assign block_id5 = blockmem[block_base5][15:8];
assign block_len5 = blockmem[block_base5][7:0];
assign block_entry_src5 = blockmem[block_src_addr5];
assign block_entry_dest5 = blockmem[block_dest_addr5];
assign block_id6 = blockmem[block_base6][15:8];
assign block_len6 = blockmem[block_base6][7:0];
assign block_entry_src6 = blockmem[block_src_addr6];
assign block_entry_dest6 = blockmem[block_dest_addr6];
assign block_id7 = blockmem[block_base7][15:8];
assign block_len7 = blockmem[block_base7][7:0];
assign block_entry_src7 = blockmem[block_src_addr7];
assign block_entry_dest7 = blockmem[block_dest_addr7];
assign block_id8 = blockmem[block_base8][15:8];
assign block_len8 = blockmem[block_base8][7:0];
assign block_entry_src8 = blockmem[block_src_addr8];
assign block_entry_dest8 = blockmem[block_dest_addr8];

integer i;
initial 
begin
    for(i=0; i<MEM_SIZE; i=i+1) begin
        blockmem[i] <= 0;
    end
    ram_addr_reg <= 0;
end


always @(posedge ram_clk)
begin
    block_base2 <= 16'h1 + (block_len << 1);
    block_base3 <= block_base2 + 16'h1 + (block_len2 << 1);
    block_base4 <= block_base3 + 16'h1 + (block_len3 << 1);
    block_base5 <= block_base4 + 16'h1 + (block_len4 << 1);
    block_base6 <= block_base5 + 16'h1 + (block_len5 << 1);
    block_base7 <= block_base6 + 16'h1 + (block_len6 << 1);
    block_base8 <= block_base7 + 16'h1 + (block_len7 << 1);
end
  
always @(posedge ram_clk)
begin
    ram_addr_reg <= ram_addr;
    if (~ram_cen & ram_addr<(MEM_SIZE/2))
    begin
        if      (ram_wen==2'b00) blockmem[ram_addr]        <= ram_din;
        else if (ram_wen==2'b01) blockmem[ram_addr][15:8]  <= ram_din[15:8]; //  <= {ram_din[15:8], mem_val[7:0]};
        else if (ram_wen==2'b10) blockmem[ram_addr][7:0]   <= ram_din[7:0]; // <= {mem_val[15:8], ram_din[7:0]};
    end
end

assign ram_dout = blockmem[ram_addr_reg];

endmodule // blockmem
