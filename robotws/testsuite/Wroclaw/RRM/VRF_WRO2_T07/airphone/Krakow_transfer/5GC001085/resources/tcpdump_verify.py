"""
:copyright: Nokia Networks
:author: Justyna Gacek
:maintainer: Justyna Gacek
:contact: justyna.gacek@nokia.com
"""

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.tcpdump_verify import *
from ta5g_interface_tools import ta5g_interface_tools
from suite_specific_keywords import get_test_prefix
from robot.api import logger
import os


def get_pcap_filepath():
    log_dirpath = ta5g_interface_tools().get_robot_output_dir()
    prefix = get_test_prefix()
    pcap_file_path = os.path.join(log_dirpath, prefix, "tcpdump_GNB_{}.pcap".format(prefix))
    return pcap_file_path


def verify_xnap_handover_request_packet_nonexistence():
    verify_gnb_tcpdump_no_packet_existence(packet_filter='xnap.HandoverRequest_element',
                                           pcap_file_path=get_pcap_filepath())


def verify_xnap_handoverrequestacknowledge_packet_nonexistence():
    verify_gnb_tcpdump_no_packet_existence(packet_filter='xnap.HandoverRequestAcknowledge_element',
                                           pcap_file_path=get_pcap_filepath())


def verify_gnb_tcpdump_packet_existence_after_XnSetupRequest(packet_filter, number_of_packets=1):
    xnSetupRequest_number = get_gnb_tcpdump_packet_number(packet_filter='xnap.XnSetupRequest_element',
                                                          pcap_file_path=get_pcap_filepath())
    packet_filter = '{} and frame.number > {}'.format(packet_filter, xnSetupRequest_number)
    verify_gnb_tcpdump_packet_existence(packet_filter=packet_filter, number_of_packets=number_of_packets,
                                        pcap_file_path=get_pcap_filepath())


def verify_NRCGI_HO_request():
    verify_gnb_tcpdump_packet_existence(packet_filter='xnap.NR_Cell_Identity == 0x0000001001',
                                        number_of_packets=1,
                                        pcap_file_path=get_pcap_filepath())


def verify_NGAP_XnSetupRequest_packet_existence():
    verify_gnb_tcpdump_packet_existence(packet_filter='xnap.XnSetupRequest_element',
                                        number_of_packets=1, pcap_file_path=get_pcap_filepath())


def verify_NGAP_XnSetupFailure_packet_existence():
    verify_gnb_tcpdump_packet_existence_after_XnSetupRequest(packet_filter='xnap.XnSetupFailure_element')
    logger.info(msg='xnap.XnSetupFailure_element matched', also_console=True)


def verify_NGAP_UplinkRANConfigurationTransfer_packet_existance():
    verify_gnb_tcpdump_packet_existence(packet_filter='ngap.UplinkRANConfigurationTransfer_element',
                                        pcap_file_path=get_pcap_filepath())
    logger.info(msg='ngap.UplinkRANConfigurationTransfer_element', also_console=True)


def get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_name(attribute_name):
    attribute_value = get_gnb_tcpdump_packet_attribute_value_by_name(
        packet_filter='ngap.UplinkRANConfigurationTransfer_element', attribute_name=attribute_name,
        pcap_file_path=get_pcap_filepath())
    return attribute_value


def get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_name_and_xpath(attribute_name, element_xpath):
    attribute_value = get_gnb_tcpdump_packet_attribute_value_by_name(
        packet_filter='ngap.UplinkRANConfigurationTransfer_element',
        attribute_name=attribute_name,
        element_xpath=element_xpath,
        pcap_file_path=get_pcap_filepath())
    return attribute_value


def get_NGAP_DownlinkRANConfigurationTransfer_attribute_value_by_xpath(element_xpath):
    attribute_value = get_gnb_tcpdump_packet_attribute_value_by_element_xpath(
        packet_filter='ngap.DownlinkRANConfigurationTransfer_element',
        element_xpath=element_xpath,
        pcap_file_path=get_pcap_filepath())
    return attribute_value


