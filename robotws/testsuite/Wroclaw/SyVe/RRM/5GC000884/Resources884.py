from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputChecker import TputChecker
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.conventers.UplaneComponent import UplaneComponent
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.L2TraceCollector import L2TraceCollector
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.UplaneTTiParesr import UplaneTTiParesr
import random

LTE_ENB = "MRBTS-40442"


class Resources884(object):

    def __init__(self, ue_type):
        self.feature = "5GC000884"
        self.syslog = SyslogCollector()
        self.bts_faults = BtsFaults()
        self.bts_config = BtsConfig()
        self.bts_startup = StartupManager()
        self.bts_snapshot = BtsSnapshot()
        self.ue1 = Ue(ue_type, ue_id=1)
        self.tput = TputChecker()
        self.transfer_end_time = TimeStamp.unix_timestamp
        self.attenuator = Attenuator()
        self.pcap = None
        self.uplane_pcap_trace = None
        self.uplane = None
        self.value_list_pwrcrtl = ["pucchPuschSrs", "pucch", "puschSrs"]
        self.active_flag = random.choice(self.value_list_pwrcrtl)

    def prepare_tdd_gnb_for_884_feature_testing(self):
        self._prepare_gnb('TDD')
        self._set_no_attenuation_on_lte_ports()

    def prepare_fdd_gnb_for_884_feature_testing(self):
        self._prepare_gnb('FDD')

    def _prepare_gnb(self, duplex):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, duplex, 'featureOFF')
        self.bts_config.perform_full_commissioning(scf_file)
        self.bts_startup.manage_commissioned_bts_to_reach_on_air_state()

    def prepare_tdd_enb_for_884_feature_testing(self):
        self.bts_startup.update_sw_and_commission_remote_bts(self.feature, LTE_ENB)

    def prepare_environment_and_start_logging_for_884_feature(self):
        self.attenuator.restore_no_attenuation_on_all_ports()
        self.ue1.prepare_ue()
        self.syslog.start_btslog_on_local_machine()

    def wait_for_x2_connection_between_gnb_and_enb_established(self):
        self.bts_startup.wait_for_x2_connected()

    def restore_base_config_and_cleanup_the_setup_and_collect_logs_if_the_test_fails(self, duplex):
        from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
        Rfrl.common_step_trigger()
        self.ue1.detach()
        try:
            self.pcap.stop_collecting_pcap_and_collect_files_on_local_os_if_the_test_fails()
        except AttributeError:
            Logger.warning("Stopping collecting pcap failed, probably not started")
        self.ue1.try_to_get_and_remove_traffic_log_files()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.bts_faults.log_active_faults()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self._restore_bts_configuration(duplex)

    def collect_snapshot_if_suite_fails(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()

    def collect_snapshots_if_suite_fails(self):
        self.bts_startup.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(bts_name=LTE_ENB)
        self.collect_snapshot_if_suite_fails()

    def scenario_close_loop_power_control(self, duplex, active_flag=None):
        if active_flag:
            self.active_flag = active_flag
        self._feature_flag_closed_loop_power_control_is_enabled(duplex=duplex, flag=self.active_flag)
        self.ue_is_attached()
        self.pcap_file_collection_is_turned_on()
        self.data_traffic_for_the_ue_is_launched()
        self.radio_channel_condition_is_changed()
        self.pcap_file_collection_is_stopped()
        self.data_traffic_for_the_ue_is_stopped()

    def gnb_is_up_and_running(self):
        self.bts_startup.manage_commissioned_bts_to_reach_on_air_state()

    def ue_is_attached(self):
        self.ue1.attach()

    def data_traffic_for_the_ue_is_launched(self):
        transmission_time = 60
        self.ue1.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=100, data_name="DL")
        self.ue1.start_tcp_uplink_data_transmission(duration=transmission_time, traffic_mb=100, data_name="UL")
        self.transfer_end_time = TimeStamp().unix_timestamp + transmission_time

    def data_traffic_for_the_ue_is_stopped(self):
        time_for_iperf_log_to_be_updated = 5
        TimeStamp.wait_for_the_unix_timestamp(self.transfer_end_time + time_for_iperf_log_to_be_updated)
        self.ue1.stop_uplink_transmission(data_name="UL")
        self.ue1.stop_downlink_transmission(data_name="DL")
        self.ue1.detach()

    def pcap_file_collection_is_turned_on(self):
        self.uplane_pcap_trace = L2TraceCollector()
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Ps")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Lo")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiRlc")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiPdcp")
        self.uplane_pcap_trace.prepare_and_start_collecting_pcap_trace_logs()

    def radio_channel_condition_is_changed(self):
        self.attenuator.increase_ports_attenuation_periodically(delta_attenuation=10,
                                                                interval=5, number_of_repetition=3)
        self.attenuator.decrease_ports_attenuation_periodically(delta_attenuation=10,
                                                                interval=5, number_of_repetition=3)

    def pcap_file_collection_is_stopped(self):
        self.uplane_pcap_trace.stop_collecting_pcap_trace_logs()
        self.uplane = UplaneComponent()
        self.uplane.pcap2csv(files_path_pattern=self.uplane_pcap_trace.pcap_file_path,
                             output_path=self.uplane_pcap_trace.pcap_dir)

    def tcp_command_check_for_selected_parameter_value_actulclosedlooppwrctrl(self):
        fun_list = [self.tpc_command_for_uplink_are_sent_properly_according_to_current_radio_conditions,
                    self.tpc_command_for_downlink_are_sent_properly_according_to_current_radio_conditions,
                    self.tpc_command_and_srs_are_sent_properly_according_to_current_radio_conditions]
        dict_value_function = dict(zip(self.value_list_pwrcrtl, fun_list))
        function_name_for_validation = dict_value_function[f'{self.active_flag}']
        function_name_for_validation()

    def tpc_command_for_uplink_are_sent_properly_according_to_current_radio_conditions(self):
        ul_tpc = UplaneTTiParesr(file_path=self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv")
        ul_tpc.read_file_tti_trace_csv("ulTpc", "tpc")
        self._parse_csv_file_for_tpc_commands(ul_tpc.msg_id_report_data_list, "ulTpc")
        dl_tpc = UplaneTTiParesr(file_path=self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv")
        dl_tpc.read_file_tti_trace_csv("dlTpc", "tpc")
        self._parse_csv_file_for_tpc_commands(dl_tpc.msg_id_report_data_list, "dlTpc")

    def tpc_command_for_downlink_are_sent_properly_according_to_current_radio_conditions(self):
        dl_tpc = UplaneTTiParesr(file_path=self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv")
        dl_tpc.read_file_tti_trace_csv("dlTpc", "tpc")
        self._parse_csv_file_for_tpc_commands(dl_tpc.msg_id_report_data_list, "dlTpc")

    def tpc_command_and_srs_are_sent_properly_according_to_current_radio_conditions(self):
        ul_tpc = UplaneTTiParesr(file_path=self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv")
        ul_tpc.read_file_tti_trace_csv("ulTpc", "tpc")
        self._parse_csv_file_for_tpc_commands(ul_tpc.msg_id_report_data_list, "ulTpc")

    def _feature_flag_closed_loop_power_control_is_enabled(self, duplex, flag):
        delta_file = ScfPathFinder().get_delta_path_for_feature(self.feature, "{}_{}".format(flag, duplex.lower()))
        self.bts_config.perform_delta_commissioning(delta_file)

    def _restore_bts_configuration(self, duplex):
        delta_file = ScfPathFinder().get_delta_path_for_feature(self.feature, "{}_disabled".format(duplex.lower()))
        self.bts_config.perform_delta_commissioning(delta_file)

    def _set_no_attenuation_on_lte_ports(self):
        lte_attenuator_ports = [9, 10]
        for port in lte_attenuator_ports:
            self.attenuator.set_port_attenuation(port=port, target_attenuation=0)

    @staticmethod
    def _parse_csv_file_for_tpc_commands(dl_ul_tpc, message_id):
        list_tcp_value = set()
        for tpc_report in dl_ul_tpc:
            list_tcp_value.add(tpc_report['tpc'])
        Logger.info(f"TPC values found {message_id}: {list_tcp_value}")
        assert len(list_tcp_value) >= 2, "TPC commands have less values than expected at least three"
