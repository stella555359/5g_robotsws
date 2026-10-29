# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:maintainer: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import os
from collections import defaultdict

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem

from testsuite.Krakow.RRM.Airphone.resources.Python.mcshark_management import download_mcshark_if_not_present
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import check_file_exists, get_latest_file
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console, logger_warning, \
    logger_console_info
from testsuite.Krakow.RRM.Airphone.resources.Python.bip_management import create_tshark_command
from testsuite.Krakow.RRM.Airphone.resources.Python.pcap_validation import get_message_value_from_frame, \
    convert_pcap_to_json_using_tshark, read_json_file

from testsuite.Krakow.RRM.Airphone.resources.Python.slice_scheduling.validation_txt import (
    ensure_it_is_file_stream, convert_enum_to_list, regexp_in_string_exists,
    regexp_item_in_stream, map_item_id_to_its_content, split_by_regexp
)


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


class StreamDoesNotContainLineException(Exception):
    pass


class QuotasOtherThanExpectedException(Exception):
    pass


class NotExistingCellGivenException(Exception):
    pass


class NotExistingSliceListGivenException(Exception):
    pass


class NotExistingCellSetupReqTxtFileException(Exception):
    pass


class CellGroupIdDoesNotEqualToCellIdException(Exception):
    pass


class SdInBipDoesNotMatchScfException(Exception):
    pass


class NoSliceListInCellSetupReqException(Exception):
    pass


class NotExistingResourceGroupListGivenException(Exception):
    pass


class NoResourceGroupListInCellSetupReqException(Exception):
    pass


class NrgIdOtherThanExpectedException(Exception):
    pass


class PlmnOtherThanExpectedException(Exception):
    pass


class ResourceGroupIdOtherThanExpected(Exception):
    pass


class DifferentNumberOfUesAndExpectedValuesException(Exception):
    pass


class DifferntSpidValuesThanExpectedInSgnbAdditionRequest(Exception):
    pass


def __save_pcap_to_txt(output_dir, prefix, pcap_path, using_mcshark, filter):
    output_path = os.path.join(output_dir, prefix + '.txt')
    tshark = create_tshark_command(bip_pcap_file=pcap_path, using_mcshark=using_mcshark, filter_mode=filter,
                                   luashark_path=None, output_path=output_path)
    OperatingSystem().run(tshark)
    return output_path


def __look_for_pcap_file(output_dir, pattern, using_mcshark, filter):
    try:
        latest_bip = get_latest_file(os.path.join(output_dir, pattern))
        if latest_bip is None:
            return None
    except ValueError:
        return None
    logger_console('Decoding {} file to txt format and checking if {} returns sth...'.format(latest_bip, filter))
    output = __save_pcap_to_txt(output_dir=output_dir, prefix='testfile',
                                pcap_path=latest_bip,
                                using_mcshark=using_mcshark,
                                filter=filter)
    if check_file_exists(output):
        logger_console('Returning pcap with filter {}: {}'.format(filter, latest_bip))
        return latest_bip
    logger_console('{} does not contain any msg with filter {}!'.format(latest_bip, filter))
    return None


def __get_latest_collected_bip(output_dir, using_mcshark, filter):
    patterns = ['p_*.pcap', '0_*.pcap', '1_*.pcap', '2_*.pcap', 'bip.pcap', '*.pcap']
    for p in patterns:
        found_bip_path = __look_for_pcap_file(output_dir=output_dir, pattern=p,
                                              using_mcshark=using_mcshark, filter=filter)
        if found_bip_path is not None:
            return found_bip_path
    raise NotExistingTxtBipFileWithFilterException('Could not find bip file with filter {}!'.format(filter))


def save_filtered_pcap_to_txt_file(output_dir, prefix, using_mcshark, pcap_path=None, filter=''):
    if not pcap_path:
        pcap_path = __get_latest_collected_bip(output_dir=output_dir, using_mcshark=using_mcshark, filter=filter)
    if using_mcshark:
        download_mcshark_if_not_present()
    output_path = __save_pcap_to_txt(output_dir=output_dir, prefix=prefix, pcap_path=pcap_path,
                                     using_mcshark=using_mcshark, filter=filter)
    BuiltIn().set_suite_variable('${BIP_TXT_OUTPUT_PATH}', output_path)


def ensure_decoded_txt_file_exists():
    txt = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    exists = check_file_exists(txt)
    if not exists:
        raise NotExistingTxtBipFileWithFilterException(
            'File does not contain any data {}!'.format(txt)
        )


def set_output_dir_tc():
    BuiltIn().set_suite_variable('${OUTPUT_DIR_TC}', '/home/ute/logs/E_9084')
    BuiltIn().set_suite_variable('${BIP_TXT_OUTPUT_PATH}', '/home/ute/logs/E_9084/dldata_pdsch_pdcch_send_req.txt')


