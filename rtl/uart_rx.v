module uart_rx #(
    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE  = 9_600
)(
    input wire       clk,
    input wire       reset,
    input wire       rx_serial,

    output reg [7:0] rx_data,
    output reg       rx_valid
);

localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

localparam [1:0] IDLE      = 2'b00,
                 START_BIT = 2'b01,
                 DATA_BITS = 2'b10,
                 STOP_BIT  = 2'b11;

reg [1:0]  state;
reg [15:0] baud_counter;
reg [2:0]  bit_index;

reg rx_sync1;
reg rx_sync2;


// 2-Flip-Flop Synchronizer
always @(posedge clk) begin
    if (reset) begin
        rx_sync1 <= 1;
        rx_sync2 <= 1;
    end
    else begin
        rx_sync1 <= rx_serial;
        rx_sync2 <= rx_sync1;
    end
end


// UART Receiver FSM
always @(posedge clk) begin
    if (reset) begin
        state        <= IDLE;
        baud_counter <= 0;
        bit_index    <= 0;
        rx_data      <= 0;
        rx_valid     <= 0;
    end
    else begin
        rx_valid <= 0;

        case (state)

            IDLE: begin
                baud_counter <= 0;
                bit_index    <= 0;

                if (rx_sync2 == 0) begin
                    state <= START_BIT;
                end
            end


            START_BIT: begin
                if (baud_counter < (CLKS_PER_BIT / 2) - 1) begin
                    baud_counter <= baud_counter + 1;
                end
                else begin
                    baud_counter <= 0;

                    if (rx_sync2 == 0) begin
                        state <= DATA_BITS;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
            end


            DATA_BITS: begin
                if (baud_counter < CLKS_PER_BIT - 1) begin
                    baud_counter <= baud_counter + 1;
                end
                else begin
                    baud_counter <= 0;

                    rx_data[bit_index] <= rx_sync2;

                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end
                    else begin
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end
                end
            end


            STOP_BIT: begin
                if (baud_counter < CLKS_PER_BIT - 1) begin
                    baud_counter <= baud_counter + 1;
                end
                else begin
                    baud_counter <= 0;

                    if (rx_sync2 == 1) begin
                        rx_valid <= 1;
                    end

                    state <= IDLE;
                end
            end

        endcase
    end
end

endmodule
