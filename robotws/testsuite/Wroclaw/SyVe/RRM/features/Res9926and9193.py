from datetime import datetime
from enum import Enum
from time import sleep

from taf.hw.mcs import mcs

from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults, CELL_BLOCKED_FAULT_ID
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters, PM_COLLECTION_SECONDS, \
    LEGACY_CELL_COUNTER_PATH_STREAM_SW
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.NetworkInterfaceManager import NetworkInterfaceManager
from testsuite.Wroclaw.SyVe.RRM.resources.Pdu import Pdu
from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.TTITraces import TTITraces
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import UTE_UE
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector

PRB_AVAIL_PDSCH = "M55308C10003"
PRB_AVAIL_PDSCH_SLICES = "M55308C10007"

DL_PRB_USED_DATA_PMQAP = "M55363C00001"
PRB_USED_PDSCH_NSA_PLMN = "M55338C01001"

DL_PRB_USED_DATA_NRG = "M55910C00001"

NO_PAIRED_UE_DL = "M55308C34012"
TWO_PAIRED_UES_DL = "M55308C34013"
THREE_PAIRED_UES_DL = "M55308C34014"
FOUR_PAIRED_UES_DL = "M55308C34015"

DL_2LAYER = "M55308C34005"
DL_3LAYER = "M55308C34006"
DL_4LAYER = "M55308C34007"
DL_5LAYER = "M55308C34008"
DL_6LAYER = "M55308C34009"
DL_7LAYER = "M55308C34010"
DL_8LAYER = "M55308C34011"
DL_9LAYER = "M55308C34016"
DL_10LAYER = "M55308C34017"
DL_11LAYER = "M55308C34018"
DL_12LAYER = "M55308C34019"
DL_13LAYER = "M55308C34020"
DL_14LAYER = "M55308C34021"
DL_15LAYER = "M55308C34022"
DL_16LAYER = "M55308C34023"

PAIRED_UES_COUNTERS = [NO_PAIRED_UE_DL, TWO_PAIRED_UES_DL, THREE_PAIRED_UES_DL, FOUR_PAIRED_UES_DL]
PRB_PER_LAYERS_COUNTERS = [DL_2LAYER, DL_3LAYER, DL_4LAYER, DL_5LAYER, DL_6LAYER, DL_7LAYER, DL_8LAYER, DL_9LAYER,
                           DL_10LAYER, DL_11LAYER, DL_12LAYER, DL_13LAYER, DL_14LAYER, DL_15LAYER, DL_16LAYER]


COMMON_PATH = "CELLS/NRCELL-{}" if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW\
    else (f"MRBTS-{Env.GNBS[0].global_bts_id}/NRBTS-{Env.GNBS[0].global_bts_id}/" + "NRCELL-{}")

PMQAP_COUNTERS = [PRB_AVAIL_PDSCH, DL_PRB_USED_DATA_PMQAP]
PLMN_COUNTERS = [PRB_AVAIL_PDSCH_SLICES, PRB_USED_PDSCH_NSA_PLMN] + PMQAP_COUNTERS
NRG_SPID_COUNTERS = [PRB_AVAIL_PDSCH_SLICES, DL_PRB_USED_DATA_NRG] + PMQAP_COUNTERS

MCS_FILE = "testsuite/Wroclaw/SyVe/RRM/CB009926/resources/MCS/4UE_DL_paired_16DL8UL.csv"

SHIELDBOX_PDU_ID = 2

CELL16DL8UL = 501
CELL8DL8UL = 502

UEPC_SSH_ADDR = "10.44.234.219"
PHASE_SHIFTER_ADDR = "10.44.234.46"
PHASE_SHIFTER_VENDOR = "TOPYOUNG"
PHASE_SHIFTER_MODEL = "MCS2350A2-128B16-A4"


