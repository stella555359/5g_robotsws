"""
CommissioningFileModifier.py v1.0
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""


import re
import os
import subprocess
from traceback import format_exception
from threading import Thread
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, EnvironmentIssue, InvalidUserInput)


class WiresharkUsage(object):
    """
    This class is used to collect wireshark logs and stop the log collection. Logs are collected by using TShark that
    is a powerful command-line utility for Linux for capturing and analyzing network traffic.

    User gives the name of the network device or IP to parameter ${WS_DEVICE_OR_IP} in test suite (or via TAG) that
     is then parsed from the listed network devices. This variable is mandatory and wireshark logs will not be collected
     if this parameter is not given.

    User can also give protocol with variable ${WS_PROTOCOL} that is filtered from the logs, default protocol is tcp,
     can be for example udp. This variable is optional.

    User can also give specific filter with variable ${WS_FILTER} that is filtered from the logs, default filter is
     empty. Can be for example 'host 54.204.39.132 and port 443'. This variable is optional.

    With for example TAGS:
        WS_DEVICE_OR_IP=eth1
        WS_FILTER=host 54.204.39.132 and port 443
    User can get all the network traffic from the device eth1 that is filtered by host and port.

    NOTE that this class is not called in common_resources.robot, it is called in CollectLogs.py.
    """
    name_of_network_device = None
    capture_protocol = "tcp"
    ws_filter = ""

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")

    def command_to_terminal(self, command, print_output=True):
        """
        Give command to terminal of control PC.

        :param str command: Command to give to terminal.
        :param bool print_output: If True, output of command is printed to console.
        """
        info(f"Give command: {command}")
        subp = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            outs, errs = subp.communicate(timeout=3600)
            self.logger.debug("Command output: outs={},  errs={}".format(outs, errs))
            out = subp.wait()
            self.logger.debug(f"After wait: {out}")
            if print_output:
                info(f"Output of command:\n{outs.decode('utf-8')}")
            else:
                print(f"Output of command:\n{outs.decode('utf-8')}")
            return outs.decode("utf-8")
        except subprocess.TimeoutExpired as e:
            print(f"TimeoutExpired when giving command: {command}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        finally:
            self.logger.debug("Kill the subprocess in finally, just in case")
            subp.kill()

    def check_tshark_version(self):
        """Check tshark version checks that TShark is installed to the control PC and prints it to eventlog."""
        version = self.command_to_terminal("tshark -v", print_output=False)
        if "TShark" in version:
            info(f"TShark is installed to the control PC.")
        else:
            error(f"TShark is not installed to the control PC. Take contact to UTE maintenance.")
            raise EnvironmentIssue("TShark is not installed to the control PC.")

    def find_network_devices(self):
        """
        Find network devices that are available in the control PC.

        :return: List of network devices.
        :rtype: list
        """
        devices = self.command_to_terminal("tshark -D", print_output=False)
        if not devices:
            error(f"No network devices found for TShark.")
            raise EnvironmentIssue
        devices = devices.split("\n")
        devices = [device.split(". ")[1].strip() for device in devices if device]
        info(f"Network devices: {devices}")
        return devices

    def check_user_input(self):
        """
        Check if user has given IP address or name of some existing network device.
        """
        user_input = BuiltIn().get_variable_value("${WS_DEVICE_OR_IP}")
        info("User has given input: {}".format(user_input))
        if "${WS_PROTOCOL}" in BuiltIn().get_variables():
            WiresharkUsage.capture_protocol = BuiltIn().get_variable_value("${WS_PROTOCOL}")
            info(f"User has given protocol: {WiresharkUsage.capture_protocol}")
        if "${WS_FILTER}" in BuiltIn().get_variables():
            WiresharkUsage.ws_filter = BuiltIn().get_variable_value("${WS_FILTER}")
            info(f"User has given filter: {WiresharkUsage.ws_filter}")
        network_devices = self.find_network_devices()
        if re.match(r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", user_input) or user_input.count(":") == 7:
            info(f"User has given IP address: {user_input}")
            self.get_name_of_network_device_from_ip(user_input, network_devices)
        else:
            info(f"User has given network device: {user_input}")
            self.check_network_device(user_input, network_devices)

    def check_network_device(self, user_input, network_devices):
        """
        Check if user has given correct network device.

        :param str user_input: Network device that user has given.
        :param list network_devices: List of network devices.
        """
        if not network_devices:
            error(f"No network devices given to check_network_device method.")
            raise ScriptIssue
        for network_device in network_devices:
            if user_input == network_device:
                self.logger.debug(f"User given network device is found from the control PC: {user_input}")
                WiresharkUsage.name_of_network_device = user_input
                break
        if WiresharkUsage.name_of_network_device is None:
            error(f"User given network device is not found from the control PC: {user_input}")
            self.command_to_terminal(f'ip addr show', print_output=False)
            raise InvalidUserInput

    def get_name_of_network_device_from_ip(self, ip, network_devices):
        """
        Get the name of network device from IP address.

        :param str ip: IP address that user has given.
        :param list network_devices: List of network devices.
        """
        if not ip:
            error(f"No ip given to get_name_of_network_device_from_ip method.")
            raise ScriptIssue
        if not network_devices:
            error(f"No network devices given to get_name_of_network_device_from_ip method.")
            raise ScriptIssue
        for network_device in network_devices:
            if ip in self.get_ip_address_of_network_device(network_device):
                self.logger.debug(f"Network device is found from the control PC: {network_device}")
                WiresharkUsage.name_of_network_device = network_device
                break
        if WiresharkUsage.name_of_network_device is None:
            error(f"Network device is not found from the control PC for IP: {ip}.")
            self.command_to_terminal(f'ip addr show', print_output=False)
            raise InvalidUserInput

    def get_ip_address_of_network_device(self, network_device):
        """
        Get the IP address of network device.
        """
        return self.command_to_terminal(f"ip addr show {network_device}", print_output=False)

    def start_wireshark_thread(self):
        """Start wireshark thread."""
        self.check_tshark_version()
        self.check_user_input()
        info("Starting WireShark log collection...")
        self.logger.debug(f"Started ws_thread")
        ws_thread = Thread(target=self.start_ws_log, name="ws_thread", daemon=True)
        ws_thread.daemon = True
        ws_thread.start()

    def start_ws_log(self):
        """
        Start the Wireshark log collection.
        """
        if WiresharkUsage.name_of_network_device is None:
            error(f"No network device given to start_ws_log method.")
            raise ScriptIssue("No network device given")
        ws_log_path = os.path.join(self.logger.log_dir, "wireshark_log.pcap")
        command = (f"tshark -w {ws_log_path} -t ad -i {WiresharkUsage.name_of_network_device} "
                   f"{WiresharkUsage.capture_protocol} {WiresharkUsage.ws_filter}&")
        print(f"Command used to Wireshark logs: {ws_log_path}")
        self.command_to_terminal(command)

    def stop_wireshark_thread(self):
        """
        Stops wireshark thread
        """
        info("Stop WireShark log collection")
        self.logger.debug("Stopping TShark")
        self.command_to_terminal("pgrep tshark")
        self.command_to_terminal("pkill -f tshark")
        self.command_to_terminal("pgrep tshark")
