"""
:copyright: Nokia Networks
:author: Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
:maintainer: Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
:description: Keywords for RRC processing delay analysis based on BIP traces converted to csv
"""

import logging
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers

csv_bip = csv_verifiers()
output_dir = BuiltIn().get_variable_value("${OUTPUT DIR}")
csv_path = f"{output_dir}/BIP_logs.csv"


def get_sfn_and_slot_number_of_rrc_message(rrc_message: str, bip_message: str) -> tuple:
    """
    Filters SFN and Slot number for particular RRC message

    :param rrc_message: string with RRC message name, e.g. RRC Reconfiguration
    :param bip_message: string with L1L2 BIP message name, e.g.  DlData_PdschPayloadTbSendReqL1sw
    :return:  sfn and slot number of requested message
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    for packet in csv_list:
        if all(msg in ''.join(packet) for msg in (rrc_message, bip_message)):
            sfn, slot, *rest = packet
            info = ''.join(rest)
            logging.info(f"{rrc_message}\nSFN: {packet[0]} Slot: {packet[1]} - Info: {info}")
            return int(sfn), int(slot)
    else:
        raise Exception(f'{rrc_message} message not found within {bip_message} messages')


def convert_sfn_and_slot_to_time(sfn: int, slot: int) -> float:
    """
    Converts sfn and slots to time (ms) for Subcarrier spacing 120kHz

    :param sfn: subframe number
    :param slot: slot number
    :return: timestamp (ms)
    """
    return (80 * sfn + slot) * 0.125


def verify_rrc_processing_delay_for_rrc_reconfiguration():
    """
    Verifies RRC processing delay between DlData_PdschPayloadTbSendReqL1sw containing RRC reconfiguration sent by gNB
    and DlData_PdcchSendReqL1sw containing grant for RRC Reconfiguration Complete sent by UE. Delay should be higher
    than 10 ms.
    """
    rrc_reconf_sfn, rrc_reconf_slot = get_sfn_and_slot_number_of_rrc_message(
        rrc_message="RRC Reconfiguration",
        bip_message="DlData_PdschPayloadTbSendReqL1sw")
    rrc_reconf_comp_sfn, rrc_reconf_comp_slot = get_sfn_and_slot_number_of_rrc_message(
        rrc_message="RRC Reconfiguration Complete",
        bip_message="UlData_PuschReceiveRespLoL1sw")
    rrc_reconf_time = convert_sfn_and_slot_to_time(rrc_reconf_sfn, rrc_reconf_slot)
    rrc_reconf_comp_time = convert_sfn_and_slot_to_time(rrc_reconf_comp_sfn, rrc_reconf_comp_slot)
    rrc_processing_delay = rrc_reconf_comp_time - rrc_reconf_time - 4 * 0.125
    logging.info(f"RRC processing delay for RRC Reconfiguration Complete: {rrc_processing_delay} ms")
    assert 10 < rrc_processing_delay < 100, f"RRC processing delay for RRC Reconfiguration has abnormal value: " \
                                            f"{rrc_processing_delay}"
