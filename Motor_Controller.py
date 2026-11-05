import serial #Use pip install pyserial
import time

SERIAL_PORT = "COM3"
BAUD_RATE = 115200

def setup_serial():
    try:
        ser = serial.Serial(
            port=SERIAL_PORT,
            baudrate=BAUD_RATE,
            bytesize=serial.EIGHTBITS, #Size: 8-bits
            parity=serial.PARITY_NONE, #No parity bits
            stopbits=serial.STOPBITS_ONE,
            timeout=1
        )
        print(f"Connected to Zynq board on {SERIAL_PORT}")
        return ser
    
    except serial.SerialException as e:
        print(f"Error opening serial port: {e}")
        return None

def speed_control(ser, speed_percentage):
    speed_percentage = max(0, min(100, speed_percentage))
    command = int((speed_percentage / 100) * 255)
    ser.write(bytes([command]))
    print(f"Send {speed_percentage} speed | Raw Byte: 0x{command:02X}")

if __name__ == '__main__':
    zynq_serial = setup_serial()
    if zynq_serial:
        try:
            while True:
                user_input = input("Enter target motor speed (0-100) or 'Q' to quit: ")
                if user_input.lower() == 'q' or user_input.lower() == 'Q':
                    # Send a 0 speed command to stop the motor safely before quitting
                    speed_control(zynq_serial, 0)
                    print("Shutting Down Controller.")
                    break
                    
                if user_input.isdigit():
                    speed = int(user_input)
                    speed_control(zynq_serial, speed)
                else:
                    print("Invalid input. Please enter a number between 0 and 100.")
                    
        except KeyboardInterrupt:
            speed_control(zynq_serial, 0)
            
        finally:
            zynq_serial.close()