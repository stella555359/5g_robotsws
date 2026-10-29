from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import MEDIATEK
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.L2TraceCollector import L2TraceCollector
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite, Env, Logger, ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.conventers.UplaneComponent import UplaneComponent
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.ACsiParser import ACsiParser
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, upload_file
from testsuite.Wroclaw.SyVe.RRM.resources.Troubleshooting import Troubleshooting
from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.bsh_interface import execute_ssh_command_on_bsh
import time
import copy

MAX_20MHZ_TPUT = 50
MAX_UL_20MHZ_TPUT = 10
HASH_CONTAINER_FILES = "/ffs/run/HashContainer*"
GNB_FILES_TO_REMOVE_ASP_LOG_ACTIVATION = ["/ffs/run/swpool/L2RT/addons/trace.tgz",
                                          "/ffs/run/boardcfg/1/B/mcu-aspa/addons/trace.tgz"]
GNB_UPLOAD_SCRIPT_ACTIVE_ASP_LOG = "testsuite/Wroclaw/SyVe/RRM/5GC007798/gNB_script/asp_log_turn_on.sh"
GNB_DIR_ASP_ACTIVATION_LOG_SCRIPT = "/tmp/asp_log_turn_on.sh"
SUCCESSFUL_REMOTE_PROCEDURE_MSG = "DONE"
LTE_CELL = 1
SCELL_GNB = 4
SYSLOG_FLAGS = ["0x10079=800000", "0x100B7=1", "0x200DB=1", "0x420000=1", "0x1003F=1",
                "0x10041=2", "0x590072=1", "0x10040=1", "0x10041=5", "0x10045=534217728",
                "0x1A1300=0", "0x340000 = 15", "0x5900d4=0", "0x59006A=1", "0x5900bf=20"]
COMMENTED_FLAGS = ["0x45005a=1", "0x1A0020=1"]
UL_DATA_NAME = "ul_udp_traffic"
DL_DATA_NAME = "dl_udp_traffic"
DL_DATA_NAME_SCELL = "dl_udp_scell"


