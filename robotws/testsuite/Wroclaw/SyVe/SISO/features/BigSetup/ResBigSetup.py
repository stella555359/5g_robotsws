from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import GALAXY_S23
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.SISO.resources.AirphoneClient import AirphoneClient
from time import time

TPUT_100MBPS = 100
DEFAULT_PDU_ID = 1


class ResBigSetup(object):

    def __init__(self):
        self.feature = "BIG_SETUP"
        self.ues = [Ue(GALAXY_S23, ue_id=1), Ue(GALAXY_S23, ue_id=2), Ue(GALAXY_S23, ue_id=3), Ue(GALAXY_S23, ue_id=4)]
        self.airphone = AirphoneClient(ip_address='10.42.66.194', username='ute', password='UTE.debian12')
        self.ap_ues_ids = [1, 2, 3, 4]
        self.env_data = TestEnvData()
        self.bts_config = BtsConfig()
        self.bts_startup = StartupManager()
        self.bts_state = BtsState()
        self.bts_faults = BtsFaults()
        self.bts_snapshot = BtsSnapshot()
        self.bts_oam = BtsOam()
        self.start_time = None
        self.stop_time = None

    def prepare_ues(self):
        for ue in self.ues:
            ue.prepare_ue()

    def ues_are_attached(self):
        for ue in self.ues:
            ue.restart_ue()
            ue.attach()

    def traffic_on_ues_is_started(self):
        for ue in self.ues:
            ue.start_tcp_uplink_data_transmission(duration=60, traffic_mb=1, data_name="UL_VIC")

    def gnb_is_in_onair_state(self):
        self.bts_startup.manage_commissioned_bts_to_reach_on_air_state()

    def all_cells_are_in_onair(self):
        self.bts_startup.wait_for_all_cells_on_air()

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        for ue in self.ues:
            ue.detach()
            ue.try_to_get_and_remove_traffic_log_files()

    def time_measuring_is_started(self):
        self.start_time = time()

    def bts_is_restarted(self):
        self.bts_oam.reset_gnb_site()

    def time_measuring_is_stopped(self):
        self.stop_time = time()

    def startup_time_is_calculated(self):
        Logger.info(f'Calculated startup time: {self.stop_time - self.start_time}')

    def airphone_ues_are_attached(self):
        for ue_id in self.ap_ues_ids:
            self.airphone.attach_ue(ue_id, DEFAULT_PDU_ID)

    def airphone_ues_are_detached(self):
        for ue_id in self.ap_ues_ids:
            self.airphone.kill_ue(ue_id)

    def dl_traffic_on_airphone_ues_is_started(self):
        for ue_id in self.ap_ues_ids:
            self.airphone.start_traffic(ue_id, DEFAULT_PDU_ID, 'dl', TPUT_100MBPS)

    def ul_traffic_on_airphone_ues_is_started(self):
        for ue_id in self.ap_ues_ids:
            self.airphone.start_traffic(ue_id, DEFAULT_PDU_ID, 'ul', TPUT_100MBPS)

    def dl_traffic_on_airphone_ues_is_stopped(self):
        for ue_id in self.ap_ues_ids:
            self.airphone.stop_traffic(ue_id, DEFAULT_PDU_ID, 'dl')

    def ul_traffic_on_airphone_ues_is_stopped(self):
        for ue_id in self.ap_ues_ids:
            self.airphone.stop_traffic(ue_id, DEFAULT_PDU_ID, 'ul')

    def dl_traffic_stats_on_airphone_ues_are_checked(self):
        for ue_id in self.ap_ues_ids:
            stats = self.airphone.get_traffic_dl_stats(ue_id)
            assert stats is not None and float(stats) > 0.0, f"DL not started on UE:{ue_id}"

    def ul_traffic_stats_on_airphone_ues_are_checked(self):
        for ue_id in self.ap_ues_ids:
            stats = self.airphone.get_traffic_ul_stats(ue_id)
            assert stats is not None and float(stats) > 0.0, f"UL not started on UE:{ue_id}"
