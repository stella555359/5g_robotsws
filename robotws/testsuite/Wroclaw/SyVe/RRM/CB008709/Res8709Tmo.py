from testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib import SliceSchedulingLib, NRResourceGroup, TDD
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import CELL_BLOCKED_FAULT_ID
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import GALAXY_S23, OPPO
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


NEIGHBOURING_GNB_CELLS = [cell_id for cell_id in range(101, 106)]
USED_NRRG_MIN_QUOTA = 50


class Res8709Tmo(SliceSchedulingLib):
    def __init__(self):
        super(Res8709Tmo, self).__init__()
        self.feature = "CB008709"
        self.ue1_slice1 = None
        self.ue2_slice1 = None
        self._create_ues()
        self.cell_id = 100

    def prepare_bts_for_feature_testing(self):
        try:
            self.syslog.start_btslog_on_local_machine(name=Env.BTSLOG_5G_SUITE_ALIAS)
            self.bts_faults.add_active_fault_to_allowed_list(CELL_BLOCKED_FAULT_ID)
            self.startup_manager.confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation()
            self._commission_tmo_test_line()
            self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        finally:
            self.syslog.stop_btslog(name=Env.BTSLOG_5G_SUITE_ALIAS)
        self.suite_setup_done = True

    def gnb_is_up_and_running_in_a_sa_nsa_mode_in_tdd_with_uplink_sas_enabled_with_proper_quotas_for_nrrgs(self):
        self._configure_ul_tdd_nrresource_groups()

    def _commission_tmo_test_line(self):
        scf_path = ScfPathFinder().get_scf_path_for_feature(self.feature, self.local_gnb_id)
        self.bts_config.perform_full_commissioning(scf_path)

    def prepare_environment_and_start_logging(self):
        self._prepare_ues()
        self.syslog.start_btslog_on_local_machine()

    def multiple_ues_are_attached_to_the_tdd_cell_with_various_radio_conditions_with_different_dnns(self):
        self.bts_oam.make_sure_gnb_cells_are_blocked(NEIGHBOURING_GNB_CELLS)
        self._attach_all_ues()

    def _create_ues(self):
        self.ue1_slice1 = Ue(type_=GALAXY_S23, ue_id=1)
        self.ue2_slice1 = Ue(type_=OPPO, ue_id=2)

    def _prepare_ues(self):
        self.ue1_slice1.prepare_ue()
        self.ue2_slice1.prepare_ue()

    def _attach_all_ues(self):
        self.ue1_slice1.attach()
        self.ue2_slice1.attach()

    def _detach_all_ues(self):
        self.ue1_slice1.detach()
        self.ue2_slice1.detach()

    def _configure_ul_tdd_nrresource_groups(self):
        self.technology = TDD
        self.dl_sas = False
        self._configure_ul_tdd_resource_group_list()

    def _configure_ul_tdd_resource_group_list(self):
        # TODO: udpate _confirm_sum_of_target_shares function if more than one NRRG is used
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=USED_NRRG_MIN_QUOTA,
                                            max_quota=100, in_use=True)
        nrresource_group2 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=2, min_quota=20, max_quota=50,
                                            in_use=False)
        self.nrrg_groups = [nrresource_group1, nrresource_group2]

    def _stop_tput_for_all_ues(self, transfer_end_time):
        TimeStamp.wait_for_the_unix_timestamp(transfer_end_time)
        ue1_1_tput = self.data_name.format(1, 1)
        ue2_1_tput = self.data_name.format(2, 1)
        Logger.info(f"Average Slice1 UE1 Tput: "
                    f"{self.ue1_slice1.get_average_megabits_data_transfer(ue1_1_tput, analyze_entries=300):.2f}Mbps")
        self.ue1_slice1.stop_uplink_transmission(data_name=ue1_1_tput)
        Logger.info(f"Average Slice1 UE2 Tput: "
                    f"{self.ue2_slice1.get_average_megabits_data_transfer(ue2_1_tput, analyze_entries=300):.2f}Mbps")
        self.ue2_slice1.stop_uplink_transmission(data_name=ue2_1_tput)

    def _try_to_remove_traffic_files(self):
        self.ue1_slice1.try_to_get_and_remove_traffic_log_files()
        self.ue2_slice1.try_to_get_and_remove_traffic_log_files()

    def _detach_ue_remove_traffic_files_and_cleanup_logs(self):
        self._detach_all_ues()
        self._try_to_remove_traffic_files()
        self.cleanup_the_setup_and_collect_logs_if_the_test_fails()

    def _make_sure_all_cells_are_unblocked(self):
        self.bts_oam.make_sure_gnb_cells_are_unblocked(NEIGHBOURING_GNB_CELLS)

    def _start_uplink_tput_for_all_ues(self, transmission_time):
        self.data_name = "TMO_UE{}_SLICE{}"
        ul_traffic_mb = 100
        self.ue1_slice1.start_udp_uplink_data_transmission(duration=transmission_time,
                                                           traffic_mb=ul_traffic_mb,
                                                           data_name=self.data_name.format(1, 1))
        self.ue2_slice1.start_udp_uplink_data_transmission(duration=transmission_time,
                                                           traffic_mb=ul_traffic_mb,
                                                           data_name=self.data_name.format(2, 1))

    @staticmethod
    def _confirm_sum_of_target_shares(sum_of_calculated_target_share, acceptable_min_sum=USED_NRRG_MIN_QUOTA):
        # function called from SliceSchedulingLib and uses different acceptable_min_sum.
        # It must be overwritten as long as TMO uses only one NRRG, see _configure_ul_tdd_resource_group_list
        acceptable_min_sum = USED_NRRG_MIN_QUOTA
        assert sum_of_calculated_target_share > acceptable_min_sum, \
            f"Sum of achieved target shares for NRRGs should be greater than acceptable min sum: {acceptable_min_sum}%"
        Logger.info(f"Sum of achieved target shares in used NRRGs is: {sum_of_calculated_target_share:.2f}%")
