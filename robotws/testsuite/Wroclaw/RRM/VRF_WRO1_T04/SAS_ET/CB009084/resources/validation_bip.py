# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.mcshark_management import \
    ensure_mcshark_package_is_installed
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import \
    check_file_exists, get_latest_file
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import \
    logger_console, logger_warning
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.bip_management import \
    create_tshark_command
from validation_txt import ensure_it_is_file_stream, convert_enum_to_list, regexp_in_string_exists
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
import os


class NotExistingTxtBipFileWithFilterException(Exception):
    pass


class SfnValueMismatchException(Exception):
    pass


class SlotValueMismatchException(Exception):
    pass


class NotExpectedSlotInPdschSendReqException(Exception):
    pass


class WrongStartPrbValueInPdschSendReqException(Exception):
    pass


class WrongNumOfPrbValueInPdschSendReqException(Exception):
    pass


def __save_pcap_to_txt(output_dir, prefix, pcap_path, using_mcshark, filter, names='l1l2bip'):
    output_path = os.path.join(output_dir, names, prefix + ".txt")
    tshark = create_tshark_command(bip_pcap_file=pcap_path, using_mcshark=using_mcshark, filter_mode=filter,
                                   luashark_path=None, output_path=output_path)
    OperatingSystem().run(tshark)
    return output_path


def __look_for_pcap_file(output_dir, pattern, using_mcshark, filter, names='l1l2bip'):
    try:
        latest_bip = get_latest_file(os.path.join(output_dir, names, pattern))
        if latest_bip is None:
            return None
    except ValueError:
        return None
    logger_console("Decoding {} file to txt format and checking if {} returns sth...".format(latest_bip, filter))
    output = __save_pcap_to_txt(output_dir=output_dir, prefix='testfile',
                                pcap_path=latest_bip,
                                using_mcshark=using_mcshark,
                                filter=filter)
    if check_file_exists(output):
        logger_console("Returning pcap with filter {}: {}".format(filter, latest_bip))
        return latest_bip
    logger_console("{} does not contain any msg with filter {}!".format(latest_bip, filter))
    return None


def __get_latest_collected_bip(output_dir, using_mcshark, filter):
    patterns = ['p_*.pcap', '0_*.pcap', '1_*.pcap', '2_*.pcap', 'bip.pcap']
    for p in patterns:
        found_bip_path = __look_for_pcap_file(output_dir=output_dir, pattern=p,
                                              using_mcshark=using_mcshark, filter=filter)
        if found_bip_path is not None:
            return found_bip_path
    raise NotExistingTxtBipFileWithFilterException("Could not find bip file with filter {}!".format(filter))


def save_filtered_pcap_to_txt_file(output_dir, prefix, using_mcshark, pcap_path=None, filter=''):
    mcshark_global_path = BuiltIn().get_variable_value("${BIP_MCSHARK_PATH}")
    if not pcap_path:
        pcap_path = __get_latest_collected_bip(output_dir=output_dir, using_mcshark=using_mcshark, filter=filter)
    if using_mcshark:
        ensure_mcshark_package_is_installed(mcshark_path=mcshark_global_path)
    output_path = __save_pcap_to_txt(output_dir=output_dir, prefix=prefix, pcap_path=pcap_path,
                                     using_mcshark=using_mcshark, filter=filter)
    logger_console("\n Output BIP path {} \n".format(output_path))
    BuiltIn().set_suite_variable("${BIP_TXT_OUTPUT_PATH}", output_path)


def set_output_dir_tc():
    BuiltIn().set_suite_variable("${OUTPUT_DIR_TC}", '/home/ute/logs/E_9084')
    BuiltIn().set_suite_variable("${BIP_TXT_OUTPUT_PATH}", '/home/ute/logs/E_9084/dldata_pdsch_pdcch_send_req.txt')


def __strings_does_not_contain_correct_order_pdsch_pdcch_send_req_msgs(expected_pdsch_1, expected_pdsch_2,
                                                                       expected_pdcch):
    pdsch_send_req_text = BuiltIn().get_variable_value('${DLDATA_PDSCHSENDREQ_TEXT}')
    pdcch_send_req_text = BuiltIn().get_variable_value('${DLDATA_PDCCHSENDREQ_TEXT}')
    if regexp_in_string_exists(string=expected_pdsch_1, text=pdsch_send_req_text, raise_exception=False) and\
       regexp_in_string_exists(string=expected_pdsch_2, text=pdsch_send_req_text, raise_exception=False) and\
       regexp_in_string_exists(string=expected_pdcch, text=pdcch_send_req_text, raise_exception=False):
        return not True

    return not False


