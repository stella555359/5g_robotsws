# -*- coding: utf-8 -*-
"""
:description: Keywords for managing ports on GUDE PDU via Telnet.
:copyright: Nokia Networks
:author: Lukasz Rutkowski
:contact: lukasz.rutkowski@nokia.com
"""
import telnetlib
import time


def power_on_gude_port(ip, port, telnet_port=23):
    pdu = telnetlib.Telnet(ip, telnet_port)
    time.sleep(1)
    pdu.read_very_eager()
    time.sleep(2)
    pdu.write('port {} state set 1\r\n'.format(port))
    time.sleep(1)
    pdu.write('port all state 1 show\r\n')
    time.sleep(1)
    values = pdu.read_very_eager().rstrip()
    pdu.close()

    return True if "P{}=ON".format(port) in values else False


def power_off_gude_port(ip, port, telnet_port=23):
    pdu = telnetlib.Telnet(ip, telnet_port)
    time.sleep(1)
    pdu.read_very_eager()
    time.sleep(2)
    pdu.write('port {} state set 0\r\n'.format(port))
    time.sleep(1)
    pdu.write('port all state 1 show\r\n')
    time.sleep(1)
    values = pdu.read_very_eager().rstrip()
    pdu.close()

    return True if "P{}=OFF".format(port) in values else False


def reboot_gude_port(ip, port, telnet_port=23):
    pdu = telnetlib.Telnet(ip, telnet_port)
    time.sleep(1)
    pdu.read_very_eager()
    time.sleep(2)
    pdu.write('port {} state set 0\r\n'.format(port))
    time.sleep(10)
    pdu.write('port {} state set 1\r\n'.format(port))
    time.sleep(1)
    pdu.write('port all state 1 show\r\n')
    time.sleep(1)
    values = pdu.read_very_eager().rstrip()
    pdu.close()

    return True if "P{}=ON".format(port) in values else False
