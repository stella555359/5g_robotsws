import os
import re
import tarfile

from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pdml import pdml
from taf.collectors.btslog import btslog
from taf.collectors.core import core
from taf.collectors.tcpdump import tcpdump
from taf.converters.pcaptopdml import pcaptopdml
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.resources.log.log import blog

_pdml = pdml()
ute_tshark = ute_tshark()
builtin = BuiltIn()
pcaptopdml = pcaptopdml()
_core = core()
_btslog = btslog()

L_PMO29_pcap_msgs = [
    "e1ap.procedureCode == 9 and e1ap.id == 17",
    "f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and nr-rrc.c1 == 2",
    "e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9 and e1ap.protocolIEs == 2",
    "f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 6",
    "f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and nr-rrc.resumeCause == 8",
    "f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and nr-rrc.c1 == 0"
]

J_B05_pcap_msgs = [
    "e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9 and e1ap.id == 17",
    "f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and nr-rrc.criticalExtensions == 0 "
    "and nr-rrc.ran_NotificationAreaInfo == 1 and nr-rrc.mcc == 3 and nr-rrc.mnc == 2",
    "e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9 and e1ap.protocolIEs == 2",
    "f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 6",
    "f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and nr-rrc.c1 == 0 and nr-rrc.resumeCause == 8"
]

B_pcap = [
    'e1ap.BearerContextInactivityNotification_element',
    'e1ap.BearerContextModificationRequest_element',
    'f1ap.UEContextReleaseCommand_element',
    'e1ap.BearerContextModificationResponse_element',
    'e1ap.f1ap.UEContextReleaseComplete_element']


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def extract_file():
    file_path = get_path()
    with tarfile.open("{}/btslog/{}".format(file_path, "BtsLog.tgz", 'r')) as tar:
        tar.extractall(file_path + "/btslog/")


def create_syslog_collector(filename):
    executor = {"host": "10.44.149.146",
                "user": "ute",
                "password": "uteUTE!"}
    _btslog.create_btslog_collector(name="btslog", target_file_name=filename,
                                    executor=executor)
    _btslog.setup_collectors("btslog")


def start_syslog():
    _btslog.start_collectors("btslog")
    _btslog.set_global_alias("btslog")


def stop_and_collect_syslog(file_dir):
    _btslog.stop_collectors("btslog")
    _btslog.collect_collectors("btslog", target_dir=file_dir)
    _btslog.teardown_collectors("btslog")
    extract_file()


def create_tcpdump_collector(pcap_file):
    executor_master = {"host": "192.168.255.129",
                       "user": "toor4nsn",
                       "password": "oZPS0POrRieRtu"}
    executor_slave = {"host": "192.168.253.2",
                      "user": "toor4nsn",
                      "password": "oZPS0POrRieRtu",
                      "proxy": executor_master}
    tcpdump().create_tcpdump_collector(name="tcpdump", target_file_name=pcap_file, options="sctp -i any -p",
                                       executor=executor_slave)
    _core.setup_collectors("tcpdump")


def create_tcpdump_collector_from_remote(pcap_file):
    executor = {"host": "10.44.224.23",
                "user": "toor4nsn",
                "password": "oZPS0POrRieRtu"}
    tcpdump().create_tcpdump_collector(name="tcpdump_remote", target_file_name=pcap_file, options="sctp -i any -p",
                                       executor=executor, capture_locally="true")
    _core.setup_collectors("tcpdump_remote")


def start_collecting_tcp_dump():
    _core.start_collectors("tcpdump")
    tcpdump().set_global_alias("tcpdump")


def start_collecting_tcp_dump_remote():
    _core.start_collectors("tcpdump_remote")
    tcpdump().set_global_alias("tcpdump_remote")


def stop_and_collect_tcp_dump(file_dir):
    _core.stop_collectors("tcpdump")
    _core.collect_collectors("tcpdump", target_dir=file_dir)
    _core.teardown_collectors("tcpdump")


