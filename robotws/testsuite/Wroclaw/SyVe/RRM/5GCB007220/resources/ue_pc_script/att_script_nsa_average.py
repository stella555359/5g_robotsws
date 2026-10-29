import sys
import time
import serial
import os

MANUAL_INFO_MSG = """
Script must be executed with 3 arguments!
Possible script usage:
- python att_script_nsa_average.py First Second Third
Example: python att_script_nsa_average.py 0 17 4
First - start from value
Second - end on value
Third - increment by value in steps
"""


def set_attenuation(attenuation_step):
    serialPort.write("sma 5 {0},6 {0},7 {0},8 {0}\r\n".format(attenuation_step))
    os.system('echo Set att to {} >> result_avg.txt'.format(attenuation_step))
    output = [x for x in serialPort.read(100).splitlines() if x]
    os.system('echo output {} >> result_avg.txt'.format(output[0]))


def read_attenuation():
    serialPort.write("raa\r\n")
    output = [x for x in serialPort.read(1000).splitlines() if x]
    os.system("echo Read attenuation {} >> result_avg.txt".format(output[5:9]))


def display_error_and_exit():
    os.system("echo {} >> result_avg.txt".format(MANUAL_INFO_MSG))
    exit(0)


if __name__ == "__main__":
    os.system("echo Start script: > result_avg.txt")
    os.system("echo WinPID:{} >> result_avg.txt".format(os.getpid()))
    if len(sys.argv) != 4:
        display_error_and_exit()
    start, stop, step = sys.argv[1:]
    serialPort = serial.Serial(
        port="COM13", baudrate=115200, bytesize=8, timeout=2)
    for attenuation in range(int(start), int(stop), int(step)):
        set_attenuation(attenuation)
        read_attenuation()
        time.sleep(15)
    serialPort.close()
    os.system("echo DONE >> result_avg.txt")
