import json
import os
import re
import tarfile
import time

from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pdml import pdml
from taf.collectors.btslog import btslog
from taf.collectors.core import core
from taf.collectors.tcpdump import tcpdump
from taf.converters.pcaptopdml import pcaptopdml
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

_builtin = BuiltIn()
_core = core()
_btslog = btslog()
_pcaptopdml = pcaptopdml()
_pdml = pdml()
_ssh = ssh()
_admin = admin()

CB011041_AB2_MSG1 = r'.*?DBG/cp_ue/NrDrbContainer.cpp:\d+ PagingPriority for PagingStrategy:1 is ' \
                    r'PagingPriority: priolevel1'

CB011041_AB2_MSG2 = r'.*?DBG/cp_ue/CpUeTimerManager.cpp:\d+.*?ranPagingGuard Timer is started with ' \
                    r'15000 milliseconds'

CB011041_EBC_1_MSG1 = r'.*?Conditions to use paging repetitions are met. Starting tRanPagingRepGuardTimer'

CB011041_EBC_1_MSG2 = r'.*?ranPagingRepGuardTimer Timer is started with 20000 milliseconds'

CB011041_EBC_1_MSG3 = r'.*?Starting tRanPagingAttPeriodGuardTimer timer'

CB011041_EBC_1_MSG4 = r'.*?ranPagingAttPeriodGuardTimer Timer is started with 2560 milliseconds'

CB011041_EBC_1_MSG5 = r'.*?ranPagingAttPeriodGuardTimer Timer expired for UE with ueIdCu:\d+'

CB011041_EBC_1_MSG6 = r'.*?ranPagingRepGuardTimer Timer expired for UE with ueIdCu:\d+'

CB011041_EBC_1_MSG7 = r'.*?Timer tRanPagingRepGuardTimer expired. Finishing paging procedure'

rrcrelease_msg = re.compile(r"nr-rrc\.mcc_tree.?: {'Item 0': {'nr-rrc.MCC_MNC_Digit': '5'}, "
                            r"'Item 1': {'nr-rrc.MCC_MNC_Digit': '4'}, 'Item 2': {'nr-rrc.MCC_MNC_Digit': '0'}}, "
                            r"'per.sequence_of_length': '2', 'nr-rrc.mnc': '2', "
                            r"'nr-rrc.mnc_tree': {'Item 0': {'nr-rrc.MCC_MNC_Digit': '0'}, "
                            r"'Item 1': {'nr-rrc.MCC_MNC_Digit': '1'}}}, 'per.sequence_of_length': '1', "
                            r"'nr-rrc.ran_Area': '1', 'nr-rrc.ran_Area_tree': "
                            r"{'Item 0': {'nr-rrc.RAN_AreaConfig_element': {'per.optional_field_bit': '1', "
                            r"'nr-rrc.trackingAreaCode': '00:1b:ef', 'per.sequence_of_length': "
                            r"'1', 'nr-rrc.ran_AreaCodeList': '1', 'nr-rrc.ran_AreaCodeList_tree': "
                            r"{'Item 0': {'nr-rrc.RAN_AreaCode': '(?P<item0>\d)'")

rrcreleaseidle_msg = re.compile(r"{'name': 'RRCRelease', 'code': 1301, 'data': {'nr-rrc': "
                                r"{'nr-rrc.DL_DCCH_Message_element': {'per.choice_index': '0', 'nr-rrc.message': '0',"
                                r" 'nr-rrc.message_tree': {'per.choice_index': '2', 'nr-rrc.c1': '2', 'nr-rrc.c1_tree':"
                                r" {'nr-rrc.rrcRelease_element': {'nr-rrc.rrc_TransactionIdentifier': '\d',"
                                r" 'per.choice_index': '0', 'nr-rrc.criticalExtensions': '0',"
                                r" 'nr-rrc.criticalExtensions_tree': {'nr-rrc.rrcRelease_element':"
                                r" {'per.optional_field_bit': '0'}}}}}}}}")

rrcresumerequest1_msg = re.compile(r"RRCResumeRequest1.*nr-rrc\.rrcResumeRequest1_element.*nr-rrc.resumeCause':"
                                   r" '(?P<item0>\d)'")