def stop_and_collect_tcp_dump_remote(file_dir):
    _core.stop_collectors("tcpdump_remote")
    _core.collect_collectors("tcpdump_remote", target_dir=file_dir)
    _core.teardown_collectors("tcpdump_remote")


def cb008225_activation():
    parameter = [
        {"parameterName": "actRrcInactState", "operation": "update", "value": "intra-gNB"},
    ]
    return parameter


def max_num_of_rrc_con_ues_per_du(maxnumperdu):
    parameter = [
        {"parameterName": "maxNumOfRrcConUEsPerDU", "operation": "update", "value": "{}".format(maxnumperdu)},
    ]
    return parameter


def max_num_of_rrc_sa(maxNumOfRrcSA):
    parameter = [
        {"parameterName": "maxNumOfRrcSA", "operation": "update", "value": "{}".format(maxNumOfRrcSA)},
    ]
    return parameter


def _file_reader(filename):
    with open(filename, 'rb') as f:
        for line in f:
            try:
                line = line.decode()
            except UnicodeDecodeError:
                continue
            yield line


def check_actRrcInactState_activation(path):
    pattern_1 = re.compile(r'.*?"nr-rrc.ranac": "0"')
    pattern_2 = re.compile(r'.*?"nr-rrc.useFullResumeID": "0"')
    msg_1, msg_2 = False, False,
    for line in _file_reader(path):
        if pattern_1.match(line):
            msg_1 = True
            blog(pattern_1.match(line).group(0))
        if pattern_2.match(line):
            msg_2 = True
            blog(pattern_2.match(line).group(0))
        if all([msg_1, msg_2]):
            return True
    raise ValueError('No message found in log. Message status: msg_1={}, msg_2={}'.format(msg_1, msg_2))


def check_pcap_packets(log_path, test_name, *args):
    ute_tshark.setup_tshark(interface='any', alias='pcap')
    for arg in args:
        value = ute_tshark.get_packets_count(packet_filter=arg,
                                             pcap_file_path="{}/{}".format(log_path, test_name),
                                             alias='pcap')
        builtin.should_be_equal_as_integers(value, 1)
    ute_tshark.teardown_tshark(alias='pcap')


def check_if_counters_increased(final_cts, cell_id, expected_value=1, increment=0):
    """Method verifies that particular pm counters increased by 1 for the chosen cell"""
    if int(expected_value) == 0:
        for counter_id in final_cts:
            assert counter_id not in final_cts or int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"
    if int(increment) == 1:
        for counter_id in final_cts:
            assert counter_id not in final_cts or int(final_cts[counter_id][str(cell_id)]) > int(expected_value), \
                counter_id + "counter did not increment"
    else:
        for counter_id in final_cts:
            assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"


