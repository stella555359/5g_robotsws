import os
import subprocess
from taf.rfrl.utilities.robot.general import get_builtin_value
from ute_common_admin.exception import AdminApiProcedureFailureException

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_airphone import (
    load_template_iphy, upload_default_iphy_file
)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_gnb import (
    perform_recomissioning_with_delta, modify_object_operation_state_if_needed,
    perform_gnb_commissioning, run_on_ap, wait_for_requested_bts_state, update_parameter_value,
    set_proper_vlan_id_in_scf, get_gnb_build_release
)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_console_info
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.file_management import upload_files_to_ap
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.logs_collection import LogsCollectorWrapper
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.utilities import get_log_dir
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.variables import GNB2_IP
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.variables import ip_config


class EnvResources:

    def __init__(self):
        self.logs_instance = LogsCollectorWrapper()
        self.default_scf1_path = \
            os.path.join(get_log_dir(suite_log_dir=True), self.logs_instance.default_scf1_filename)
        self.default_scf2_path = \
            os.path.join(get_log_dir(suite_log_dir=True), self.logs_instance.default_scf2_filename)
        self.default_iphy_path = \
            os.path.join(get_log_dir(suite_log_dir=True), self.logs_instance.default_iphy_filename)

    @staticmethod
    def perform_scf_commissioning(scf_gnb1_filepath, scf_gnb2_filepath=None):
        """
        Perform commissioning of both gNBs.

        :param scf_gnb1_filepath: (str) gNB1 SCF filepath
        :param scf_gnb2_filepath: (str) gNB2 SCF filepath
        """

        perform_gnb_commissioning(scf_file=scf_gnb1_filepath)
        if GNB2_IP:
            perform_gnb_commissioning(scf_file=scf_gnb2_filepath, bts_host_ip=GNB2_IP)

    def restore_default_scfs(self):
        """
        Restore default SCF files.
        """

        self.perform_scf_commissioning(
            scf_gnb1_filepath=self.default_scf1_path,
            scf_gnb2_filepath=self.default_scf2_path
        )

    @staticmethod
    def perform_iphy_reconfiguration():
        """
        Load iphy file from template and upload it to Airphone with up-to-date build versions.
        """

        iphy_template_filepath = get_builtin_value(f'IPHY_AWKUC')
        if iphy_template_filepath:
            logger_console_info(f'\niphy_template_filepath: {iphy_template_filepath}\n')
            load_template_iphy(iphy_template_filepath)
        else:
            logger_console_info('Iphy reconfiguration skipped')

    def restore_default_iphy(self):
        """
        Upload default iphy file into AP.
        """

        upload_files_to_ap(files=[self.default_iphy_path], remote_path='/rom/simmode')
        run_on_ap(f'cd /rom/simmode; ln -fs {self.logs_instance.default_iphy_filename} iphy.xml')
        run_on_ap('system-module-reboot')
        logger_console_info('IPHY file modified successfully')

    @staticmethod
    def update_vlan_id_in_scf():
        scf_template_filepath = get_builtin_value(f'scf_RAN_sharing')
        if scf_template_filepath:
            set_proper_vlan_id_in_scf(scf_template_filepath)
        else:
            logger_console_info('SCF VLAN update skipped')

    @staticmethod
    def add_ips():
        logger_console_info(f'\nip_config: {ip_config}\n')
        result = subprocess.run(
            ["sudo", "bash", ip_config],
            capture_output=True,  # captures stdout and stderr
            text=True  # returns output as string instead of bytes
        )
        logger_console_info(f'\nresult: {result}\n')

    @staticmethod
    def create_link_to_wts():
        subprocess.run(['rm', '-rf', '/opt/iphy/latest'], check=True)
        subprocess.run(['ln', '-s', '/opt/wts/latest', '/opt/iphy/latest'], check=True)
        subprocess.run(['sudo', 'chmod', '-R', '777', '/opt/iphy/latest'], check=True)
        subprocess.run(['sudo', 'chmod', '-R', '777', '/opt/wts/latest'], check=True)
