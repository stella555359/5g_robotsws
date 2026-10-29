from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputChecker import TputChecker
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import GALAXY_S21_ULTRA
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData

MAX_10MHZ_TPUT = 80
MAX_5MHZ_TPUT = 40
MAX_UL_5MHZ_TPUT = 10
SLOTS_UE_DRX_ACTIVE = "M55308C11001"
SLOTS_UE_DRX_SLEEP = "M55308C11002"
NR_CELL_ID = 5


class Res772(object):

    def __init__(self):
        self.feature = "5GC000772"
        self.syslog = SyslogCollector()
        self.bts_faults = BtsFaults()
        self.bts_pm = BtsPmCounters()
        self.bts_config = BtsConfig()
        self.bts_startup = StartupManager()
        self.bts_snapshot = BtsSnapshot()
        self.ue1 = Ue(GALAXY_S21_ULTRA, ue_id=1)
        self.ue2 = Ue(GALAXY_S21_ULTRA, ue_id=2)
        self.tput = TputChecker()
        self.pm_counters = {}
        self.transfer_end_time = TimeStamp.unix_timestamp
        self.ue2_transfer_end_time = TimeStamp.unix_timestamp

    @staticmethod
    def update_swconfig_for_syslog_flags():
        syslog_flags = ["0x420000=1", "0x10041=2", "0x590072=1", "0x41001b=1"]
        Swconfig().update_swconfig_flags(syslog_flags)

    def prepare_environment_and_start_logging_for_772_feature(self):
        self.ue1.prepare_ue()
        self.ue2.prepare_ue()
        self.syslog.start_btslog_on_local_machine()

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
        Rfrl.common_step_trigger()
        self.ue1.detach()
        self.ue2.detach()
        self.ue1.try_to_get_and_remove_traffic_log_files()
        self.ue2.try_to_get_and_remove_traffic_log_files()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.bts_faults.log_active_faults()

    def cleanup_environment_collect_snapshot_if_suite_fails_and_block_the_site(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()
        BtsOam().make_sure_gnb_site_is_blocked()

    def gnb_is_up_and_running(self):
        self.bts_startup.manage_commissioned_bts_to_reach_on_air_state()

    def feature_flag_actcdrx_is_set_to_true_with_drx_profile_configured_cell_setup_in_the_scf(self,
                                                                                              bandwidth,
                                                                                              inactivity):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, bandwidth, inactivity)
        self.bts_config.perform_full_commissioning(scf_file)

    def data_traffic_in_dl_for_the_ue_is_launched_with_maximum_throughput(self):
        transmission_time = 120
        self.ue1.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=MAX_10MHZ_TPUT,
                                                      data_name="DL")
        self.transfer_end_time = TimeStamp().unix_timestamp + transmission_time
        self._wait_for_first_ue_downlink_transfer_end()

    def drx_configuration_is_triggered_for_the_ue_after_successful_setup_of_the_data_bearer(self):
        self._confirm_first_ue_configuration(duration=10)

    def drx_configuration_is_kept_for_the_ue_after_online_modification(self):
        self._confirm_first_ue_configuration(duration=3)
        allocated_cdrx_lines = self.syslog.get_all_logs_containing_text_from_syslog_files("Allocated defaultDrx")
        nr_of_allocations = allocated_cdrx_lines.count("Allocated defaultDrx")
        assert nr_of_allocations == 1, \
            "Unexpected number={} of DRX allocations for first UE after online modification".format(nr_of_allocations)

    def _confirm_first_ue_configuration(self, duration):
        drx_long_cycle_lines = self.syslog.get_all_logs_containing_text_from_syslog_files("drxLongCycle")
        assert "drxLongCycle" in drx_long_cycle_lines, \
            "drxLongCycle configuration missing in the syslog"
        drx_slot_lines = self.syslog.get_all_logs_containing_text_from_syslog_files("drxSlotDuration")
        assert "drxSlotDuration:{}".format(duration) in drx_slot_lines, \
            "Some DRX parameters may not be set correctly in BTS (drxOnDuration)"
        allocated_cdrx_lines = self.syslog.get_all_logs_containing_text_from_syslog_files("Allocated defaultDrx")
        assert "Allocated defaultDrx" in allocated_cdrx_lines, \
            "DRX configuration may not be configured correctly for the UE"

    def the_configured_data_rate_is_reached_in_dl(self):
        self.tput.check_downlink_tcp_throughput(ue_id=1, required_tput=MAX_10MHZ_TPUT,
                                                deviation=20, analyze_entries=100, data_name="DL")

    def ue_supporting_long_drx_functionality_is_attached(self):
        self.ue1.attach()

    def bts_pm_counters_are_collected(self):
        self.bts_pm.wait_for_new_pm_counters_measurement_interval_data()
        self.pm_counters = self.bts_pm.get_raw_pm_counters([SLOTS_UE_DRX_ACTIVE, SLOTS_UE_DRX_SLEEP])
        Logger.debug("Raw DRX active PM counters: {}".format(self.pm_counters))

    def pm_counter_slots_ue_drx_active_is_updated(self):
        self.bts_pm.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(
            raw_pm_data=self.pm_counters, counter_id=SLOTS_UE_DRX_ACTIVE, cell_id=NR_CELL_ID)

    def pm_counter_slots_ue_drx_sleep_is_updated(self):
        self.bts_pm.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(
            raw_pm_data=self.pm_counters, counter_id=SLOTS_UE_DRX_SLEEP, cell_id=NR_CELL_ID)

    def data_radio_bearer_for_ue_is_set_up(self):
        transmission_time = 60
        self.ue1.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=MAX_5MHZ_TPUT,
                                                      data_name="DL")
        self.ue1.start_tcp_uplink_data_transmission(duration=transmission_time,
                                                    traffic_mb=MAX_UL_5MHZ_TPUT, data_name="UL")
        self.transfer_end_time = TimeStamp().unix_timestamp + transmission_time
        self._wait_for_first_ue_downlink_transfer_end()
        self.ue1.stop_uplink_transmission(data_name="UL")

    def the_configured_data_rate_is_reached_in_ul_and_dl(self):
        self.tput.check_uplink_tcp_throughput(ue_id=1, required_tput=MAX_UL_5MHZ_TPUT,
                                              deviation=10, analyze_entries=50, data_name="UL")
        self.tput.check_downlink_tcp_throughput(ue_id=1, required_tput=MAX_5MHZ_TPUT,
                                                deviation=10, analyze_entries=50, data_name="DL")

    def data_traffic_in_dl_for_the_ue_is_launched(self):
        first_ue_transmission_time = 180
        self.ue1.start_tcp_downlink_data_transmission(duration=first_ue_transmission_time, traffic_mb=MAX_5MHZ_TPUT,
                                                      data_name="DL")
        self.transfer_end_time = TimeStamp().unix_timestamp + first_ue_transmission_time

    def drx_profile_is_modified_online_by_changing_the_value_of_drxondurationtimer_from_3ms_to_10ms(self):
        delta_old_release = """[{"distName": "MRBTS-50441/NRBTS-50441/NRCELL-5", "operation": "update", "parameters": [
        {"parameterName": "drxProfile1",
         "value": [ {"drxInactivityTimer": "40ms", "drxLongCycle":"40ms", "drxOnDurationTimer":"10ms",
                     "drxRetransTimerDl":"16slot", "drxRetransTimerUl":"16slot"}], "operation": "update"}]}]"""
        delta_new_release = """[{"distName": "MRBTS-50441/NRBTS-50441/NRCELL-5", "operation": "update", "parameters": [
        {"parameterName": "drxProfile1",
         "value": [ {"drxHarqRttTimerDl":"0symbols", "drxHarqRttTimerUl":"0symbols", "drxInactivityTimer": "40ms",
         "drxLongCycle":"40ms", "drxOnDurationTimer":"10ms", "drxRetransTimerDl":"16slot",
          "drxRetransTimerUl":"16slot"}], "operation": "update"}]}]"""
        support_old_drx_delta = "23R"
        if support_old_drx_delta in TestEnvData.STREAM_SW:
            self.bts_config.perform_delta_commissioning(delta_old_release)
        else:
            self.bts_config.perform_delta_commissioning(delta_new_release)

    def another_ue_supporting_long_drx_functionality_is_attached(self):
        try:
            self.ue2.attach()
        except AssertionError:
            Logger.warning("UE2 was not attached in the first attempt, trying again")
            ue2_attach_timeout = 120
            self.transfer_end_time += ue2_attach_timeout
            self.ue2.detach()
            self.ue2.attach()

    def data_radio_bearer_for_the_second_ue_is_set_up(self):
        second_ue_transmission_time = 60
        self.ue2.start_tcp_downlink_data_transmission(duration=second_ue_transmission_time, traffic_mb=MAX_5MHZ_TPUT,
                                                      data_name="DL")
        self.ue2_transfer_end_time = TimeStamp().unix_timestamp + second_ue_transmission_time

    def the_second_ue_is_attached_and_configured_with_updated_cdrx_profile(self):
        time_for_iperf_log_to_be_updated = 3
        TimeStamp.wait_for_the_unix_timestamp(self.ue2_transfer_end_time + time_for_iperf_log_to_be_updated)
        self.ue2.stop_downlink_transmission(data_name="DL")
        self.ue2.detach()
        nr_of_transferring_ues = 2
        self.tput.check_downlink_tcp_throughput(ue_id=2, required_tput=MAX_5MHZ_TPUT/nr_of_transferring_ues,
                                                deviation=35, analyze_entries=50, data_name="DL")
        self._check_second_ue_logs_for_drx_configuration()

    def the_first_ue_is_configured_with_the_initial_drx_profile_and_keeps_the_profile_even_after_modification(self):
        self._wait_for_first_ue_downlink_transfer_end()
        time_after_ue2_detached = 20
        self.tput.check_downlink_tcp_throughput(ue_id=1, required_tput=MAX_5MHZ_TPUT,
                                                deviation=20, analyze_entries=time_after_ue2_detached, data_name="DL")
        self._check_fist_ue_logs_for_drx_configuration()

    def _wait_for_first_ue_downlink_transfer_end(self):
        time_for_iperf_log_to_be_updated = 10
        TimeStamp.wait_for_the_unix_timestamp(self.transfer_end_time + time_for_iperf_log_to_be_updated)
        self.ue1.stop_downlink_transmission(data_name="DL")
        self.ue1.detach()

    def _check_fist_ue_logs_for_drx_configuration(self):
        first_ue_drx_duration_timer = "drxSlotDuration:3"
        drx_duration_log = self.syslog.get_all_logs_containing_text_from_syslog_files("drxSlotDuration")
        assert first_ue_drx_duration_timer in drx_duration_log, \
            "First UE has not been configured with DRX profile parameters before change"
        nr_of_ue_configurations = drx_duration_log.count(first_ue_drx_duration_timer)
        assert nr_of_ue_configurations == 1, \
            "First UE has been different number () than once".format(nr_of_ue_configurations)

    def _check_second_ue_logs_for_drx_configuration(self):
        second_ue_drx_duration_timer = "drxSlotDuration:10"
        drx_slot_lines = self.syslog.get_all_logs_containing_text_from_syslog_files("drxSlotDuration")
        assert second_ue_drx_duration_timer in drx_slot_lines, \
            "Second UE has not been configured with DRX profile parameters before change"
        assert drx_slot_lines.count(second_ue_drx_duration_timer) > 0, \
            "Second UE was not configured (value=0) with drxSlotDuration:10"
