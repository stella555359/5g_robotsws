# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
:maintainer: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
"""

import os
import time
import threading
from taf.hw.rmod_serial_interface import rmod_serial_interface


class RuSerialLogCollector(object):

    def __init__(self,
                 ru_pc_address,
                 ru_pc_ssh_port,
                 ru_pc_username,
                 ru_pc_password,
                 ru_type,
                 serial_port,
                 remote_dir,
                 python_path,
                 log_save_dir,
                 serial_number,
                 logger,
                 pyro_ip,
                 vlan_id,
                 btslog_stream_port):
        self.ru_pc_address = ru_pc_address
        self.ru_pc_ssh_port = ru_pc_ssh_port
        self.ru_pc_username = ru_pc_username
        self.ru_pc_password = ru_pc_password

        self.ru_type = ru_type
        self.serial_port = serial_port
        serial_port_char_name = self.serial_port.replace("/", "")

        self.remote_dir = remote_dir
        self.python_path = python_path

        self._ru_pc_connection_alias = "ru_pc_{}_con_for_{}".format(
            self.ru_pc_address, serial_port_char_name)
        self._rmod_connection_alias = "{}_{}_port".format(
            self.ru_pc_address, serial_port_char_name)

        self._stop_monitor_ru_reboot_flag = False

        self.log_save_dir = log_save_dir
        self.serial_number = serial_number

        self.logger = logger
        self.pyro_ip = pyro_ip
        """
        if vlan_id is None, use default vlan_id 0xC0A864C8 (192.168.100.200, the ip of VLAN257)
        """
        self.vlan_id = vlan_id if vlan_id else "0xC0A864C8"
        self.btslog_stream_port = btslog_stream_port if btslog_stream_port else 51001

        self.log_prefix = "ru_serial_{}_{}_{}".format(
            self.serial_number, self.ru_pc_address, serial_port_char_name)
        self.log_count = 0

        self._rmod_serial = rmod_serial_interface()
        self._rmod_serial.setup_host(self.ru_pc_address,
                                     self.ru_pc_username,
                                     self.ru_pc_password,
                                     remote_dir=self.remote_dir,
                                     python_path=self.python_path,
                                     upload=True,
                                     ssh_port=self.ru_pc_ssh_port,
                                     pyro_ip=self.pyro_ip,
                                     alias=self._ru_pc_connection_alias)

    def connect(self):
        retry_times = 2
        while retry_times:
            try:
                self._rmod_serial.setup_rmod_connection(rmod_type=self.ru_type,
                                                        port=self.serial_port,
                                                        host_connection=self._ru_pc_connection_alias,
                                                        alias=self._rmod_connection_alias)
            except Exception as err:
                retry_times -= 1
                self.logger.info("connect serial port failed, retry again")
                continue

    def disconnect(self):
        try:
            self._rmod_serial.teardown(alias=self._rmod_connection_alias)
            self.logger.info("disconnected serial {} on {}".format(self.serial_port, self.ru_pc_address))
        except Exception as err:
            err_msg = str(err)
            self.logger.info("disconnect serial, error: {}".format(err_msg))

    def shutdown_host_connection(self):
        try:
            self._rmod_serial.shutdown(host_connection=self._ru_pc_connection_alias)
            self.logger.info("shutdown host {} connection".format(self.ru_pc_address))
        except Exception as err:
            err_msg = str(err)
            self.logger.info("shutdown host connection, error: {}".format(err_msg))

    def enable_lmi_eth(self):
        result = self._rmod_serial.execute_command("sudo lmi-eth on", alias=self._rmod_connection_alias)
        self.logger.info("enable lmi eth, {}".format(result))

    def _monitor_for_enable_lmi_eth_on_ru_reboot(self):
        print("started the monitor for enable lmi eth when ru reboot")
        while not self._stop_monitor_ru_reboot_flag:
            print("waiting for ru login prompt")
            output = self._read_output_until("login:")
            if output:
                self.download_serial_log()

                self.disconnect()
                self.connect()

                self.enable_lmi_eth()
                self.config_aasyslog_parameters()
                print("enable lmi eth by monitor")

        print("stopped monitoring for enabling LMI ETH on RU reboot")

    def config_aasyslog_parameters(self):
        self.configure_aasyslog_flags()
        if not self.is_aasyslog_configured():
            self.logger.error("aasyslog configured failed for {}".format(self.serial_port))

    def is_aasyslog_configured(self):
        output = self._rmod_serial.execute_command("cat /mnt/runtime/swconfig.txt", alias=self._rmod_connection_alias)
        self.logger.info("check aasyslog flags: " + output)
        if "No such file" in output:
            return False

        if "0x10041" in output and "0x10042" in output and "0x10043" in output:
            return True

        return False

    def configure_aasyslog_flags(self):
        """
        rad -mpw 0x10041  0x2            # AaSysLogOutputMode
                                           Syslog output mode
                                          - 0 = none 1 = all 2 = udp 3 = sic 4 = standard output
                                          - 5 = local 6 = remote 7 = not valid
        rad -mpw 0x10042 0xC0A864C8      #Here the IP is: 192.168.100.200, the ip of VLAN257
        rad -mpw 0x10043 0xC739          #Here the port is: 51001
        """
        command = "rad -mpw 0x10041  0x2"
        output = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
        self.logger.info(command + " output: " + output)

        command = "rad -mpw 0x10042 {}".format(self.vlan_id)
        output = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
        self.logger.info(command + " output: " + output)

        command = "rad -mpw 0x10043 0x{:x}".format(self.btslog_stream_port)
        output = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
        self.logger.info(command + " output: " + output)
        self.logger.info("add RU flags finished")

    def _read_output_until(self, pattern):
        output = ""
        while not self._stop_monitor_ru_reboot_flag:
            print_log = self._rmod_serial.collect_rmod_output(alias=self._rmod_connection_alias)
            output += print_log
            if pattern.lower() in output.lower():
                return output
            time.sleep(1)
        return ""

    def download_serial_log(self, local_log_path=None):
        if not local_log_path:
            local_log_path = os.path.join(self.log_save_dir, "{}_{}.log".format(self.log_prefix, self.log_count))
            self.log_count += 1
        self.logger.info("save serial log to '{}'".format(local_log_path))
        try:
            self._rmod_serial.download_log(local_log_path, alias=self._rmod_connection_alias)
        except Exception as err:
            err_msg = str(err)
            self.logger.error("failed to download serial {} log, error: {}".format(self.serial_port, err_msg))

    def merge_serial_logs(self):
        total_serial_log_file_name = "{}.log".format(self.log_prefix)
        os.popen("cd {}; cat {}_*.log >> {}".format(self.log_save_dir, self.log_prefix, total_serial_log_file_name))
        os.popen("cd {}; rm {}_*.log".format(self.log_save_dir, self.log_prefix))
        self.logger.info("merge to one serial log file {}".format(total_serial_log_file_name))

    def start_monitor_for_enable_lmi_eth_on_ru_reboot(self):
        self._stop_monitor_ru_reboot_flag = False
        monitor_thread = threading.Thread(target=self._monitor_for_enable_lmi_eth_on_ru_reboot)
        monitor_thread.start()

    def stop_monitor_for_enable_lmi_eth_on_ru_reboot(self):
        self._stop_monitor_ru_reboot_flag = True

    def __del__(self):
        try:
            self.disconnect()
        except Exception:
            self.logger.info("disconnected {} or is already disconnected".format(self._rmod_connection_alias))

        try:
            self.shutdown_host_connection()
        except Exception:
            self.logger.info("shutdown {} or is already shutdown".format(self._ru_pc_connection_alias))


def create_ru_serial_log_collector(ru_pc_address="",
                                   ru_pc_ssh_port=22,
                                   ru_pc_username=None,
                                   ru_pc_password=None,
                                   ru_type="AVQC",
                                   serial_port="COM32",
                                   remote_dir='C:/rsi',
                                   python_path="C:/Python39/python",
                                   log_save_dir="./",
                                   serial_number="",
                                   logger=None,
                                   pyro_ip=None,
                                   vlan_id="",
                                   btslog_stream_port=51001):
    """
    Creates a RU serial log collector object.

    The RU serial log collector object can be used for operating RU,
    such as enabling LMI ETH, downloading serial logs, etc.

    :param ru_pc_address: The IP address of the RU PC.
    :param ru_pc_ssh_port: The SSH port of the RU PC.
    :param ru_pc_username: The username of the RU PC.
    :param ru_pc_password: The password of the RU PC.
    :param ru_type: The type of the RU.
    :param serial_port: The serial port of the RU.
    :param remote_dir: The remote directory of the RU PC for proxy.
    :param python_path: The python path of the RU PC.
    :param log_save_dir: The directory for saving the serial log.
    :param serial_number: The serial number of the RU.
    :param logger: The logger for the RU serial log collector.
    :param pyro_ip: The IP address of the Pyro server.
    :param vlan_id: The VLAN ID for the RU btslog.
    :param btslog_stream_port: The BTS log stream port for the RU.
    :return: The object of the RU serial log collector.
    """
    ru_serial_log_collector = RuSerialLogCollector(ru_pc_address=ru_pc_address,
                                                   ru_pc_ssh_port=ru_pc_ssh_port,
                                                   ru_pc_username=ru_pc_username,
                                                   ru_pc_password=ru_pc_password,
                                                   ru_type=ru_type,
                                                   serial_port=serial_port,
                                                   remote_dir=remote_dir,
                                                   python_path=python_path,
                                                   log_save_dir=log_save_dir,
                                                   serial_number=serial_number,
                                                   logger=logger,
                                                   pyro_ip=pyro_ip,
                                                   vlan_id=vlan_id,
                                                   btslog_stream_port=btslog_stream_port)

    ru_serial_log_collector.connect()
    return ru_serial_log_collector
