import pexpect
import re
import os
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import SSHConnectionFailure
from testsuite.Oulu.TrunkEng.PM.Resources.netact_dict import netact

LAB_PC_PASSWD = "4Gtest!!"
LAB_PC_USERNAME = "fiou4gusr"


class OAMConnection:

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.pexpect_log = None

    def check_and_restore_oam_connection(self, pc_ip, netact_ip):
        """
        Check OAM connection and try to restore it if needed.

        :param pc_ip: IP address of the PC where the OAM connection is checked
        :param netact_ip: IP address of the NetAct server
        """
        info("Check OAM connection and try to restore it if needed.")
        restore_ctr = 0
        while not self.modify_oam_connection(pc_ip, "check", netact_ip) and restore_ctr < 6:
            self.modify_oam_connection(pc_ip, "restore", netact_ip)
            BuiltIn().sleep("10s")
            restore_ctr += 1

    def check_and_drop_oam_connection(self, pc_ip, netact_ip):
        """
        Check OAM connection and try to drop it if needed.

        :param pc_ip: IP address of the PC where the OAM connection is checked
        :param netact_ip: IP address of the NetAct server
        """
        info("Check OAM connection and try to drop it if needed.")
        drop_ctr = 0
        while self.modify_oam_connection(pc_ip, "check", netact_ip) and drop_ctr < 6:
            self.modify_oam_connection(pc_ip, "drop", netact_ip)
            BuiltIn().sleep("10s")
            drop_ctr += 1

    def modify_oam_connection(self, pc_ip, action, netact_ip):
        """
        Check OAM connection and try to restore it if needed.

        :param pc_ip: IP address of the PC where the OAM connection is checked
        :param action: Action to be done. Possible values: check, restore, drop
        :param netact_ip: IP address of the NetAct server

        :return: True if OAM connection is up, False otherwise
        :raise SSHConnectionFailure: If timeout while checking OAM connection
        """
        info("Checking OAM connection.")
        pc_connection = self.make_connection_to_netact_pc(pc_ip)
        info("Ask for super user rights")
        try:
            pc_connection.sendline("sudo su")
            index = pc_connection.expect(["assword", "root", pexpect.EOF], timeout=30)
            if index == 0:
                info("Give sudo password")
                pc_connection.sendline(LAB_PC_PASSWD)
                pc_connection.expect(r".*?@.*#", 30)
                info("Check filters.")
                pc_connection.sendline("nft list table bridge filter")
                if action == "check":
                    return self.check_oam_connection(pc_connection, netact_ip)
                elif action == "restore":
                    self.restore_oam_connection(pc_connection)
                    BuiltIn().sleep("10s")
                elif action == "drop":
                    self.drop_oam_connection(pc_connection, netact_ip)
                    BuiltIn().sleep("10s")
            else:
                error("Sudo password is not asked. Can't continue to restore connection")
                raise SSHConnectionFailure("Sudo password is not asked. Can't continue to restore connection")
        except pexpect.TIMEOUT as e:
            error(f"Timeout while checking OAM connection. ({e})\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise SSHConnectionFailure(f"Timeout while checking OAM connection.")

    @staticmethod
    def check_oam_connection(pc_connection, netact_ip):
        """
        Check OAM connection.

        :param pc_connection: Connection to the PC where the OAM connection is checked
        :param netact_ip: IP address of the NetAct server

        :return: True if OAM connection is up, False otherwise
        """
        oam_connection = True
        try:
            output = pc_connection.expect([rf".*ip daddr vmap {{ {netact_ip} : drop }}.*"], 30)
            if output == 0:
                oam_connection = False
                info("Netact is dropped.")
        except pexpect.TIMEOUT:
            info("OAM connection is up.")
        return oam_connection

    @staticmethod
    def drop_oam_connection(pc_connection, netact_ip):
        """
        Drop OAM connection.

        :param pc_connection: Connection to the PC where the OAM connection is dropped
        :param netact_ip: IP address of the NetAct server

        :raise SSHConnectionFailure: If timeout while dropping OAM connection
        """
        try:
            pc_connection.expect([r".*?@.*#"], 30)
            info("Drop OAM connection.")
            pc_connection.sendline(f"nft add rule bridge filter FORWARD ip daddr vmap {{{netact_ip} : drop}}\n")
            pc_connection.expect([r".*?@.*#"], 30)
            info("OAM connection is dropped.")
        except pexpect.TIMEOUT as e:
            error(f"Timeout while dropping OAM connection. ({e})")
            raise SSHConnectionFailure(f"Timeout while dropping OAM connection.")

    @staticmethod
    def restore_oam_connection(pc_connection):
        """
        Restore OAM connection.

        :param pc_connection: Connection to the PC where the OAM connection is restored

        :raise SSHConnectionFailure: If timeout while restoring OAM connection
        """
        try:
            pc_connection.expect([r".*?@.*#"], 30)
            info("Restore OAM connection.")
            pc_connection.sendline("nft delete rule bridge filter FORWARD handle 0")
            pc_connection.expect([r".*?@.*#"], 30)
            pc_connection.sendline("nft list table bridge filter")
            pc_connection.expect([r".*?@.*#"], 30)
            info("OAM connection is restored.")
        except pexpect.TIMEOUT as e:
            error(f"Timeout while restoring OAM connection. ({e})")
            raise SSHConnectionFailure(f"Timeout while restoring OAM connection.")

    def make_connection_to_netact_pc(self, pc_ip):
        """
        Make SSH connection to NetAct PC.

        :param pc_ip: IP address of the NetAct PC

        :return: Connection to the NetAct PC
        """
        pc_connection = None
        save_path = self.logger.log_dir
        if not os.path.exists(self.logger.log_dir):
            if "/loop_" in save_path:
                save_path = save_path.split("/loop_")[0]
                self.logger.debug(f"Folder {self.logger.log_dir} doesn't exists anymore, use test folder path to save "
                                  f"the ssh file: {save_path}")
        if not os.path.exists(save_path):
            self.logger.debug(f"Folder {save_path} doesn't exists anymore, use suite folder path to save the "
                              f"ssh file: {self.logger.suite_folder}")
            save_path = self.logger.suite_folder
        if not os.path.exists(f"{save_path}/ssh_logs"):
            self.logger.debug(f"Folder {save_path}/ssh_logs doesn't exists, create it.")
            os.makedirs(f"{save_path}/ssh_logs", exist_ok=True)
        save_path = f"{save_path}/ssh_logs"
        self.logger.debug(f"Save ssh logs to folder {save_path}.")
        pexpect_log_file_path = os.path.join(save_path, f"ssh_netact_pc_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")
        self.logger.debug("Log file path: {}".format(pexpect_log_file_path))
        self.pexpect_log = open(pexpect_log_file_path, 'a')

        try_time = 0
        ssh_ok = False
        info("Trying to connect to NetAct PC. Max 10 tries.")
        while try_time < 11 and not ssh_ok:
            try_time += 1
            try:
                self.logger.debug(f"Create ssh connection to {pc_ip} ({try_time}.try)")
                pc_connection = pexpect.spawn(f"ssh {LAB_PC_USERNAME}@{pc_ip}", encoding='utf-8')
                pc_connection.logfile = self.pexpect_log
                pc_connection.sendline("yes")
                pc_connection.expect(".*?assword.*")
                pc_connection.sendline(LAB_PC_PASSWD)
                pc_connection.expect(r".*Last login.*")
                ssh_ok = True
            except pexpect.TIMEOUT as e:
                if try_time == 10:
                    error(f"Timeout while taking ssh connection to {pc_ip}. ({e})")
                    raise SSHConnectionFailure(f"Timeout while taking ssh connection to {pc_ip}.")
                else:
                    self.logger.debug(f"Timeout while taking ssh connection to {pc_ip}. Try again. ({e})")
                    pc_connection.close()
                    pc_connection = None
            except pexpect.EOF as e:
                if try_time == 10:
                    error(f"EOF while taking ssh connection to {pc_ip}. ({e})")
                    raise SSHConnectionFailure(f"EOF while taking ssh connection to {pc_ip}.")
                else:
                    self.logger.debug(f"EOF while taking ssh connection to {pc_ip}. Try again. ({e})")
                    pc_connection.close()
                    pc_connection = None
        info("Connected successfully to NetAct PC.")
        return pc_connection

    def get_ips_from_resource_file(self):
        """
        Get IP addresses from resource file.

        :return tuple: PC and NetAct IP addresses
        """
        for key, value in netact.items():
            if key == str(self.get_bts_id()):
                pc_ip = value[0]
                netact_ip = value[1]
                return pc_ip, netact_ip
        error("Can't find IP addresses for netact in resource file (PM/Resources/netact_dict.py).")

    def get_bts_id(self):
        """
        Get BTS ID.
        """
        bts_id = self.bts.get_parameter_value_from_bts_info("btsId")
        return bts_id
