import logging
import json
from robot.api.deco import keyword
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable
from taf.rfrl.utilities.parsers.pcap_checker import pcap_checker

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.common import RfAttenuator
from testsuite.Krakow.RRM.RAN_PZ.resources.pcap_verification.flow_verifier import flow_verifier
import testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.pcap.msg.rrc as rrc


_tl = get_builtin_value(param_name="tl")


@keyword()
def get_nr_cell_id_in_hex(nr_cell_id, hex_len=11):
    """
    The function dump nrcellid to hex format.

    :param nr_cell_id: cell's nrcellid in dec format
    :param hex_len: length of hex string after '0x'
    :return: cell's nrcellid in hex format
    """

    return "{0:#0{1}x}".format(int(nr_cell_id), hex_len)


@keyword()
def get_pm_counters_list(counter_prefix, suffix_len=3, size=20):
    """
    The function returns list of PM Counter IDs.
    Example get_pm_counters_list(counter_prefix="M55311C42") returns [M55311C42001, M55311C42002 ... , M55311C42020]

    :param counter_prefix: string containing beginning/prefix of PM Counter name
    :param suffix_len: amount of characters to be added to prefix of PM Counter name
    :param size: generated list size
    :return: list of PM Counter IDs
    """

    return [counter_prefix + str(i).zfill(suffix_len) for i in range(1, size + 1)]


def find_all_scells_in_message(expected_scells, message):
    """
    Finds expected SCells in message list. Message is part of pcap text structure.

    :param expected_scells: SCells expected to find
    :param message: Message including SCells
    :return bool: Return true if all SCells are in the message
    """

    scells_as_str = map(str, expected_scells)
    scells_as_hex = map(get_nr_cell_id_in_hex, expected_scells)
    expected_scells = dict(zip(scells_as_str, scells_as_hex))
    return all(
        scell_id_as_str in str(message) or scell_id_as_hex in str(message)
        for scell_id_as_str, scell_id_as_hex in expected_scells.items()
    )


@keyword()
def find_item_in_message(expected_item, message):
    """
    Finds item in message.

    :param expected_item: Item expected to find
    :param message: Message including item
    :return bool: Return true if item is in message
    """

    return expected_item in str(message)


@keyword()
def find_items_in_message(expected_items, message):
    """
    Finds items in message.

    :param expected_items: Item expected to find
    :param message: Message including items
    :return bool: Return true if all items are included in message
    """

    return all(expected_item in str(message) for expected_item in expected_items)


@keyword()
def check_if_one_item_is_within_other_item(parent_item, child_items, message):
    """
    Checks if items are included in other item

    :param parent_item: Item within other item should be included
    :param child_items: Items included in parent item
    :param message: Message including items
    :return bool: Return true if all children items ares included in parent items
    """

    parent_item_in_message = str(message.find(parent_item))
    return all(child_item in parent_item_in_message for child_item in child_items)


@keyword()
def check_if_item_has_proper_value(item, value, message):
    """
    Checks if item exists in message and have proper value

    :param item: Item to look for in message
    :param value: Value of looked item
    :param message: Message including item
    :return bool: Return true if item exists and has proper value
    """

    message = str(message)
    index_of_item = message.find(item)
    item_and_value = message[index_of_item:].split(',')[0]
    return value in item_and_value.split(':')[1]


@keyword()
def count_appearances_in_message(item, appearances, message):
    """
    Checks appearance of item in message and return true if appearances are not less than given value

    :param item: Item to look for in message
    :param appearances: Number of appearances of item that need to be checked
    :param message: Message including item
    :return bool: Return true if item appears no less than given value in message
    """

    all_items_form_message = list(message.find(item))
    logging.info("All items of the message: {}".format(all_items_form_message))
    counter = 0
    for item in all_items_form_message:
        if "'val': '0'" in str(item):
            counter += 1
    logging.info("Item {} appeared {} times in {} message".format(item, counter, message))
    return counter >= int(appearances)


@keyword()
def find_cause_and_its_value(item, value, message):
    """
    Checks if item exists in message and have proper value

    :param item: Item to look for in message
    :param value: Value of looked item
    :param message: Message including item
    :return bool: Return true if item exists and has proper value
    """

    item_in_message = str(message.find(item))
    return value in item_in_message


