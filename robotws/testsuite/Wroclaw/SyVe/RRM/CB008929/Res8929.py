from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkParser import McsharkParser
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminMirroring import BtsAdminMirroring
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputCharts import TputCharts
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import MEDIATEK
from collections import Counter
from time import sleep
import math

MODULATION_64QAM = "QAM64"
MODULATION_256QAM = "QAM256"

MIN_ATTENUATION = 10
MINIMUM_GAIN = 33
AVERAGE_GAIN = 8.4
MINIMUM_AVG_MCS = 26
UL_256QAM_BASE_TPUT_MBITS = 170
PUSCH_CP_INI_256TBL_MCS_27 = "M55302C11027"
PUSCH_CP_SUCC_INI_256TBL_MCS27 = "M55302C13027"
PUSCH_CP_SUCC_ANY_256TBL_MCS27 = "M55302C14027"
PUSCH_CP_INI_VOL_256TBL_MCS27 = "M55304C09027"
PUSCH_CP_INRE_VOL_256TBL_MCS27 = "M55304C10027"
PUSCH_CP_RANK2_256TBL_MCS_27 = "M55303C23027"
PUSCH_CP_RANK1_256TBL_MCS_27 = "M55303C22027"

PUSCH_256TBL_PM_COUNTERS = [PUSCH_CP_INI_256TBL_MCS_27, PUSCH_CP_SUCC_INI_256TBL_MCS27, PUSCH_CP_SUCC_ANY_256TBL_MCS27,
                            PUSCH_CP_INI_VOL_256TBL_MCS27, PUSCH_CP_INRE_VOL_256TBL_MCS27]

PUSCH_CP_RANK_PM_COUNTERS = [PUSCH_CP_RANK1_256TBL_MCS_27, PUSCH_CP_RANK2_256TBL_MCS_27]

LTE_ENB = "MRBTS-40436"
LTE_CELL_ID = 1
GNB_CELL_ID = 1
CELL_DEP_TYPE_SA = "SA"
CELL_DEP_TYPE_NSA = "NSA"
CELL_DEP_TYPE_SANSA = "SA+NSA"
AVG_UL_256QAM = "avg_ul_with_256qam"
LEGACY_STREAMS = ["SBTS22R4", "SBTS23R1", "SBTS23R2", "SBTS23R3"]


