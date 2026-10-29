from time import sleep

from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, download_file
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import XIAOMI_MI11
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkParser import McsharkParser as TSharkParser
from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl

SST = 'sST: 1e'
SD = 'sD: d143a5'
ALLOWED_NSSAI = 'AllowedNSSAI: 1 item'
DRBS_TO_BE_SETUP = 'DRBs-ToBeSetup-List: 1 item'
PDU_TO_SETUP = 'PDU-Session-Resource-To-Setup-List: 1 item'
DL_RAN_STAT_TRANSFER = 'DownlinkRANStatusTransfer'
HO_REQUIRED_MSG = 'HandoverRequired'
HO_REQUEST_MSG = 'HandoverRequest'
HO_REQUEST_ACK_MSG = 'HandoverRequestAcknowledge'
HO_COMMAND_MSG = 'HandoverCommand'
HO_NOTIFY_CMD = 'HandoverNotify'
MIN_ATTENUATION = 0
MAX_ATTENUATION = 63
INITIAL_MAX_ATTENUATION = 90
PCAP_UNSUCCESSFUL_MSG = 'Not all required mesgs found in pcap'
PID_TCPDUMP_CMD = "ps -ef | grep tcpdump | egrep -v 'grep|firewall|cp_nb|eth' | awk '{print $2}'"
TCPDUMP_CMD = 'cd /tmp && (nohup  tcpdump -i any -w master.pcap 1>/dev/null 2>/dev/null &); exit'
NGAP_PROTOCOL = 'ngap'
XNAP_PROTOCOL = 'xnap'
E1AP_PROTOCOL = 'e1ap'
F1AP_PROTOCOL = 'f1ap'
PHONE_NO = "+358485611000533"
PHONE_CALL_DURATION_SEC = 20
CALL_ONGOING = 'mCallState=2'
CALL_ENDED = 'mCallState=0'
WRONG_CALL_STAT_MSG = 'Wrong status of the phone call'
DRB_INACTIVITY_TIMEOUT_SEC = 10
NGAP_PDU_RES_REL_REQ = ['PDUSessionResourceItemCxtRelReq', 'pDUSessionID: 2']
NGAP_PDU_RES_REL_RESP = ['PDUSessionResourceItemCxtRelCpl', 'pDUSessionID: 2']
F1AP_CTX_MOD_REQ = 'UEContextModificationRequest'
F1AP_CTX_MOD_RESP = 'UEContextModificationResponse'
F1AP_DU_TO_CU_RRC = 'DUtoCURRCInformation'
F1AP_RLC_CFG_AM = 'rlc-Config: am (0)'
F1AP_DL_RRC_RECONF = ['DL-DCCH-Message', 'message: c1 (0)', 'c1: rrcReconfiguration (0)']
F1AP_RRC_RECONF_CPL = 'RRCReconfigurationCompleteIndicator: true (0)'
F1AP_UL_RRC_RECONF_CPL = ['UL-DCCH-Message', 'message: c1 (0)', 'c1: rrcReconfigurationComplete (1)']
E1AP_DRB_TO_REM = ['pDU-Session-ID: 2', 'dRB-To-Remove-List-NG-RAN: 1 item']
E1AP_BEARER_CTX_MOD_RESP = 'nG-RAN-BearerContextModificationResponse: 1 item'
NG_HO_PREP_ATT_SRC_IAF_PLMN = 'M55149C03001'
NG_HO_EXEC_ATT_SRC_IAF_PLMN = 'M55149C03002'
NG_HO_EXEC_SUCC_SRC_IAF_PLMN = 'M55149C03003'
PER_SLICE_COUNTERS = [NG_HO_PREP_ATT_SRC_IAF_PLMN, NG_HO_EXEC_ATT_SRC_IAF_PLMN, NG_HO_EXEC_SUCC_SRC_IAF_PLMN]
SOURCE_GNB = 'MRBTS-51114'
NG_HO_RES_ALC_ATT_TRG = 'M55125C07503'
NG_HO_RES_ALC_SUCC_TRG = 'M55125C07504'
NG_HO_EXEC_NOTIFY_TRG = 'M55125C07520'
NG_HO_PREP_SUCC_SRC = 'M55125C07512'
NG_HO_EXEC_ATT_SRC_NRREL = 'M55153C00502'
NG_HO_EXEC_SUCC_SRC_NRREL = 'M55153C00503'
NG_HO_EXEC_AVG_TIME = 'M55125C07525'
NG_HO_EXEC_MAX_TIME = 'M55125C07526'
NG_HO_PREP_ATT_SRC_NRREL = 'M55153C00501'
COUNTERS_NGHO_SUCC = [NG_HO_RES_ALC_ATT_TRG, NG_HO_RES_ALC_SUCC_TRG, NG_HO_EXEC_NOTIFY_TRG]
COUNTERS_NGHO_NRCEL_SUCC = [NG_HO_PREP_SUCC_SRC, NG_HO_EXEC_AVG_TIME, NG_HO_EXEC_MAX_TIME]
COUNTERS_NGHO_NRREL_SUCC = [NG_HO_PREP_ATT_SRC_NRREL, NG_HO_EXEC_ATT_SRC_NRREL, NG_HO_EXEC_SUCC_SRC_NRREL]
TARGET_HO_CELL_NR = 1
SOURCE_HO_CELL_NR = 1