@keyword()
def check_messages_length(messages, expected_length):
    """
    Checks if table of messages have propper value

    :param messages: Table of message to check value
    :param expected_length: expected table length
    :return bool: Return true if expected length of table of messages in not less than given value
    """

    return len(list(messages)) >= int(expected_length)


@keyword()
def remove_unused_gnb_from_tl_robot_variable():
    """
    Removes second gNB from 'tl' variable that common keywords won't check its state since it is not used for tests

    :return: None
    """

    tl_var = get_builtin_value('tl')
    logging.info('Initial tl variable: {}'.format(tl_var))
    del tl_var.gnbs[1]
    logging.info('Modified tl variable: {}'.format(tl_var))
    set_robot_suite_variable('tl', tl_var)


@keyword()
def verify_f1ap_ue_context_release(pcap_file):
    """
    Verifies F1AP  messages content based on pcap file.
    ueContextReleaseCommand has Cause radioNetwork == normal-release

    :param pcap_file: path to pcap file
    :return: None
    """

    f1ap_awaited_messages = """
        UEContextReleaseCommand has radioNetwork == normal-release  {
            findBy { has(f1ap.UEContextReleaseCommand_element) }
            verifyBy { has(f1ap.radioNetwork:=10) }
        }
        UEContextReleaseComplete {
            findBy { has(f1ap.UEContextReleaseComplete_element) }
        }
        UEContextReleaseCommand radioNetwork == normal-release and rrcRelease {
            findBy { has(f1ap.UEContextReleaseCommand_element) }
            verifyBy { has(f1ap.radioNetwork:=10)
                       has(nr-rrc.rrcRelease_element) }
        }
        UEContextReleaseComplete {
            findBy { has(f1ap.UEContextReleaseComplete_element) }
        }
    """
    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='f1ap',
                               awaited_messages=f1ap_awaited_messages,
                               forbidden_messages=None)


@keyword()
def verify_e1ap_bearer_context_release(pcap_file):
    """
    Verifies E1AP messages content based on pcap file.
    ueContextReleaseCommand has Cause radioNetwork == normal-release

    :param pcap_file: path to pcap file
    :return: None
    """

    e1ap_awaited_messages = """
        BearerContextReleaseCommand has radioNetwork == normal-release {
            findBy { has(e1ap.BearerContextReleaseCommand_element) }
            verifyBy { has(e1ap.radioNetwork:=20) }
        }
        BearerContextReleaseComplete {
            findBy { has(e1ap.BearerContextReleaseComplete_element) }
        }
    """
    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='e1ap',
                               awaited_messages=e1ap_awaited_messages,
                               forbidden_messages=None)


@keyword()
def verify_ngap_ue_context_release(pcap_file):
    """
    Verifies NGAP messages content based on pcap file.
    ueContextReleaseCommand has Cause radioNetwork == normal-release

    :param pcap_file: path to pcap file
    :return: None
    """

    ngap_awaited_messages = """
        UEContextReleaseCommand has nas == deregister  {
            findBy { has(ngap.UEContextReleaseCommand_element) }
            verifyBy { has(ngap.nas:=2)
            }
        }
        UEContextReleaseComplete {
            findBy { has(ngap.UEContextReleaseComplete_element) }
        }
    """
    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='ngap',
                               awaited_messages=ngap_awaited_messages,
                               forbidden_messages=None)


def verify_f1_ue_context_setup(pcap_file):
    """
    Verifies NGAP messages content based on pcap file.
    ueContextReleaseCommand has Cause radioNetwork == normal-release

    :param pcap_file: path to pcap file
    :return: None
    """

    awaited_messages = """
        MN UEContextSetupRequest  {
            findBy { has(f1ap.UEContextSetupRequest_element) }
        }
        MN UEContextSetupResponse {
            findBy { has(f1ap.UEContextSetupResponse_element) }
        }
        SN UEContextSetupRequest  {
            findBy { has(f1ap.UEContextSetupRequest_element) }
            verifyBy { has(f1ap.SCell_ToBeSetup_List:=7)
                       has(nr-rrc.allowedBC_ListMRDC:=1)
            }
        }
        SN UEContextSetupResponse {
            findBy { has(f1ap.UEContextSetupResponse_element) }
            verifyBy { has(f1ap.SelectedBandCombinationIndex)
                       has(f1ap.SelectedFeatureSetEntryIndex)
                       has(nr-rrc.sCellToAddModList:=7)
            }
        }
    """
    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='f1ap',
                               awaited_messages=awaited_messages,
                               forbidden_messages=None)