def __strings_does_not_contain_correct_order_pdsch_pdcch_send_req_msgs(expected_pdsch_1, expected_pdsch_2,
                                                                       expected_pdcch):
    pdsch_send_req_text = BuiltIn().get_variable_value('${DLDATA_PDSCHSENDREQ_TEXT}')
    pdcch_send_req_text = BuiltIn().get_variable_value('${DLDATA_PDCCHSENDREQ_TEXT}')
    if regexp_in_string_exists(string=expected_pdsch_1, text=pdsch_send_req_text, raise_exception=False) and \
            regexp_in_string_exists(string=expected_pdsch_2, text=pdsch_send_req_text, raise_exception=False) and \
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
    value_1 = match_1.group('VALUE')

    match_2 = regexp_in_string_exists(string=string2, regexp=regexp)
    value_2 = match_2.group('VALUE')

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
    logger_console('Ensuring PDSCH PDCCH Send Req contain correct values for -F MU MIMO in: {}'.format(bip_path))
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
    logger_console('Ensuring PDSCH PDCCH Send Req contain correct values for -E DSS Enabled in: {}'.format(bip_path))
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
        slot_value = slot_match.group('VALUE')

        if not (slot_value in slots_used):
            msg = 'Wrong slot {} found in PdschSendReq! Slots used: {}'.format(slot_value, slots_used)
            logger_warning(msg)
            raise NotExpectedSlotInPdschSendReqException(msg)


def get_cell_group_ids():
    stream = ensure_it_is_file_stream(
        BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}'), 'icom_5g'
    )
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    grp_ids = regexp_item_in_stream(
        regexp=BuiltIn().get_variable_value('${VALID_BIP_CELLGRP_ID_REGEXP}'),
        stream=cellsetupreq_msgs,
        item='CELLGRP_ID',
    )
    logger_console('Retrieved CellGrpIDs {}'.format(grp_ids))
    return grp_ids


def ensure_cell_ids_consists_of_the_same_cellgrp_ids(cell=None, grp_ids=None):
    if grp_ids is None:
        grp_ids = get_cell_group_ids()
    if cell is None:
        cells = [1, 2]
    elif isinstance(cell, str):
        cells = [int(cell)]

    for cell_id in cells:
        cell_id = validate_given_cell(cell_id)
        try:
            cellgrp_id = grp_ids[cell_id]
        except IndexError:
            msg = 'CellGroup with Index {} does not exist in list {}!'.format(
                cell_id, grp_ids
            )
            raise CellGroupIdDoesNotEqualToCellIdException(msg)
        if str(cellgrp_id) != str(cell_id):
            msg = 'CellGroupID does not equal to given Cell ID: {} != {}'.format(
                cellgrp_id, cell_id
            )
            raise CellGroupIdDoesNotEqualToCellIdException(msg)
    logger_console('Cell Ids are the same as the Cell Group Ids!')


def ensure_slice_aware_scheduler_is_activated():
    """There is no need for first elem in list, as it contains no necessary data. Then we
    parse concrete string with msg for given cell.
    """
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring Slice Aware Scheduler exists in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    regexp_in_string_exists(
        text=BuiltIn().get_variable_value('${VALID_BIP_FEATURE_ACTIVATED}'),
        string=cellsetupreq_msgs[cell],
    )
    logger_console('Found feature activated on cell {}'.format(cell))


def __retrieve_slice_list(string_list, cell_id=0, slice_list_id=0):
    """Assuming that there is only 2 slice list, split returns 3 items,
    where 1-index and 2-index returns correct slice lists
    2-nd slice list contains too much data, so we delete not needed data
    """
    split = BuiltIn().get_variable_value('${VALID_BIP_SLICE_LIST_SPLIT_TEXT}')
    string = string_list[cell_id]
    if split not in string:
        msg = 'There is no slice list in given cellsetupreq for cell {}!'.format(
            cell_id
        )
        raise NoSliceListInCellSetupReqException(msg)
    splitted = string.split(split)
    return (
        splitted[slice_list_id + 1][:800]
        if slice_list_id == 1
        else splitted[slice_list_id + 1]
    )


def __retrieve_quotas_from_slice_list(slice_list):
    match_minquota = regexp_in_string_exists(
        regexp=BuiltIn().get_variable_value('${VALID_BIP_MINQUOTA_REGEXP}'),
        string=slice_list,
    )
    match_maxquota = regexp_in_string_exists(
        regexp=BuiltIn().get_variable_value('${VALID_BIP_MAXQUOTA_REGEXP}'),
        string=slice_list,
    )
    return {
        'min': match_minquota.group('MINQUOTA'),
        'max': match_maxquota.group('MAXQUOTA'),
    }


def ensure_quotas_contain_correct_values(expected_quotas, slice_list_id=1):
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    slice_list_id = validate_given_slice_list(slice_list_id)
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring Quotas contain correct values in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    slice_list = __retrieve_slice_list(
        string_list=cellsetupreq_msgs, cell_id=cell, slice_list_id=slice_list_id
    )
    actual_quotas = __retrieve_quotas_from_slice_list(slice_list)
    validate_single_quotas(
        actual=actual_quotas, expected=expected_quotas[slice_list_id]
    )


