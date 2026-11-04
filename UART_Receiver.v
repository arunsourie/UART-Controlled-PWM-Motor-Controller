`timescale 1ns / 1ps

module UART_Receiver #(
    parameter CLKS_PER_BIT = 868 // 100 MHz System Clock / 115200 Baud Rate = 868.05
)(
    input  wire       clk,
    input  wire       reset_n,
    input  wire       rx_serial,     // Asynchronous serial pin from PC
    output reg  [7:0] rx_data_out,   // The assembled 8-bit command
    output reg        rx_data_valid  // Pulses HIGH for one clock tick when data is ready
);

    // State Machine Definitions
    localparam IDLE         = 3'b000;
    localparam RX_START_BIT = 3'b001;
    localparam RX_DATA_BITS = 3'b010;
    localparam RX_STOP_BIT  = 3'b011;
    localparam CLEANUP      = 3'b100;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;

    // Double-flop synchronizer to prevent metastability
    reg rx_sync_1, rx_sync_2;

    always @(posedge clk) begin
        if (!reset_n) begin
            rx_sync_1 <= 1'b1;
            rx_sync_2 <= 1'b1; // UART lines idle HIGH
        end else begin
            rx_sync_1 <= rx_serial;
            rx_sync_2 <= rx_sync_1;
        end
    end

    // UART Receiver Finite State Machine
    always @(posedge clk) begin
        if (!reset_n) begin
            state         <= IDLE;
            clk_count     <= 0;
            bit_index     <= 0;
            rx_data_out   <= 0;
            rx_data_valid <= 0;
        end
        else begin
            rx_data_valid <= 0;

            case (state)
                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx_sync_2 == 1'b0) begin
                        state <= RX_START_BIT;
                    end
                end

                RX_START_BIT: begin
                    // Wait until the middle of the start bit to sample
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        if (rx_sync_2 == 1'b0) begin
                            clk_count <= 0;
                            state     <= RX_DATA_BITS;
                        end
                        else begin
                            state     <= IDLE;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end

                RX_DATA_BITS: begin
                    // Wait for the full bit period to sample in the middle
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end
                    else begin
                        clk_count <= 0;
                        rx_data_out[bit_index] <= rx_sync_2;

                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state     <= RX_STOP_BIT;
                        end
                    end
                end

                RX_STOP_BIT: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        rx_data_valid <= 1'b1;
                        clk_count     <= 0;
                        state         <= CLEANUP;
                    end
                end

                CLEANUP: begin
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule