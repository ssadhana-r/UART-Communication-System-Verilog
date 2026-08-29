module uart_tx #(
    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE  = 9_600
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx_serial,
    output reg        tx_busy,
    output reg        tx_done
);
localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;
localparam [1:0] IDLE      = 2'b00,
                 START_BIT = 2'b01,
                 DATA_BITS = 2'b10,
                 STOP_BIT  = 2'b11;
reg [1:0] state;

reg [15:0] baud_counter;
reg [2:0]  bit_index;
reg [7:0]  tx_data_reg;

always @(posedge clk) begin
    if (reset) begin
        state        <= IDLE;
        baud_counter <= 0;
        bit_index    <= 0;
        tx_data_reg  <= 0;
        tx_serial    <= 1;
        tx_busy      <= 0;
        tx_done      <= 0;
    end
    else begin
        tx_done <= 0;
        case (state)

    IDLE: begin
        tx_serial    <= 1;
        tx_busy      <= 0;
        baud_counter <= 0;
        bit_index    <= 0;
 
        if (tx_start) begin
           tx_data_reg <= tx_data;
           tx_busy     <= 1;
           state       <= START_BIT;
        end
    end

    START_BIT: begin
        tx_serial <= 0;

    if (baud_counter < CLKS_PER_BIT - 1) begin
        baud_counter <= baud_counter + 1;
    end
    else begin
        baud_counter <= 0;
        state <= DATA_BITS;
    end    
    end

    DATA_BITS: begin
        tx_serial <= tx_data_reg[bit_index];

        if (baud_counter < CLKS_PER_BIT - 1) begin
           baud_counter <= baud_counter + 1;
    end
        else begin
            baud_counter <= 0;

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
        tx_serial <= 1;

    if (baud_counter < CLKS_PER_BIT - 1) begin
        baud_counter <= baud_counter + 1;
    end
    else begin
        baud_counter <= 0;
        tx_done <= 1;
        tx_busy <= 0;
        state <= IDLE;
    end
    end
endcase
    end
end                
endmodule