def __retrieve_sd_values_from_slice_list(slice_list):
    sd_regexps = BuiltIn().get_variable_value('${VALID_BIP_SD_REGEXPS}')
    rtn = []
    for regexp in sd_regexps:
        match = regexp_in_string_exists(regexp=regexp, string=slice_list)
        rtn.append(match.group('SDVALUE'))
    logger_console('Found sd values: {}'.format(rtn))
    return rtn


def __dec2hex(val):
    return str(hex(int(val)))


def __hex2dec(val):
    return str(int(val, 16))


def __compose_sd_value(sd_values):
    sd_hex = ''
    sd_hex += __dec2hex(sd_values[0])
    sd_hex += __dec2hex(sd_values[1]).replace('0x', '')
    sd_hex += __dec2hex(sd_values[2]).replace('0x', '')
    sd_dec = __hex2dec(sd_hex)
    logger_console('Composed sd value in hex: {}, dec: {}'.format(sd_hex, sd_dec))
    return sd_dec


def ensure_sd_has_values_as_in_scf(expected_sd, slice_list_id=0):
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    slice_list_id = validate_given_slice_list(slice_list_id)
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console(
        'Ensuring sd from bip has the same values as in SCF: {}'.format(bip_path)
    )
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    slice_list = __retrieve_slice_list(
        string_list=cellsetupreq_msgs, cell_id=cell, slice_list_id=slice_list_id
    )
    sd_values = __retrieve_sd_values_from_slice_list(slice_list)
    sd = __compose_sd_value(sd_values)
    if sd != expected_sd[slice_list_id]:
        msg = 'sd not matching in bip! actual: {} expected: {}'.format(
            sd, expected_sd[slice_list_id]
        )
        raise SdInBipDoesNotMatchScfException(msg)
    logger_console('sd values are the same either in bip as in scf!')


def validate_single_quotas(actual, expected):
    msg = 'Min Expected: {}; Min Actual: {}\nMax Expected: {}; Max Actual: {}'.format(
        expected['min'], actual['min'], expected['max'], actual['max']
    )
    if actual['min'] == expected['min'] and actual['max'] == expected['max']:
        logger_console('Quotas equal to expected:\n' + msg)
        return

    raise QuotasOtherThanExpectedException('Quotas different from expected:\n' + msg)


def validate_given_cell(cell):
    proper_cells = [1, 2, 3, 4]
    cell = int(cell)
    if cell is None or cell not in proper_cells:
        msg = 'Passed cell ID {}, which does not exist, use {}'.format(cell, proper_cells)
        raise NotExistingCellGivenException(msg)
    return cell


def validate_given_slice_list(slice_list, decrease_value=False):
    proper_lists = [0, 1, 2, 3]
    slice_list = int(slice_list)
    if decrease_value:
        slice_list -= 1
    if slice_list not in proper_lists:
        msg = 'Passed slice list num {}, which does not exist, use {}'.format(slice_list, proper_lists)
        raise NotExistingSliceListGivenException(msg)
    return slice_list


def ensure_quotas_contain_correct_values_nsa(expected_quotas):
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring Quotas contain correct values in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    rg_mapping = __retrieve_resource_group_id_to_content_mapping(
        cell_setups=cellsetupreq_msgs, cell_id=cell
    )
    actual_quotas = __retrieve_quotas_from_resource_groups(rg_mapping)
    for resource_group_id in expected_quotas.keys():
        validate_single_quotas(
            actual=actual_quotas[resource_group_id], expected=expected_quotas[resource_group_id]
        )


def validate_given_resource_group_list(resource_group_list, decrease_value=False):
    proper_lists = [0, 1, 2, 3]
    resource_group_list = int(resource_group_list)
    if decrease_value:
        resource_group_list -= 1
    if resource_group_list not in proper_lists:
        msg = 'Passed resourcegroup list num {}, which does not exist, use {}'.format(resource_group_list, proper_lists)
        raise NotExistingResourceGroupListGivenException(msg)
    return resource_group_list


def __retrieve_resource_group_id_to_content_mapping(cell_setups, cell_id=1):
    rg_text = BuiltIn().get_variable_value('${VALID_BIP_RESOURCE_GROUP_LIST_SPLIT_TEXT}')
    single_cell_setup_content = cell_setups[cell_id]
    if rg_text not in single_cell_setup_content:
        msg = 'There is no resource group list in given cellsetupreq for cell {}!'.format(
            cell_id
        )
        raise NoResourceGroupListInCellSetupReqException(msg)
    splitted = single_cell_setup_content.split(rg_text)[1:]
    splitted[-1] = splitted[-1][:800]
    splitted = map_item_id_to_its_content(splitted,
                                          BuiltIn().get_variable_value('${VALID_BIP_NRG_ID_REGEXP}'))
    return splitted


def __retrieve_quotas_from_resource_groups(resource_groups_mapping):
    quotas = {}
    for id, content in resource_groups_mapping.items():
        match_minquota = regexp_in_string_exists(
            regexp=BuiltIn().get_variable_value('${VALID_BIP_MINQUOTA_REGEXP}'),
            string=content,
        )
        match_maxquota = regexp_in_string_exists(
            regexp=BuiltIn().get_variable_value('${VALID_BIP_MAXQUOTA_REGEXP}'),
            string=content,
        )
        quotas[id] = {
            'min': match_minquota.group('MINQUOTA'),
            'max': match_maxquota.group('MAXQUOTA'),
        }
    return quotas