rrcresume_msg = re.compile(r"RRCResume.*nr-rrc.*nr-rrc.rrcResume_element")

rrcresumecomplete_msg = re.compile(r"RRCResumeComplete.*nr-rrc.*nr-rrc.rrcResumeComplete_element")

rrcreject = re.compile(r"RRCReject.*nr-rrc\.rrcReject_element.*nr-rrc.waitTime': '(?P<item0>\d)'")


def collect_scf_before_test():
    blog("\nCollecting backup SCF...")
    with Admin5G() as admin_api:
        admin_api.get_current_scf_file(get_path(), 'backup_scf.xml')


def collect_bts_snapshot():
    blog("\nCollecting BTS Snapshot...")
    with Admin5G() as admin_api:
        admin_api.get_snapshot(target_file_name='{}/{}_snapshot.zip'.format(
            _builtin.get_variable_value('${LOG_PATH}'), _builtin.get_variable_value('${test_name}')
        ))


def create_syslog_collector(filename):
    executor = {"host": "10.44.149.100",
                "user": "ute",
                "password": "uteUTE!"}
    _btslog.create_btslog_collector(name="btslog", target_file_name=filename,
                                    executor=executor)
    _btslog.setup_collectors("btslog")


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def extract_file():
    file_path = get_path()
    with tarfile.open("{}/btslog/{}".format(file_path, "BtsLog.tgz", 'r')) as tar:
        tar.extractall(file_path + "/btslog/")


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


def start_tcp_dump():
    _core.start_collectors("tcpdump")
    tcpdump().set_global_alias("tcpdump")


def stop_and_collect_tcp_dump(file_dir):
    _core.stop_collectors("tcpdump")
    _core.collect_collectors("tcpdump", target_dir=file_dir)
    _core.teardown_collectors("tcpdump")


def validate_inactive_state(elt_log, ranac):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = [x for x in log if x['name'] == 'RRCRelease' and 'nr-rrc' in x['data']
            and 'nr-rrc.DL_DCCH_Message_element' in x['data']['nr-rrc']
            and 'nr-rrc.suspendConfig_element' in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']
            ['nr-rrc.message_tree']['nr-rrc.c1_tree']['nr-rrc.rrcRelease_element']
            ['nr-rrc.criticalExtensions_tree']['nr-rrc.rrcRelease_element']]
    matched = re.search(rrcrelease_msg, str(msgs[0]))
    assert matched, f"RRCRelease has unrecognizable structure, found RRCRelease: {msgs[0]}"
    assert matched.groups()[0] == ranac, f"Expected ranac value = " \
           f"{ranac}, instead got: {matched.groups()}"


def validate_inactive_state_for_ab3(elt_log, ranac1, ranac2):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = [x for x in log if x['name'] == 'RRCRelease' and 'nr-rrc' in x['data']
            and 'nr-rrc.DL_DCCH_Message_element' in x['data']['nr-rrc']
            and 'nr-rrc.suspendConfig_element' in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']
            ['nr-rrc.message_tree']['nr-rrc.c1_tree']['nr-rrc.rrcRelease_element']
            ['nr-rrc.criticalExtensions_tree']['nr-rrc.rrcRelease_element']]
    matched_1 = re.search(rrcrelease_msg, str(msgs[0]))
    matched_2 = re.search(rrcrelease_msg, str(msgs[1]))
    assert matched_1, f"RRCRelease has unrecognizable structure, found RRCRelease: {msgs[0]}"
    assert matched_1.groups()[0] == ranac1, f"Expected ranac value = " \
           f"{ranac1}, instead got: {matched_1.groups()}"
    assert matched_2, f"RRCRelease has unrecognizable structure, found RRCRelease: {msgs[1]}"
    assert matched_2.groups()[0] == ranac2, f"Expected ranac value = " \
           f"{ranac2}, instead got: {matched_2.groups()}"


