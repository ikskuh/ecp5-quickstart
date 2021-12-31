module fifo_testbench(input clk, input rst);

  localparam period = 20;  

  reg write = 0;
  reg [3:0] write_data = 0;

  reg read = 0;
  wire [3:0] read_data;

  initial begin 
    #4 write <= 1;
    write_data <= 4'h5;
    #2 write <= 0;
    #2 read <= 1;
    #2 read <= 0;

    #4 write <= 1;
    write_data <= 4'h9;
    #2 write_data <= 4'hC;
    #2 write <= 0;

    #2 read <= 1;
    #6 read <= 0;

    #100 $finish;
  end

  fifo uart0_fifo ( .rst(rst), .clk(clk),
    .write(write),
    .write_data(write_data),
    .read(read),
    .read_data(read_data)
  );
  defparam uart0_fifo.length = 8;
  defparam uart0_fifo.bit_width = 4;

endmodule