def ensure_nrg_ids_are_correct(expected_resource_group_ids):
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring NRG ID contain correct value in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    resource_group_id_to_content_map = __retrieve_resource_group_id_to_content_mapping(
        cell_setups=cellsetupreq_msgs, cell_id=cell
    )
    actual_nrg_ids = resource_group_id_to_content_map.keys()
    for expected_id in expected_resource_group_ids:
        validate_single_nrg_id(
            actual_ids_list=actual_nrg_ids, expected=expected_id
        )


def validate_single_nrg_id(actual_ids_list, expected):
    msg = 'Expected ID: {}; Actual IDs: {}'.format(expected, actual_ids_list)
    if int(expected) in actual_ids_list:
        logger_console('NSA Resource Group present: {}'.format(expected))
        return
    raise NrgIdOtherThanExpectedException('NSA Resource Group not in expected:\n' + msg)


def ensure_plmns_contain_correct_values_in_nrg(expected_plmns):
    logger_console('Expected PLMN: {}'.format(expected_plmns))
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring PLMN contain correct values in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    resource_group_id_to_content_map = __retrieve_resource_group_id_to_content_mapping(
        cell_setups=cellsetupreq_msgs, cell_id=cell
    )
    actual_plmns = __retrieve_plmns_from_resource_group_list(resource_group_id_to_content_map)
    for resource_group_id in resource_group_id_to_content_map.keys():
        decoded_plmn = __decode_plmn_from_bip(actual_plmns[resource_group_id])
        validate_single_plmn(
            actual=decoded_plmn, expected=expected_plmns[resource_group_id]
        )


def __retrieve_plmns_from_resource_group_list(resource_groups_mapping):
    plmns = {}
    for id, content in resource_groups_mapping.items():
        match_mcc = regexp_in_string_exists(
            regexp=BuiltIn().get_variable_value('${VALID_BIP_MCC_REGEXP}'),
            string=content,
        )
        match_mnc = regexp_in_string_exists(
            regexp=BuiltIn().get_variable_value('${VALID_BIP_MNC_REGEXP}'),
            string=content,
        )
        match_mnc_length = regexp_in_string_exists(
            regexp=BuiltIn().get_variable_value('${VALID_BIP_MNC_LENGTH_REGEXP}'),
            string=content,
        )
        plmns[id] = {
            'first_encoded_number': match_mcc.group('FIRST_ENCODED_NUMBER'),
            'second_encoded_number': match_mnc.group('SECOND_ENCODED_NUMBER'),
            'third_encoded_number': match_mnc_length.group('THIRD_ENCODED_NUMBER'),
        }
    return plmns


def __decode_plmn_from_bip(plmn):
    first_encoded_number = str(bin(int(plmn['first_encoded_number']))).replace('0b', '').rjust(8, '0')
    second_encoded_number = str(bin(int(plmn['second_encoded_number']))).replace('0b', '').rjust(8, '0')
    third_encoded_number = str(bin(int(plmn['third_encoded_number']))).replace('0b', '').rjust(8, '0')
    digits = [first_encoded_number[max(0, i - 4):i] for i in range(len(first_encoded_number), 0, -4)]
    digits += [second_encoded_number[max(0, i - 4):i] for i in range(len(second_encoded_number), 0, -4)]
    digits += [third_encoded_number[max(0, i - 4):i] for i in range(len(third_encoded_number), 0, -4)]
    mcc_and_mnc = ''
    for digit in digits:
        if digit != '1111':
            mcc_and_mnc += str(int(digit, 2))

    return {
        'mcc': mcc_and_mnc[0:3].lstrip('0').rjust(1, '0'),
        'mnc': mcc_and_mnc[3:].lstrip('0').rjust(1, '0'),
        'mnc_length': '3' if len(mcc_and_mnc) == 6 else '2'
    }


def validate_single_plmn(actual, expected):
    msg = 'Expected: {}:{}:{}; Actual: {}:{}:{}'.format(
        expected['mcc'], expected['mnc'], expected['mnc_length'], actual['mcc'], actual['mnc'], actual['mnc_length']
    )
    if actual['mcc'] == expected['mcc'] and actual['mnc'] == expected['mnc'] and \
            actual['mnc_length'] == expected['mnc_length']:
        logger_console('PLMN equal to expected:\n' + msg)
        return
    raise PlmnOtherThanExpectedException('PLMN different from expected:\n' + msg)


def ensure_default_nrg_id_contain_correct_value(expected_default_nrg_ids):
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring default NRG ID contain correct value in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    plmn_configs_list = __retrieve_plmn_configs_list(cellsetupreq_msgs, cell)
    actual_default_nrg_ids = __retrieve_default_nrg_ids_from_plmn_config_list(plmn_configs_list)
    msg = 'Wrong number of default NRGs! Expected: {}, actual: {}'.format(expected_default_nrg_ids,
                                                                          actual_default_nrg_ids)
    assert len(actual_default_nrg_ids) == len(expected_default_nrg_ids), msg
    for expected_default_nrg_id in expected_default_nrg_ids:
        validate_single_nrg_id(
            actual_ids_list=actual_default_nrg_ids, expected=expected_default_nrg_id
        )