@keyword()
def verify_ngap_initial_context_setup(pcap_file, nrcell_id):
    """
    Verifies NGAP messages content based on pcap file.
    ueContextReleaseCommand has Cause radioNetwork == normal-release

    :param pcap_file: path to pcap file
    :param nrcell_id: nr cell identity in HEX to be checked in UL NAS transport to 5GC # e.g. 0x000000004b348014
    :return: None
    """

    ngap_awaited_messages = """
        InitialUEMessage is RegistrationRequest {
            findBy { has(ngap.InitialUEMessage_element) }
            verifyBy { has(ngap.NRCellIdentity:=%s) }
        }
        InitialContextSetupRequest has PDU Session {
            findBy { has(ngap.InitialContextSetupRequest_element) }
            verifyBy { has(ngap.PDUSessionResourceSetupListCxtReq) }
        }
        InitialContextSetupResponse has PDU Session {
            findBy { has(ngap.InitialContextSetupResponse_element) }
            verifyBy { has(ngap.PDUSessionResourceSetupListCxtRes) }
        }
    """
    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='ngap',
                               awaited_messages=ngap_awaited_messages % nrcell_id,
                               forbidden_messages=None)


@keyword()
def check_that_interfreq_and_interrat_measurements_were_configured_for_ue(pcap_file):
    """
    Verifies RRC messages content based on pcap file. rrcReconfiguration has to contain Inter-Freq and Inter-RAT
    measurement configuration.

    :param pcap_file: path to pcap file
    :return: None
    """

    rrc_msgs = ["rrcReconfiguration"]
    _log_messages(rrc_msgs, pcap_file)
    checks = [
        """rrcReconfiguration(
                contains(measObjectNR),
                contains(freqBandIndicatorNR=78),
                contains(eventA2),
                not_contains(freqBandIndicatorNR=257))""",
        """rrcReconfiguration(
                contains(measObjectNR),
                contains(freqBandIndicatorNR=28),
                not_contains(freqBandIndicatorNR=257),
                contains(eventA1),
                contains(eventA3),
                not_contains(eventA4),
                contains(measObjectEUTRA),
                contains(reportConfigInterRAT),
                contains(eventB2))""",
    ]
    _log_checks(checks)
    flow_verifier().expect_messages_in_flow(awaited_messages=checks, pcap_file=pcap_file)


@keyword()
def check_that_interfreq_and_interrat_measurements_were_not_configured_for_ue(pcap_file):
    """
    Verifies RRC messages content based on pcap file. rrcReconfiguration cannot contain Inter-Freq and Inter-RAT
    measurement configuration.

    :param pcap_file: path to pcap file
    :return: None
    """

    rrc_msgs = ["rrcReconfiguration"]
    _log_messages(rrc_msgs, pcap_file)
    checks = [
        """PDUSessionResourceSetupRequest(
                contains(fiveQI=9))""",
        """PDUSessionResourceSetupResponse(
                contains(PDUSessionResourceSetupItemSURes))""",
        """rrcReconfiguration(
                contains(measObjectNR),
                contains(freqBandIndicatorNR=257),
                contains(eventA4),
                not_contains(measObjectEUTRA),
                not_contains(reportConfigInterRAT),
                not_contains(eventA2),
                not_contains(eventA3))""",
    ]
    _log_checks(checks)
    flow_verifier().expect_messages_in_flow(awaited_messages=checks, pcap_file=pcap_file)


