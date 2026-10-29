"""
author/contact:   krzysztof.1.wrobel@nokia.com, I_MN_RAN_PZ1_WRO_7_SG_GMS <I_MN_RAN_PZ1_WRO_7_SG@internal.nsn.com>
Description:      functions to tracking params in csv
"""

from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, upload_file, download_file
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.L2TraceCollector import L2TraceCollector
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.conventers.UplaneComponent import UplaneComponent
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.AperiodicJitterMsgParser import AperiodicJitterMsgParser
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue as Check_Ue
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import ASKEY_AT_ADB
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.ACsiParser import ACsiParser
from testsuite.Wroclaw.SyVe.RRM.resources.bsh_interface import execute_ssh_command_on_bsh
from time import sleep

LTE_LNCEL = 1
HASH_CONTAINER_FILES = "/ffs/run/HashContainer*"
GNB_FILES_TO_REMOVE_ASP_LOG_ACTIVATION = ["/ffs/run/swpool/L2RT/addons/trace.tgz",
                                          "/ffs/run/boardcfg/1/A/mcu-aspd/addons/trace.tgz",
                                          "/ffs/run/boardcfg/2/A/mcu-aspd/addons/trace.tgz",
                                          "/ffs/run/boardcfg/3/A/mcu-aspd/addons/trace.tgz"]
GNB_UPLOAD_SCRIPT_ACTIVE_ASP_LOG = "testsuite/Wroclaw/SyVe/RRM/5GCB007220/resources/gNB_script/asp_log_turn_on.sh"
GNB_DIR_ASP_ACTIVATION_LOG_SCRIPT = "/tmp/asp_log_turn_on.sh"
SCRIPT_DIR_FOR_UE_PC = "testsuite/Wroclaw/SyVe/RRM/5GCB007220/resources/ue_pc_script/"
JITTER_SCRIPT_NAME = "att_script_nsa_jitter.py"
SET_TO_0_NAME = "set_tl19_att_to_0.py"
AVERAGE_SCRIPT_NAME = "att_script_nsa_average.py"
UE_PC_DIRECTORY = "/home/wro5gcloud/ue_pc_script/"
SUCCESSFUL_REMOTE_PROCEDURE_MSG = "DONE"
DT_NAME_DL = "DT_DL_UDP_7220"
DT_NAME_UL = "DT_UL_UDP_7220"
CAPABILITIES = "QUALCOMM_UE"