def validate_idle_state(elt_log):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = [x for x in log if x['name'] == 'RRCRelease' and 'nr-rrc' in x['data']
            and 'nr-rrc.DL_DCCH_Message_element' in x['data']['nr-rrc']
            and 'nr-rrc.suspendConfig_element' not in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']]
    matched = re.search(rrcreleaseidle_msg, str(msgs[0]))
    assert matched, f"RRCRelease has unrecognizable structure, found RRCRelease: {msgs[0]}"


def validate_rrcresumerequest1(elt_log, cause):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = [x for x in log if x['name'] == 'RRCResumeRequest1' and 'nr-rrc' in x['data']
            and 'nr-rrc.UL_CCCH1_Message_element' in x['data']['nr-rrc']
            and 'nr-rrc.resumeCause' in x['data']['nr-rrc']['nr-rrc.UL_CCCH1_Message_element']
            ['nr-rrc.message_tree']['nr-rrc.c1_tree']['nr-rrc.rrcResumeRequest1_element']
            ['nr-rrc.rrcResumeRequest1_element']]
    matched = re.search(rrcresumerequest1_msg, str(msgs[0]))
    assert matched, f"RRCResumeRequest1 has unrecognizable structure, found RRCRelease: {msgs[0]}"
    assert matched.groups()[0] == cause, f"Expected ranac value = " \
           f"{cause}, instead got: {matched.groups()}"


def validate_rrcresume(elt_log,):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msg1 = [x for x in log if x['name'] == 'RRCResume' and 'nr-rrc' in x['data']
            and 'nr-rrc.DL_DCCH_Message_element' in x['data']['nr-rrc']
            and 'nr-rrc.rrcResume_element' in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']
            ['nr-rrc.message_tree']['nr-rrc.c1_tree']]
    msg2 = [x for x in log if x['name'] == 'RRCResumeComplete' and 'nr-rrc' in x['data']
            and 'nr-rrc.UL_DCCH_Message_element' in x['data']['nr-rrc']
            and 'nr-rrc.rrcResumeComplete_element' in x['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']
            ['nr-rrc.message_tree']['nr-rrc.c1_tree']]
    matched_1 = re.search(rrcresume_msg, str(msg1[0]))
    matched_2 = re.search(rrcresumecomplete_msg, str(msg2[0]))
    assert matched_1, f"RRCResume has unrecognizable structure, found RRCResume: {msg1[0]}"
    assert matched_2, f"RRCResumeComplete has unrecognizable structure, found RRCResumeComplete: {msg2[0]}"


def validate_rrcresumerequest1_ul_with_reject(elt_log, cause):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msg1 = [x for x in log if x['name'] == 'RRCResumeRequest1' and 'nr-rrc' in x['data']
            and 'nr-rrc.UL_CCCH1_Message_element' in x['data']['nr-rrc']
            and 'nr-rrc.resumeCause' in x['data']['nr-rrc']['nr-rrc.UL_CCCH1_Message_element']
            ['nr-rrc.message_tree']['nr-rrc.c1_tree']['nr-rrc.rrcResumeRequest1_element']
            ['nr-rrc.rrcResumeRequest1_element']]
    msg2 = [x for x in log if x['name'] == 'RRCReject' and 'nr-rrc' in x['data']]
    matched_1 = re.search(rrcresumerequest1_msg, str(msg1[0]))
    matched_2 = re.search(rrcreject, str(msg2[0]))
    assert matched_1, f"RRCResumeRequest1 has unrecognizable structure, found RRCRelease: {msg1[0]}"
    assert matched_1.groups()[0] == cause, f"Expected ranac value = " \
           f"{cause}, instead got: {matched_1.groups()}"
    assert matched_2, f"RRCReject has unrecognizable structure, found RRCRelease: {msg2[0]}"
    assert matched_2.groups()[0] == '8', f"Expected wait time = 8s, instead got: {matched_2.groups()}"


def convert_pdml(file_path):
    _pcaptopdml.create_pcap_to_pdml_converter(name="pcap", file_path_pattern=file_path)
    _pcaptopdml.convert("pcap")


def verify_callflow_for_ab1(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_pmo_a2(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextStatusChange',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element',
                     'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'e1ap.DLDataNotification_element',
                     ],
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: suspend.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mo-Data.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: resume.*'
                    'BearerContextModificationResponse.*'
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: suspend.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'DLDataNotification.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mt-Access.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: resume.*'
                    'BearerContextModificationResponse.*'
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: suspend.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_aec1(filepath):
    _pdml.check_msc(filepath,
                    ['ngap.UEContextReleaseRequest_element',
                     'ngap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseCommand_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseComplete_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'ngap.UEContextReleaseComplete_element',
                     ],
                    'UEContextReleaseRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextReleaseCommand.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_aec2(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'nr-rrc.rrcReject_element',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mo-Data.*'
                    'UEContextReleaseCommand.*'
                    'rrcReject.*'
                    )


def verify_callflow_for_pmo_a3(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest_element',
                     'nr-rrc.resumeCause',
                     'nr-rrc.rrcSetup_element',
                     'nr-rrc.rrcSetupComplete_element',
                     'ngap.InitialUEMessage_element',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest\n'
                    r'resumeCause: rna-Update.*'
                    'rrcSetup.*'
                    'rrcSetupComplete.*'
                    'InitialUEMessage.*'
                    )


def verify_callflow_for_ab3(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextStatusChange',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'e1ap.DLDataNotification_element',
                     'f1ap.Paging_element',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
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
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: resume.*'
                    'BearerContextModificationResponse.*'
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: suspend.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_biwk4(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: rna-Update.*'
                    'UEContextReleaseCommand.*'
                    'UEContextReleaseComplete'
                    )


def verify_callflow_for_cb011041_ab2(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextStatusChange',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'ngap.PDUSessionResourceModifyRequest_element',
                     'ngap.fiveQI',
                     'f1ap.Paging_element',
                     'f1ap.PagingPriority',
                     'nr-rrc.rrcResumeRequest1_element',
                     'nr-rrc.resumeCause',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'PDUSessionResourceModifyRequest\n'
                    r'fiveQI: 8.*'
                    'Paging\n'
                    r'PagingPriority: priolevel1.*'
                    'rrcResumeRequest1\n'
                    r'resumeCause: mt-Access.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'BearerContextModificationRequest\n'
                    r'BearerContextStatusChange: resume.*'
                    )


def verify_callflow_for_bec1(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'f1ap.Paging_element',
                     'ngap.UEContextReleaseRequest_element',
                     'ngap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseComplete_element',
                     'ngap.UEContextReleaseComplete_element',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'Paging.*'
                    'Paging.*'
                    'Paging.*'
                    'Paging.*'
                    'Paging.*'
                    'Paging.*'
                    'UEContextReleaseRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextReleaseCommand.*'
                    'BearerContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    )


def verify_callflow_for_pmo_b3(filepath):
    _pdml.check_msc(filepath,
                    ['e1ap.BearerContextModificationRequest_element',
                     'e1ap.BearerContextModificationResponse_element',
                     'f1ap.UEContextReleaseCommand_element',
                     'f1ap.UEContextReleaseComplete_element',
                     'nr-rrc.rrcResumeRequest_element',
                     'nr-rrc.resumeCause',
                     'nr-rrc.rrcSetup_element',
                     'nr-rrc.rrcSetupComplete_element',
                     'ngap.InitialUEMessage_element',
                     'ngap.UEContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseCommand_element',
                     'e1ap.BearerContextReleaseComplete_element',
                     'ngap.UEContextReleaseComplete_element',
                     'ngap.InitialContextSetupRequest_element',
                     'f1ap.UEContextSetupRequest_element',
                     'f1ap.UEContextSetupResponse_element',
                     'ngap.InitialContextSetupResponse_element',
                     ],
                    'BearerContextModificationRequest.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextModificationResponse.*'
                    'UEContextReleaseComplete.*'
                    'rrcResumeRequest\n'
                    r'resumeCause: rna-Update.*'
                    'rrcSetup.*'
                    'rrcSetupComplete.*'
                    'InitialUEMessage.*'
                    'UEContextReleaseCommand.*'
                    'BearerContextReleaseCommand.*'
                    'BearerContextReleaseComplete.*'
                    'UEContextReleaseComplete.*'
                    'InitialContextSetupRequest.*'
                    'UEContextSetupRequest.*'
                    'UEContextSetupResponse.*'
                    'InitialContextSetupResponse.*'
                    )


def check_if_counters_increased(final_cts, cell_id, expected_value=1, morethanzero=None):
    """Method verifies that particular pm counters increased by 1 for the chosen cell"""
    if int(expected_value) == 0:
        for counter_id in final_cts:
            assert counter_id not in final_cts or int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"
    elif morethanzero is not None:
        for counter_id in final_cts:
            assert int(final_cts[counter_id][str(cell_id)]) > 0, \
                counter_id + "wrong counter value"
    else:
        for counter_id in final_cts:
            assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"


def start_ul_data_transfer():
    try:
        _ssh.connect_to(hostname="10.45.168.53", username='5g', password='2019H@slo')
        _ssh.send_command(command='iperf3 -s -i 1 -p 9099')
        time.sleep(3)
        _ssh.connect_to(hostname="10.42.22.156", username='wro5grrm', password='5gpass!1')
        time.sleep(3)
        _ssh.send_command(command='adb shell iperf3 -c 10.45.168.53 -u -p 9099 -i 1 -b 200M -l 1400 -t 20')
        _ssh.read_output()
        time.sleep(10)
    finally:
        _ssh.disconnect()
    blog("Data transfer finished")


def start_dl_data_transfer():
    ue_ip = _builtin.get_variable_value("${ip}")
    dl_command = 'iperf3 -c {} -u -p 6092 -i 1 -b 300M -l 1400 -t 30'.format(ue_ip)
    try:
        _ssh.connect_to(hostname="10.42.22.156", username='wro5grrm', password='5gpass!1')
        _ssh.send_command(command='adb shell iperf3 -s -i 1 -p 6092 -1')
        time.sleep(3)
        _ssh.connect_to(hostname='10.45.168.53', username='5g', password='2019H@slo')
        _ssh.send_command(command=dl_command)
        time.sleep(3)
        _ssh.read_output()
        time.sleep(10)
    finally:
        _ssh.disconnect()
    blog("Data transfer finished")


def reboot_redcap_ue():
    try:
        _ssh.connect_to(hostname="10.42.22.156", username='wro5grrm', password='5gpass!1')
        _ssh.send_command(command='adb reboot')
        time.sleep(60)
    finally:
        _ssh.disconnect()
    blog("Ue reboot done")


def set_maxNumOfRrcSARedCap(maxNumOfRrcSARedCap):
    with Admin5G() as admin_api:
        admin_api.perform_parameter_recommissioning("MRBTS-50822/NRBTS-50822/NRCELL-221",
                                                    parameter="maxNumOfRrcSARedCap",
                                                    operation="update", value=maxNumOfRrcSARedCap,
                                                    skip_parameter_relation_errors=False,
                                                    should_activate=True, timeout=300)


def set_biwk2_parameters_setup():
    try:
        _admin.setup_admin()
        _admin.create_delta()
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "activityNotificationLevelSA", "drb")
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "drbRrcInactInactivityTimerSARedCap", 15)
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822/NRDRB-14", "drbRrcInactInactivityTimerSA", 60)
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822/SNSSAI-1", "drbRrcInactInactivityTimerSA", 70)
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "srbInactivityTimerSARedCap", 10)
        _admin.perform_delta_recommissioning(delta_file=_admin.get_delta())
    finally:
        _admin.teardown_admin()


def set_biwk2_parameters_teardown():
    try:
        _admin.setup_admin()
        _admin.create_delta()
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "activityNotificationLevelSA", "ue")
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "drbRrcInactInactivityTimerSARedCap", 5)
        _admin.append_parameter_delete_to_delta("MRBTS-50822/NRBTS-50822/NRDRB-14", "drbRrcInactInactivityTimerSA")
        _admin.append_parameter_delete_to_delta("MRBTS-50822/NRBTS-50822/SNSSAI-1", "drbRrcInactInactivityTimerSA")
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "srbInactivityTimerSARedCap", 30)
        _admin.perform_delta_recommissioning(delta_file=_admin.get_delta())
    finally:
        _admin.teardown_admin()