@keyword()
def check_that_a4_nrdc_is_configured_and_rrc_release_contains_frequencies_for_reselection(pcap_file):
    """
    Verifies RRC messages content based on pcap file. rrcReconfiguration have to contain A4 NRDC. rrcRelease have to
    contain cellReselectionPriorities.

    :param pcap_file: path to pcap file
    :return: None
    """

    rrc_msgs = ["rrcReconfiguration",
                "rrcRelease"]
    _log_messages(rrc_msgs, pcap_file)
    checks = [
        """PDUSessionResourceSetupRequest(
                contains(fiveQI=9))""",
        """PDUSessionResourceSetupResponse(
                contains(PDUSessionResourceSetupItemSURes))""",
        """rrcReconfiguration(
                contains(measObjectNR),
                contains(freqBandIndicatorNR=257),
                contains(eventA4))""",
        """rrcReconfiguration(
                contains(measIdToRemoveList: 1 item),
                contains(gapUE: release (0)))""",
        """rrcRelease(
                contains(cellReselectionPriorities))"""
    ]
    _log_checks(checks)
    flow_verifier().expect_messages_in_flow(awaited_messages=checks, pcap_file=pcap_file)


@keyword()
def check_reestablishment(pcap_file):
    """
    Verifies RRC messages content based on pcap file. rrcReconfiguration on serving cell have to contain A4 NRDC.
    rrcReestablishment is successful to other cell than serving one. rrcReconfiguration on other cell have to
    contain A4 NRDC.

    :param pcap_file: path to pcap file
    :return: None
    """

    rrc_msgs = ["rrcReconfiguration",
                "rrcReestablishmentRequest",
                "rrcReestablishment",
                "rrcReestablishmentComplete"]
    _log_messages(rrc_msgs, pcap_file)
    checks = [
        """PDUSessionResourceSetupRequest(
                contains(fiveQI=9))""",
        """PDUSessionResourceSetupResponse(
                contains(PDUSessionResourceSetupItemSURes))""",
        """rrcReconfiguration(
                contains(measObjectNR),
                contains(freqBandIndicatorNR=257),
                contains(eventA4))""",
        """rrcReestablishmentRequest(
                contains(physCellId=30))""",
        """rrcReestablishment""",
        """rrcReestablishmentComplete""",
        """rrcReconfiguration(
                contains(measObjectNR),
                contains(freqBandIndicatorNR=78),
                not_contains(reportConfigNR))""",
        """rrcReconfiguration(
                contains(measObjectNR),
                contains(freqBandIndicatorNR=257),
                contains(eventA4))""",
    ]
    _log_checks(checks)
    flow_verifier().expect_messages_in_flow(awaited_messages=checks, pcap_file=pcap_file)


def _log_checks(str_list):
    """Logs list of expected messages that we want to verify."""
    logging.info("Messages to be verified:")
    for str_item in str_list:
        logging.info(str_item)


def _log_messages(msgs_to_log, pcap_file):
    """Logs contents of desired messages from pcap file"""

    if not msgs_to_log:
        logging.warning("Empty list of messages to be logged")
    fv = flow_verifier()
    for msg_type in msgs_to_log:
        msgs = fv.get_messages_from_the_flow(awaited_message=msg_type,
                                             pcap_file=pcap_file)
        if not msgs:
            logging.info("No message containing {} field found")
        for msg in msgs:
            msg_chunk = msg.find(msg_type)
            logging.info(json.dumps(next(iter(msg_chunk), None), indent=4))


@keyword
def trigger_reestablishment_to_other_cell(src_radio_type, tgt_radio_type):
    """
    Keyword tries to trigger UE reestablishment to other cell (than serving one) by changing attenuation of ports
    connected to RUs serving cells

    :param src_radio_type: RU.radio_type from __init.py__, e.g.: "AHEH"
    :param tgt_radio_type: RU.radio_type from __init.py__, e.g.: "AZQO"
    :return: None
    """
    ck = RfAttenuator()
    ck.set_attenuation_for_ru(radio_type=tgt_radio_type, value="0dB")
    ck.set_attenuation_for_ru(radio_type=src_radio_type, value="110dB")


@keyword()
def verify_nrdc_call_setup(pcap_file):
    """
    Verifies basic flow of NRDC call setup on NR-RRC interface

    :param pcap_file: path to pcap file
    :return: None
    """

    flow = [rrc.MEASUREMENT_REPORT_PCI % '70',
            rrc.RRC_RECONFIG_NRDC_DETAILED,
            rrc.RRC_RECONFIG_COMPLETE]

    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='f1ap',
                               awaited_messages="".join(flow),
                               forbidden_messages=rrc.RRC_RECONFIG_SCG_RELEASE)
