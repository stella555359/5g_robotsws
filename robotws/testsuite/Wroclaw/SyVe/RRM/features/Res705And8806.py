import time

from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import ONEPLUS_9_PRO
from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import download_file
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkParser import McsharkParser as TSharkParser
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.PcapCollector import PcapCollector
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.bsh_interface import execute_ssh_command_on_bsh

MIN_ATTENUATION = 0
MAX_ATTENUATION = 63
INITIAL_MAX_ATTENUATION = 90
TARGET_HO_CELL_NR = 54
SOURCE_HO_CELL_NR = 1
HO_REQUIRED_MSG = 'HandoverRequired'
HO_REQUEST_MSG = 'HandoverRequest'
HO_REQUEST_ACK_MSG = 'HandoverRequestAcknowledge'
HO_PREP_FAIL_MSG = 'HandoverPreparationFailure'
HO_COMMAND_MSG = 'HandoverCommand'
HO_NOTIFY_CMD = 'HandoverNotify'
HO_FAIL_MSG = 'HandoverFailure'
HO_CANCEL_MSG = 'HandoverCancel'
HO_CANCEL_ACK_MSG = 'HandoverCancelAcknowledge'
UE_CONTEXT_REL_CMD = 'UEContextReleaseCommand'
DL_RAN_STAT_TRANSFER = 'DownlinkRANStatusTransfer'
SCELL_ADDITION_MSG = 'sCellToAddModList'
UE_SETUP_RECORD_MSG = 'ueSetupRecord: data (0)'
PDU_SESSION_RECORD_MSG = 'ver-Id: id-VER-GNB-CU-PduSessionResourceInfoTraceRecord (14)'
UE_DU_CONNECTIVITY_MSG = 'ver-Id: id-VER-GNB-CU-UeDuConnectivityTraceRecord (12)'
NGAP_PROTOCOL = 'ngap'
F1AP_PROTOCOL = 'f1ap'
NSETAPX_PROTOCOL = 'nsetapx'
NSETAPX_SETTINGS = 'ntrstr.port:10010,10020'
PCAP_UNSUCCESSFUL_MSG = 'Not all required mesgs found in pcap'
PCAP_INCORRECT_MSG = 'Improper mesgs found in pcap'
PCAP_NOT_PROPER_MSG = 'HO successful mesgs found in pcap'
TCPDUMP_CMD = 'cd /tmp && (nohup  tcpdump -i any -w master.pcap 1>/dev/null 2>/dev/null &); exit'
F1AP_TCPDUMP_CMD = 'nohup  tcpdump -i any sctp -w /ffs/run/logs/slave.pcap 1>/dev/null 2>/dev/null &'
PID_TCPDUMP_CMD = "ps -ef | grep tcpdump | egrep -v 'grep|firewall|eth' | awk '{print $2}'"
PID_NC_CMD = "ps -ef | grep 'nc -lkvnp' | egrep -v 'grep' | awk '{print $2}'"
F1AP_PID_TCPDUMP_CMD = "ps -ef | grep tcpdump | egrep -v 'grep|portrange|eth' | awk '{print $2}'"
NG_HO_RES_ALC_ATT_TRG = 'M55125C07503'
NG_HO_RES_ALC_SUCC_TRG = 'M55125C07504'
NG_HO_EXEC_NOTIFY_TRG = 'M55125C07520'
NG_HO_RES_ALC_F_AC_TRG = 'M55125C07505'
NG_HO_PREP_ATT_SRC_NRREL = 'M55153C00501'
NG_HO_PREP_SUCC_SRC = 'M55125C07512'
NG_HO_EXEC_ATT_SRC_NRREL = 'M55153C00502'
NG_HO_EXEC_SUCC_SRC_NRREL = 'M55153C00503'
NG_HO_EXEC_AVG_TIME = 'M55125C07525'
NG_HO_EXEC_MAX_TIME = 'M55125C07526'
NG_HO_PREP_FAIL_RRL_SRC = 'M55125C07507'
NG_HO_PREP_CNC_SRC = 'M55125C07516'
NG_HO_PREP_CNC_ACK_SRC = 'M55125C07517'
NG_HO_PREP_ATT_SRC_IEF_PLMN = 'M55149C03004'
NG_HO_EXEC_ATT_SRC_IEF_PLMN = 'M55149C03005'
NG_HO_EXEC_SUCC_SRC_IEF_PLMN = 'M55149C03006'
COUNTERS_705AB3 = [NG_HO_RES_ALC_ATT_TRG, NG_HO_RES_ALC_SUCC_TRG, NG_HO_EXEC_NOTIFY_TRG]
COUNTERS_8806AB3_NRCEL = [NG_HO_PREP_SUCC_SRC, NG_HO_EXEC_AVG_TIME, NG_HO_EXEC_MAX_TIME]
COUNTERS_8806AB3_NRREL = [NG_HO_PREP_ATT_SRC_NRREL, NG_HO_EXEC_ATT_SRC_NRREL, NG_HO_EXEC_SUCC_SRC_NRREL]
COUNTERS_8806AEC2 = [NG_HO_PREP_CNC_SRC, NG_HO_PREP_CNC_ACK_SRC]
PCMD_MESGS_SRC = [UE_SETUP_RECORD_MSG, PDU_SESSION_RECORD_MSG, UE_DU_CONNECTIVITY_MSG, HO_REQUIRED_MSG]
PCMD_MESGS_TRG = [UE_SETUP_RECORD_MSG, PDU_SESSION_RECORD_MSG, UE_DU_CONNECTIVITY_MSG, HO_REQUEST_MSG,
                  HO_REQUEST_ACK_MSG, HO_NOTIFY_CMD]