def set_ranac(operation, ranAC):
    with Admin5G() as admin_api:
        admin_api.perform_parameter_recommissioning("MRBTS-50822/NRBTS-50822/NRCELL-222/NRPLMNSET_SA-1",
                                                    parameter="ranAC",
                                                    operation=operation, value=ranAC,
                                                    skip_parameter_relation_errors=False,
                                                    should_activate=True, timeout=300)


def set_IdleMMSteering(actIdleMMSteering, rrcInactIMMSteeringEnabled):
    try:
        _admin.setup_admin()
        _admin.create_delta()
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "actIdleMMSteering", actIdleMMSteering)
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "rrcInactIMMSteeringEnabled",
                                                rrcInactIMMSteeringEnabled)
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "t380", "5min")
        _admin.perform_delta_recommissioning(delta_file=_admin.get_delta())
    finally:
        _admin.teardown_admin()


def set_actPagingEnh(actPagingEnh, t380, pagingRepMaxNum=None, ranPagingRepGuardTimer=None, bec1=False):
    try:
        _admin.setup_admin()
        _admin.create_delta()
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "actPagingEnh", actPagingEnh)
        _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822", "t380", t380)
        if bec1:
            _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822/NRPAGING_STRAT_RRCINACT-1",
                                                    "pagingRepMaxNum", pagingRepMaxNum)
            _admin.append_parameter_update_to_delta("MRBTS-50822/NRBTS-50822/NRPAGING_STRAT_RRCINACT-1",
                                                    "ranPagingRepGuardTimer", ranPagingRepGuardTimer)
        else:
            _admin.append_parameter_delete_to_delta("MRBTS-50822/NRBTS-50822/NRPAGING_STRAT_RRCINACT-1",
                                                    "pagingRepMaxNum")
            _admin.append_parameter_delete_to_delta("MRBTS-50822/NRBTS-50822/NRPAGING_STRAT_RRCINACT-1",
                                                    "ranPagingRepGuardTimer")
        _admin.perform_delta_recommissioning(delta_file=_admin.get_delta())
    finally:
        _admin.teardown_admin()


