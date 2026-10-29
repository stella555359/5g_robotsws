from testsuite.Wroclaw.SyVe.RRM.CB006991.Res6991 import *
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkParser import McsharkParser
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.PcapCollector import PcapCollector

RIM_RS_ENTRY = "RimRs"
RIM_DETECTED_ALARM_ID = "7525"
NSETAPX_PROTOCOL = 'nsetapx'
NSETAPX_SETTINGS = 'ntrstr.port:10010'
PCAP_UNSUCCESSFUL_MSG = 'Not all required mesgs found in pcap'
PID_NC_CMD = "ps -ef | grep 'nc -lkvnp' | egrep -v 'grep' | awk '{print $2}'"
PCMD_REPORT_MESG = "riSlopeMeasRecord: data (0)"


class Res10437(Res6991):

    def __init__(self):
        super(Res10437, self).__init__()
        self.feature = "CB010437"
        self.bts_config = BtsConfig()
        self.pcap_collector = None
        self.pcmd_trace_path = None
        self.pcmd_port = '10010'

    @staticmethod
    def download_nsetapx_plugin():
        McsharkParser().download_nsetapx_plugin()

    def commissioned_victim_gnb_with_feature_cb010437_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'victim')
        self.bts_config.perform_full_commissioning(scf_file)

    def rimrs_is_not_stored_in_syslog(self):
        nr_of_rimrs = self.get_mesgs_count_in_syslog(RIM_RS_ENTRY)
        assert nr_of_rimrs == 0, "Unexpected number={} of RimRs entries".format(nr_of_rimrs)

    def rimrs_alarm_is_inactive(self):
        assert not self.bts_faults.is_fault_active(RIM_DETECTED_ALARM_ID), "RIM alarm active"

    def commissioned_victim_gnb_with_rim_deactivated(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature, "rim_deactivated"))

    def commissioned_victim_gnb_with_cb010437_deactivated(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().get_delta_path_for_feature(self.feature, "pcmd"))

    def start_capturing_pcmd_trace(self, port):
        nc_command = 'nc -lkvnp {} --recv-only'.format(port)
        VmOs.execute_single_command_in_shell('(nohup {} 1>/dev/null 2>/dev/null &); exit'.format(nc_command))
        self.start_pcap_collector(port)

    @staticmethod
    def stop_capturing_pcmd_trace():
        pid = VmOs.execute_single_command_in_shell(PID_NC_CMD)
        VmOs.execute_single_command_in_shell('kill {}'.format(pid))

    @staticmethod
    def check_if_reports_are_in_pcmd_pcap(file_path, report_mesg):
        decoded_trace = McsharkParser().decode_nsetapx_from_pcap_with_custom_param(file_path, NSETAPX_SETTINGS)
        assert report_mesg in decoded_trace, PCAP_UNSUCCESSFUL_MSG

    def start_pcap_collector(self, port):
        self.pcap_collector = PcapCollector()
        self.pcap_collector.start_collecting_pcap(port=port)

    def pcmd_capturing_is_started(self):
        self.start_capturing_pcmd_trace(self.pcmd_port)

    def pcmd_capturing_is_stopped(self):
        self.stop_capturing_pcmd_trace()
        self.pcap_collector.stop_collecting_pcap()
        self.pcmd_trace_path = self.pcap_collector.pcap_file_path

    def rimrs_report_is_in_pcmd(self):
        self.check_if_reports_are_in_pcmd_pcap(self.pcmd_trace_path, PCMD_REPORT_MESG)
