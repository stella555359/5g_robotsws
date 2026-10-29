#!/usr/bin/env python
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
import os
from sys import platform

if platform == "win32":
    import win_inet_pton
import yaml
import struct

from pymodbustcp_cust import pyModbusTCP_cust
from failures import failure_text
import time


class FestoClient(object):
    """
    Festo Client to deal with Fasto device using Modbus TCP
    Function:
        - reset_error(): To reset Errors on Device.
        - start_homing(): To set Homing before start.
        - move_to_position(): To Set Position.
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, debug=False):
        self.debug = debug

    def load_config(self, config_fn, debug=False):
        """

        :param config_ini_path:
        :param invert_axis:
        :param debug:
        """
        self.debug = debug
        if "INIT_CONFIG_FILE_PATH" in os.environ:
            config_path = os.path.join(os.environ['INIT_CONFIG_FILE_PATH'], config_fn)
            with open(config_path) as yaml_file:
                config = yaml.load(yaml_file, Loader=yaml.FullLoader)
                # Drive data
                self.device_id = config['device_id']
                self.SERVER_HOST = config['SERVER_HOST']
                self.SERVER_PORT = config['SERVER_PORT']
                # PC Ue
                self.festo_PC_IP = config['festo_PC_IP']
                self.festo_PC_Port = config['festo_PC_Port']
                self.festo_PC_user = config['festo_PC_user']
                self.festo_PC_pswd = config['festo_PC_pswd']
                # Technicals data
                self.max_limit = float(config['max_limit'])
                self.min_limit = float(config['min_limit'])
                self.ref_point = float(config['ref_point'])
                self.unit_factor = float(config['unit_factor'])

                self.max_velocity = float(config['max_velocity'])
                self.default_velocity = float(config['default_velocity'])
                self.default_acceleration = config['default_acceleration']

                self.err_margin = config['err_margin']
                self.measurment_unit = config['measurment_unit']
                self.velocity_unit = config['velocity_unit']
                self.accelration_unit = config['accelration_unit']
                self.invert_axis = config['invert_axis']
                self.modbus_client = pyModbusTCP_cust(host=self.festo_PC_IP,
                                                      port=self.festo_PC_Port,
                                                      unit_id=self.device_id,
                                                      auto_open=True,
                                                      auto_close=True,
                                                      debug=self.debug)

    def get_server_host(self):
        """

        """
        return self.SERVER_HOST

    def get_server_port(self):
        """

        :param port:
        """
        return self.SERVER_PORT

    def get_festo_PC_IP(self):
        """

        """
        return self.festo_PC_IP

    def get_festo_PC_Port(self):
        """

        """
        return self.festo_PC_Port

    def get_festo_PC_user(self):
        """

        """
        return self.festo_PC_user

    def get_festo_PC_pswd(self):
        """

        """
        return self.festo_PC_pswd

    def host(self, host):
        """

        :param host:
        """
        if bool(self.modbus_client):
            self.modbus_client.host(host)

    def port(self, port):
        """

        :param port:
        """
        if bool(self.modbus_client):
            self.modbus_client.port(port)

    def _decode_registers(self, data):
        """
            decode Festo modbus register response
        :param data:
        :return: list of register values
        """
        SCON, SPOS = struct.unpack('>BB', struct.pack('>H', data[0]))
        SDIR, V = struct.unpack('>BB', struct.pack('>H', data[1]))
        POS = struct.unpack('>i', struct.pack('>HH', data[2], data[3]))[0]

        # print ("Data Recieved: {} {} {} {} {}".format(hex(SCON), hex(SPOS), hex(SDIR), V, POS))
        return [SCON, SPOS, SDIR, V, POS]

    def _encode_registers(self, CCON, CPOS, CDIR, V, POS):
        """
             encode Festo modbus register
        :param CCON:
        :param CPOS:
        :param CDIR:
        :param V:
        :param POS:
        :return: status (True or False)
        """
        # print ("Data Sent: {} {} {} {} {}".format(hex(CCON), hex(CPOS), hex(CDIR), V, POS))
        Position = struct.unpack('>HH', struct.pack('>i', POS))
        return [
            struct.unpack('>H', struct.pack('>BB', CCON, CPOS))[0],
            struct.unpack('>H', struct.pack('>BB', CDIR, V))[0],
            Position[0],
            Position[1]
        ]

    def read_exception_status(self):
        num = self.modbus_client.read_exception_status()
        if 0 <= num <= 75:
            return failure_text[num]
        else:
            return "Exception number unknown"

    def reset_error(self):
        # Check FAULT flag
        sregs = self.modbus_client.read_holding_registers(0, 4)
        if sregs:
            SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
        else:
            return "Error occurred on read_holding_registers"
        if bool(SCON & 0x4):
            return "Device with warning flag on"
        if bool(SCON & 0x8):
            # Set Direct OPM
            cregs = self._encode_registers(0x41, 0x0, 0x0, 0x0, 0x0)
            if not self.modbus_client.write_multiple_registers(0, cregs):
                return "Rest Error: Error occurred on write_multiple_registers #1"
            # Erase Error
            cregs = self._encode_registers(0x49, 0x0, 0x0, 0x0, 0x0)
            if not self.modbus_client.write_multiple_registers(0, cregs):
                return "Rest Error: Error occurred on write_multiple_registers #2"
            time.sleep(0.1)
            sregs = self.modbus_client.read_holding_registers(0, 4)
            if sregs:
                SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
            else:
                return "Error occurred on read_holding_registers"
            if bool(SCON & 0x4):
                return "Device with warning flag on"
            if bool(SCON & 0x8):
                return "Error Reset Fail: device still with error "
        return ""

    def start_homing(self, Force=False, timeout=180):
        """
            run horming to prepare the device.
        :param Force:
        :param timeout:
        :return: "Err_MSG", and the position
        """
        self.__enable_ModBus()

        # check if Homing is needed
        sregs = self.modbus_client.read_holding_registers(0, 4)
        if sregs:
            SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
            if bool(SPOS & 0x989680) and not Force:
                # print ( "Homing is valide")
                return "", current_pos
        else:
            return "Error occurred on write_multiple_registers", None

        # Setting the Homing command
        cregs = self._encode_registers(0x43, 0x1, 0x0, 0x85, 0x0)
        if not self.modbus_client.write_multiple_registers(0, cregs):
            return "Error occurred on write_multiple_registers", None
        time.sleep(0.1)
        sregs = self.modbus_client.read_holding_registers(0, 4)
        if sregs:
            SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
            if bool(SCON & 0x4):
                return "Device warning massage at position: ", current_pos
            if bool(SCON & 0x8):
                return "Device Error occurred at position: ", current_pos
            if not bool(SCON & 0x53) and not bool(SPOS & 0x1):
                return "Error occurred on setting homing commande", None
        else:
            return "Error occurred on read_holding_registers", None

        # Start the homing Task
        cregs = self._encode_registers(0x43, 0x5, 0x0, self.default_velocity, 0x0)
        if not self.modbus_client.write_multiple_registers(0, cregs):
            return "Error occurred on write_multiple_registers", None
        time.sleep(0.1)
        timeout_start = time.time()
        while time.time() < timeout_start + timeout:
            sregs = self.modbus_client.read_holding_registers(0, 4)
            if sregs:
                SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
                if bool(SCON & 0x4):
                    return "Device warning massage at position: ", current_pos
                if bool(SCON & 0x8):
                    return "Device Error occurred at position: ", current_pos
                if bool(SPOS & 0x80):
                    return "", current_pos
            time.sleep(0.1)
        else:
            return "Time out", None

    def __get_sw_position(self, position):
        """
            return SW position
        :param position:
        :return: Position
        """
        if bool(position) and self.invert_axis:
            position = -float(position)
        return position

    def __enable_ModBus(self):
        # Enable disable defore start
        cregs = self._encode_registers(0x4B, 0x1, 0x0, 0, 0)
        if not self.modbus_client.write_multiple_registers(0, cregs):
            return "Error occurred on write_multiple_registers #1", None
        time.sleep(1)
        cregs = self._encode_registers(0x42, 0x1, 0x0, 0, 0)
        if not self.modbus_client.write_multiple_registers(0, cregs):
            return "Error occurred on write_multiple_registers #1", None
        time.sleep(1)
        cregs = self._encode_registers(0x43, 0x1, 0x0, 0, 0)
        if not self.modbus_client.write_multiple_registers(0, cregs):
            return "Error occurred on write_multiple_registers #1", None
        time.sleep(1)

    def _direct_move_to_Position(self, setpoint_pos, velocity, timeout):
        """
        This function use direct mode to set position
        :param setpoint_pos:
        :param velocity:
        :param timeout: timeout in second
        """

        # Setting the position and velocity
        cregs = self._encode_registers(0x43, 0x1, 0x0, velocity, setpoint_pos)
        time.sleep(0.1)
        if not self.modbus_client.write_multiple_registers(0, cregs):
            return "Error occurred on write_multiple_registers #1", None

        sregs = self.modbus_client.read_holding_registers(0, 4)
        time.sleep(0.1)
        if sregs:
            SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
            if not bool(SCON & 0x53) and SPOS not in [0x85, 0x95]:
                return "Error occurred on read_holding_registers", None

        # Start the positioning Task
        cregs = self._encode_registers(0x43, 0x3, 0x0, velocity, setpoint_pos)
        time.sleep(0.1)
        if not self.modbus_client.write_multiple_registers(0, cregs):
            return "Error occurred on write_multiple_registers #2", None
        timeout_start = time.time()
        while time.time() < timeout_start + timeout:
            # print "time", time.strftime("%H:%M:%S")
            sregs = self.modbus_client.read_holding_registers(0, 4)
            if sregs:
                SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
                if bool(SCON & 0x8):
                    return "Device Error occurred at position: ", current_pos
                elif bool(SCON & 0x4):
                    return "Device warning message at position: ", current_pos
                if not bool(SDIR & 0x10) and (bool(SPOS & 0x85) or bool(SPOS & 0x87)):
                    return "", current_pos
            time.sleep(0.1)
        else:
            return "Time out", None

    def move_to_Position(self, setpoint_pos, relative_position=False,
                         velocity=None, timeout=180, retry=5):
        """

        :param setpoint_pos:
        :param relative_position:
        :param velocity:
        :param timeout:
        :param retry:
        :return:
        """
        self.__enable_ModBus()
        current_pos = None
        err_msg = ''
        if isinstance(setpoint_pos, unicode):
            setpoint_pos = float(setpoint_pos.replace(u'\N{MINUS SIGN}', '-'))

        sregs = self.modbus_client.read_holding_registers(0, 4)

        if sregs:
            SCON, SPOS, SDIR, V, current_pos = self._decode_registers(sregs)
        else:
            err_msg = "Error occurred on read_holding_registers"
            return err_msg, None

        # check FCT flag
        if bool(SCON & 0x186a0):
            err_msg = "Error occurred please deactivate FCT flag before to continue"
            return err_msg, self.__get_sw_position(current_pos)
        # check Ref falg (Homing if it's valid)
        if not bool(SPOS & 0x989680):
            err_msg = "Error occurred homing is not valid"
            return err_msg, self.__get_sw_position(current_pos)
        if bool(SCON & 0x8):
            return "Device with error please check the device before to continue", None

        setpoint_pos = self.__get_sw_position(setpoint_pos)

        if relative_position:
            setpoint_pos += current_pos / self.unit_factor

        if not (self.min_limit <= setpoint_pos <= self.max_limit):
            return "Target position is out of range", None
        elif not abs(current_pos - setpoint_pos) > self.err_margin:
            current_pos /= self.unit_factor
            return "", self.__get_sw_position(current_pos)
        if not bool(velocity):
            velocity = self.default_velocity
        if self.max_velocity == 0.0:
            return "max_velocity is not set, please check file config", None
        elif not (0.0 < velocity <= self.max_velocity):
            return "velocity is out of range", None
        velocity = int(255 * (velocity / self.max_velocity))
        setpoint_pos = int(setpoint_pos * self.unit_factor)

        while retry:
            # print "retry %s " % retry
            err_msg, current_pos = self._direct_move_to_Position(setpoint_pos, velocity, timeout)
            if bool(err_msg):
                return err_msg, self.__get_sw_position(current_pos)
            if abs(current_pos - setpoint_pos) > self.err_margin * self.unit_factor:
                retry -= 1
                timeout = 30
                time.sleep(0.1)
            else:
                current_pos = current_pos / self.unit_factor
                return "", self.__get_sw_position(current_pos)
        else:
            err_msg = "Error occurred on setpoint position\n"
            err_msg += "\t requested {} and returned {}\n".format(setpoint_pos, current_pos)
            return err_msg, None
