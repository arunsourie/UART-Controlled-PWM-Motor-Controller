`include "PWM_Generator.v"
`timescale 1ns / 1ps

module PWM_Generator_tb();
    reg clk;
    reg reset_n;
    reg en;
    reg [31:0] period_count;
    reg [31:0] duty_count;
    wire pwm_out;

    PWM_Generator #(
        .COUNTER_WIDTH(32)
    ) uut (
        .clk(clk),
        .reset_n(reset_n),
        .en(en),
        .period_count(period_count),
        .duty_count(duty_count),
        .pwm_out(pwm_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; //Clock: 100 MHz (10ns period)
    end

    initial begin
        reset_n = 0;
        en = 0;
        period_count = 100;
        duty_count = 0;
        #100;        
        reset_n = 1;
        en = 1;
        // Test Case 1: 25% Duty Cycle
        duty_count = 25;
        #500;
        // Test Case 2: 50% Duty Cycle
        duty_count = 50;
        #500;
        // Test Case 3: 75% Duty Cycle
        duty_count = 75;
        #500;
        // Test Case 4: 100% Duty Cycle (Always ON)
        duty_count = 100;
        #500;
        // Test Case 5: 0% Duty Cycle (Always OFF)
        duty_count = 0;
        #500;
        // Test Case 6: Disable module entirely
        en = 0;
        #200;
        $display("Simulation Complete.");
        $finish;
    end
endmodule