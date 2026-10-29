import time
import serial

serialPort = serial.Serial(
    port="COM13", baudrate=115200, bytesize=8, timeout=2)

serialPort.write(b"sma 1 0,2 0,3 0,4 0\r\n")
print("Command sent 0 db att")
time.sleep(2)

serialPort.close()
print("DONE")
