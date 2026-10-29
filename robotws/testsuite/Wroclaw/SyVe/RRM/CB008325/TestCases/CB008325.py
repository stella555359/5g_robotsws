from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.AperiodicJitterMsgParser import AperiodicJitterMsgParser
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, upload_file
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import GALAXY_S21_ULTRA
from testsuite.Wroclaw.SyVe.RRM.resources.conventers.UplaneComponent import UplaneComponent
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.L2TraceCollector import L2TraceCollector
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.ACsiParser import ACsiParser
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Pdu import Pdu as Pdu
import time
import copy

LTE_CELL = 2
NR_FDD_CELL = 2
DT_NAME_DL = "DT_DL_TCP"
DT_NAME_UL = "DT_UL_TCP"
SCRIPT_DIR_FOR_UE_PC = "testsuite/Wroclaw/SyVe/RRM/CB008325/resources/ue_pc_script"
JITTER_SCRIPT_NAME = "att_script_nsa_jitter_tl18.py"
SET_TO_0_NAME = "set_tl18_att_to_0.py"
UE_PC_DIRECTORY = "/home/wro5gcloud/ue_pc_script_tl18/"
SUCCESSFUL_REMOTE_PROCEDURE_MSG = "DONE"
UE_PC_TL_19_IP = '10.42.22.50'


