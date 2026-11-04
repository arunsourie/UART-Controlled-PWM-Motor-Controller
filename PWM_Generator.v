`timescale 1ns / 1ps

module PWM_Generator #(
    parameter COUNTER_WIDTH = 32
)(
    input  wire                     clk,           // High-speed PL clock (e.g., 100 MHz)
    input  wire                     reset_n,       // Active-low synchronous reset
    input  wire                     en,            // Enable toggle to start/stop the motor instantly
    input  wire [COUNTER_WIDTH-1:0] period_count,  // Defines the PWM frequency (Total clock ticks)
    input  wire [COUNTER_WIDTH-1:0] duty_count,    // Defines the ON time (Clock ticks pin is HIGH)
    output reg                      pwm_out        // Physical output to the motor driver IC
);

    reg [COUNTER_WIDTH-1:0] timer_reg;

    always @(posedge clk) begin
        if (!reset_n) begin
            timer_reg <= 0;
            pwm_out   <= 1'b0;
        end 

        else if (en) begin
            if (timer_reg >= period_count - 1) begin
                timer_reg <= 0;
            end
            else begin
                timer_reg <= timer_reg + 1;
            end

            // Duty Cycle
            if (timer_reg < duty_count) begin
                pwm_out <= 1'b1; // Output HIGH
            end else begin
                pwm_out <= 1'b0; // Output LOW
            end
        end 
        
        else begin
            timer_reg <= 0;
            pwm_out   <= 1'b0;
        end
    end
endmodule