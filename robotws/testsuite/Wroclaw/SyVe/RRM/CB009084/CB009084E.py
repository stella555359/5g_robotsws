from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters, PM_COLLECTION_SECONDS
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import QUALCOMM_SDX65, GALAXY_S20
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from time import sleep
from datetime import datetime
from testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib import PRB_AVAIL_PDSCH_SLICES, PRB_USED_PDSCH_SLICE, \
    PRB_PDSCH_UTIL_RATIO_SLICE_MAX, PRB_AVAIL_PDSCH_NSA_PLMN, PRB_USED_PDSCH_NSA_PLMN, SA_PM_COUNTERS, \
    NSA_PM_COUNTERS, STREAMS_BEFORE_SAS_MIGRATION, DL_PRB_USED_DATA_NRG, DL_PRB_UTIL_SLOT_MAX_NRG, \
    DL_SANSA_SAS_PM_COUNTERS, SAS_MIGRATION_FIRST_STEP_STREAM, DL_PRB_AVAIL_SAS
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import NOK_STATUSES
from testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib import NetworkSlice, Plmn, NRResourceGroup
from testsuite.Wroclaw.SyVe.RRM.resources.Troubleshooting import Troubleshooting
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import QUALCOMM_SDX55


FEATURE = "CB009084"
BANDWIDTH_UE_NSA = 250
BANDWIDTH_UE_SA = 100
TIME_TO_START_NSA_TRAFFIC = 30
PRB_PDSCH_UTIL_RATIO_PLMN_MAX = "M55338C01002"
NSA_PM_COUNTERS = NSA_PM_COUNTERS + [PRB_PDSCH_UTIL_RATIO_PLMN_MAX]
SNSSAI_1_SA = "SST-1_SD-13714341"
SNSSAI_2_SA = "SST-1_SD-13714342"
MCC1 = "540"
MNC1 = "01"
CELL_ID_5G = 3
NEW_COUNTERS_PATH = f"MRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRCELL-{CELL_ID_5G}"


