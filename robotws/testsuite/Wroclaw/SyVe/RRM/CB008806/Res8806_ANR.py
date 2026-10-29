from testsuite.Wroclaw.SyVe.RRM.features.Res705And8806 import *
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import QUALCOMM_SDX65
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.bsh_interface import execute_ssh_command_on_bsh

CP_LOGS_CMD = "cp /tmp/node_CPUE20/tmp/startup_cp_ue.log /ffs/run/logs/"
EXTENDED_LOG_SET_CMD = 'echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini; ' \
                       'chmod a+r /ffs/run/cp_runtime.ini'
ANR_LOG_ENTRY = 'Total NrRels nad NrReles number:1'


class Res8806_ANR(object):

    def __init__(self):
        self.feature = "5GC000705"
        self.source_gnb_id = 1
        self.bts_config = BtsConfig()
        self.bts_state = BtsState()
        self.bts_startup = StartupManager()
        self.bts_admin = BtsAdminApi(
            bts_host=Env.GNBS[self.source_gnb_id].cu.oam_http_connection_details.addr)
        self.ue1 = Ue(QUALCOMM_SDX65, ue_id=1)
        self.cp_ue_log_file = None
        self.ssh_connection_gnb_source = Env.GNBS[self.source_gnb_id].cu.oam_ssh_connection_details
        self.ssh_connection_gnb_target = Env.GNB_SSH_CONNECTION_DETAILS
        self.ssh_connection_vm_source = Env.VM_SSH_CONN_DETAILS

    def commissioned_target_gnb_with_feature_cb008806_anr_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'TargetAnr')
        self.bts_config.perform_full_commissioning(scf_file)

    def commissioned_source_gnb_with_cb008806_anr_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'SourceAnr')
        self.bts_config.perform_full_commissioning(scf_file, self.source_gnb_id)

    def extended_log_reporting_for_anr_on_source_is_set(self):
        execute_ssh_command(self.ssh_connection_gnb_source, EXTENDED_LOG_SET_CMD)
        self.reboot_source_and_manage_to_onair()

    def cp_ue_log_from_source_is_downloaded(self):
        execute_ssh_command_on_bsh(smod_ssh_connection_parameters=self.ssh_connection_gnb_source,
                                   bsh_number="0:1",
                                   command=CP_LOGS_CMD)
        self.cp_ue_log_file = VmOs.join_path_elements(Env().test_log_dir, "source_cp_ue.log")
        self.collect_file(self.cp_ue_log_file, self.ssh_connection_gnb_source,
                          file_location_on_gnb="/ffs/run/logs/startup_cp_ue.log")

    def cp_ue_log_from_source_contains_anr_entry(self):
        with open(self.cp_ue_log_file) as cp_ue_log:
            assert ANR_LOG_ENTRY in cp_ue_log.read()

    def anr_handover_is_performed(self):
        self.start_script_ue_pc_attenuator("perform_handover.py")

    def environment_for_anr_test_is_prepared(self):
        self.start_script_ue_pc_attenuator("set_start_values.py")
        self.ue1.prepare_ue()
        self.ue1.attach()

    @staticmethod
    def start_script_ue_pc_attenuator(script_run):
        pc_with_attenuator_com_conn = Env.LTE_VM_SSH_CONN_DETAILS
        pc_script_directory = "ANR"
        run_script_ue_pc = "cd {} && (python {}); exit"\
            .format(pc_script_directory, script_run)
        execute_ssh_command(pc_with_attenuator_com_conn, run_script_ue_pc)

    @staticmethod
    def collect_file(logdir, ssh_connection, file_location_on_gnb='/tmp/master.pcap'):
        download_file(ssh_connection, file_location_on_gnb, logdir)

    def reboot_source_and_manage_to_onair(self, timeout=600, interval=15):
        execute_ssh_command(self.ssh_connection_gnb_source, "reboot")
        self.bts_admin.wait_for_admin_connection_possibility(timeout)
        while not self.bts_state.are_all_cells_on_air(self.source_gnb_id) and timeout > 0:
            timeout -= interval
            time.sleep(interval)
        self.bts_state.are_all_cells_on_air(self.source_gnb_id)
