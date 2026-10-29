import serial
import sys
import getopt
import subprocess
import re
import time


def main(argv):
    port = ""
    waitedip = ""
    Set_baudrate = 115200

    if len(argv) == 0:
        print('Usage:\n')
        print('  python AttachUE.py -p <UEmodemPort> -i waitedip [-b <SerialBaudRate>]\n')
        print('  long option name --port --baudrate --wait_ip\n')
        sys.exit(2)
    try:
        opts, args = getopt.getopt(argv, "p:b:i:", ["port=", "baudrate=", "wait_ip="])
    except getopt.GetoptError:
        print('Usage:\n')
        print('  python AttachUE.py -p <UEmodemPort> -i waitedip [-b <SerialBaudRate>]\n')
        print('  long option name --port --baudrate --wait_ip\n')
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-p", "--port"):
            port = arg
        elif opt in ("-b", "--baudrate"):
            Set_baudrate = int(arg)
        elif opt in ("-i", "--wait_ip"):
            waitedip = str(arg)

    if port == "" or waitedip == "":
        print('Usage:\n')
        print('  python AttachUE.py -p <UEmodemPort> -i waitedip [-b <SerialBaudRate>]\n')
        print('  long option name --port --baudrate --wait_ip\n')
        sys.exit(2)

    modem = serial.Serial(port, baudrate=Set_baudrate)
    resp = ""
    send = modem.write(str.encode('AT+CGATT=1\r'))
    while resp != 'OK' and resp != 'ERROR':
        resp = modem.readline()
        resp = resp.decode()
        resp = resp.rstrip('\r\n')

    if resp == 'ERROR':
        sys.exit(1)

    time.sleep(5)
    tocheck = ""
    for i in range(10):
        try:
            tocheck = subprocess.check_output(["wsl", "ip", "addr", "show", "|", "wsl", "grep", waitedip], shell=True)
            tocheck = str(tocheck)
        except subprocess.CalledProcessError:
            time.sleep(5)
            pass
        m = re.search(r'\d+\.\d+\.\d+\.\d+', tocheck)
        if m is not None:
            getip = str(m.group())
            if getip == waitedip:
                print('OK')
                sys.exit(0)
        time.sleep(5)
    print("Error waited IP not get")
    sys.exit(1)


if __name__ == '__main__':
    main(sys.argv[1:])
