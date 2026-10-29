from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import MEDIATEK
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.PcapCollector import BipCollector, TcpdumpCollector, \
    expected_log_is_stored_in_pcap

NR_GNB = "MRBTS-50449"
GNB_ID = 0
TCPDUMP_FILTER = "(nr-rrc.p_Max==29)&&(nr-rrc.ul_FullPowerTransmission_r16==1)"
BIP_FILTER_HIGH_ATT = "(UlData_puschReceiveReqGrant_t.codebookIndex==2)&&(UlData_puschReceiveReqGrant_t.numOfLayers==1)"
BIP_FILTER_LOW_ATT = "(UlData_puschReceiveReqGrant_t.codebookIndex==0)&&(UlData_puschReceiveReqGrant_t.numOfLayers==2)"
TCPDUMP_FILE = "pwr_mod.pcap"

HIGH_ATTENUATION = 20
LOW_ATTENUATION = 0


class ResCni91473(CommonSuite):

    def __init__(self):
        super(ResCni91473, self).__init__()
        self.feature = "CNI91473"
        self.attenuator = Attenuator()
        self.bts_config = BtsConfig()
        self.startup_manager = StartupManager()
        self.ue = Ue(MEDIATEK, ue_id=1)
        self.syslog = SyslogCollector()
        self.bts_faults = BtsFaults()
        self.bts_snapshot = BtsSnapshot()
        self.tcpdump_file = None
        self.newest_bip_file = None
        self.data_name = "CNI91473_UL"
        self._bip_collector = BipCollector()
        self._tcpdump_collector = TcpdumpCollector()

    def prepare_bts_for_testing(self):
        self.startup_manager.confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation()
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, NR_GNB)
        self.bts_config.perform_full_commissioning(scf_file)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.make_sure_mcshark_plugin_exists()

    def prepare_default_configuration(self):
        self._prepare_ue()
        self.ue.detach()
        self.syslog.start_btslog_on_local_machine()

    def make_sure_logs_collection_and_traffic_stopped_if_test_fails(self):
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self._tcpdump_collector.stop_tcpdump_collection()
            self._bip_collector.stop_bip_trace_on_gnb()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.ue.stop_uplink_transmission(data_name=self.data_name)
        self.ue.detach()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.bts_faults.log_active_faults()

    def cleanup_the_setup_and_collect_logs_if_the_suite_fails(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()
        self.bts_faults.log_active_faults()
        self.bts_faults.log_historical_faults()

    def set_attenuation_for_ru(self):
        self.attenuator.set_ports_attenuation(HIGH_ATTENUATION)

    def start_tcpdump_capturing_on_gnb(self):
        self._tcpdump_collector.start_tcpdump_collection()

    def attach_ue(self):
        self.ue.attempt_to_attach_several_times()

    def tcpdump_capturing_is_stopped_and_downloaded_from_gnb(self):
        self.tcpdump_file = self._tcpdump_collector.stop_and_download_tcpdump_from_gnb(TCPDUMP_FILE)

    def expected_power_mod_log_is_stored_in_pcap(self):
        expected_log_is_stored_in_pcap(self.tcpdump_file, TCPDUMP_FILTER)

    def ue_throughput_started(self):
        transmission_time = 60 * 10
        self.ue.start_tcp_uplink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                   data_name=self.data_name)

    def collect_bip_logs_on_gnb(self):
        pcap_files = self._bip_collector.collect_bip_logs_on_gnb()
        assert pcap_files, "Bip logs not collected correctly from bts."
        self.newest_bip_file = pcap_files[-1]  # Lucky guess, expected logs should be in every file, but we only need to
        # find it once

    def check_bip_logs_for_high_attenuation(self):
        expected_log_is_stored_in_pcap(self.newest_bip_file, BIP_FILTER_HIGH_ATT)

    def check_bip_logs_for_low_attenuation(self):
        expected_log_is_stored_in_pcap(self.newest_bip_file, BIP_FILTER_LOW_ATT)

    def change_full_power_mode(self):
        self.attenuator.set_ports_attenuation(LOW_ATTENUATION)

    def _prepare_ue(self):
        try:
            self.ue.prepare_ue()
        except AssertionError as not_prepared_ue_error:
            Logger.warning(f"{not_prepared_ue_error} - UE will be restarted with adb and checked again")
            self.ue.restart_ue()
            self.ue.prepare_ue()
