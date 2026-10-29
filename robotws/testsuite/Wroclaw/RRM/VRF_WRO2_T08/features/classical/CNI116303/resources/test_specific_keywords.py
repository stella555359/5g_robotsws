import os
import tarfile

from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pdml import pdml
from taf.collectors.btslog import btslog
from taf.collectors.core import core
from taf.collectors.tcpdump import tcpdump
from taf.converters.pcaptopdml import pcaptopdml
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G

_builtin = BuiltIn()
_core = core()
_btslog = btslog()
_pcaptopdml = pcaptopdml()
_pdml = pdml()
_ssh = ssh()
_admin = admin()
ute_tshark = ute_tshark()


interfreq_HO_B1 = [
    "ngap.NGAP_PDU == 0 and ngap.procedureCode == 14 and ngap.fiveQI == 9",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.drx_Config == 1 and nr-rrc.drx_LongCycleStartOffset == 9",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.physCellId == 998 and not nr-rrc.measResultNeighCells == 0 "
    "and nr-rrc.measId == 1",
    "f1ap.procedureCode == 7 and nr-rrc.drx_Config == 0 and nr-rrc.gapUE == 1",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.drx_Config == 0",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.measId == 5",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.drx_Config == 1 and nr-rrc.drx_LongCycleStartOffset == 13",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.measResultNeighCells == 0 and "
    "nr-rrc.plmn_IdentityInfoList == 1",
    "ngap.procedureCode == 48 and ngap.TransportLayerAddressIPv4 == 10.44.224.88",
    "ip.src == 10.44.225.88 and ip.dst == 10.27.28.136 and ngap.procedureCode == 12 and ngap.radioNetwork == 16",
    "ip.src == 10.27.28.136 and ip.dst == 10.44.225.88 and ngap.procedureCode == 12 and ngap.HandoverType == 0",
    "ngap.procedureCode == 6 and ngap.TransportLayerAddressIPv4 == 10.44.224.106",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 0",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 1",
    "ngap.procedureCode == 41 and ngap.radioNetwork == 2"
]


interfreq_HO_B2 = [
    "ngap.NGAP_PDU == 0 and ngap.procedureCode == 14 and ngap.fiveQI == 9",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.drx_Config == 1 and nr-rrc.drx_LongCycleStartOffset == 9",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.physCellId == 998 and not nr-rrc.measResultNeighCells == 0 "
    "and nr-rrc.measId == 1",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.measId == 4 and nr-rrc.measId == 5 and "
    "nr-rrc.measId == 6 and nr-rrc.gapUE == 1 and nr-rrc.drx_Config == 0",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.measId == 5 and nr-rrc.measResultNeighCells == 0 "
    "and nr-rrc.physCellId == 999",
    "f1ap.procedureCode == 12 and nr-rrc.measIdToRemoveList == 2 and nr-rrc.gapUE == 0",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.reportType == 2 and nr-rrc.cellForWhichToReportCGI == 999 "
    "and nr-rrc.drx_Config == 1",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.measResultNeighCells == 0 "
    "and nr-rrc.plmn_IdentityInfoList == 1",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.reportConfigToAddModList == 1 and nr-rrc.eventId == 1",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 0",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 1",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.physCellId == 998 and nr-rrc.physCellId == 999 "
    "and nr-rrc.measId == 10",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 0 and xnap.radioNetwork == 1",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 0",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 1",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 6"
]


interfreq_HO_B2_alt1 = [
    "ngap.NGAP_PDU == 0 and ngap.procedureCode == 14 and ngap.fiveQI == 9",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.drx_Config == 1 and nr-rrc.drx_LongCycleStartOffset == 9",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.physCellId == 998 and not nr-rrc.measResultNeighCells == 0 "
    "and nr-rrc.measId == 1",
    "f1ap.procedureCode == 12 and nr-rrc.c1 == 0 and nr-rrc.measId == 4 and nr-rrc.measId == 5 and "
    "nr-rrc.measId == 6 and nr-rrc.gapUE == 1 and nr-rrc.drx_Config == 0",
    "f1ap.procedureCode == 13 and nr-rrc.c1 == 0 and nr-rrc.measId == 5 and nr-rrc.measResultNeighCells == 0 "
    "and nr-rrc.physCellId == 999",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 0",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 1",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 0 and xnap.radioNetwork == 1",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 0",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 1",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 6"
]


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def collect_scf_before_test():
    blog("Collecting backup SCF...")
    with Admin5G() as admin_api:
        admin_api.get_current_scf_file(get_path(), 'backup_scf.xml', timeout=60)


def collect_bts_snapshot():
    blog("Collecting BTS Snapshot...")
    with Admin5G() as admin_api:
        admin_api.get_snapshot(f"{_builtin.get_variable_value('${LOG_PATH}')}/"
                               f"{_builtin.get_variable_value('${test_name}')}_snapshot.zip")


