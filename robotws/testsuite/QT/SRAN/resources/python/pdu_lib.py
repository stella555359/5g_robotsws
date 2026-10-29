# -*- coding: utf-8 -*-
"""
:description: Keywords for managing ports on 'GUDE' and 'ATEN' PDU via Telnet.
:copyright: Nokia Networks
:author: Lukasz Rutkowski
:contact: lukasz.rutkowski@nokia.com
"""
import telnetlib
from time import sleep
from robot.api import logger


def _setup(ip, port, telnet_port):
    pdu, pdu_type = _login_to_pdu(ip, telnet_port)
    if pdu_type == "ATEN" and len(str(port)) == 1:
        port = "0{}".format(port)
    commands = _set_commands(port)

    return pdu, pdu_type, commands


def _login_to_pdu(ip, telnet_port):
    logger.info("Opening connection to PDU ({}) via telnet...".format(ip))
    pdu = telnetlib.Telnet(ip, telnet_port)
    sleep(1)
    welcome_msg = pdu.read_very_eager().decode('ascii')
    pdu_type = "ATEN" if "Login" in welcome_msg or "login" in welcome_msg else "GUDE"
    if pdu_type == "ATEN":
        pdu.write("teladmin".encode('ascii') + b"\r\n")
        sleep(1)
        pdu.write("telpwd".encode('ascii') + b"\r\n")
        sleep(1)
        out = pdu.read_very_eager().decode('ascii')
        if "Incorrect" in out:
            logger.error("Incorrect user name or password! Check PDU config.")
        if "successfully" not in out:
            logger.error("Connection to PDU ({}) failed.".format(ip))
    logger.info("Successfully connected to PDU ({}) via telnet.".format(ip))
    sleep(1)

    return pdu, pdu_type


def _set_commands(port):
    commands_dict = {
        "ATEN": {
            "ON": "sw o{} on imme\r\n".format(port),
            "OFF": "sw o{} off imme\r\n".format(port),
            "read": "read status o{} format\r\n".format(port),
            "is_on": "Outlet {} on".format(port),
            "is_off": "Outlet {} off".format(port)
        },
        "GUDE": {
            "ON": "port {} state set 1\r\n".format(port),
            "OFF": "port {} state set 0\r\n".format(port),
            "read": "port {} state show\r\n".format(port),
            "is_on": "ON",
            "is_off": "OFF"
        }
    }

    return commands_dict


def reboot_pdu_port(ip, port, telnet_port=23):
    """
    :param ip: PDU IP address
    :param port: port/slot on PDU to reboot
    :param telnet_port: (optional) telnet port for PDU, default value: 23
    """
    logger.info("Rebooting port {} on PDU: {}".format(port, ip))
    pdu, pdu_type, commands = _setup(ip, port, telnet_port)

    pdu.write(commands[pdu_type]["OFF"].encode('ascii') + b"\r\n")
    sleep(10)
    pdu.read_very_eager().decode('ascii')
    pdu.write(commands[pdu_type]["read"].encode('ascii') + b"\r\n")
    sleep(1)
    off_check = pdu.read_very_eager().decode('ascii')
    if commands[pdu_type]["is_on"] in off_check:
        logger.error("Port {} is still ON and should be OFF now".format(port))
        return False
    pdu.write(commands[pdu_type]["ON"].encode('ascii') + b"\r\n")
    sleep(2)
    pdu.write(commands[pdu_type]["read"].encode('ascii') + b"\r\n")
    sleep(1)
    on_check = pdu.read_very_eager().decode('ascii')
    pdu.close()

    if commands[pdu_type]["is_on"] in on_check:
        logger.info("PDU port {} rebooted successfully.".format(port))
        return True
    logger.error("Port {} reboot failed, check PDU manually".format(port))
    return False


def power_on_pdu_port(ip, port, telnet_port=23):
    """
    :param ip: PDU IP address
    :param port: port/slot on PDU to turn ON
    :param telnet_port: (optional) telnet port for PDU, default value: 23
    """
    logger.info("Power ON port {} on PDU: {}".format(port, ip))
    pdu, pdu_type, commands = _setup(ip, port, telnet_port)

    pdu.write(commands[pdu_type]["ON"])
    sleep(2)
    pdu.write(commands[pdu_type]["read"])
    sleep(1)
    on_check = pdu.read_very_eager()
    pdu.close()

    if commands[pdu_type]["is_on"] in on_check:
        logger.info("PDU port {} powered ON successfully.".format(port))
        return True
    logger.error("Port {} power ON failed, check PDU manually".format(port))
    return False


def power_off_pdu_port(ip, port, telnet_port=23):
    """
    :param ip: PDU IP address
    :param port: port/slot on PDU to turn OFF
    :param telnet_port: (optional) telnet port for PDU, default value: 23
    """
    logger.info("Power OFF port {} on PDU: {}".format(port, ip))
    pdu, pdu_type, commands = _setup(ip, port, telnet_port)

    pdu.write(commands[pdu_type]["OFF"])
    sleep(2)
    pdu.write(commands[pdu_type]["read"])
    sleep(1)
    on_check = pdu.read_very_eager()
    pdu.close()

    if commands[pdu_type]["is_off"] in on_check:
        logger.info("PDU port {} powered OFF successfully.".format(port))
        return True
    logger.error("Port {} power OFF failed, check PDU manually".format(port))
    return False
