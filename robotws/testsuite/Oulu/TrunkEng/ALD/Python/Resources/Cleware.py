from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDExceptions import SwitchSettingFailure, SwitchGettingFailure, \
                            KeyErrorInEnvironmentsDict, ClewareDeviceNotFoundException
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.TCPClient import TCPClient
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDEnvironments import ENVIRONMENT_DICT


class Cleware:

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.tcp = TCPClient()
        self.PORT = 40039
        self.env = ENVIRONMENT_DICT

    def get_serial_numbers(self, ip="", env=None):
        """
        Gets the serial numbers of devices and returns them as a list

        :param string ip: ip address (get_cleware_ip() if not given)
        :param env: e.g. "2_11_CLOUDx
        :returns list: list of Cleware serial numbers
        :raises NoClewareIpInInitFileException: In case Cleware IP is not in __init__.py and not given
        """
        if not ip:
            try:
                ip = self.get_cleware_ip()
                info("cleware ip: {}".format(ip))
            except TypeError:
                ip = self.env[env]["cleware"]["ip"]
                info("Found Cleware ip is: {}".format(ip))

        serial_numbers = self.tcp.send_and_receive_tcp(ip, self.PORT, "GET_SERIALNOS", first_receive=True)
        serial_numbers = serial_numbers.strip("\r\n")
        info("Serial numbers are: {}".format(serial_numbers))
        return serial_numbers.split(";")

    def set_switch(self, status, serial_number=None, pin_id=None, ip="", env=None, alarm=None, antennaline=None):
        """
        Set Switch ON or OFF
        NOTE: Give either the cleware serial_number and pin_id OR env, alarm and antennaline since this function
        requires either one to work

        :param string status: OFF or ON
        :param (Optional) serial_number: Cleware serial, if not given, get through ENVIRONMENT_DICT
        :param (Optional) pin_id: Cleware pin, from 0 to 7, if not given, get through ENVIRONMENT_DICT
        :param (Optional) ip: Cleware ip address, if not given, get through tl-parameter
        :param (Optional) env: e.g. 2_11_CLOUDx, used for ENVIRONMENT_DICT
        :param (Optional) alarm: Fault id e.g. 10, used for ENVIRONMENT_DICT
        :param (Optional) antennaline: e.g. RMOD-x/ANTL-x used for ENVIRONMENT_DICT
        :raises NoClewareIpInInitFileException: In case Cleware IP is not in __init__.py and not given
        :raises KeyErrorInEnvironmentsDict: If key was not found in ENVIRONMENT_DICT
        :raises SwitchSettingFailure: If setting the switch was unsuccessful
        """
        if not ip:
            try:
                ip = self.get_cleware_ip()
            except TypeError:
                ip = self.env[env]["cleware"]["ip"]

        if not serial_number and not pin_id:
            try:
                serial_number = list(self.env[env]["cleware"]["alarms"][alarm][antennaline].keys())[0]
                pin_id = list(self.env[env]["cleware"]["alarms"][alarm][antennaline].values())[0]
            except KeyError as e:
                error(f"KeyError in ENVIRONMENT_DICT, ENV: {env}, ALARM: {alarm}, ANTENNALINE: {antennaline}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise KeyErrorInEnvironmentsDict

        cleware_devices = self.get_serial_numbers(ip=ip)
        if serial_number not in cleware_devices:
            error("Cleware {} not found in environment. Check ENV: {}, ALARM: {}, ANTENNALINE: {}".format(
                serial_number, env, alarm, antennaline))
            raise ClewareDeviceNotFoundException

        self.connect(serial_number=serial_number, ip=ip)
        return_status = self.tcp.send_and_receive_tcp(
            ip, self.PORT, "SWITCH_{} {}".format(status, pin_id), first_receive=True, print_output=True)
        if return_status == -1:
            error("Setting device {} failed, check pin id {}".format(serial_number, pin_id))
            raise SwitchSettingFailure

    def get_switch(self, serial_number=None, pin_id=None, ip="", env=None, alarm=None, antennaline=None):
        """
        Gets the status of the device's pin
        NOTE: Give either the cleware serial_number and pin_id OR env, alarm and antennaline since this function
        requires either one to work

        :param (Optional) serial_number: Cleware serial, if not given, get through ENVIRONMENT_DICT
        :param (Optional) pin_id: Cleware pin, from 0 to 7, if not given, get through ENVIRONMENT_DICT
        :param (Optional) ip: Cleware ip address, if not given, get through tl-parameter
        :param (Optional) env: e.g. 2_11_CLOUDx, used for ENVIRONMENT_DICT
        :param (Optional) alarm: Fault id e.g. 10, used for ENVIRONMENT_DICT
        :param (Optional) antennaline: e.g. RMOD-x/ANTL-x used for ENVIRONMENT_DICT
        :raises NoClewareIpInInitFileException: In case Cleware IP is not in __init__.py and not given
        :raises SwitchGettingFailure: In case given serial number or pin is incorrect
        """
        if not ip:
            try:
                ip = self.get_cleware_ip()
            except TypeError:
                ip = self.env[env]["cleware"]["ip"]

        if not serial_number and not pin_id:
            serial_number = list(self.env[env]["cleware"]["alarms"][alarm][antennaline].keys())[0]
            pin_id = list(self.env[env]["cleware"]["alarms"][alarm][antennaline].values())[0]
            info("CLEWARE SERIAL: {} PIN_ID: {}".format(serial_number, pin_id))

        pin_status = self.tcp.send_and_receive_tcp(ip, self.PORT, "READ_LINE {}".format(pin_id), first_receive=True)
        pin_status = int(pin_status)
        if pin_status == -1:
            error("Error in getting pin, check serial number: {} or pin: {}".format(serial_number, pin_id))
            raise SwitchGettingFailure
        return pin_status

    def connect(self, serial_number=None, env=None, alarm=None, antennaline=None, ip=""):
        """
        Connects to specific cleware device

        :param (Optional) serial_number: Cleware serial, if not given, get through ENVIRONMENT_DICT
        :param (Optional) ip: Cleware ip address, if not given, get through tl-parameter
        :param (Optional) env: e.g. 2_11_CLOUDx, used for ENVIRONMENT_DICT
        :param (Optional) alarm: Fault id e.g. 10, used for ENVIRONMENT_DICT
        :param (Optional) antennaline: e.g. RMOD-x/ANTL-x used for ENVIRONMENT_DICT
        :return:
        """
        if not ip:
            try:
                ip = self.get_cleware_ip()
            except TypeError:
                ip = self.env[env]["cleware"]["ip"]

        if not serial_number:
            try:
                serial_number = list(self.env[env]["cleware"]["alarms"][alarm][antennaline].keys())[0]
            except KeyError as e:
                error(f"KeyError in ENVIRONMENT_DICT, ENV: {env}, ALARM: {alarm}, ANTENNALINE: {antennaline}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise KeyErrorInEnvironmentsDict

        self.tcp.send_and_receive_tcp(ip, self.PORT, "CONNECT {}".format(serial_number), print_output=True)

    def get_cleware_ip(self):
        """
        Gets the ip address of the cleware device

        :returns: Ip address
        """

        cleware = self.bts.tl.hardware_controllers
        cleware_ip = cleware[0].default_ssh_connection_details.addr
        return cleware_ip
