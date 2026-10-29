"""
This module contains functions to calculate latencies for inter gNB handover and inter eNB handover.
It also verifies the inter gNB handover and calculates the call release latency.
It uses the pcap_checker to analyze the pcap files and extract the necessary information.

:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com
"""

from datetime import datetime
from typing import List

from robot.api import logger as robot_logger
from robot.api.deco import keyword
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.parsers.pcap_checker import pcap_checker
from taf.analyzer.pcap.pcap_packet import PcapPacket

from filters import *


@keyword()
def verify_inter_gnb_handover(pcap_file: str, pci_5g: int) -> None:
    """
    Verify inter gNB handover in pcap file.

    :param pcap_file: The path to the pcap file from inter gNB HO.
    :param pci_5g: The PCI of the 5G cell.

    :return: None
    """

    logger.log_info_to_console(msg=f"Verifying inter gNB handover in pcap file: {pcap_file}", log_hierarchy=2)
    logger.log_info_to_console(msg=f"PCI of 5G cell: {pci_5g}", log_hierarchy=2)
    robot_logger.debug(f"Verifying inter gNB handover in pcap file: {pcap_file}")
    robot_logger.debug(f"PCI of 5G cell: {pci_5g}")
    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='x2ap',
                               awaited_messages=INTER_GNB_HO_PACKETS_FILTER % pci_5g,
                               forbidden_messages=None)
    logger.log_info_to_console(msg="Inter gNB handover verification completed successfully.", log_hierarchy=2)
    robot_logger.info("Inter gNB handover verification completed successfully.")


@keyword()
def calculate_call_release_latency(pcap_file: str) -> float:
    """
    Calculate the call release latency.

    :param pcap_file: The path to the pcap file from 5G attach with call release.

    :return: The call release latency.
    """

    sgnb_release_required_packets = _get_messages(
        pcap_file=pcap_file,
        display_filter='x2ap',
        awaited_message=SGNB_RELEASE_REQUIRED_FILTER
    )
    ue_context_release_complete_packets = _get_messages(
        pcap_file=pcap_file,
        display_filter='f1ap',
        awaited_message=UE_CONTEXT_RELEASE_COMPLETE_FILTER
    )

    logger.log_info_to_console(
        msg=f"Length of SgNBReleaseRequired packets: {len(sgnb_release_required_packets)}",
        log_hierarchy=2
    )
    logger.log_info_to_console(
        msg=f"Length of UEContextReleaseComplete packets: {len(ue_context_release_complete_packets)}",
        log_hierarchy=2
    )
    robot_logger.debug(f"Length of SgNBReleaseRequired packets: {len(sgnb_release_required_packets)}")
    robot_logger.debug(f"Length of UEContextReleaseComplete packets: {len(ue_context_release_complete_packets)}")

    call_release_latency = _calculate_latency(
        sgnb_release_required_packets[-1],
        ue_context_release_complete_packets[-1]
    )
    robot_logger.info(f'Call release latency: {call_release_latency}')
    return call_release_latency


@keyword()
def calculate_inter_gnb_handover_latency(pcap_file: str, pci_5g: int = 50, source_address: str = '10.84.190.72',
                                         destination_address: str = '10.84.190.55') -> float:
    """
    Calculate the inter gNB handover latency and verify inter gNB HO.

    :param pcap_file: The path to the pcap file from inter gNB HO.
    :param pci_5g: The PCI of the 5G cell.
    :param source_address: The source address of the message.
    :param destination_address: The destination address of the message.

    :return: The inter gNB handover latency.
    """

    verify_inter_gnb_handover(pcap_file, pci_5g)

    sgnb_change_required_packets = _get_messages(
        pcap_file=pcap_file,
        display_filter='x2ap',
        awaited_message=SGNB_CHANGE_REQUIRED_FILTER
    )

    sns_status_transfer_packets = _get_messages(
        pcap_file=pcap_file,
        display_filter='x2ap',
        awaited_message=SNS_STATUS_TRANSFER_FILTER
    )

    for message in sns_status_transfer_packets:
        ip_src = message.get_field_value_by_name("ip.src")[0]
        ip_dst = message.get_field_value_by_name("ip.dst")[0]
        if ip_src == source_address and ip_dst == destination_address:
            sns_status_transfer_packets = [message]
            break

    logger.log_info_to_console(
        msg=f"Length of SgNBChangeRequired packets: {len(sgnb_change_required_packets)}",
        log_hierarchy=2
    )
    logger.log_info_to_console(
        msg=f"Length of SNStatusTransfer packets: {len(sns_status_transfer_packets)}",
        log_hierarchy=2
    )
    robot_logger.debug(f"Length of SgNBChangeRequired packets: {len(sgnb_change_required_packets)}")
    robot_logger.debug(f"Length of SNStatusTransfer packets: {len(sns_status_transfer_packets)}")

    inter_gnb_ho_latency = _calculate_latency(
        sgnb_change_required_packets[-1],
        sns_status_transfer_packets[-1]
    )
    robot_logger.info(f'Inter gNB handover latency: {inter_gnb_ho_latency}')
    return inter_gnb_ho_latency