def __retrieve_default_nrg_ids_from_plmn_config_list(plmn_configs_list):
    default_nrg_ids = []
    for plmn_content in plmn_configs_list:
        match_default_nrg_id = regexp_in_string_exists(
            regexp=BuiltIn().get_variable_value('${VALID_BIP_DEFAULT_NRG_ID_REGEXP}'),
            string=plmn_content,
        )
        default_nrg_ids.append(int(match_default_nrg_id.group('DEFAULT_NRG_ID')))
    return default_nrg_ids


def ensure_spid_based_slicing_is_correct(activated=True):
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring SPID based slicing exists in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    if activated:
        regexp_in_string_exists(
            text='{}True'.format(BuiltIn().get_variable_value('${VALID_BIP_FEATURE_8746_ACTIVATED}')),
            string=cellsetupreq_msgs[cell],
        )
    else:
        regexp_in_string_exists(
            text='{}False'.format(BuiltIn().get_variable_value('${VALID_BIP_FEATURE_8746_ACTIVATED}')),
            string=cellsetupreq_msgs[cell],
        )
    logger_console('Validation of feature activation flag in CellSetupReq passed')


def ensure_nsaresourcegroup_not_set_in_plmnconfig():
    cell = validate_given_cell(
        BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')
    )
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring nsaResourceGroup is not set in plmnConfig in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    cellsetupreq_msgs = map_item_id_to_its_content(cellsetupreq_msgs,
                                                   BuiltIn().get_variable_value('${VALID_BIP_CELL_ID_REGEXP}'))
    plmn_configs_list = __retrieve_plmn_configs_list(cellsetupreq_msgs, cell)
    for plmn_content in plmn_configs_list:
        regexp_in_string_exists(
            regexp='{}'.format(BuiltIn().get_variable_value('${VALID_BIP_NSA_RESOURCE_GRP_IN_PLMN_REGEXP}')),
            string=plmn_content,
        )


def __retrieve_plmn_configs_list(cell_setups, cell_id=1):
    plmn_text = BuiltIn().get_variable_value('${VALID_BIP_PLMN_CONFIG_ID_REGEXP}')
    single_cell_setup_content = cell_setups[cell_id]
    splitted = split_by_regexp(plmn_text, single_cell_setup_content)
    if len(splitted) == 1:
        msg = 'There is no plmn config list in given cellsetupreq for cell {}!'.format(cell_id)
        raise NoResourceGroupListInCellSetupReqException(msg)
    splitted = splitted[1:]
    splitted[-1] = splitted[-1][:2500]
    return splitted


def ensure_resourcegroupid_not_set_in_usersetupreq(ues=None):
    if ues is None:
        ues = [11]
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring resourceGroupId is not set in userSetupReq msg for UEs {} in: {}'.format(ues, bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    usersetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    for ue in ues:
        regexp_in_string_exists(
            regexp='{}'.format(BuiltIn().get_variable_value('${VALID_BIP_EMPTY_RESOURCE_GROUP_ID_REGEXP}')),
            string=usersetupreq_msgs[ue - 11],
        )


def __retrieve_nrg_ids_from_usersetupreq_msg(usersetupreq_msgs):
    match_nrg_ids = list()
    for msg in usersetupreq_msgs:
        if regexp_in_string_exists(
                regexp=BuiltIn().get_variable_value('${VALID_BIP_EMPTY_RESOURCE_GROUP_ID_REGEXP}'),
                string=msg, raise_exception=False):
            match_nrg_ids.append(None)
        else:
            match_nrg_id = regexp_in_string_exists(
                regexp=BuiltIn().get_variable_value('${VALID_BIP_RESOURCE_GROUP_ID_REGEXP}'),
                string=msg)
            match_nrg_ids.append(int(match_nrg_id.group('NRGID')))
    return match_nrg_ids


def ensure_resourcegroupid_properly_set_in_usersetupreq(ues, expected_nrg_ids):
    if not isinstance(expected_nrg_ids, list) or len(ues) != len(expected_nrg_ids):
        msg = "Expected_nrg_ids parameter's length should be equal to number_of_ues parameter's length"
        raise DifferentNumberOfUesAndExpectedValuesException(msg)
    bip_path = BuiltIn().get_variable_value('${BIP_TXT_OUTPUT_PATH}')
    logger_console('Ensuring NSA resource group ID fields contain correct values in: {}'.format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, 'icom_5g')
    usersetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    actual_nrg_ids = __retrieve_nrg_ids_from_usersetupreq_msg(usersetupreq_msgs=usersetupreq_msgs)
    for i in range(0, len(ues)):
        if expected_nrg_ids[i] is None:
            ensure_resourcegroupid_not_set_in_usersetupreq(ues=[ues[i]])
        elif actual_nrg_ids[i] != expected_nrg_ids[i]:
            msg = 'Resource group ID {} other than expected: {} for UE-{}'.format(actual_nrg_ids[i],
                                                                                  expected_nrg_ids[i], ues[i])
            raise ResourceGroupIdOtherThanExpected(msg)


