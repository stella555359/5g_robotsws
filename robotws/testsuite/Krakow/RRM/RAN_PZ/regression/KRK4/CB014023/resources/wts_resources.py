import os
import shutil
import re
import time
from taf.config.wts import wts
from ta5g_ue_mobility import ta5g_ue_mobility
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_wts import (
    attach_ue_and_establish_pdu_session, start_traffic_for_multiple_ues, stop_data_traffic_for_multiple_ues,
    check_ue_thput_stats, configure_ips_on_vm_interfaces, wait_for_environment_prepared_for_wts_ready_state,
    attach_ue_and_perform_sgnb_addition, setup_x2_link, get_next_suci, get_next_imsi, get_next_ipv4_address,
    run_egate_cmd, wait_for_information_block_reception, check_bearer_stats)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.utilities import get_log_dir
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.variables import wts_6_AMF
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import (
    logger_info, logger_warning, logger_debug, logger_console_info
)


class WtsSetup:
    """
    This class is responsible for setting up the WTS environment for test execution.
    It prepares the WTS configuration file, sets up necessary links, configures IP addresses on VM etc.
    """

    configuration_dir = os.path.dirname(os.path.abspath(__file__))

    def __init__(self):
        self._x2_link_pass_regexp = 'X2AP Link with GNB-<GNB-ID> .* is up'
        self._default_cfg_path = '/opt/wts/latest/basic_setup.cfg'
        self._target_filename = 'wts_cfg.cfg'
        self._wts_instance = wts()
        self._pdu_regexp_pattern = f'UE-<UE-ID> PDU SESSION ID-<PDU-ID> setup/reestablishment complete'
        self._ue_deregister_regexp_pattern = f'UE<UE-ID>: detached'
        self._dl_tput_stats_pass_regexp = 'NR PDSCH'
        self._ul_tput_stats_pass_regexp = 'NR PUSCH'

    def setup_wts_environment(self, allow_first_reboot=True):
        """
        Prepares the WTS environment for test execution.
        This includes preparing the VM IP addresses, setting up the simulator and the X2 link.
        FR2 NSA - SIB messages are received after X2 link is established
        FR2 SA - X2 link should not be established, SIB is received only for PCell

        :param allow_first_reboot: (bool, optional) Whether to allow the first reboot. Default is True.
        """

        # self._prepare_vm_ip_addresses()
        wts_file = self._prepare_wts_configuration_file()
        logger_console_info(f'\nwts_file: {wts_file}\n')
        wait_for_environment_prepared_for_wts_ready_state(
            wts_config_filename=wts_file,
            sib_reception_dict={2: [1], 1: [1]},
            info_block_type='SystemInformationBlockType1',
            allow_first_reboot=allow_first_reboot,
        )

    def _prepare_wts_configuration_file(self):
        """
        Prepare WTS configuration file for test execution
        and rename the folder to avoid the '#' character
        """

        original_log_dir = get_log_dir()
        test_dir_name = os.path.basename(original_log_dir)
        sanitized_test_dir_name = re.sub(r'[#]', '_', test_dir_name)

        parent_log_dir = os.path.dirname(original_log_dir)
        sanitized_log_dir = os.path.join(parent_log_dir, sanitized_test_dir_name)

        os.makedirs(sanitized_log_dir, exist_ok=True)
        wts_cfg_path = os.path.join(sanitized_log_dir, self._target_filename)
        shutil.copyfile(src=wts_6_AMF, dst=wts_cfg_path)

        # wts_cfg_path = os.path.join(get_log_dir(), self._target_filename)
        # shutil.copyfile(src=wts_6_AMF, dst=wts_cfg_path)
        # # self._wts_instance.load_wts_cfg(wts_cfg_path)
        # # mods
        # # self._wts_instance.save_wts_cfg(file_path=wts_cfg_path)
        logger_console_info(f'\nwts_cfg_path: {wts_cfg_path}\n')
        return wts_cfg_path

    def register_multiple_ues_and_handle_traffic(self, trf_duration=40, deregister=False):
        """
        Handle registering UEs and traffic running based on configuration specified in 'ues_conf' parameter.

        :param ues_conf: (tuple) global value from test_scenario_variables.py
        :param trf_duration: (int) Time when traffic is running for single UE [s]
        :param deregister: (bool)
        """

        ues_conf = (
            {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'dl_mbps': 525},
            {'ue_id': 2, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'dl_mbps': 525},
            {'ue_id': 3, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'dl_mbps': 525},
            {'ue_id': 4, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'dl_mbps': 525},
            {'ue_id': 5, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'dl_mbps': 525},
            {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'dl_mbps': 525},
        )

        for ue_conf in ues_conf:
            getattr(self, f'attach_sa_ue_and_run_traffic')(**ue_conf)
            if trf_duration:
                self.wait_for_traffic_running(trf_duration)
                self.get_ue_throughput_stats(**ue_conf)
                self.stop_traffic(number_of_ues=1, first_ue_id=ue_conf['ue_id'], net_arch=ue_conf['net_arch'])
            # if deregister:
            #     if ue_conf["net_arch"] == 'sa':
            #         self.deregister_ues(sa_ues=str(ue_conf['ue_id']))
            #     else:
            #         self.deregister_ues(nsa_ues=str(ue_conf['ue_id']))

    def attach_sa_ue_and_run_traffic(self, ue_id=1, pdu=1, cell_id=1, enb_id=2, nwslice=1, trf_dir='bi', **kwargs):
        """
        Attach single SA UE and run traffic for it
        """

        attach_ue_and_establish_pdu_session(
            ue_id=ue_id,
            cell_id=cell_id,
            enb_id=enb_id,
            pdu=pdu,
            nwslice=nwslice,
            pdu_regexp=self._get_pdu_regexp(ue_id, pdu),
        )
        time.sleep(3)  # necessary for traffic counters to be more accurate
        start_traffic_for_multiple_ues(
            number_of_ues=1,
            first_ue_id=ue_id,
            traffic_direction=trf_dir,
            **kwargs
        )

    @staticmethod
    def wait_for_traffic_running(duration=1, **kwargs):
        """
        :param duration: (int) Wait time in seconds
        """

        time.sleep(duration)

    def get_ue_throughput_stats(self, ue_id=1, trf_dir='bi', scell_range='0-15', bearer_id=2, **kwargs):
        """
        Get UE throughput statistics

        :param ue_id: (int)
        :param trf_dir: (str) Traffic direction 'dl', 'ul' or 'bi'
        :param scell_range: (str) Cells range for which statistics will be displayed
        :param bearer_id: (int) bearer ID for NSA UE
        """

        dl_stats = check_ue_thput_stats(
            ues_ids=ue_id,
            scell=scell_range,
            type='pdsch',
            pass_regexp=self._dl_tput_stats_pass_regexp
        )
        logger_console_info(dl_stats)
        return dl_stats

    def _get_pdu_regexp(self, ue_id, pdu):
        return self._pdu_regexp_pattern.replace('<UE-ID>', str(ue_id)).replace('<PDU-ID>', str(pdu))

    @staticmethod
    def stop_traffic(number_of_ues, **kwargs):
        """
        Stops all traffic for certain UEs.
        """

        stop_data_traffic_for_multiple_ues(
            number_of_ues=number_of_ues,
            traffic_direction='dl',
            trf_id='1-32',
            **kwargs
        )

    def attach_ue_and_expect_error(self, ue_id=1, cell_id=1, plmn_id="002:002"):
        register_ue_error_regexp = f"AMF-1: Received PLMN {plmn_id} in the SUCI is not supported."
        command = "set_pdu_param ue={} pdu={} trf_type=internal".format(ue_id, ue_id)
        run_egate_cmd(cmd=command)
        ta5g_ue_mobility().attach_ue(ue_id=ue_id, cell=cell_id, enb=2, timeout=60,
                                     pass_regexp=register_ue_error_regexp)

    def attach_multiple_ues_and_expect_error(self, ue_ids=None, cell_id=1, plmn_ids=None):
        if not ue_ids:
            ue_ids = [2, 3, 4, 5, 6]
        if not plmn_ids:
            plmn_ids = ["002:002", "003:003", "004:004", "005:005", "006:006"]
        for (ue_id, plmn_id) in zip(ue_ids, plmn_ids):
            self.attach_ue_and_expect_error(ue_id=ue_id, plmn_id=plmn_id, cell_id=cell_id)
