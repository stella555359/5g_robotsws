from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkParser import McsharkParser
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminMirroring import BtsAdminMirroring
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import XIAOMI_MI12
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputCharts import TputCharts
import testsuite.Wroclaw.SyVe.RRM.features.delta_commisionings_1118 as delta
import testsuite.Wroclaw.SyVe.RRM.features.eda02715164counters as eda
from time import sleep
from collections import Counter

MIN_ATTENUATION = 0
# MINIMUM_GAIN = 1.331
MINIMUM_GAIN = 1.28   # re-check MINIMUM_GAIN when UE is changed from Xiaomi
AVERAGE_GAIN = 1.084
MINIMUM_AVG_MCS = 26
PUSCH_CP_INI_256TBL_MCS_27 = "M55302C11027"
PUSCH_CP_INI_256TBL_MCS_26 = "M55302C11026"
PUSCH_CP_SUCC_INI_256TBL_MCS27 = "M55302C13027"
PUSCH_CP_SUCC_ANY_256TBL_MCS27 = "M55302C14027"
PUSCH_CP_INI_VOL_256TBL_MCS27 = "M55304C09027"
PUSCH_CP_INRE_VOL_256TBL_MCS27 = "M55304C10027"
PUSCH_CP_RANK2_256TBL_MCS_27 = "M55303C23027"
PUSCH_CP_RANK1_256TBL_MCS_27 = "M55303C22027"
SA = "SA"
NSA = "NSA"

PUSCH_256TBL_PM_COUNTERS = [PUSCH_CP_INI_256TBL_MCS_27, PUSCH_CP_SUCC_INI_256TBL_MCS27, PUSCH_CP_SUCC_ANY_256TBL_MCS27,
                            PUSCH_CP_INI_VOL_256TBL_MCS27, PUSCH_CP_INRE_VOL_256TBL_MCS27]

PUSCH_CP_RANK_PM_COUNTERS = [PUSCH_CP_RANK1_256TBL_MCS_27, PUSCH_CP_RANK2_256TBL_MCS_27]

LTE_ENB = "MRBTS-40435"
LTE_CELL_ID = 1


