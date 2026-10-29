from taf.ul.gnb.bip.collection import collection as bip_collection

from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, download_file
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkParser import McsharkParser
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env

TCPDUMP_FILE_PATH = '/tmp/master.pcap'
PCAP_UNSUCCESSFUL_MSG = 'Required frames not found in pcap'
PCAP_SUCCESSFUL_MSG = 'Found expected frames in pcap logs'
TCPDUMP_CMD = f'(nohup  tcpdump -i any -w {TCPDUMP_FILE_PATH} 1>/dev/null 2>/dev/null &); exit'
PID_TCPDUMP_CMD = "ps -ef | grep tcpdump | egrep -v 'grep|firewall|eth' | awk '{print $2}'"


def expected_log_is_stored_in_pcap(pcap_file, pcap_filter):
    tshark_parser = McsharkParser()
    tshark_parser.convert_pcap_file_with_filter_using_mcshark(pcap_file, pcap_filter)
    assert tshark_parser.tshark_output, PCAP_UNSUCCESSFUL_MSG
    Logger.info(PCAP_SUCCESSFUL_MSG)
    return tshark_parser.tshark_output


class BipCollector:
    def __init__(self, gnb_id=0):
        self._bip_collector = bip_collection()
        self.bip_files = None
        self.gnb_id = gnb_id

    def configure_bip_collection(self, **configuration_params):
        self._bip_collector.configure_bip_collection(**configuration_params)

    def start_bip_trace_on_gnb(self):
        self._bip_collector.start_bip_trace(self.gnb_id)

    def stop_and_download_bip_trace_on_gnb(self):
        self.bip_files = self._bip_collector.stop_bip_trace(Env().test_log_dir, self.gnb_id)
        return self.bip_files

    def stop_bip_trace_on_gnb(self):
        self._bip_collector.stop_bip_trace("/tmp", self.gnb_id)

    def collect_bip_logs_on_gnb(self):
        Logger.info("Starting BIP logs for gnb")
        self.start_bip_trace_on_gnb()
        Logger.info("Stopping and collecting BIP logs from gnb")
        return self.stop_and_download_bip_trace_on_gnb()

    def collect_bip_logs_on_gnb_from_performed_procedure(self, procedure):
        Logger.info("Starting BIP logs for gnb")
        self.start_bip_trace_on_gnb()
        Logger.info(f"Performing procedure: {procedure.name}")
        procedure()
        Logger.info("Stopping and collecting BIP logs from gnb")
        return self.stop_and_download_bip_trace_on_gnb()


class TcpdumpCollector:

    def __init__(self, ssh_connection_details=Env.GNB_SSH_CONNECTION_DETAILS):
        self.ssh_connection_details = ssh_connection_details

    def start_tcpdump_collection(self):
        execute_ssh_command(self.ssh_connection_details, TCPDUMP_CMD)
        self._make_sure_tcpdump_is_running()
        Logger.info(f"Tcp dump is running on gnb: {TCPDUMP_CMD}")

    def stop_tcpdump_collection(self):
        pid_script_process = self._get_tcpdump_pid(PID_TCPDUMP_CMD)
        for pid in pid_script_process.strip().split():
            kill_tcpdump = f"kill -2 {pid}"
            Logger.info(f"Performing cmd: {kill_tcpdump} on gnb")
            execute_ssh_command(self.ssh_connection_details, kill_tcpdump)
        if not pid_script_process:
            Logger.debug("tcpdump not started")

    def stop_and_download_tcpdump_from_gnb(self, pcap_name):
        Logger.info("Stopping and collecting tcpdump")
        self.stop_tcpdump_collection()
        return self.collect_tcpdump(pcap_name)

    def collect_tcpdump(self, pcap_name):
        target_path = VmOs.join_path_elements(Env().test_log_dir, pcap_name)
        Logger.info(f"Collecting tcp dump to {target_path}")
        download_file(self.ssh_connection_details, TCPDUMP_FILE_PATH, target_path)
        return target_path

    def _make_sure_tcpdump_is_running(self, pid_cmd=PID_TCPDUMP_CMD):
        pid_script_process = self._get_tcpdump_pid(pid_cmd)
        assert pid_script_process, "Tcpdump was not started"
        Logger.debug(f"Tcp dump pid: {pid_script_process}")

    def _get_tcpdump_pid(self, pid_cmd):
        output, _ = execute_ssh_command(self.ssh_connection_details, pid_cmd)
        return output