def get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_xpath(element_xpath):
    attribute_value = get_gnb_tcpdump_packet_attribute_value_by_element_xpath(
        packet_filter='ngap.UplinkRANConfigurationTransfer_element',
        element_xpath=element_xpath,
        pcap_file_path=get_pcap_filepath())
    return attribute_value


def get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_name_and_showname(
        attribute_name, attribute_showname):
    attribute_value = get_gnb_tcpdump_packet_attribute_value_by_name_and_showname(
        packet_filter='ngap.UplinkRANConfigurationTransfer_element',
        attribute_name=attribute_name,
        attribute_showname=attribute_showname,
        pcap_file_path=get_pcap_filepath())
    return attribute_value


def verify_NGAP_UplinkRANConfigurationTransfer_packet_attribute_value_by_name(attribute_name, expected_value):
    attribute_value = get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_name(attribute_name=attribute_name)
    assert attribute_value == expected_value


def verify_NGAP_UplinkRANConfigurationTransfer_packet_attribute_value_by_name_and_showname(attribute_name,
                                                                                           attribute_showname,
                                                                                           expected_value):
    attribute_value = get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_name_and_showname(
        attribute_name=attribute_name, attribute_showname=attribute_showname)
    assert attribute_value == expected_value


def verify_NGAP_UplinkRANConfigurationTransfer_packet_attribute_value_by_name_and_xpath(attribute_name, element_xpath,
                                                                                        expected_value):
    attribute_value = get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_name_and_xpath(
        attribute_name=attribute_name,
        element_xpath=element_xpath)
    assert attribute_value == expected_value


def verify_NGAP_UplinkRANConfigurationTransfer_packet_values_for_7883_TC20_TC21():
    verify_NGAP_UplinkRANConfigurationTransfer_packet_attribute_value_by_name(
        attribute_name='ngap.TransportLayerAddressIPv4', expected_value='10.0.1.2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_attribute_value_by_name(
        attribute_name='ngap.TransportLayerAddressIPv6', expected_value='fd94:e15d:8bda:aefc::1:25')
    logger.info(msg='ngap.TransportLayerAddressIPv4 attributes matched', also_console=True)


def verify_NGAP_UplinkRANConfigurationTransfer_packet_value(expected_value):
    verify_NGAP_UplinkRANConfigurationTransfer_packet_attribute_value_by_name(
        attribute_name='ngap.TransportLayerAddressIPv4', expected_value=expected_value)
    logger.info(msg='ngap.TransportLayerAddressIPv4 attributes matched', also_console=True)


def verify_NGAP_DownlinkRANConfigurationTransfer_packet_existance():
    verify_gnb_tcpdump_packet_existence(packet_filter='ngap.DownlinkRANConfigurationTransfer_element',
                                        pcap_file_path=get_pcap_filepath())
    logger.info(msg='ngap.DownlinkRANConfigurationTransfer_element matched', also_console=True)


def get_NGAP_DownlinkRANConfigurationTransfer_attribute_value_by_name(attribute_name):
    attribute_value = get_gnb_tcpdump_packet_attribute_value_by_name(
        packet_filter='ngap.DownlinkRANConfigurationTransfer_element', attribute_name=attribute_name,
        pcap_file_path=get_pcap_filepath())
    return attribute_value


def verify_NGAP_DownlinkRANConfigurationTransfer_packet_attribute_value_by_name(attribute_name, expected_value):
    attribute_value = get_NGAP_DownlinkRANConfigurationTransfer_attribute_value_by_name(attribute_name=attribute_name)
    assert attribute_value == expected_value


def verify_NGAP_DownlinkRANConfigurationTransfer_packet_value(expected_value):
    verify_NGAP_DownlinkRANConfigurationTransfer_packet_attribute_value_by_name(
        attribute_name='ngap.TransportLayerAddressIPv6', expected_value=expected_value)
    logger.info(msg='ngap.DownlinkRANConfigurationTransfer_element attributes matched', also_console=True)


def verify_gnb_tcpdump_packet_existence_after_UplinkRANConfigurationTransfer(packet_filter, number_of_packets=1):
    uplinkRANConfigurationTransfer_number = get_gnb_tcpdump_packet_number(
        packet_filter='ngap.UplinkRANConfigurationTransfer_element', pcap_file_path=get_pcap_filepath())
    packet_filter = '{} and frame.number > {}'.format(packet_filter, uplinkRANConfigurationTransfer_number)
    verify_gnb_tcpdump_packet_existence(packet_filter=packet_filter, number_of_packets=number_of_packets,
                                        pcap_file_path=get_pcap_filepath())


