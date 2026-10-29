"""
author/contact:        adam.proszek@nokia.com
Description:           class to gather log collction from eGen installed on airframe
eGEn documentation:    https://egen.gitlabe1-pages.ext.net.nokia.com/eGen/master/user-guide.html#cheatsheet
"""

from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, download_file
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env


class EgenLogsCollector(object):

    def __init__(self, ssh_connection_details):
        self.ssh_connection_details = ssh_connection_details
        self.log_path = "/tmp/egenlogs"

    def capture_logs(self, cores, pci_addr1, pci_addr2, number_of_packets=1000000):
        """
            Function gathers specified number of packets from ecpri interface on eGen
            To collect complete logs, it is required to use two sfp ports, one for radio module, one for bbmod.
            :param cores: subset of cpu cores
            :param pci_addr1: pci address of sfp network card port
            :param pci_addr2: pci address of sfp network card port
            :param number_of_packets: specified number of packets

        """
        capture_logs_command = f"sudo ./egen --cores {cores} --port {pci_addr1} --port {pci_addr2} --constant-timing " \
            f"--capture {self.log_path} --save-n-and-quit {number_of_packets}"
        execute_ssh_command(self.ssh_connection_details, capture_logs_command)
        Logger.info(f"The log collection has been initiated. Once captured, they will be located at: {self.log_path}")

    def download_egen_logs(self):
        _egen_log_dir = str(Env.test_log_dir) + "_egen"
        VmOs.make_empty_dir(_egen_log_dir)
        download_file(self.ssh_connection_details, self.log_path, _egen_log_dir)
