from taf.internal.sbts.admin.exceptions import AdminApiConnectionClosedException, AdminApiProcedureFailureException

from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import CELL_BLOCKED_FAULT_ID
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters, PM_COLLECTION_SECONDS, \
    LEGACY_CELL_COUNTER_PATH_STREAM_SW
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import ASKEY_AT_ADB
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Pdu import Pdu as Pdu
from testsuite.Wroclaw.SyVe.RRM.resources.exceptions import DeviceHostnameNotFound
from time import sleep
from datetime import datetime

LOW_BUFFER_TRAFFIC_MB = 1

PRB_AVAIL_PDSCH = "M55308C10003"
PRB_AVAIL_PDSCH_SLICES = "M55308C10007"
PRB_USED_PDSCH_SLICE = "M55359C00000"
DL_PRB_USED_DATA_NRG = "M55910C00001"
PRB_USED_PDSCH_PLMN = "M55338C00001"
PRB_PDSCH_UTIL_RATIO_SLICE_MAX = "M55359C00001"
DL_PRB_UTIL_SLOT_MAX_NRG = "M55910C00002"
PRB_AVAIL_PDSCH_NSA_PLMN = "M55338C01000"
PRB_USED_PDSCH_NSA_PLMN = "M55338C01001"
UL_PRB_USED_DATA_NRG = "M55910C00003"
UL_PRB_UTIL_SLOT_MAX_NRG = "M55910C00004"
UL_PRB_AVAIL_SAS = "M55308C10012"
UL_PRB_USED_DATA_PMQAP = "M55363C00002"
UL_PRB_UTIL_SLOT_MAX_PMQAP = "M55363C00004"
DL_PRB_AVAIL_SAS = "M55308C10013"
UL_PRBB_PMQAP_COUNTERS = [UL_PRB_USED_DATA_PMQAP, UL_PRB_UTIL_SLOT_MAX_PMQAP]
UL_SANSA_SAS_PM_COUNTERS = [UL_PRB_AVAIL_SAS, UL_PRB_USED_DATA_NRG, UL_PRB_UTIL_SLOT_MAX_NRG]
DL_SANSA_SAS_PM_COUNTERS = [DL_PRB_AVAIL_SAS, DL_PRB_USED_DATA_NRG, DL_PRB_UTIL_SLOT_MAX_NRG]
STREAMS_BEFORE_SAS_MIGRATION = ["SBTS23R2", "SBTS23R3", "SBTS23R4", "SBTS24R1"]
SAS_MIGRATION_FIRST_STEP_STREAM = "SBTS24R2"
PER_SLICE_COLLECTED_COUNTERS = [PRB_USED_PDSCH_SLICE, PRB_PDSCH_UTIL_RATIO_SLICE_MAX] \
    if Env.STREAM_SW in STREAMS_BEFORE_SAS_MIGRATION else [DL_PRB_USED_DATA_NRG, DL_PRB_UTIL_SLOT_MAX_NRG]
SA_PM_COUNTERS = [PRB_AVAIL_PDSCH_SLICES] + PER_SLICE_COLLECTED_COUNTERS
NSA_PM_COUNTERS = [PRB_AVAIL_PDSCH_NSA_PLMN, PRB_USED_PDSCH_NSA_PLMN]
PM_COUNTERS_FLAGS = ["miNrCellUtilization", "miNrCellUtilPerPLMN", "miNrSlicingL1Resource", "miNrSlicingCuUp"]
FDD_CELL = 371
FDD = "fdd"
TDD = "tdd"
TDD_CELL = 372
LTE_CELL = 34
SNSAI_1 = "SST-1_SD-13714341"
SNSAI_2 = "SST-1_SD-13714342"
SNSAI_3 = "SST-1_SD-13714343"
SNSAI_4 = "SST-1_SD-13714336"
MCC1 = "540"
MNC1 = "01"
MCC2 = "310"
MNC2 = "260"
BASE_FEATURE = "CB008132"
ASKEY_PDU_PORT = 6


class NetworkSlice(object):

    def __init__(self, snsai, cell_id, mcc, mnc, min_quota, max_quota, in_use):
        self.name = snsai
        self.cell_id = cell_id
        self.mcc = mcc
        self.mnc = mnc
        self.allowed_deviation = 2
        self.in_use = in_use
        self.min_quota = max(0, (min_quota - self.allowed_deviation)) if self.in_use else 0
        self.max_quota = max(0, (max_quota + self.allowed_deviation)) if self.in_use else 0
        self.quotas = [min_quota, max_quota] if self.in_use else [0, 0]

    def __repr__(self):
        slice_info = f"slice: {self.name} for cell {self.cell_id} " \
                     f"with MCC-{self.mcc}{'_' if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW else '/'}" \
                     f"MNC-{self.mnc}"
        quota = f"with the quota: [{self.min_quota}-{self.max_quota}]"
        return f"\nACTIVE {slice_info} {quota}" if self.in_use else f"\nDISABLED {slice_info}"


class Plmn(object):

    def __init__(self, cell_id, mcc, mnc, min_quota, max_quota):
        self.cell_id = cell_id
        self.mcc = mcc
        self.mnc = mnc
        self.allowed_deviation = 2
        self.min_quota = (min_quota - self.allowed_deviation/2)
        self.max_quota = (max_quota + self.allowed_deviation)
        self.quotas = [min_quota, max_quota]

    def __str__(self):
        return f"MCC-{self.mcc}_MNC-{self.mnc}" if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW \
            else f"MCC-{self.mcc}/MNC-{self.mnc}"


class NRResourceGroup(object):

    def __init__(self, cell_id, resource_group_id, min_quota, max_quota, in_use):
        self.in_use = in_use
        self.cell_id = cell_id
        self.allowed_deviation = 2
        self.id = resource_group_id
        self.min_quota = max(0, (min_quota - self.allowed_deviation)) if self.in_use else 0
        self.max_quota = max(0, (max_quota + self.allowed_deviation)) if self.in_use else 0
        self.target_share_min = min_quota
        self.target_share_max = max_quota
        self.quotas = [min_quota, max_quota]
        self.full_buffer = True

    def __str__(self):
        return f"NRRESOURCEGROUP-{self.id} with minQuota:{self.min_quota}%, maxQuota:{self.max_quota}%"

    def set_new_quotas(self, min_quota, max_quota, full_buffer=True):
        self.min_quota = max(0, (min_quota - self.allowed_deviation)) if self.in_use else 0
        self.max_quota = max(0, (max_quota + self.allowed_deviation)) if self.in_use else 0
        self.quotas = [min_quota, max_quota] if self.in_use else [0, 0]
        self.target_share_min = min_quota
        self.target_share_max = max_quota
        self.full_buffer = full_buffer


