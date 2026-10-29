from time import sleep

from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import ONEPLUS_9_PRO_ANDROID12

RIM_RS_SEND_REQ = 'RimRsSendReq'
RIM_RS_MANAGER = 'isRs1Detected:1'
MINUTE = 60
SYSLOG_COLLECTING_TIME = 30*MINUTE
TRAFFIC_DURATION = 30*MINUTE
RIMRS_ALARM_ID = 7527
AGRESSOR_GNB_ID = 1
AGRESSOR_TL_ID = 'MRBTS-50445'
DL_MITIGATION = 'DL mitigation: xsfn'


class Res6991(object):

    def __init__(self):
        self.feature = "CB006991"
        self.bts_config = BtsConfig()
        self.bts_startup = StartupManager()
        self.bts_state = BtsState()
        self.ue_victim = Ue(ONEPLUS_9_PRO_ANDROID12, ue_id=1)
        self.ue_aggressor = Ue(ONEPLUS_9_PRO_ANDROID12, ue_id=2)
        self.syslog = SyslogCollector()
        self.bts_faults = BtsFaults()
        self.bts_snapshot = BtsSnapshot()
        self.env_data = TestEnvData()
        self.ssh_connection_vm_aggr = self.env_data.LTE_VM_SSH_CONN_DETAILS

    @staticmethod
    def update_swconfig_flags_on_victim():
        syslog_and_rim_flags = ["0x420000=1", "0x10041=2", "0x590072=1", "0x41001b=1", "0x58057A=4", "0x58057E=128",
                                "0x58057F=11", "0x580689=1024"]
        Swconfig().update_swconfig_flags(syslog_and_rim_flags)

    def prepare_remote_gnb(self):
        self.bts_startup.update_sw_and_commission_remote_bts(self.feature, AGRESSOR_TL_ID, self.ssh_connection_vm_aggr,
                                                             'AgressorRIMRS')

    def commission_victim_gnb_with_feature_cb006991_activated_to_onair(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'VictimRIMRS')
        self.bts_config.perform_full_commissioning(scf_file)
        self.victim_gnb_is_in_onair_state()

    def commissioned_victim_gnb_with_feature_cb006991c_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'VictimAlarmRIMRS')
        self.bts_config.perform_full_commissioning(scf_file)
        self.victim_gnb_is_in_onair_state()

    def commissioned_agressor_gnb_with_feature_cb006991c_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'AgressorRIMRS')
        self.bts_config.perform_full_commissioning(scf_file, AGRESSOR_GNB_ID)

    def victim_gnb_is_in_onair_state(self):
        self.bts_startup.manage_commissioned_bts_to_reach_on_air_state()

    def agressor_gnb_is_in_onair_state(self):
        self.bts_state.are_all_cells_on_air(AGRESSOR_GNB_ID)

    def get_mesgs_count_in_syslog(self, mesg):
        matching_lines = self.syslog.get_all_logs_containing_text_from_syslog_files(mesg)
        return matching_lines.count(mesg)

    def rimrssendreq_is_stored_in_syslog(self):
        nr_of_rimrssendreq = self.get_mesgs_count_in_syslog(RIM_RS_SEND_REQ)
        assert nr_of_rimrssendreq >= 1, "Unexpected number={} of RimRsSendReq".format(nr_of_rimrssendreq)

    def rimrsmanager_is_stored_in_syslog(self):
        nr_of_rimrsmanager = self.get_mesgs_count_in_syslog(RIM_RS_MANAGER)
        assert nr_of_rimrsmanager >= 1, "Unexpected number={} of RimRsManager".format(nr_of_rimrsmanager)

    def dlmitigation_is_stored_in_syslog(self):
        nr_of_item = self.get_mesgs_count_in_syslog(DL_MITIGATION)
        assert nr_of_item >= 1, "Unexpected number={} of {}".format(nr_of_item, DL_MITIGATION)

    def rimrs_alarm_is_active(self):
        assert self.bts_faults.is_fault_active(RIMRS_ALARM_ID), "Fault 7527 not active!"

    def prepare_ues(self):
        self.ue_victim.prepare_ue()
        self.ue_aggressor.prepare_ue()

    def victim_ue_is_attached(self):
        self.ue_victim.restart_ue()
        self.ue_victim.attach()

    def aggressor_ue_is_attached(self):
        self.ue_aggressor.restart_ue()
        self.ue_aggressor.attach()

    def traffic_on_victim_ue_is_started(self):
        self.ue_victim.start_tcp_uplink_data_transmission(duration=TRAFFIC_DURATION, traffic_mb=1,
                                                          data_name="UL_VIC")

    def traffic_on_aggressor_ue_is_started(self):
        self.ue_aggressor.start_tcp_downlink_data_transmission(duration=TRAFFIC_DURATION, traffic_mb=1,
                                                               data_name="DL_AGG")

    def syslog_capturing_is_started(self):
        self.syslog.start_btslog_on_local_machine()

    @staticmethod
    def syslog_is_being_collected():
        Logger.info("SYSLOG is going to be collected for 30 minutes. Starting now - please wait")
        sleep(SYSLOG_COLLECTING_TIME)

    def syslog_capturing_is_stopped(self):
        self.syslog.stop_btslog_and_collect_files_on_local_os()
        Logger.info("SYSLOG collecting stopped")

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        Rfrl.common_step_trigger()
        self.ue_victim.detach()
        self.ue_victim.try_to_get_and_remove_traffic_log_files()
        self.ue_aggressor.detach()
        self.ue_aggressor.try_to_get_and_remove_traffic_log_files()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.bts_faults.log_active_faults()

    def cleanup_remote_vm(self):
        self.bts_startup.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(
            bts_name=AGRESSOR_TL_ID, ssh_connection_details=self.ssh_connection_vm_aggr)