class Res8120(object):

    def __init__(self):
        self.feature = "CB008120"
        self.attenuator = Attenuator()
        self.attenuator_ports = list(self.attenuator.attenuator_ports)
        self.bts_config = BtsConfig()
        self.bts_counters = BtsPmCounters()
        self.bts_startup = StartupManager()
        self.bts_state = BtsState()
        self.env_data = TestEnvData()
        self.bts_faults = BtsFaults()
        self.bts_snapshot = BtsSnapshot()
        self.syslog = SyslogCollector()
        self.pcap_src_file = None
        self.pcap_tgt_file = None
        self.pcap_slave_file = None
        self.source_gnb_id = 1
        self.source_gnb_tl_id = 51114
        self.target_gnb_tl_id = 51113
        self.source_vm_id = 1
        self.ssh_connection_gnb_source = self.env_data.GNBS[self.source_gnb_id].cu.oam_ssh_connection_details
        self.ssh_connection_gnb_target = self.env_data.GNB_SSH_CONNECTION_DETAILS
        self.ssh_connection_vm_source = self.env_data.VM_SSH_CONN_DETAILS
        self.source_tdd_ports = self.attenuator_ports[2:4]
        self.target_tdd_ports = self.attenuator_ports[0:2]
        self.ue1 = Ue(XIAOMI_MI11, ue_id=1)

    def target_gnb_is_in_onair_state(self):
        self.bts_startup.manage_commissioned_bts_to_reach_on_air_state()

    def source_gnb_is_in_onair_state(self):
        self.bts_state.are_all_cells_on_air(self.source_gnb_id)

    def commissioned_target_gnb_with_feature_cb008120_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'TargetActivated')
        self.bts_config.perform_full_commissioning(scf_file)

    def commissioned_source_gnb_with_feature_cb008120_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'SourceActivated')
        self.bts_config.perform_full_commissioning(scf_file, self.source_gnb_id)

    def commissioned_target_gnb_with_xn_handover_enabled(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature, "activate_xn_ho_tgt"))

    def commissioned_source_gnb_with_xn_handover_enabled(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature, "activate_xn_ho_src"),
                                                    gnb_id=self.source_gnb_id)

    def hanover_per_slice_counters_are_incremented_on_source(self):
        self.check_if_counters_are_incremented_slice(PER_SLICE_COUNTERS, self.source_gnb_id)

    def successful_attach_is_performed(self):
        for port in self.target_tdd_ports:
            self.attenuator.set_port_attenuation(port, INITIAL_MAX_ATTENUATION)
        for port in self.source_tdd_ports:
            self.attenuator.set_port_attenuation(port, MIN_ATTENUATION)
        self.ue1.prepare_ue()
        self.ue1.attach()

    def successful_attach_with_vonr_is_peformed(self):
        self.successful_attach_is_performed()
        self._make_vonr_attach()

    def environment_for_successful_handover_is_prepared(self):
        for port in self.target_tdd_ports:
            self.attenuator.set_port_attenuation(port, INITIAL_MAX_ATTENUATION)
        for port in self.source_tdd_ports:
            self.attenuator.set_port_attenuation(port, MIN_ATTENUATION)
        self.ue1.prepare_ue()
        self.ue1.attach()

    def start_tcpdump_collection(self, ssh_connection, cmd=TCPDUMP_CMD):
        execute_ssh_command(ssh_connection, cmd)
        Logger.info("Tcpdump is running on gnb: {}".format(cmd))
        self._make_sure_tcpdump_is_running(ssh_connection)

    def stop_tcpdump_collection(self, ssh_connection):
        pid_script_process = self._get_tcpdump_pid(ssh_connection, PID_TCPDUMP_CMD)
        kill_tcpdump = "kill -15 {}".format(pid_script_process)
        execute_ssh_command(ssh_connection, kill_tcpdump)

    @staticmethod
    def _get_tcpdump_pid(ssh_connection, pid_cmd):
        output, _ = execute_ssh_command(ssh_connection, pid_cmd)
        return output

    def _make_sure_tcpdump_is_running(self, ssh_connection, pid_cmd=PID_TCPDUMP_CMD):
        pid_script_process = self._get_tcpdump_pid(ssh_connection, pid_cmd)
        assert pid_script_process, "Tcpdump was not started"

    @staticmethod
    def collect_tcpdump(logdir, ssh_connection, pcap_location_on_gnb='/tmp/master.pcap'):
        download_file(ssh_connection, pcap_location_on_gnb, logdir)

    def pcap_capturing_is_started_on_source_gnb(self):
        self.start_tcpdump_collection(self.ssh_connection_gnb_source)

    def pcap_capturing_is_started_on_source_and_target_gnb(self):
        self.start_tcpdump_collection(self.ssh_connection_gnb_source)
        self.start_tcpdump_collection(self.ssh_connection_gnb_target)

    def pcap_capturing_is_stopped_on_source_gnb(self):
        self.stop_tcpdump_collection(self.ssh_connection_gnb_source)
        self.pcap_src_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_src.pcap")
        self.collect_tcpdump(self.pcap_src_file, self.ssh_connection_gnb_source)

    def pcap_capturing_is_stopped_on_source_and_target_gnb(self):
        self.stop_tcpdump_collection(self.ssh_connection_gnb_source)
        self.stop_tcpdump_collection(self.ssh_connection_gnb_target)
        self.pcap_src_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_src.pcap")
        self.pcap_tgt_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_tgt.pcap")
        self.collect_tcpdump(self.pcap_src_file, self.ssh_connection_gnb_source)
        self.collect_tcpdump(self.pcap_tgt_file, self.ssh_connection_gnb_target)

    def ue_data_traffic_is_started(self):
        traffic_duration = 120
        traffic_thp = 10
        self.ue1.start_udp_downlink_data_transmission(traffic_duration, traffic_thp, data_name='DL')

    def handover_is_performed(self):
        self.attenuator.perform_handover(self.source_tdd_ports, self.target_tdd_ports)

    def check_ngap_attach_log(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        for msg in [ALLOWED_NSSAI, SST, SD]:
            assert msg in pcap_from_source, PCAP_UNSUCCESSFUL_MSG

    def check_f1ap_attach_log(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, F1AP_PROTOCOL)
        pcap_from_source_f1ap = [item.strip(' ') for item in tshark_parser.tshark_output]
        for msg in [DRBS_TO_BE_SETUP, SST, SD]:
            assert msg in pcap_from_source_f1ap, PCAP_UNSUCCESSFUL_MSG

    def check_e1ap_attach_log(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, E1AP_PROTOCOL)
        pcap_from_source_e1ap = [item.strip(' ') for item in tshark_parser.tshark_output]
        for msg in [PDU_TO_SETUP, SST, SD]:
            assert msg in pcap_from_source_e1ap, PCAP_UNSUCCESSFUL_MSG

    def successful_attach_attempt_log_is_stored_in_pcap(self):
        self.check_ngap_attach_log()
        self.check_f1ap_attach_log()
        self.check_e1ap_attach_log()

    def successful_ngap_handover_attempt_log_is_stored_in_pcap(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_tgt_file, NGAP_PROTOCOL)
        pcap_from_target = [item.strip(' ') for item in tshark_parser.tshark_output]

        for msg in [HO_REQUIRED_MSG, HO_COMMAND_MSG]:
            assert msg in pcap_from_source, PCAP_UNSUCCESSFUL_MSG
        for msg in [HO_REQUEST_MSG, HO_REQUEST_ACK_MSG, DL_RAN_STAT_TRANSFER, HO_NOTIFY_CMD]:
            assert msg in pcap_from_target, PCAP_UNSUCCESSFUL_MSG

    def successful_xnap_handover_attempt_log_is_stored_in_pcap(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, XNAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_tgt_file, XNAP_PROTOCOL)
        pcap_from_target = [item.strip(' ') for item in tshark_parser.tshark_output]

        for msg in [HO_REQUEST_MSG, HO_REQUEST_ACK_MSG]:
            assert msg in pcap_from_source, PCAP_UNSUCCESSFUL_MSG
        for msg in [HO_REQUEST_MSG, HO_REQUEST_ACK_MSG]:
            assert msg in pcap_from_target, PCAP_UNSUCCESSFUL_MSG

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        Rfrl.common_step_trigger()
        self.ue1.detach()
        self.stop_tcpdump_collection(self.ssh_connection_gnb_source)
        self.stop_tcpdump_collection(self.ssh_connection_gnb_target)
        self.ue1.try_to_get_and_remove_traffic_log_files()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.bts_faults.log_active_faults()

    def cleanup_environment_and_collect_snapshot_if_execution_fails(self):
        self.bts_snapshot.collect_snapshot_if_the_suite_fails()
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
                                                             'SourceActivated')

    def phone_call_is_established(self):
        self.ue1.make_phone_call(PHONE_NO)
        sleep(PHONE_CALL_DURATION_SEC)
        assert CALL_ONGOING in self.ue1.get_phone_call_status(), WRONG_CALL_STAT_MSG

    def phone_call_is_ended(self):
        self.ue1.hang_up_phone_call()
        assert CALL_ENDED in self.ue1.get_phone_call_status(), WRONG_CALL_STAT_MSG

    def successful_release_attempt_log_is_stored_in_pcap(self):
        self._check_ngap_pcap_for_cb008120bc()
        self._check_f1ap_pcap_for_cb008120bc()
        self._check_e1ap_pcap_for_cb008120bc()

    def check_if_counters_are_incremented_slice(self, list_of_counters, gnb_id):
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()
        for counter in list_of_counters:
            values = list(self.bts_counters.get_raw_pm_counters([counter], gnb_id)[u'BTS'][u'BTS'][u'NRBTS-51114']
                          [u'MCC-540_MNC-01'][u'SST-30_SD-13714341'][u'NSL']
                          [u'{}'.format(counter)].values())
            assert sum(values) > 0

    def check_if_first_counter_is_already_updated(self, counter, cell, bts_id, gnb_id=0):
        self.bts_counters.wait_and_confirm_bts_cell_pm_counter_is_greater_than_zero(counter_id=counter, cell_id=cell,
                                                                                    bts_id=bts_id, gnb_id=gnb_id)

    def check_if_counters_on_gnb_are_incremented(self, list_of_counters, cell, bts_id, gnb_id=0):
        for counter in list_of_counters:
            self.bts_counters.get_and_confirm_bts_cell_pm_counter_is_greater_than_zero(counter_id=counter, cell_id=cell,
                                                                                       bts_id=bts_id, gnb_id=gnb_id)

    def check_if_counters_are_incremented_nrrel(self, list_of_counters, cell_id, gnb_id):
        for counter in list_of_counters:
            if 'SBTS24R2' in self.env_data.get_admin_release():
                values = list(self.bts_counters.get_raw_pm_counters([counter], gnb_id)[u'BTS']
                              [u'MRBTS-{}'.format(self.source_gnb_tl_id)][u'NRBTS-{}'.format(self.source_gnb_tl_id)]
                              [u'NRCELL-{}'.format(cell_id)][u'NRCI-837435393'][u'MCC-540'][u'MNC-01'][u'NRREL']
                              [u'{}'.format(counter)].values())
            else:
                values = list(self.bts_counters.get_raw_pm_counters([counter], gnb_id)[u'BTS'][u'CELLS']
                              [u'NRCELL-{}'.format(cell_id)][u'NRCI-837435393'][u'MCC-540_MNC-01'][u'NRREL']
                              [u'{}'.format(counter)].values())
            assert sum(values) > 0

    def check_if_counters_are_incremented(self, list_of_counters, cell_id, bts_id, gnb_id=0):
        self.check_if_first_counter_is_already_updated(list_of_counters[0], cell_id, bts_id, gnb_id)
        self.check_if_counters_on_gnb_are_incremented(list_of_counters, cell_id, bts_id, gnb_id)

    def counters_are_incremented_for_successful_ng_ho(self):
        self.check_if_counters_are_incremented(COUNTERS_NGHO_SUCC, TARGET_HO_CELL_NR, bts_id=self.target_gnb_tl_id)
        self.check_if_counters_are_incremented(COUNTERS_NGHO_NRCEL_SUCC, SOURCE_HO_CELL_NR, self.source_gnb_tl_id,
                                               self.source_gnb_id)
        self.check_if_counters_are_incremented_nrrel(COUNTERS_NGHO_NRREL_SUCC, SOURCE_HO_CELL_NR, self.source_gnb_id)

    def snssai_drb_inactivity_timer_is_set(self):
        self.bts_config.perform_delta_commissioning(
            ScfPathFinder().get_delta_path_for_feature(self.feature, "activate_snssai_drbinactivitytimer_src_{}"
                                                       .format(self.env_data.get_admin_release())),
            gnb_id=self.source_gnb_id)

    def nrdrb_drb_inactivity_timer_is_set(self):
        self.bts_config.perform_delta_commissioning(
            ScfPathFinder().get_delta_path_for_feature(self.feature, "activate_nrdrb_drbinactivitytimer_src"),
            gnb_id=self.source_gnb_id)

    @staticmethod
    def drb_timeout_is_reached():
        sleep(DRB_INACTIVITY_TIMEOUT_SEC)

    def _check_ngap_pcap_for_cb008120bc(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        for msg_list in [NGAP_PDU_RES_REL_REQ, NGAP_PDU_RES_REL_RESP]:
            assert list(filter(lambda msg: msg in msg_list, pcap_from_source)), PCAP_UNSUCCESSFUL_MSG

    def _check_f1ap_pcap_for_cb008120bc(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, F1AP_PROTOCOL)
        pcap_from_source_f1ap = [item.strip(' ') for item in tshark_parser.tshark_output]
        for msg in [F1AP_CTX_MOD_REQ, F1AP_CTX_MOD_RESP, F1AP_DU_TO_CU_RRC, F1AP_RLC_CFG_AM]:
            assert msg in pcap_from_source_f1ap, PCAP_UNSUCCESSFUL_MSG
        for msg_list in [F1AP_DL_RRC_RECONF, F1AP_RRC_RECONF_CPL, F1AP_UL_RRC_RECONF_CPL]:
            assert list(filter(lambda msg: msg in msg_list, pcap_from_source_f1ap)), PCAP_UNSUCCESSFUL_MSG

    def _check_e1ap_pcap_for_cb008120bc(self):
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(self.pcap_src_file, E1AP_PROTOCOL)
        pcap_from_source_e1ap = [item.strip(' ') for item in tshark_parser.tshark_output]
        for msg_list in [E1AP_DRB_TO_REM, E1AP_BEARER_CTX_MOD_RESP]:
            assert list(filter(lambda msg: msg in msg_list, pcap_from_source_e1ap)), PCAP_UNSUCCESSFUL_MSG

    def _make_vonr_attach(self):
        for attempt in range(1, 4):
            Logger.info("VoNR attach - attempt #{}".format(attempt))
            if self.ue1.get_vonr_status():
                Logger.info("IMS registered, VoNR attached")
                return
            else:
                Logger.info("IMS NOT registered")
                self.ue1.detach()
                self.ue1.attach()
        assert False, "No VoNR attach after 3 attempts"
