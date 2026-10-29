"""
:copyright: Nokia Networks
:author: Justyna Gacek
:maintainer: Justyna Gacek
:contact: justyna.gacek@nokia.com
"""

from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import re


def get_gnb_tcpdump_packet_number(packet_filter, pcap_file_path, alias=None):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    packet_number = ta5g_tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="/tmp/frame_number.pdml",
        element_xpath='.//packet',
        attribute_xpath='.//field[@name="frame.number"]',
        attribute='show',
        pcap_file_path=pcap_file_path)
    assert len(packet_number) > 0, "{} was not found in gNB tcpdump file".format(packet_filter)
    return int(packet_number[0])


def get_gnb_tcpdump_packet_attribute_value_by_name(packet_filter, pcap_file_path, element_xpath='.//packet',
                                                   attribute_name=None, alias=None):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    attribute_value = ta5g_tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="/tmp/frame_number.pdml",
        element_xpath=element_xpath,
        attribute_xpath='.//field[@name="{}"]'.format(attribute_name),
        attribute='show',
        pcap_file_path=pcap_file_path)
    assert len(attribute_value) > 0, "{} was not found in {} in gNB tcpdump file".format(attribute_name, packet_filter)
    return attribute_value[0]


def get_gnb_tcpdump_packet_attribute_value_by_name_and_showname(packet_filter, pcap_file_path, attribute_name=None,
                                                                attribute_showname=None, alias=None):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    attribute_value = ta5g_tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="/tmp/frame_number.pdml",
        element_xpath='.//packet',
        attribute_xpath='.//field[@name="{}" and @showname="{}"]'.format(attribute_name, attribute_showname),
        attribute='show',
        pcap_file_path=pcap_file_path)
    assert len(attribute_value) > 0, "{} was not found in {} in gNB tcpdump file".format(attribute_name, packet_filter)
    return attribute_value[0]


def get_gnb_tcpdump_packet_attribute_value_by_element_xpath(packet_filter, pcap_file_path, element_xpath='.//packet',
                                                            alias=None):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    attribute_value = ta5g_tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="/tmp/frame_atribute.pdml",
        element_xpath=element_xpath,
        attribute_xpath='.',
        attribute='show',
        pcap_file_path=pcap_file_path)

    assert len(attribute_value) > 0, "{} was not found in gNB tcpdump file".format(packet_filter)
    return attribute_value[0]


def verify_gnb_tcpdump_packet_existence(packet_filter, pcap_file_path, number_of_packets=1, alias=None):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    ta5g_tshark_instance.verify_tshark(
        alias=alias,
        pcap_file_path=pcap_file_path,
        packet_filter=packet_filter,
        pass_criteria=' =={}'.format(number_of_packets)
    )
    logger.info(msg='{} matched'.format(packet_filter), also_console=True)


def verify_gnb_tcpdump_no_packet_existence(packet_filter, pcap_file_path, alias=None):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    ta5g_tshark_instance.verify_tshark_for_no_messages(
        alias=alias,
        pcap_file_path=pcap_file_path,
        packet_filter=packet_filter
    )
    logger.info(msg='{} matched'.format(packet_filter), also_console=True)


def get_timestamps_from_tshark_messages(alias, filter, element_xpath='.//packet',
                                        attribute_xpath='.//field[@name="timestamp"]', attribute='value',
                                        pcap_file_path=None, output_pdml_filepath='/tmp/output.pdml'):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    messages_times = ta5g_tshark_instance.get_attribute_values_from_tshark_messages(
                alias=alias,
                filter=filter,
                output_pdml_filepath=output_pdml_filepath,
                element_xpath=element_xpath,
                attribute_xpath=attribute_xpath,
                attribute=attribute,
                pcap_file_path=pcap_file_path
            )
    return messages_times


def get_tshark_attribute_values_by_name(packet_filter, pcap_file_path, element_xpath='.//packet',
                                        attribute_name=None, output_pdml_filepath='/tmp/output.pdml', alias=None):
    ta5g_tshark_instance = BuiltIn().get_library_instance('ta5g_tshark')
    if alias is None:
        alias = BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}")
    attribute_value = ta5g_tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath=output_pdml_filepath,
        element_xpath=element_xpath,
        attribute_xpath='.//field[@name="{}"]'.format(attribute_name),
        attribute='show',
        pcap_file_path=pcap_file_path)
    assert len(attribute_value) > 0, "{} was not found in {} in gNB tcpdump file".format(attribute_name, packet_filter)
    return attribute_value