def verify_NGAP_DownlinkRANConfigurationTransfer_packet_existance_after_UplinkRANConfigurationTransfer():
    verify_gnb_tcpdump_packet_existence_after_UplinkRANConfigurationTransfer(
        packet_filter='ngap.DownlinkRANConfigurationTransfer_element')
    logger.info(msg='ngap.DownlinkRANConfigurationTransfer_element matched', also_console=True)


def verify_NGAP_DownlinkRANConfigurationTransfer_packet_attribute_ngap_gNB_ID_value(expected_value='00:00:42:60'):
    attribute_value = get_NGAP_DownlinkRANConfigurationTransfer_attribute_value_by_xpath(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="ngap.gNB_ID"]')
    assert attribute_value == expected_value


def verify_NGAP_UplinkRANConfigurationTransfer_packet_element(element_xpath, expected_value='00:00:42:60'):
    attribute_value = get_NGAP_UplinkRANConfigurationTransfer_attribute_value_by_xpath(
        element_xpath=element_xpath)
    assert attribute_value == expected_value


def verify_NGAP_UplinkRANConfigurationTransfer_packet_values_for_7883_TC23():
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="e212.mcc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="e212.mnc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="ngap.gNB_ID"]',
        expected_value='00:00:08')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mcc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mnc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*'
                      '[@name="ngap.tAC"]',
        expected_value='0')

    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="e212.mcc"]',
        expected_value='311')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="e212.mnc"]',
        expected_value='489')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="ngap.gNB_ID"]',
        expected_value='00:00:04')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mcc"]',
        expected_value='311')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mnc"]',
        expected_value='489')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*'
                      '[@name="ngap.tAC"]',
        expected_value='0')
    logger.info(msg='ngap.UplinkRANConfigurationTransfer_element attributes matched', also_console=True)


def verify_NGAP_UplinkRANConfigurationTransfer_packet_values_for_7883_TC012():
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="e212.mcc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="e212.mnc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="ngap.gNB_ID"]',
        expected_value='00:00:08')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mcc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mnc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*'
                      '[@name="ngap.tAC"]',
        expected_value='0')

    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="e212.mcc"]',
        expected_value='311')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="e212.mnc"]',
        expected_value='489')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="ngap.gNB_ID"]',
        expected_value='00:00:04')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mcc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mcc"]',
        expected_value='2')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*'
                      '[@name="ngap.tAC"]',
        expected_value='0')
    logger.info(msg='ngap.UplinkRANConfigurationTransfer_element attributes matched', also_console=True)


def verify_NGAP_UplinkRANConfigurationTransfer_packet_values_for_7883_TC022():
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="e212.mcc"]',
        expected_value='311')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="e212.mnc"]',
        expected_value='489')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.targetRANNodeID_SON_element"]/*/*/*/*[@name="ngap.gNB_ID"]',
        expected_value='00:00:08')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mcc"]',
        expected_value='311')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mnc"]',
        expected_value='489')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.targetRANNodeID_SON_element"]/*[@name="ngap.selectedTAI_element"]/*'
                      '[@name="ngap.tAC"]',
        expected_value='0')

    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="e212.mcc"]',
        expected_value='311')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="e212.mnc"]',
        expected_value='489')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='.//field[@name="ngap.sourceRANNodeID_element"]/*/*/*/*[@name="ngap.gNB_ID"]',
        expected_value='00:00:04')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mcc"]',
        expected_value='311')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*/*'
                      '[@name="e212.5gstai.mnc"]',
        expected_value='489')
    verify_NGAP_UplinkRANConfigurationTransfer_packet_element(
        element_xpath='//field[@name="ngap.sourceRANNodeID_element"]/*[@name="ngap.selectedTAI_element"]/*'
                      '[@name="ngap.tAC"]',
        expected_value='0')
    logger.info(msg='ngap.UplinkRANConfigurationTransfer_element attributes matched', also_console=True)
