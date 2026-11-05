#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"

// The base address Vitis assigned to custom IP
#define CORE_BASE_ADDR XPAR_UART_PWM_CORE_0_BASEADDR

// Register Offsets
#define PWM_PERIOD_REG (CORE_BASE_ADDR + 0x00)
#define PWM_DUTY_REG   (CORE_BASE_ADDR + 0x04)
#define PWM_EN_REG     (CORE_BASE_ADDR + 0x08)
#define UART_RX_REG    (CORE_BASE_ADDR + 0x0C)

int main() {
    xil_printf("Starting PWM Motor Controller...\r\n");

    // 1. Set PWM Period (10,000 count = 10kHz PWM frequency at 100MHz clock)
    u32 period = 10000;
    Xil_Out32(PWM_PERIOD_REG, period);

    // 2. Set initial Duty Cycle to 0 (Stopped)
    u32 duty = 0;
    Xil_Out32(PWM_DUTY_REG, duty);

    // 3. Enable PWM block
    Xil_Out32(PWM_EN_REG, 1);

    u32 uart_data;
    xil_printf("System ready. Waiting for 0-255 raw byte speed commands...\r\n");

    while (1) {
        // Read slv_reg3 to check for incoming UART data
        uart_data = Xil_In32(UART_RX_REG);

        // Check if the valid pulse (bit 8) is high
        if (uart_data & 0x100) {
            
            // Extract the raw byte sent from the Python script (0 to 255)
            u32 rx_byte = uart_data & 0xFF; 

            // Scale the 0-255 byte value to the 0-10000 duty cycle range
            duty = (rx_byte * period) / 255;
            
            // Hardware safety check: Ensure duty never exceeds period
            if (duty > period) {
                duty = period;
            }

            // Write the calculated duty cycle to the hardware register
            Xil_Out32(PWM_DUTY_REG, duty);
            
            // Print to Vitis serial terminal for debugging
            xil_printf("Received Raw Byte: %lu | New Duty Cycle: %lu/%lu\r\n", rx_byte, duty, period);

            // Short delay to debounce the valid pulse so we don't read the same byte twice
            for (volatile int i = 0; i < 100000; i++);
        }
    }
    return 0;
}