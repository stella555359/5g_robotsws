import os
import time
import threading
from traceback import format_exception
from taf.hw.rmod_serial_interface import rmod_serial_interface
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning

separate_radios = ["AHLOA", "AHLOB", "AEHC"]


class SerialConsole:

    def __init__(self,
                 ru_pc_address,
                 ru_pc_username,
                 ru_pc_password,
                 ru_type,
                 serial_port,
                 remote_dir,
                 python_path,
                 serial_number):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ru_pc_address = ru_pc_address
        self.ru_pc_username = ru_pc_username
        self.ru_pc_password = ru_pc_password

        self.ru_type = ru_type
        self.serial_port = serial_port
        serial_port_char_name = self.serial_port.replace("/", "")

        self.remote_dir = remote_dir
        self.python_path = python_path

        self._ru_pc_connection_alias = f"ru_pc_{self.ru_pc_address}_con_for_{serial_port_char_name}"
        self._rmod_connection_alias = f"{self.ru_pc_address}_{serial_port_char_name}_port"

        self._login_possible = True
        self.log_save_dir = ""
        self.serial_number = serial_number

        self.log_prefix = f"ru_serial_{self.serial_number}_{self.ru_pc_address}_{serial_port_char_name}"
        self.log_count = 0

        self._rmod_serial = rmod_serial_interface()
        self._rmod_serial.setup_host(self.ru_pc_address,
                                     self.ru_pc_username,
                                     self.ru_pc_password,
                                     remote_dir=self.remote_dir,
                                     python_path=self.python_path,
                                     upload=True,
                                     alias=self._ru_pc_connection_alias)

    def connect(self):
        try:
            self._rmod_serial.setup_rmod_connection(rmod_type=self.ru_type,
                                                    port=self.serial_port,
                                                    host_connection=self._ru_pc_connection_alias,
                                                    alias=self._rmod_connection_alias)
            info(f"Connected serial {self.serial_port} on {self.ru_pc_address}")
        except Exception as err:
            info(f"{''.join(format_exception(type(err), err, err.__traceback__))}")
            warning(f"Unable to create serial connection to:\nrmod_type={self.ru_type}, port={self.serial_port},"
                    f"host_connection={self._ru_pc_connection_alias}, alias={self._rmod_connection_alias}")

    def disconnect(self):
        try:
            self._rmod_serial.teardown(alias=self._rmod_connection_alias)
            info(f"Disconnected serial {self.serial_port} on {self.ru_pc_address}")
        except Exception as err:
            err_msg = str(err).replace("\r", "").replace("\n", "").strip()
            info(f"Disconnect serial, error: {err_msg}")

    def shutdown_host_connection(self):
        try:
            self._rmod_serial.shutdown(host_connection=self._ru_pc_connection_alias)
            info(f"Shutdown host {self.ru_pc_address} connection")
        except Exception as err:
            err_msg = str(err).replace("\r", "").replace("\n", "").strip()
            info(f"Shutdown host connection, error: {err_msg}")

    def _enable_lmi_eth(self):
        info("Trying to set lmi-eth on")
        command = "/usr/bin/lmi-eth on" if self.ru_type == "AHLOA" else "sudo lmi-eth on"
        result = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
        info(f"Lmi-eth enabled. Output: {result}")

    def _print_lmi_eth_status(self):
        try:
            command = ("/usr/bin/lmi-eth" if self.ru_type == "AHLOA" else "sudo lmi-eth on")
            result = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
            info(f"Lmi-eth status: {result}")
        except Exception as err:
            info(f"{''.join(format_exception(type(err), err, err.__traceback__))}")
            warning(f"Unable to print_lmi_eth_status")

    def _wait_login_not_possible(self):
        while self._login_possible:
            try:
                rmod_info_dict = self._rmod_serial.get_rmod_info(self._rmod_connection_alias)
                # info(f"RMOD status: {rmod_info_dict}")
                if not rmod_info_dict["login_possible"]:
                    self._login_possible = False
                    break
                time.sleep(3)
            except Exception as err:
                info(f"{''.join(format_exception(type(err), err, err.__traceback__))}")
            info("Login is not possible")

    def _wait_login_possible(self):
        while not self._login_possible:
            try:
                rmod_info_dict = self._rmod_serial.get_rmod_info(self._rmod_connection_alias)
                # info(f"RMOD status: {rmod_info_dict}")
                if rmod_info_dict["login_possible"]:
                    self._login_possible = True
                    break
                time.sleep(3)
            except Exception as err:
                info(f"{''.join(format_exception(type(err), err, err.__traceback__))}")
        wait_time = 10 if self.ru_type == "AHLOA" else 5
        info(f"Login is possible. Wait extra {wait_time}s")
        time.sleep(wait_time)

    def _monitor_for_enable_lmi_eth_on_ru_reboot(self):
        info("Started the monitor for enable lmi eth when ru reboot")
        self._wait_login_not_possible()
        self._wait_login_possible()
        # self.download_serial_log()
        self._enable_lmi_eth()
        self._print_lmi_eth_status()
        self.config_aasyslong_parameters()
        info("Stopped monitoring for enabling LMI ETH on RU reboot")

    def config_aasyslong_parameters(self):
        attempts = 0
        while not self.configure_aasyslog_flags() and attempts < 20:
            info(f"Aasyslog configured failed for {self.serial_port}")
            time.sleep(2)
            attempts += 1
        if self.ru_type not in separate_radios and not self.is_aasyslog_configured():
            info(f"Aasyslog configured failed for {self.serial_port}")

    def is_aasyslog_configured(self):
        try:
            output = self._rmod_serial.execute_command("cat /mnt/runtime/swconfig.txt",
                                                       alias=self._rmod_connection_alias)
            info("Check aasyslog flags: " + output.replace("\r", " ").replace("\n", " "))
            if "No such file" in output:
                return False
            if "0x10041" in output and "0x10042" in output and "0x10043" in output:
                return True
            return False
        except Exception as err:
            info(f"{''.join(format_exception(type(err), err, err.__traceback__))}")
            warning(f"Unable to check is aasyslog configured")
            return False

    def configure_aasyslog_flags(self):
        """
        rad -mpw 0x10041  0x2            # AaSysLogOutputMode
                                          \u2013 Syslog output mode
                                          - 0 = none 1 = all 2 = udp 3 = sic 4 = standard output
                                          - 5 = local 6 = remote 7 = not valid
        rad -mpw 0x10042 0xC0A864C8      #Here the IP is: 192.168.100.200, the ip of VLAN257
        rad -mpw 0x10043 0xC739          #Here the port is: 51001
        """
        try:
            result = True
            if self.ru_type in separate_radios:
                command = "/usr/bin/ccsShell.sh rad -mpw 0x10041 0x2"
            else:
                command = "rad -mpw 0x10041 0x4"
            output = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
            info(command + " output: " + output.replace("\r", "").replace("\n", ""))
            if "Connection refused" in output:
                result = False
            if self.ru_type in separate_radios:
                command = "/usr/bin/ccsShell.sh rad -mpw 0x10042 0xC0A864C8"
            else:
                command = "rad -mpw 0x10042 0xC0A864C8"
            output = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
            info(command + " output: " + output.replace("\r", "").replace("\n", ""))
            if "Connection refused" in output:
                result = False
            if self.ru_type in separate_radios:
                command = "/usr/bin/ccsShell.sh rad -mpw 0x10043 0xC739"
            else:
                command = "rad -mpw 0x10043 0xC739"
            output = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
            info(command + " output: " + output.replace("\r", "").replace("\n", ""))
            if "Connection refused" in output:
                result = False
            info("Add RU flags finished")
            return result
        except Exception as err:
            info(f"{''.join(format_exception(type(err), err, err.__traceback__))}")
            warning(f"Unable to configure aasyslog flags")
            return False

    def download_serial_log(self, local_log_path=None):
        self.log_save_dir = os.path.join(self.logger.log_dir, "serial_logs")
        if not local_log_path:
            local_log_path = os.path.join(self.log_save_dir, "{}_{}.log".format(self.log_prefix, self.log_count))
            self.log_count += 1
        info(f"Save serial log to '{local_log_path}'")
        try:
            self._rmod_serial.download_log(local_log_path, alias=self._rmod_connection_alias)
        except Exception as err:
            err_msg = str(err).replace("\r", "").replace("\n", "").strip()
            info(f"Failed to download serial {self.serial_port} log, error: {err_msg}")

    def merge_serial_logs(self):
        total_serial_log_file_name = f"{self.log_prefix}.log"
        os.popen(f"cd {self.log_save_dir}; cat {self.log_prefix}_*.log >> {total_serial_log_file_name}")
        os.popen(f"cd {self.log_save_dir}; rm {self.log_prefix}_*.log")
        info(f"Merge to one serial log file {total_serial_log_file_name}")

    def start_monitor_for_enable_lmi_eth_on_ru_reboot(self):
        self._login_possible = True
        monitor_thread = threading.Thread(target=self._monitor_for_enable_lmi_eth_on_ru_reboot)
        monitor_thread.start()

    def send_command(self, command, wait_result=True):
        try:
            result = ""
            if wait_result:
                result = self._rmod_serial.execute_command(command, alias=self._rmod_connection_alias)
                info(f"Sent command: {command}. Output: {result}")
            else:
                self._rmod_serial.send_command(command, alias=self._rmod_connection_alias)
                info(f"Sent command: {command}.")
            return result
        except Exception as err:
            info(f"{''.join(format_exception(type(err), err, err.__traceback__))}")
            warning(f"Unable to send command '{command}' to serial {self.serial_port} alias "
                    f"{self._rmod_connection_alias}")
            return ""

    def __del__(self):
        try:
            self.disconnect()
        except Exception:
            info(f"Disconnected {self._rmod_connection_alias} or is already disconnected")

        try:
            self.shutdown_host_connection()
        except Exception:
            info(f"Shutdown {self._ru_pc_connection_alias} or is already shutdown")
