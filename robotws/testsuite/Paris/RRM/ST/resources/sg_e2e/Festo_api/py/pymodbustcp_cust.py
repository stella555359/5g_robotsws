##!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
Python Class library to handel festo automate control operation using ModBus TCP client.
Library info:
            Reusable Universal API Library Using basic level communication ModBus standard protocol via TCP/IP.

Library capabilities:
            - usage of ini config file (automaton device metrics and limitations).
            - load config file to instantiate python class objects.
            - Move axis or rotation position, with facultative option inverted axis in order to facilitate
                execution robot test code  treatment.
            - Homing (made a referencing of the automaton device if not already set before to run TC).
            - Collect Device Errors
            - Clear device errors.
"""

from sys import platform

if platform == "win32":
    import win_inet_pton
import configparser
import struct
from pyModbusTCP.client import ModbusClient
from pyModbusTCP import constants as const


class pyModbusTCP_cust(ModbusClient):
    """
        Extension of the code to read device EXCEPTION STATUS
    """
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, host=None, port=None, unit_id=None, timeout=None,
                 debug=None, auto_open=None, auto_close=None):
        # Initialisation de l'objet
        ModbusClient.__init__(self, host=host, port=port, unit_id=unit_id, timeout=timeout,
                              debug=debug, auto_open=auto_open, auto_close=auto_close)
        self.__debug = self.debug()

    def read_exception_status(self):
        """Modbus function READ_EXCEPTION_STATUS (0x07)
        :returns: bits list or None if error
        :rtype: list of bool or None
        """
        # build frame
        tx_buffer = self._mbus_frame(
            0x07, struct.pack('>HH', 0x0, 0x1))
        # send request
        s_send = self._send_mbus(tx_buffer)
        # check error
        if not s_send:
            return None
        # receive
        f_body = self._recv_mbus()
        # check error
        if not f_body:
            return None
        # check min frame body size
        if len(f_body) < 1:
            self.__last_error = const.MB_RECV_ERR
            self.__debug_msg('read_exception_status(): rx frame under min size')
            self.close()
            return None
        exception_number = struct.unpack("B", f_body[0:1])[0]
        return exception_number

    def __debug_msg(self, msg):
        """Print debug message if debug mode is on
        :param msg: debug message
        :type msg: str
        """
        if self.__debug:
            print(msg)