class Res7798(CommonSuite):

    def __init__(self):
        super(Res7798, self).__init__()
        self.feature = '5GC007798'
        self.enb_id = 'MRBTS-41101'
        self.attenuator = Attenuator()
        self.attenuator_ports_enb = list(self.attenuator.attenuator_ports)[0:2]
        self.attenuator_ports_gnb_pcell_6 = list(self.attenuator.attenuator_ports)[2:4]
        self.attenuator_ports_gnb_scell_4 = list(self.attenuator.attenuator_ports)[4:6]
        self.ue = Ue(MEDIATEK, ue_id=1)
        self.transfer_end_time = TimeStamp.unix_timestamp
        self.uplane_pcap_trace = None
        self.uplane = None
        self.ssh_lmp_gnb = Env.GNB_SSH_CONNECTION_DETAILS
        self.asp_filepath = None
        self.m_plane_enb = Env.ENB_HTTPS_CONNECTION_HOST
        self.traffic_scell_pcell = None
        self.enb_connection_details = Env.LTE_VM_SSH_CONN_DETAILS
        self.troubleshooting = Troubleshooting()

    @staticmethod
    def flags_are_set_for_test_uci_only_disabled():
        syslog_copy_flags = copy.copy(SYSLOG_FLAGS)
        syslog_copy_flags.append("0x580431=0")
        Swconfig().change_swconfig_flags(syslog_copy_flags, COMMENTED_FLAGS)

    @staticmethod
    def flags_are_set_for_test_uci_only_enabled():
        syslog_copy_flags = copy.copy(SYSLOG_FLAGS)
        syslog_copy_flags.append("0x580431=1")
        Swconfig().change_swconfig_flags(syslog_copy_flags, COMMENTED_FLAGS)

    def prepare_ue_and_start_logging(self):
        self.ue.prepare_ue()
        self.bts_log_start_logging()

    def stop_and_collect_logs_if_test_fails_and_do_the_common_step(self):
        self.bts_log_stop_logging()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
        Rfrl.common_step_trigger()

    def collect_snapshots_if_suite_fails(self):
        self.collect_remote_enb_snapshot_if_execution_fails()
        self.collect_snapshot_if_suite_fails()

    def bts_log_start_logging(self):
        self.syslog.start_btslog_on_local_machine()

    def bts_log_stop_logging(self):
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()

    def gnb_is_up_and_running(self):
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def right_scf_file_is_chosen_and_gnb_commissioned(self, *parameters):
        Logger.info("Search for proper SCF and commission gNB with parameters: {}".format(parameters))
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, *parameters)
        self.bts_config.perform_full_commissioning(scf_file)

    def ue_attached(self):
        self.ue.attempt_to_attach_several_times()

    def cleanup_ue_traffic_files(self):
        self.ue.detach()
        self.ue.try_to_get_and_remove_traffic_log_files()

    def not_needed_cells_for_test_nsa_are_blocked(self):
        self.bts_oam.block_gnb_cell(cell_number=SCELL_GNB)

    def set_no_attenuation_on_lte_ports(self):
        for port in self.attenuator_ports_enb:
            self.attenuator.set_port_attenuation(port=port, target_attenuation=0)

    def set_no_attenuation_on_gnb_ports_cell_6(self):
        for port in self.attenuator_ports_gnb_pcell_6:
            self.attenuator.set_port_attenuation(port=port, target_attenuation=0)

    def data_traffic_open_loop_is_launched(self):
        sleep_to_collect_acsi = 10
        self.ue.start_udp_downlink_data_transmission(duration=120, traffic_mb=170,
                                                     data_name=DL_DATA_NAME, packet_size=1400)
        for _ in range(3):
            self.ue.start_udp_uplink_data_transmission(duration=10, traffic_mb=70,
                                                       data_name=UL_DATA_NAME, packet_size=1400)
            time.sleep(sleep_to_collect_acsi)
            self.ue.stop_uplink_transmission(data_name=UL_DATA_NAME)
        self.ue.stop_downlink_transmission(data_name=DL_DATA_NAME)

    def data_traffic_in_dl_and_ul_for_the_ue_is_launched(self):
        sleep_to_collect_acsi = 30
        self._start_data_traffic_for_downlink_and_uplink()
        time.sleep(sleep_to_collect_acsi)
        self._stop_data_traffic_for_downlink_and_uplink()

    def data_traffic_in_dl_and_ul_for_the_ue_is_launched_jitter(self):
        time_for_ping = 60
        self.ue.generate_traffic_via_ping_to_appserver(time_for_ping=time_for_ping)
        # investigation ongoing for 23r4 build
        # time.sleep(time_for_ping)
        self._attenuation_jitter_increase_decrease_db()
        self.ue.ping_stop_and_check_results()

    def data_traffic_in_dl_and_ul_for_the_ue_is_launched_scell(self):
        sleep_low_traffic_acsi = 5
        sleep_active_scell_traffic_acsi = 15
        sleep_to_collect_acsi = 15
        self._start_data_traffic_for_downlink_and_uplink(dl_mb=10, ul_mb=2)
        time.sleep(sleep_low_traffic_acsi)
        self.ue.start_udp_downlink_data_transmission(duration=20, traffic_mb=400,
                                                     data_name=DL_DATA_NAME_SCELL, packet_size=1400)
        time.sleep(sleep_active_scell_traffic_acsi)
        self._get_traffic_statistic_for_pcell_scell()
        time.sleep(sleep_to_collect_acsi)
        self.ue.stop_downlink_transmission(data_name=DL_DATA_NAME_SCELL)
        self._stop_data_traffic_for_downlink_and_uplink()

    def traffic_pcell_scell_is_checked(self, traffic_both_cells=290, percent=15):
        min_expected = traffic_both_cells - (percent * (traffic_both_cells / 100))
        if min_expected > self.traffic_scell_pcell:
            Logger.warning(f"Traffic to low check please check the results, minimum expected result is {min_expected},"
                           f" current traffic was {self.traffic_scell_pcell}")

    def uplane_pcap_trace_collecting_is_started(self):
        self.uplane_pcap_trace = L2TraceCollector()
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Ps")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2Lo")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiRlc")
        self.uplane_pcap_trace.update_l2_trace_configuration(trace_type="Component", up_sw="L2HiPdcp")
        self.uplane_pcap_trace.prepare_and_start_collecting_pcap_trace_logs()

    def uplane_pcap_trace_collecting_is_stopped(self):
        self.uplane_pcap_trace.stop_collecting_pcap_trace_logs()
        self.uplane = UplaneComponent()
        self.uplane.pcap2csv(files_path_pattern=self.uplane_pcap_trace.pcap_file_path,
                             output_path=self.uplane_pcap_trace.pcap_dir)

    def uplane_file_open_loop_is_validated(self):
        file_path = self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv"
        Logger.info(f"File to check:\n{file_path}")
        parse = ACsiParser(file_path=file_path)
        parse.check_the_csv_file_acsi_report_fdd_ol()

    def uplane_file_close_loop_is_validated(self):
        file_path = self.uplane_pcap_trace.pcap_dir + ".dlAndUl.csv"
        Logger.info(f"File to check:\n{file_path}")
        parse = ACsiParser(file_path=file_path)
        parse.check_the_csv_file_acsi_report_fdd_cl()

    def asp_logs_collecting_is_activated(self):
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

    def asp_logs_are_downloaded(self):
        self.asp_filepath = self.troubleshooting.collect_asp_logs_and_return_log_name(
            node_to_download_from="node_0x1740")

    def counter_for_jitter_is_changed_from_low_to_high(self):
        counter_jitter = 0
        substring = "jitter state to 1"
        with open(self.asp_filepath, "r") as asp_file:
            for index, line in enumerate(asp_file):
                if line.count(substring):
                    counter_jitter += 1
        Logger.info("Counter that jitter change stats: {}".format(counter_jitter))

    def attenuation_scell_is_set_to_high(self):
        self._set_attenuation_scell(target_attenuation=50)

    def attenuation_scell_is_set_to_minimum(self):
        self._set_attenuation_scell(target_attenuation=0)

    def attenuation_scell_is_set_to_maximum(self):
        self._set_attenuation_scell(target_attenuation=95)

    def make_sure_nsa_cell_is_blocked(self):
        try:
            self.bts_oam.make_sure_enb_cell_is_blocked(cell_number=LTE_CELL)
        except Exception as error:
            Logger.warning(error)

    def make_sure_nsa_cell_is_unblocked(self):
        try:
            self.bts_oam.make_sure_enb_cell_is_unblocked(cell_number=LTE_CELL)
        except Exception as error:
            Logger.warning(error)

    def _start_data_traffic_for_downlink_and_uplink(self, dl_mb=170, ul_mb=100):
        self.ue.start_udp_downlink_data_transmission(duration=120, traffic_mb=dl_mb,
                                                     data_name=DL_DATA_NAME, packet_size=1400)
        self.ue.start_udp_uplink_data_transmission(duration=120, traffic_mb=ul_mb,
                                                   data_name=UL_DATA_NAME, packet_size=1400)

    def _stop_data_traffic_for_downlink_and_uplink(self):
        self.ue.stop_uplink_transmission(data_name=UL_DATA_NAME)
        self.ue.stop_downlink_transmission(data_name=DL_DATA_NAME)

    def _get_traffic_statistic_for_pcell_scell(self):
        entries_check = 10
        pcell_traffic = self.ue.get_maximum_megabit_data_transfer(data_name=DL_DATA_NAME,
                                                                  analyze_entries=entries_check)
        scell_traffic = self.ue.get_maximum_megabit_data_transfer(data_name=DL_DATA_NAME_SCELL,
                                                                  analyze_entries=entries_check)
        self.traffic_scell_pcell = float(pcell_traffic) + float(scell_traffic)
        Logger.info("Pcell plus Scell traffic: {}".format(self.traffic_scell_pcell))

    def _is_asp_log_activated(self):
        _asp_log_check = "lxc-attach -n 0x1740 cat /var/preserve/feature_log_activation.txt"
        output, _ = execute_ssh_command_on_bsh(smod_ssh_connection_parameters=self.ssh_lmp_gnb,
                                               bsh_number="1:1",
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
            Logger.info("Files removed HC {}".format(_hash_container_to_remove))

    def _attenuation_jitter_increase_decrease_db(self):
        sleep_time_for_jitter = 2
        for _ in range(0, 11):
            for port in self.attenuator_ports_gnb_pcell_6:
                self.attenuator.set_port_attenuation(port=port, target_attenuation=30)
            time.sleep(sleep_time_for_jitter)
            for port in self.attenuator_ports_gnb_pcell_6:
                self.attenuator.set_port_attenuation(port=port, target_attenuation=0)
            time.sleep(sleep_time_for_jitter)

    def _set_attenuation_scell(self, target_attenuation):
        for port in self.attenuator_ports_gnb_scell_4:
            self.attenuator.set_port_attenuation(port=port, target_attenuation=target_attenuation)