PER_SLICE_COUNTERS = [NG_HO_PREP_ATT_SRC_IEF_PLMN, NG_HO_EXEC_ATT_SRC_IEF_PLMN, NG_HO_EXEC_SUCC_SRC_IEF_PLMN]
SOURCE_GNB = 'MRBTS-51118'


class Res705And8806(CommonSuite):

    def __init__(self):
        super(Res705And8806, self).__init__()
        self.feature = "5GC000705"
        self.bts_config = BtsConfig()
        self.bts_counters = BtsPmCounters()
        self.bts_startup = StartupManager()
        self.bts_state = BtsState()
        self.syslog = SyslogCollector()
        self.bts_faults = BtsFaults()
        self.bts_snapshot = BtsSnapshot()
        self.gnb_uptime_before_reconfig = 0
        self.env_data = TestEnvData()
        self.attenuator = Attenuator()
        self.ue1 = Ue(ONEPLUS_9_PRO, ue_id=1)
        self.source_gnb_id = 1
        self.source_vm_id = 1
        self.pcap = None
        self.ssh_connection_gnb_source = self.env_data.GNBS[self.source_gnb_id].cu.oam_ssh_connection_details
        self.ssh_connection_gnb_target = self.env_data.GNB_SSH_CONNECTION_DETAILS
        self.ssh_connection_vm_source = self.env_data.VM_SSH_CONN_DETAILS
        self.initial_counters_values = {}
        self.pcap_src_file = None
        self.pcap_tgt_file = None
        self.pcap_f1ap_file = None
        self.pcap_collector = None
        self.pcap_location_on_gnb = '/tmp/master.pcap'
        self.attenuator_ports = list(self.attenuator.attenuator_ports)
        self.source_tdd_ports = self.attenuator_ports[2:4]
        self.target_fdd_ports = self.attenuator_ports[4:6]
        self.target_tdd_ports = self.attenuator_ports[0:2]
        self.pcmd_port_source = '10010'
        self.pcmd_port_target = '10020'
        self.pcmd_trace_path = None

    def target_gnb_is_in_onair_state(self):
        self.bts_startup.manage_commissioned_bts_to_reach_on_air_state()

    def source_gnb_is_in_onair_state(self):
        self.bts_state.are_all_cells_on_air(self.source_gnb_id)

    def commissioned_target_gnb_with_feature_5gc000705_deactivated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'Nonactive')
        self.bts_config.perform_full_commissioning(scf_file)

    def commissioned_target_gnb_with_feature_5gc000705_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'Active')
        self.bts_config.perform_full_commissioning(scf_file)

    def commissioned_target_gnb_with_feature_5gc000705_activated_with_cell_trace_enabled(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature,
                                                                               "pcmd_trace_activate_51117_{}"
                                                                               .format(self.env_data
                                                                                       .get_admin_release())))

    def commissioned_target_gnb_with_feature_5gc000705_activated_with_cell_trace_disabled(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature,
                                                                               "pcmd_trace_deactivate_51117_{}"
                                                                               .format(self.env_data
                                                                                       .get_admin_release())))

    def commissioned_source_gnb_with_feature_5gc000705_activated_with_cell_trace_enabled(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature,
                                                                               "pcmd_trace_activate_51118_{}"
                                                                               .format(self.env_data
                                                                                       .get_admin_release())),
                                                    gnb_id=self.source_gnb_id)

    def commissioned_source_gnb_with_feature_5gc000705_activated_with_cell_trace_disabled(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature,
                                                                               "pcmd_trace_deactivate_51118_{}"
                                                                               .format(self.env_data
                                                                                       .get_admin_release())),
                                                    gnb_id=self.source_gnb_id)

    def commissioned_target_gnb_with_feature_5gc000705_activated_with_blind_scell_addition(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'TargetScell')
        self.bts_config.perform_full_commissioning(scf_file)

    def commissioned_source_gnb_with_feature_5gc000705_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'SourceActive')
        self.bts_config.perform_full_commissioning(scf_file, self.source_gnb_id)

    def commissioned_source_gnb_with_feature_5gc000705_activated_with_blind_scell_addition(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'SourceScell')
        self.bts_config.perform_full_commissioning(scf_file, self.source_gnb_id)

    def commissioned_target_gnb_with_feature_5gc000705_activated_with_reject_handover_preparation_set(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'RejectHOprep')
        self.bts_config.perform_full_commissioning(scf_file)

    def commissioned_source_gnb_with_feature_5gc000705_activated_with_handover_cancellation_set(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'SourceCancellation')
        self.bts_config.perform_full_commissioning(scf_file, self.source_gnb_id)

    def perform_delta_commissioning_activate(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature, "ngap_ho_activate"))

    def perform_delta_commissioning_deactivate(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature, "ngap_ho_deactivate"))

    def get_uptime_from_gnb(self):
        output = execute_ssh_command(self.env_data.GNB_SSH_CONNECTION_DETAILS, command="cut -d ' ' -f1 /proc/uptime")
        return float(output[0])

    def gnb_is_not_restarted(self):
        time_for_potential_gnb_restart = 30
        time.sleep(time_for_potential_gnb_restart)
        assert self.get_uptime_from_gnb() > self.gnb_uptime_before_reconfig, "gNB restarted"

    def parameters_for_ngap_handover_are_activated(self):
        self.gnb_uptime_before_reconfig = self.get_uptime_from_gnb()
        self.perform_delta_commissioning_activate()

    def parameters_for_ngap_handover_are_deactivated(self):
        self.gnb_uptime_before_reconfig = self.get_uptime_from_gnb()
        self.perform_delta_commissioning_deactivate()

    def handover_is_performed(self):
        self.attenuator.perform_handover(self.source_tdd_ports, self.target_fdd_ports)

    def intra_handover_is_performed(self):
        self.attenuator.perform_handover(self.target_fdd_ports, self.target_tdd_ports)

    def pcap_capturing_is_started_on_source_and_target_gnb(self):
        self.start_tcpdump_collection(self.ssh_connection_gnb_source)
        self.start_tcpdump_collection(self.ssh_connection_gnb_target)

    def pcap_capturing_is_started_on_target_gnb(self):
        self.start_tcpdump_collection(self.ssh_connection_gnb_target)

    def pcap_capturing_is_stopped_on_source_and_target_gnb(self):
        self.stop_tcpdump_collection(self.ssh_connection_gnb_source)
        self.stop_tcpdump_collection(self.ssh_connection_gnb_target)
        self.pcap_src_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_src.pcap")
        self.pcap_tgt_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_tgt.pcap")
        self.collect_tcpdump(self.pcap_src_file, self.ssh_connection_gnb_source)
        self.collect_tcpdump(self.pcap_tgt_file, self.ssh_connection_gnb_target)

    def pcap_capturing_is_stopped_on_target_gnb(self):
        self.stop_tcpdump_collection(self.ssh_connection_gnb_target)
        self.pcap_tgt_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_tgt.pcap")
        self.collect_tcpdump(self.pcap_tgt_file, self.ssh_connection_gnb_target)

    def successful_handover_attempt_log_is_stored_in_pcap(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_tgt_file, NGAP_PROTOCOL)
        pcap_from_target = [item.strip(' ') for item in tshark_parser.tshark_output]

        for msg in [HO_REQUIRED_MSG, HO_COMMAND_MSG]:
            assert msg in pcap_from_source, PCAP_UNSUCCESSFUL_MSG
        for msg in [HO_REQUEST_MSG, HO_REQUEST_ACK_MSG, DL_RAN_STAT_TRANSFER, HO_NOTIFY_CMD]:
            assert msg in pcap_from_target, PCAP_UNSUCCESSFUL_MSG

    def no_successful_handover_attempt_log_is_stored_in_pcap(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_tgt_file, NGAP_PROTOCOL)
        pcap_from_target = [item.strip(' ') for item in tshark_parser.tshark_output]

        for msg in [HO_REQUEST_ACK_MSG, DL_RAN_STAT_TRANSFER, HO_NOTIFY_CMD]:
            assert msg not in pcap_from_target, PCAP_NOT_PROPER_MSG

    def unsuccessful_handover_attempt_log_is_stored_in_pcap(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_tgt_file, NGAP_PROTOCOL)
        pcap_from_target = [item.strip(' ') for item in tshark_parser.tshark_output]

        for msg in [HO_REQUIRED_MSG, HO_PREP_FAIL_MSG]:
            assert msg in pcap_from_source, PCAP_UNSUCCESSFUL_MSG
        for msg in [HO_REQUEST_ACK_MSG, HO_NOTIFY_CMD]:
            assert msg not in pcap_from_target, PCAP_NOT_PROPER_MSG

    def handover_preparation_rejection_attempt_log_is_stored_in_pcap(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_tgt_file, NGAP_PROTOCOL)
        pcap_from_target = [item.strip(' ') for item in tshark_parser.tshark_output]

        for msg in [HO_REQUIRED_MSG, HO_PREP_FAIL_MSG]:
            assert msg in pcap_from_source, PCAP_UNSUCCESSFUL_MSG
        for msg in [HO_REQUEST_MSG, HO_FAIL_MSG]:
            assert msg in pcap_from_target, PCAP_NOT_PROPER_MSG

    def handover_cancellation_attempt_log_is_stored_in_pcap(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_tgt_file, NGAP_PROTOCOL)
        pcap_from_target = [item.strip(' ') for item in tshark_parser.tshark_output]

        for msg in [HO_CANCEL_MSG, HO_CANCEL_ACK_MSG]:
            assert msg in pcap_from_source, PCAP_UNSUCCESSFUL_MSG
        assert UE_CONTEXT_REL_CMD in pcap_from_target, PCAP_UNSUCCESSFUL_MSG

    def successful_handover_with_blind_scell_addition_attempt_log_is_stored_in_pcap(self):
        self.successful_handover_attempt_log_is_stored_in_pcap()
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_f1ap_file, F1AP_PROTOCOL)
        pcap_from_target_f1ap = [item.strip(' ') for item in tshark_parser.tshark_output]
        assert (SCELL_ADDITION_MSG in msg for msg in pcap_from_target_f1ap), PCAP_UNSUCCESSFUL_MSG

    def counters_are_incremented_ab3(self):
        self.check_if_counters_are_incremented(COUNTERS_705AB3, TARGET_HO_CELL_NR)

    def counters_are_incremented_ab3_cb008806(self):
        self.check_if_counters_are_incremented(COUNTERS_8806AB3_NRCEL, SOURCE_HO_CELL_NR, self.source_gnb_id)
        self.check_if_counters_are_incremented_nrrel(COUNTERS_8806AB3_NRREL, SOURCE_HO_CELL_NR, self.source_gnb_id)

    def counters_are_incremented_aec2_cb008806(self):
        self.check_if_counters_are_incremented(COUNTERS_8806AEC2, SOURCE_HO_CELL_NR, self.source_gnb_id)

    def counter_is_incremented_aec1(self):
        self.check_if_first_counter_is_already_updated(NG_HO_RES_ALC_F_AC_TRG, TARGET_HO_CELL_NR)

    def counter_is_incremented_aec1_cb008806(self):
        self.check_if_first_counter_is_already_updated(NG_HO_PREP_FAIL_RRL_SRC, SOURCE_HO_CELL_NR, self.source_gnb_id)

    def hanover_per_slice_counters_are_incremented_on_source(self):
        self.check_if_counters_are_incremented_slice(PER_SLICE_COUNTERS, self.source_gnb_id)

    def environment_for_successful_handover_is_prepared(self):
        for port in self.target_fdd_ports + self.target_tdd_ports:
            self.attenuator.set_port_attenuation(port, INITIAL_MAX_ATTENUATION)
        for port in self.source_tdd_ports:
            self.attenuator.set_port_attenuation(port, MIN_ATTENUATION)
        self.ue1.prepare_ue()
        self.ue1.restart_ue()
        self.ue1.attach()

    def environment_for_unsuccessful_handover_is_prepared(self):
        for port in self.source_tdd_ports + self.target_tdd_ports:
            self.attenuator.set_port_attenuation(port, INITIAL_MAX_ATTENUATION)
        for port in self.target_fdd_ports:
            self.attenuator.set_port_attenuation(port, MIN_ATTENUATION)
        self.ue1.prepare_ue()
        self.ue1.restart_ue()
        self.ue1.attach()

    def ue_data_traffic_is_started(self):
        traffic_duration = 90
        traffic_thp = 100
        self.ue1.start_udp_downlink_data_transmission(traffic_duration, traffic_thp, data_name='DL')

    def start_tcpdump_collection(self, ssh_connection, cmd=TCPDUMP_CMD, bsh_number=None):
        if bsh_number in None:
            execute_ssh_command(ssh_connection, cmd)
        else:
            execute_ssh_command_on_bsh(smod_ssh_connection_parameters=ssh_connection,
                                       bsh_number=bsh_number,
                                       command=cmd)

        log_bsh_number = "" if bsh_number is None else " (bsh: {})".format(bsh_number)
        Logger.info("Tcpdump is running on gnb{}: {}".format(log_bsh_number, cmd))
        self._make_sure_tcpdump_is_running(ssh_connection)

    def _make_sure_tcpdump_is_running(self, ssh_connection, pid_cmd=PID_TCPDUMP_CMD):
        pid_script_process = self._get_tcpdump_pid(ssh_connection, pid_cmd)
        assert pid_script_process, "Tcpdump was not started"

    @staticmethod
    def _get_tcpdump_pid(ssh_connection, pid_cmd, bsh_number=None):
        if bsh_number is None:
            output, _ = execute_ssh_command(ssh_connection, pid_cmd)
        else:
            output, _ = execute_ssh_command_on_bsh(smod_ssh_connection_parameters=ssh_connection,
                                                   bsh_number=bsh_number,
                                                   command=pid_cmd)
        return output

    @staticmethod
    def collect_tcpdump(logdir, ssh_connection, pcap_location_on_gnb='/tmp/master.pcap'):
        download_file(ssh_connection, pcap_location_on_gnb, logdir)

    def stop_tcpdump_collection(self, ssh_connection):
        pid_script_process = self._get_tcpdump_pid(ssh_connection, PID_TCPDUMP_CMD)
        kill_tcpdump = "kill -2 {}".format(pid_script_process)
        execute_ssh_command(ssh_connection, kill_tcpdump)

    def stop_tcpdump_collection_on_slave(self):
        pid_script_process = self._get_tcpdump_pid(self.ssh_connection_gnb_target, F1AP_PID_TCPDUMP_CMD, "0:1")
        kill_tcpdump = "kill -2 {}".format(pid_script_process)
        execute_ssh_command_on_bsh(smod_ssh_connection_parameters=self.ssh_connection_gnb_target,
                                   bsh_number="0:1",
                                   command=kill_tcpdump)

    def check_if_counters_on_gnb_are_incremented(self, list_of_counters, cell, gnb_id=0):
        for counter in list_of_counters:
            self.bts_counters.get_and_confirm_bts_cell_pm_counter_is_greater_than_zero(counter, cell, gnb_id=gnb_id)

    def check_if_first_counter_is_already_updated(self, counter, cell, gnb_id=0):
        self.bts_counters.wait_and_confirm_bts_cell_pm_counter_is_greater_than_zero(counter, cell, gnb_id)

    def check_if_counters_are_incremented(self, list_of_counters, cell_id, gnb_id=0):
        self.check_if_first_counter_is_already_updated(list_of_counters[0], cell_id, gnb_id)
        self.check_if_counters_on_gnb_are_incremented(list_of_counters, cell_id, gnb_id)

    def check_if_counters_are_incremented_nrrel(self, list_of_counters, cell_id, gnb_id):
        for counter in list_of_counters:
            values = list(self.bts_counters.get_raw_pm_counters([counter], gnb_id)[u'BTS'][u'CELLS']
                          [u'NRCELL-{}'.format(cell_id)][u'NRCI-837500982'][u'MCC-540_MNC-01'][u'NRREL']
                          [u'{}'.format(counter)].values())
            assert sum(values) > 0

    def check_if_counters_are_incremented_slice(self, list_of_counters, gnb_id):
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()
        for counter in list_of_counters:
            values = list(self.bts_counters.get_raw_pm_counters([counter], gnb_id)[u'BTS'][u'BTS'][u'NRBTS-51118']
                          [u'MCC-540_MNC-01'][u'SST-1_SD-13714341'][u'NSL']
                          [u'{}'.format(counter)].values())
            assert sum(values) > 0

    def cleanup_the_setup_and_collect_logs_if_the_test_failed(self):
        self.cleanup_the_setup_and_collect_logs_if_the_test_fails()
        self.stop_tcpdump_collection(self.ssh_connection_gnb_source)
        self.stop_tcpdump_collection(self.ssh_connection_gnb_target)
        self.stop_tcpdump_collection_on_slave()
        self.ue1.detach()

    def make_sure_ue_actions_are_cleared(self):
        self.ue1.try_to_get_and_remove_traffic_log_files()

    def cleanup_environment_and_collect_snapshot_if_execution_fails(self):
        self.bts_startup.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(
            bts_name=SOURCE_GNB, ssh_connection_details=self.ssh_connection_vm_source)

    @staticmethod
    def update_swconfig_for_syslog_flags():
        syslog_flags = ["0x420000=1", "0x10041=2", "0x590072=1", "0x41001b=1"]
        Swconfig().update_swconfig_flags(syslog_flags)

    def prepare_ue_and_start_logging(self):
        self.ue1.prepare_ue()
        self.syslog.start_btslog_on_local_machine()

    def update_swconfig_and_prepare_source_gnb(self):
        self.update_swconfig_for_syslog_flags()
        self.bts_startup.update_sw_and_commission_remote_bts(self.feature, SOURCE_GNB, self.ssh_connection_vm_source,
                                                             'SourceActive')

    def update_swconfig_and_prepare_source_gnb_and_download_nsetapx_plugin(self):
        self.update_swconfig_for_syslog_flags()
        self.make_sure_mcshark_plugin_exists()

    def slave_pcap_capturing_is_started(self):
        self.start_tcpdump_collection(self.ssh_connection_gnb_target, F1AP_TCPDUMP_CMD, "0:1")

    def slave_pcap_capturing_is_stopped(self):
        self.stop_tcpdump_collection_on_slave()
        self.pcap_f1ap_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_f1ap.pcap")
        self.collect_tcpdump(self.pcap_f1ap_file, self.ssh_connection_gnb_target,
                             pcap_location_on_gnb='/ffs/run/logs/slave.pcap')

    def start_capturing_pcmd_trace(self, port):
        nc_command = 'nc -lkvnp {} --recv-only'.format(port)
        VmOs.execute_single_command_in_shell('(nohup {} 1>/dev/null 2>/dev/null &); exit'.format(nc_command))
        self.start_pcap_collector(port)

    @staticmethod
    def stop_capturing_pcmd_trace():
        pid = VmOs.execute_single_command_in_shell(PID_NC_CMD)
        VmOs.execute_single_command_in_shell('kill {}'.format(pid))

    @staticmethod
    def check_if_mesgs_are_in_tracing_pcap(file_path, list_of_mesgs):
        decoded_trace = TSharkParser().decode_nsetapx_from_pcap_with_custom_param(file_path, NSETAPX_SETTINGS)
        for mesg in list_of_mesgs:
            assert mesg in decoded_trace, PCAP_UNSUCCESSFUL_MSG

    @staticmethod
    def check_if_mesgs_are_not_in_tracing_pcap(file_path, list_of_mesgs):
        decoded_trace = TSharkParser().decode_nsetapx_from_pcap_with_custom_param(file_path, NSETAPX_SETTINGS)
        for mesg in list_of_mesgs:
            assert mesg not in decoded_trace, PCAP_INCORRECT_MSG

    def nsetapx_messages_are_stored_in_tracing_log_from_source(self):
        self.check_if_mesgs_are_in_tracing_pcap(self.pcmd_trace_path, PCMD_MESGS_SRC)

    def nsetapx_messages_are_stored_in_tracing_log_from_target(self):
        self.check_if_mesgs_are_in_tracing_pcap(self.pcmd_trace_path, PCMD_MESGS_TRG)

    def nsetapx_messages_are_not_stored_in_tracing_log_from_source(self):
        self.check_if_mesgs_are_not_in_tracing_pcap(self.pcmd_trace_path, PCMD_MESGS_SRC)

    def nsetapx_messages_are_not_stored_in_tracing_log_from_target(self):
        self.check_if_mesgs_are_not_in_tracing_pcap(self.pcmd_trace_path, PCMD_MESGS_TRG)

    def trace_capturing_is_started_on_source(self):
        self.start_capturing_pcmd_trace(self.pcmd_port_source)

    def trace_capturing_is_started_on_target(self):
        self.start_capturing_pcmd_trace(self.pcmd_port_target)

    def trace_capturing_is_stopped(self):
        self.stop_capturing_pcmd_trace()
        self.pcap_collector.stop_collecting_pcap()
        self.pcmd_trace_path = self.pcap_collector.pcap_file_path

    def start_pcap_collector(self, port):
        self.pcap_collector = PcapCollector()
        self.pcap_collector.start_collecting_pcap(port=port)