class Res7220And7134(CommonSuite):

    def __init__(self, feature_):
        super(Res7220And7134, self).__init__()
        self.feature = feature_
        self.enb_id = "MRBTS-40440"
        self.syslog = SyslogCollector()
        self.bts_snapshot = BtsSnapshot()
        self.bts_oam = BtsOam()
        self.uplane_pcap_trace = None
        self.uplane = None
        self._pid_script_process = None
        self.asp_filepath = None
        self.ssh_ue_pc = Env().UES[0].ssh_connection_details
        self.ssh_lmp_gnb = Env().GNB_SSH_CONNECTION_DETAILS
        self.m_plane_enb = Env.ENB_HTTPS_CONNECTION_HOST
        self.enb_connection_details = Env().LTE_VM_SSH_CONN_DETAILS
        self.ue_askey = Check_Ue(type_=ASKEY_AT_ADB, ue_id=1)
        self.file_traffic_logs = 0
        self.saved_iteration_logs_dir = None

    @staticmethod
    def check_if_acsi_are_enabled_in_cells():
        with BtsAdminApi() as gnbapi:
            for cell_info in gnbapi.get_managed_objects(class_name="NRCELL_A", timeout=30):
                assert cell_info['parameters']['actAperCsi'], \
                    "Problem with SCF check parameter actAperCsi. For cell info: {}".format(cell_info)

    def find_scf_and_commission_gnb(self, *parameters):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, *parameters)
        BtsConfig().perform_full_commissioning(scf_file)

    @staticmethod
    def update_swconfig_file_abio_nsa():
        Swconfig().update_swconfig_flags(["0x10041=2", "0x10045=534217728"])

    @staticmethod
    def update_swconfig_file_abin_nsa():
        Swconfig().update_swconfig_flags(["0x58057A=0x3", "0x58057c=0x1000000", "0x58057d=0x2000", "0x10041=5",
                                          "0x10040=1", "0x1003F=1"])

    @staticmethod
    def log_software_info():
        Logger.info(BtsOs().get_passive_and_active_software_version())

    def make_sure_nsa_cell_is_blocked(self):
        try:
            self.bts_oam.make_sure_enb_cell_is_blocked(cell_number=LTE_LNCEL)
        except Exception as error:
            Logger.warning(error)

    def make_sure_nsa_cell_is_unblocked(self):
        try:
            self.bts_oam.make_sure_enb_cell_is_unblocked(cell_number=LTE_LNCEL)
        except Exception as error:
            Logger.warning(error)

    @staticmethod
    def wait_until_gnb_reach_onair_state():
        StartupManager().manage_commissioned_bts_to_reach_on_air_state()

    def reboot_ue_askey(self):
        _adb_reboot = "adb -s dafb23ff reboot"
        Logger.info("Ue reboot vi command {}".format(_adb_reboot))
        execute_ssh_command(self.ssh_ue_pc, _adb_reboot)
        assert self._is_ue_detected(), "Ue not detected after adb reboot"

    def start_to_collect_uplane_pcap_trace(self):
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

    def validate_acsi_uplane_logs(self):
        file_path = self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv"
        Logger.info(f"File to check:\n{file_path}")
        parse = ACsiParser(file_path=file_path)
        parse.check_the_csv_file_acsi_report_tdd()

    def start_syslog_collection(self):
        self.syslog.start_btslog_on_local_machine()

    def stop_syslog_collection(self):
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()

    def collect_bts_gnb_snapshot(self):
        self.bts_snapshot.collect_snapshot_if_the_test_fails()

    def activate_collecting_asp_logs(self):
        if not self._is_asp_log_activated():
            self._remove_files_asp_log_if_activation_failed_from_gnb()
            self._remove_files_hash_container_from_gnb()
            _run_script = "chmod 755 {path} && {path}".format(path=GNB_DIR_ASP_ACTIVATION_LOG_SCRIPT)
            upload_file(self.ssh_lmp_gnb, GNB_UPLOAD_SCRIPT_ACTIVE_ASP_LOG, GNB_DIR_ASP_ACTIVATION_LOG_SCRIPT)
            output, _ = execute_ssh_command(self.ssh_lmp_gnb, _run_script)
            assert SUCCESSFUL_REMOTE_PROCEDURE_MSG in output, "Script execution failed"
            Logger.info("Script uploaded in to gNB and execute, command: {}".format(_run_script))
        else:
            Logger.info("Script is activated and logs already are collected")

    def download_asp_logs(self):
        _file_name = "ASP-1730_startup.log"
        _abio_asp_file_download = "bget 1:0 /tmp/node_0x1730/tmp/{} /tmp/".format(_file_name)
        _gnb_file_download = "/tmp/{}".format(_file_name)
        _asp_log_dir = str(Env.test_log_dir) + "_ASP"
        VmOs.make_empty_dir(_asp_log_dir)
        execute_ssh_command(self.ssh_lmp_gnb, _abio_asp_file_download, execution_timeout=20)
        self.asp_filepath = VmOs.join_path_elements(_asp_log_dir, _file_name)
        download_file(self.ssh_lmp_gnb, _gnb_file_download, self.asp_filepath)

    def check_the_asp_jitter_tdd_abio(self, max_subfram=20):
        expect_acsi_msg = int(BtsConfig().get_csi_report_periodicity_for_cells()['NRCELL_A-1']) / max_subfram
        jitter = AperiodicJitterMsgParser(expect_acsi_msg)
        jitter.parse_file_asp_log(filepath=self.asp_filepath)

    def check_the_asp_jitter_tdd_abin(self, max_subfram=20):
        expect_acsi_msg = int(BtsConfig().get_csi_report_periodicity_for_cells()['NRCELL_A-1']) / max_subfram
        jitter = AperiodicJitterMsgParser(expect_acsi_msg)
        self._syslog_parse_for_multiple_match()
        jitter.parse_file_asp_log(filepath=self.asp_filepath)

    def start_script_ue_pc_attenuator_jitter(self):
        script_run = "att_script_nsa_jitter.py"
        file_to_read = "result_att.txt"
        self._start_script_ue_pc_attenuator(script_run, file_to_read)

    def start_script_ue_pc_attenuator_average(self, param_script):
        script_run = "att_script_nsa_average.py"
        file_to_read = "result_avg.txt"
        self._start_script_ue_pc_attenuator(script_run, file_to_read, param_script)

    def prepare_ue_pc_to_test(self):
        self._upload_script_ue_pc()
        self._set_attenuator_port_to_0db()

    def run_traffic_with_defined_parameters_for_attenuator_script(self, param_script, dl_traffic_check,
                                                                  analyze_entries=95):
        throughput_ul = 70
        throughput_dl = 900
        self._start_data_traffic_dl_ul(traffic_ul=throughput_ul, traffic_dl=throughput_dl)
        self.start_script_ue_pc_attenuator_average(param_script)
        self._check_dl_throughput_after_ended_script(dl_traffic_check=dl_traffic_check,
                                                     analyze_entries=analyze_entries)

    def cleanup_ue_traffic_files(self):
        self.ue_askey.try_to_get_and_remove_traffic_log_files()

    def prepare_gnb_with_acsi_turn_off(self):
        self._acsi_turn_off_in_configuration_delta_commissioning()
        self._set_attenuator_port_to_0db()

    def clear_ue_pc_nsa_test(self):
        if self._pid_script_process:
            self._kill_script_ue_pc_attenuator()
        self._set_attenuator_port_to_0db()

    def ue_prepare(self):
        self.ue_askey.prepare_ue()

    def ue_attached(self):
        self.ue_askey.attach()

    def ue_detach(self):
        self.ue_askey.detach()

    def start_brush_traffic_ul_dl(self, duration=10, brush_attempt=4, analyze_entries=5):
        for brush in range(0, brush_attempt):
            Logger.info("Brush attempt traffic {}".format(brush))
            self._start_data_traffic_dl_ul(duration=duration)
            self.ue_askey.wait_for_data_transmission_end(DT_NAME_UL)
            self.ue_askey.wait_for_data_transmission_end(DT_NAME_DL)
            self._data_transfer_has_been_stopped()
            self._log_average_traffic_for_dl_and_ul(analyze_entries=analyze_entries)
            self._move_checked_traffic_files()

    def generate_traffic_vi_ping(self):
        time_for_ping = 60
        self.ue_askey.generate_traffic_via_ping_to_appserver(time_for_ping=time_for_ping)
        sleep(time_for_ping)
        self.ue_askey.ping_stop_and_check_results()

    def _is_ue_detected(self):
        time_wait_for_ue = 180
        interval = 10
        adb_check = "adb devices | grep -i dafb23ff | wc -l"
        while time_wait_for_ue > 0:
            output, _ = execute_ssh_command(self.ssh_ue_pc, adb_check)
            if output == "1":
                return True
            sleep(interval)
            time_wait_for_ue -= interval
        return False

    def _set_attenuator_port_to_0db(self):
        _cmd_set_att_to_0db = "cd {} && python set_tl19_att_to_0.py".format(UE_PC_DIRECTORY)
        output, _ = execute_ssh_command(self.ssh_ue_pc, _cmd_set_att_to_0db)
        assert SUCCESSFUL_REMOTE_PROCEDURE_MSG in output, "Script execution failed ue pc set att to 0"
        Logger.info("Script to set attenuator port to 0db: {}".format(_cmd_set_att_to_0db))

    def _start_script_ue_pc_attenuator(self, script_run, file_to_read, param_script=""):
        _run_script_ue_pc = "cd {} && (nohup python {} {} 1>/dev/null 2>/dev/null &); exit"\
            .format(UE_PC_DIRECTORY, script_run, param_script)
        execute_ssh_command(self.ssh_ue_pc, _run_script_ue_pc)
        self._make_sure_attenuator_script_is_running(file_to_read)
        Logger.info("Script is running on ue_pc: {}".format(_run_script_ue_pc))

    @staticmethod
    def _get_blocking_state(cell_block):
        if cell_block['parameters'].get("stateInfo") is not None:
            return cell_block['parameters'].get("stateInfo").get("blockingState")
        else:
            return cell_block['parameters'].get("blockingState")

    def _is_asp_log_activated(self):
        _asp_log_check = "lxc-attach -n 0x1730 cat /var/preserve/feature_log_activation.txt"
        output, _ = execute_ssh_command_on_bsh(smod_ssh_connection_parameters=self.ssh_lmp_gnb,
                                               bsh_number="1:0",
                                               command=_asp_log_check)
        return True if "L2.L2_PS.UL.APER_CSI=1" in output and "L2.L2_PS.DL.APER_CSI=1" in output \
            else False

    def _is_file_exist_on_gnb(self, filepath):
        _asp_log_check = "ls -la {}".format(filepath)
        output, _ = execute_ssh_command(self.ssh_lmp_gnb, _asp_log_check)
        return True if output else False

    def _remove_files_asp_log_if_activation_failed_from_gnb(self):
        for filepath_trace in GNB_FILES_TO_REMOVE_ASP_LOG_ACTIVATION:
            if self._is_file_exist_on_gnb(filepath_trace):
                _trace_files_to_remove = "rm {}{}".format(filepath_trace, "*")
                _, err = execute_ssh_command(self.ssh_lmp_gnb, _trace_files_to_remove)
                assert not err, "Remove files failed {}".format(_trace_files_to_remove)
                Logger.info("Files removed {}".format(_trace_files_to_remove))

    def _remove_files_hash_container_from_gnb(self):
        if self._is_file_exist_on_gnb(HASH_CONTAINER_FILES):
            _hash_container_to_remove = "rm {}".format(HASH_CONTAINER_FILES)
            _, err = execute_ssh_command(self.ssh_lmp_gnb, _hash_container_to_remove)
            assert not err, "Remove files failed {}".format(_hash_container_to_remove)
            Logger.info("Files removed HC{}".format(_hash_container_to_remove))

    def _make_sure_attenuator_script_is_running(self, file_to_read):
        _cmd_winpid_read_process = "cat {}{} | grep -v grep | grep WinPID".format(UE_PC_DIRECTORY, file_to_read)
        output, _ = execute_ssh_command(self.ssh_ue_pc, _cmd_winpid_read_process)
        Logger.info("WinPID {}".format(output))
        _cmd_pid_read_process = "ps -a | awk '{} == {} {}'".format("$4", output.split(":")[1], "{print $1}")
        output, _ = execute_ssh_command(self.ssh_ue_pc, _cmd_pid_read_process)
        self._pid_script_process = output
        deb_output, _ = execute_ssh_command(self.ssh_ue_pc, "ps -a")
        Logger.debug("All process in cygwin, debug print: \n {}".format(deb_output))
        Logger.info("PID {}".format(self._pid_script_process))
        assert self._pid_script_process, "Script was not started please check if COM port is not used"

    def _kill_script_ue_pc_attenuator(self):
        _cmd_kill_script = "kill -9 {}".format(self._pid_script_process)
        _, err = execute_ssh_command(self.ssh_ue_pc, _cmd_kill_script)
        if err.strip() and 'No such process' not in err:
            assert not err, "Script not killed {}".format(_cmd_kill_script)
        Logger.info("Killed execution of script on ue_pc: {}".format(_cmd_kill_script))

    def _upload_script_ue_pc(self):
        self._remove_old_script_and_logs_ue_pc()
        execute_ssh_command(self.ssh_ue_pc, "mkdir {}".format(UE_PC_DIRECTORY))
        upload_file(self.ssh_ue_pc, VmOs.join_path_elements(SCRIPT_DIR_FOR_UE_PC, JITTER_SCRIPT_NAME),
                    VmOs.join_path_elements(UE_PC_DIRECTORY, JITTER_SCRIPT_NAME))
        upload_file(self.ssh_ue_pc, VmOs.join_path_elements(SCRIPT_DIR_FOR_UE_PC, SET_TO_0_NAME),
                    VmOs.join_path_elements(UE_PC_DIRECTORY, SET_TO_0_NAME))
        upload_file(self.ssh_ue_pc, VmOs.join_path_elements(SCRIPT_DIR_FOR_UE_PC, AVERAGE_SCRIPT_NAME),
                    VmOs.join_path_elements(UE_PC_DIRECTORY, AVERAGE_SCRIPT_NAME))

    def _remove_old_script_and_logs_ue_pc(self):
        if self._is_directory_exist_on_ue_pc(UE_PC_DIRECTORY):
            execute_ssh_command(self.ssh_ue_pc, "rm -rf {}".format(UE_PC_DIRECTORY))

    def _is_directory_exist_on_ue_pc(self, directory):
        _ue_pc_directory_check = "ls -la {}".format(directory)
        output, _ = execute_ssh_command(self.ssh_ue_pc, _ue_pc_directory_check)
        return True if output else False

    def _start_data_traffic_dl_ul(self, traffic_ul=10, traffic_dl=90, duration=150):
        self.ue_askey.start_udp_uplink_data_transmission(duration=duration, traffic_mb=traffic_ul,
                                                         data_name=DT_NAME_UL, packet_size=1400)
        self.ue_askey.start_udp_downlink_data_transmission(duration=duration, traffic_mb=traffic_dl,
                                                           data_name=DT_NAME_DL, packet_size=1400)

    def _data_transfer_has_been_stopped(self):
        self.ue_askey.stop_uplink_transmission(data_name=DT_NAME_UL)
        self.ue_askey.stop_downlink_transmission(data_name=DT_NAME_DL)

    def _log_average_traffic_for_dl_and_ul(self, analyze_entries):
        Logger.info("UL {}".format(self.ue_askey.get_average_megabits_data_transfer(data_name=DT_NAME_UL,
                                                                                    analyze_entries=analyze_entries,
                                                                                    client_log_check=False)))
        Logger.info("DL {}".format(self.ue_askey.get_average_megabits_data_transfer(data_name=DT_NAME_DL,
                                                                                    analyze_entries=analyze_entries)))

    def _check_dl_throughput_after_ended_script(self, dl_traffic_check, analyze_entries):
        time_wait_to_script_end = 180
        self._wait_for_script_ends_its_execution(time_wait_to_script_end)
        self._data_transfer_has_been_stopped()
        avg_traffic = self.ue_askey.get_average_megabits_data_transfer(data_name=DT_NAME_DL,
                                                                       analyze_entries=analyze_entries)
        self._move_checked_traffic_files()
        Logger.info(f"DL avg value {avg_traffic} and min value expected is {dl_traffic_check}")
        if float(avg_traffic) < float(dl_traffic_check):
            Logger.warning(f"Traffic is lower then expected {dl_traffic_check} is {avg_traffic} ")

    def _wait_for_script_ends_its_execution(self, second_to_check=180):
        check_command = "ps -ef | awk '$2 == {} {}' | wc -l".format(self._pid_script_process, "{print}")
        interval = 5
        assert_msg_info = "Script not ended in required time: {}s".format(second_to_check)
        while second_to_check > 0:
            output, _ = execute_ssh_command(self.ssh_ue_pc, check_command)
            if output == "0":
                Logger.info("Script killed or ended {} {}".format(self._pid_script_process, output))
                self._pid_script_process = None
                return
            sleep(interval)
            second_to_check -= interval
        assert False, assert_msg_info

    @staticmethod
    def _acsi_turn_off_in_configuration_delta_commissioning():
        BtsConfig().perform_cell_parameter_recommissioning(cell_id=1, parameter="actAperCsi", value="false")
        StartupManager().wait_for_all_cells_on_air()

    def _syslog_parse_for_multiple_match(self):
        path = Env.BTS_LOG_DIR_5G
        tmp_jitter_dir = Env.BTS_LOG_DIR_5G + "/jitter_dir/"
        self.asp_filepath = tmp_jitter_dir + "jitter.txt"
        VmOs.make_empty_dir(tmp_jitter_dir)
        for file_ in sorted(VmOs.get_files_with_names_starting_with(path, "SYSLOG")):
            with open(VmOs.join_path_elements(path, file_), "r") as log, open(self.asp_filepath, 'a') as file_asp:
                self._save_asp_log_to_file(file_asp, log)

    @staticmethod
    def _save_asp_log_to_file(file_asp, log):
        import re
        for line in log:
            if re.search("xsfnOnAir|updateCsiJitterState", line):
                file_asp.write(line)

    def _move_checked_traffic_files(self):
        current_iteration_logs_dir = Env().test_log_dir
        self.saved_iteration_logs_dir = Env().test_log_dir + "_step_{}".format(self.file_traffic_logs)
        if VmOs.check_if_dir_is_not_empty(current_iteration_logs_dir):
            VmOs.move_dir(current_iteration_logs_dir, self.saved_iteration_logs_dir)
            self.file_traffic_logs += 1
