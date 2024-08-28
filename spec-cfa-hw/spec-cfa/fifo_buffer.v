module fifo_buffer (
    clk,
    reset,
    write_en,
    read_en,
    data_in,

    data_out,
    occupancy
);

parameter DATA_WIDTH = 32;
parameter BUFFER_SIZE = 8;
parameter ADDR_WIDTH = 3;

// INPUTS
input clk;
input reset;
input write_en;
input read_en;
input [DATA_WIDTH-1:0] data_in;

// OUTPUTS
output [DATA_WIDTH-1:0] data_out;
output [ADDR_WIDTH-1:0] occupancy;

reg [ADDR_WIDTH-1:0] write_ptr = 0;
reg [ADDR_WIDTH-1:0] read_ptr = 0;
reg [DATA_WIDTH-1:0] buffer [0:BUFFER_SIZE-1];
reg write_en_dly;
reg read_en_dly;

assign occupancy = write_ptr >= read_ptr ? write_ptr - read_ptr : 8 - read_ptr + write_ptr;
assign data_out = buffer[read_ptr];

integer i;
initial
begin
    for(i=0; i<BUFFER_SIZE; i = i + 1) begin
        buffer[i] = 32'h0;
    end
end

always @(posedge clk) begin
    if (reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
    end
    else begin
        // Delay write_en by one clock cycle
        write_en_dly <= write_en;
        
        // Write data to buffer on rising edge of write_en
        if (write_en && !write_en_dly) begin
            buffer[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1;
            if (write_ptr == BUFFER_SIZE) begin
                write_ptr <= 0;
            end
        end
        
        // Delay read_en by one clock cycle
        read_en_dly <= read_en;

        // Read data from buffer on rising edge of read_en
        if (read_en && !read_en_dly) begin
            read_ptr <= read_ptr + 1;
            if (read_ptr == BUFFER_SIZE) begin
                read_ptr <= 0;
            end
        end
    end
end
    
endmodule
