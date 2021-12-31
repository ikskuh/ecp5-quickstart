module top (
  input global_clk,   // 12 MHz
  input btn,          // Active LOW
  input global_reset, // Active LOW
  output [7:0] led,   // Active LOW
  input  [7:0] switch, // Active LOW
  output uart_txd,
  input uart_rxd,
  output mirror_uart_txd,
  output mirror_uart_rxd
);
  wire clk, clk_locked;

  assign mirror_uart_txd = uart_txd;
  assign mirror_uart_rxd = uart_rxd;

  ECP5_PLL #(.IN_MHZ(12), .OUT0_MHZ(160), .OUT1_MHZ(12), .OUT3_MHZ(12)) pll
     (.clkin(global_clk), .reset(1'b0), .standby(1'b0), .locked(clk_locked), .clkout0(clk));

  localparam system_freq = 160_000_000;

  reg [31:0] counter;
  reg [7:0] led_state;

  initial begin
    counter <= 0;
    led_state <= 8'b1010_1010;
  end

  assign led = ~led_state;
 
  always @ (posedge clk) begin
    if (global_reset == 0) begin
      counter <= 0;
    end else begin 
      if (counter == system_freq - 1) begin
        counter <= 0;
        led_state <= led_state + 1;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  localparam baud_rate = 115_200;

  wire data_avail;
  wire send;
  wire [7:0] serial_data_in;
  wire [7:0] serial_data_out;

  wire can_read;
  wire tx_busy;
  wire send_data;

  assign send_data = can_read && !tx_busy;

  uart_sender uart0_tx (
      .clk(clk), 
      .rst(global_reset), 
      
      .send(send_data), 
      .busy(tx_busy),
      .data(serial_data_out), 

      .txd(uart_txd)
    );
  defparam uart0_tx.clk_freq = system_freq;
  defparam uart0_tx.baud_rate = baud_rate;

  uart_receiver uart0_rx (.clk(clk), .rst(global_reset), .avail(data_avail), .data(serial_data_in), .rxd(uart_rxd));
    // error, busy, 
  defparam uart0_rx.clk_freq = system_freq;
  defparam uart0_rx.baud_rate = baud_rate;

  fifo uart0_fifo ( 
    .rst(global_reset), .clk(clk), 

    .write(data_avail),
    .write_data(serial_data_in),

    .read(send_data),
    .read_data(serial_data_out), 

    // .can_write(), ignore this for now
    .can_read(can_read)
  );
  defparam uart0_fifo.length = 8;
  defparam uart0_fifo.bit_width = 8;

endmodule