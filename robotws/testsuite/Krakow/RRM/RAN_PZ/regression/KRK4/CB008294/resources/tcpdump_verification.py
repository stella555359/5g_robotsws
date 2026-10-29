"""
:copyright: Nokia Networks
:author: Mateusz Pajor, Damian Zak
:maintainer: Mateusz Pajor, Damian Zak
:contact: mateusz.pajor@nokia.com, damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

from os.path import join

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_console_info

from log_collection import get_test_log_dirpath
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.tcpdump_verify import (
    verify_gnb_tcpdump_packet_existence)


def verify_overheating_in_tcpdump():
    alias = BuiltIn().get_variable_value("${TCPDUMP_ALIAS}")
    tcpdump_log_path = BuiltIn().get_variable_value("${TCPDUMP_LOG_PATH}")
    verify_gnb_tcpdump_packet_existence(
        packet_filter=BuiltIn().get_variable_value("${RRC_RECONFIGURATION_OVERHEATING_TCPDUMP_FILTER}"),
        pcap_file_path=tcpdump_log_path,
        alias=alias)
    verify_gnb_tcpdump_packet_existence(
        packet_filter=BuiltIn().get_variable_value("${UE_CAPABILITIES_OVERHEATING_TCPDUMP_FILTER}"),
        pcap_file_path=tcpdump_log_path,
        alias=alias)


def verify_beamchange_in_ttitrace():
    logger_console_info("Start beamchange validation in TTI Traces")
    log_dir_path = get_test_log_dirpath()
    tshark_instance = BuiltIn().get_library_instance('ute_tshark')
    tshark_instance.setup_tshark(interface=None, alias='dummy_tshark')
    beam_0 = tshark_instance.get_packets_count(
        packet_filter="itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.subcellId == 0x00 && "
                      "itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.beamId == 0x00",
        pcap_file_path=f"{log_dir_path}/tti_trace_beam_change/l2stream3/tcpdump/tcpdump.pcap",
        alias='dummy_tshark')
    beam_1 = tshark_instance.get_packets_count(
        packet_filter="itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.subcellId == 0x00 && "
                      "itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.beamId == 0x0a",
        pcap_file_path=f"{log_dir_path}/tti_trace_beam_change/l2stream3/tcpdump/tcpdump.pcap",
        alias='dummy_tshark')
    tshark_instance.teardown_tshark(alias='dummy_tshark')
    assert beam_1 > 0 and beam_0 > 0, \
        f"Beam change didn\'t occur. \nNumber of beam 0 packets: {beam_0} \nNumber of beam 1 packets: {beam_1}"
    logger_console_info("Beamchange validated successfully in TTI Traces")