class Environment:
    def __init__(self):
        self.gnb_1_name = f"MRBTS-{Env.GNBS[0].instance_id}"
        self.gnb_1_id = 0
        self.ssh_connection_gnb_local = Env.GNB_SSH_CONNECTION_DETAILS
        self.bts_admin = BtsAdminApi()
        self.bts_counters = BtsPmCounters()
        self.bts_startup = StartupManager()
        self.syslog = SyslogCollector()
        self.delta = ScfPathFinder()
        self.startup_manager = StartupManager()
        self.bts_config = BtsConfig()
        self.bts_snapshot = BtsSnapshot()
        self.bts_faults = BtsFaults()
        self.bts_oam = BtsOam()  # TODO: Think if bts_oam should be in test resource.
        self.mcs = mcs()

    def prepare_suite(self, feature):
        self._update_swconfig_for_syslog_flags()
        self.set_mcs()
        self._prepare_local_gnb(feature)
        self.bts_faults.add_active_fault_to_allowed_list(CELL_BLOCKED_FAULT_ID)
        self.bts_oam.make_sure_gnb_cell_is_blocked(CELL8DL8UL)
        NetworkInterfaceManager(UEPC_SSH_ADDR).turn_off_all_interfaces()

    def suite_teardown(self):
        self._make_sure_all_cells_are_unblocked()
        self._collect_snapshots_if_suite_fails_and_log_active_faults()

    def prepare_environment_and_start_logging(self):
        self.syslog.start_btslog_on_local_machine()

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        Rfrl.common_step_trigger()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.bts_faults.log_active_faults()
        self.bts_faults.log_historical_faults()

    def commission_bts_if_the_test_failed(self, feature):
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self.commission_gnb(feature, self.gnb_1_id, self.gnb_1_name)
            self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def bts_configuration_update(self, feature, delta):
        Logger.info(f"Updating bts configuration with delta: {delta}")
        self.bts_config.perform_delta_commissioning(
            self.delta.get_delta_path_for_feature(feature, delta))
        self.bts_admin.wait_for_admin_connection_possibility(interval=90)
        self.startup_manager.wait_for_cell_on_air(CELL16DL8UL)

    def set_mcs(self):
        try:
            self.mcs.setup(alias="Test", vendor=PHASE_SHIFTER_VENDOR, model=PHASE_SHIFTER_MODEL,
                           server_ip=PHASE_SHIFTER_ADDR, server_port=28888, row_num=128, column_num=16)
            with open(MCS_FILE) as mcs_conf:
                for line in mcs_conf.readlines()[1:]:
                    params = line.strip().strip(",").split(",")
                    output_port = params[0][1:]
                    for index, elem in enumerate(params[1:], 1):
                        att, phase = elem.split("|")
                        self.mcs.set_attenuation(float(att), index, output_port=int(output_port), mcs_device="Test")
                        self.mcs.set_phase(float(phase), index, output_port=int(output_port), mcs_device="Test")
        finally:
            self.mcs.teardown(mcs_device="Test")

    def _collect_snapshots_if_suite_fails_and_log_active_faults(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()
        self.bts_faults.log_active_faults()
        self.bts_faults.log_historical_faults()

    def _prepare_local_gnb(self, feature):
        self.startup_manager.confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation()
        self._commission_base_feature_test_line(feature)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    @staticmethod
    def _update_swconfig_for_syslog_flags():
        syslog_flags = ["0x420000=1", "0x10041=2", "0x590072=1", "0x41001b=1"]
        Swconfig().update_swconfig_flags(syslog_flags)

    def _commission_base_feature_test_line(self, feature):
        self.bts_config.perform_full_commissioning(self.delta.get_scf_path_for_feature(feature, self.gnb_1_name))

    def commission_gnb(self, feature, bts_id, *scf_params):
        scf_file = ScfPathFinder().get_scf_path_for_feature(feature, *scf_params)
        self.bts_config.perform_full_commissioning(scf_file, bts_id)

    def _make_sure_all_cells_are_unblocked(self):
        self.bts_oam.make_sure_gnb_cell_is_unblocked(CELL16DL8UL)
        self.bts_oam.make_sure_gnb_cell_is_unblocked(CELL8DL8UL)

    def switch_blocked_cells(self):
        self.bts_oam.make_sure_gnb_cell_is_blocked(CELL16DL8UL)
        self.bts_oam.make_sure_gnb_cell_is_unblocked(CELL8DL8UL)

    def switch_back_blocked_cells(self):
        self.bts_oam.make_sure_gnb_cell_is_unblocked(CELL16DL8UL)
        self.bts_oam.make_sure_gnb_cell_is_blocked(CELL8DL8UL)


class TrafficTypes(Enum):
    TX = 1
    RX = 2


class Res9926and9193:

    def __init__(self):
        self.bts_configuration = Environment()
        self.ue_1 = Ue(type_=UTE_UE, ue_id=1, capabilities="REAL_ANDROID_UE_1")
        self.ue_2 = Ue(type_=UTE_UE, ue_id=2, capabilities="REAL_ANDROID_UE_2")
        self.ue_3 = Ue(type_=UTE_UE, ue_id=3, capabilities="REAL_ANDROID_UE_3")
        self.ue_4 = Ue(type_=UTE_UE, ue_id=4, capabilities="REAL_ANDROID_UE_4")
        self.active_ues = None
        self.feature = None
        self.bts_admin = BtsAdminApi()
        self.bts_counters = BtsPmCounters()
        self.tti = TTITraces()
        self.traffic_direction = None

    def prepare_suite(self, feature):
        self.feature = feature
        Logger.info(feature)
        self.bts_configuration.prepare_suite(self.feature)
        self.tti.download_gnb_logs_tool()

    def prepare_test(self, feature):
        self.feature = feature
        self._prepare_ues()
        self.bts_configuration.prepare_environment_and_start_logging()

    def teardown_suite(self):
        self.bts_configuration.suite_teardown()
        self.tti.remove_gnb_logs_tool()

    def teardown_test(self):
        self.stop_traffic_on_all_ues()
        self._detach_ue_remove_traffic_files_and_cleanup_logs()
        self._preserve_tti_traces_if_test_failed()
        self.bts_configuration.commission_bts_if_the_test_failed(self.feature)

    def collect_tti_traces(self):
        self.tti.collect_tti_traces()

    def remove_tti_traces(self):
        self.tti.remove_tti_traces()

    def check_values_on_4_ues_no_rank_downgrade(self):
        self.tti.unpack_tti_traces(['type', 'lcId', 'numOfLayers', 'muStatus', 'mcsTable', 'tbSize'],
                                   ["dlFdSchedData[]"])
        self.tti.content = self.tti.get_filtered_data("lcId", [4])
        controlled_params = {"RANK4": self.tti.get_percentage_of_values("numOfLayers", "RANK4"),
                             "MUPAIR": self.tti.get_percentage_of_values("muStatus", "MUPAIR"),
                             "QAM256": self.tti.get_percentage_of_values("mcsTable", "QAM256")}
        for key, item in controlled_params.items():
            assert item > 0.50, f"value {key} of param occured only in {item * 100}% of requested lines. Expected 50%."
        # TODO:
        # self.dl_pm_counters_are_collected()
        # self._verify_ues_paired_counters(COMMON_PATH.format(CELL16DL8UL), paired_ues=4)
        # self._verify_layers_counters(COMMON_PATH.format(CELL16DL8UL), layers=16)

    def check_values_on_basic_case(self):
        self.tti.unpack_tti_traces(['type', 'slot', 'SLIV'], ["dlFdSchedData"])
        self.tti.content = self.tti.get_filtered_data("slot", [3, 13])
        controlled_params = {"57": self.tti.get_percentage_of_values("SLIV", 57)}
        for key, item in controlled_params.items():
            assert item > 0.50, f"value {key} of param occured only in {item * 100}% of requested lines. Expected 50%."

    def check_values_on_two_ues_with_non_gbr(self):
        self.tti.unpack_tti_traces(['type', 'numOfLayers', 'ulMuStatus', 'mcsTable'],
                                   ["ulFdSchedData", "ulFdSchedData[]"])
        controlled_params = {"RANK2": self.tti.get_percentage_of_values("numOfLayers", "RANK2"),
                             # "MUPAIRED_TAPERING": self.tti.get_percentage_of_values("ulMuStatus",
                             #                                                        "MUPAIRED_TAPERING"),
                             "QAM256": self.tti.get_percentage_of_values("mcsTable", "QAM256")}
        for key, item in controlled_params.items():
            assert item > 0.50, f"value {key} of param occured only in {item * 100}% of requested lines. Expected 50%."

    def check_values_for_interworking_with_cb008360(self):
        self.tti.unpack_tti_traces(['type', 'numOfLayers', 'ulMuStatus', 'mcsTable'],
                                   ["ulFdSchedData", "ulFdSchedData[]"])
        controlled_params = {"RANK2": self.tti.get_percentage_of_values("numOfLayers", "RANK2"),
                             # "MUPAIRED_TAPERING": self.tti.get_percentage_of_values("ulMuStatus",
                             #                                                        "MUPAIRED_TAPERING"),
                             "QAM256": self.tti.get_percentage_of_values("mcsTable", "QAM256")}
        for key, item in controlled_params.items():
            assert item > 0.50, f"value {key} of param occured only in {item * 100}% of requested lines. Expected 50%."

    def check_values_for_time_offset_reconfiguration(self):
        self.tti.unpack_tti_traces(['type', 'physCellId'])
        controlled_params = {"Cell: 501": self.tti.get_percentage_of_values("physCellId", 501)}
        for key, item in controlled_params.items():
            assert item > 0.50, f"value {key} of param occured only in {item * 100}% of requested lines. Expected 50%."

    def prepare_four_active_ues(self):
        self.active_ues = [self.ue_1, self.ue_2, self.ue_3, self.ue_4]

    def prepare_three_active_ues(self):
        self.active_ues = [self.ue_1, self.ue_2, self.ue_3]

    def prepare_two_active_ues(self):
        self.active_ues = [self.ue_1, self.ue_2]

    def prepare_one_active_ue(self):
        self.active_ues = [self.ue_1]

    def prepare_custom_active_ues(self, *ues):
        self.active_ues = ues

    def multiple_ues_are_detached_from_cell(self):
        self._detach_all_ues()

    def multiple_ues_are_attached_to_the_cell(self):
        self._attach_all_ues()

    def data_tx_started_for_the_all_ues(self):
        transmission_time = self._get_transmission_time()
        self._start_dl_tput_for_all_ues(transmission_time)

    def data_rx_started_for_the_all_ues(self):
        transmission_time = self._get_transmission_time()
        self._start_ul_tput_for_all_ues(transmission_time)

    def activate_first_offset(self):
        Logger.info(self.feature)
        self.bts_configuration.bts_configuration_update(self.feature, "activate_set_1")

    def activate_second_offset(self):
        self.bts_configuration.bts_configuration_update(self.feature, "activate_set_2")

    def activate_third_offset(self):
        self.bts_configuration.bts_configuration_update(self.feature, "activate_set_3")

    def return_to_base_config(self):
        self.bts_configuration.bts_configuration_update(self.feature, "return_to_basic")

    def dl_pm_counters_are_collected(self):
        self._wait_and_collect_counters(PAIRED_UES_COUNTERS + PRB_PER_LAYERS_COUNTERS, "PAIRED UES AND LAYERS")

    def switch_blocked_cells(self):
        self.bts_configuration.switch_blocked_cells()

    def switch_back_blocked_cells(self):
        self.bts_configuration.switch_back_blocked_cells()

    def _verify_ues_paired_counters(self, common_path, paired_ues):
        ues_paired_counters = self._extract_ues_paired_counters(common_path)
        self._check_ues_paired(ues_paired_counters, paired_ues)

    def _extract_ues_paired_counters(self, common_path):
        paired_counters = []
        for item in PAIRED_UES_COUNTERS:
            counter_path = f"{common_path}{item}"
            wanted_counter = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
                raw_pm_data=self.active_raw_counters, path=counter_path, t_stamp=self.counter_timestamp)
            paired_counters.append(wanted_counter)
        return paired_counters

    @staticmethod
    def _check_ues_paired(counters, paired_ues=1):
        all_prbs = sum(counters)
        assert counters[paired_ues - 1] / all_prbs * 100 > 90, \
            f"Expected {paired_ues} paired ues in 90% of cases.\n" \
            f"Ues are paired as expected in {counters[paired_ues - 1] / all_prbs * 100}% " \
            f"of all throughput."

    def _verify_layers_counters(self, common_path, layers):
        layers_counters = self._extract_layer_counters(common_path)
        self._check_layers(layers_counters, layers)

    def _extract_layer_counters(self, common_path):
        layers_counters = []
        for item in PRB_PER_LAYERS_COUNTERS:
            counter_path = f"{common_path}{item}"
            wanted_counter = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
                raw_pm_data=self.active_raw_counters, path=counter_path, t_stamp=self.counter_timestamp)
            layers_counters.append(wanted_counter)
        return layers_counters

    @staticmethod
    def _check_layers(counters, layers=2):
        all_prbs = sum(counters)
        assert counters[layers - 2] / all_prbs * 100 > 90, \
            f"Expected {layers} layers in 90% of cases.\n" \
            f"Number of layers as expected in {counters[layers - 2] / all_prbs * 100}% " \
            f"of all throughput."

    def _get_transmission_time(self):
        transmission_time = 1200
        self.data_name = "AVQL_UE_{}"
        return transmission_time

    def _prepare_ues(self):
        try:
            self._check_all_ues_are_prepared()
        except AssertionError as not_prepared_ue_error:
            Logger.warning(f"{not_prepared_ue_error} - UEs will be restarted with adb and checked again")
            self._restart_all_ues()
            self._check_all_ues_are_prepared()

    def _restart_all_ues(self):
        Logger.info("Restarting all UEs with adb reboot")
        self._reboot_all_ues()

    def _reboot_all_ues(self):
        for ue in self.active_ues:
            ue.restart_ue()

    def _check_all_ues_are_prepared(self):
        for ue in self.active_ues:
            ue.prepare_ue()

    def _attach_all_ues(self):
        for ue in self.active_ues:
            ue.attempt_to_attach_several_times()

    def _start_dl_tput_for_all_ues(self, transmission_time):
        self.traffic_direction = TrafficTypes.TX
        for index, ue in enumerate(self.active_ues):
            ue.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=1550,
                                                    data_name=self.data_name.format(index))

    def stop_traffic_on_all_ues(self):
        for index, ue in enumerate(self.active_ues):
            if self.traffic_direction == TrafficTypes.TX:
                ue.stop_downlink_transmission(data_name=self.data_name.format(index))
            elif self.traffic_direction == TrafficTypes.RX:
                ue.stop_uplink_transmission(data_name=self.data_name.format(index))
        self.traffic_direction = None

    def _start_ul_tput_for_all_ues(self, transmission_time):
        self.traffic_direction = TrafficTypes.RX
        for index, ue in enumerate(self.active_ues):
            ue.start_tcp_uplink_data_transmission(duration=transmission_time, traffic_mb=250,
                                                  data_name=self.data_name.format(index))

    def _detach_ue_remove_traffic_files_and_cleanup_logs(self):
        self._detach_all_ues()
        self.bts_configuration.cleanup_the_setup_and_collect_logs_if_the_test_fails()

    def _detach_all_ues(self):
        for ue in self.active_ues:
            ue.detach()

    def _preserve_tti_traces_if_test_failed(self):
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self.tti.move_tti_traces_to(Env().test_log_dir)
        self.tti.remove_tti_traces()

    def _wait_for_next_pm_counters_measurements(self, action):
        Logger.info(f"Waiting {PM_COLLECTION_SECONDS}sec for PM Counters to be generated by UEs throughput "
                    f"after *{action.upper()}* online reconfiguration")
        sleep(PM_COLLECTION_SECONDS)
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()

    @staticmethod
    def _get_latest_pm_counters_period_epoch():
        latest_pm_counters_epoch = (BtsOs().get_epoch() - PM_COLLECTION_SECONDS) \
                                   // PM_COLLECTION_SECONDS * PM_COLLECTION_SECONDS
        Logger.info(f"Timestamp for PM Counters collecting: {datetime.fromtimestamp(latest_pm_counters_epoch)}"
                    f" Epoch: {latest_pm_counters_epoch}")
        return latest_pm_counters_epoch

    def _wait_and_collect_counters(self, counters, msg, gnb_id=0):
        self._wait_for_next_pm_counters_measurements(msg)
        self.active_raw_counters = self.bts_counters.get_raw_pm_counters(counters, gnb_id=gnb_id)
        self.counter_timestamp = self._get_latest_pm_counters_period_epoch()