@keyword()
def calculate_inter_enb_handover_latency(pcap_file: str, source_address: str = '10.84.190.73') -> float:
    """
    Calculate the inter eNB handover latency.

    :param pcap_file: The path to the pcap file from inter eNB HO.
    :param source_address: The source address of the message.

    :return: The inter eNB handover latency.
    """

    sgnb_addition_request_packets = _get_messages(
        pcap_file=pcap_file,
        display_filter='x2ap',
        awaited_message=SGNB_ADDITION_REQUEST_FILTER
    )
    ue_context_modification_packets = _get_messages(
        pcap_file=pcap_file,
        display_filter='f1ap',
        awaited_message=UE_CONTEXT_MODIFICATION_RESPONSE_FILTER
    )

    for message in sgnb_addition_request_packets:
        print(message.get_field_value_by_name("ip.src"))
        if message.get_field_value_by_name("ip.src")[0] == source_address:
            sgnb_addition_request_packets = [message]
            break

    logger.log_info_to_console(
        msg=f"Length of SgNBAdditionRequest packets: {len(sgnb_addition_request_packets)}",
        log_hierarchy=2
    )
    logger.log_info_to_console(
        msg=f"Length of UEContextModificationResponse packets: {len(ue_context_modification_packets)}",
        log_hierarchy=2
    )
    robot_logger.debug(f"Length of SgNBAdditionRequest packets: {len(sgnb_addition_request_packets)}")
    robot_logger.debug(f"Length of UEContextModificationResponse packets: {len(ue_context_modification_packets)}")

    inter_enb_ho_latency = _calculate_latency(
        sgnb_addition_request_packets[-1],
        ue_context_modification_packets[-1]
    )
    robot_logger.info(f'Inter eNB handover latency: {inter_enb_ho_latency}')
    return inter_enb_ho_latency


def _calculate_latency(first_message: PcapPacket, second_message: PcapPacket) -> float:
    """
    Calculate the latency between two messages.

    :param first_message: The first message to calculate latency.
    :param second_message: The second message to calculate latency.

    :return: The rate of messages.
    """

    messages_start = _proces_time(first_message.get_field_value_by_name("timestamp"))
    messages_end = _proces_time(second_message.get_field_value_by_name("timestamp"))
    messages_timedelta = (messages_end - messages_start).total_seconds() * 1000
    return messages_timedelta


def _get_messages(pcap_file: str, display_filter: str, awaited_message: str) -> List[PcapPacket]:
    """
    Get messages from the pcap file.

    :param pcap_file: The path to the pcap file.
    :param display_filter: The display filter to filter messages.
    :param awaited_message: The awaited message to filter messages.

    :return: The list of messages.
    """

    return pcap_checker().get_packets(
        pcap_file=pcap_file,
        display_filter=display_filter,
        awaited_message=awaited_message
    )


def _proces_time(time: str) -> datetime:
    """
    Convert a string representation of time to a datetime object.

    :param time: The string representation of time in the format "Mon DD, YYYY HH:MM:SS".

    :return: The datetime object representing the given time.
    """

    MONTH_TEXT_TO_NUMBER_MAP = dict(zip(
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], range(1, 13)
    ))

    time = [element for element in time[0].split(" ") if element != ""]
    year, month, day = int(time[2]), MONTH_TEXT_TO_NUMBER_MAP[time[0]], int(time[1].split(",")[0])

    time = time[3].split(".")
    microsecond = int(int(time[1]) / 1000)

    time = time[0].split(":")
    hour, minute, second = int(time[0]), int(time[1]), int(time[2])

    return datetime(year, month, day, hour, minute, second, microsecond)
