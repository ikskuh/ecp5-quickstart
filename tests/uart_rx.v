module uart_rx_testbench(input clk, input rst);

  wire data_avail;
  wire [7:0] data;

  reg rxd = 1;

  initial begin
    #4; // wait

    rxd <= 0; // START
    #16 rxd <= 1; // BIT 0
    #16 rxd <= 0; // BIT 1
    #16 rxd <= 1; // BIT 2
    #16 rxd <= 0; // BIT 3
    #16 rxd <= 1; // BIT 4
    #16 rxd <= 0; // BIT 5
    #16 rxd <= 1; // BIT 6
    #16 rxd <= 0; // BIT 7
    #16 rxd <= 1; ; // STOP

    #64 $finish;
  end

  uart_receiver uart (.clk(clk), .rst(rst), .avail(data_avail), .data(data), .rxd(rxd));
  defparam uart.clk_freq = 8; 
  defparam uart.baud_rate = 1;  

endmodule