def __retrieve_spid_values_from_sgnb_addition_request_msg(msgs):
    match_spid_values = list()
    for msg in msgs:
        regexp = BuiltIn().get_variable_value('${VALID_UE_CONTEXT_SETUP_REGEXP}')
        match_spid_values.append(int(regexp_in_string_exists(regexp=regexp, string=msg).group('SPID')))
    return match_spid_values


def validate_ue_context_setup(expected_spid_values):
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR_TC}') + '/NG'
    pcap_path = get_latest_file(os.path.join(output_dir, '*.pcap'))
    logger_console('Ensuring SubscriberProfileIDforRFP field is properly set in sgnb addition request')
    logs_path = __save_pcap_to_txt(output_dir=output_dir,
                                   prefix=BuiltIn().get_variable_value('${NG_LINK_MSG_UE_CONTEXT_SETUP}'),
                                   pcap_path=pcap_path,
                                   using_mcshark=True,
                                   filter=BuiltIn().get_variable_value('${NG_LINK_FILTER_UE_CONTEXT_SETUP}'))
    stream = ensure_it_is_file_stream(logs_path, ': id-SubscriberProfileIDforRFP\n')
    sgnb_addition_req_msgs = convert_enum_to_list(enum=stream)
    sgnb_addition_req_msgs = sgnb_addition_req_msgs[1:]
    sgnb_addition_req_msgs = [sgnb_addition_req_msgs[i][:400] for i in range(0, len(sgnb_addition_req_msgs))]
    actual_spid_values = __retrieve_spid_values_from_sgnb_addition_request_msg(sgnb_addition_req_msgs)
    if expected_spid_values != actual_spid_values:
        msg = 'Actual: {}, expected: {}'.format(actual_spid_values, expected_spid_values)
        raise DifferntSpidValuesThanExpectedInSgnbAdditionRequest(msg)


def extract_cellsetupreq_data_from_syscom_message(syscom_packet):
    cellsetupreq_data_structure = ["itf_l2_ps_cell_cellsetupreq",
                                   ("itf_l2_ps_cell_CellSetupReq_t.lcrId",),
                                   ("ulResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_QuotasConfig.minQuota",),
                                   ("ulResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_QuotasConfig.maxQuota",),
                                   ("dlResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_QuotasConfig.minQuota",),
                                   ("dlResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_QuotasConfig.maxQuota",),
                                   ("dlResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_DefaultResourceGroup.defaultResourceGroupId",),
                                   ("dlResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_DefaultResourceGroup.resourceGroupId",),
                                   ("ulResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_DefaultResourceGroup.defaultResourceGroupId",),
                                   ("ulResourceGroupConfig (StaticVariableSizedArray)",
                                    "itf_DefaultResourceGroup.resourceGroupId",),
                                   ]
    cellsetupreq_data_values = get_message_value_from_frame(syscom_packet,
                                                            unique_field=cellsetupreq_data_structure[0],
                                                            list_of_next_unique_field=cellsetupreq_data_structure[
                                                                                      1:])
    try:
        lcr_id = int(cellsetupreq_data_values[0])
    except ValueError:
        logger_console_info('Provided syscom packet does not contain cellsetupreq message!')
        raise
    cellsetupreq_info = {lcr_id: {'dl_rgs_quotas': {}, 'ul_rgs_quotas': {},
                                  'dl_default_rgs': set(), 'dl_default_rgs_mapping': {},
                                  'ul_default_rgs': set(), 'ul_default_rgs_mapping': {}}}
    for id, ul_quotas in enumerate(zip(cellsetupreq_data_values[1], cellsetupreq_data_values[2]), 1):
        min_quota, max_quota = ul_quotas
        cellsetupreq_info[lcr_id]['ul_rgs_quotas'].update({id: (int(min_quota), int(max_quota))})
    for id, dl_quotas in enumerate(zip(cellsetupreq_data_values[3], cellsetupreq_data_values[4]), 1):
        min_quota, max_quota = dl_quotas
        cellsetupreq_info[lcr_id]['dl_rgs_quotas'].update({id: (int(min_quota), int(max_quota))})
    for internal_default_rg_id, real_rg_id in zip(cellsetupreq_data_values[5], cellsetupreq_data_values[6]):
        cellsetupreq_info[lcr_id]['dl_default_rgs_mapping'][int(internal_default_rg_id)] = int(real_rg_id)
    cellsetupreq_info[lcr_id]['dl_default_rgs'].update(
        list(cellsetupreq_info[lcr_id]['dl_default_rgs_mapping'].values()))
    for internal_default_rg_id, real_rg_id in zip(cellsetupreq_data_values[7], cellsetupreq_data_values[8]):
        cellsetupreq_info[lcr_id]['ul_default_rgs_mapping'][int(internal_default_rg_id)] = int(real_rg_id)
    cellsetupreq_info[lcr_id]['ul_default_rgs'].update(
        list(cellsetupreq_info[lcr_id]['ul_default_rgs_mapping'].values()))
    return cellsetupreq_info


