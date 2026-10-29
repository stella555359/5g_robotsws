import serial
import sys
import getopt


def main(argv):
    port = ""
    Set_baudrate = 115200

    # print (argv)

    if len(argv) == 0:
        print('Usage:')
        print('  python DettachUE.py -p <UEmodemPort> [-b <SerialBaudRate>]')
        print('  long option name --port --baudrate')
        sys.exit(2)
    try:
        opts, args = getopt.getopt(argv, "p:b:i:", ["port=", "baudrate=", "wait_ip="])
    except getopt.GetoptError:
        print('Usage:')
        print('  python DettachUE.py -p <UEmodemPort> [-b <SerialBaudRate>]')
        print('  long option name --port --baudrate')
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-p", "--port"):
            port = str(arg)
        elif opt in ("-b", "--baudrate"):
            Set_baudrate = int(arg)

    if port == "":
        print('Usage:')
        print('  python DettachUE.py -p <UEmodemPort> [-b <SerialBaudRate>]')
        print('  long option name --port --baudrate')

    modem = serial.Serial(port, baudrate=Set_baudrate)
    resp = ""
    send = modem.write(str.encode('AT+CGATT=0\r'))
    while resp != 'OK' and resp != 'ERROR':
        resp = modem.readline()
        resp = resp.decode()
        resp = resp.rstrip('\r\n')
    print(resp)


if __name__ == '__main__':
    main(sys.argv[1:])