class CB009084E(CommonSuite):

    def __init__(self):
        super(CB009084E, self).__init__()
        self.ue_nsa = Ue(type_=QUALCOMM_SDX65, ue_id=1)
        self.ue_sa_slice_341 = Ue(type_=QUALCOMM_SDX55, ue_id=3)
        self.ue_sa_slice_342 = Ue(type_=QUALCOMM_SDX55, ue_id=2)
        self.samsungS20_dss = Ue(type_=GALAXY_S20, ue_id=4)
        self.enb_id = "MRBTS-40434"
        self.bts_counters = BtsPmCounters()
        self.bts_oam = BtsOam()
        self.delta = ScfPathFinder()
        self.raw_counters = None
        self.slices = None
        self.plmns = None
        self.sa_nr_resource_groups = None
        self.nsa_nr_resource_groups = None
        self.enb_connection_details = Env.LTE_VM_SSH_CONN_DETAILS

    def prepare_base_feature_test_line(self):
        self.feature = FEATURE
        self.bts_config.perform_full_commissioning(ScfPathFinder().get_scf_path_for_feature(self.feature,
                                                                                            self.local_gnb_id))
        self._manage_commissioned_gnb_dss()
        self.prepare_enb()
        Troubleshooting().check_active_fault_and_freeze_test_line_if_forbidden_fault_found(skip_fault10_checking=True)
        self._perform_site_reset_dss_enb_gnb()
        self.syslog.start_btslog_on_local_machine()
        self._manage_site_to_reach_on_air_state()
        self._configure_sa_fdd_resources_group()
        self._configure_nsa_fdd_resources_group()
        self._configure_fdd_slices_list()
        self._configure_plmn_list()

    def perform_delta_for_new_quota_values(self):
        self._reconfigure_sa_fdd_resources_group()
        self._reconfigure_nsa_fdd_resources_group()
        self._reconfigure_fdd_slices_list()
        self._reconfigure_plmn_list()
        self.bts_config.perform_delta_commissioning(self.delta.get_delta_path_for_feature(self.feature,
                                                                                          "changeValueQuota"))

    def collect_logs(self):
        self.cleanup_the_setup_and_collect_logs_if_the_test_fails()
        self.collect_remote_enb_snapshot_if_execution_fails()

    def attach_all_ues(self):
        self._attach_dss()
        self._attach_ues()

    def detach_all_ues(self):
        self._detach_dss()
        self.ue_nsa.detach()
        self.ue_sa_slice_342.detach()
        self.ue_sa_slice_341.detach()

    def cleanup_ue_traffic_files(self):
        self.ue_nsa.try_to_get_and_remove_traffic_log_files()
        self.ue_sa_slice_342.try_to_get_and_remove_traffic_log_files()
        self.ue_sa_slice_341.try_to_get_and_remove_traffic_log_files()

    def start_dl_tcp_traffic(self):
        transmission_time = 1800
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period=2)
        self._start_tput_for_all_ues(transmission_time)
        Logger.info(f"Data Tx started, minute: {BtsOs().get_current_minute()}")

    def stop_downlink_traffic(self):
        self.ue_nsa.stop_downlink_transmission(data_name="qualcom_nsa")
        self.ue_sa_slice_342.stop_downlink_transmission(data_name="qualcom_342")
        self.ue_sa_slice_341.stop_downlink_transmission(data_name="qualcom_341")

    def verify_pm_counters(self):
        self._wait_for_next_pm_counters_measurements()
        self._sa_pm_counters_are_checked_to_be_collected_when_tput_was_active()
        self._nsa_pm_counters_are_checked_to_be_collected_when_tput_was_active()

    def verify_pm_counters_for_new_quota_values(self):
        self._wait_for_next_pm_counters_measurements()
        self._sa_pm_counters_are_checked_to_be_collected_when_tput_was_active()
        self._nsa_pm_counters_are_checked_to_be_collected_when_tput_was_active()

    def _attach_dss(self):
        self.samsungS20_dss.prepare_ue()
        self.samsungS20_dss.attach()

    def _attach_ues(self):
        self.ue_nsa.prepare_ue()
        self.ue_nsa.attach()
        self.ue_sa_slice_342.prepare_ue()
        self.ue_sa_slice_342.attach()
        self.ue_sa_slice_341.prepare_ue()
        self.ue_sa_slice_341.attach()
        sleep(TIME_TO_START_NSA_TRAFFIC)

    def _detach_dss(self):
        self.samsungS20_dss.detach()

    def _start_tput_for_all_ues(self, transmission_time):
        self.ue_nsa.start_udp_downlink_data_transmission(duration=transmission_time, traffic_mb=BANDWIDTH_UE_NSA,
                                                         data_name="qualcom_nsa", mtu_size=1400)
        self.ue_sa_slice_342.start_udp_downlink_data_transmission(duration=transmission_time,
                                                                  traffic_mb=BANDWIDTH_UE_SA,
                                                                  data_name="qualcom_342", mtu_size=1400)
        self.ue_sa_slice_341.start_udp_downlink_data_transmission(duration=transmission_time,
                                                                  traffic_mb=BANDWIDTH_UE_SA,
                                                                  data_name="qualcom_341", mtu_size=1400)

    def _configure_fdd_slices_list(self):
        slice1 = NetworkSlice(snsai=SNSSAI_1_SA, cell_id=CELL_ID_5G, mcc=MCC1, mnc=MNC1,
                              min_quota=40, max_quota=40, in_use=True)
        slice2 = NetworkSlice(snsai=SNSSAI_2_SA, cell_id=CELL_ID_5G, mcc=MCC1, mnc=MNC1,
                              min_quota=20, max_quota=100, in_use=True)
        self.slices = [slice1, slice2]

    def _configure_plmn_list(self):
        plmn = Plmn(cell_id=CELL_ID_5G, mcc=MCC1, mnc=MNC1, min_quota=0, max_quota=100)
        self.plmns = [plmn]

    def _configure_sa_fdd_resources_group(self):
        nrresource_group1 = NRResourceGroup(cell_id=CELL_ID_5G, resource_group_id=1, min_quota=40, max_quota=40,
                                            in_use=True)
        nrresource_group2 = NRResourceGroup(cell_id=CELL_ID_5G, resource_group_id=2, min_quota=20, max_quota=100,
                                            in_use=True)
        self.sa_nr_resource_groups = [nrresource_group1, nrresource_group2]

    def _configure_nsa_fdd_resources_group(self):
        nrresource_group5 = NRResourceGroup(cell_id=CELL_ID_5G, resource_group_id=5, min_quota=0, max_quota=100,
                                            in_use=True)
        self.nsa_nr_resource_groups = [nrresource_group5]

    def _reconfigure_sa_fdd_resources_group(self):
        nrresource_group1 = NRResourceGroup(cell_id=CELL_ID_5G, resource_group_id=1, min_quota=0, max_quota=100,
                                            in_use=True)
        nrresource_group2 = NRResourceGroup(cell_id=CELL_ID_5G, resource_group_id=2, min_quota=40, max_quota=40,
                                            in_use=True)
        self.sa_nr_resource_groups = [nrresource_group1, nrresource_group2]

    def _reconfigure_nsa_fdd_resources_group(self):
        nrresource_group5 = NRResourceGroup(cell_id=CELL_ID_5G, resource_group_id=5, min_quota=20, max_quota=100,
                                            in_use=True)
        self.nsa_nr_resource_groups = [nrresource_group5]

    def _reconfigure_fdd_slices_list(self):
        slice1 = NetworkSlice(snsai=SNSSAI_1_SA, cell_id=CELL_ID_5G, mcc=MCC1, mnc=MNC1,
                              min_quota=0, max_quota=100, in_use=True)
        slice2 = NetworkSlice(snsai=SNSSAI_2_SA, cell_id=CELL_ID_5G, mcc=MCC1, mnc=MNC1,
                              min_quota=40, max_quota=40, in_use=True)
        self.slices = [slice1, slice2]

    def _reconfigure_plmn_list(self):
        plmn = Plmn(cell_id=CELL_ID_5G, mcc=MCC1, mnc=MNC1, min_quota=20, max_quota=100)
        self.plmns = [plmn]

    def _sa_pm_counters_are_checked_to_be_collected_when_tput_was_active(self):
        sas_counters = DL_SANSA_SAS_PM_COUNTERS if self.sas_migration_2nd_step else SA_PM_COUNTERS
        self.raw_counters = self.bts_counters.get_raw_pm_counters(sas_counters)
        tstamp = self._get_latest_pm_counters_period_epoch()
        available_pdsch = self._get_prb_avail_pdsch_slices_pm_counter_if_exists(tstamp)
        if Env.STREAM_SW in STREAMS_BEFORE_SAS_MIGRATION:
            for a_slice in self.slices:
                used_prb_slice = self._get_used_slice_counter_if_exists(a_slice, tstamp)
                self._sa_max_slice_pm_counters_are_checked_when_tput_was_active(a_slice, tstamp)
                self._sa_calculated_slice_pm_counters_are_checked_when_tput_was_active(a_slice, used_prb_slice,
                                                                                       available_pdsch)
        else:
            max_counters = self._get_max_data_nrg_counters_sa(tstamp)
            used_counters = self._get_used_data_nrg_counters_sa(tstamp)
            for rg_id, a_nrrg in enumerate(self.sa_nr_resource_groups):
                self._confirm_single_nrrg_pm_counters(a_nrrg, rg_id, max_counters, used_counters, available_pdsch)

    def _nsa_pm_counters_are_checked_to_be_collected_when_tput_was_active(self):
        if Env.STREAM_SW in STREAMS_BEFORE_SAS_MIGRATION:
            self.raw_counters = self.bts_counters.get_raw_pm_counters(NSA_PM_COUNTERS)
            tstamp = self._get_latest_pm_counters_period_epoch()
            for a_plmn in self.plmns:
                self._nsa_max_plmn_pm_counter_are_checked_when_tput_was_active(a_plmn, tstamp)
                self._confirm_nsa_slice_pm_conters_exist_and_correct(a_plmn, tstamp)
        else:
            sas_counters = DL_SANSA_SAS_PM_COUNTERS if self.sas_migration_2nd_step else SA_PM_COUNTERS
            self.raw_counters = self.bts_counters.get_raw_pm_counters(sas_counters)
            tstamp = self._get_latest_pm_counters_period_epoch()
            available_pdsch = self._get_prb_avail_pdsch_slices_pm_counter_if_exists(tstamp)
            max_counters = self._get_max_data_nrg_counters_nsa(tstamp)
            used_counters = self._get_used_data_nrg_counters_nsa(tstamp)
            for rg_id, a_nrrg in enumerate(self.nsa_nr_resource_groups):
                self._confirm_single_nrrg_pm_counters(a_nrrg, rg_id, max_counters, used_counters, available_pdsch)

    def _wait_for_next_pm_counters_measurements(self):
        Logger.info(f"Waiting {PM_COLLECTION_SECONDS}sec for PM Counters to be generated by UEs throughput")
        sleep(PM_COLLECTION_SECONDS)
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()

    def _perform_site_reset_dss_enb_gnb(self):
        self.bts_oam.reset_gnb_site()
        self.bts_oam.reset_enb_site()

    def _manage_commissioned_gnb_dss(self):
        self.startup_manager.manage_commissioned_bts_dss_radio_sharing()

    def _manage_site_to_reach_on_air_state(self):
        NOK_STATUSES.append('degraded')
        self.startup_manager.manage_commissioned_remote_bts_to_reach_on_air_state(self.enb_id,
                                                                                  self.enb_connection_details)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.startup_manager.wait_for_x2_connected()

    @staticmethod
    def _get_latest_pm_counters_period_epoch():
        latest_pm_counters_epoch = BtsOs().get_epoch() - 2 * PM_COLLECTION_SECONDS
        Logger.info(f"Timestamp for PM Counters collecting: "
                    f"{datetime.fromtimestamp(latest_pm_counters_epoch)} Epoch: {latest_pm_counters_epoch}")
        return latest_pm_counters_epoch

    def _get_prb_avail_pdsch_slices_pm_counter_if_exists(self, tstamp):
        sas_counter = DL_PRB_AVAIL_SAS if self.sas_migration_2nd_step else PRB_AVAIL_PDSCH_SLICES
        pm_counters = self.bts_counters.extract_bts_cell_pm_counter(self.raw_counters,
                                                                    sas_counter, cell_id=CELL_ID_5G,
                                                                    t_stamp=tstamp)
        assert self._get_pm_counter_value(sas_counter, pm_counters) > 0, \
            f"{sas_counter} counters not collected!"
        Logger.info(f"{sas_counter} counters confirmed")
        return self._get_pm_counter_value(sas_counter, pm_counters)

    def _get_used_data_nrg_counters_sa(self, tstamp):
        used_prbs_nrg1_path = f"{NEW_COUNTERS_PATH}/NRRESOURCEGROUP-1/NCUPNRG/{DL_PRB_USED_DATA_NRG}"
        used_prbs_nrg2_path = f"{NEW_COUNTERS_PATH}/NRRESOURCEGROUP-2/NCUPNRG/{DL_PRB_USED_DATA_NRG}"
        used_prbs_nrg_1 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.raw_counters, path=used_prbs_nrg1_path, t_stamp=tstamp)
        used_prbs_nrg_2 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.raw_counters, path=used_prbs_nrg2_path, t_stamp=tstamp)
        return [used_prbs_nrg_1, used_prbs_nrg_2]

    def _get_max_data_nrg_counters_sa(self, tstamp):
        used_prbs_nrg1_path = f"{NEW_COUNTERS_PATH}/NRRESOURCEGROUP-1/NCUPNRG/{DL_PRB_UTIL_SLOT_MAX_NRG}"
        used_prbs_nrg2_path = f"{NEW_COUNTERS_PATH}/NRRESOURCEGROUP-2/NCUPNRG/{DL_PRB_UTIL_SLOT_MAX_NRG}"
        max_prbs_nrg_1 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.raw_counters, path=used_prbs_nrg1_path, t_stamp=tstamp)
        max_prbs_nrg_2 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.raw_counters, path=used_prbs_nrg2_path, t_stamp=tstamp)
        return [max_prbs_nrg_1, max_prbs_nrg_2]

    def _get_max_data_nrg_counters_nsa(self, tstamp):
        used_prbs_nrg5_path = f"{NEW_COUNTERS_PATH}/NRRESOURCEGROUP-5/NCUPNRG/{DL_PRB_UTIL_SLOT_MAX_NRG}"
        max_prbs_nrg_5 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.raw_counters, path=used_prbs_nrg5_path, t_stamp=tstamp)
        return [max_prbs_nrg_5]

    def _get_used_data_nrg_counters_nsa(self, tstamp):
        used_prbs_nrg5_path = f"{NEW_COUNTERS_PATH}/NRRESOURCEGROUP-5/NCUPNRG/{DL_PRB_USED_DATA_NRG}"
        used_prbs_nrg_5 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.raw_counters, path=used_prbs_nrg5_path, t_stamp=tstamp)
        return [used_prbs_nrg_5]

    def _get_used_slice_counter_if_exists(self, a_slice, tstamp):
        used_slice_pm = self.bts_counters.extract_cell_slice_pm_counters(self.raw_counters, cell_id=a_slice.cell_id,
                                                                         slice_name=a_slice.name,
                                                                         counter_id=PRB_USED_PDSCH_SLICE,
                                                                         mobile_country_code=a_slice.mcc,
                                                                         mobile_network_code=a_slice.mnc,
                                                                         t_stamp=tstamp)
        pm_value_increased_when_slice_used = self._get_pm_counter_value(PRB_USED_PDSCH_SLICE, used_slice_pm) > 0
        slice_not_used = True if self._get_pm_counter_value(PRB_USED_PDSCH_SLICE, used_slice_pm) == 0 else False
        confirmed_slice_usage = pm_value_increased_when_slice_used if a_slice.in_use else slice_not_used
        assert confirmed_slice_usage, "PRB_USED_PDSCH_SLICE counters collecting problem!"
        Logger.info(f"{PRB_USED_PDSCH_SLICE} for a slice '{a_slice.name}' - confirmed")
        return self._get_pm_counter_value(PRB_USED_PDSCH_SLICE, used_slice_pm)

    def _sa_max_slice_pm_counters_are_checked_when_tput_was_active(self, a_slice, tstamp):
        ratio_slice_pm = self.bts_counters.extract_cell_slice_pm_counters(self.raw_counters, cell_id=a_slice.cell_id,
                                                                          slice_name=a_slice.name,
                                                                          counter_id=PRB_PDSCH_UTIL_RATIO_SLICE_MAX,
                                                                          mobile_country_code=a_slice.mcc,
                                                                          mobile_network_code=a_slice.mnc,
                                                                          t_stamp=tstamp)
        value_ratio_slice_pm = self._get_pm_counter_value(PRB_PDSCH_UTIL_RATIO_SLICE_MAX, ratio_slice_pm)
        if a_slice.in_use and not a_slice.min_quota <= value_ratio_slice_pm <= a_slice.max_quota:
            Logger.warning(f"A slice '{a_slice.name}' PM counter {PRB_PDSCH_UTIL_RATIO_SLICE_MAX} "
                           f"indicates value:{value_ratio_slice_pm} - out of configured quotas {a_slice.quotas}")
        else:
            Logger.info(f"{PRB_PDSCH_UTIL_RATIO_SLICE_MAX} for a slice '{a_slice.name}'"
                        f" - confirmed val:{value_ratio_slice_pm}")

    @staticmethod
    def _sa_calculated_slice_pm_counters_are_checked_when_tput_was_active(a_slice, used_slice_drbs,
                                                                          available_slices_drbs):
        used_slice_ratio = used_slice_drbs / available_slices_drbs * 100
        Logger.info(f"CALCULATIONS for a slice '{a_slice.name}' - confirmed val:{used_slice_ratio:.2f}")
        assert a_slice.min_quota <= used_slice_ratio <= a_slice.max_quota, \
            f"The slice {a_slice.name} ratio is : {used_slice_ratio:.2f} is out of configured quota " \
            f"{a_slice.min_quota}-{a_slice.max_quota}"

    def _confirm_nsa_slice_pm_conters_exist_and_correct(self, a_plmn, tstamp):
        available_prbs = self.bts_counters.extract_cell_plmn_pm_counters(cell_id=a_plmn.cell_id,
                                                                         counter_id=PRB_AVAIL_PDSCH_NSA_PLMN,
                                                                         mobile_network_code=a_plmn.mnc,
                                                                         mobile_country_code=a_plmn.mcc,
                                                                         raw_pm_data=self.raw_counters,
                                                                         t_stamp=tstamp)
        used_prbs = self.bts_counters.extract_cell_plmn_pm_counters(cell_id=a_plmn.cell_id,
                                                                    counter_id=PRB_USED_PDSCH_NSA_PLMN,
                                                                    mobile_network_code=a_plmn.mnc,
                                                                    mobile_country_code=a_plmn.mcc,
                                                                    raw_pm_data=self.raw_counters,
                                                                    t_stamp=tstamp)
        value_used_prbs = self._get_pm_counter_value(PRB_USED_PDSCH_NSA_PLMN, used_prbs)
        value_available_prbs = self._get_pm_counter_value(PRB_AVAIL_PDSCH_NSA_PLMN, available_prbs)
        used_prbs_ratio = value_used_prbs / value_available_prbs * 100
        Logger.info(f"The PLMN {a_plmn} ratio is : {used_prbs_ratio:.2f}"
                    f" - should match qoutas: {a_plmn.min_quota}<->{a_plmn.max_quota}")
        assert a_plmn.min_quota <= used_prbs_ratio <= a_plmn.max_quota, \
            f"The slice {a_plmn} ratio is : {used_prbs_ratio:.2f} is out of configured quota " \
            f"{a_plmn.min_quota}-{a_plmn.max_quota}"

    def _nsa_max_plmn_pm_counter_are_checked_when_tput_was_active(self, a_plmn, tstamp):
        pm_counter = self.bts_counters.extract_cell_plmn_pm_counters(raw_pm_data=self.raw_counters,
                                                                     counter_id=PRB_PDSCH_UTIL_RATIO_PLMN_MAX,
                                                                     cell_id=a_plmn.cell_id,
                                                                     mobile_country_code=a_plmn.mcc,
                                                                     mobile_network_code=a_plmn.mnc,
                                                                     t_stamp=tstamp)
        value_ratio_plmn_max = self._get_pm_counter_value(PRB_PDSCH_UTIL_RATIO_PLMN_MAX, pm_counter)
        Logger.info(f"Actual NSA PM counter value: {value_ratio_plmn_max} should be in range {a_plmn.quotas}")
        if not a_plmn.min_quota <= value_ratio_plmn_max <= a_plmn.max_quota:
            Logger.warning(f"PM counter nsa {PRB_PDSCH_UTIL_RATIO_PLMN_MAX} is out of configured quotas "
                           f"{a_plmn.quotas} actual value {value_ratio_plmn_max}")

    @staticmethod
    def _get_pm_counter_value(counter_id, pm_value):
        try:
            return sum(pm_value.values())
        except TypeError as type_err:
            raise AssertionError(f"Pm counter {counter_id} has no integer value, got {pm_value}: {type_err}")

    def _confirm_single_nrrg_pm_counters(self, a_nrrg, rg_id, all_max_nr_counters,
                                         all_used_nr_counters, available_pdsch):
        used_pm_value = all_used_nr_counters[rg_id]
        max_pm_value = all_max_nr_counters[rg_id]
        Logger.info(f"used {all_used_nr_counters}")
        Logger.info(f"max {all_max_nr_counters}")
        if a_nrrg.in_use and not a_nrrg.min_quota <= max_pm_value <= a_nrrg.max_quota:
            Logger.warning(f"A slice '{a_nrrg}' PM counter {PRB_PDSCH_UTIL_RATIO_SLICE_MAX} indicates "
                           f"value:{max_pm_value} - out of configured quotas {a_nrrg.quotas}")
        else:
            Logger.info(f"{PRB_PDSCH_UTIL_RATIO_SLICE_MAX} for a NRRG '{a_nrrg}' - confirmed val:{max_pm_value}")
        Logger.info(f"CHECKING: {a_nrrg.min_quota} <= {max_pm_value} <= {a_nrrg.max_quota}")
        self._confirm_nrrg_calculation(a_nrrg, used_pm_value, available_pdsch)

    @staticmethod
    def _confirm_nrrg_calculation(a_nrrg, used_slice_drbs,  available_slices_drbs):
        used_slice_ratio = used_slice_drbs / available_slices_drbs * 100
        Logger.info(f"CALCULATIONS for a NRRG '{a_nrrg}' - confirmed val:{used_slice_ratio:.2f}")
        assert_info = f"The slice {a_nrrg} ratio is : {used_slice_ratio:.2f} is out of configured quota " \
            f"{a_nrrg.min_quota}-{a_nrrg.max_quota}"
        assert a_nrrg.min_quota <= used_slice_ratio <= a_nrrg.max_quota, assert_info

    @property
    def sas_migration_2nd_step(self):
        return True if Env.STREAM_SW not in STREAMS_BEFORE_SAS_MIGRATION + [SAS_MIGRATION_FIRST_STEP_STREAM] else False
