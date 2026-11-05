# UART-Controlled-PWM-Motor-Controller
This repository contains a complete hardware-software co-design for an open-loop motor controller built on the ZedBoard Zynq-7000 platform. The system uses a custom Verilog-based AXI peripheral to generate precise PWM signals and receive serial commands, driven by a bare-metal embedded C application running on the Cortex-A9 processor.

System Architecture
The project is divided into three functional layers spanning hardware design, embedded firmware, and host control:

1. Programmable Logic (PL): A custom AXI4 slave IP (UART_PWM_Core) built in Vivado 2026.1. It houses two custom Verilog modules:
    - UART_Receiver.v: Operates at 115200 baud (868 clocks per bit at a 100MHz system clock).
    - PWM_Generator.v: Generates a 10kHz PWM signal mapped to a 0–10,000 duty cycle range.

2. Processing System (PS): A bare-metal C application developed in Vitis. It continuously polls the UART receiver's AXI memory registers, scales the incoming 8-bit command (0–255), and writes the updated duty cycle back to the hardware.

3. Host Control Interface: A Python script utilizing the pyserial library to send real-time speed bytes from a PC to the ZedBoard over a USB-to-UART adapter.

Hardware Prerequisites
1. ZedBoard Zynq Evaluation and Development Kit
2. L298N Motor Driver Module and a DC Motor
3. USB-to-UART TTL Adapter
4. Digital Storage Oscilloscope (DSO) or Logic Analyzer (for physical signal verification)
5. 12V DC External Power Supply (for the motor)
