`include "UART_Receiver.v"
`timescale 1ns / 1ps

module UART_Receiver_tb();
    reg clk;
    reg reset_n;
    reg rx_serial;
    wire [7:0] rx_data_out;
    wire       rx_data_valid;
    localparam CLOCK_PERIOD_NS = 10; 
    localparam CLKS_PER_BIT    = 868; 

    UART_Receiver #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk(clk),
        .reset_n(reset_n),
        .rx_serial(rx_serial),
        .rx_data_out(rx_data_out),
        .rx_data_valid(rx_data_valid)
    );

    // Generate 100 MHz Clock
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD_NS / 2) clk = ~clk; 
    end

    task send_byte;
        input [7:0] data;
        integer i;
        begin
            rx_serial = 1'b0; // Start Bit
            #(CLKS_PER_BIT * CLOCK_PERIOD_NS);
            
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial = data[i];
                #(CLKS_PER_BIT * CLOCK_PERIOD_NS);
            end

            rx_serial = 1'b1; // Stop Bit
            #(CLKS_PER_BIT * CLOCK_PERIOD_NS);
        end
    endtask

    initial begin
        reset_n   = 0;
        rx_serial = 1;

        #100;
        reset_n = 1;
        #1000;

        send_byte(8'h5A);
        
        #(3 * CLKS_PER_BIT * CLOCK_PERIOD_NS);

        $finish;
    end
endmodule