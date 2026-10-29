from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import ASKEY_AT_ADB
import time

LOCAL_GNB_CELL_ID = 1
NEIGHBOURING_GNB_CELL_ID = 1
CAPABILITIES = "QUALCOMM_UE"
NGNB = "MRBTS-50439"
BTSLOG_5GNGNB_ALIAS = "btslog5gngnb"
NEIGHBOURING_GNB_ID = "MRBTS-{}".format(Env.GNBS[1].instance_id)
NEIGHBOURING_GNB_CONNECTION_DETAILS = Env.TESTLINE.test_pcs[1].default_ssh_connection_details
NEIGHBOURING_BTS_LOG_EXECUTOR = {"host": NEIGHBOURING_GNB_CONNECTION_DETAILS.addr,
                                 "user": NEIGHBOURING_GNB_CONNECTION_DETAILS.username,
                                 "password": NEIGHBOURING_GNB_CONNECTION_DETAILS.password}
TRANSMISSION_TIME = 120
LINES_TO_ANALYZE = 30
DL_TRAFFIC_MB = 40


class Resources7271(CommonSuite):

    def __init__(self):
        super(Resources7271, self).__init__()
        self.feature = "CB007271"
        self.ue = Ue(type_=ASKEY_AT_ADB, ue_id=1)
        self.abil_tput = None
        self.abin_tput = None

    def collect_remote_gnb_snapshot_if_suite_fails(self):
        self.startup_manager.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(
            bts_name=NGNB, ssh_connection_details=NEIGHBOURING_GNB_CONNECTION_DETAILS)

    def commission_neighbouring_gnb_and_wait_for_bts_to_reach_on_air_state(self):
        Logger.info("Performing config reset, sw update and commissioning neighbouring gNB")
        self.startup_manager.update_sw_and_commission_remote_bts(self.feature, NEIGHBOURING_GNB_ID,
                                                                 NEIGHBOURING_GNB_CONNECTION_DETAILS)

    def prepare_environment_and_start_logging_for_7271_feature(self):
        self.bts_oam.make_sure_gnb_cell_is_unblocked(cell_number=LOCAL_GNB_CELL_ID, gnb_id=0)
        self.bts_oam.make_sure_gnb_cell_is_unblocked(cell_number=NEIGHBOURING_GNB_CELL_ID, gnb_id=1)
        self.ue.prepare_ue()
        self.syslog.start_btslog_on_local_machine()
        self.syslog.start_btslog_on_remote_machine(bts_log_dir=Env.BTS_LOG_DIR_5G, name=BTSLOG_5GNGNB_ALIAS,
                                                   ssh_connection_details=NEIGHBOURING_GNB_CONNECTION_DETAILS,
                                                   executor=NEIGHBOURING_BTS_LOG_EXECUTOR)

    def cleanup_the_setup_collect_logs_if_the_test_fails_and_unblock_all_cells(self):
        from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
        Rfrl.common_step_trigger()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.bts_faults.log_active_faults()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails(name=BTSLOG_5GNGNB_ALIAS)
        self.bts_oam.make_sure_gnb_cell_is_unblocked(cell_number=LOCAL_GNB_CELL_ID, gnb_id=0)
        self.bts_oam.make_sure_gnb_cell_is_unblocked(cell_number=NEIGHBOURING_GNB_CELL_ID, gnb_id=1)

    def start_and_check_ul_tput_abil(self):
        abil_data_name = "TPUT_ABIL"
        self._block_local_gnb_cell_and_check_if_it_is_blocked()
        self.abil_tput = self._start_and_get_ul_tput(abil_data_name)
        self._unblock_local_gnb_cell_and_check_if_it_is_unblocked()

    def start_and_check_ul_tput_abin(self):
        abin_data_name = "TPUT_ABIN"
        self._block_neighbouring_gnb_cell_and_check_if_it_is_blocked()
        self.abin_tput = self._start_and_get_ul_tput(abin_data_name)
        self._unblock_neighbouring_gnb_cell_and_check_if_it_is_unblocked()

    def _start_and_get_ul_tput(self, data_name):
        self.ue.attach()
        self.ue.start_tcp_uplink_data_transmission(duration=TRANSMISSION_TIME, traffic_mb=DL_TRAFFIC_MB,
                                                   data_name=data_name)
        time.sleep(TRANSMISSION_TIME)
        self.ue.stop_uplink_transmission(data_name=data_name)
        avg_tput = self.ue.get_average_megabits_data_transfer(
            data_name=data_name, analyze_entries=LINES_TO_ANALYZE, client_log_check=False)
        Logger.info("Average uplink {} is {:.2f}Mbps".format(data_name, avg_tput))
        self.ue.detach()
        return avg_tput

    def check_if_tput_is_ok_on_both_tls(self):
        real_deviation = abs((self.abin_tput / self.abil_tput) * 100 - 100)
        assert self.abil_tput * 0.95 < self.abin_tput < self.abil_tput * 1.05, \
            "Throughput is not correct - should be equal or 5% deviation. "\
            "Measured deviation is {:.2f}%".format(real_deviation)
        Logger.info("Measured deviation is {:.2f}%".format(real_deviation))

    def make_sure_ue_actions_are_cleared(self):
        self.ue.try_to_get_and_remove_traffic_log_files()

    def _block_local_gnb_cell_and_check_if_it_is_blocked(self):
        Logger.info("blocking local cell_ABIN")
        self.bts_oam.block_gnb_cell(LOCAL_GNB_CELL_ID)

    def _unblock_local_gnb_cell_and_check_if_it_is_unblocked(self):
        Logger.info("unblocking local cell_ABIN")
        self.bts_oam.unblock_gnb_cell(LOCAL_GNB_CELL_ID)

    def _block_neighbouring_gnb_cell_and_check_if_it_is_blocked(self):
        Logger.info("blocking local cell_ABIL")
        self.bts_oam.block_gnb_cell(NEIGHBOURING_GNB_CELL_ID, 1)

    def _unblock_neighbouring_gnb_cell_and_check_if_it_is_unblocked(self):
        Logger.info("unblocking local cell_ABIL")
        self.bts_oam.unblock_gnb_cell(NEIGHBOURING_GNB_CELL_ID, 1)