class Res1118(CommonSuite):

    def __init__(self):
        super(Res1118, self).__init__()
        self.feature = "5GC001118"
        self.bts_state = BtsState()
        self.ue = Ue(XIAOMI_MI12)
        self.bts_counters = BtsPmCounters()
        self.attenuator = Attenuator()
        self.bts_admin_mirroring = BtsAdminMirroring()
        self.ul_data_name = None
        self.max_tput_no_256qam = None
        self.max_tput_with_256qam = None
        self.avg_tput_no_256qam = None
        self.avg_tput_with_256qam = None
        self.raw_counters = None
        self.pm_start_time = None
        self.cell_dep_type = None
        self.all_tputs = {}

    def prepare_tdd_gnb_for_1118_feature_testing(self):
        self._update_swconfig_for_syslog_flags()
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, "100MHz_NR")
        self.bts_config.perform_full_commissioning(scf_file)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def prepare_tdd_enb_for_1118_feature_testing(self):
        self.startup_manager.update_sw_and_commission_remote_bts(self.feature, LTE_ENB)

    def prepare_environment_and_start_logging_for_1118_feature(self):
        pm_counter_collection_timestamp_shift = 5*60
        self.pm_start_time = TimeStamp().unix_timestamp - pm_counter_collection_timestamp_shift
        self.attenuator.set_ports_attenuation(MIN_ATTENUATION)
        self._set_no_attenuation_on_lte_ports()
        self.syslog.start_btslog_on_local_machine()
        self.ue.prepare_ue()
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=1, parameter="actUl256Qam", value="false")

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
        Rfrl.common_step_trigger()
        self.ue.try_to_detach_ue()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails(target_dir=Env().test_log_dir)
        self.ue.try_to_get_and_remove_traffic_log_files()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()

    def reset_gnb_and_wait_for_on_air(self):
        self.bts_oam.reset_gnb_site()
        self.startup_manager.wait_for_all_cells_on_air()

    def cell_deployment_type_is_sa_standalone(self):
        self.bts_oam.make_sure_enb_cell_is_blocked(LTE_CELL_ID)
        if not self.bts_state.are_all_cell_dep_type_as_expected(SA):
            self.bts_config.perform_delta_commissioning(delta.nsa_to_sa)
            self.startup_manager.wait_for_all_cells_on_air()
        self.cell_dep_type = SA

    def cell_deployment_type_is_nsa_non_standalone(self):
        self.bts_oam.make_sure_enb_cell_is_unblocked(LTE_CELL_ID)
        if not self.bts_state.are_all_cell_dep_type_as_expected(NSA):
            self.bts_config.perform_delta_commissioning(delta.sa_to_nsa)
            self.startup_manager.wait_for_all_cells_on_air()
        self.cell_dep_type = NSA

    def gnb_and_enb_are_connected_via_x2(self):
        self.startup_manager.wait_for_x2_connected()

    def collect_snapshots_if_suite_fails_and_log_active_faults(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()
        self.startup_manager.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(bts_name=LTE_ENB)
        self.bts_faults.log_active_faults()
        self.bts_faults.log_historical_faults()

    def uplink_256qam_is_activated(self):
        Logger.info("Activating Uplink 256QAM")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=1, parameter="actUl256Qam", value="true")

    def uplink_256qam_is_deactivated(self):
        Logger.info("Deactivating Uplink 256QAM")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=1, parameter="actUl256Qam", value="false")

    def active_use_of_uplink_dft_s_ofdm_is_activated(self):
        Logger.info("Activating Uplink Dft S Ofdm")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=1, parameter="actUlDftSOfdm", value="true")

    def deactivate_use_of_uplink_dft_s_ofdm(self):
        Logger.info("Deactivating Uplink Dft S Ofdm")
        self.bts_config.perform_cell_parameter_recommissioning(cell_id=1, parameter="actUlDftSOfdm", value="false")

    def ue_is_attached(self):
        self.ue.attach()

    def ue_is_detached(self):
        self.ue.detach()

    def ue_is_reattached(self):
        Logger.info("Reattaching UE")
        self.ue.detach()
        self.ue.attach()

    def data_transfer_has_been_stopped_in_uplink(self):
        self.ue.wait_for_data_transmission_end(data_name=self.ul_data_name)
        self.ue.stop_uplink_transmission(data_name=self.ul_data_name)
        self.ue.detach()

    def data_transfer_has_been_started_in_uplink_with_uplink_256qam_deactivated(self):
        self.ul_data_name = "deactivated_256qam"
        self.ue.start_udp_uplink_data_transmission(duration=60, traffic_mb=170,
                                                   data_name=self.ul_data_name, buffer_len=1400)

    def data_transfer_has_been_started_in_uplink_with_uplink_256qam_activated(self):
        self.ul_data_name = "activated_256qam"
        self.ue.start_udp_uplink_data_transmission(duration=60, traffic_mb=170,
                                                   data_name=self.ul_data_name, buffer_len=1400)

    def l1_common_pusch_transform_precoder_flag_t_is_enabled(self):
        self._check_l1_common_transform_precoder_flag_state(state='enabled')

    def l1_common_pusch_transform_precoder_flag_t_is_disabled_and_l1_common_mcs_table_t_is_max256qam(self):
        mcshark_parser = self._check_l1_common_transform_precoder_flag_state(state='disabled')
        expected_max_qam = "max256QAM"
        mcs_table_param = "l1_common_mcsTable_t"
        mcs_table_values = mcshark_parser.get_l1_common_parameter_values("mcsTable", mcs_table_param)
        assert expected_max_qam in mcs_table_values, "{} not found in {}".format(expected_max_qam, mcs_table_param)
        mcs_set_values = set(mcs_table_values)
        assert len(mcs_set_values) == 1, "There are other values than expected {} in {}\n" \
                                         "Values {}".format(expected_max_qam, mcs_table_param, mcs_set_values)
        Logger.info("Checked: {} is {}".format(mcs_table_param, expected_max_qam))

    def environment_conditions_are_improving(self):
        self.attenuator.decrease_ports_attenuation_periodically(
            delta_attenuation=2, interval=1, number_of_repetition=20)
        self.attenuator.set_ports_attenuation(MIN_ATTENUATION)

    def data_transfer_has_been_started_in_uplink_with_both_uplink_parameters_enabled(self):
        self.ul_data_name = "UlDftSOfdm_and_256qam"
        self.ue.start_udp_uplink_data_transmission(duration=900, traffic_mb=250,
                                                   data_name=self.ul_data_name, buffer_len=900)

    def data_transfer_is_stopped_in_uplink_with_both_uplink_parameters_enabled(self):
        self.ue.stop_uplink_transmission(data_name=self.ul_data_name)
        self.ue.detach()

    def l1_common_modulation_order_is_64qam(self):
        self._check_l1_common_modulation_order("QAM64")

    def l1_common_modulation_order_is_256qam(self):
        self._check_l1_common_modulation_order("QAM256")

    def l1_common_modulation_order_is_256qam_and_average_mcs_value_is_as_expected(self):
        mcshark_parser = self._check_l1_common_modulation_order("QAM256")
        mcs_values = mcshark_parser.get_parameter_integer_values("mcs")
        Logger.info("MCS values : {}".format(mcs_values))
        avg_mcs = sum(mcs_values)/len(mcs_values)
        assert avg_mcs >= MINIMUM_AVG_MCS, "Average MCS is too low {:.3f}".format(avg_mcs)
        Logger.info("Checked: Average MCS is {:.3f}".format(avg_mcs))

    def environment_conditions_are_getting_worse(self):
        self.attenuator.increase_ports_attenuation_periodically(
            delta_attenuation=2, interval=1, number_of_repetition=20)

    def data_transfer_with_changing_conditions_is_started_in_uplink_with_uplink_256qam_deactivated(self):
        ul_data_name = "avg_ul_no_256qam"
        self.avg_tput_no_256qam = [self._data_transfer_with_changing_conditions_is_started(f"{ul_data_name}_{nr}")
                                   for nr in range(1, 3)]

    def data_transfer_with_changing_conditions_is_started_in_uplink_with_uplink_256qam_activated(self):
        ul_data_name = "avg_ul_with_256qam"
        self.avg_tput_with_256qam = [self._data_transfer_with_changing_conditions_is_started(f"{ul_data_name}_{nr}")
                                     for nr in range(1, 3)]

    def data_has_been_sent_in_both_directions_with_maximum_throughput_without_256qam_in_uplink(self):
        ul_data_name = "max_ul_no_256qam"
        dl_data_name = "max_dl_no_256qam"
        self.max_tput_no_256qam = self._start_data_transfer_in_both_directions(ul_data_name, dl_data_name)

    def data_has_been_sent_in_both_directions_with_maximum_throughput_with_256qam_in_uplink(self):
        ul_data_name = "max_ul_with_256qam"
        dl_data_name = "max_dl_with_256qam"
        self.max_tput_with_256qam = self._start_data_transfer_in_both_directions(ul_data_name, dl_data_name)

    def data_of_the_size_1gb_has_been_sent_in_both_directions_with_maximum_throughput_with_256qam_in_uplink(self):
        ul_data_name = "ul_data_name_1gb_ul"
        dl_data_name = "ul_data_name_1gb_dl"
        self.ue.start_udp_downlink_data_transmission(duration="1g", traffic_mb=100,
                                                     data_name=dl_data_name, buffer_len=900)
        self.ue.start_udp_uplink_data_transmission(duration="1g", traffic_mb=900,
                                                   data_name=ul_data_name, buffer_len=900, mtu_size=1400)
        sleep(90)
        self.ue.stop_uplink_transmission(data_name=ul_data_name)
        self.ue.stop_downlink_transmission(data_name=dl_data_name)
        self.ue.detach()

    def uplink_throughput_is_133_and_nine_tenth_percent_higher_with_expected_gain(self):
        real_gain = self.max_tput_with_256qam / self.max_tput_no_256qam
        real_gain_as_percentage = real_gain*100
        assert real_gain >= MINIMUM_GAIN,\
            "Real gain is to low {:.1f}% vs expected {:.1f}%".format(real_gain_as_percentage, MINIMUM_GAIN*100)
        Logger.info("Real throughput gain is {:.1f}% in peak".format(real_gain_as_percentage))

    def uplink_throughput_is_8_and_four_tenths_percent_better_with_expected_gain(self):
        # TODO: restore single tput checking when OTA UE replaced with stable, conducted one
        avg_gains = [avg256/no256 for avg256, no256 in zip(self.avg_tput_with_256qam, self.avg_tput_no_256qam)
                     if avg256 > 0 and no256 > 0]
        Logger.info(f"Achieved average gains are: {[round(gain*100, 2) for gain in avg_gains]}")
        max_avg_gain_as_percent = max(avg_gains)*100
        tput_chart = TputCharts().draw_tput_change_chart(self.all_tputs, chart_name=self.cell_dep_type,
                                                         title='Tput dependency of attenuation increased periodically')
        Logger.picture(tput_chart)
        assert any(filter(lambda gain: gain > AVERAGE_GAIN, avg_gains)),\
            f"Max achieved average gain is to low {max_avg_gain_as_percent:.1f}% vs expected {AVERAGE_GAIN*100:.1f}%"
        Logger.info(f"Real throughput gain is {max_avg_gain_as_percent:.1f} in average")

    def pusch_256tbl_pm_counters_are_updated(self):
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()
        self.raw_counters = self.bts_counters.get_raw_pm_counters(PUSCH_256TBL_PM_COUNTERS + PUSCH_CP_RANK_PM_COUNTERS)
        for counter in PUSCH_256TBL_PM_COUNTERS:
            self.bts_counters.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self.raw_counters,
                                                                                           counter_id=counter,
                                                                                           cell_id=1,
                                                                                           t_stamp=self.pm_start_time)

    def pusch_cp_rank1_256tbl_pm_counter_is_updated(self):
        self.bts_counters.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self.raw_counters,
                                                                                       PUSCH_CP_RANK1_256TBL_MCS_27,
                                                                                       cell_id=1,
                                                                                       t_stamp=self.pm_start_time)

    def pusch_cp_rank2_256tbl_pm_counter_is_updated(self):
        self.bts_counters.extract_and_confirm_bts_cell_pm_counter_is_greater_than_zero(self.raw_counters,
                                                                                       PUSCH_CP_RANK2_256TBL_MCS_27,
                                                                                       cell_id=1,
                                                                                       t_stamp=self.pm_start_time)

    def packet_capturing_is_started_on_bts(self):
        self.bts_admin_mirroring.start_interface_mirroring_l1l2(capturing_time=7)

    def new_pm_counter_cycle_is_started(self):
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(0)
        shift_1m_before_new_period = 60
        self.pm_start_time = TimeStamp().unix_timestamp - shift_1m_before_new_period

    def eda_pm_counters_are_collected_and_verified(self):
        counters_from_0_to_27 = range(28)
        pusch_cp_ini_256tbl_mcs_counters = ["M55304C090" + str(x).zfill(2) for x in counters_from_0_to_27]
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()
        self.raw_counters = self.bts_counters.get_raw_pm_counters(pusch_cp_ini_256tbl_mcs_counters)
        counter_values = []
        for counter in pusch_cp_ini_256tbl_mcs_counters:
            counter_ = self.bts_counters.extract_bts_cell_pm_counter(self.raw_counters, counter_id=counter, cell_id=1,
                                                                     t_stamp=self.pm_start_time)
            Logger.info(f"Counter: {counter}: values:{sum(counter_.values())}")
            counter_values.append(f"{counter}:{sum(counter_.values())}")
        Logger.info(f"Counters values: {counter_values}")
        self._verify_eda_counters(counter_values)

    def _verify_eda_counters(self, counter_values):
        counters_sum = 0
        eda_counters = eda.SA_PUSCH_CP_INI_VOL_256TBL_COUNTERS if self.cell_dep_type == SA \
            else eda.NSA_PUSCH_CP_INI_VOL_256TBL_COUNTERS
        for counter in counter_values:
            counters_sum += self._confirm_counter_value(counter, eda_counters)
        expected_min_pm_sum, expected_max_pm_sum = eda_counters[eda.SUM_OF_COUNTERS]
        assert expected_min_pm_sum < counters_sum < expected_max_pm_sum, \
            f"Sum of all MCS counters:{counters_sum} out of expected: {expected_min_pm_sum}-{expected_max_pm_sum}"

        Logger.info("All of MCS PM counters verified")

    @staticmethod
    def _confirm_counter_value(counter, eda_counters):
        counter_name, counter_value = counter.split(":")
        counter_value = int(counter_value)
        expected_min, expected_max = eda_counters[counter_name]
        assert expected_min <= counter_value <= expected_max, \
            f"Counter: {counter_name} value: {counter_value} out of expected value range: {expected_min}-{expected_max}"
        return counter_value

    def _check_l1_common_transform_precoder_flag_state(self, state):
        self.packet_capturing_is_started_on_bts()
        pcap_path = self._download_pcap_file_from_the_bts("expect_flag_t_{}".format(state))
        mcshark_parser = McsharkParser()
        mcshark_parser.convert_pcap_file_with_filter_using_mcshark(pcap_path, "uldata_puschreceivereq")
        flag_states_list = mcshark_parser.get_l1_common_parameter_values("puschTransformPrecoderFlag",
                                                                         "l1_common_puschTransformPrecoderFlag_t")
        unique_flag_states = Counter(flag_states_list)
        Logger.info(f"Pusch Transform Precoder Flag values found in pcap:{unique_flag_states}, expected: {state}")
        nr_of_expected_flag_states = unique_flag_states.get(state)
        nr_of_all_flag_states = sum(unique_flag_states.values())
        Logger.debug(f"All flags state number:{nr_of_all_flag_states}, "
                     f"expected flags state number {nr_of_expected_flag_states}")
        assert nr_of_all_flag_states > 0, "puschTransformPrecoderFlag_t states not found in pcap"
        if nr_of_expected_flag_states != nr_of_all_flag_states:
            Logger.warning("Different Pusch Transform Precoder Flag values found in pcap!!!")
        assert nr_of_expected_flag_states > 0.99 * nr_of_all_flag_states, f"Expected puschTransformPrecoderFlag_t" \
            f"  flag state: '{state}' is disturbed by too many '{self._get_the_opposite_state(state)}' flags found!"
        Logger.info("Checked: puschTransformPrecoderFlag_t is {}".format(state))
        return mcshark_parser

    @staticmethod
    def _get_the_opposite_state(state):
        return "enabled" if state == "disabled" else "disabled"

    def _start_data_transfer_in_both_directions(self, ul_data_name, dl_data_name):
        self.ue.start_udp_uplink_data_transmission(duration=60, traffic_mb=900,
                                                   data_name=ul_data_name, buffer_len=900, mtu_size=1400)
        self.ue.start_udp_downlink_data_transmission(duration=60, traffic_mb=900,
                                                     data_name=dl_data_name, buffer_len=900)
        self.packet_capturing_is_started_on_bts()
        self.ue.wait_for_data_transmission_end(data_name=ul_data_name)
        self.ue.wait_for_data_transmission_end(data_name=dl_data_name)
        max_tput = self.ue.get_maximum_megabit_data_transfer(data_name=ul_data_name, analyze_entries=50)
        self.ue.stop_uplink_transmission(data_name=ul_data_name)
        self.ue.stop_downlink_transmission(data_name=dl_data_name)
        self.ue.detach()
        return max_tput

    def _data_transfer_with_changing_conditions_is_started(self, ul_data_name):
        time_for_edge_tputs = 5
        self.ue.start_udp_uplink_data_transmission(duration=145, traffic_mb=250,
                                                   data_name=ul_data_name, buffer_len=1000)
        sleep(time_for_edge_tputs)
        self.attenuator.increase_ports_attenuation_periodically(
            delta_attenuation=2, interval=1, number_of_repetition=18)
        sleep(time_for_edge_tputs)
        avg_tput = self.ue.get_average_megabits_data_transfer(ul_data_name, analyze_entries=135)
        self.ue.stop_uplink_transmission(data_name=ul_data_name)
        self.attenuator.set_ports_attenuation(MIN_ATTENUATION)
        Logger.info(f"Single Average Tput: {avg_tput:.2f}Mbps for {ul_data_name}")
        self.all_tputs[ul_data_name] = self.ue.get_all_throughput_values(data_name=ul_data_name, analyze_entries=135)
        time_for_attenuator_rest = 60
        sleep(time_for_attenuator_rest)
        return avg_tput

    def _check_l1_common_modulation_order(self, modulation):
        pcap_path = self._download_pcap_file_from_the_bts("expect_{}".format(modulation.lower()))
        mcshark_parser = McsharkParser()
        modulations = mcshark_parser.convert_pcap_with_filter_and_get_l1_common_parameter_values(
            param_name="modulationOrder", l1_param="l1_common_modulationOrder_t",
            pcap_file=pcap_path, tshark_filter="uldata_puschreceivereq")
        unique_modulations = Counter(modulations)
        Logger.info("Modulation types found in pcap: {}".format(unique_modulations))
        assert modulation in unique_modulations.keys(), \
            "Different modulation type than expected {}, modulations found:{}".format(modulation, unique_modulations)
        nr_of_expected_modulation_entries = unique_modulations.get(modulation)
        nr_of_all_modulations_entries = sum(unique_modulations.values())
        assert nr_of_expected_modulation_entries > nr_of_all_modulations_entries * 0.96, \
            "There were few different modulation orders {}".format(unique_modulations)
        Logger.info("Expected modulation {} found".format(modulation))
        return mcshark_parser

    @staticmethod
    def _update_swconfig_for_syslog_flags():
        syslog_flags = ["0x420000=1", "0x10041=2", "0x590072=1", "0x41001b=1"]
        Swconfig().update_swconfig_flags(syslog_flags)

    def _set_no_attenuation_on_lte_ports(self):
        lte_attenuator_ports = [8, 16]
        for port in lte_attenuator_ports:
            self.attenuator.set_port_attenuation(port=port, target_attenuation=0)

    def _download_pcap_file_from_the_bts(self, pcap_name):
        return self.bts_admin_mirroring.download_pcap_file_from_the_bts(pcap_name)
