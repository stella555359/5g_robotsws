"""
:author: Anna Bien
:maintainer: Anna Bien
:owner_email: anna.bien@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
"""

import os
from taf.rfrl.utilities.robot.general import get_builtin_value
from ute_common_admin.exception import AdminApiProcedureFailureException

from testsuite.Krakow.RRM.Airphone.resources.Python.common_airphone import (
    load_template_iphy, upload_default_iphy_file
)
from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import (
    perform_recomissioning_with_delta, modify_object_operation_state_if_needed,
    perform_gnb_commissioning, run_on_ap, wait_for_requested_bts_state, update_parameter_value,
    set_proper_vlan_id_in_scf, get_gnb_build_release
)
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console_info
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import upload_files_to_ap
from testsuite.Krakow.RRM.Airphone.CB010636.resources.logs_collection import LogsCollectorWrapper
from testsuite.Krakow.RRM.Airphone.CB010636.resources.utilities import get_log_dir, get_test_prefix
from testsuite.Krakow.RRM.Airphone.CB010636.resources.variables import (
    GNB_IP, GNB2_IP, DELTA_FR2_SA_PCELL_RECONF, DELTA_ACT_PER_CC_DL_UL
)
from robot.libraries.BuiltIn import BuiltIn


class EnvResources:

    def __init__(self):
        self.logs_instance = LogsCollectorWrapper()
        self.default_scf1_path = \
            os.path.join(get_log_dir(suite_log_dir=True), self.logs_instance.default_scf1_filename)
        self.default_scf2_path = \
            os.path.join(get_log_dir(suite_log_dir=True), self.logs_instance.default_scf2_filename)
        self.default_iphy_path = \
            os.path.join(get_log_dir(suite_log_dir=True), self.logs_instance.default_iphy_filename)

    def perform_delta_recommissioning(self, delta_path_gnb1=None, delta_path_gnb2=None):
        """
        Send delta configuration files to both gNBs.
        If delta files are not provided reconfiguration will be skipped.

        :param delta_path_gnb1: (str) Path to gNB1 delta file (optional)
        :param delta_path_gnb2: (str) Path to gNB2 delta file (optional)
        """

        def send_delta_and_modify_objects_on_failure(delta_path, scf_path, bts_host_ip):
            try:
                perform_recomissioning_with_delta(path_to_delta=delta_path, bts_host_ip=bts_host_ip)
            except AdminApiProcedureFailureException:
                modify_object_operation_state_if_needed(
                    delta_file=delta_path,
                    scf_path=scf_path
                )
                perform_recomissioning_with_delta(path_to_delta=delta_path, bts_host_ip=bts_host_ip)

        if delta_path_gnb1:
            logger_console_info(f'Sending {os.path.basename(delta_path_gnb1)} to gNB1')
            send_delta_and_modify_objects_on_failure(
                delta_path=delta_path_gnb1,
                scf_path=self.default_scf1_path,
                bts_host_ip=GNB_IP
            )
        if delta_path_gnb2:
            logger_console_info(f'Sending {os.path.basename(delta_path_gnb2)} to gNB2')
            send_delta_and_modify_objects_on_failure(
                delta_path=delta_path_gnb2,
                scf_path=self.default_scf2_path,
                bts_host_ip=GNB2_IP
            )

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

        test_prefix = get_test_prefix()
        iphy_template_filepath = get_builtin_value(f'IPHY_{test_prefix.upper()}')
        if iphy_template_filepath:
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

    def configure_cell1_as_a_pcell(self):
        """
        Configure NRCELL-1 as a PCell.
        Note: Applicable for FR2 SA configuration, in which only one PCell can be configured.
        """

        self.perform_delta_recommissioning(delta_path_gnb1=DELTA_FR2_SA_PCELL_RECONF)
        wait_for_requested_bts_state(bts_state='onair')

    def activate_act_per_cc_ul_dl_user_thpt(self):
        """
        Configure NRCELL-1 as a PCell.
        Note: Applicable for FR2 SA configuration, in which only one PCell can be configured.
        """

        self.perform_delta_recommissioning(delta_path_gnb1=DELTA_ACT_PER_CC_DL_UL)
        wait_for_requested_bts_state(bts_state='onair')

    @staticmethod
    def toggle_per_cc_user_throughput_counters(counter_status='true'):
        logger_console_info(f"Set Per CC User Throughput counters to {counter_status.upper()}")
        update_parameter_value(parameter='actPerCCDLUserThpt', value=counter_status.lower())
        update_parameter_value(parameter='actPerCCULUserThpt', value=counter_status.lower())

    @staticmethod
    def toggle_thpTimeCalc(value='disabled'):
        logger_console_info(f"Set thpTimeCalc to {value.upper()}")
        update_parameter_value(parameter='thpTimeCalc', value=value.lower())

    @staticmethod
    def set_data_thres_dl_mac_sdu(value=20000, nrdrb_id=11, type='volume'):
        counter_type = "volThresDiscardDlMacSdu" if type.lower() == "volume" else "durationThresDiscardDlMacSdu"
        logger_console_info(f"Set {counter_type} value to: {value} for NRDRB: {nrdrb_id}")
        update_parameter_value(parameter=f'{counter_type}',
                               value=value,
                               dist_name=f'MRBTS-1/NRBTS-1/NRDRB-{nrdrb_id}')

    @staticmethod
    def update_vlan_id_in_scf():
        test_prefix = get_test_prefix()
        scf_template_filepath = get_builtin_value(f'SCF_{test_prefix.upper()}')
        if scf_template_filepath:
            set_proper_vlan_id_in_scf(scf_template_filepath)
        else:
            logger_console_info('SCF VLAN update skipped')

    @staticmethod
    def set_release_variable():
        release = get_gnb_build_release(convert_to_trunk=True)
        BuiltIn().set_suite_variable("${RELEASE}", release)
