#!/usr/bin/python3
import telnetlib
import time


def test(incr, loop):
    value = int(incr) * int(loop)
    try:
        telnet = telnetlib.Telnet('10.45.153.204', 3001)
    except Exception as e:
        print(e)
    cmd = "SMA 9 " + str(value) + ",10 " + str(value) + ",11 " + str(value) + ",12 " + str(value)
    print(cmd)
    telnet.write((cmd + "\r\n").encode('ascii'))
    time.sleep(5)
    val = telnet.read_until(b"\n")
    print(val)
    telnet.close()


def pva(value1, value2):
    test(value1, value2)
