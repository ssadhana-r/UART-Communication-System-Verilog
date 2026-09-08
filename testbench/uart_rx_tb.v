`timescale 1ns / 1ps

module uart_rx_tb;

reg clk;
reg reset;
reg rx_serial;

wire [7:0] rx_data;
wire rx_valid;

always #10 clk = ~clk;

uart_rx #(
    .CLOCK_FREQ(50_000_000),
    .BAUD_RATE(9_600)
) dut (
    .clk(clk),
    .reset(reset),
    .rx_serial(rx_serial),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
);

initial begin

    clk = 0;
    reset = 1;
    rx_serial = 1;

    #100;
    reset = 0;

    // Start bit
    rx_serial = 0;
    #104170;

    // Data bit 0
    rx_serial = 1;
    #104170;

    // Data bit 1
    rx_serial = 0;
    #104170;

    // Data bit 2
    rx_serial = 1;
    #104170;

    // Data bit 3
    rx_serial = 0;
    #104170;

    // Data bit 4
    rx_serial = 0;
    #104170;

    // Data bit 5
    rx_serial = 1;
    #104170;

    // Data bit 6
    rx_serial = 0;
    #104170;

    // Data bit 7
    rx_serial = 1;
    #104170;

    // Stop bit
    rx_serial = 1;
    #104170;

    rx_serial = 1;

    #1000;
    $finish;

end

endmodule
