import json
import os
import re
import tarfile

from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pdml import pdml
from taf.collectors.btslog import btslog
from taf.collectors.core import core
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

initial_parameters_1 = [
    {"parameterName": "actCDrx", "operation": "update", "value": "true"},
    {"parameterName": "drxProfileNrAnr", "operation": "update", "value":
        [{"drxControl": "intraNRNSAinterFreq",
          "nrDrxDN": "MRBTS-50831/NRBTS-50831/NRDRX-4"},
         {"drxControl": "any",
          "nrDrxDN": "MRBTS-50831/NRBTS-50831/NRDRX-4"}],
     }
]


initial_parameters_2 = [
    {"parameterName": "a3MeasSsbRsrp", "operation": "update", "value":
     [{"a3HysteresisSsbRsrp": 0,
       "a3OffsetSsbRsrp": 3,
       "a3TimeToTriggerSsbRsrp": "ms320"}]
     }
]


meas_report = re.compile(r"{'name': 'MeasurementReport', 'code': 1302, 'data': {'nr-rrc': "
                         r"{'nr-rrc.UL_DCCH_Message_element': {'per.choice_index': '0', 'nr-rrc.message': '0',"
                         r" 'nr-rrc.message_tree': {'per.choice_index': '0', 'nr-rrc.c1': '0', 'nr-rrc.c1_tree': "
                         r"{'nr-rrc.measurementReport_element': {'per.choice_index': '0', 'nr-rrc.criticalExtensions': "
                         r"'0', 'nr-rrc.criticalExtensions_tree': {'nr-rrc.measurementReport_element': "
                         r"{'per.optional_field_bit': '0', 'nr-rrc.measResults_element': {'per.extension_bit': '0', "
                         r"'per.optional_field_bit': '0', 'nr-rrc.measId': '6', 'per.sequence_of_length': '1', "
                         r"'nr-rrc.measResultServingMOList': '1', 'nr-rrc.measResultServingMOList_tree': {'Item 0': "
                         r"{'nr-rrc.MeasResultServMO_element': {'per.extension_bit': '0', 'per.optional_field_bit': "
                         r"'0', 'nr-rrc.servCellId': '8', 'nr-rrc.measResultServingCell_element': "
                         r"{'per.extension_bit': '0', 'per.optional_field_bit': '1', 'nr-rrc.physCellId': '50', "
                         r"'nr-rrc.measResult_element': {'per.optional_field_bit': '0', 'nr-rrc.cellResults_element': ")
A2_Measurement = r'.*?DBG/cp_ue/MeasurementReportHandlerServiceNsa.cpp:\d+ MeasId: \d+ ' \
                 r'and MeasurementType: A2ActiveInterFreq.'
A3_Measurement = r'.*?DBG/cp_ue/MeasurementReportHandlerServiceNsa.cpp:\d+ MeasId: \d+ ' \
                 r'and MeasurementType: InterFreqA3.'
MSG_1 = r'.*?NrcgiOrEutracgiReport Timer expired for UE with ueIdCu'
MSG_2 = r'.*?NeighbourStatusUpdate with CgiMeasFailure will not be send to cpcl, because NrCgi not found'
MSG_3 = r'.*?PCI Resolution Failure - NRCGI report timeout!'


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def collect_scf_before_test():
    blog("Collecting backup SCF...")
    with Admin5G() as admin_api:
        admin_api.get_current_scf_file(get_path(), 'backup_scf.xml')


def collect_bts_snapshot():
    blog("Collecting BTS Snapshot...")
    with Admin5G() as admin_api:
        admin_api.get_snapshot(target_file_name=f"{_builtin.get_variable_value('${LOG_PATH}')}/"
                                                f"{_builtin.get_variable_value('${test_name}')}_snapshot.zip")


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


def extract_file():
    file_path = get_path()
    with tarfile.open(f"{file_path}/btslog/{'BtsLog.tgz'}", 'r') as tar:
        tar.extractall(f"{file_path}" + "/btslog/")


def set_initial_parameters():
    blog("Setting initial parameters...")
    parameters_1 = initial_parameters_1
    parameters_2 = initial_parameters_2
    try:
        _admin.setup_admin()
        _admin.perform_object_recommissioning(dist_name='MRBTS-50831/NRBTS-50831/NRCELL-1',
                                              parameter=parameters_1,
                                              operation='update',
                                              skip_parameter_relation_errors=False)
        _admin.perform_object_recommissioning(dist_name='MRBTS-50831/NRBTS-50831/NRCELL-1/NRHOIF-1',
                                              parameter=parameters_2,
                                              operation='update',
                                              skip_parameter_relation_errors=False)
    finally:
        _admin.teardown_admin()


def check_syslog(syslog_path):
    pattern_1 = re.compile(A2_Measurement, re.IGNORECASE)
    pattern_2 = re.compile(A3_Measurement, re.IGNORECASE)
    pattern_3 = re.compile(MSG_1, re.IGNORECASE)
    pattern_4 = re.compile(MSG_2, re.IGNORECASE)
    pattern_5 = re.compile(MSG_3, re.IGNORECASE)
    msg_1 = msg_2 = msg_3 = msg_4 = msg_5 = False
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
        if all([msg_1, msg_2, msg_3, msg_4, msg_5]):
            return True
    raise ValueError(f"Check procedure failed. Messages status: msg_1={msg_1}, msg_2={msg_2}, msg_3={msg_3}, "
                     f"msg_4={msg_4}, 'msg_5={msg_5}")


def validate_pci_res_failure(elt_log):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = [x for x in log if x['name'] == 'MeasurementReport' and 'nr-rrc' in x['data']
            and 'nr-rrc.UL_DCCH_Message_element' in x['data']['nr-rrc']
            and '6' in x['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']['nr-rrc.message_tree']['nr-rrc.c1_tree']
            ['nr-rrc.measurementReport_element']['nr-rrc.criticalExtensions_tree']['nr-rrc.measurementReport_element']
            ['nr-rrc.measResults_element']['nr-rrc.measId']
            and '50' in x['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']['nr-rrc.message_tree']['nr-rrc.c1_tree']
            ['nr-rrc.measurementReport_element']['nr-rrc.criticalExtensions_tree']['nr-rrc.measurementReport_element']
            ['nr-rrc.measResults_element']['nr-rrc.measResultServingMOList_tree']['Item 0']
            ['nr-rrc.MeasResultServMO_element']['nr-rrc.measResultServingCell_element']['nr-rrc.physCellId']
            and 'nr-rrc.measResultNeighCells' not in x['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']
            ['nr-rrc.message_tree']['nr-rrc.c1_tree']['nr-rrc.measurementReport_element']
            ['nr-rrc.criticalExtensions_tree']['nr-rrc.measurementReport_element']
            ['nr-rrc.measResults_element']]
    matched = re.search(meas_report, str(msgs[0]))
    assert matched, f"RRCRelease has unrecognizable structure, found RRCRelease: {msgs[0]}"