def verify_sleeping_cell_by_rrcresumerequestreject_pcap():
    filter_list = L_PMO29_pcap_msgs
    source_filepath = "{}/{}/tcpdump/L_PMO6".format(builtin.get_variable_value("${LOG_PATH}"),
                                                    builtin.get_variable_value("${TESTNAME}"))
    pcap_alias = "L_pcap"
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[0],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 1, "{} packets for filter: {} in {}-should be 1".format(packets, filter_list[0], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[1],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 1, "{} packets for filter: {} in {}-should be 1".format(packets, filter_list[1], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[2],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 1, "{} packets for filter: {} in {}-should be 1".format(packets, filter_list[2], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[3],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets > 10, "{} packets for filter: {} in {}-should exist".format(packets, filter_list[3], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[4],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets > 10, "{} packets for filter: {} in {}-should exist".format(packets, filter_list[4], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[5],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets > 10, "{} packets for filter: {} in {}-should exist".format(packets, filter_list[5], source_filepath)
    ute_tshark.teardown_tshark(alias=pcap_alias)


def verify_J_B05_pcap():
    filter_list = J_B05_pcap_msgs
    source_filepath = "{}/{}/tcpdump/J_B5".format(builtin.get_variable_value("${LOG_PATH}"),
                                                  builtin.get_variable_value("${TESTNAME}"))
    pcap_alias = "J_pcap"
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[0],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 1, "{} packets for filter: {} in {}-should be 1".format(packets, filter_list[0], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[1],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 2, "{} packets for filter: {} in {}-should be 1".format(packets, filter_list[1], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[2],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 1, "{} packets for filter: {} in {}-should be 1".format(packets, filter_list[2], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[3],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 2, "{} packets for filter: {} in {}-should exist".format(packets, filter_list[3], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[4],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 1, "{} packets for filter: {} in {}-should exist".format(packets, filter_list[4], source_filepath)


def get_rrcreject_fire_times(syslog_path):
    fires = []
    for line in _file_reader(syslog_path):
        if "Tracing outgoing: NrCuL3MsgId::nrRrcRrcReject" in line:
            fires.append(line.split(' ')[1].split('.')[0])
    return fires


def count_fires_for_rrcreject(syslog_path):
    return len(get_rrcreject_fire_times(syslog_path))


def convert_pdml(file_path):
    pcaptopdml.create_pcap_to_pdml_converter(name="pcap",
                                             file_path_pattern=file_path)
    pcaptopdml.convert("pcap")


def verify_pdml(filepath):
    gnb_id_pdml_string = r'gnb-id: 031a3c \[bit length 22, 2 LSB pad bits, 0000 0011  0001 1010  0011 11.. ' \
                         r'decimal value 50831\]'
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if sw_release in ['SBTS24R3', 'SBTS25R1', 'SBTS25R2', 'SBTS25R3']:
            initial_sequence = 'startRecordingSession.*'\
                               'stopRecordingSession.*'\
                               'rrcResumeRequest1.*'\
                               'rrcRelease.*'
        else:
            initial_sequence = 'rrcResumeRequest1.*' \
                               'rrcRelease.*' \
                               'startRecordingSession.*' \
                               'stopRecordingSession.*'
    msg_sequence = 'DuUeCtxReleaseData-r1.*'\
                   f'{gnb_id_pdml_string}\n{gnb_id_pdml_string}\n'\
                   r'gnb-cu-ue-f1ap-Id: \d+.*'\
                   r'gnb-du-ue-f1ap-Id: \d+.*'\
                   'ueCtxReleaseCmdSndTime.*'\
                   r'seconds: \d+\nseconds: \d+\nseconds: \d+\n'\
                   r'useconds: \d+\nuseconds: \d+\nuseconds: \d+\n'
    _pdml.check_msc(filepath, ['nr-rrc.rrcResumeRequest1_element', 'nr-rrc.rrcRelease_element',
                               'nsetapx.startRecordingSession_element',
                               'nsetapx.stopRecordingSession_element', 'nsetapx.DuUeCtxReleaseData_r1_element',
                               'nsetapx.gnb_id', "nsetapx.gnb_cu_ue_f1ap_Id", "nsetapx.gnb_du_ue_f1ap_Id",
                               "nsetapx.ueCtxReleaseCmdSndTime_element", "nsetapx.seconds", "nsetapx.useconds"],
                    initial_sequence + msg_sequence)


def verify_callflow_for_E_B3(filepath):
    _pdml.check_msc(filepath,
                    ['nr-rrc.measurementReport_element', 'nr-rrc.rrcReconfiguration_element',
                     'nr-rrc.rrcReconfigurationComplete_element', 'nr-rrc.rrcRelease_element',
                     'nr-rrc.rrcResumeRequest1_element', 'nr-rrc.resumeCause',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element', 'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element', 'nr-rrc.rrcResume_element',
                     'nr-rrc.rrcResumeComplete_element', 'nr-rrc.measurementReport_element',
                     'nr-rrc.rrcReconfiguration_element', 'nr-rrc.rrcReconfigurationComplete_element'
                     ],
                    'measurementReport.*'
                    'rrcReconfiguration.*'
                    'rrcReconfigurationComplete.*'
                    'rrcRelease.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mo-Data.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest.*'
                    'BearerContextModificationResponse.*'
                    'rrcResume.*'
                    'rrcResumeComplete.*'
                    'measurementReport.*'
                    'rrcReconfiguration.*'
                    'rrcReconfigurationComplete.*'
                    )


def verify_callflow_for_C_B1(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element', 'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element', 'f1ap.UEContextReleaseComplete_element',
                     'e1ap.DLDataNotification_element', 'f1ap.Paging_element',
                     'nr-rrc.rrcResumeRequest1_element', 'nr-rrc.resumeCause', 'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element', 'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element', 'nr-rrc.rrcResume_element',
                     'nr-rrc.rrcResumeComplete_element'
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'DLDataNotification.*'
                    'Paging.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mt-Access.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest.*'
                    'BearerContextModificationResponse.*'
                    'rrcResume.*'
                    'rrcResumeComplete.*'
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_D_B1(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element', 'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element', 'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element', 'nr-rrc.resumeCause', 'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element', 'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element', 'nr-rrc.rrcResume_element',
                     'nr-rrc.rrcResumeComplete_element'
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mo-Data.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest.*'
                    'BearerContextModificationResponse.*'
                    'rrcResume.*'
                    'rrcResumeComplete.*'
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_I_B5(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'nr-rrc.rrcSetup_element',
                     'nr-rrc.rrcSetupComplete_element',
                     'ngap.InitialUEMessage_element',
                     'ngap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseComplete_element',
                     'ngap.UEContextReleaseComplete_element',
                     'ngap.InitialContextSetupRequest_element',
                     'ngap.InitialContextSetupResponse_element',
                     'ngap.PDUSessionResourceSetupRequest_element',
                     'ngap.fiveQI',
                     'ngap.PDUSessionResourceSetupResponse_element',
                     'ngap.PDUSessionResourceModifyRequest_element',
                     'ngap.fiveQI',
                     'ngap.PDUSessionResourceModifyResponse_element'
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: emergency.*'
                    'rrcSetup.*'
                    'rrcSetupComplete.*'
                    'InitialUEMessage.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextReleaseCommand.*'
                    'BearerContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    'InitialContextSetupRequest.*'
                    'InitialContextSetupResponse.*'
                    'PDUSessionResourceSetupRequest\n'
                    r'fiveQI: 5.*'
                    'PDUSessionResourceSetupResponse.*'
                    'PDUSessionResourceModifyRequest.*'
                    r'fiveQI: 1.*'
                    'PDUSessionResourceModifyResponse.*'
                    )


def verify_callflow_for_step_1(filepath):
    _pdml.check_msc(filepath,
                    ['nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'e1ap.DLDataNotification_element',
                     'f1ap.Paging_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element',
                     'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'nr-rrc.rrcResume_element',
                     'nr-rrc.rrcResumeComplete_element',
                     'xnap.HandoverRequest_element',
                     'xnap.HandoverRequestAcknowledge_element',
                     'xnap.SNStatusTransfer_element',
                     'xnap.UEContextRelease_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseComplete_element',
                     'f1ap.UEContextReleaseComplete_element'
                     ],
                    'rrcResumeRequest1\n'
                    r'resumeCause: rna-Update.*'
                    'UEContextReleaseCommand.*'
                    'UEContextReleaseComplete.*'
                    'DLDataNotification.*'
                    'Paging.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mt-Access.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest.*'
                    'BearerContextModificationResponse.*'
                    'rrcResume.*'
                    'rrcResumeComplete.*'
                    'HandoverRequest.*'
                    'HandoverRequestAcknowledge.*'
                    'SNStatusTransfer.*'
                    'UEContextRelease.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextReleaseCommand.*'
                    'BearerContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_step_1_remote(filepath):
    _pdml.check_msc(filepath,
                    ['xnap.HandoverRequest_element',
                     'xnap.HandoverRequestAcknowledge_element',
                     'xnap.SNStatusTransfer_element',
                     'ngap.PathSwitchRequest_element',
                     'ngap.PathSwitchRequestAcknowledge_element',
                     'e1ap.BearerContextInactivityNotification_element',
                     'e1ap.BearerContextModificationRequest_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseComplete_element',
                     ],
                    'HandoverRequest.*'
                    'HandoverRequestAcknowledge.*'
                    'SNStatusTransfer.*'
                    'PathSwitchRequest.*'
                    'PathSwitchRequestAcknowledge.*'
                    'BearerContextInactivityNotification.*'
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_step_2(filepath):
    _pdml.check_msc(filepath,
                    ['ngap.HandoverRequest_element',
                     'ngap.HandoverRequestAcknowledge_element',
                     'ngap.DownlinkRANStatusTransfer_element',
                     'ngap.HandoverNotify_element',
                     'e1ap.BearerContextInactivityNotification_element',
                     'e1ap.BearerContextModificationRequest_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseComplete_element',
                     ],
                    'HandoverRequest.*'
                    'HandoverRequestAcknowledge.*'
                    'DownlinkRANStatusTransfer.*'
                    'HandoverNotify.*'
                    'BearerContextInactivityNotification.*'
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_step_2_remote(filepath):
    _pdml.check_msc(filepath,
                    ['nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element',
                     'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'nr-rrc.rrcResume_element',
                     'nr-rrc.rrcResumeComplete_element',
                     'ngap.HandoverRequired_element',
                     'ngap.HandoverCommand_element',
                     'ngap.UplinkRANStatusTransfer_element',
                     'ngap.UEContextReleaseCommand_element',
                     'ngap.radioNetwork',
                     'f1ap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseComplete_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'ngap.UEContextReleaseComplete_element'
                     ],
                    'rrcResumeRequest1\n'
                    r'resumeCause: rna-Update.*'
                    'UEContextReleaseCommand.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mo-Data.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest.*'
                    'BearerContextModificationResponse.*'
                    'rrcResume.*'
                    'rrcResumeComplete.*'
                    'HandoverRequired\n'
                    r'radioNetwork: handover-desirable-for-radio-reason.*'
                    'HandoverCommand.*'
                    'UplinkRANStatusTransfer.*'
                    'UEContextReleaseCommand\n'
                    r'radioNetwork: successful-handover.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextReleaseCommand.*'
                    'BearerContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_step_3(filepath):
    _pdml.check_msc(filepath,
                    ['nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element',
                     'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'nr-rrc.rrcResume_element',
                     'nr-rrc.rrcResumeComplete_element',
                     'nr-rrc.measurementReport_element',
                     'nr-rrc.eutra_PhysCellId',
                     'ngap.HandoverRequired_element',
                     'ngap.HandoverCommand_element',
                     'nr-rrc.mobilityFromNRCommand_element',
                     'ngap.UEContextReleaseCommand_element',
                     'ngap.radioNetwork'
                     ],
                    'rrcResumeRequest1\n'
                    r'resumeCause: rna-Update.*'
                    'UEContextReleaseCommand.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mo-Data.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest.*'
                    'BearerContextModificationResponse.*'
                    'rrcResume.*'
                    'rrcResumeComplete.*'
                    'measurementReport\n'
                    r'eutra-PhysCellId: 479.*'
                    'HandoverRequired.*'
                    'HandoverCommand.*'
                    'mobilityFromNRCommand.*'
                    'UEContextReleaseCommand\n'
                    r'radioNetwork: successful-handover.*'
                    )
