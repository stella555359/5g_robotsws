from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import QUALCOMM_SDX55
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputChecker import TputChecker
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Troubleshooting import Troubleshooting
import random
import time
import re
from robot.errors import ExecutionFailed

DL_TPUT_10MHZ = 90
DL_TPUT_10MHZ_TARGET = 84
UL_TPUT_10MHZ = 30
UL_TPUT_10MHZ_TARGET = 28.5
DL_TPUT_20MHZ = 165
DL_TPUT_20MHZ_TARGET = 130
UL_TPUT_20MHZ = 65
UL_TPUT_20MHZ_TARGET = 63
ALLOWED_DEVIATION = 15
TRANSMISSION_TIME = 3*60
ENTRIES_TO_ANALYZE_FOR_3_MIN_TPUT = 120
DL_DATA_NAME = 'DL_{}'
UL_DATA_NAME = 'UL_{}'
BTS_SECTORS = [1, 2, 3]


class Resources2558(CommonSuite):

    def __init__(self):
        super(Resources2558, self).__init__()
        self.feature = "5GC002558"
        self.swconfig = Swconfig()
        self.ue = Ue(QUALCOMM_SDX55, ue_id=1)
        self.tput_checker = TputChecker()
        self.cells_to_block = list(BTS_SECTORS)
        self.troubleshooting = Troubleshooting()
        self.bts_sector_chosen_for_test = None

    def set_test_variables_for_test(self, eda_test=False):
        self.bts_sector_chosen_for_test = 1 if eda_test else random.choice(BTS_SECTORS)
        Logger.info("BTS sector chosen for test: {}".format(self.bts_sector_chosen_for_test))
        self.cells_to_block.remove(self.bts_sector_chosen_for_test)

    def selected_sector_is_ready_for_test(self):
        for cell in self.cells_to_block:
            self.bts_oam.make_sure_gnb_cell_is_blocked(cell)

    def all_cells_are_unblocked_after_test(self):
        for cell in self.cells_to_block:
            self.bts_oam.make_sure_gnb_cell_is_unblocked(cell)

    def prb_blanking_is_configured_on_cell(self, blanked_low_dl, blanked_low_ul, blanked_high_dl, blanked_high_ul):
        dictionary_of_parameters_to_change = {"nbrOfBlankedPRBsLowEdgeDL": blanked_low_dl,
                                              "nbrOfBlankedPRBsLowEdgeUL": blanked_low_ul,
                                              "nbrOfBlankedPRBsHighEdgeDL": blanked_high_dl,
                                              "nbrOfBlankedPRBsHighEdgeUL": blanked_high_ul}
        for parameter in dictionary_of_parameters_to_change:
            Logger.info(f"Changing Nr of blanked PRBs {parameter} to {dictionary_of_parameters_to_change[parameter]}")
            self.bts_config.perform_cell_parameter_recommissioning(cell_id=self.bts_sector_chosen_for_test,
                                                                   parameter=parameter,
                                                                   value=dictionary_of_parameters_to_change[parameter])

    def asp_log_file_is_downloaded_and_number_of_blanked_prbs_is_checked_in_asp_startup_log(self, blanked_low_dl,
                                                                                            blanked_low_ul,
                                                                                            blanked_high_dl,
                                                                                            blanked_high_ul):
        log_file_location = self.troubleshooting.collect_asp_logs_and_return_log_name(
            node_to_download_from="node_L2RT20")
        Logger.debug("Looking for file to parse with filepath: {}".format(log_file_location))
        Resources2558.parse_prb_log_output(log_file_location, blanked_low_dl, blanked_low_ul, blanked_high_dl,
                                           blanked_high_ul)

    def prepare_and_attach_ue(self, eda_test=False):
        self.ue.prepare_ue()
        try:
            self.ue.attach()
        except Exception as error:
            if eda_test:
                Logger().warning("UE was not attached during eda test! Please check if alarm 4383 occured in"
                                 "alarm history. See 02938167 in PR tool for problem description.")
            Logger().warning("UE was not attached! The error was: {}. Restarting UE and trying again.".format(error))
            self.ue.restart_ue()
            self.ue.attach()

    def restart_ue(self):
        self.ue.restart_ue()

    def proper_tcp_traffic_is_launched_and_reached(self, bandwidth,
                                                   dl_traffic_mb=DL_TPUT_10MHZ,
                                                   ul_traffic_mb=UL_TPUT_10MHZ,
                                                   dl_required_tput=DL_TPUT_10MHZ_TARGET,
                                                   ul_required_tput=UL_TPUT_10MHZ_TARGET):
        if bandwidth == '20MHz':
            dl_traffic_mb = DL_TPUT_20MHZ
            ul_traffic_mb = UL_TPUT_20MHZ
            dl_required_tput = DL_TPUT_20MHZ_TARGET
            ul_required_tput = UL_TPUT_20MHZ_TARGET
        self._start_tcp_traffic(bandwidth, dl_traffic_mb, ul_traffic_mb)
        time.sleep(TRANSMISSION_TIME)
        self._stop_tcp_traffic(bandwidth)
        self._check_tcp_traffic(bandwidth, dl_required_tput, ul_required_tput)

    def _start_tcp_traffic(self, bandwidth, dl_traffic_mb, ul_traffic_mb):
        self.ue.start_tcp_downlink_data_transmission(duration=TRANSMISSION_TIME,
                                                     traffic_mb=dl_traffic_mb,
                                                     data_name=DL_DATA_NAME.format(bandwidth))
        self.ue.start_tcp_uplink_data_transmission(duration=TRANSMISSION_TIME,
                                                   traffic_mb=ul_traffic_mb,
                                                   data_name=UL_DATA_NAME.format(bandwidth))

    def make_sure_ue_actions_are_cleared(self):
        self.ue.try_to_get_and_remove_traffic_log_files()

    def _stop_tcp_traffic(self, bandwidth):
        self.ue.stop_uplink_transmission(UL_DATA_NAME.format(bandwidth))
        self.ue.stop_downlink_transmission(DL_DATA_NAME.format(bandwidth))

    def _check_tcp_traffic(self, bandwidth, dl_required_tput, ul_required_tput):
        self.tput_checker.check_downlink_tcp_throughput(ue_id=1,
                                                        required_tput=dl_required_tput,
                                                        deviation=ALLOWED_DEVIATION,
                                                        analyze_entries=ENTRIES_TO_ANALYZE_FOR_3_MIN_TPUT,
                                                        data_name=DL_DATA_NAME.format(bandwidth))
        self.tput_checker.check_uplink_tcp_throughput(ue_id=1,
                                                      required_tput=ul_required_tput,
                                                      deviation=ALLOWED_DEVIATION,
                                                      analyze_entries=ENTRIES_TO_ANALYZE_FOR_3_MIN_TPUT,
                                                      data_name=UL_DATA_NAME.format(bandwidth))

    def detach_qualcomm_ue(self):
        self.ue.detach()

    def update_sw_config_and_prepare_gnb_with_proper_bandwidth(self, bandwidth, uuf_test=False):
        self._update_swconfig(uuf_test)
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, self.local_gnb_id, bandwidth)
        self.bts_config.perform_full_commissioning(scf_file)

    def wait_for_bts_to_reach_on_air_state(self):
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def _update_swconfig(self, uuf_test):
        default_flags = ["0x10045=536870912", "0x45005a=1", "0x1A1300=0", "0x1A0020=1"]
        uuf_flags = ["0x3F001E=1", "0x210017=1", "0x10079=500000"]
        if uuf_test:
            default_flags.extend(uuf_flags)
        self.swconfig.update_swconfig_flags(default_flags)

    @staticmethod
    def parse_prb_log_output(log_file, blanked_low_dl, blanked_low_ul, blanked_high_dl, blanked_high_ul):
        blanked_prb_dict = {"LowEdgeDL": blanked_low_dl, "LowEdgeUL": blanked_low_ul, "HighEdgeDL": blanked_high_dl,
                            "HighEdgeUL": blanked_high_ul}
        with open(log_file, "r") as file:
            file_read = file.read()
            for blanking_direction, number_of_blanked_prbs_in_chosen_direction in blanked_prb_dict.items():
                if str(number_of_blanked_prbs_in_chosen_direction) not in re.findall(
                        r'nbrOfBlankedPRBs{} = (\d)'.format(blanking_direction), file_read):
                    raise ExecutionFailed('nbrOfBlankedPRBs{} != {}'.format(
                        blanking_direction, number_of_blanked_prbs_in_chosen_direction))
