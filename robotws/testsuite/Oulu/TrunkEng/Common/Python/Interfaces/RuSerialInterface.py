# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pekka Lonnakko
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Copied from testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ru_serial_log_collector.py and modified for serving
I_MN_RAN_RD_TV_OTACI_CITCRT1 needs

On lmi-pc:
- Python installed and environment path variable configured
- pyserial, Pyro4 and serpent python libraries
- Open SSH Server running on Services (Installation: Optional Features -> OpenSSH Server)
  -> Search services.msc -> OpenSSH SSH Server -> Start and set to Automatic
- BTSlog running if needed (not needed for just enabling LMI ETH and downloading serial logs)

Example usage:
Library          testsuite.Oulu.TrunkEng.Common.Python.Interfaces.RuSerialInterface  WITH NAME  Serial

or if multiple RUs are needed:
Library          testsuite.Oulu.TrunkEng.Common.Python.Interfaces.RuSerialInterface  100.68.219.115
...              FIOU4GUSR
...              !4Glinnanmaa4
...              AEHC
...              COM3
...              C:/rsi
...              C:/Users/FIOU4GUSR/AppData/Local/Programs/Python/Python314/python.exe
...              AH231800650  WITH NAME  Serial1
Library          testsuite.Oulu.TrunkEng.Common.Python.Interfaces.RuSerialInterface  100.68.219.115
...              FIOU4GUSR
...              !4Glinnanmaa4
...              AEHC
...              COM5
...              C:/rsi
...              C:/Users/FIOU4GUSR/AppData/Local/Programs/Python/Python314/python.exe
...              AH234800083  WITH NAME  Serial2

Initialize Ru Serial Interface (init infos can be set here but it is easier to just modify this file):
Run Keyword And Continue On Failure   Serial.Connect Ru

Start Monitor For Enable Lmi Eth On Ru Reboot (This should be started when login is still possible to RU):
Run Keyword And Continue On Failure   Serial.Start Monitor For Enable Lmi Eth On Ru Reboot

Send Command (example command to reboot RU):
Run Keyword And Continue On Failure   Serial.Send Command   reboot

Download Serial Log:
Run Keyword And Continue On Failure   Serial.Download Serial Log  merge_files=${True}
"""

from testsuite.Oulu.TrunkEng.Common.Python.Resources.SerialConsole import SerialConsole


class RuSerialInterface:

    def __init__(self,
                 ru_pc_address="100.68.219.83",
                 ru_pc_username=r"FIOU4GUSR",
                 ru_pc_password="!4Glinnanmaa4",
                 ru_type="AEQE",
                 serial_port="COM15",
                 remote_dir=r'C:/rsi',
                 python_path=r"C:/Users/fiou4gusr/AppData/Local/Programs/Python/Python39/python.exe",
                 serial_number="1M222002710"):
        """
        Creates a RU serial log collector object.

        The RU serial log collector object can be used for operating RU,
        such as enabling LMI ETH, downloading serial logs, etc.

        :param ru_pc_address: The IP address of the RU PC.
        :param ru_pc_username: The username of the RU PC.
        :param ru_pc_password: The password of the RU PC.
        :param ru_type: The type of the RU.
        :param serial_port: The serial port of the RU.
        :param remote_dir: The remote directory of the RU PC for proxy.
        :param python_path: The python path of the RU PC.
        :param serial_number: The serial number of the RU.
        :return: The object of the RU serial log collector.
        """
        self.ru_serial_log_collector = SerialConsole(ru_pc_address=ru_pc_address,
                                                     ru_pc_username=ru_pc_username,
                                                     ru_pc_password=ru_pc_password,
                                                     ru_type=ru_type,
                                                     serial_port=serial_port,
                                                     remote_dir=remote_dir,
                                                     python_path=python_path,
                                                     serial_number=serial_number)

    def connect_ru(self):
        """
        Connect to RU.
        """
        self.ru_serial_log_collector.connect()

    def disconnect_ru(self):
        """
        Disconnect from RU.
        """
        self.ru_serial_log_collector.disconnect()

    def start_monitor_for_enable_lmi_eth_on_ru_reboot(self):
        """
        Start monitoring for enabling LMI ETH on RU reboot. This should be started before any reset so that RU
        still has login possibility.
        """
        self.ru_serial_log_collector.start_monitor_for_enable_lmi_eth_on_ru_reboot()

    def download_serial_log(self, merge_files=False):
        """
        Download serial log.
        """
        self.ru_serial_log_collector.download_serial_log()
        if merge_files:
            self.ru_serial_log_collector.merge_serial_logs()

    def send_command(self, command, wait_for_result=True):
        """
        Send command to RU serial port.

        :param command: The command to be sent.
        :param wait_for_result: Whether to wait for the command result.
        """
        self.ru_serial_log_collector.send_command(command, wait_result=wait_for_result)

    def configure_aasyslog_flags(self):
        """
        Configure AASYSLOG flags on RU.
        """
        return self.ru_serial_log_collector.config_aasyslong_parameters()
