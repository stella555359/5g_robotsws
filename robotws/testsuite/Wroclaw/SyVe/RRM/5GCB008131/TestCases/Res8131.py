from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import GALAXY_S21_ULTRA
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.L2TraceCollector import L2TraceCollector
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.conventers.UplaneComponent import UplaneComponent
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.ACsiParser import ACsiParser
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
import time
import math

NR_CELL_ID_FDD = "826359810"
LTE_CELL = 2
LOWER_LOAD = 10
LOWER_LOAD_DEVIATION = 1
HIGHER_LOAD = 900
HIGH_LOAD_LOWER_LIMIT = 400
HIGH_LOAD_UPPER_LIMIT = 1000
LAST_ENTRIES_TO_ANALYZE = 60
SECONDARY_CELL_ID = 1
TIME_UNTIL_TRAFFIC_STABILISES = 10
TIME_NEEDED_TO_RUN_TRAFFIC_TILL_THE_END_OF_TEST = 2040


class Res8131(CommonSuite):

    def __init__(self):
        super(Res8131, self).__init__()
        self.feature = '5GCB008131'
        self.ue = Ue(GALAXY_S21_ULTRA, ue_id=1)
        self.uplane = None
        self.uplane_pcap_trace = None
        self.transmission_time = 15
        self.file_traffic_logs = 0
        self.saved_iteration_logs_dir = None

    @staticmethod
    def erase_unused_and_update_swconfig_flags():
        syslog_flags = ["0x10041=1",
                        "0x10040=1",
                        "0x1003F=1",
                        "402=0x10000001", "0x19000A=1", "0x30000F=1", "0x10045=534217728", "0x590072=1", "0x66001b=1"]
        commented_ones = ["0x45005a=1", "0x1A1300=0", "0x1A0020=1"]
        Swconfig().change_swconfig_flags(syslog_flags, commented_ones)

    def prepare_environment(self):
        self.ue.prepare_ue()
        try:
            self.bts_oam.make_sure_enb_cell_is_blocked(LTE_CELL)
        except Exception as err:
            Logger.debug(f"PDU is disabled or bts don't have configuration:\n{err}")
        self.secondary_cell_is_blocked()
        self.ue_attached()
        self._check_cell_id_after_attach()
        self.secondary_cell_is_unblocked()
        self.ue.detach()

    def gnb_is_up_and_running(self):
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def ue_attached(self):
        self.ue.attach()

    def higher_and_lower_load_are_launched_and_secondary_cell_addition_is_verified_by_tput_check(self):
        self.uplane_pcap_trace_collection_is_started()
        self.ue.start_tcp_uplink_data_transmission(duration=TIME_NEEDED_TO_RUN_TRAFFIC_TILL_THE_END_OF_TEST,
                                                   traffic_mb=LOWER_LOAD, data_name='UL')
        self.ue.start_tcp_downlink_data_transmission(duration=TIME_NEEDED_TO_RUN_TRAFFIC_TILL_THE_END_OF_TEST,
                                                     traffic_mb=LOWER_LOAD, data_name='lowertput')
        time.sleep(TIME_UNTIL_TRAFFIC_STABILISES)
        self.ue.start_tcp_downlink_data_transmission(duration=TIME_NEEDED_TO_RUN_TRAFFIC_TILL_THE_END_OF_TEST,
                                                     traffic_mb=HIGHER_LOAD, data_name='highertput')
        time.sleep(self.transmission_time)
        self._check_lower_tput()
        self._check_higher_tput()
        self._collect_traffic_files_and_stop_uplane_collection('first_step')
        self.move_checked_traffic_files()

    def higher_load_is_stopped_and_secondary_cell_removal_is_verified_by_tput_check(self):
        self.uplane_pcap_trace_collection_is_started()
        self.ue.stop_downlink_transmission(data_name='highertput')
        time.sleep(self.transmission_time)
        self._check_lower_tput()
        self._collect_traffic_files_and_stop_uplane_collection('second_step')
        self.move_checked_traffic_files()

    def higher_load_is_launched_again_and_secondary_cell_addition_is_verified_by_tput_check(self):
        self.uplane_pcap_trace_collection_is_started()
        time.sleep(TIME_UNTIL_TRAFFIC_STABILISES)
        self.ue.start_tcp_downlink_data_transmission(duration=TIME_NEEDED_TO_RUN_TRAFFIC_TILL_THE_END_OF_TEST,
                                                     traffic_mb=HIGHER_LOAD, data_name='highertput')
        time.sleep(self.transmission_time)
        self._check_lower_tput()
        self._check_higher_tput()
        self._collect_traffic_files_and_stop_uplane_collection('third_step')
        self.move_checked_traffic_files()

    def data_traffic_for_the_ue_is_stopped_and_ue_detached(self):
        try:
            self.ue.stop_uplink_transmission(data_name='UL')
            self.ue.stop_downlink_transmission(data_name='lowertput')
            self.ue.stop_downlink_transmission(data_name='highertput')
        except Exception as err:
            Logger.warning(err)
        finally:
            self.ue.detach()

    def try_to_remove_traffic_files(self):
        self.ue.try_to_get_and_remove_traffic_log_files()

    def uplane_pcap_trace_collection_is_started(self):
        self.uplane_pcap_trace = L2TraceCollector()
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Ps")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Lo")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiRlc")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiPdcp")
        self.uplane_pcap_trace.prepare_and_start_collecting_pcap_trace_logs()

    def uplane_pcap_trace_collection_is_stopped(self):
        self.uplane_pcap_trace.stop_collecting_pcap_trace_logs()
        self.uplane = UplaneComponent()
        self.uplane.pcap2csv(files_path_pattern=self.uplane_pcap_trace.pcap_file_path,
                             output_path=self.uplane_pcap_trace.pcap_dir)

    def uplane_file_is_validated_and_checked_for_proper_acsi_quantity(self):
        file_path = self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv"
        Logger.info(f"File to check:\n{file_path}")
        parse = ACsiParser(file_path=file_path)
        parse.check_the_csv_file_acsi_report_tdd()

    def secondary_cell_is_blocked(self):
        self.bts_oam.block_gnb_cell(SECONDARY_CELL_ID)

    def secondary_cell_is_unblocked(self):
        self.bts_oam.unblock_gnb_cell(SECONDARY_CELL_ID)

    def move_checked_traffic_files(self):
        current_iteration_logs_dir = Env().test_log_dir
        self.saved_iteration_logs_dir = Env().test_log_dir + "_step_{}".format(self.file_traffic_logs)
        if Os.check_if_dir_is_not_empty(current_iteration_logs_dir):
            Os.move_dir(current_iteration_logs_dir, self.saved_iteration_logs_dir)
            self.file_traffic_logs += 1

    @staticmethod
    def copy_tcpdump_file_to_test_folder(indication):
        Os.execute_command('cp /tmp/tcpdump_tcpdump.pcap {}/tcpdump_{}_step.pcap'.format(Env().test_log_dir,
                                                                                         indication))

    def _get_average_transfer_for_traffic(self, data_name, seconds_for_data_statistics):
        stabilization_period_seconds = LOWER_LOAD
        analyze_entries = seconds_for_data_statistics - stabilization_period_seconds
        return self.ue.get_average_megabits_data_transfer(data_name=data_name, analyze_entries=analyze_entries)

    def _check_lower_tput(self):
        assert math.fabs(self._get_average_transfer_for_traffic('UL', LAST_ENTRIES_TO_ANALYZE) - LOWER_LOAD) < \
               LOWER_LOAD_DEVIATION, "low UL traffic check failed, please check the saved files"
        assert math.fabs(self._get_average_transfer_for_traffic('lowertput', LAST_ENTRIES_TO_ANALYZE) - LOWER_LOAD) < \
               LOWER_LOAD_DEVIATION, "low DL traffic check failed, please check the saved files"

    def _check_higher_tput(self):
        assert HIGH_LOAD_LOWER_LIMIT < \
               self._get_average_transfer_for_traffic('highertput', LAST_ENTRIES_TO_ANALYZE) < HIGH_LOAD_UPPER_LIMIT, \
               "high DL traffic check failed, please check the saved files"

    def _collect_traffic_files_and_stop_uplane_collection(self, indication):
        self.copy_tcpdump_file_to_test_folder(indication)
        self.uplane_pcap_trace_collection_is_stopped()

    def _check_cell_id_after_attach(self):
        cell_id_attached_ue = self.ue.get_mnci_cell_id()
        Logger.debug(f"Ue attached to the cell id: {cell_id_attached_ue}")
        assert str(cell_id_attached_ue).strip() in str(NR_CELL_ID_FDD), \
            f"Attach to incorrect cell id {cell_id_attached_ue}"
