from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import is_dry_run
from moler.util.moler_test import MolerTest
from taf.sw.qualcomm.license import license
from robot.libraries.BuiltIn import BuiltIn
import paramiko
import logging
import yaml
import os


class LicenseKeeper:

    def __init__(self, ue_id=0,
                 licence_keeper_path='/cygdrive/c/auto/QPM_LK_1_5_1_krk',
                 credentials_filename='credentials.yaml'):

        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.uepc_ipaddr = tl.ues[ue_id].ssh_connection_details.addr
        self.uepc_username = tl.ues[ue_id].ssh_connection_details.username
        self.uepc_password = tl.ues[ue_id].ssh_connection_details.password
        self.ue_serial = tl.ues[ue_id].serial_number
        self.credentials_filename = credentials_filename
        self.licence_keeper_path = licence_keeper_path
        self.ue_id = ue_id
        self.lkp = license()
        if not is_dry_run():
            try:
                self._login()
            except Exception as e:
                logging.warning("Login to licence Keeper failure."
                                "Exception occurred: {}".format(e))

    def _login(self):
        launcher = {"host": self.uepc_ipaddr,
                    "path": self.licence_keeper_path,
                    "user": self.uepc_username,
                    "password": self.uepc_password}

        credentials_path = os.path.join(self.licence_keeper_path, self.credentials_filename)
        credentials = self._get_credentials_from_file(credentials_path)
        login = credentials['user']
        password = credentials['password']

        self.lkp.setup(launcher=launcher)
        self.lkp.login(username=login, password=password)

    def get_qcat_licence(self):
        self.lkp.get_licence_qcat_5g()

    def get_pcat_licence(self):
        self.lkp.get_licence_pcat_5g()

    def get_qxdm_5g_licence(self):
        self.lkp.get_licence_qxdm_5g()

    def release_qcat_licence(self):
        self.lkp.release_licence_qcat_5g()

    def release_pcat_licence(self):
        self.lkp.release_licence_pcat_5g()

    def release_qxdm_5g_licence(self):
        self.lkp.release_licence_qxdm_5g()

    def logout(self):
        self.lkp.logout()
        self.lkp.teardown()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _get_credentials_from_file(self, file_path, ssh_port=22):
        """
        Read configuration file located on UEPC and return dict.

        :param file_path:               path to file with credentials located on UE_PC
        :return: credentials:           dict

        credentials.yaml file should be in format as below:
        user: project_account@nokia.com
        password: GiveMeLicence
        """
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(self.uepc_ipaddr, ssh_port, self.uepc_username, self.uepc_password)
        std_in, std_out, std_err = ssh_client.exec_command("cat {}".format(file_path))
        std_out.channel.recv_exit_status()
        file_content = std_out.readlines()
        credentials = yaml.load("\n".join(file_content), Loader=yaml.FullLoader)
        ssh_client.close()
        return credentials
