import serial
import sys
import getopt


def main(argv):
    port = ""
    wait_imsi = ""
    wait_imei = ""
    Set_baudrate = 115200

    if len(argv) == 0:
        print('Usage:')
        print('  python AttachUE.py -p <UEmodemPort> -i imsi -e imei [-b <SerialBaudRate>]')
        print('  long option name --port --baudrate --imsi --imei')
        sys.exit(2)
    try:
        opts, args = getopt.getopt(argv, "p:b:i:e:", ["port=", "baudrate=", "imsi=", "imei="])
    except getopt.GetoptError:
        print('Usage:')
        print('  python AttachUE.py -p <UEmodemPort> -i imsi -e imei [-b <SerialBaudRate>]')
        print('  long option name --port --baudrate --imsi --imei')
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-p", "--port"):
            port = arg
        elif opt in ("-b", "--baudrate"):
            Set_baudrate = int(arg)
        elif opt in ("-i", "--imsi"):
            wait_imsi = arg
        elif opt in ("-e", "--imei"):
            wait_imei = arg

    if port == "" or wait_imsi == "" or wait_imei == "":
        print('Usage:')
        print('  python AttachUE.py -p <UEmodemPort> -i imsi -e imei [-b <SerialBaudRate>]')
        print('  long option name --port --baudrate --imsi --imei')
        sys.exit(2)

    modem = serial.Serial(port, baudrate=Set_baudrate)
    resp = ""
    send = modem.write(str.encode('ATE1\r'))
    while resp != 'OK' and resp != 'ERROR':
        resp = modem.readline()
        resp = resp.decode()
        resp = resp.rstrip('\r\n')
    if wait_imei != 'None':
        send = modem.write(str.encode('AT+CGSN\r'))
        resp = modem.readline()
        resp = resp.decode()
        resp = resp.rstrip("\r\n")
        if resp != 'AT+CGSN':
            print('NOK')
            sys.exit(1)
        resp = modem.readline()
        resp = resp.decode()
        resp = resp.rstrip("\r\n")
        if resp != wait_imei:
            print("IMEI : " + resp)
            print('NOK')
            sys.exit(1)

    send = modem.write(str.encode('AT+CIMI\r'))
    resp = modem.readline()
    resp = resp.decode()
    resp = resp.rstrip("\r\n")
    if resp != 'AT+CIMI':
        print('NOK')
        sys.exit(1)
    resp = modem.readline()
    resp = resp.decode()
    resp = resp.rstrip("\r\n")
    if resp != wait_imsi:
        print("IMSI : " + resp)
        print('NOK')
        sys.exit(1)
    while resp != 'OK' and resp != 'ERROR':
        resp = modem.readline()
        resp = resp.decode()
        resp = resp.rstrip("\r\n")
    print(resp)


if __name__ == '__main__':
    main(sys.argv[1:])