class SliceSchedulingLib(CommonSuite):
    def __init__(self):
        super(SliceSchedulingLib, self).__init__()
        self.feature = None
        self.enb_id = "MRBTS-40447"
        self.enb_connection_details = Env.LTE_VM_SSH_CONN_DETAILS
        self.bts_counters = BtsPmCounters()
        self.delta = ScfPathFinder()
        self.raw_counters = None
        self.cell_id = None
        self.slices = None
        self.plmns = None
        self.nrrg_groups = None
        self.data_name = None
        self.nsa_data_name = "_NSA_ONLY"
        self.technology = None
        self.is_nsa_available = False
        self.suite_setup_done = False
        self.used_slices = {}
        self.used_slice_ratios = {}
        self.common_eda_tstamp = None
        self.dl_sas = True
        self.ue_slice1 = None
        self.ue_slice3 = None
        self.ue_slice4 = None
        self.ue_nsa_only = None
        self._create_ues()

    def _create_ues(self):
        self.ue_slice1 = Ue(type_=ASKEY_AT_ADB, ue_id=2)
        self.ue_slice3 = Ue(type_=ASKEY_AT_ADB, ue_id=1)
        self.ue_slice4 = Ue(type_=ASKEY_AT_ADB, ue_id=3)
        self.ue_nsa_only = Ue(type_=ASKEY_AT_ADB, ue_id=4)

    @staticmethod
    def switch_on_ues_pdu_port():
        Pdu().switch_on_pdu_port(ASKEY_PDU_PORT)

    @staticmethod
    def switch_off_ues_pdu_port():
        Pdu().switch_off_pdu_port(ASKEY_PDU_PORT)

    def prepare_bts_for_feature_testing(self):
        self.syslog.start_btslog_on_local_machine(name=Env.BTSLOG_5G_SUITE_ALIAS)
        self.bts_faults.add_active_fault_to_allowed_list(CELL_BLOCKED_FAULT_ID)
        self.startup_manager.confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation()
        self.commission_base_feature_test_line()
        self.prepare_enb()
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.syslog.stop_btslog(name=Env.BTSLOG_5G_SUITE_ALIAS)
        self.suite_setup_done = True

    def prepare_bts_for_feature_parity_7134_testing(self):
        self.syslog.start_btslog_on_local_machine(name=Env.BTSLOG_5G_SUITE_ALIAS)
        self.bts_faults.add_active_fault_to_allowed_list(CELL_BLOCKED_FAULT_ID)
        self.startup_manager.confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation()
        self.commission_7134_test_line()
        self.prepare_enb()
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.syslog.stop_btslog(name=Env.BTSLOG_5G_SUITE_ALIAS)
        self.suite_setup_done = True

    def prepare_sa_bts_for_feature_testing(self):
        self.syslog.start_btslog_on_local_machine(name=Env.BTSLOG_5G_SUITE_ALIAS)
        self.bts_faults.add_active_fault_to_allowed_list(CELL_BLOCKED_FAULT_ID)
        self.startup_manager.confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation()
        self.commission_base_feature_test_line()
        try:
            self.make_sure_lte_cell_is_blocked()
        except AdminApiConnectionClosedException as error:
            Logger.warning(f"Blocking LTE cell was not possible. LTE will be updated to the SUT SW.\n"
                           f"Block LTE cell failed due to: {error}")
            self.prepare_enb()
            self.make_sure_lte_cell_is_blocked()
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.syslog.stop_btslog(name=Env.BTSLOG_5G_SUITE_ALIAS)
        self.suite_setup_done = True

    def collect_logs_in_case_of_suite_setup_failure(self):
        if not self.suite_setup_done:
            self.syslog.stop_btslog_and_collect_files_on_local_os(name=Env.BTSLOG_5G_SUITE_ALIAS,
                                                                  target_dir=Env().test_suite_dir)
            Logger.warning("Suite setup has failed, trying to display active faults and collect snapshot")
            BtsAdminApi().wait_for_admin_connection_possibility()
            self.bts_faults.log_active_faults()
            self.bts_faults.log_historical_faults()
            self.collect_snapshot()

    def commission_base_feature_test_line(self):
        self.feature = BASE_FEATURE
        self.bts_config.perform_full_commissioning(ScfPathFinder().get_scf_path_for_feature(self.feature,
                                                                                            self.local_gnb_id))

    def commission_ul_sas_feature_with_nbr_interworking(self):
        self.bts_config.perform_full_commissioning(ScfPathFinder().get_scf_path_for_feature(self.feature,
                                                                                            self.local_gnb_id,
                                                                                            "UL_SAS"))
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def gnb_is_up_and_running_in_sa_nsa_mode_in_fdd_with_ul_and_dl_sas_enabled_with_different_rg_configuration(self):
        self.bts_config.perform_full_commissioning(ScfPathFinder().get_scf_path_for_feature(self.feature,
                                                                                            self.local_gnb_id,
                                                                                            "ULDL"))
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.make_sure_lte_cell_is_blocked()
        self.bts_oam.make_sure_gnb_cell_is_blocked(TDD_CELL)
        self.cell_id = FDD_CELL
        self.technology = FDD

    def commission_7134_test_line(self):
        self.feature = "CB007134"
        self.bts_config.perform_full_commissioning(ScfPathFinder().get_scf_path_for_feature(self.feature,
                                                                                            self.local_gnb_id))

    def prepare_environment_and_start_logging_for_feature(self, feature):
        self.feature = feature
        self._prepare_ues()
        self.syslog.start_btslog_on_local_machine()
        self.startup_manager.wait_for_x2_connected()

    def cleanup_environment_and_stop_logging_for_the_feature(self):
        self._detach_ue_remove_traffic_files_and_cleanup_logs()
        self._make_sure_all_cells_are_unblocked()

    def cleanup_environment_and_stop_logging_for_the_feature_and_restore_base_scf(self):
        self._detach_ue_remove_traffic_files_and_cleanup_logs()
        self.commission_gnb_and_wait_for_bts_to_reach_on_air_state()

    def cleanup_environment_and_stop_logging_for_the_feature_and_restore_base_scf_if_test_fails(self):
        self._detach_ue_remove_traffic_files_and_cleanup_logs()
        self._make_sure_all_cells_are_unblocked()
        self._commission_bts_if_the_test_failed()

    def gnb_is_up_and_running_in_a_sa_mode_in_fdd_with_configured_multiple_slices_and_their_pm_counters(self):
        self._configure_fdd_with_slices()
        self.bts_oam.block_gnb_cell(TDD_CELL)
        self.make_sure_lte_cell_is_blocked()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          self._delta_on_name()))
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature, "fdd_quotas"))

    def gnb_is_up_and_running_in_a_sa_mode_in_tdd_with_configured_multiple_slices_and_their_pm_counters(self):
        self._configure_tdd_with_slices()
        self.bts_oam.block_gnb_cell(FDD_CELL)
        self.make_sure_lte_cell_is_blocked()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          self._delta_on_name()))
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature, "tdd_quotas"))

    def gnb_is_up_and_running_in_a_sa_nsa_mode_in_fdd_with_configured_multiple_slices_and_their_pm_counters(self):
        self.is_nsa_available = True
        self._configure_fdd_with_slices()
        self.plmns = [Plmn(cell_id=self.cell_id, mcc=MCC1, mnc=MNC1, min_quota=5, max_quota=10)]
        self.bts_oam.block_gnb_cell(TDD_CELL)
        self.make_sure_lte_cell_is_unblocked()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          self._delta_on_name()))
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature, "fdd_quotas"))

    def gnb_is_up_and_running_in_a_sa_nsa_mode_in_tdd_with_configured_multiple_slices_and_their_pm_counters(self):
        self.is_nsa_available = True
        self._configure_tdd_with_slices()
        self.plmns = [Plmn(cell_id=self.cell_id, mcc=MCC1, mnc=MNC1, min_quota=5, max_quota=10)]
        # TODO: one NRRG for the NSA UE
        self.bts_oam.block_gnb_cell(FDD_CELL)
        self.make_sure_lte_cell_is_unblocked()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          self._delta_on_name()))
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature, "tdd_quotas"))

    def gnb_is_up_and_running_in_a_sa_nsa_mode_in_tdd_with_uplink_sas_enabled_with_proper_quotas_for_nrrgs(self):
        self.is_nsa_available = True
        self._configure_ul_tdd_nrresource_groups()
        self.bts_oam.block_gnb_cell(FDD_CELL)
        self.make_sure_lte_cell_is_unblocked()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          "enable_uplink_sas"))

    def gnb_is_up_and_running_in_a_sa_mode_in_tdd_with_uplink_sas_and_nbr_activated(self):
        self.is_nsa_available = False
        self._configure_ul_tdd_nrresource_groups_for_nbr_interworking()
        self.bts_oam.block_gnb_cell(FDD_CELL)
        self.make_sure_lte_cell_is_blocked()

    def gnb_is_up_and_running_in_a_nsa_mode_in_fdd_with_configured_multiple_slices_and_their_pm_counters(self):
        self.is_nsa_available = True
        self._configure_fdd_with_plmns()
        self._change_cell_dep_type(FDD, "sansa_to_nsa")
        self.bts_oam.block_gnb_cell(TDD_CELL)
        self.make_sure_lte_cell_is_unblocked()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          self._delta_on_name()))

    def gnb_is_up_and_running_in_a_nsa_mode_in_tdd_with_configured_multiple_slices_and_their_pm_counters(self):
        self.is_nsa_available = True
        self._configure_tdd_with_plmns()
        self._change_cell_dep_type(TDD, "sansa_to_nsa")
        self.bts_oam.block_gnb_cell(FDD_CELL)
        self.make_sure_lte_cell_is_unblocked()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          self._delta_on_name()))

    def gnb_is_up_and_running_in_a_sa_mode_in_fdd_with_configured_for_low_traffic_drbs(self):
        self._configure_fdd_with_slices()
        # TODO : Changes not needed for EDA function
        slice1 = self.slices[0]
        slice3 = self.slices[2]
        slice4 = self.slices[3]
        self.slices[0] = NetworkSlice(snsai=slice1.name, cell_id=slice1.cell_id, mcc=slice1.mcc, mnc=slice1.mnc,
                                      min_quota=0, max_quota=50, in_use=slice1.in_use)
        self.slices[2] = NetworkSlice(snsai=slice3.name, cell_id=slice3.cell_id, mcc=slice3.mcc, mnc=slice3.mnc,
                                      min_quota=0, max_quota=50, in_use=slice3.in_use)
        self.slices[3] = NetworkSlice(snsai=slice4.name, cell_id=slice4.cell_id, mcc=slice4.mcc, mnc=slice4.mnc,
                                      min_quota=0, max_quota=0, in_use=False)
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          self._delta_on_name()))
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature, "eda_quotas"))
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          "slice_weight_factor_on"))
        self.startup_manager.wait_for_all_cells_on_air()
        self.bts_oam.block_gnb_cell(TDD_CELL)
        self.make_sure_lte_cell_is_blocked()

    def multiple_ues_are_attached_to_the_fdd_cell_with_various_radio_conditions_with_different_dnns(self):
        self._restart_all_ues()
        self._attach_all_ues()

    def two_ues_are_attached_to_the_fdd_cell_with_various_radio_conditions_with_different_dnns(self):
        self._restart_two_eda_ues()
        self._attach_two_ues_with_different_plmn()
        self.ue_slice4.detach()
        self.ue_nsa_only.detach()

    def multiple_ues_are_attached_to_the_tdd_cell_with_various_radio_conditions_with_different_dnns(self):
        self._restart_all_ues()
        self._attach_all_ues()

    def multiple_ues_are_attached_again_to_the_tdd_cell(self):
        self._attach_all_ues()

    def data_tx_of_the_nongbr_drbs_is_started_for_the_ues_at_different_times(self):
        self._start_downlink_data_transfers()

    def data_rx_of_the_nongbr_drbs_is_started_for_the_ues_at_different_times(self):
        self._start_uplink_data_transfers()

    def data_rx_of_the_nongbr_drbs_is_started_for_the_ues_at_different_times_is_again_started_with_full_buffer(self):
        self.nsa_data_name = "_NSA_FULL_BUFFER_UL"
        self._start_uplink_data_transfers()

    def data_rx_and_tx_of_the_nongbr_drbs_is_started_for_the_ues_at_different_times(self):
        self._start_both_directions_data_transfers()

    def low_buffer_data_rx_of_the_nongbr_drbs_is_started_for_one_ue_and_full_buffer_rx_for_the_rest_ues(self):
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period=2)
        self._start_uplink_data_transfers_with_one_low_buffer()

    def pm_counters_are_not_stored_when_feature_disabled(self):
        self._wait_for_next_pm_counters_measurements("disable the feature")
        sas_counters = DL_SANSA_SAS_PM_COUNTERS if self.sas_migration_2nd_step else SA_PM_COUNTERS
        self.raw_counters = self.bts_counters.get_raw_pm_counters(sas_counters)
        self._check_pm_available_slices_counter_not_exist()
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self._confirm_nrrg_pm_counters_do_not_exist()
            # SA RESOURCEGROUPS
            self.nrrg_groups[0].in_use = True
            self.nrrg_groups[1].in_use = False
            self.nrrg_groups[2].in_use = True
            self.nrrg_groups[3].in_use = True
            # NSA RESOURCEGROUPS
            self.nrrg_groups[4].in_use = self.is_nsa_available
            self.nrrg_groups[5].in_use = False
        else:
            self._check_pm_used_slices_counters_not_exist()
            self._check_ratio_slice_counter_value_not_exist()
            self.slices[0].in_use = True
            self.slices[1].in_use = False
            self.slices[2].in_use = True
            self.slices[3].in_use = True

    def data_tx_of_the_nongbr_drbs_is_started_for_the_ues(self):
        transmission_time = 3600
        self.data_name = "RECONFIG_DL_SLICE{}"
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period=2)
        self._start_downlink_tput_for_all_ues(transmission_time)
        Logger.info(f"Data Tx started, minute: {BtsOs().get_current_minute()}")

    def low_buffer_data_tx_of_the_nongbr_drbs_is_started_for_the_ues(self):
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period=2)
        two_minutes_before_test_pm_period = 120
        one_minute_after_test_pm_period = 60
        transmission_time = two_minutes_before_test_pm_period + PM_COLLECTION_SECONDS + one_minute_after_test_pm_period
        transfer_end_time = TimeStamp().unix_timestamp + transmission_time
        self.data_name = "EDA_DL_SLICE{}"
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period=2)
        self.ue_slice3.start_tcp_downlink_data_transmission(duration=transmission_time,
                                                            traffic_mb=10, data_name=self.data_name.format(3),
                                                            mtu_size=1400, tcp_window_size="0,5")
        self.ue_slice1.start_tcp_downlink_data_transmission(duration=transmission_time,
                                                            traffic_mb=10, data_name=self.data_name.format(1),
                                                            mtu_size=1400, tcp_window_size="0,5")
        Logger.info(f"Data Tx started, minute: {BtsOs().get_current_minute()}")
        TimeStamp.wait_for_the_unix_timestamp(transfer_end_time)

    def data_transfer_is_related_to_configured_quotas_before_disabling_the_slice_aware_scheduler(self):
        self._wait_for_next_pm_counters_measurements("enable the feature")
        self._confirm_tput_based_on_pm_counters()

    def data_transfer_is_related_to_configured_quotas_after_enabling_the_slice_aware_scheduler(self):
        self._wait_for_next_pm_counters_measurements("re-enable the feature")
        self._confirm_tput_based_on_pm_counters()

    def one_slice_is_removed_from_configuration(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "remove_slice_24r2"))
        else:
            support_old_slice_delta = "23R"
            if support_old_slice_delta in Env.STREAM_SW:
                self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                                  "remove_slice_old"))
            else:
                self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                                  "remove_slice_new"))

    def data_transfer_for_the_ue_using_removed_slice_is_not_scheduled(self):
        # TODO: SAS migration implementation
        self._wait_for_next_pm_counters_measurements("remove one slice")
        self.nrrg_groups[0].in_use = False
        self.slices[0].in_use = False
        self._confirm_tput_based_on_pm_counters()
        self.nrrg_groups[0].in_use = True
        self.slices[0].in_use = True

    def one_slice_is_added_to_configuration(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "add_slice_24r2"))
            self.nrrg_groups[0].in_use = True
        else:
            support_old_slice_delta = "23R"
            if support_old_slice_delta in Env.STREAM_SW:
                self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                                  "add_slice_old"))
            else:
                self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                                  "remove_slice_new"))
            added_slice = NetworkSlice(snsai=SNSAI_1, cell_id=self.cell_id, mcc=MCC1, mnc=MNC1,
                                       min_quota=5, max_quota=20, in_use=True)
            self.slices[0] = added_slice

    def data_transfer_for_the_ue_using_added_slice_is_scheduled(self):
        self._wait_for_next_pm_counters_measurements("add a new slice")
        self._confirm_tput_based_on_pm_counters()

    def slices_quotas_are_reconfigured(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self.nrrg_groups[0] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1,
                                                  min_quota=5, max_quota=15, in_use=True)
            self.nrrg_groups[1] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=2,
                                                  min_quota=45, max_quota=65, in_use=False)
            self.nrrg_groups[2] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3,
                                                  min_quota=5, max_quota=15, in_use=True)
            self.nrrg_groups[3] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=4,
                                                  min_quota=5, max_quota=15, in_use=True)
            # NSA NRRGs are not reconfigured
        else:
            slice1 = NetworkSlice(snsai=SNSAI_1, cell_id=self.cell_id, mcc=MCC1, mnc=MNC1,
                                  min_quota=5, max_quota=15, in_use=True)
            slice2 = NetworkSlice(snsai=SNSAI_2, cell_id=self.cell_id, mcc=MCC1, mnc=MNC1,
                                  min_quota=45, max_quota=65, in_use=False)
            slice3 = NetworkSlice(snsai=SNSAI_3, cell_id=self.cell_id, mcc=MCC2, mnc=MNC2,
                                  min_quota=5, max_quota=15, in_use=True)
            slice4 = NetworkSlice(snsai=SNSAI_4, cell_id=self.cell_id, mcc=MCC2, mnc=MNC2,
                                  min_quota=5, max_quota=15, in_use=True)
            self.slices = [slice1, slice2, slice3, slice4]
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          "update_quotas"))

    def nsa_quotas_are_reconfigured(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            pass  # due to regression optimization there is no case with in NSA NRRGs change
        else:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "update_nsa_quotas"))
            self.plmns = [Plmn(cell_id=self.cell_id, mcc=MCC1, mnc=MNC1, min_quota=10, max_quota=15)]

    def data_transfers_for_the_ues_using_changed_quotas_is_scheduled(self):
        self._wait_for_next_pm_counters_measurements("change the quotas")
        self._confirm_tput_based_on_pm_counters()

    def restore_original_scf_quotas(self):
        # FIXME: only if fails
        self.bts_config.perform_delta_commissioning(
            self.delta.get_delta_path_for_feature(self.feature, f"{self.technology}_quotas"))
        self._configure_slices_list()

    def restore_original_nsa_scf_quotas(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self.nrrg_groups[4] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=5,
                                                  min_quota=5, max_quota=10, in_use=True)
            self.nrrg_groups[5] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=6,
                                                  min_quota=10, max_quota=15, in_use=False)
        else:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "restore_nsa_quotas"))
            self.plmns = [Plmn(cell_id=self.cell_id, mcc=MCC1, mnc=MNC1, min_quota=5, max_quota=10)]

    def empty_nr_resource_groups_are_removed_and_nrpmqap_objects_for_both_plmns_created(self):
        Logger.info("Removing empty resource groups (and creating NRPMQAP objects)")
        pmqap_delta_postfix = "legacy" if Env.ADMIN_CONNECT_STREAM < "SBTS25R1" else "25r1"
        self.bts_config.perform_delta_commissioning(
            self.delta.get_delta_path_for_feature(self.feature, f"remove_empty_nrrgs_add_pmqap_{pmqap_delta_postfix}"))
        self.startup_manager.wait_for_all_cells_on_air()
        empty_nrrg_6_index = -1
        empty_nrrg_2_index = 1
        self.nrrg_groups.remove(self.nrrg_groups[empty_nrrg_6_index])
        self.nrrg_groups.remove(self.nrrg_groups[empty_nrrg_2_index])
        self.bts_oam.make_sure_gnb_cell_is_blocked(FDD_CELL)

    def nr_resource_groups_quotas_are_updated(self):
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period=3)
        self.bts_config.perform_delta_commissioning(
            self.delta.get_delta_path_for_feature(self.feature, "update_tdd_nrrgs_quotas"))
        nsa_nrrg_5_index_for_low_buffer = -1
        nrrg_3_index_after_nrrg2_removed = 1
        self.nrrg_groups[nrrg_3_index_after_nrrg2_removed].set_new_quotas(min_quota=10, max_quota=45)
        self.nrrg_groups[nsa_nrrg_5_index_for_low_buffer].set_new_quotas(min_quota=20, max_quota=60, full_buffer=False)

    def data_tput_is_stopped(self):
        self._stop_tput_for_all_ues(0)

    def data_tput_is_stopped_and_ues_are_detached(self):
        self._stop_tput_for_all_ues(0)
        self._detach_all_ues()

    def data_tput_is_stopped_and_ues_are_detached_and_low_buffer_traffic_is_as_expected(self):
        low_buffer_tput = self._stop_tput_for_all_ues(0)
        self._detach_all_ues()
        allowed_tput_deviation = 0.05
        assert (1 - allowed_tput_deviation) * LOW_BUFFER_TRAFFIC_MB <= low_buffer_tput \
               <= LOW_BUFFER_TRAFFIC_MB * (1 + allowed_tput_deviation), \
               f"Low buffer traffic {low_buffer_tput:.2f}Mbps is out of allowed {allowed_tput_deviation*100}% range"

    def data_tput_is_stopped_and_the_two_ues_are_detached(self):
        self._stop_tput_for_two_ues(0)
        self._detach_all_ues()

    def both_directions_data_tput_is_stopped_and_ues_are_detached(self):
        ues = [(self.ue_slice1, 1), (self.ue_slice3, 3)]
        for ue, ue_id in ues:
            ue.stop_uplink_transmission(data_name=f"BOTH_WAYS_UL{ue_id}")
            ue.stop_downlink_transmission(data_name=f"BOTH_WAYS_DL{ue_id}")
        self._detach_all_ues()

    def slice_aware_scheduler_is_disabled(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "disable_feature"))
            for nrrg in self.nrrg_groups:
                nrrg.in_ue = False
        else:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "disable_feature"))
            for slice_ in self.slices:
                slice_.in_use = False

    def slice_aware_scheduler_is_enabled(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "enable_feature"))
        else:
            self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                              "enable_feature"))

    def nbr_congestion_control_for_pusch_is_activated_for_the_cell(self):
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          "enable_congestion_control"))

    def data_tx_of_the_nongbr_drbs_is_again_started_for_the_ues_at_different_times(self):
        self._restart_all_ues()
        self._attach_all_ues()
        Logger.info("Once again, UEs attached...")
        self._start_downlink_data_transfers()

    def pm_counters_are_checked_to_be_collected_when_tput_was_active(self):
        sas_counters = DL_SANSA_SAS_PM_COUNTERS if self.sas_migration_2nd_step else SA_PM_COUNTERS
        self.raw_counters = self.bts_counters.get_raw_pm_counters(sas_counters)
        tstamp = self._get_latest_pm_counters_period_epoch()
        available_pdsch = self._confirm_prb_avail_pdsch_slices_pm_counter_exists(tstamp)
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self._confirm_downlink_nrrg_pm_conters_exist_and_correct(available_pdsch)
        else:
            self._confirm_slice_pm_conters_exist_and_correct(available_pdsch)
        return tstamp

    def pm_counters_for_uplink_are_checked_to_be_collected_when_tput_was_active_with_achieved_share_per_nrrg(self):
        self.raw_counters = self.bts_counters.get_raw_pm_counters(UL_SANSA_SAS_PM_COUNTERS)
        tstamp = self._get_latest_pm_counters_period_epoch()
        ul_prb_avail_sas = self._confirm_ul_prb_avail_sas_pm_counter_exists(tstamp)
        used_counters = self._confirm_uplink_nrrg_pm_conters_exist_and_correct(ul_prb_avail_sas)
        self._confirm_target_shares(used_counters, ul_prb_avail_sas=ul_prb_avail_sas)

    def pm_counters_for_uplink_are_checked_to_be_collected_when_tput_was_active_with_nbr_activated(self):
        self.raw_counters = self.bts_counters.get_raw_pm_counters(UL_SANSA_SAS_PM_COUNTERS)
        tstamp = self._get_latest_pm_counters_period_epoch()
        ul_prb_avail_sas = self._confirm_ul_prb_avail_sas_pm_counter_exists(tstamp)
        used_counters = self._confirm_uplink_nrrg_pm_conters_exist_and_correct(ul_prb_avail_sas,
                                                                               nbr_groups=True)
        self._confirm_target_shares(used_counters, ul_prb_avail_sas=ul_prb_avail_sas, nbr_groups=True)

    def pm_counters_and_target_share_per_nrrg_with_low_buffer_ul_are_correct_after_online_reconfiguration(self):
        self._wait_for_next_pm_counters_measurements("update_qoutas")
        self._check_pm_counters_and_target_share_for_ul_nrrgs()

    def pm_counters_and_target_share_per_nrrg_with_low_buffer_ul_are_correct(self):
        # quotas are updated for better stability during removing empty groups
        nsa_nrrg_5_index_for_low_buffer = -1
        nrrg_3_index_after_nrrg2_removed = 1
        self.nrrg_groups[nrrg_3_index_after_nrrg2_removed].set_new_quotas(min_quota=10, max_quota=45)
        self.nrrg_groups[nsa_nrrg_5_index_for_low_buffer].set_new_quotas(min_quota=20, max_quota=60, full_buffer=False)
        self._wait_for_next_pm_counters_measurements("low_buffer")
        self._check_pm_counters_and_target_share_for_ul_nrrgs()

    def pm_counters_and_target_share_per_nrrg_with_full_buffer_ul_are_correct(self):
        nsa_nrrg_5_index_for_full_buffer = -1
        nsa_min_quota = self.nrrg_groups[nsa_nrrg_5_index_for_full_buffer].min_quota + 2
        nsa_max_quota = self.nrrg_groups[nsa_nrrg_5_index_for_full_buffer].max_quota - 2
        self.nrrg_groups[nsa_nrrg_5_index_for_full_buffer].set_new_quotas(min_quota=nsa_min_quota,
                                                                          max_quota=nsa_max_quota,
                                                                          full_buffer=True)
        self._check_pm_counters_and_target_share_for_ul_nrrgs()

    def pm_counters_and_target_share_per_nrrg_with_parallel_traffic_dl_are_correct(self):
        self._configure_dl_fdd_resource_group_list_for_simultaneous_traffic()
        self.dl_sas = True
        Logger.info(f"Configured Downlink NRRGs:{[str(nrrg) for nrrg in self.nrrg_groups]}")
        self.raw_counters = self.bts_counters.get_raw_pm_counters(DL_SANSA_SAS_PM_COUNTERS)
        tstamp = self._get_latest_pm_counters_period_epoch()
        dl_prb_avail_sas = self._confirm_prb_avail_pdsch_slices_pm_counter_exists(tstamp)
        used_counters = self._confirm_downlink_nrrg_pm_conters_exist_and_correct(dl_prb_avail_sas)
        self._confirm_target_shares(used_counters, dl_prb_avail_sas=dl_prb_avail_sas,
                                    expected_deviation=10, acceptable_min_sum=90)

    def pm_counters_and_target_share_per_nrrg_with_parallel_traffic_ul_are_correct(self):
        self._configure_ul_fdd_resource_group_list_for_simultaneous_traffic()
        self.dl_sas = False
        Logger.info(f"Configured Uplink NRRGs:{[str(nrrg) for nrrg in self.nrrg_groups]}")
        self.raw_counters = self.bts_counters.get_raw_pm_counters(UL_SANSA_SAS_PM_COUNTERS)
        tstamp = self._get_latest_pm_counters_period_epoch()
        ul_prb_avail_sas = self._confirm_ul_prb_avail_sas_pm_counter_exists(tstamp)
        used_counters = self._confirm_uplink_nrrg_pm_conters_exist_and_correct(ul_prb_avail_sas)
        self._confirm_target_shares(used_counters, ul_prb_avail_sas=ul_prb_avail_sas,
                                    expected_deviation=10, acceptable_min_sum=90)

    def _check_pm_counters_and_target_share_for_ul_nrrgs(self):
        self.raw_counters = self.bts_counters.get_raw_pm_counters(UL_SANSA_SAS_PM_COUNTERS)
        tstamp = self._get_latest_pm_counters_period_epoch()
        ul_prb_avail_sas = self._confirm_ul_prb_avail_sas_pm_counter_exists(tstamp)
        used_counters = self._confirm_uplink_nrrg_pm_conters_exist_and_correct(ul_prb_avail_sas)
        self._confirm_target_shares(used_counters, ul_prb_avail_sas=ul_prb_avail_sas)

    def nrpmqap_pm_counters_for_plmns_match_the_nrrgs_counters_for_these_plmns(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        pm_qap_counters = self.bts_counters.get_raw_pm_counters(UL_PRBB_PMQAP_COUNTERS)
        common_path = f"MRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRCELL-{self.cell_id}"
        used_data_pmqap_1_pm, used_data_pmqap_2_pm = self._extract_used_data_pmqap_plmn_counters(common_path,
                                                                                                 pm_qap_counters,
                                                                                                 tstamp)

        max_data_pmqap_1_pm, max_data_pmqap_2_pm = self._extract_max_data_pmqap_plmn_counters(common_path,
                                                                                              pm_qap_counters,
                                                                                              tstamp)

        self._confirm_max_data_pmqap_counters(max_data_pmqap_1_pm, max_data_pmqap_2_pm)
        self._confirm_used_data_pmqap_counters(tstamp, used_data_pmqap_1_pm, used_data_pmqap_2_pm)

    def _extract_max_data_pmqap_plmn_counters(self, common_path, pm_qap_counters, tstamp):
        max_data_pmqap_1_plmn1_path = f"{common_path}/NRPMQAP-1/PTHPQ/{UL_PRB_UTIL_SLOT_MAX_PMQAP}"
        max_data_pmqap_2_plmn2_path = f"{common_path}/NRPMQAP-2/PTHPQ/{UL_PRB_UTIL_SLOT_MAX_PMQAP}"
        max_data_pmqap_1_plmn1_pm = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=pm_qap_counters, path=max_data_pmqap_1_plmn1_path, t_stamp=tstamp)
        max_data_pmqap_2_plmn2_pm = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=pm_qap_counters, path=max_data_pmqap_2_plmn2_path, t_stamp=tstamp)
        return max_data_pmqap_1_plmn1_pm, max_data_pmqap_2_plmn2_pm

    def _extract_used_data_pmqap_plmn_counters(self, common_path, pm_qap_counters, tstamp):
        used_data_pmqap_1_plmn1_path = f"{common_path}/NRPMQAP-1/PTHPQ/{UL_PRB_USED_DATA_PMQAP}"
        used_data_pmqap_2_plmn2_path = f"{common_path}/NRPMQAP-2/PTHPQ/{UL_PRB_USED_DATA_PMQAP}"
        used_data_pmqap_1_pm = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=pm_qap_counters, path=used_data_pmqap_1_plmn1_path, t_stamp=tstamp)
        used_data_pmqap_2_pm = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=pm_qap_counters, path=used_data_pmqap_2_plmn2_path, t_stamp=tstamp)
        return used_data_pmqap_1_pm, used_data_pmqap_2_pm

    @staticmethod
    def _confirm_max_data_pmqap_counters(max_data_pmqap_1_plmn1_pm, max_data_pmqap_2_plmn2_pm):
        max_data_info = "Maximum UL PRB Utilization for NRPMQAP (M55363C00004) "
        max_data_pmqap_err = max_data_info + f"for a PLNM is not updated"
        plmn_1_result = f" PLNM1 MCC-{MCC1}/MNC-{MNC1} - {max_data_pmqap_1_plmn1_pm}%"
        plmn_2_result = f" PLNM2 MCC-{MCC2}/MNC-{MNC2} - {max_data_pmqap_2_plmn2_pm}%"
        assert max_data_pmqap_1_plmn1_pm > 0, max_data_pmqap_err + plmn_1_result
        assert max_data_pmqap_2_plmn2_pm > 0, max_data_pmqap_err + plmn_2_result
        Logger.info(max_data_info + plmn_1_result + "," + plmn_2_result)

    def _confirm_used_data_pmqap_counters(self, tstamp, used_data_pmqap_1_pm, used_data_pmqap_2_pm):
        used_data_pmqap_info = "Number of UL PRBs used for data traffic for NRPMQAP (M55363C00002) compared " \
                               "to sum ofUL_PRB_USED_DATA_NRG (M55910C00003) PM per PLMN is "
        used_data_pmqap_err = used_data_pmqap_info + "not correct! "
        plmn1_1u, plmn2_1u, plmn2_2u, plmn1_2u = self._extract_used_data_nrg_counters(tstamp)

        plmn1_counters_ratio = (plmn1_1u + plmn1_2u) / (used_data_pmqap_1_pm * 100)
        assert 0.95 < plmn1_counters_ratio < 1.05, \
            used_data_pmqap_err + f"PLNM1 MCC-{MCC1}/MNC-{MNC1} sum is " \
                                  f"{plmn1_1u}+{plmn1_2u}={plmn1_1u + plmn1_2u} != {used_data_pmqap_1_pm * 100} " \
                                  f"with ratio = {plmn1_counters_ratio:.3f}"
        Logger.info(used_data_pmqap_info +
                    f"{used_data_pmqap_1_pm * 100} ~= {plmn1_1u}+{plmn1_2u}={plmn1_1u + plmn1_2u} "
                    f"with ratio: {plmn1_counters_ratio:.3f} for PLNM1 MCC-{MCC1}/MNC-{MNC1}")

        plmn2_counters_ratio = (plmn2_1u + plmn2_2u) / (used_data_pmqap_2_pm * 100)
        assert 0.95 < plmn1_counters_ratio < 1.05, \
            used_data_pmqap_err + f"PLNM2 MCC-{MCC2}/MNC-{MNC2} sum is " \
                                  f"{plmn2_1u}+{plmn2_2u}={plmn2_1u + plmn2_2u} != {used_data_pmqap_2_pm * 100} " \
                                  f"with ratio = {plmn2_counters_ratio}"
        Logger.info(used_data_pmqap_info +
                    f"{used_data_pmqap_2_pm * 100} ~= {plmn2_1u}+{plmn2_2u}={plmn2_1u + plmn2_2u} "
                    f"with ratio: {plmn2_counters_ratio:.3f} for PLNM2 MCC-{MCC2}/MNC-{MNC2}")

    def _confirm_target_shares(self, used_counters, ul_prb_avail_sas=None, dl_prb_avail_sas=None, nbr_groups=False,
                               expected_deviation=5, acceptable_min_sum=98):
        prb_avail_sas = ul_prb_avail_sas if ul_prb_avail_sas else dl_prb_avail_sas
        avl_counter_name = "UL_PRB_AVAIL_SAS" if ul_prb_avail_sas else "DL_PRB_AVAIL_SAS"
        usd_counter_name = "UL_PRB_USED_DATA_NRG" if ul_prb_avail_sas else "DL_PRB_USED_DATA_NRG"
        Logger.info(f"{avl_counter_name} counter value used for target share calculation: {prb_avail_sas}")
        sum_of_calculated_target_share = 0
        target_shares = self._get_target_shares()
        full_buffer_only = True if \
            all([a_nrrg.full_buffer for a_nrrg in self.nrrg_groups]) and \
            all([a_nrrg.in_use for a_nrrg in self.nrrg_groups]) else False
        is_nrrg_the_nbr_group = [False, False, True] if nbr_groups else [False for _ in self.nrrg_groups]
        for rg_id, a_nrrg in enumerate(self.nrrg_groups):
            target_share = target_shares[rg_id]
            single_share = used_counters[rg_id] / prb_avail_sas * 100
            single_share_str = f"{single_share:.2f}"
            target_share_str = f"{target_share:.2f}"
            Logger.info(f"Achieved share for {a_nrrg} is {single_share_str:>5}% "
                        f"vs target {target_share_str:>5}% - {usd_counter_name} value: {used_counters[rg_id]}")
            sum_of_calculated_target_share += single_share
            if a_nrrg.in_use and a_nrrg.full_buffer:
                if full_buffer_only and not nbr_groups:
                    assert target_share - expected_deviation < single_share < target_share + expected_deviation, \
                        f"A {a_nrrg} share {single_share:.2f}% is out of expected range:" \
                        f" {target_share - expected_deviation:.2f}% <-> {target_share + expected_deviation:.2f}%"
                elif full_buffer_only and nbr_groups:
                    self._confirm_target_share_with_nbr_activated(a_nrrg, is_nrrg_the_nbr_group, rg_id,
                                                                  single_share, target_share)
                else:
                    assert single_share > target_share, \
                        f"A {a_nrrg} share is too low: {single_share:.1f}% < {target_share}%"
            elif a_nrrg.in_use and not a_nrrg.full_buffer:
                assert 0 < single_share < target_share, \
                    f"A {a_nrrg} share out of expected range: 0 < {single_share}% < {target_share}%"
            else:
                assert int(single_share) == 0, f"A {a_nrrg} share should be 0, but is {single_share}%"
        self._confirm_sum_of_target_shares(sum_of_calculated_target_share, acceptable_min_sum)

    @staticmethod
    def _confirm_sum_of_target_shares(sum_of_calculated_target_share, acceptable_min_sum=98):
        assert sum_of_calculated_target_share >= acceptable_min_sum, \
            ("Sum of achieved target shares in used NRRGs is too low: "
             f"{sum_of_calculated_target_share}% < {acceptable_min_sum}%")
        Logger.info(f"Sum of achieved target shares in used NRRGs is: {sum_of_calculated_target_share:.2f}%")

    @staticmethod
    def _confirm_target_share_with_nbr_activated(a_nrrg, is_nrrg_the_nbr_group, rg_id, single_share, target_share):
        if is_nrrg_the_nbr_group[rg_id]:
            assert single_share > target_share, \
                (f"A NBR NRRG {a_nrrg} share is too low: "
                 f"{single_share:.2f}% < {target_share:.2f}% of target")
        else:
            assert target_share > single_share, \
                (f"A Non-NBR NRRG {a_nrrg} share is to high: "
                 f"{single_share:.2f}% >= {target_share:.2f}% of target")
            if target_share - 5 > single_share:
                Logger.warning(f"A Non-NBR NRRG {a_nrrg} share is more than 5% smaller {single_share:.2f}% "
                               f"than the target share {target_share:.2f}%")

    def _get_target_shares(self):
        min_quotas = [nrrg.target_share_min for nrrg in self.nrrg_groups]
        max_quotas = [nrrg.target_share_max for nrrg in self.nrrg_groups]
        diff_quotas = [max_quota - min_quota for max_quota, min_quota in zip(max_quotas, min_quotas)]
        sum_of_diff_quotas = sum(diff_quotas)
        min_quotas_factor = 100 - sum(min_quotas)
        share_calcs = [min_quota+((diff_quota/sum_of_diff_quotas) * min_quotas_factor)
                       for min_quota, diff_quota in zip(min_quotas, diff_quotas)]
        return [min(share_calc, max_quota) for share_calc, max_quota in zip(share_calcs, max_quotas)]

    def prb_used_pdsch_plmn_and_other_slices_counters_for_two_ones_are_verified(self):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        self.common_eda_tstamp = self.pm_counters_are_checked_to_be_collected_when_tput_was_active()
        allowed_deviation = 0.05
        used_pdsch_counters = self.bts_counters.get_raw_pm_counters([PRB_USED_PDSCH_PLMN])

        used_prbs_plmn1 = self._extract_used_prbs_plmn(used_pdsch_counters, mcc=MCC1, mnc=MNC1)
        used_prbs_plmn3 = self._extract_used_prbs_plmn(used_pdsch_counters, mcc=MCC2, mnc=MNC2)

        self._verify_slice_to_plmn_counters_ratio(used_prbs_plmn=used_prbs_plmn1, snsai=SNSAI_1,
                                                  allowed_deviation=allowed_deviation)
        self._verify_slice_to_plmn_counters_ratio(used_prbs_plmn=used_prbs_plmn3, snsai=SNSAI_3,
                                                  allowed_deviation=allowed_deviation)
        self._verify_counters_based_prbs_for_slices(allowed_deviation)
        self._verify_calculated_prbs_for_slices(allowed_deviation)

    def relation_between_legacy_counters_and_sas_counters_is_verified(self):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        prb_avail_pdsch, prb_avail_pdsch_slices, used_prbs_plmn1, used_slice_pm = \
            self._collect_legacy_and_sas_counters_for_eda_check()
        self._check_legacy_and_sas_counters(prb_avail_pdsch, prb_avail_pdsch_slices,
                                            used_prbs_plmn1, used_slice_pm)

    def _delta_on_name(self):
        delta_on_name = "counters_on_sas24r2" if self.sas_migration_first_step or self.sas_migration_2nd_step \
            else "counters_on_legacy"
        return delta_on_name

    def _collect_legacy_and_sas_counters_for_eda_check(self):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        legacy_counters = [PRB_AVAIL_PDSCH, PRB_USED_PDSCH_PLMN]
        sas_counters = [PRB_AVAIL_PDSCH_SLICES, PRB_USED_PDSCH_SLICE]
        raw_legacy_counters = self.bts_counters.get_raw_pm_counters(legacy_counters)
        raw_sas_counters = self.bts_counters.get_raw_pm_counters(sas_counters)
        prb_avail_pdsch = self._extract_prb_avail_pdsch(raw_legacy_counters)
        used_prbs_plmn1 = self._extract_used_prbs_plmn(raw_legacy_counters, mcc=MCC1, mnc=MNC1)
        prb_avail_pdsch_slices = self.bts_counters.extract_bts_cell_pm_counter(raw_sas_counters,
                                                                               PRB_AVAIL_PDSCH_SLICES,
                                                                               cell_id=self.cell_id,
                                                                               t_stamp=self.common_eda_tstamp)
        used_slice_pm = self.bts_counters.extract_cell_slice_pm_counters(raw_sas_counters, cell_id=FDD_CELL,
                                                                         slice_name=SNSAI_1,
                                                                         counter_id=PRB_USED_PDSCH_SLICE,
                                                                         mobile_country_code=MCC1,
                                                                         mobile_network_code=MNC1,
                                                                         t_stamp=self.common_eda_tstamp)
        return prb_avail_pdsch, prb_avail_pdsch_slices, used_prbs_plmn1, used_slice_pm

    @staticmethod
    def _check_legacy_and_sas_counters(prb_avail_pdsch, prb_avail_pdsch_slices, used_prbs_plmn1, used_slice_pm):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        prb_used_pdsch_slice = int(sum(used_slice_pm.values()) / 100)
        prb_avail_pdsch_slice = int(sum(prb_avail_pdsch_slices.values()) / 100)
        Logger.info(f"EDA03030618 calculations: \n"
                    f"PRB_AVAIL_PDSCH - PRB_USED_PDSCH_PLMN = PRB_AVAIL_PDSCH_SLICES - PRB_USED_PDSCH_SLICE\n"
                    f"for Legacy counters: \n"
                    f"PRB_AVAIL_PDSCH/M55308C10003: {prb_avail_pdsch}\n"
                    f"PRB_USED_PDSCH_PLMN/M55338C00001: {used_prbs_plmn1}\n"
                    f"and SAS counters (divided by 100): \n"
                    f"PRB_AVAIL_PDSCH_SLICES/M55308C10007: {prb_avail_pdsch_slice}\n"
                    f"PRB_USED_PDSCH_SLICE/M55359C00000: {prb_used_pdsch_slice}")
        legacy_counters_calculation = prb_avail_pdsch - used_prbs_plmn1
        sas_counters_calculation = prb_avail_pdsch_slice - prb_used_pdsch_slice
        eda_explanation = f"M55338C00001 PRB_USED_PDSCH_PLMN: {used_prbs_plmn1} should count more PRB than " \
                          f"M55359C00000 PRB_USED_PDSCH_SLICE: {prb_used_pdsch_slice} " \
                          f"like SRB traffic so it can be litter higher"
        allowed_one_8prb_frame = 8
        sas_and_legacy_counters_difference = sas_counters_calculation - legacy_counters_calculation
        assert sas_and_legacy_counters_difference >= -allowed_one_8prb_frame, \
            "Legacy counters calculation should not be greater than SAS counters calculation.\n" \
            "It should be: PRB_AVAIL_PDSCH - PRB_USED_PDSCH_PLMN = PRB_AVAIL_PDSCH_SLICES - PRB_USED_PDSCH_SLICE\n" + \
            eda_explanation
        if sas_and_legacy_counters_difference < 0:
            Logger.warning(eda_explanation + f"\nThis condition is not met, but yet allowed: {allowed_one_8prb_frame}")
            # For the next assert to do not fail and still check in case for too low counters values
            prb_used_pdsch_slice -= allowed_one_8prb_frame

        used_prbs_counters_ratio = prb_used_pdsch_slice / used_prbs_plmn1 * 100
        assert 100 >= used_prbs_counters_ratio > 99.999, \
            f"Incorrect PRB_USED_PDSCH counters ratio: {used_prbs_counters_ratio:.4f}% \n" + eda_explanation
        Logger.info("EDA03030618 Checked: M55308C10003 - M55338C00001 = M55308C10007 - M55359C00000")

    def _verify_slice_to_plmn_counters_ratio(self, allowed_deviation, used_prbs_plmn, snsai):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        slice_counters_ratio = int(used_prbs_plmn) / int(self.used_slices[snsai]) * 100
        assert (1 + allowed_deviation) > slice_counters_ratio > (1 - allowed_deviation), \
            f"PRB_USED_PDSCH_PLMN * 100 not equal to PRB_USED_PDSCH_SLICE" \
            f" for {snsai} with ratio: {slice_counters_ratio}"
        Logger.info(f"PRB_USED_PDSCH_PLMN and PRB_USED_PDSCH_SLICE ratio for {snsai} is {slice_counters_ratio:.2f}")

    def _extract_prb_avail_pdsch(self, prb_avail_pdsch):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        plmn = f"CELLS/NRCELL-{self.cell_id}/NCELA/{PRB_AVAIL_PDSCH}" \
            if self.legacy_counter_tree else \
            f"MRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRBTS-{Env.GNB_GLOBAL_BTS_ID}" \
            f"/NRCELL-{self.cell_id}/NCELA/{PRB_AVAIL_PDSCH}"
        used_prbs_plmn = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=prb_avail_pdsch, path=plmn, t_stamp=self.common_eda_tstamp)
        return used_prbs_plmn

    def _extract_used_prbs_plmn(self, used_pdsch_counters, mcc, mnc):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        plmn = f"CELLS/NRCELL-{self.cell_id}/MCC-{mcc}_MNC-{mnc}/NCUPL/{PRB_USED_PDSCH_PLMN}" \
            if self.legacy_counter_tree else \
            f"MRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRBTS-{Env.GNB_GLOBAL_BTS_ID}" \
            f"/NRCELL-{self.cell_id}/MCC-{mcc}/MNC-{mnc}/NCUPL/{PRB_USED_PDSCH_PLMN}"
        used_prbs_plmn = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=used_pdsch_counters, path=plmn, t_stamp=self.common_eda_tstamp)
        return used_prbs_plmn

    def _verify_counters_based_prbs_for_slices(self, allowed_deviation):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        used_slices_ratio = int(self.used_slices[SNSAI_1]) / int(self.used_slices[SNSAI_3])
        assert (1 + 2 * allowed_deviation) > used_slices_ratio > (1 - 2 * allowed_deviation), \
            f"Calculated PRBs ratio for both slices is not equal: {used_slices_ratio}"
        Logger.info(f"PRB_USED_PDSCH_SLICE ratio for {SNSAI_1} and {SNSAI_3} is {used_slices_ratio:.2f}")

    def _verify_calculated_prbs_for_slices(self, allowed_deviation):
        used_calc_prbs_ratio = int(self.used_slice_ratios[SNSAI_1]) / int(self.used_slice_ratios[SNSAI_3])
        assert (1 + 2 * allowed_deviation) > used_calc_prbs_ratio > (1 - 2 * allowed_deviation), \
            "Calculated PRBs ratio for both slices is not equal"
        Logger.info(f"Calculated PRBs values ratio for {SNSAI_1} and {SNSAI_3} is {used_calc_prbs_ratio:.2f}")

    def nsa_pm_counters_are_checked_to_be_collected_when_tput_was_active(self):
        try:
            self.raw_counters = self.bts_counters.get_raw_pm_counters(NSA_PM_COUNTERS)
            if self.sas_migration_first_step:
                self._confirm_nsa_plmn_pm_counters_do_not_exist()  # If appear must not be updated for 24R2 (CB008828)
            elif self.sas_migration_2nd_step:
                assert False, f"NSA counters {NSA_PM_COUNTERS} should be removed since 24R3"
            else:
                self._confirm_nsa_slice_pm_conters_exist_and_correct()
        except AdminApiProcedureFailureException:
            if self.sas_migration_first_step or self.sas_migration_2nd_step:
                Logger.info(f"NSA Counters {NSA_PM_COUNTERS} not exist as expected for {Env.STREAM_SW}")
            else:
                assert False, f"NSA counters {NSA_PM_COUNTERS} not incremented in BTS for {Env.STREAM_SW}. " \
                              f"24R2 migration: {self.sas_migration_first_step},  " \
                              f"24R3 migration: {self.sas_migration_2nd_step}"

    def pm_counters_flags_are_disabled_for_counters_collecting(self):
        # SAS Migration: I think there is no need to create different counters_off deltas, may be common
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          "counters_off"))

    def pm_counters_are_checked_to_be_not_collected_when_tput_was_active(self):
        sas_counters = DL_SANSA_SAS_PM_COUNTERS if self.sas_migration_2nd_step else SA_PM_COUNTERS
        self.raw_counters = self.bts_counters.get_raw_pm_counters(sas_counters)
        self._confirm_prb_avail_pdsch_slices_pm_counter_does_not_exist()
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self._confirm_nrrg_pm_counters_do_not_exist()
        else:
            self._confirm_slice_pm_counters_do_not_exist()

    def nsa_pm_counters_are_checked_to_be_not_collected_when_tput_was_active(self):
        try:
            self.raw_counters = self.bts_counters.get_raw_pm_counters(NSA_PM_COUNTERS)
            if not self.sas_migration_2nd_step:
                self._confirm_nsa_plmn_pm_counters_do_not_exist()  # If appear must not be updated before 24R3
            else:
                assert False, f"NSA counters {NSA_PM_COUNTERS} should be removed since 24R3"
        except AdminApiProcedureFailureException:
            Logger.info(f"NSA Counters {NSA_PM_COUNTERS} not exist as expected for {Env.STREAM_SW}"
                        f"24R2 migration: {self.sas_migration_first_step},  "
                        f"24R3 migration: {self.sas_migration_2nd_step}")

    @staticmethod
    def slice_aware_scheduler_is_set_to_true(bsh_number="1:1"):
        slice_aware_set_true = "actCellSliceAwareScheduler=1"

        try:
            slice_aware_log = BtsOs().get_slice_aware_log_line(bsh_number=bsh_number)
        except DeviceHostnameNotFound:
            Logger.warning(f"BBMOD node with bsh number '{bsh_number}' has not found")
            return

        if not slice_aware_log:
            Logger.warning("Slice aware log not found in the ASP-1740_startup file")
        elif slice_aware_set_true not in slice_aware_log.strip():
            Logger.warning(f"Slice aware scheduler log found but seems to be not activated: {slice_aware_log}")
        else:
            Logger.info("Slice aware scheduler is set to True: {}".format(slice_aware_set_true))

    def make_sure_lte_cell_is_blocked(self):
        self.bts_oam.make_sure_enb_cell_is_blocked(LTE_CELL)

    def make_sure_lte_cell_is_unblocked(self):
        self.bts_oam.make_sure_enb_cell_is_unblocked(LTE_CELL)

    def _configure_fdd_with_slices(self):
        self.cell_id = FDD_CELL
        self.technology = FDD
        self._configure_slices_list()

    def _configure_tdd_with_slices(self):
        self.cell_id = TDD_CELL
        self.technology = TDD
        self._configure_slices_list()

    def _configure_ul_tdd_nrresource_groups(self):
        self.cell_id = TDD_CELL
        self.technology = TDD
        self.dl_sas = False
        self._configure_ul_tdd_resource_group_list()

    def _configure_ul_tdd_nrresource_groups_for_nbr_interworking(self):
        self.cell_id = TDD_CELL
        self.technology = TDD
        self.dl_sas = False
        self._configure_ul_tdd_resource_group_list_for_nbr_interworking()

    def _configure_fdd_with_plmns(self):
        self.cell_id = FDD_CELL
        self.technology = FDD
        if self.sas_migration_first_step:
            self._configure_nsa_resource_group_list()
        else:
            self._configure_plmn_list()

    def _configure_tdd_with_plmns(self):
        self.cell_id = TDD_CELL
        self.technology = TDD
        if self.sas_migration_first_step:
            self._configure_nsa_resource_group_list()  # pure NSA not tested due to reg optimisation
        else:
            self._configure_plmn_list()

    def _detach_ue_remove_traffic_files_and_cleanup_logs(self):
        self._detach_all_ues()
        self._try_to_remove_traffic_files()
        self.cleanup_the_setup_and_collect_logs_if_the_test_fails()
        self.startup_manager.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(self.enb_id,
                                                                                              suite_level=False)

    def _make_sure_all_cells_are_unblocked(self):
        self.bts_oam.make_sure_gnb_cell_is_unblocked(TDD_CELL)
        self.bts_oam.make_sure_gnb_cell_is_unblocked(FDD_CELL)

    def _try_to_remove_traffic_files(self):
        self.ue_slice1.try_to_get_and_remove_traffic_log_files()
        self.ue_slice3.try_to_get_and_remove_traffic_log_files()
        self.ue_slice4.try_to_get_and_remove_traffic_log_files()
        if self.is_nsa_available:
            self.ue_nsa_only.try_to_get_and_remove_traffic_log_files()

    def _change_cell_dep_type(self, technology, change):
        delta = f"{technology}_{change}"
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature, delta))
        self.startup_manager.wait_for_all_cells_on_air()

    def _prepare_ues(self):
        try:
            self._check_all_ues_are_prepared()
        except AssertionError as not_prepared_ue_error:
            Logger.warning(f"{not_prepared_ue_error} - UEs will be restarted with adb and checked again")
            self._restart_all_ues()
            self._check_all_ues_are_prepared()

    def _check_all_ues_are_prepared(self):
        self.ue_slice3.prepare_ue()
        self.ue_slice1.prepare_ue()
        self.ue_slice4.prepare_ue()
        self.ue_nsa_only.prepare_ue()

    def _attach_all_ues(self):
        self._attach_sa_ues()
        if self.is_nsa_available:
            self._attempt_to_attach_several_times(self.ue_nsa_only)

    def _attach_two_ues_with_different_plmn(self):
        self._attempt_to_attach_several_times(self.ue_slice3)
        self._attempt_to_attach_several_times(self.ue_slice1)

    def _attach_sa_ues(self):
        self._attempt_to_attach_several_times(self.ue_slice3)
        self._attempt_to_attach_several_times(self.ue_slice1)
        self._attempt_to_attach_several_times(self.ue_slice4)

    @staticmethod
    def _attempt_to_attach_several_times(ue, retry_number=5):
        for attempt in range(retry_number):
            try:
                ue.attach()
                Logger.info(f"{ue.get_ue_name()} - attached in the attempt #{attempt + 1}")
                return
            except AssertionError:
                Logger.warning(f"{ue.get_ue_name()} - not attached in the attempt #{attempt+1}")
                ue.detach()
        assert False, f"{ue.get_ue_name()} - not attached in all attempts"

    def _restart_all_ues(self):
        Logger.info("Restarting all UEs with PDU restart")
        Pdu().restart_pdu_port(ASKEY_PDU_PORT)
        self._wait_for_sa_ues()
        if self.is_nsa_available:
            self.ue_nsa_only.wait_for_ue_rebooted()

    def _restart_two_eda_ues(self):
        # EDA checks legacy and SAS counters relations, migration doesn't make sense here, to be removed after 24R1
        Logger.info("Restarting EDA UEs with PDU restart")
        Pdu().restart_pdu_port(ASKEY_PDU_PORT)
        self.ue_slice1.wait_for_ue_rebooted()
        self.ue_slice3.wait_for_ue_rebooted()

    def _wait_for_sa_ues(self):
        self.ue_slice1.wait_for_ue_rebooted()
        self.ue_slice3.wait_for_ue_rebooted()
        self.ue_slice4.wait_for_ue_rebooted()

    def _detach_all_ues(self):
        self._detach_sa_ues()
        if self.is_nsa_available:
            self.ue_nsa_only.detach()

    def _detach_sa_ues(self):
        self.ue_slice3.detach()
        self.ue_slice1.detach()
        self.ue_slice4.detach()

    def _configure_slices_list(self):
        if self.technology == FDD:
            self._configure_fdd_slices_list()
            self._configure_fdd_resource_group_list()
        elif self.technology == TDD:
            self._configure_tdd_slices_list()
            self._configure_tdd_resource_group_list()
        else:
            assert False, "Neither TDD nor FDD technology not declared, slices cannot be configured"

    def _configure_fdd_slices_list(self):
        slice1 = NetworkSlice(snsai=SNSAI_1, cell_id=self.cell_id, mcc=MCC1, mnc=MNC1,
                              min_quota=5, max_quota=20, in_use=True)
        slice2 = NetworkSlice(snsai=SNSAI_2, cell_id=self.cell_id, mcc=MCC1, mnc=MNC1,
                              min_quota=10, max_quota=30, in_use=False)
        slice3 = NetworkSlice(snsai=SNSAI_3, cell_id=self.cell_id, mcc=MCC2, mnc=MNC2,
                              min_quota=10, max_quota=15, in_use=True)
        slice4 = NetworkSlice(snsai=SNSAI_4, cell_id=self.cell_id, mcc=MCC2, mnc=MNC2,
                              min_quota=30, max_quota=40, in_use=True)
        self.slices = [slice1, slice2, slice3, slice4]

    def _configure_fdd_resource_group_list(self):
        # SA NRRESOURCEGROUPS
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=5, max_quota=20,
                                            in_use=True)
        nrresource_group2 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=2, min_quota=10, max_quota=30,
                                            in_use=False)
        nrresource_group3 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3, min_quota=10, max_quota=15,
                                            in_use=True)
        nrresource_group4 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=4, min_quota=30, max_quota=40,
                                            in_use=True)
        # NSA NRRESOURCEGROUPS
        nrresource_group5 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=5, min_quota=5, max_quota=10,
                                            in_use=self.is_nsa_available)
        nrresource_group6 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=6, min_quota=10, max_quota=15,
                                            in_use=False)
        self.nrrg_groups = [nrresource_group1, nrresource_group2, nrresource_group3, nrresource_group4,
                            nrresource_group5, nrresource_group6]

    def _configure_tdd_slices_list(self):
        slice1 = NetworkSlice(snsai=SNSAI_1, cell_id=self.cell_id, mcc=MCC1, mnc=MNC1,
                              min_quota=5, max_quota=10, in_use=True)
        slice2 = NetworkSlice(snsai=SNSAI_2, cell_id=self.cell_id, mcc=MCC1, mnc=MNC1,
                              min_quota=50, max_quota=65, in_use=False)
        slice3 = NetworkSlice(snsai=SNSAI_3, cell_id=self.cell_id, mcc=MCC2, mnc=MNC2,
                              min_quota=10, max_quota=15, in_use=True)
        slice4 = NetworkSlice(snsai=SNSAI_4, cell_id=self.cell_id, mcc=MCC2, mnc=MNC2,
                              min_quota=5, max_quota=20, in_use=True)
        self.slices = [slice1, slice2, slice3, slice4]

    def _configure_tdd_resource_group_list(self):
        # SA NRRESOURCEGROUPS
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=5, max_quota=20,
                                            in_use=True)
        nrresource_group2 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=2, min_quota=50, max_quota=65,
                                            in_use=False)
        nrresource_group3 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3, min_quota=10, max_quota=15,
                                            in_use=True)
        nrresource_group4 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=4, min_quota=5, max_quota=20,
                                            in_use=True)
        # NSA NRRESOURCEGROUPS
        nrresource_group5 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=5, min_quota=10, max_quota=30,
                                            in_use=self.is_nsa_available)
        nrresource_group6 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=6, min_quota=10, max_quota=30,
                                            in_use=False)
        self.nrrg_groups = [nrresource_group1, nrresource_group2, nrresource_group3, nrresource_group4,
                            nrresource_group5, nrresource_group6]

    def _configure_ul_tdd_resource_group_list(self):
        # SA NRRESOURCEGROUPS
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=5, max_quota=100,
                                            in_use=True)
        nrresource_group2 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=2, min_quota=50, max_quota=65,
                                            in_use=False)
        nrresource_group3 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3, min_quota=10, max_quota=15,
                                            in_use=True)
        nrresource_group4 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=4, min_quota=5, max_quota=20,
                                            in_use=True)
        # NSA NRRESOURCEGROUPS
        nrresource_group5 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=5, min_quota=5, max_quota=10,
                                            in_use=self.is_nsa_available)
        nrresource_group6 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=6, min_quota=10, max_quota=15,
                                            in_use=False)
        self.nrrg_groups = [nrresource_group1, nrresource_group2, nrresource_group3, nrresource_group4,
                            nrresource_group5, nrresource_group6]

    def _configure_ul_tdd_resource_group_list_for_nbr_interworking(self):
        self._configure_ul_tdd_resource_group_list()
        self._update_nrrg_groups_for_nbr_interworking()

    def _update_nrrg_groups_for_nbr_interworking(self):
        deviation_factor_for_max_quota = 3
        self.nrrg_groups[0] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1,
                                              min_quota=5, max_quota=25+deviation_factor_for_max_quota, in_use=True)
        self.nrrg_groups[2] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3,
                                              min_quota=10, max_quota=35+deviation_factor_for_max_quota, in_use=True)
        self.nrrg_groups[3] = NRResourceGroup(cell_id=self.cell_id, resource_group_id=4,
                                              min_quota=5, max_quota=40+deviation_factor_for_max_quota, in_use=True)
        empty_nrrg_2_index = 1
        empty_first_nsa_index = 4
        self.nrrg_groups = self.nrrg_groups[0:empty_first_nsa_index]
        self.nrrg_groups.remove(self.nrrg_groups[empty_nrrg_2_index])

    def _configure_plmn_list(self):
        plmn1 = Plmn(cell_id=self.cell_id, mcc=MCC1, mnc=MNC1, min_quota=5, max_quota=10)
        plmn2 = Plmn(cell_id=self.cell_id, mcc=MCC2, mnc=MNC2, min_quota=10, max_quota=15)
        self.plmns = [plmn1, plmn2]

    def _configure_nsa_resource_group_list(self):
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=5, max_quota=10,
                                            in_use=True)
        nrresource_group2 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=2, min_quota=10, max_quota=15,
                                            in_use=True)
        self.nsa_nr_resource_groups = [nrresource_group1, nrresource_group2]

    def _configure_dl_fdd_resource_group_list_for_simultaneous_traffic(self):
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=15, max_quota=25,
                                            in_use=True)
        nrresource_group3 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3, min_quota=20, max_quota=100,
                                            in_use=True)
        self.nrrg_groups = [nrresource_group1, nrresource_group3]

    def _configure_ul_fdd_resource_group_list_for_simultaneous_traffic(self):
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=20, max_quota=100,
                                            in_use=True)
        nrresource_group3 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3, min_quota=15, max_quota=25,
                                            in_use=True)
        self.nrrg_groups = [nrresource_group1, nrresource_group3]

    def _start_downlink_data_transfers(self):
        transfer_end_time, transmission_time = self._prepare_counter_measurement()
        self.data_name = "SCHEDULER_DL{}"
        self._start_downlink_tput_for_all_ues(transmission_time)
        TimeStamp.wait_for_the_unix_timestamp(transfer_end_time)

    def _start_uplink_data_transfers(self):
        transfer_end_time, transmission_time = self._prepare_counter_measurement()
        self.data_name = "SCHEDULER_UL{}"
        self._start_uplink_tput_for_all_ues(transmission_time)
        TimeStamp.wait_for_the_unix_timestamp(transfer_end_time)

    def _start_both_directions_data_transfers(self):
        transfer_end_time, transmission_time = self._prepare_counter_measurement(minutes_before_pm_period=3)
        traffic_stabilization_time = 20
        ues = [(self.ue_slice3, 3), (self.ue_slice1, 1)]
        for ue, ue_id in ues:
            ue.start_udp_downlink_data_transmission(duration=transmission_time,
                                                    traffic_mb=100, data_name=f"BOTH_WAYS_DL{ue_id}",
                                                    mtu_size=700, tcp_window_size="0,5")
            sleep(traffic_stabilization_time)
            ue.start_udp_uplink_data_transmission(duration=transmission_time,
                                                  traffic_mb=100, data_name=f"BOTH_WAYS_UL{ue_id}",
                                                  mtu_size=700, tcp_window_size="0,5", force_iperf2=True)
            sleep(traffic_stabilization_time)
        TimeStamp.wait_for_the_unix_timestamp(transfer_end_time)

    def _start_uplink_data_transfers_with_one_low_buffer(self):
        transmission_time = 30*60
        ul_traffic_mb = 100
        self.data_name = "FULL_BUFFER_UL{}"
        self.nsa_data_name = "_NSA_LOW_BUFFER"
        self.ue_nsa_only.start_udp_uplink_data_transmission(duration=transmission_time,
                                                            traffic_mb=LOW_BUFFER_TRAFFIC_MB,
                                                            data_name=self.data_name.format(self.nsa_data_name),
                                                            mtu_size=1400, tcp_window_size="0,5")
        self._start_uplink_tput_for_sa_ues(transmission_time, ul_traffic_mb)

    def _prepare_counter_measurement(self, minutes_before_pm_period=2):
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(
            minutes_before_pm_period=minutes_before_pm_period)
        seconds_before_test_pm_period = minutes_before_pm_period * 60
        seconds_after_test_pm_period = 60
        transmission_time = seconds_before_test_pm_period + PM_COLLECTION_SECONDS + seconds_after_test_pm_period
        transfer_end_time = TimeStamp().unix_timestamp + transmission_time
        return transfer_end_time, transmission_time

    def _confirm_tput_based_on_pm_counters(self):
        sas_counters = DL_SANSA_SAS_PM_COUNTERS if self.sas_migration_2nd_step else SA_PM_COUNTERS
        self.raw_counters = self.bts_counters.get_raw_pm_counters(sas_counters)
        tstamp = self._get_latest_pm_counters_period_epoch()
        available_slices_drbs = self._confirm_prb_avail_pdsch_slices_pm_counter_exists(tstamp)
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            Logger.info(f"Test data template NRRGs: {[str(nrrg) for nrrg in self.nrrg_groups]}")
            used_counters = self._extract_used_data_nrg_counters(tstamp)
            for rg_id, a_nrrg in enumerate(self.nrrg_groups):
                used_sliced_drbs = self._confirm_used_nrrg_counter_exists(used_counters, a_nrrg, rg_id)
                if a_nrrg.in_use:
                    self._confirm_nrrg_calculation(a_nrrg, used_sliced_drbs, available_slices_drbs)
        else:
            Logger.info(f"Test data template slices: {self.slices}")
            for a_slice in self.slices:
                used_slice_drbs = self._confirm_used_slice_counter_exists(a_slice, tstamp)
                self._confirm_slices_calculation(a_slice, used_slice_drbs, available_slices_drbs)
        Logger.info(f"PM Counters confirmed, minute: {BtsOs().get_current_minute()}")

    def _stop_tput_for_all_ues(self, transfer_end_time):
        self._stop_tput_for_sa_ues(transfer_end_time)
        if self.is_nsa_available:
            tput_name = self.data_name.format(self.nsa_data_name)
            nsa_tput = self.ue_nsa_only.get_average_megabits_data_transfer(tput_name, analyze_entries=300)
            Logger.info(f"Average NSA only UE: {nsa_tput:.2f}Mbps")
            self.ue_nsa_only.stop_downlink_transmission(data_name=tput_name)
            return nsa_tput

    def _stop_tput_for_two_ues(self, transfer_end_time):
        TimeStamp.wait_for_the_unix_timestamp(transfer_end_time)
        ue1_tput = self.data_name.format(1)
        ue3_tput = self.data_name.format(3)
        Logger.info(f"Average Slice1 MCC-{MCC1}_MNC-{MNC1} UE Tput: "
                    f"{self.ue_nsa_only.get_average_megabits_data_transfer(ue1_tput, analyze_entries=300):.2f}Mbps")
        Logger.info(f"Average Slice3 MCC-{MCC2}_MNC-{MNC2} UE Tput: "
                    f"{self.ue_nsa_only.get_average_megabits_data_transfer(ue3_tput, analyze_entries=300):.2f}Mbps")
        self.ue_slice3.stop_downlink_transmission(data_name=ue3_tput)
        self.ue_slice1.stop_downlink_transmission(data_name=ue1_tput)

    def _stop_tput_for_sa_ues(self, transfer_end_time):
        TimeStamp.wait_for_the_unix_timestamp(transfer_end_time)
        ue1_tput = self.data_name.format(1)
        ue3_tput = self.data_name.format(3)
        ue4_tput = self.data_name.format(4)
        Logger.info(f"Average Slice1 UE Tput: "
                    f"{self.ue_nsa_only.get_average_megabits_data_transfer(ue1_tput, analyze_entries=300):.2f}Mbps")
        Logger.info(f"Average Slice3 UE Tput: "
                    f"{self.ue_nsa_only.get_average_megabits_data_transfer(ue3_tput, analyze_entries=300):.2f}Mbps")
        Logger.info(f"Average Slice4 UE Tput: "
                    f"{self.ue_nsa_only.get_average_megabits_data_transfer(ue4_tput, analyze_entries=300):.2f}Mbps")
        self.ue_slice3.stop_downlink_transmission(data_name=ue3_tput)
        self.ue_slice1.stop_downlink_transmission(data_name=ue1_tput)
        self.ue_slice4.stop_downlink_transmission(data_name=ue4_tput)

    def _start_downlink_tput_for_all_ues(self, transmission_time):
        self._start_downlink_tput_for_sa_ues(transmission_time)
        if self.is_nsa_available:
            self.ue_nsa_only.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                                  data_name=self.data_name.format(self.nsa_data_name),
                                                                  mtu_size=1400, tcp_window_size="0,5")

    def _start_uplink_tput_for_all_ues(self, transmission_time):
        ul_traffic_mb = 100
        if self.is_nsa_available:
            self.ue_nsa_only.start_udp_uplink_data_transmission(duration=transmission_time, traffic_mb=ul_traffic_mb,
                                                                data_name=self.data_name.format(self.nsa_data_name),
                                                                mtu_size=1400, tcp_window_size="0,5")
        self._start_uplink_tput_for_sa_ues(transmission_time, ul_traffic_mb=ul_traffic_mb)

    def _start_downlink_tput_for_sa_ues(self, transmission_time):
        self.ue_slice3.start_tcp_downlink_data_transmission(duration=transmission_time,
                                                            traffic_mb=100, data_name=self.data_name.format(3),
                                                            mtu_size=1400, tcp_window_size="0,5")
        self.ue_slice1.start_tcp_downlink_data_transmission(duration=transmission_time,
                                                            traffic_mb=100, data_name=self.data_name.format(1),
                                                            mtu_size=1400, tcp_window_size="0,5")
        self.ue_slice4.start_tcp_downlink_data_transmission(duration=transmission_time,
                                                            traffic_mb=100, data_name=self.data_name.format(4),
                                                            mtu_size=1400, tcp_window_size="0,5")

    def _start_uplink_tput_for_sa_ues(self, transmission_time, ul_traffic_mb):
        self.ue_slice4.start_udp_uplink_data_transmission(duration=transmission_time,
                                                          traffic_mb=ul_traffic_mb, data_name=self.data_name.format(4),
                                                          mtu_size=1400, tcp_window_size="0,5")
        self.ue_slice3.start_udp_uplink_data_transmission(duration=transmission_time,
                                                          traffic_mb=ul_traffic_mb, data_name=self.data_name.format(3),
                                                          mtu_size=1400, tcp_window_size="0,5")
        self.ue_slice1.start_udp_uplink_data_transmission(duration=transmission_time,
                                                          traffic_mb=ul_traffic_mb, data_name=self.data_name.format(1),
                                                          mtu_size=1400, tcp_window_size="0,5")

    def _commission_bts_if_the_test_failed(self):
        from robot.libraries.BuiltIn import BuiltIn
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self.commission_gnb_and_wait_for_bts_to_reach_on_air_state()

    def _confirm_slice_pm_conters_exist_and_correct(self, available_pdsch):
        tstamp = self._get_latest_pm_counters_period_epoch()
        Logger.info(f"Test data template slices: {self.slices}")
        for a_slice in self.slices:
            self._confirm_single_slice_pm_counters(a_slice, tstamp, available_pdsch)

    def _confirm_downlink_nrrg_pm_conters_exist_and_correct(self, available_pdsch):
        tstamp = self._get_latest_pm_counters_period_epoch()
        Logger.info(f"Test data template nr resource groups: {[str(rg) for rg in self.nrrg_groups]}")
        max_counters = self._extract_max_data_nrg_counters(tstamp)
        used_counters = self._extract_used_data_nrg_counters(tstamp)
        for rg_id, a_nrrg in enumerate(self.nrrg_groups):
            self._confirm_single_nrrg_pm_counters(a_nrrg, rg_id, max_counters, used_counters, available_pdsch)
        return used_counters

    def _confirm_uplink_nrrg_pm_conters_exist_and_correct(self, ul_prb_avail_sas, nbr_groups=False):
        tstamp = self._get_latest_pm_counters_period_epoch()
        Logger.info(f"Test data template nr resource groups: {[str(rg) for rg in self.nrrg_groups]}")
        max_counters = self._extract_max_data_nrg_counters(tstamp)
        used_counters = self._extract_used_data_nrg_counters(tstamp)
        # TODO: SISOCRT-2748 - remove all stream dependencies after 24R3
        nbr_groups = nbr_groups if "24R3" in Env.STREAM_SW else False
        is_nrrg_the_nbr_group = [False, False, True] if nbr_groups else [False for _ in self.nrrg_groups]
        for rg_id, a_nrrg in enumerate(self.nrrg_groups):
            self._confirm_single_nrrg_pm_counters(a_nrrg, rg_id, max_counters, used_counters,
                                                  ul_prb_avail_sas, is_nrrg_the_nbr_group[rg_id])
        return used_counters

    def _confirm_nsa_slice_pm_conters_exist_and_correct(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        for a_plmn in self.plmns:
            available_prbs = self.bts_counters.extract_cell_plmn_pm_counters(cell_id=self.cell_id,
                                                                             counter_id=PRB_AVAIL_PDSCH_NSA_PLMN,
                                                                             mobile_network_code=a_plmn.mnc,
                                                                             mobile_country_code=a_plmn.mcc,
                                                                             raw_pm_data=self.raw_counters,
                                                                             t_stamp=tstamp)
            used_prbs = self.bts_counters.extract_cell_plmn_pm_counters(cell_id=self.cell_id,
                                                                        counter_id=PRB_USED_PDSCH_NSA_PLMN,
                                                                        mobile_network_code=a_plmn.mnc,
                                                                        mobile_country_code=a_plmn.mcc,
                                                                        raw_pm_data=self.raw_counters,
                                                                        t_stamp=tstamp)
            used_prbs_ratio = sum(used_prbs.values()) / sum(available_prbs.values()) * 100
            Logger.info(f"The PLMN {a_plmn} ratio is : {used_prbs_ratio:.2f}"
                        f" - should match qoutas: {a_plmn.min_quota}<->{a_plmn.max_quota}")
            assert a_plmn.min_quota <= used_prbs_ratio <= a_plmn.max_quota, \
                f"The slice {a_plmn} ratio is : {used_prbs_ratio:.2f} is out of configured quota " \
                f"{a_plmn.min_quota}-{a_plmn.max_quota}"

    def _confirm_single_slice_pm_counters(self, a_slice, tstamp, available_pdsch):
        used_slice_drbs = self._confirm_used_slice_counter_exists(a_slice, tstamp)
        self._confirm_ratio_slice_counter_value(a_slice, tstamp)
        self._confirm_slices_calculation(a_slice, used_slice_drbs, available_pdsch)

    def _confirm_single_nrrg_pm_counters(self, a_nrrg, rg_id, all_max_nr_counters,
                                         all_used_nr_counters, available_pdsch, nbr_group=False):
        used_pm_value = all_used_nr_counters[rg_id]
        max_pm_value = all_max_nr_counters[rg_id]
        slice_max_counter = DL_PRB_UTIL_SLOT_MAX_NRG if self.dl_sas else UL_PRB_UTIL_SLOT_MAX_NRG
        slice_max_counter_str = "DL_PRB_UTIL_SLOT_MAX_NRG" if self.dl_sas else "UL_PRB_UTIL_SLOT_MAX_NRG"
        Logger.info(f"Checking {slice_max_counter_str}: "
                    f"{a_nrrg.min_quota} <= {max_pm_value} <= {a_nrrg.max_quota}")
        if a_nrrg.in_use and not a_nrrg.min_quota <= max_pm_value <= a_nrrg.max_quota and a_nrrg.full_buffer:
            Logger.warning(f"A slice '{a_nrrg}' PM counter {slice_max_counter} indicates "
                           f"value:{max_pm_value} - out of configured quotas {a_nrrg.quotas}")
        else:
            buffer_str = "full buffer tput" if a_nrrg.full_buffer else "low buffer tput"
            Logger.info(f"{slice_max_counter} for a NRRG '{a_nrrg}' - confirmed val:{max_pm_value} for {buffer_str}")
        self._confirm_nrrg_calculation(a_nrrg, used_pm_value, available_pdsch, nbr_group)

    def _extract_used_data_nrg_counters(self, tstamp):
        traffic_counter = DL_PRB_USED_DATA_NRG if self.dl_sas else UL_PRB_USED_DATA_NRG
        return self._extract_nrrg_counters(traffic_counter, tstamp)

    def _extract_max_data_nrg_counters(self, tstamp):
        traffic_counter = DL_PRB_UTIL_SLOT_MAX_NRG if self.dl_sas else UL_PRB_UTIL_SLOT_MAX_NRG
        return self._extract_nrrg_counters(traffic_counter, tstamp)

    def _extract_nrrg_counters(self, traffic_counter, tstamp):
        common_path = f"CELLS/NRCELL-{self.cell_id}" if self.legacy_counter_tree \
            else f"MRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRCELL-{self.cell_id}"
        return [self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.raw_counters, path=f"{common_path}/NRRESOURCEGROUP-{nr_rg.id}/NCUPNRG/{traffic_counter}",
            t_stamp=tstamp) for nr_rg in self.nrrg_groups]

    def _confirm_slices_calculation(self, a_slice, used_slice_drbs,  available_slices_drbs):
        used_slice_ratio = used_slice_drbs / available_slices_drbs * 100
        self.used_slice_ratios[a_slice.name] = used_slice_ratio
        Logger.info(f"CALCULATIONS for a slice '{a_slice.name}' - confirmed val:{used_slice_ratio:.2f}")
        assert a_slice.min_quota <= used_slice_ratio <= a_slice.max_quota, \
            f"The slice {a_slice.name} ratio is : {used_slice_ratio:.2f} is out of configured quota " \
            f"{a_slice.min_quota}-{a_slice.max_quota}"

    @staticmethod
    def _confirm_nrrg_calculation(a_nrrg, used_slice_drbs, available_slices_drbs, nbr_group=False):
        used_slice_ratio = used_slice_drbs / available_slices_drbs * 100
        Logger.info(f"CALCULATIONS for a NRRG '{a_nrrg}' - confirmed val:{used_slice_ratio:.2f}")
        assert_info_full_buffer = f"The NRRG {a_nrrg} ratio is : {used_slice_ratio:.2f} is out of configured quota " \
            f"{a_nrrg.min_quota}-{a_nrrg.max_quota} for full buffer traffic"
        assert_info_low_buffer = f"The NRRG {a_nrrg} ratio is : {used_slice_ratio:.2f} should be greater than zero, " \
                                 f"but lower than minQuota: {a_nrrg.min_quota} for low buffer traffic"
        if a_nrrg.full_buffer and not nbr_group:
            assert a_nrrg.min_quota <= used_slice_ratio <= a_nrrg.max_quota, assert_info_full_buffer
        elif a_nrrg.full_buffer and nbr_group:
            assert used_slice_ratio > a_nrrg.max_quota, f"A NRRG {a_nrrg} with NBR activated should exceed max quota"
        else:
            assert 0 < used_slice_ratio < a_nrrg.min_quota, assert_info_low_buffer

    def _confirm_ratio_slice_counter_value(self, a_slice, tstamp):
        ratio_slice_pm = self.bts_counters.extract_cell_slice_pm_counters(self.raw_counters, cell_id=a_slice.cell_id,
                                                                          slice_name=a_slice.name,
                                                                          counter_id=PRB_PDSCH_UTIL_RATIO_SLICE_MAX,
                                                                          mobile_country_code=a_slice.mcc,
                                                                          mobile_network_code=a_slice.mnc,
                                                                          t_stamp=tstamp)
        pm_key, pm_value = ratio_slice_pm.popitem()
        if a_slice.in_use and not a_slice.min_quota <= pm_value <= a_slice.max_quota:
            Logger.warning(f"A slice '{a_slice.name}' PM counter {PRB_PDSCH_UTIL_RATIO_SLICE_MAX} indicates "
                           f"value:{pm_value} - out of configured quotas {a_slice.quotas}")
        else:
            Logger.info(f"{PRB_PDSCH_UTIL_RATIO_SLICE_MAX} for a slice '{a_slice.name}' - confirmed val:{pm_value}")
        return pm_value

    def _confirm_used_slice_counter_exists(self, a_slice, tstamp):
        used_slice_pm = self.bts_counters.extract_cell_slice_pm_counters(self.raw_counters, cell_id=a_slice.cell_id,
                                                                         slice_name=a_slice.name,
                                                                         counter_id=PRB_USED_PDSCH_SLICE,
                                                                         mobile_country_code=a_slice.mcc,
                                                                         mobile_network_code=a_slice.mnc,
                                                                         t_stamp=tstamp)
        sum_of_slice_counter_values = self._get_used_slice_sum(used_slice_pm, a_slice)
        self.used_slices[a_slice.name] = sum_of_slice_counter_values
        pm_value_increased_when_slice_used = True if sum_of_slice_counter_values > 0 else False
        slice_not_used = True if sum_of_slice_counter_values == 0 else False
        Logger.info(f"Sum of {PRB_USED_PDSCH_SLICE} counter is {sum_of_slice_counter_values}, "
                    f"slice in use:{a_slice.in_use}, pm value increased: {pm_value_increased_when_slice_used}, "
                    f"slice used calculation: {False if slice_not_used else True}")
        confirmed_slice_usage = pm_value_increased_when_slice_used if a_slice.in_use else slice_not_used
        assert confirmed_slice_usage, "PRB_USED_PDSCH_SLICE counters collecting problem!"
        Logger.info(f"{PRB_USED_PDSCH_SLICE} for a slice '{a_slice.name}' - confirmed")
        return sum_of_slice_counter_values

    def _confirm_used_nrrg_counter_exists(self, used_counters, a_nrrg, nrrg_id):
        nrrg_counter_values = used_counters[nrrg_id]
        pm_value_increased_when_slice_used = True if nrrg_counter_values else False
        slice_not_used = True if not nrrg_counter_values else False
        slice_max_counter = DL_PRB_USED_DATA_NRG if self.dl_sas else UL_PRB_UTIL_SLOT_MAX_NRG
        Logger.info(f"Value of {slice_max_counter} counter is {nrrg_counter_values}, "
                    f"NRRG in use: {a_nrrg.in_use}, pm value increased: {pm_value_increased_when_slice_used}, "
                    f"NRRG used for calculation: {False if slice_not_used else True}")
        confirmed_slice_usage = pm_value_increased_when_slice_used if a_nrrg.in_use else slice_not_used
        assert confirmed_slice_usage, "UL/DL_PRB_USED_DATA_NRG counters collecting problem!"
        Logger.info(f"{slice_max_counter} for a NRRG '{a_nrrg}' - confirmed")
        return nrrg_counter_values

    @staticmethod
    def _get_used_slice_sum(used_slice_pm, a_slice):
        pm_value_sum = 0
        Logger.info(f"Used slice pm: {used_slice_pm}")
        try:
            pm_value_sum = sum(used_slice_pm.values())
        except TypeError as type_error:
            if a_slice.in_use:
                assert False, f"Cannot get the {PRB_USED_PDSCH_SLICE} " \
                              f"for a slice '{a_slice.name}' in use due to {type_error}"
        except Exception as error:
            assert False, f"Cannot get the {PRB_USED_PDSCH_SLICE} values for a slice '{a_slice.name}' due to {error}"
        return pm_value_sum

    def _confirm_prb_avail_pdsch_slices_pm_counter_exists(self, tstamp):
        sas_counter = DL_PRB_AVAIL_SAS if self.sas_migration_2nd_step else PRB_AVAIL_PDSCH_SLICES
        pm_counters = self.bts_counters.extract_bts_cell_pm_counter(self.raw_counters,
                                                                    sas_counter, cell_id=self.cell_id,
                                                                    t_stamp=tstamp)
        assert sum(pm_counters.values()) > 0, \
            f"{sas_counter} counter not collected!"
        Logger.info(f"{PRB_AVAIL_PDSCH_SLICES} counters confirmed")
        return sum(pm_counters.values())

    def _confirm_ul_prb_avail_sas_pm_counter_exists(self, tstamp):
        pm_counters = self.bts_counters.extract_bts_cell_pm_counter(self.raw_counters,
                                                                    UL_PRB_AVAIL_SAS, cell_id=self.cell_id,
                                                                    t_stamp=tstamp)
        assert sum(pm_counters.values()) > 0, "UL_PRB_AVAIL_SAS counters not collected!"
        Logger.info(f"{UL_PRB_AVAIL_SAS} counters confirmed")
        return sum(pm_counters.values())

    def _confirm_prb_avail_pdsch_slices_pm_counter_does_not_exist(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        sas_counter = DL_PRB_AVAIL_SAS if self.sas_migration_2nd_step else PRB_AVAIL_PDSCH_SLICES
        pm_counters = self.bts_counters.extract_bts_cell_pm_counter(self.raw_counters,
                                                                    sas_counter, cell_id=self.cell_id,
                                                                    t_stamp=tstamp)
        try:
            counter, values = pm_counters.items()
            assert False, f"{sas_counter} counters collected! {counter}:{values}"
        except ValueError:
            Logger.info(f"{sas_counter} counters not exist as expected")

    def _confirm_slice_pm_counters_do_not_exist(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        for a_slice in self.slices:
            self._confirm_slice_counter_not_exist(a_slice, PRB_PDSCH_UTIL_RATIO_SLICE_MAX, tstamp)
            self._confirm_slice_counter_not_exist(a_slice, PRB_USED_PDSCH_SLICE, tstamp)

    def _confirm_nrrg_pm_counters_do_not_exist(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        max_counters = self._extract_max_data_nrg_counters(tstamp)
        used_counters = self._extract_used_data_nrg_counters(tstamp)
        for rg_id, a_nrrg in enumerate(self.nrrg_groups):
            used_pm_value = used_counters[rg_id]
            max_pm_value = max_counters[rg_id]
            self._confirm_nrrg_counter_not_exist(a_nrrg, used_pm_value, "DL_PRB_USED_DATA_NRG")
            self._confirm_nrrg_counter_not_exist(a_nrrg, max_pm_value, "DL_PRB_UTIL_SLOT_MAX_NRG")

    def _confirm_nsa_plmn_pm_counters_do_not_exist(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        for a_plmn in self.plmns:
            for counter in NSA_PM_COUNTERS:
                counters = self.bts_counters.extract_cell_plmn_pm_counters(self.raw_counters, cell_id=a_plmn.cell_id,
                                                                           counter_id=counter,
                                                                           mobile_country_code=a_plmn.mcc,
                                                                           mobile_network_code=a_plmn.mnc,
                                                                           t_stamp=tstamp)
                assert not counters or sum(counters.values()) == 0, f"{counter} PLMN counters collected! :{counters}"
                Logger.info(f"{a_plmn} {counter} counter - not exist as expected")

    def _confirm_slice_counter_not_exist(self, a_slice, counter, tstamp):
        counter_slice = self.bts_counters.extract_cell_slice_pm_counters(self.raw_counters, cell_id=a_slice.cell_id,
                                                                         slice_name=a_slice.name,
                                                                         counter_id=counter,
                                                                         mobile_country_code=a_slice.mcc,
                                                                         mobile_network_code=a_slice.mnc,
                                                                         t_stamp=tstamp)
        slice_, counters = counter_slice.popitem()
        assert not counters, f"{slice_} slice counters collected! :{counters}"
        Logger.info(f"{counter} for a slice '{slice_}' - not exist as expected")

    @staticmethod
    def _confirm_nrrg_counter_not_exist(a_nrrg, counter, counter_name):
        assert not counter, f"{a_nrrg} NR resource group counters collected! :{a_nrrg}"
        Logger.info(f"Counter {counter_name} for a NRRG '{a_nrrg}' - not exist as expected")

    def _check_pm_used_slices_counters_not_exist(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        for a_slice in self.slices:
            used_slice_drbs = 0
            try:
                used_slice_drbs = self._confirm_used_slice_counter_exists(a_slice, tstamp)
            except AssertionError:
                Logger.info(f"{PRB_USED_PDSCH_SLICE} for a slice '{a_slice.name}' - confirmed")
            assert used_slice_drbs == 0, \
                f"PRB_USED_PDSCH_SLICE for a slice {a_slice.name} collected with disabled feature!!"

    def _check_ratio_slice_counter_value_not_exist(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        for a_slice in self.slices:
            ratio_slice_used = 0
            try:
                ratio_slice_used = self._confirm_ratio_slice_counter_value(a_slice, tstamp)
            except AssertionError:
                Logger.info(f"{PRB_PDSCH_UTIL_RATIO_SLICE_MAX} for a slice '{a_slice.name}' - confirmed val:0")
            assert ratio_slice_used == 0, \
                f"PRB_PDSCH_UTIL_RATIO_SLICE_MAX for a slice {a_slice.name} collected with disabled feature!!"

    def _check_pm_available_slices_counter_not_exist(self):
        tstamp = self._get_latest_pm_counters_period_epoch()
        available_slices_drbs = 0
        try:
            available_slices_drbs = self._confirm_prb_avail_pdsch_slices_pm_counter_exists(tstamp)
        except AssertionError:
            Logger.info("PRB_AVAIL_PDSCH_SLICES is zero as expected")
        assert available_slices_drbs == 0, "PRB_AVAIL_PDSCH_SLICES collected with disabled feature!!"

    def _wait_for_next_pm_counters_measurements(self, action):
        Logger.info(f"Waiting {PM_COLLECTION_SECONDS}sec for PM Counters to be generated by UEs throughput "
                    f"for *{action.upper()}*")
        sleep(PM_COLLECTION_SECONDS)
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()

    @staticmethod
    def _get_latest_pm_counters_period_epoch():
        latest_pm_counters_epoch = BtsOs().get_epoch() - 2 * PM_COLLECTION_SECONDS
        Logger.info(f"Timestamp for PM Counters collecting: {datetime.fromtimestamp(latest_pm_counters_epoch)}"
                    f" Epoch: {latest_pm_counters_epoch}")
        return latest_pm_counters_epoch

    @property
    def sas_migration_first_step(self):
        return True if Env.ADMIN_CONNECT_STREAM == SAS_MIGRATION_FIRST_STEP_STREAM else False

    @property
    def sas_migration_2nd_step(self):
        return True if Env.STREAM_SW not in STREAMS_BEFORE_SAS_MIGRATION + [SAS_MIGRATION_FIRST_STEP_STREAM] else False

    @property
    def legacy_counter_tree(self):
        return True if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW else False
