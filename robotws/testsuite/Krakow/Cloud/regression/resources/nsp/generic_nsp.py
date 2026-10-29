"""
NSP server operations

:copyright: Nokia Networks
:author: Grzegorz Hajto, Lukasz Skoczylas,
:contact: grzegorz.hajto@nokia.com, lukasz.skoczylas@nokia.com
"""

import os
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from taf.ul.sc.util.helpers import generate_unix_remote_device


class GenericNsp(object):
    """"Generic NSP operations"""
    def __init__(self, nsp_server_ip, user="root", password="siemens"):
        self.nsp_server_ip = nsp_server_ip
        self.wo_import_path = "/opt/nsp/nfmp/server/nms/activation/wo_import/"
        self.user = user
        self.password = password

    @load_moler_configuration_from_tl()
    def send_wo_file_to_nsp(self, work_order_filename, bts_id=0, du_id=0):
        """
        Sends work order file identified by work_order_filename to NSP wo_import directory
        :param work_order_filename: (str) path to work order file
        :param bts_id:  (int) ID of gNB/eNB, default 0
        :param du_id: (int) DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        pc = DeviceFactory.get_device('TEST_PC')  # in /home/ute on test pc
        pc.goto_state('UNIX_LOCAL')  # in robotws5g eg. /home/ute/auto/robotws5g
        scp_download_files = pc.get_cmd(
            cmd_name="scp",
            cmd_params={
                "source": work_order_filename,
                "dest": "{0}@{1}:{2}".format(self.user, self.nsp_server_ip, self.wo_import_path),
                "password": "{0}".format(self.password),
                "options": "-p"})
        scp_download_files()
        generate_unix_remote_device("nsp_server", self.nsp_server_ip, self.user, self.password)
        nsp = DeviceFactory.get_device("nsp_server")
        nsp.goto_state("UNIX_REMOTE")
        file_on_nsp = self.wo_import_path + os.path.basename(work_order_filename)
        chmod = nsp.get_cmd(
            cmd_name='chmod',
            cmd_params={'permission': '666', 'filename': file_on_nsp})
        chmod()
