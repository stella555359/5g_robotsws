import os
import time
import serial

serialPort = serial.Serial(
    port="COM13", baudrate=115200, bytesize=8, timeout=2)

os.system('echo Result file:> result_att.txt')
os.system("echo WinPID:{} >> result_att.txt".format(os.getpid()))
for attempt in range(0, 60):
    serialPort.write(b"sma 5 30,6 30,7 30,8 30\r\n")
    os.system('echo {}:Command sent 30 db att >> result_att.txt'.format(attempt))
    time.sleep(3)
    serialPort.write(b"sma 5 0,6 0,7 0,8 0\r\n")
    os.system('echo {}:Command sent 0 db att >> result_att.txt'.format(attempt))
    time.sleep(2)

serialPort.close()
