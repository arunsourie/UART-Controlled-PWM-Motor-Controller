import serial
import msvcrt
import time

# Update this to match the port shown in Windows Device Manager
COM_PORT = 'COM3'  
BAUD_RATE = 115200

try:
    # Open the serial port
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
    print(f"Successfully connected to {COM_PORT} at {BAUD_RATE} baud.")
    print("Motor Controls:")
    print("  [W]     - Speed Up")
    print("  [S]     - Slow Down")
    print("  [Space] - Emergency Stop")
    print("  [Q]     - Quit script")
    print("-" * 30)

    while True:
        # Check if a key has been pressed
        if msvcrt.kbhit():
            # Read the key and convert it to uppercase
            key_bytes = msvcrt.getch()
            
            try:
                key = key_bytes.decode('utf-8').upper()
            except UnicodeDecodeError:
                continue # Ignore non-standard keys like arrow keys

            if key in ['W', 'S', ' ']:
                ser.write(key.encode('utf-8'))
                
                if key == ' ':
                    print("Sent: [EMERGENCY STOP]")
                else:
                    print(f"Sent: {key}")
                    
                time.sleep(0.05) # Tiny debounce delay
                
            elif key == 'Q':
                print("Closing connection...")
                break

except serial.SerialException as e:
    print(f"\n[ERROR] Could not open {COM_PORT}.")
    print("1. Is the USB connected?")
    print("2. Is the COM port number correct in Device Manager?")
    print("3. Do you have a serial terminal like PuTTY already open holding the port hostage?")
    print(f"Detailed error: {e}")

finally:
    # Safely close the port when the script ends or crashes
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("Serial port closed.")