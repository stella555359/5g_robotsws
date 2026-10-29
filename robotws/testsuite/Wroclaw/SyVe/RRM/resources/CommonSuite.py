from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Troubleshooting import Troubleshooting
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkPluginDownloader import McsharkPluginDownloader
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam


class CommonSuite(object):

    def __init__(self):
        self.feature = None
        self.enb_id = None
        self.neighbouring_gnb_id = None
        self.enb_connection_details = None
        self.neighbouring_gnb_connection_details = None
        self.local_gnb_id = "MRBTS-{}".format(Env.GNB_ID)
        self.bts_config = BtsConfig()
        self.startup_manager = StartupManager()
        self.bts_oam = BtsOam()
        self.bts_snapshot = BtsSnapshot()
        self.syslog = SyslogCollector()
        self.bts_faults = BtsFaults()
        self.bts_config = BtsConfig()

    def commission_gnb_and_wait_for_bts_to_reach_on_air_state(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, self.local_gnb_id)
        self.bts_config.perform_full_commissioning(scf_file)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def prepare_enb(self):
        Logger.info("Performing config reset, sw update and commissioning on eNB")
        self.startup_manager.update_sw_and_commission_remote_bts(self.feature, self.enb_id,
                                                                 self.enb_connection_details)

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        Rfrl.common_step_trigger()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.bts_faults.log_active_faults()
        self.bts_faults.log_historical_faults()

    def collect_snapshot_if_suite_fails(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()

    def collect_remote_enb_snapshot_if_execution_fails(self, suite_level=True):
        self.startup_manager.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(bts_name=self.enb_id,
                                                                                              suite_level=suite_level)

    def collect_snapshot(self):
        self.bts_snapshot.collect_snapshot(Env.OUTPUT_DIR)

    @staticmethod
    def collect_ssh_snapshot_if_suite_fails():
        Troubleshooting.collect_snapshot_via_ssh_if_suite_fails('snapshot_ssh.zip')

    def collect_logs_from_fsp_interfaces_on_abia_if_suite_fails(self):
        Troubleshooting.collect_abia_logs_if_suite_fails(self.enb_connection_details)

    @staticmethod
    def make_sure_mcshark_plugin_exists():
        McsharkPluginDownloader().check_mcshark_plugin_exists_and_try_to_download_otherwise()

    def wait_for_bbmod_card_remote_bts(self):
        self.startup_manager.remote_manager.wait_for_bbmod_remote_cart_to_be_enabled(self.enb_id,
                                                                                     self.enb_connection_details)