def extract_cellsetupreq_info_from_pcap(pcap_path, output_dir=None, output_filename=None):
    json_file = convert_pcap_to_json_using_tshark(pcap_path, output_dir=output_dir, output_filename=output_filename,
                                                  message_filter="itf_l2_ps_cell_cellsetupreq")
    packets = read_json_file(json_file)
    cellsetupreq_info = {}
    for packet in packets:
        cellsetupreq_info.update(extract_cellsetupreq_data_from_syscom_message(packet))
    return cellsetupreq_info


def extract_cellsetupreq_data_from_sas_delta_dict(sas_delta_dict: dict, rg_profile_grp=None):
    cellsetupreq_info_for_cells = {}
    for cell_id in sas_delta_dict["cellDepType"].keys():
        cellsetupreq_info_for_cells[cell_id] = {'dl_rgs_quotas': {}, 'ul_rgs_quotas': {}, 'dl_default_rgs': set(),
                                                'ul_default_rgs': set()}
    for cell_id, rg_prof_grp in sas_delta_dict['RG_profile_grp'].items():
        if 'DL' in rg_prof_grp.keys():
            if rg_profile_grp is None:
                for rg_id, quotas in enumerate(zip(sas_delta_dict["minQuotas"], sas_delta_dict["maxQuotas"]), 1):
                    cellsetupreq_info_for_cells[cell_id]['dl_rgs_quotas'][rg_id] = quotas
            else:
                for rg_id, quotas in enumerate(
                        zip(sas_delta_dict["minQuotas"][rg_profile_grp], sas_delta_dict["maxQuotas"][rg_profile_grp]),
                        1):
                    cellsetupreq_info_for_cells[cell_id]['dl_rgs_quotas'][rg_id] = quotas

            plmn_to_rg_mapping = sas_delta_dict["defaultRG"][rg_prof_grp['DL']]
            for rg in plmn_to_rg_mapping.values():
                cellsetupreq_info_for_cells[cell_id]['dl_default_rgs'].update(rg.values())

        if 'UL' in rg_prof_grp.keys():
            if rg_profile_grp is None:
                for rg_id, quotas in enumerate(zip(sas_delta_dict["minQuotas"], sas_delta_dict["maxQuotas"]), 1):
                    cellsetupreq_info_for_cells[cell_id]['ul_rgs_quotas'][rg_id] = quotas
            else:
                for rg_id, quotas in enumerate(
                        zip(sas_delta_dict["minQuotas"][rg_profile_grp], sas_delta_dict["maxQuotas"][rg_profile_grp]),
                        1):
                    cellsetupreq_info_for_cells[cell_id]['ul_rgs_quotas'][rg_id] = quotas

            plmn_to_rg_mapping = sas_delta_dict["defaultRG"][rg_prof_grp['UL']]
            for rg in plmn_to_rg_mapping.values():
                cellsetupreq_info_for_cells[cell_id]['ul_default_rgs'].update(rg.values())
    return cellsetupreq_info_for_cells


def check_cellsetupreq_has_proper_values(pcap_file_path, sas_delta_dict, cell_id, rg_profile_grp=None):
    cellsetupreq_info_from_pcap = extract_cellsetupreq_info_from_pcap(pcap_file_path, '/tmp/')[cell_id]
    cellsetupreq_info_from_delta_dict = extract_cellsetupreq_data_from_sas_delta_dict(sas_delta_dict, rg_profile_grp)[
        cell_id]
    for key, val in cellsetupreq_info_from_delta_dict.items():
        if val != cellsetupreq_info_from_pcap[key]:
            logger_console_info(f'Values do not match for {key}: real value is {cellsetupreq_info_from_pcap[key]},'
                                f' value from dict is {val}')
            raise ValueError
    logger_console_info(f'Cell Setup message properly validated for cell {cell_id}')


def extract_usersetupreq_info_from_packet(packet):
    usersetupreq_fields = ["itf_l2_ps_user_usersetupreq",
                           ("3gpp.rnti",),
                           ("itf_l2_ps_DrbAddReqPs.dlResourceGroupId_item",),
                           ("itf_l2_ps_DrbAddReqPs.dlDefaultResourceGroupId",),
                           ("itf_l2_ps_DrbAddReqPs.ulResourceGroupId_item",),
                           ("itf_l2_ps_DrbAddReqPs.ulDefaultResourceGroupId",),
                           ]
    return get_message_value_from_frame(packet, unique_field=usersetupreq_fields[0],
                                        list_of_next_unique_field=usersetupreq_fields[1:])


