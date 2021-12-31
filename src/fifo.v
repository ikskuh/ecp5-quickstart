module fifo (
  input rst, 
  input clk,
  input write,
  input read,
  input [bit_width - 1:0] write_data,
  output [bit_width - 1:0] read_data, 
  output can_write,
  output can_read
);
  parameter length = 16;
  parameter bit_width = 8;

  assign can_read = (count != 0); 
  assign can_write = (count != length); 
  assign read_data = data[read_counter];

  localparam buffer_bits = $clog2(length);

  localparam buffer_limit = buffer_bits-1;
  localparam word_limit = bit_width-1;

  reg [word_limit:0] data [buffer_limit:0];

  reg [buffer_bits:0]  count = 0; 
  reg [buffer_limit:0] read_counter = 0, write_counter = 0;

  initial begin
    read_counter <= 0;
    write_counter <= 0;
  end

  always @ (posedge clk) 
  begin 
    if (rst == 0) begin 
      read_counter <= 0;
      write_counter <= 0;
    end else begin
      if (read == 1 && write == 1) begin
        // special case: simultaneous read/write always succeeds
        if (read_counter != write_counter) begin
          data[write_counter] <= write_data; 
        end
        read_counter += 1;
        write_counter += 1; 
      end else if(read == 1 && count != 0) begin
        read_counter += 1;
        count -= 1;
      end else if(write == 1 && count < length) begin
        data[write_counter] <= write_data; 
        write_counter += 1; 
        count += 1;
      end 
    end 
  end

endmodule
