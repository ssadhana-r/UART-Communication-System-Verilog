`timescale 1ns / 1ps

module uart_tx_tb;

reg clk;
reg reset;
reg tx_start;
reg [7:0] tx_data;

wire tx_serial;
wire tx_busy;
wire tx_done;

always #10 clk = ~clk;

uart_tx #(
    .CLOCK_FREQ(50_000_000),
    .BAUD_RATE(9_600)
) dut (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_serial(tx_serial),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

initial begin
    clk      = 0;
    reset    = 1;
    tx_start = 0;
    tx_data  = 8'b0;

    #100;
    reset = 0;

    #100;
    tx_data  = 8'b1010_0101;
    tx_start = 1;

    #20;
    tx_start = 0;

    #2_000_000;
    $finish;
end

endmodule