def extract_bearersetupreq_info_from_packet(packet):
    bearersetupreq_fields = ["itf_l2_ps_user_bearersetupreq",
                             ("3gpp.rnti",),
                             ("itf_l2_ps_DrbAddReqPs.dlResourceGroupId_item",),
                             ("itf_l2_ps_DrbAddReqPs.dlDefaultResourceGroupId",),
                             ("itf_l2_ps_DrbAddReqPs.ulResourceGroupId_item",),
                             ("itf_l2_ps_DrbAddReqPs.ulDefaultResourceGroupId",),
                             ]
    return get_message_value_from_frame(packet, unique_field=bearersetupreq_fields[0],
                                        list_of_next_unique_field=bearersetupreq_fields[1:])


def get_used_resource_groups_for_nsa_ues(pcap_path):
    json_file = convert_pcap_to_json_using_tshark(pcap_path, message_filter="itf_l2_ps_user_usersetupreq")
    usersetupreq_packets = read_json_file(json_file)
    resource_groups_for_nsa_ues = []
    for packet in usersetupreq_packets:
        packet_info = extract_usersetupreq_info_from_packet(packet)
        if packet_info[0] == '0':
            nsa_ue_resource_groups = {
                'dl_resource_groups': [int(packet_info[1]) if packet_info[1] else None],
                'dl_default_resource_groups': [int(packet_info[2]) if packet_info[2] else None],
                'ul_resource_groups': [int(packet_info[3]) if packet_info[3] else None],
                'ul_default_resource_groups': [int(packet_info[4]) if packet_info[4] else None],
            }
            resource_groups_for_nsa_ues.append(nsa_ue_resource_groups)
    return resource_groups_for_nsa_ues


def get_used_resource_groups_for_sa_ues(pcap_path):
    json_file = convert_pcap_to_json_using_tshark(pcap_path, message_filter="itf_l2_ps_user_bearersetupreq")
    bearersetupreq_packets = read_json_file(json_file)
    rntis_in_order = []
    rnti_resource_groups = {}
    for packet in bearersetupreq_packets:
        packet_info = extract_bearersetupreq_info_from_packet(packet)
        rnti = packet_info[0]
        if rnti != '0':
            if rnti not in rnti_resource_groups.keys():
                rntis_in_order.append(rnti)
                rnti_resource_groups[rnti] = defaultdict(list)

            rnti_resource_groups[rnti]['dl_resource_groups'].append(int(packet_info[1]) if packet_info[1] else None)
            rnti_resource_groups[rnti]['dl_default_resource_groups'].append(
                int(packet_info[2]) if packet_info[2] else None)
            rnti_resource_groups[rnti]['ul_resource_groups'].append(int(packet_info[3]) if packet_info[3] else None)
            rnti_resource_groups[rnti]['ul_default_resource_groups'].append(
                int(packet_info[4]) if packet_info[4] else None)
    return [dict(rnti_resource_groups[rnti]) for rnti in rntis_in_order]


def validate_resource_groups_for_ues(pcap_file_path, rgs_for_sa_ues=(), rgs_for_nsa_ues=(), direction='ul',
                                     cell_id=1):
    cellsetupreq_info_from_pcap = extract_cellsetupreq_info_from_pcap(pcap_file_path, '/tmp/')[cell_id]
    default_rgs_mapping = cellsetupreq_info_from_pcap[f'{direction}_default_rgs_mapping']
    pcap_sa_ues_rgs = get_used_resource_groups_for_sa_ues(pcap_file_path)
    pcap_nsa_ues_rgs = get_used_resource_groups_for_nsa_ues(pcap_file_path)

    pcap_rgs_for_sa_ues = _get_rgs_used_by_ues(default_rgs_mapping, pcap_sa_ues_rgs, direction)
    pcap_rgs_for_nsa_ues = _get_rgs_used_by_ues(default_rgs_mapping, pcap_nsa_ues_rgs, direction)

    if rgs_for_sa_ues:
        assert rgs_for_sa_ues == pcap_rgs_for_sa_ues, f'SA UE Rgs are {pcap_rgs_for_sa_ues}, ' \
                                                      f'provided ones are {rgs_for_sa_ues}'
    if rgs_for_nsa_ues:
        assert rgs_for_nsa_ues == pcap_rgs_for_nsa_ues, f'NSA UE Rgs are {pcap_rgs_for_nsa_ues}, ' \
                                                        f'provided ones are {rgs_for_nsa_ues}'
    logger_console_info('Resource groups for UEs are assigned properly')


def _get_rgs_used_by_ues(default_rgs_mapping, pcap_sa_ues_rgs, direction):
    pcap_rgs_for_ues = []
    for single_ue_rgs in pcap_sa_ues_rgs:
        single_ue_rgs_for_given_direction = []
        for rg_num, default_rg_num in zip(single_ue_rgs[f'{direction}_resource_groups'],
                                          single_ue_rgs[f'{direction}_default_resource_groups']):
            rg = rg_num if rg_num else default_rgs_mapping[default_rg_num]
            single_ue_rgs_for_given_direction.append(rg)
        if len(single_ue_rgs_for_given_direction) == 1:
            pcap_rgs_for_ues.append(single_ue_rgs_for_given_direction[0])
        else:
            pcap_rgs_for_ues.append(tuple(single_ue_rgs_for_given_direction))
    return tuple(pcap_rgs_for_ues)