class Res8929(CommonSuite):

    def __init__(self):
        super(Res8929, self).__init__()
        self.feature = "CB008929"
        self.ue = Ue(MEDIATEK)
        self.bts_admin = BtsAdminApi()
        self.bts_state = BtsState()
        self.bts_counters = BtsPmCounters()
        self.attenuator = Attenuator()
        self.bts_admin_mirroring = BtsAdminMirroring()
        self.raw_counters = None
        self.pm_start_time = None
        self.ul_data_name = None
        self.max_tput_no_256qam = None
        self.max_tput_with_256qam = None
        self.avg_tput_no_256qam = None
        self.avg_tput_with_256qam = None
        self.avg_tput_with_type_a = None
        self.avg_tput_with_type_b = None
        self.avg_tput_2x4 = None
        self.avg_tput_4x4 = None
        self.avg_tput_actuldatadmrsfdm = None
        self.avg_tput_no_actuldatadmrsfdm = None
        self.all_tputs = {}
        self.cell_dep_type = None

    def prepare_tdd_gnb_for_8929_feature_testing(self):
        self._update_swconfig_for_syslog_flags()
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, "100MHz_NR")
        self.bts_config.perform_full_commissioning(scf_file)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def prepare_tdd_enb_for_8929_feature_testing(self):
        self.startup_manager.update_sw_and_commission_remote_bts(self.feature, LTE_ENB)

    def prepare_environment_and_start_logging_for_8929_feature(self):
        pm_counter_collection_timestamp_shift = 5 * 60
        self.pm_start_time = TimeStamp().unix_timestamp - pm_counter_collection_timestamp_shift
        self.attenuator.set_ports_attenuation(MIN_ATTENUATION)
        self.syslog.start_btslog_on_local_machine()
        self.ue.prepare_ue()
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=GNB_CELL_ID,
                                                               parameter="actUl256Qam", value="false")

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
        Rfrl.common_step_trigger()
        self.ue.try_to_detach_ue()
        self.ue.try_to_get_and_remove_traffic_log_files()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails(target_dir=Env().test_log_dir)
        self.bts_snapshot.collect_snapshot_if_the_test_fails()

    def collect_snapshots_if_suite_fails_and_log_active_faults(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()
        self.startup_manager.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(bts_name=LTE_ENB)
        self.bts_faults.log_active_faults()

    def cell_deployment_type_is_sa_standalone(self):
        self.bts_oam.make_sure_enb_cell_is_blocked(LTE_CELL_ID)
        current_cell_dep_type = self.bts_state.get_all_cells_cell_dep_type_values().get(GNB_CELL_ID)
        Logger.info("Current cellDepType is: {}".format(current_cell_dep_type))
        self.cell_dep_type = CELL_DEP_TYPE_SA
        if current_cell_dep_type == CELL_DEP_TYPE_SA:
            return
        self._update_bts_configuration(self._get_proper_sa_delta(current_cell_dep_type))
        self.bts_admin.wait_for_admin_connection_possibility(interval=60)
        self.startup_manager.wait_for_all_cells_on_air()

    def cell_deployment_type_is_2x4_sa_standalone_with_256qam(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, "2x4SA")
        self.bts_config.perform_full_commissioning(scf_file)
        self.bts_admin.wait_for_admin_connection_possibility(interval=60)
        self.startup_manager.wait_for_all_cells_on_air()
        self.bts_oam.make_sure_enb_cell_is_blocked(LTE_CELL_ID)

    def cell_deployment_type_is_nsa_non_standalone(self):
        self.bts_oam.make_sure_enb_cell_is_unblocked(LTE_CELL_ID)
        current_cell_dep_type = self.bts_state.get_all_cells_cell_dep_type_values().get(GNB_CELL_ID)
        Logger.info("Current cellDepType is: {}".format(current_cell_dep_type))
        self.cell_dep_type = CELL_DEP_TYPE_NSA
        if current_cell_dep_type == CELL_DEP_TYPE_NSA:
            return
        self._update_bts_configuration(self._get_proper_nsa_delta(current_cell_dep_type))
        self.bts_admin.wait_for_admin_connection_possibility(interval=60)
        self.startup_manager.wait_for_x2_connected()
        self.startup_manager.wait_for_all_cells_on_air()

    def uplink_256qam_is_activated(self):
        Logger.info("Activating Uplink 256QAM")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=GNB_CELL_ID,
                                                               parameter="actUl256Qam", value="true")

    def uplink_256qam_is_deactivated(self):
        Logger.info("Deactivating Uplink 256QAM")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=GNB_CELL_ID,
                                                               parameter="actUl256Qam", value="false")

    def pusch_mapping_type_a_is_configured(self):
        Logger.info("Activating PUCSH Mapping TypeA")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=GNB_CELL_ID,
                                                               parameter="puschMappingType", value="TypeA")

    def pusch_mapping_type_b_is_configured(self):
        Logger.info("Activating PUCSH Mapping TypeB")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=GNB_CELL_ID,
                                                               parameter="puschMappingType", value="TypeB")
        sleep(20)

    def actuldatadmrsfdm_is_configured_to_false(self):
        Logger.info("Deactivating actUlDataDmrsFdm")
        self._update_bts_configuration("act_ul_data_dmrs_fdm_off")

    def actuldatadmrsfdm_is_configured_to_true(self):
        Logger.info("Activating actUlDataDmrsFdm")
        self._update_bts_configuration("act_ul_data_dmrs_fdm_on")

    def restore_default_flag_if_the_test_fails(self):
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self.actuldatadmrsfdm_is_configured_to_true()

    def restore_default_bts_configuration_if_the_test_fails(self):
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, "100MHz_NR")
            self.bts_config.perform_full_commissioning(scf_file)
            self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def bts_configuration_is_updated_to_4_uplink_antenna_pipes(self):
        Logger.info("Updating BTS config to 4x4")
        self._update_bts_configuration("2x4sa_to_4x4sa")
        self.bts_admin.wait_for_admin_connection_possibility(interval=90)
        self.startup_manager.wait_for_all_cells_on_air()

    def ue_is_attached(self):
        self.ue.attempt_to_attach_several_times()

    def ue_is_reattached(self):
        Logger.info("Reattaching UE")
        self.ue.detach()
        self.ue.attempt_to_attach_several_times()

    def data_transfer_has_been_started_in_uplink_with_uplink_256qam_deactivated(self):
        self.ul_data_name = "deactivated_256qam"
        self.ue.start_udp_uplink_data_transmission(duration=60, traffic_mb=UL_256QAM_BASE_TPUT_MBITS,
                                                   data_name=self.ul_data_name, buffer_len=1400)

    def data_transfer_has_been_started_in_uplink_with_uplink_256qam_activated(self):
        self.ul_data_name = "activated_256qam"
        self.ue.start_udp_uplink_data_transmission(duration=60, traffic_mb=UL_256QAM_BASE_TPUT_MBITS,
                                                   data_name=self.ul_data_name, buffer_len=1400)

    def data_transfer_has_been_sent_in_both_directions_with_mapping_type_a_configured(self):
        self.avg_tput_with_type_a = self._get_avg_ul_data_transfer_in_both_directions(ul_data_name="avg_ul_with_TypeA",
                                                                                      dl_data_name="avg_dl_with_TypeA")

    def data_transfer_has_been_sent_in_both_directions_with_mapping_type_b_configured(self):

        self.avg_tput_with_type_b = self._get_avg_ul_data_transfer_in_both_directions(ul_data_name="avg_ul_with_TypeB",
                                                                                      dl_data_name="avg_dl_with_TypeB")

    def data_transfer_has_been_sent_in_both_directions_with_actuldatadmrsfdm_not_configured(self):
        self.avg_tput_no_actuldatadmrsfdm = self._get_avg_ul_data_transfer_in_both_directions(
            ul_data_name="avg_ul_no_actuldatadmrsfdm", dl_data_name="avg_dl_no_actuldatadmrsfdm")
        self._display_mcs_information(is_drm_flag_enabled=False)

    def data_transfer_has_been_sent_in_both_directions_with_actuldatadmrsfdm_configured(self):
        self.avg_tput_actuldatadmrsfdm = self._get_avg_ul_data_transfer_in_both_directions(
            ul_data_name="avg_ul_with_actuldatadmrsfdm", dl_data_name="avg_dl_with_actuldatadmrsfdm")
        self._display_mcs_information(is_drm_flag_enabled=True)

    def data_has_been_sent_in_both_directions_with_maximum_throughput_without_256qam_in_uplink(self):
        self.max_tput_no_256qam = self._start_data_transfer_in_both_directions(ul_data_name="max_ul_no_256qam",
                                                                               dl_data_name="max_dl_no_256qam")

    def data_has_been_sent_with_maximum_throughput_in_2x4_uplink(self):
        self.avg_tput_2x4 = self._start_data_transfer_in_both_directions(ul_data_name=f"max_avg_ul_2x4",
                                                                         dl_data_name="max_avg_dl_2x4", dl_size=70)
        Logger.debug(f"Achieved 2x4 average maximum throughputs: {self.avg_tput_2x4}Mbps")
        self.ue.detach()

    def data_has_been_sent_with_maximum_throughput_in_4x4_uplink(self):
        self.avg_tput_4x4 = self._start_data_transfer_in_both_directions(ul_data_name=f"max_avg_ul_4x4",
                                                                         dl_data_name="max_avg_dl_4x4", dl_size=70)
        Logger.debug(f"Achieved 4x4 average maximum throughput: {self.avg_tput_4x4}Mbps")

    def data_has_been_sent_in_both_directions_with_maximum_throughput_with_256qam_in_uplink(self):
        self.max_tput_with_256qam = self._start_data_transfer_in_both_directions(ul_data_name="max_ul_with_256qam",
                                                                                 dl_data_name="max_dl_with_256qam")

    def data_transfer_with_changing_conditions_is_started_in_uplink_with_uplink_256qam_deactivated(self):
        self.avg_tput_no_256qam = self._data_transfer_with_changing_conditions_is_started(
            ul_data_name="avg_ul_no_256qam")

    def data_transfer_with_changing_conditions_is_started_in_uplink_with_uplink_256qam_activated(self):
        self.ue.detach()
        self.ue.attempt_to_attach_several_times()
        self.avg_tput_with_256qam = self._data_transfer_with_changing_conditions_is_started(ul_data_name=AVG_UL_256QAM)

    def data_transfer_has_been_stopped_in_uplink(self):
        self.ue.wait_for_data_transmission_end(data_name=self.ul_data_name)
        self.ue.stop_uplink_transmission(data_name=self.ul_data_name)
        self.ue.detach()

    def l1_common_modulation_order_is_64qam(self):
        self._check_l1_common_modulation_order(modulation=MODULATION_64QAM)

    def l1_common_modulation_order_is_256qam(self):
        self._check_l1_common_modulation_order(modulation=MODULATION_256QAM)

    def l1_common_num_ceaxc_shows_2_pipes_and_256qam_in_use(self):
        self._check_l1_common_num_ce_axc_t(nr_of_pipes=2)

    def l1_common_num_ceaxc_shows_4_pipes_and_256qam_in_use(self):
        self._check_l1_common_num_ce_axc_t(nr_of_pipes=4)

    def l1_common_modulation_order_is_256qam_and_average_mcs_value_is_as_expected(self):
        mcshark_parser = self._check_l1_common_modulation_order("QAM256")
        mcs_values = mcshark_parser.get_parameter_integer_values("mcs")
        Logger.debug("MCS values : {}".format(mcs_values))
        avg_mcs = sum(mcs_values) / len(mcs_values)
        assert avg_mcs >= MINIMUM_AVG_MCS, "Average MCS is too low {:.3f}".format(avg_mcs)
        Logger.info("Checked: Average MCS is {:.3f}".format(avg_mcs))

    def stable_transfers_with_both_mapping_types_are_achieved(self):
        Logger.info("TypeA throughput: {}Mbps".format(self.avg_tput_with_type_a))
        Logger.info("TypeB throughput: {}Mbps".format(self.avg_tput_with_type_b))
        assert UL_256QAM_BASE_TPUT_MBITS * 0.95 <= self.avg_tput_with_type_a <= UL_256QAM_BASE_TPUT_MBITS * 1.05, \
            "TypeA average throughput {}Mbps out of allowed 5% deviation for {}Mbps".format(self.avg_tput_with_type_a,
                                                                                            UL_256QAM_BASE_TPUT_MBITS)
        assert UL_256QAM_BASE_TPUT_MBITS * 0.95 <= self.avg_tput_with_type_b <= UL_256QAM_BASE_TPUT_MBITS * 1.05, \
            "TypeB average throughput {}Mbps out of allowed 5% deviation for {}Mbps".format(self.avg_tput_with_type_b,
                                                                                            UL_256QAM_BASE_TPUT_MBITS)

    def stable_transfers_with_both_actuldatadmrsfdm_values_are_achieved(self):
        Logger.info(f"actUlDataDmrsFdm False: {self.avg_tput_no_actuldatadmrsfdm}Mbps")
        Logger.info(f"actUlDataDmrsFdm True: {self.avg_tput_actuldatadmrsfdm}Mbps")
        assert self.avg_tput_actuldatadmrsfdm > self.avg_tput_no_actuldatadmrsfdm, \
            "actUlDataDmrsFdm True flag have not improved the throughput"
        assert self.avg_tput_no_actuldatadmrsfdm > UL_256QAM_BASE_TPUT_MBITS / 2, \
            "Minimal required UL Tput: {}Mbps not achieved: {}Mbps!".format(UL_256QAM_BASE_TPUT_MBITS // 2,
                                                                            self.avg_tput_no_actuldatadmrsfdm)

    def stable_transfers_with_both_configurations_of_antenna_pipes_are_achieved(self):
        allowed_deviation = 0.15
        Logger.info(f"2x4 Throughput: {self.avg_tput_2x4}Mbps")
        Logger.info(f"4x4 Throughput: {self.avg_tput_4x4}Mbps")
        lowest_allowed_4x4tput = self.avg_tput_4x4 * (1 - allowed_deviation)
        assert lowest_allowed_4x4tput > self.avg_tput_2x4, \
            f"Throughput (Mbps) were too different in 2x4:{self.avg_tput_2x4}Mbps" \
            f" and 4x4:{self.avg_tput_4x4}Mbps configurations"

    def uplink_throughput_gain_percentage_compared_to_64qam_is_at_least_as_expected(self):
        real_gain = (self.max_tput_with_256qam - self.max_tput_no_256qam) / self.max_tput_no_256qam * 100
        assert math.ceil(real_gain) >= MINIMUM_GAIN, \
            "Real gain is to low {:.1f}% vs expected {:.2f}%".format(real_gain, MINIMUM_GAIN)
        Logger.info("Real throughput gain is {:.2f}% in peak".format(real_gain))

    def uplink_throughput_is_8_and_four_tenths_percent_better_with_expected_gain(self):
        avg_gain = (self.avg_tput_with_256qam - self.avg_tput_no_256qam) / self.avg_tput_no_256qam * 100
        tput_chart = TputCharts().draw_tput_change_chart(self.all_tputs, chart_name=self.cell_dep_type,
                                                         title='Tput dependency of attenuation increased periodically')
        Logger.picture(tput_chart)
        assert avg_gain >= AVERAGE_GAIN, \
            "Average gain is to low {:.1f}% vs expected {:.1f}%".format(avg_gain, AVERAGE_GAIN)
        Logger.info("Real throughput gain is {:.1f}% in average".format(avg_gain))

    def pusch_256tbl_pm_counters_are_updated(self):
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()
        self.raw_counters = self.bts_counters.get_raw_pm_counters(PUSCH_256TBL_PM_COUNTERS + PUSCH_CP_RANK_PM_COUNTERS)
        for counter in PUSCH_256TBL_PM_COUNTERS:
            self.bts_counters.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self.raw_counters,
                                                                                           counter_id=counter,
                                                                                           cell_id=GNB_CELL_ID,
                                                                                           t_stamp=self.pm_start_time)

    def pusch_cp_rank1_256tbl_pm_counter_is_updated(self):
        self.bts_counters.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self.raw_counters,
                                                                                       PUSCH_CP_RANK1_256TBL_MCS_27,
                                                                                       cell_id=GNB_CELL_ID,
                                                                                       t_stamp=self.pm_start_time)

    def pusch_cp_rank2_256tbl_pm_counter_is_updated(self):
        self.bts_counters.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self.raw_counters,
                                                                                       PUSCH_CP_RANK2_256TBL_MCS_27,
                                                                                       cell_id=GNB_CELL_ID,
                                                                                       t_stamp=self.pm_start_time)

    def packet_capturing_is_started_on_bts(self):
        self.bts_admin_mirroring.start_interface_mirroring_l1l2(capturing_time=7)

    @staticmethod
    def _get_proper_sa_delta(current_cell_dep_type):
        if Env.STREAM_SW in LEGACY_STREAMS:
            return "nsa_legacy_to_sa" if current_cell_dep_type == CELL_DEP_TYPE_NSA else "sansa_2_sa"
        return "nsa_to_sa" if current_cell_dep_type == CELL_DEP_TYPE_NSA else "sansa_2_sa"

    @staticmethod
    def _get_proper_nsa_delta(current_cell_dep_type):
        if Env.STREAM_SW in LEGACY_STREAMS:
            return "sa_legacy_to_nsa" if current_cell_dep_type == CELL_DEP_TYPE_SA else "sansa_2_nsa"
        return "sa_to_nsa" if current_cell_dep_type == CELL_DEP_TYPE_SA else "sansa_2_nsa"

    def _update_bts_configuration(self, delta):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().get_delta_path_for_feature(self.feature, delta))

    def _start_data_transfer_in_both_directions(self, ul_data_name, dl_data_name, dl_size=900):
        traffic_mb = self._get_traffic_mb_for_cell_dep_type()
        self.ue.start_tcp_uplink_data_transmission(duration=60, traffic_mb=traffic_mb,
                                                   data_name=ul_data_name, buffer_len=900)
        self.ue.start_udp_downlink_data_transmission(duration=60, traffic_mb=70,
                                                     data_name=dl_data_name, buffer_len=dl_size)
        self.packet_capturing_is_started_on_bts()
        self.ue.wait_for_data_transmission_end(data_name=ul_data_name)
        self.ue.wait_for_data_transmission_end(data_name=dl_data_name)
        max_tput = self.ue.get_maximum_megabit_data_transfer(data_name=ul_data_name, analyze_entries=50)
        self.ue.stop_uplink_transmission(data_name=ul_data_name)
        self.ue.stop_downlink_transmission(data_name=dl_data_name)
        Logger.info(f"Traffic '{ul_data_name}' has UL max: {max_tput:.1f}Mbps")
        return max_tput

    def _get_avg_ul_data_transfer_in_both_directions(self, ul_data_name, dl_data_name):
        self.ue.start_udp_uplink_data_transmission(duration=90, traffic_mb=UL_256QAM_BASE_TPUT_MBITS,
                                                   data_name=ul_data_name, buffer_len=900)
        self.ue.start_udp_downlink_data_transmission(duration=90, traffic_mb=100,
                                                     data_name=dl_data_name, buffer_len=900)
        self.packet_capturing_is_started_on_bts()
        self.ue.wait_for_data_transmission_end(data_name=ul_data_name)
        self.ue.wait_for_data_transmission_end(data_name=dl_data_name)
        avg_tput = self.ue.get_average_megabits_data_transfer(data_name=ul_data_name, analyze_entries=70)
        self.ue.stop_uplink_transmission(data_name=ul_data_name)
        self.ue.stop_downlink_transmission(data_name=dl_data_name)
        self.ue.detach()
        return avg_tput

    def _data_transfer_with_changing_conditions_is_started(self, ul_data_name):
        time_for_edge_tputs = 5
        traffic_mb = self._get_traffic_mb_for_cell_dep_type()
        sleep(time_for_edge_tputs)
        self.ue.start_tcp_uplink_data_transmission(duration=145, traffic_mb=traffic_mb,
                                                   data_name=ul_data_name, packet_size=1000)
        self.attenuator.increase_ports_attenuation_periodically(
            delta_attenuation=4, interval=1, number_of_repetition=15)
        sleep(time_for_edge_tputs)
        avg_tput = self.ue.get_average_megabits_data_transfer(ul_data_name, analyze_entries=135)
        self.all_tputs[ul_data_name] = self.ue.get_all_throughput_values(data_name=ul_data_name, analyze_entries=135)
        self.ue.stop_uplink_transmission(data_name=ul_data_name)
        self.ue.detach()
        self.attenuator.set_ports_attenuation(MIN_ATTENUATION)
        return avg_tput

    def _get_traffic_mb_for_cell_dep_type(self):
        current_cell_dep_type = self.bts_state.get_all_cells_cell_dep_type_values().get(GNB_CELL_ID)
        return 130 if current_cell_dep_type == CELL_DEP_TYPE_NSA else 250

    def _check_l1_common_modulation_order(self, modulation):
        pcap_path = self.bts_admin_mirroring.download_pcap_file_from_the_bts("expect_{}".format(modulation.lower()))
        mcshark_parser = McsharkParser()
        modulations = mcshark_parser.convert_pcap_with_filter_and_get_l1_common_parameter_values(
            param_name="modulationOrder", l1_param="l1_common_modulationOrder_t",
            pcap_file=pcap_path, tshark_filter="uldata_puschreceivereq")
        return self._count_and_check_modulation_from_pcap(mcshark_parser, modulation, modulations)

    @staticmethod
    def _count_and_check_modulation_from_pcap(mcshark_parser, modulation, modulations):
        unique_modulations = Counter(modulations)
        Logger.info("Modulation types found in pcap: {}".format(unique_modulations))
        assert modulation in unique_modulations.keys(), \
            "Different modulation type than expected {}, modulations found:{}".format(modulation, unique_modulations)
        nr_of_expected_modulation_entries = unique_modulations.get(modulation)
        nr_of_all_modulations_entries = sum(unique_modulations.values())
        assert nr_of_expected_modulation_entries > nr_of_all_modulations_entries * 0.95, \
            "There were few different modulation orders {}".format(unique_modulations)
        Logger.info("Expected modulation {} found".format(modulation))
        return mcshark_parser

    def _check_l1_common_num_ce_axc_t(self, nr_of_pipes):
        pipes_nr = "NUM_C_EAXC_{}".format(nr_of_pipes)
        pcap_path = self.bts_admin_mirroring.download_pcap_file_from_the_bts("expect_eaxc_{}".format(nr_of_pipes))
        mcshark_parser = McsharkParser()
        pipes = mcshark_parser.convert_pcap_with_filter_and_get_l1_common_parameter_values(
            param_name="numCeAxCIndex", l1_param="l1_common_numCeAxC_t",
            pcap_file=pcap_path, tshark_filter="uldata_puschreceivereq")
        unique_pipes = set(pipes)
        Logger.info("Antenna pipes types found in pcap: {}".format(unique_pipes))
        assert pipes_nr in unique_pipes, \
            "Different Pipes nr than expected {}, pipes found:{}".format(pipes_nr, unique_pipes)
        Logger.info("Expected antenna pipes entry '{}' found".format(unique_pipes))
        modulations = mcshark_parser.convert_pcap_with_filter_and_get_l1_common_parameter_values(
            param_name="modulationOrder", l1_param="l1_common_modulationOrder_t",
            pcap_file=pcap_path, tshark_filter="uldata_puschreceivereq")
        self._count_and_check_modulation_from_pcap(mcshark_parser, MODULATION_256QAM, modulations)

    def _display_mcs_information(self, is_drm_flag_enabled):
        pcap_path = self.bts_admin_mirroring.download_pcap_file_from_the_bts(
            "actuldatadmrsfdm_{}".format(is_drm_flag_enabled))
        mcshark_parser = McsharkParser()
        mcshark_parser.convert_pcap_file_with_filter_using_mcshark(pcap_path, "uldata_puschreceivereq")
        mcs_values = mcshark_parser.get_parameter_integer_values("mcs")
        Logger.debug("MCS values for actuldatadmrsfdm set to {}:\n {}".format(mcs_values, is_drm_flag_enabled))
        avg_mcs = sum(mcs_values) / len(mcs_values)
        drm_flag_info = "Drm flag {}".format("enabled" if is_drm_flag_enabled else "disabled")
        if avg_mcs < MINIMUM_AVG_MCS:
            Logger.warning("Average MCS is too low {:.3f} for {}".format(avg_mcs, drm_flag_info))
        else:
            Logger.info("Checked: Average MCS is {:.3f} for {}".format(avg_mcs, drm_flag_info))

    @staticmethod
    def _update_swconfig_for_syslog_flags():
        syslog_flags = ["0x420000=1", "0x10041=2", "0x590072=1", "0x41001b=1"]
        Swconfig().update_swconfig_flags(syslog_flags)