class CB008325(CommonSuite):

    def __init__(self):
        super(CB008325, self).__init__()
        self.feature = 'CB008325'
        self.enb_id = "MRBTS-40437"
        self.ue = Ue(GALAXY_S21_ULTRA, ue_id=1)
        self.uplane_pcap_trace = None
        self.uplane = None
        self.delta = ScfPathFinder()
        self.ue_pc_ssh_attenuator_tl19 = self._set_correct_ip_to_ue_pc_tl19()
        self.enb_connection_details = Env.LTE_VM_SSH_CONN_DETAILS

    def prepare_environment_for_sa_scenario(self):
        self.ue.prepare_ue()
        self.syslog.start_btslog_on_local_machine()
        self.scf_file_is_chosen_and_gnb_commissioned("SA", Env.GNB_ID)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.bts_oam.make_sure_gnb_cell_is_blocked(NR_FDD_CELL)
        try:
            self.bts_oam.make_sure_enb_cell_is_blocked(LTE_CELL)
        except Exception as err:
            Logger.debug(f"PDU is disabled or bts don't have configuration:\n{err}")

    def prepare_environment_for_nsa_scenario(self):
        self._power_on_enb()
        self.ue.prepare_ue()
        self.prepare_enb()
        self.bts_oam.make_sure_enb_cell_is_unblocked(LTE_CELL)
        self._erase_unused_and_update_swconfig_flags()
        self.syslog.start_btslog_on_local_machine()
        self.scf_file_is_chosen_and_gnb_commissioned("NSA", Env.GNB_ID)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()
        self.startup_manager.wait_for_x2_connected()
        self.bts_oam.make_sure_gnb_cell_is_blocked(NR_FDD_CELL)

    def scf_file_is_chosen_and_gnb_commissioned(self, *parameters):
        Logger.info("Search for proper SCF and commission gNB with parameters: {}".format(parameters))
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, *parameters)
        self.bts_config.perform_full_commissioning(scf_file)

    def prepare_ue_pc_test(self):
        self._upload_script_ue_pc_tl19()
        self._set_attenuator_port_to_0db()

    def ue_attached(self):
        self.ue.attach()

    def ue_detach(self):
        self.ue.detach()
        self.ue.try_to_get_and_remove_traffic_log_files()

    def start_burst_ul_dl_traffic(self, duration=8, iteration=5):
        for _ in range(0, iteration):
            self.start_data_traffic(duration=duration)
            time.sleep(duration)
            self.data_traffic_for_the_ue_is_stopped()

    def generate_traffic_vi_ping(self):
        time_for_ping = 60
        self.ue.generate_traffic_via_ping_to_appserver(time_for_ping=time_for_ping)
        time.sleep(time_for_ping)
        self.ue.ping_stop_and_check_results()

    def start_data_traffic(self, traffic_ul=10, traffic_dl=90, duration=150):
        self.ue.start_tcp_uplink_data_transmission(duration=duration, traffic_mb=traffic_ul, data_name=DT_NAME_UL)
        self.ue.start_tcp_downlink_data_transmission(duration=duration, traffic_mb=traffic_dl, data_name=DT_NAME_DL)

    def data_traffic_for_the_ue_is_stopped(self):
        self.ue.stop_uplink_transmission(data_name=DT_NAME_UL)
        self.ue.stop_downlink_transmission(data_name=DT_NAME_DL)

    def uplane_pcap_trace_collection_is_started(self):
        self.uplane_pcap_trace = L2TraceCollector()
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Ps")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Lo")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiRlc")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiPdcp")
        self.uplane_pcap_trace.prepare_and_start_collecting_pcap_trace_logs()

    def stop_to_collect_uplane_pcap_trace(self):
        self.uplane_pcap_trace.stop_collecting_pcap_trace_logs()
        self.uplane = UplaneComponent()
        self.uplane.pcap2csv(files_path_pattern=self.uplane_pcap_trace.pcap_file_path,
                             output_path=self.uplane_pcap_trace.pcap_dir)

    def uplane_file_is_validated_and_checked_for_proper_acsi_quantity(self):
        file_path = self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv"
        Logger.info(f"File to check:\n{file_path}")
        parse = ACsiParser(file_path=file_path)
        parse.check_the_csv_file_acsi_report_tdd()

    def start_script_ue_pc_attenuator_jitter(self):
        file_to_read = "result_att.txt"
        self._start_script_ue_pc_attenuator(JITTER_SCRIPT_NAME, file_to_read)

    @staticmethod
    def check_the_asp_jitter_tdd_abip(max_subfram=20):
        expect_acsi_msg = int(BtsConfig().get_csi_report_periodicity_for_cells()['NRCELL_A-1']) / max_subfram
        jitter = AperiodicJitterMsgParser(expect_acsi_msg)
        for file in sorted(VmOs.get_files_with_names_starting_with(Env.BTS_LOG_DIR_5G, "SYSLOG")):
            jitter.parse_file_asp_log(filepath=VmOs.join_path_elements(Env.BTS_LOG_DIR_5G, file))

    def clear_ue_pc_nsa_test(self):
        if self._pid_script_process:
            self._kill_script_ue_pc_attenuator()
        self._set_attenuator_port_to_0db()

    def _kill_script_ue_pc_attenuator(self):
        _cmd_kill_script = "kill -9 {}".format(self._pid_script_process)
        _, err = execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, _cmd_kill_script)
        if err.strip() and 'No such process' not in err:
            assert not err, "Script not killed {}".format(_cmd_kill_script)
        Logger.info("Killed execution of script on ue_pc: {}".format(_cmd_kill_script))

    def _upload_script_ue_pc_tl19(self):
        self._remove_old_script_and_logs_ue_pc()
        execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, "mkdir {}".format(UE_PC_DIRECTORY))
        upload_file(self.ue_pc_ssh_attenuator_tl19, VmOs.join_path_elements(SCRIPT_DIR_FOR_UE_PC, JITTER_SCRIPT_NAME),
                    VmOs.join_path_elements(UE_PC_DIRECTORY, JITTER_SCRIPT_NAME))
        upload_file(self.ue_pc_ssh_attenuator_tl19, VmOs.join_path_elements(SCRIPT_DIR_FOR_UE_PC, SET_TO_0_NAME),
                    VmOs.join_path_elements(UE_PC_DIRECTORY, SET_TO_0_NAME))

    def _remove_old_script_and_logs_ue_pc(self):
        if self._is_directory_exist_on_ue_pc(UE_PC_DIRECTORY):
            execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, "rm -rf {}".format(UE_PC_DIRECTORY))

    def _is_directory_exist_on_ue_pc(self, directory):
        _ue_pc_directory_check = "ls -la {}".format(directory)
        output, _ = execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, _ue_pc_directory_check)
        return True if output else False

    @staticmethod
    def _set_correct_ip_to_ue_pc_tl19():
        ssh_tmp_details = copy.copy(Env().UES[0].ssh_connection_details)
        ssh_tmp_details.addr = UE_PC_TL_19_IP
        return ssh_tmp_details

    def _set_attenuator_port_to_0db(self):
        _cmd_set_att_to_0db = f"cd {UE_PC_DIRECTORY} && python {SET_TO_0_NAME}"
        output, _ = execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, _cmd_set_att_to_0db)
        assert SUCCESSFUL_REMOTE_PROCEDURE_MSG in output, "Script execution failed ue pc set att to 0"
        Logger.info("Script to set attenuator port to 0db: {}".format(_cmd_set_att_to_0db))

    def _start_script_ue_pc_attenuator(self, script_run, file_to_read, param_script=""):
        _run_script_ue_pc = "cd {} && (nohup python {} {} 1>/dev/null 2>/dev/null &); exit"\
            .format(UE_PC_DIRECTORY, script_run, param_script)
        execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, _run_script_ue_pc)
        self._make_sure_attenuator_script_is_running(file_to_read)
        Logger.info("Script is running on ue_pc: {}".format(_run_script_ue_pc))

    def _make_sure_attenuator_script_is_running(self, file_to_read):
        _cmd_winpid_read_process = "cat {}{} | grep -v grep | grep WinPID".format(UE_PC_DIRECTORY, file_to_read)
        output, _ = execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, _cmd_winpid_read_process)
        Logger.info("WinPID {}".format(output))
        _cmd_pid_read_process = "ps -a | awk '{} == {} {}'".format("$4", output.split(":")[1], "{print $1}")
        output, _ = execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, _cmd_pid_read_process)
        self._pid_script_process = output
        deb_output, _ = execute_ssh_command(self.ue_pc_ssh_attenuator_tl19, "ps -a")
        Logger.debug("All process in cygwin, debug print: \n {}".format(deb_output))
        Logger.info("PID {}".format(self._pid_script_process))
        assert self._pid_script_process, "Script was not started please check if COM port is not used"

    @staticmethod
    def _erase_unused_and_update_swconfig_flags():
        syslog_flags = ["0x10041=1",
                        "0x10040=1",
                        "0x1003F=1",
                        "402=0x10000001", "0x19000A=1", "0x30000F=1", "0x10045=534217728", "0x590072=1", "0x66001b=1",
                        "0x580431=1", "0x58057A=0x4", "0x58057c=0x1000000", "0x58057d=0x2000"]
        commented_ones = ["0x45005a=1", "0x1A1300=0", "0x1A0020=1"]
        Swconfig().change_swconfig_flags(syslog_flags, commented_ones)

    def _power_on_enb(self):
        enb_port = 11
        rmod_port = 6
        Logger.info(f"Power on enb ports: {enb_port} {rmod_port}")
        Pdu().switch_on_pdu_port(port=enb_port)
        Pdu().switch_on_pdu_port(port=rmod_port)
        self.wait_for_bbmod_card_remote_bts()
