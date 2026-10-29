from robot.libraries.BuiltIn import BuiltIn
import os
import sys
import time
import logging
from taf.transport.ssh import ssh
from taf.transport.ssh.connection import SSHConnection
tl = BuiltIn().get_variable_value('${tl}')


class Overheat_operate(object):
    def __init__(self):
        self.ssh = ssh()
        self.sshconnection = SSHConnection()

    def login_cpc(self, hostname, username, password):
        """
        Author: Ren Biyao
        Description: login cpc
        """
        for x_retry in range(4):
            login_cpc_status = self.ssh.connect_to(hostname=hostname, username=username, password=password,
                                                   alias="login_cpc", timeout=50.0)
            if login_cpc_status is True:
                break

    def logout_cpc(self):
        """
        Author: Ren Biyao
        Description: logout cpc
        """
        self.ssh.disconnect(connection="login_cpc")

    # def Install_qmi(self, ue_sn, hostname):
    #     """
    #     Author: Ren Biyao
    #     Description:first check if qmi_tmd_query app is installed or not.
    #                 If the app is not installed, this kw will install.
    #     """
    #     self.login_cpc(hostname=str(hostname), username="nokia5G", password="noki@123")
    #     qmi_status = self.ssh.execute(command="adb -s {} shell \"ls /vendor/bin/qmi_tmd_query\"".format(ue_sn),
    #                                   connection="login_cpc", timeout=30.0)
    #     if "No such file" in qmi_status:
    #         self.ssh.send_command(command="adb -s {} root".format(ue_sn), connection="login_cpc")
    #         time.sleep(2)
    #         self.ssh.send_command(command="adb -s {} disable-verity".format(ue_sn), connection="login_cpc")
    #         remount_suc = self.ssh.execute(command="adb -s {} remount".format(ue_sn),
    #                                        connection="login_cpc", timeout=30.0)
    #         self.ssh.send_command(command="adb -s {} reboot".format(ue_sn), connection="login_cpc")
    #         time.sleep(3)
    #         for i in range(10):
    #             devices_exist = self.ssh.execute(command="adb devices", connection="login_cpc", timeout=30.0)
    #             logging.warning("devices_exist is {}".format(devices_exist))
    #             res = str(ue_sn) in devices_exist
    #             if res:
    #                 break
    #         self.ssh.send_command(command="adb -s {} root".format(ue_sn), connection="login_cpc")
    #         time.sleep(2)
    #         qmi_local_path = os.path.join(sys.path[0], 'qmi_tmd_query')
    #         logging.warning("aaaa {}".format(qmi_local_path))
    #         self.ssh.upload_file(local_path=qmi_local_path, remote_path='C:/qmi_tmd_query',
    #                              connection="login_cpc", timeout=30)
    #         self.ssh.send_command(command="adb -s {} push C:/qmi_tmd_query /vendor/bin".format(ue_sn),
    #                               connection="login_cpc")
    #         self.ssh.send_command(command="adb -s {} shell \"chmod 777 /vendor/bin/qmi_tmd_query\"".format(ue_sn),
    #                               connection="login_cpc")
    #         qmi_root = self.ssh.execute(
    #             command="adb -s {} shell \"ls -al /vendor/bin/qmi_tmd_query\"".format(ue_sn),
    #             connection="login_cpc", timeout=30.0)
    #
    #         if "root" in qmi_root and "/vendor/bin/qmi_tmd_query" in qmi_root:
    #             logging.warning("qmi_tmd_query is ready to use")
    #
    #     if "Permission denied" in qmi_status:
    #         self.ssh.send_command(command="adb -s {} shell \"chmod 777 /vendor/bin/qmi_tmd_query\"".format(ue_sn),
    #                               connection="login_cpc")
    #         qmi_root = self.ssh.execute(
    #             command="adb -s {} shell \"ls -al /vendor/bin/qmi_tmd_query\"".format(ue_sn),
    #             connection="login_cpc", timeout=30.0)
    #
    #         logging.warning("qmi status is {}".format(qmi_root))
    #     self.logout_cpc()

    # def set_cqi_value(self, ue_sn, hostname, cqi_value=1):
    #     """
    #     Author: Ren Biyao
    #     Description: This kw helps to set cqi value, only 0, 1 are valid value
    #     """
    #     try:
    #         self.sshconnection.configure(hostname=str(hostname), username="nokia5G", password="noki@123")
    #         self.sshconnection.connect()
    #         _kill_qmi = "adb -s " + str(ue_sn)+" shell ps -ef|grep qmi_tmd_query|awk '{print $2}'| adb -s " \
    #                     + str(ue_sn) + " shell xargs kill -9"
    #         self.sshconnection.send_command(_kill_qmi)
    #         for i in range(2):
    #             self.sshconnection.disconnect()
    #             self.sshconnection.connect()
    #             if "sdx60" in str(tl.ues[0].capabilities):
    #                 tn_process = self.sshconnection.send_command(
    #                     'adb -s {} root & adb -s {} shell qmi_tmd_query'.format(ue_sn, ue_sn))
    #                 time.sleep(5)
    #                 tn_process.write_input("set:0:modem:{}".format(str(cqi_value)))
    #                 time.sleep(2)
    #                 logging.warning('set qmi {} successfully for sdx60'.format(cqi_value))
    #                 tn_process.write_input("quit")
    #                 time.sleep(2)
    #                 tn_process.write_input("exit")
    #                 self.sshconnection.disconnect()
    #             else:
    #                 tn_process = self.sshconnection.send_command(
    #                     'adb -s {} root & adb -s {} shell qmi_tmd_query'.format(ue_sn, ue_sn))
    #                 time.sleep(5)
    #                 tn_process.write_input("set:0:modem_nr_dsc:{}".format(str(cqi_value)))
    #                 time.sleep(2)
    #                 logging.warning('set qmi {} successfully for sdx65'.format(cqi_value))
    #                 tn_process.write_input("quit")
    #                 time.sleep(2)
    #                 tn_process.write_input("exit")
    #                 self.sshconnection.disconnect()
    #     finally:
    #         self.sshconnection.disconnect()

    def root_ue_before_send_cqi(self, ue_sn, hostname):
        """
        Author: Dandan Fang
        Description: This kw helps to root ue first, it should do before UL traffic, else sometime UL traffic will be
        Stopped after run the command.
        """
        self.sshconnection.configure(hostname=str(hostname), username="nokia5G", password="noki@123")
        self.sshconnection.connect()
        try:
            for i in range(3):
                self.sshconnection.send_command("adb -s {} root".format(ue_sn))
                time.sleep(5)
            logging.warning('set adb root successfully')
            self.sshconnection.disconnect()
            time.sleep(1)
        finally:
            self.sshconnection.disconnect()

    def set_cqi_value(self, ue_sn, hostname, cqi_value=0):
        """
        Author: Ren Biyao
        Description: This kw helps to set cqi value, only 0, 6 are valid value
        """
        try:
            self.sshconnection.configure(hostname=str(hostname), username="nokia5G", password="noki@123")
            self.sshconnection.connect()
            self.sshconnection.send_command('adb -s {} root'.format(ue_sn))
            time.sleep(5)
            # print("ue_sn is {}".format(ue_sn))
            modem_line_num = self.sshconnection.execute(
                "adb shell 'cat /sys/class/thermal/cooling_device*/type | grep -n modem_nr_dsc'")
            # print("modem_line_num is {}". format((modem_line_num.split(':')[0]).split('n')[-1]))
            modem_5G_location = self.sshconnection.execute(
                "adb shell 'ls -ld /sys/class/thermal/cooling_device*  | sed "
                "-n '{}p''".format(str((modem_line_num.split(':')[0]).split('n')[-1])))
            # print("modem location is {}".format(modem_5G_location))
            self.sshconnection.send_command(
                'adb -s {} shell "echo {} > {}/cur_state"'.format(ue_sn, cqi_value, modem_5G_location.split()[7]))
            time.sleep(5)
            logging.warning('set overheating status {} successfully for UE'.format(cqi_value))
        finally:
            self.sshconnection.disconnect()

# if __name__ == '__main__':
    # Overheat = Overheat_operate()
    # Overheat.login_cpc(hostname="10.101.47.193", username="nokia5G", password="noki@123")
    # Overheat.Install_qmi(ue_sn="34801d0", hostname="10.101.47.193")
    # Overheat.set_cqi_value(ue_sn="34801d0", hostname="10.101.47.193", cqi_value=0)
    # Overheat.logout_cpc()
    # Overheat.logout_cpc()
