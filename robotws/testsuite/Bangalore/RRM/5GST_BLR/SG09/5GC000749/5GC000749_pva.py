#!/usr/bin/python3
import telnetlib
import time


# NRCELL 0 - FDD - port 13 of PVA to make max attenuation.
def PVA_Attenuate_Max_NR_Cell_0(ip):
    telnet = telnetlib.Telnet(ip, 3001)
    telnet.write(("SMA 13 120\r\n").encode())
    time.sleep(5)
    val = telnet.read_until(b"\n")
    telnet.close()


# NRCELL 1 - TDD - port 14 of PVA to make max attenuation.
def PVA_Attenuate_Max_NR_Cell_1(ip):
    telnet = telnetlib.Telnet(ip, 3001)
    telnet.write(("SMA 14 120\r\n").encode())
    time.sleep(5)
    val = telnet.read_until(b"\n")
    telnet.close()


# NRCELL 2 - TDD - port 15 of PVA to make max attenuation.
def PVA_Attenuate_Max_NR_Cell_2(ip):
    telnet = telnetlib.Telnet(ip, 3001)
    telnet.write(("SMA 15 120\r\n").encode())
    time.sleep(5)
    val = telnet.read_until(b"\n")
    telnet.close()


# NRCELL 2 - TDD - port 15 of PVA to make min attenuation.
def PVA_Attenuate_Min_NR_Cell_2(ip):
    telnet = telnetlib.Telnet(ip, 3001)
    telnet.write(("SMA 15 0\r\n").encode())
    time.sleep(5)
    val = telnet.read_until(b"\n")
    telnet.close()