def __string_contain_pdsch_send_req_msg(expected_pdsch):
    pdsch_send_req_text = BuiltIn().get_variable_value('${DLDATA_PDSCHSENDREQ_TEXT}')
    if regexp_in_string_exists(string=expected_pdsch, text=pdsch_send_req_text, raise_exception=False):
        return True

    return False


def __compare_values_between_two_strings(string1, string2, regexp, log_info='NoInfo'):
    match_1 = regexp_in_string_exists(string=string1, regexp=regexp)
    value_1 = match_1.group("VALUE")

    match_2 = regexp_in_string_exists(string=string2, regexp=regexp)
    value_2 = match_2.group("VALUE")

    if value_1 == value_2:
        logger_console('{} values between two strings are correct! {} == {}'.format(log_info, value_1, value_2))
        return True

    msg = '{} values are different in strings! {} != {}'.format(log_info, value_1, value_2)
    logger_warning(msg)
    return False


def __compare_sfn_slot_values_between_two_strings(string1, string2, log_info='NoMsgInfo'):
    sfn_regexp = BuiltIn().get_variable_value('${SFN_UINT16_REGEXP}')
    slot_regexp = BuiltIn().get_variable_value('${SLOT_UINT8_REGEXP}')

    sfn_are_the_same = __compare_values_between_two_strings(string1=string1, string2=string2,
                                                            regexp=sfn_regexp, log_info='SFN {}'.format(log_info))
    if not sfn_are_the_same:
        return False

    slot_are_the_same = __compare_values_between_two_strings(string1=string1, string2=string2,
                                                             regexp=slot_regexp, log_info='Slot {}'.format(log_info))
    if not slot_are_the_same:
        return False

    return True


def __compare_rnti_pattern_id_values_between_two_string(string1, string2, log_info='NoMsgInfo'):
    rnti_regexp = BuiltIn().get_variable_value('${RNTI_UINT16_REGEXP}')
    pattern_id_0_regexp = BuiltIn().get_variable_value('${PATTERN_ID_ITEM_0_UINT16_REGEXP}')

    rnti_the_same = __compare_values_between_two_strings(string1=string1, string2=string2,
                                                         regexp=rnti_regexp,
                                                         log_info='Rnti {}'.format(log_info))
    if not rnti_the_same:
        return False
    pattern_id_the_same = __compare_values_between_two_strings(string1=string1, string2=string2,
                                                               regexp=pattern_id_0_regexp,
                                                               log_info='PatternId {}'.format(log_info))
    if not pattern_id_the_same:
        return False

    return True


def __compare_start_num_of_prb_values_between_two_string(string1, string2, log_info='NoMsgInfo'):
    start_prb_regexp = BuiltIn().get_variable_value('${START_PRB_UINT16_REGEXP}')
    num_of_prb_regexp = BuiltIn().get_variable_value('${NUM_OF_PRB_UINT16_REGEXP}')

    start_prb_the_same = __compare_values_between_two_strings(string1=string1, string2=string2,
                                                              regexp=start_prb_regexp,
                                                              log_info='StartPrb {}'.format(log_info))
    if not start_prb_the_same:
        return False
    num_of_prb_the_same = __compare_values_between_two_strings(string1=string1, string2=string2,
                                                               regexp=num_of_prb_regexp,
                                                               log_info='NumOfPrb {}'.format(log_info))
    if not num_of_prb_the_same:
        return False

    return True


def __split_pdcch_between_two_dci_info_items(pdcch_string):
    dci_info_item = BuiltIn().get_variable_value('${DCI_INFO_ITEM_TEXT}')
    splitted = pdcch_string.split(dci_info_item)
    return splitted[1:]  # returning without not needed info above dci_info_items