def confirm_cb011041_ab2(syslog_path):
    pattern_1 = re.compile(CB011041_AB2_MSG1, re.IGNORECASE)
    pattern_2 = re.compile(CB011041_AB2_MSG2, re.IGNORECASE)
    msg_1 = msg_2 = False
    for line in file_reader(syslog_path):
        if pattern_1.match(line):
            msg_1 = True
        if pattern_2.match(line):
            msg_2 = True
        print([msg_1, msg_2])
        if all([msg_1, msg_2]):
            return True
    raise ValueError(f"Checking failed. Messages status: msg_1={msg_1}, msg_2={msg_2}")


def confirm_cb011041_bec1(syslog_path):
    pattern_1 = re.compile(CB011041_EBC_1_MSG1, re.IGNORECASE)
    pattern_2 = re.compile(CB011041_EBC_1_MSG2, re.IGNORECASE)
    pattern_3 = re.compile(CB011041_EBC_1_MSG3, re.IGNORECASE)
    pattern_4 = re.compile(CB011041_EBC_1_MSG4, re.IGNORECASE)
    pattern_5 = re.compile(CB011041_EBC_1_MSG5, re.IGNORECASE)
    pattern_6 = re.compile(CB011041_EBC_1_MSG6, re.IGNORECASE)
    pattern_7 = re.compile(CB011041_EBC_1_MSG7, re.IGNORECASE)
    msg_1 = msg_2 = msg_3 = msg_4 = msg_5 = msg_6 = msg_7 = False
    for line in file_reader(syslog_path):
        if pattern_1.match(line):
            msg_1 = True
        if pattern_2.match(line):
            msg_2 = True
        if pattern_3.match(line):
            msg_3 = True
        if pattern_4.match(line):
            msg_4 = True
        if pattern_5.match(line):
            msg_5 = True
        if pattern_6.match(line):
            msg_6 = True
        if pattern_7.match(line):
            msg_7 = True
        if all([msg_1, msg_2, msg_3, msg_4, msg_5, msg_6, msg_7]):
            return True
    raise ValueError(f"Checking failed. Messages status: msg_1={msg_1}, msg_2={msg_2}, msg_3={msg_3}, msg_4={msg_4}"
                     f", msg_5={msg_5}, msg_6={msg_6}, msg_7={msg_7}")