def create_syslog_collector(filename):
    executor = {"host": "10.44.178.80",
                "user": "ute",
                "password": "uteUTE!"}
    _btslog.create_btslog_collector(name="btslog", target_file_name=filename,
                                    executor=executor)
    _btslog.setup_collectors("btslog")


def extract_file():
    file_path = get_path()
    with tarfile.open(f"{file_path}/btslog/BtsLog.tgz", 'r') as tar:
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
    executor = {"host": "192.168.255.129",
                "user": "toor4nsn",
                "password": "oZPS0POrRieRtu"}
    tcpdump().create_tcpdump_collector(name="tcpdump", target_file_name=pcap_file, options="sctp -i any -p",
                                       executor=executor)
    _core.setup_collectors("tcpdump")


def start_tcp_dump():
    _core.start_collectors("tcpdump")
    tcpdump().set_global_alias("tcpdump")


def stop_and_collect_tcp_dump(file_dir):
    _core.stop_collectors("tcpdump")
    _core.collect_collectors("tcpdump", target_dir=file_dir)
    _core.teardown_collectors("tcpdump")


def get_params_for_nradjnrcell_object():
    parameter = [
        {"parameterName": "cellDepType", "operation": "update", "value": "SA+NSA"},
        {"parameterName": "cellReservedForOperatorUse", "operation": "update", "value": "notReserved"},
        {"parameterName": "fiveGsTac", "operation": "update", "value": "7152"},
        {"parameterName": "freqBandIndicatorNR", "operation": "update", "value": "66"},
        {"parameterName": "gNbId", "operation": "update", "value": "50848"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "24"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]},
        {"parameterName": "lcrId", "operation": "update", "value": "1"},
        {"parameterName": "nrarfcn", "operation": "update", "value": "434000"},
        {"parameterName": "physCellId", "operation": "update", "value": "999"},
        {"parameterName": "ssbFrequency", "operation": "update", "value": "433970"},
    ]
    return parameter


def get_params_for_nrrel_object():
    parameter = [
        {"parameterName": "cellIndividualSsbRsrpOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "cellIndividualSsbRsrqOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "gNbId", "operation": "update", "value": "50848"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "24"},
        {"parameterName": "lcrId", "operation": "update", "value": "1"},
        {"parameterName": "removeNotAllowed", "operation": "update", "value": "false"},
        {"parameterName": "handoverAllowedSA", "operation": "update", "value": "allowed"},
        {"parameterName": "handoverAllowedSARedCap", "operation": "update", "value": "forbidden"},
        {"parameterName": "isRplCellForPSCell", "operation": "update", "value": "false"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]},
        {"parameterName": "nrDcAllowed", "operation": "update", "value": "false"}
    ]
    return parameter


def verify_b1_pcap():
    filter_list = interfreq_HO_B1
    source_filepath = f"{_builtin.get_variable_value('${LOG_PATH}')}/" \
                      f"{_builtin.get_variable_value('${TESTNAME}')}/tcpdump/B_1"
    pcap_alias = "b1_pcap"
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    for packet in filter_list:
        packets = ute_tshark.get_packets_count(packet_filter=packet,
                                               pcap_file_path=source_filepath,
                                               alias=pcap_alias)
        assert packets == 1, f"{packets} packets for filter: {filter_list} in {source_filepath}-should be 1"
    ute_tshark.teardown_tshark(alias=pcap_alias)


def verify_b2_pcap():
    filter_list = interfreq_HO_B2
    source_filepath = f"{_builtin.get_variable_value('${LOG_PATH}')}/" \
                      f"{_builtin.get_variable_value('${TESTNAME}')}/tcpdump/B_2"
    pcap_alias = "b2_pcap"
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    for packet in filter_list:
        packets = ute_tshark.get_packets_count(packet_filter=packet,
                                               pcap_file_path=source_filepath,
                                               alias=pcap_alias)
        assert packets == 1, f"{packets} packets for filter: {filter_list} in {source_filepath}-should be 1"
    ute_tshark.teardown_tshark(alias=pcap_alias)


def verify_b2_alt1_pcap():
    filter_list = interfreq_HO_B2_alt1
    source_filepath = f"{_builtin.get_variable_value('${LOG_PATH}')}/" \
                      f"{_builtin.get_variable_value('${TESTNAME}')}/tcpdump/B_2_alt1"
    pcap_alias = "b2_alt1_pcap"
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    for packet in filter_list:
        if packet in filter_list[4]:
            packets = ute_tshark.get_packets_count(packet_filter=packet,
                                                   pcap_file_path=source_filepath,
                                                   alias=pcap_alias)
            assert packets == 2, f"{packets} packets for filter: {filter_list[4]} in {source_filepath}-should be 1"
        else:
            packets = ute_tshark.get_packets_count(packet_filter=packet,
                                                   pcap_file_path=source_filepath,
                                                   alias=pcap_alias)
            assert packets == 1, f"{packets} packets for filter: {filter_list} in {source_filepath}-should be 1"
    ute_tshark.teardown_tshark(alias=pcap_alias)