def ensure_pdsch_pdcch_send_req_f_mu_mimo_bip_contain_correct_values():
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console("Ensuring PDSCH PDCCH Send Req contain correct values for -F MU MIMO in: {}".format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    stream_list = convert_enum_to_list(enum=stream, without_first_elem=True)

    i = 0
    while i < len(stream_list):
        pdsch_send_req_1 = stream_list[i + 0]
        pdsch_send_req_2 = stream_list[i + 1]
        pdcch_send_req = stream_list[i + 2]
        i += 3

        if __strings_does_not_contain_correct_order_pdsch_pdcch_send_req_msgs(expected_pdsch_1=pdsch_send_req_1,
                                                                              expected_pdsch_2=pdsch_send_req_2,
                                                                              expected_pdcch=pdcch_send_req):
            continue

        sfn_slot_the_same = __compare_sfn_slot_values_between_two_strings(string1=pdsch_send_req_1,
                                                                          string2=pdsch_send_req_2,
                                                                          log_info='Pdsch_1, Pdsch_2')
        if not sfn_slot_the_same:
            continue

        sfn_slot_the_same = __compare_sfn_slot_values_between_two_strings(string1=pdsch_send_req_1,
                                                                          string2=pdcch_send_req,
                                                                          log_info='Pdsch_1, Pdcch')
        if not sfn_slot_the_same:
            continue

        dci_info_items = __split_pdcch_between_two_dci_info_items(pdcch_string=pdcch_send_req)
        if len(dci_info_items) < 2:
            continue

        rnti_pattern_id_the_same = __compare_rnti_pattern_id_values_between_two_string(string1=pdsch_send_req_1,
                                                                                       string2=dci_info_items[0],
                                                                                       log_info='Pdsch_1, dci_info_0')
        if not rnti_pattern_id_the_same:
            continue

        rnti_pattern_id_the_same = __compare_rnti_pattern_id_values_between_two_string(string1=pdsch_send_req_2,
                                                                                       string2=dci_info_items[1],
                                                                                       log_info='Pdsch_2, dci_info_1')
        if not rnti_pattern_id_the_same:
            continue

        start_num_prb_the_same = __compare_start_num_of_prb_values_between_two_string(string1=pdsch_send_req_1,
                                                                                      string2=pdsch_send_req_2,
                                                                                      log_info='Pdsch_1, Pdsch_2')
        if not start_num_prb_the_same:
            continue

        break


def ensure_pdsch_send_req_e_dss_enabled_bip_contain_correct_values():
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console("Ensuring PDSCH PDCCH Send Req contain correct values for -E DSS Enabled in: {}".format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    stream_list = convert_enum_to_list(enum=stream, without_first_elem=True)

    slot_regexp = BuiltIn().get_variable_value('${SLOT_UINT8_REGEXP}')
    slots_used = BuiltIn().get_variable_value('${SLOTS_USED_E_DSS_ENABLED}')

    start_prb_regexp = BuiltIn().get_variable_value('${START_PRB_UINT16_REGEXP}')
    num_of_prb_regexp = BuiltIn().get_variable_value('${NUM_OF_PRB_UINT16_REGEXP}')
    start_prb_expected = BuiltIn().get_variable_value('${START_PRB_VALUE_EXPECTED_E_DSS_ENABLED}')
    num_of_prb_expected = BuiltIn().get_variable_value('${NUM_OF_PRB_VALUE_EXPECTED_E_DSS_ENABLED}')

    for bip_msg in stream_list:
        if not __string_contain_pdsch_send_req_msg(expected_pdsch=bip_msg):
            continue

        slot_match = regexp_in_string_exists(string=bip_msg, regexp=slot_regexp)
        slot_value = slot_match.group("VALUE")

        if not (slot_value in slots_used):
            msg = 'Wrong slot {} found in PdschSendReq! Slots used: {}'.format(slot_value, slots_used)
            logger_warning(msg)
            raise NotExpectedSlotInPdschSendReqException(msg)

        # start_prb_match = regexp_in_string_exists(string=bip_msg, regexp=start_prb_regexp)
        # start_prb_value = start_prb_match.group("VALUE")
        #
        # num_of_prb_match = regexp_in_string_exists(string=bip_msg, regexp=num_of_prb_regexp)
        # num_of_prb_value = num_of_prb_match.group("VALUE")
        #
        # if start_prb_value != start_prb_expected:
        #     msg = 'Wrong start prb {} found in PdschSendReq! Expected: {}'.format(start_prb_value, start_prb_expected)
        #     logger_warning(msg)
        #     raise WrongStartPrbValueInPdschSendReqException(msg)
        #
        # if num_of_prb_value != num_of_prb_expected:
        #     msg = 'Wrong num of prb {} found in PdschSendReq! Exp: {}'.format(num_of_prb_value, num_of_prb_expected)
        #     logger_warning(msg)
        #     raise WrongNumOfPrbValueInPdschSendReqException(msg)
