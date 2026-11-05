#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"

// The base address Vitis assigned to your custom IP
// Note: If you get an undeclared error here, check xparameters.h for the exact name
#define CORE_BASE_ADDR XPAR_UART_PWM_CORE_0_S00_AXI_BASEADDR

// Register Offsets (Calculated automatically by the AXI bus: 0x00, 0x04, 0x08, 0x0C)
#define PWM_PERIOD_REG (CORE_BASE_ADDR + 0x00)
#define PWM_DUTY_REG   (CORE_BASE_ADDR + 0x04)
#define PWM_EN_REG     (CORE_BASE_ADDR + 0x08)
#define UART_RX_REG    (CORE_BASE_ADDR + 0x0C)

int main() {
    xil_printf("Starting Motor Controller...\r\n");

    // 1. Set PWM Period (Assuming 100MHz clock, 10,000 count = 10kHz PWM frequency)
    Xil_Out32(PWM_PERIOD_REG, 10000);

    // 2. Set initial Duty Cycle (0 = completely stopped)
    u32 duty = 0;
    Xil_Out32(PWM_DUTY_REG, duty);

    // 3. Enable PWM block (Write 1 to bit 0 of slv_reg2)
    Xil_Out32(PWM_EN_REG, 1);

    u32 uart_data;
    xil_printf("Motor initialized. Use 'W' to speed up, 'S' to slow down, Spacebar to stop.\r\n");

    // 4. Infinite loop to constantly check for serial commands
    while (1) {
        // Read slv_reg3. Bit 8 is the valid pulse, Bits 0-7 are the ASCII character.
        uart_data = Xil_In32(UART_RX_REG);

        // If bit 8 (0x100) is 1, a new byte has arrived
        if (uart_data & 0x100) {
            u8 rx_byte = uart_data & 0xFF; // Mask out just the character data

            if (rx_byte == 'W' || rx_byte == 'w') {
                duty += 1000; // Increase speed by 10%
                if (duty > 10000) duty = 10000;
                Xil_Out32(PWM_DUTY_REG, duty);
                xil_printf("Speed increased. Duty: %d/10000\r\n", duty);
            }
            else if (rx_byte == 'S' || rx_byte == 's') {
                if (duty >= 1000) duty -= 1000; // Decrease speed by 10%
                else duty = 0;
                Xil_Out32(PWM_DUTY_REG, duty);
                xil_printf("Speed decreased. Duty: %d/10000\r\n", duty);
            }
            else if (rx_byte == ' ') { 
                duty = 0; // Emergency Stop
                Xil_Out32(PWM_DUTY_REG, duty);
                xil_printf("EMERGENCY STOP.\r\n");
            }

            // Small delay to prevent reading the exact same valid pulse twice
            for (volatile int i = 0; i < 100000; i++);
        }
    }
    return 0;
}