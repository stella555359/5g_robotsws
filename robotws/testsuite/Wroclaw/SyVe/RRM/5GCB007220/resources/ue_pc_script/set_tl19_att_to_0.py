import time
import serial

serialPort = serial.Serial(
    port="COM13", baudrate=115200, bytesize=8, timeout=2)

serialPort.write(b"sma 5 0,6 0,7 0,8 0\r\n")
print("Command sent 0 db att")
time.sleep(2)

serialPort.close()
print("DONE")
