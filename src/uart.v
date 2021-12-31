module uart_sender (
  input clk, 
  input rst, 
  input send, 
  output busy,
  input [7:0] data, 
  output txd
);
  parameter clk_freq = 0;        // The frequency of clk
  parameter baud_rate = 115_200; // The desired baud rate

  assign txd = uart_txd_buf;
  assign busy = bsy_state;

  localparam baud_rate_divider = (clk_freq / baud_rate);

  localparam baud_rate_div_bits = $clog2(baud_rate_divider);

  reg [baud_rate_div_bits:0] baud_divier;
  reg uart_txd_buf;
  
  reg [3:0] uart_txd_state; // idle, start, bit 0...7, stop
  reg [7:0] uart_txd_data;
  reg bsy_state;

  initial begin
    uart_txd_buf <= 1;
    uart_txd_state <= 0;
  end

  localparam START = 0;
  localparam IDLE = 1;
  localparam STOP = 1;

  always @ (posedge clk, negedge rst) begin 
    if (rst == 0) begin
      uart_txd_buf <= 1;
      uart_txd_state <= 0;
    end else begin 

      if (uart_txd_state == 0) begin

        if (send == 1) begin
          uart_txd_buf <= START; // START
          uart_txd_state <= 1; // SEND BIT 0
          uart_txd_data <= data;
          baud_divier <= 0;
          bsy_state <= 1;
        end else begin
          uart_txd_buf <= IDLE; // IDLE
          uart_txd_state <= 0; // keep idling
        end

      end else begin
        if (baud_divier == baud_rate_divider - 1) begin
          baud_divier <= 0;

          case(uart_txd_state) 
            1: uart_txd_buf <= uart_txd_data[0];
            2: uart_txd_buf <= uart_txd_data[1];
            3: uart_txd_buf <= uart_txd_data[2];
            4: uart_txd_buf <= uart_txd_data[3];
            5: uart_txd_buf <= uart_txd_data[4];
            6: uart_txd_buf <= uart_txd_data[5];
            7: uart_txd_buf <= uart_txd_data[6];
            8: uart_txd_buf <= uart_txd_data[7];
            9: uart_txd_buf <= STOP;
            default: begin
              uart_txd_state <= 0;
              bsy_state <= 0;
            end
          endcase
          if (uart_txd_state != 10) begin
            uart_txd_state <= uart_txd_state + 1;
          end
        end else begin
          baud_divier <= baud_divier + 1;
        end
      end
    end
  end
endmodule

module uart_receiver(
  input clk,
  input rst, 
  output avail, 
  output error, 
  output busy, 
  output [7:0] data, 
  input rxd
);
  parameter clk_freq = 0;        // The frequency of clk
  parameter baud_rate = 115_200; // The desired baud rate

  assign busy = bsy_state;
  assign data = uart_txd_data;
  assign avail = avail_buf;
  assign error = error_buf;

  localparam baud_rate_divider = (clk_freq / baud_rate);
  localparam baud_rate_div_bits = $clog2(baud_rate_divider);

  reg [baud_rate_div_bits:0] baud_divier;
  
  reg [3:0] uart_txd_state; // idle, start, bit 0...7, stop
  reg [7:0] uart_txd_data;  // stores the last received byte
  reg [7:0] uart_txd_inbox; // stores the data in-flight
  reg bsy_state;
  reg avail_buf, error_buf;

  initial begin
    uart_txd_state <= 0;
    uart_txd_data <= 0;
    avail_buf <= 0;
    bsy_state <= 0;
    error_buf <= 0;
  end

  localparam START = 0;
  localparam STOP = 1;

  reg [7:0] sliding_window;
  reg [2:0] sliding_window_index;
  reg [baud_rate_div_bits:0] sampling_divider;

  always @ (posedge clk) begin
    if (uart_txd_state == 0) begin
      sampling_divider <= baud_rate_divider / 8 - 1;
      sliding_window_index <= 0;
    end else begin
      if (sampling_divider == 0) begin
        sliding_window[sliding_window_index] <= rxd;
        sampling_divider <= baud_rate_divider / 8 - 1;
        sliding_window_index += 1;
      end else begin 
        sampling_divider -= 1;
      end
  
    end
  end

  wire rxd_smoothed = (sliding_window[0] + sliding_window[1] + sliding_window[2] + sliding_window[3] + sliding_window[4] + sliding_window[5] + sliding_window[6] + sliding_window[7]) >= 4;

  always @ (posedge clk, negedge rst) begin 
    if (rst == 0) begin
      uart_txd_state <= 0;
      uart_txd_data <= 0;
      avail_buf <= 0;
      bsy_state <= 0;
      error_buf <= 0;
    end else begin 

      if (uart_txd_state == 0) begin

        avail_buf <= 0;
        error_buf <= 0;

        if (rxd == START) begin
          uart_txd_state <= 1; // SEND BIT 0
          baud_divier <= 2 * baud_rate_divider - 1; 
          bsy_state <= 1;
        end else begin
          uart_txd_state <= 0; // keep idling
        end

      end else begin
        if (baud_divier == 0) begin
          baud_divier <= baud_rate_divider - 1;

          case(uart_txd_state) 
            1: uart_txd_inbox[0] <= rxd_smoothed;
            2: uart_txd_inbox[1] <= rxd_smoothed;
            3: uart_txd_inbox[2] <= rxd_smoothed;
            4: uart_txd_inbox[3] <= rxd_smoothed;
            5: uart_txd_inbox[4] <= rxd_smoothed;
            6: uart_txd_inbox[5] <= rxd_smoothed;
            7: uart_txd_inbox[6] <= rxd_smoothed;
            8: uart_txd_inbox[7] <= rxd_smoothed;
            default: begin
              uart_txd_state <= 0;
              bsy_state <= 0;
              avail_buf <= (rxd_smoothed == STOP);
              error_buf <= (rxd_smoothed != STOP);
              uart_txd_data <= uart_txd_inbox;
            end
          endcase
          if (uart_txd_state != 9) begin
            uart_txd_state <= uart_txd_state + 1;
          end
        end else begin
          baud_divier <= baud_divier - 1;
        end
      end
    end
  end

endmodule