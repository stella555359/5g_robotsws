# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Michal Maczek, Anna Bien
:contact: michal.maczek@nokia.com, anna.bien@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import os
import re
import sys
import shlex

from subprocess import Popen, PIPE
from robot.libraries.BuiltIn import BuiltIn
from utilities import (
    logger_console, logger_warning, logger_console_info
)


class StreamDoesNotContainLineException(Exception):
    pass


class NoCellSetupReqWithAppriopriatePhysCellIdException(Exception):
    pass


class WronglyParsedDataException(Exception):
    pass


class WrongVectorSizeException(Exception):
    pass


class IncorrectValueException(Exception):
    pass


class MessageNotFound(Exception):
    pass


def regexp_in_string_exists(string, text=None, regexp=None, raise_exception=True):
    if text and text in string:
        return True
    if regexp and re.search(regexp, string):
        return re.search(regexp, string)
    if raise_exception:
        raise StreamDoesNotContainLineException("{} not in {}".format(regexp if regexp else text, string))
    else:
        return False


def __check_if_param_is_unicode_or_str(param):
    """
    :return: (bool) Returns True if param is unicode or str, in other case returns False.
    """

    global unicode
    try:
        is_unicode = not sys.version_info[0] >= 3 and isinstance(param, unicode)
    except UnboundLocalError:
        is_unicode = False
    if isinstance(param, str) or is_unicode:
        return True
    return False


def __open_txt_filename(path, split_str):
    cmd = 'cat {}'.format(path)
    cmd_splitted = shlex.split(cmd)
    output = Popen(cmd_splitted, stdout=PIPE)
    output_stream = output.stdout.read()
    decoded_stream = None
    try:
        decoded_stream = output_stream.decode("utf-8")
    except UnicodeDecodeError:
        decoded_stream = output_stream.decode("iso8859-15")
    splitted = enumerate(decoded_stream.split(split_str))
    return splitted


def __get_text_index_line_in_list(lines, text):
    index = lines.index(text)
    logger_console("Found text {} index at: {}".format(text, index))
    return index


def __get_regexp_int_value(string, regexp):
    match = regexp_in_string_exists(string=string, regexp=regexp)
    value = int(match.group("VALUE"))
    return value


def ensure_it_is_file_stream(path_or_stream, split_str='\n'):
    if __check_if_param_is_unicode_or_str(param=path_or_stream):
        return __open_txt_filename(path_or_stream, split_str=split_str)
    return path_or_stream


def convert_enum_to_list(enum, without_first_elem=False):
    rtn = [elem for idx, elem in enum]
    return rtn[1:] if without_first_elem else rtn


def load_pcap_txt_to_variable(pcap_txt_path, split_str='icom_5g'):
    stream = ensure_it_is_file_stream(pcap_txt_path, split_str)
    stream_list = convert_enum_to_list(enum=stream, without_first_elem=True)
    BuiltIn().set_suite_variable("${CURRENT_BIP_TXT}", stream_list)


def __get_cellsetupreq_with_appriopriate_group_id(stream):
    expected = BuiltIn().get_variable_value('${GRP_ID_WITH_ACTIVATED_FEATURE}')
    regexp = r'nrCellGrpId \(Uint16\): (?P<VALUE>\d+)'
    for s in stream:
        match = regexp_in_string_exists(string=s, regexp=regexp, raise_exception=False)
        if not match:
            continue
        current = match.group("VALUE")
        if current == expected:
            logger_console("Found cellsetupreq with {} expected groupid".format(expected))
            return s

    msg = "Could not find proper cellsetupreq with {} groupid".format(expected)
    logger_warning(msg)
    raise NoCellSetupReqWithAppriopriatePhysCellIdException(msg)


def __get_cellsetupreq_with_appriopriate_lcrid(stream, lcrid):
    expected = str(lcrid)
    regexp = r'lcrId \(Uint16\): (?P<VALUE>\d+)'
    for s in stream:
        match = regexp_in_string_exists(string=s, regexp=regexp, raise_exception=False)
        if not match:
            continue
        current = match.group("VALUE")
        if current == expected:
            logger_console("Found cellsetupreq with {} expected lcrId".format(expected))
            return s

    msg = "Could not find proper cellsetupreq with {} lcrId".format(expected)
    raise NoCellSetupReqWithAppriopriatePhysCellIdException(msg)


def __get_cellsetupreq_with_appriopriate_cell_id(stream, cell_id):
    expected = str(cell_id)
    regexp = BuiltIn().get_variable_value('${CELLID_UINT64_REGEXP}')
    for s in stream:
        match = regexp_in_string_exists(string=s, regexp=regexp, raise_exception=False)
        if not match:
            continue
        current = match.group("VALUE")
        if current == expected:
            logger_console("Found cellsetupreq with {} expected lcrId".format(expected))
            return s

    msg = "Could not find proper cellsetupreq with {} lcrId".format(expected)
    logger_warning(msg)
    raise NoCellSetupReqWithAppriopriatePhysCellIdException(msg)


def load_cellsetupreq_with_proper_group_id_to_variable(pcap_txt_path=None):
    if pcap_txt_path:
        load_pcap_txt_to_variable(pcap_txt_path=pcap_txt_path)
    stream = BuiltIn().get_variable_value('${CURRENT_BIP_TXT}')
    cellsetupreq = __get_cellsetupreq_with_appriopriate_group_id(stream)
    BuiltIn().set_suite_variable("${CURRENT_CELLSETUPREQ}", cellsetupreq)


def load_cellsetupreq_with_proper_lcrid_to_variable(pcap_txt_path=None, lcrid=None):
    if pcap_txt_path:
        load_pcap_txt_to_variable(pcap_txt_path=pcap_txt_path)
    stream = BuiltIn().get_variable_value('${CURRENT_BIP_TXT}')
    cellsetupreq = __get_cellsetupreq_with_appriopriate_lcrid(stream=stream, lcrid=lcrid)
    BuiltIn().set_suite_variable("${CURRENT_CELLSETUPREQ}", cellsetupreq)


def load_cellsetupreq_with_proper_cell_id_to_variable(pcap_txt_path=None, cell_id=None):
    if pcap_txt_path:
        load_pcap_txt_to_variable(pcap_txt_path=pcap_txt_path)
    stream = BuiltIn().get_variable_value('${CURRENT_BIP_TXT}')
    cellsetupreq = __get_cellsetupreq_with_appriopriate_cell_id(stream=stream, cell_id=cell_id)
    BuiltIn().set_suite_variable("${CURRENT_CELLSETUPREQ}", cellsetupreq)


def load_cellreconfigurationreq_with_proper_group_id_to_variable(pcap_txt_path=None):
    if pcap_txt_path:
        load_pcap_txt_to_variable(pcap_txt_path=pcap_txt_path)
    stream = BuiltIn().get_variable_value('${CURRENT_BIP_TXT}')
    msg = __get_cellsetupreq_with_appriopriate_group_id(stream)
    BuiltIn().set_suite_variable("${CURRENT_CELLRECONFIGURATIONREQ}", msg)


def __load_cellsetupreq_vector_to_variable(starting_text, starting_item_text, pcap_txt_path=None, loginfo=""):
    if pcap_txt_path:
        load_cellsetupreq_with_proper_group_id_to_variable(pcap_txt_path=pcap_txt_path)
    logger_console("Loading {} items to variable...".format(loginfo))
    msg = BuiltIn().get_variable_value('${CURRENT_CELLSETUPREQ}')
    lines = [s.strip() for s in msg.split('\n')]  # delete whitespaces at the beginning and at the end for every line
    i = __get_text_index_line_in_list(lines=lines, text=starting_text)
    string_containing_length = "\n".join(lines[i:i+4])  # it should contain offset and length blocks ready to parse
    match = regexp_in_string_exists(string=string_containing_length,
                                    regexp=r'Length \(Uint32\): (?P<VALUE>\d+)')
    value = int(match.group("VALUE"))
    logger_console("There is {} {} items".format(value, loginfo))
    lines_to_parse = value * 3 + 3  # as every item have 3 lines, need to count value*3 and then add first 3 elems
    beamweightvector_lines = lines[i:i+lines_to_parse]
    items = " ".join(beamweightvector_lines).split(starting_item_text)[1:]
    logger_console("There is {} {} items parsed into list".format(len(items), loginfo))
    if value != len(items):
        msg = "{} items at CellSetupReq were wrongly parsed, exp {} act {}".format(loginfo, value, len(items))
        logger_warning(msg)
        raise WronglyParsedDataException(msg)

    rtn_list = []
    for item in items:
        match = regexp_in_string_exists(string=item,
                                        regexp=r'beamId \(Uint16\): (?P<VALUE>\d+)')
        beamid = match.group("VALUE")
        match = regexp_in_string_exists(string=item,
                                        regexp=r'patternId \(Uint16\): (?P<VALUE>\d+)')
        patternid = match.group("VALUE")
        rtn_list.append({'beamid': int(beamid), "patternid": int(patternid)})

    logger_console("Returning {} items {}".format(loginfo, len(rtn_list)))
    return rtn_list


def load_beamweightvector_to_variable(pcap_txt_path=None):
    items = __load_cellsetupreq_vector_to_variable(
        starting_text='beamWeightVector (DynamicVariableSizedArray)',
        starting_item_text="beamWeightVector_item_",
        pcap_txt_path=pcap_txt_path,
        loginfo='beamWeightVector'
    )
    BuiltIn().set_suite_variable("${CURRENT_BEAMWEIGHTVECTOR_ITEMS}", items)
    return items


def load_mmimopsbeamweightvector_to_variable(pcap_txt_path=None):
    items = __load_cellsetupreq_vector_to_variable(
        starting_text='mMimoPsBeamWeightVector (DynamicVariableSizedArray)',
        starting_item_text="mMimoPsBeamWeightVector_item_",
        pcap_txt_path=pcap_txt_path,
        loginfo='mMimoPsBeamWeightVector'
    )
    BuiltIn().set_suite_variable("${CURRENT_MMIMOPSBEAMWEIGHTVECTOR_ITEMS}", items)
    return items


def ensure_beamweightvector_and_mmimopsbeamweightvector_are_proper(pcap_txt_path=None):
    """
    Validate beamWeightVector and mMimoPsBeamWeightVector in itf_l2_ps_cell_cellsetupreq packet.

    :param pcap_txt_path: (str) Path to .txt file converted from .pcap
    """

    beamweightvector = BuiltIn().get_variable_value('${CURRENT_BEAMWEIGHTVECTOR_ITEMS}')
    mmimopsbeamweightvector = BuiltIn().get_variable_value('${CURRENT_MMIMOPSBEAMWEIGHTVECTOR_ITEMS}')
    if pcap_txt_path or (not beamweightvector or not mmimopsbeamweightvector):
        load_beamweightvector_to_variable(pcap_txt_path=pcap_txt_path)
        load_mmimopsbeamweightvector_to_variable(pcap_txt_path=pcap_txt_path)

    logger_console("ensure_beamWeightVector_and_mMimoPsBeamWeightVector_are_proper")
    beamweightvector = BuiltIn().get_variable_value('${CURRENT_BEAMWEIGHTVECTOR_ITEMS}')
    mmimopsbeamweightvector = BuiltIn().get_variable_value('${CURRENT_MMIMOPSBEAMWEIGHTVECTOR_ITEMS}')
    if len(beamweightvector) != len(mmimopsbeamweightvector):
        msg = "Different vector sizes, bwv {} mmpbwv {}".format(len(beamweightvector), len(mmimopsbeamweightvector))
        logger_warning(msg)
        raise WrongVectorSizeException(msg)

    for i in range(len(beamweightvector)):
        if beamweightvector[i]['beamid'] != mmimopsbeamweightvector[i]['beamid']:
            msg = "Different beamid at {}, bwv {} mmpbwv {}".format(
                i, beamweightvector[i]['beamid'], mmimopsbeamweightvector[i]['beamid'])
            logger_warning(msg)
            raise IncorrectValueException(msg)
        if beamweightvector[i]['patternid']+8192 != mmimopsbeamweightvector[i]['patternid']:
            msg = "Different patternid at {}, bwv-8192 {} mmpbwv {}".format(
                i, beamweightvector[i]['patternid'], mmimopsbeamweightvector[i]['patternid'])
            logger_warning(msg)
            raise IncorrectValueException(msg)

    logger_console("Validated beamid and patternid at beamWeightVector_and_mMimoPsBeamWeightVector it is correct!")


def __ensure_msg_has_proper_boolean_regexp(msg, regexp, expected, loginfo):
    match = regexp_in_string_exists(string=msg, regexp=regexp)
    activated = match.group("VALUE")
    if expected in activated:
        logger_console("Found {} {}! -> {}".format(loginfo, expected, match))
        return
    msg = "Found {} not expected! -> {}".format(loginfo, match)
    logger_warning(msg)
    raise IncorrectValueException(msg)


def __ensure_current_cellsetupreq_has_proper_regexp(pcap_txt_path, regexp, expected, loginfo):
    if pcap_txt_path:
        load_cellsetupreq_with_proper_group_id_to_variable(pcap_txt_path=pcap_txt_path)
    msg = BuiltIn().get_variable_value('${CURRENT_CELLSETUPREQ}')
    __ensure_msg_has_proper_boolean_regexp(
        msg=msg, regexp=regexp, expected=expected, loginfo="cellsetupreq {}".format(loginfo)
    )


def ensure_current_cellsetupreq_has_actnrlbmmimortxpowersaving_in_proper_state(expected='True', pcap_txt_path=None):
    __ensure_current_cellsetupreq_has_proper_regexp(
        pcap_txt_path=pcap_txt_path,
        regexp=r'actNrLBmMimoRTXPowerSaving \(Boolean\): (?P<VALUE>.[a-z]+)',
        expected=expected,
        loginfo='actNrLBmMimoRTXPowerSaving'
    )


def ensure_current_cellsetupreq_has_iscellmassivemimo_in_proper_state(expected='True', pcap_txt_path=None):
    __ensure_current_cellsetupreq_has_proper_regexp(
        pcap_txt_path=pcap_txt_path,
        regexp=r'isCellMassiveMimo \(Boolean\): (?P<VALUE>.[a-z]+)',
        expected=expected,
        loginfo='isCellMassiveMimo'
    )


def __count_all_load_measuremet_ind_messages(stream):
    """
    Count itf_l2_ps_cell_powersavingloadmeasurementind messages.
    """

    regexp = re.compile(r'itf_l2_ps_cell_powersavingloadmeasurementind')
    messages_amount = 0
    for s in stream:
        try:
            regexp_in_string_exists(string=s, regexp=regexp)
            messages_amount += 1
        except StreamDoesNotContainLineException:
            continue
    try:
        assert messages_amount > 0, 'Could not find any itf_l2_ps_cell_powersavingloadmeasurementind message'
        logger_console_info('Found {} Power Saving Load Measurement Ind messages'.format(messages_amount))
    except AssertionError as msg_not_found:
        raise MessageNotFound(msg_not_found)


def count_all_powersaving_configuration_req_messages(pcap_txt_path):
    """
    Returns list [number of reduced energy saving state, number of not energy saving state] in pcap_txt_path file
    """
    if pcap_txt_path:
        load_pcap_txt_to_variable(pcap_txt_path=pcap_txt_path, split_str='Frame')
    stream = BuiltIn().get_variable_value('${CURRENT_BIP_TXT}')

    regexp_res = re.compile(r'energySavingState \(itf_l2_ps_cell_EnergySavingState\): reducedEnergySaving \(2\)')
    regexp_nes = re.compile(r'energySavingState \(itf_l2_ps_cell_EnergySavingState\): notEnergySaving \(0\)')
    messages_amount_res = 0
    messages_amount_nes = 0

    for s in stream:
        try:
            regexp_in_string_exists(string=s, regexp=regexp_res)
            messages_amount_res += 1
        except StreamDoesNotContainLineException:
            pass
        try:
            regexp_in_string_exists(string=s, regexp=regexp_nes)
            messages_amount_nes += 1
        except StreamDoesNotContainLineException:
            pass
    return [messages_amount_res, messages_amount_nes]


def ensure_powersaving_load_measurement_ind_was_sent(pcap_txt_path):
    load_pcap_txt_to_variable(pcap_txt_path=pcap_txt_path, split_str='Frame')
    stream = BuiltIn().get_variable_value('${CURRENT_BIP_TXT}')
    __count_all_load_measuremet_ind_messages(stream)


def load_dftBeam_text_to_variable(pcap_txt_path=None, cell_id=None):
    if pcap_txt_path:
        if cell_id:
            load_cellsetupreq_with_proper_cell_id_to_variable(pcap_txt_path=pcap_txt_path, cell_id=cell_id)
        else:
            load_cellsetupreq_with_proper_group_id_to_variable(pcap_txt_path=pcap_txt_path)
    msg = BuiltIn().get_variable_value('${CURRENT_CELLSETUPREQ}')
    lines = [s.strip() for s in msg.split('\n')]  # delete whitespaces at the beginning and at the end for every line
    i = __get_text_index_line_in_list(lines=lines, text=BuiltIn().get_variable_value('${DLSRSBMCONFIG_TEXT}'))
    needed_len = i + 2000
    if len(msg) <= needed_len:
        logger_console("As cellsetupreq for dftBeam is shorter than expected, assigning actual length ")
        needed_len = len(msg)
    msg = "\n".join(lines[i:needed_len])
    logger_console("Writing dftBeam text from bip to variable")
    BuiltIn().set_suite_variable("${CURRENT_DFTBEAM}", msg)


def load_dftbeamsetlist_items_to_variable(pcap_txt_path=None, cell_id=None):
    if pcap_txt_path:
        load_dftBeam_text_to_variable(pcap_txt_path=pcap_txt_path, cell_id=cell_id)
    msg = BuiltIn().get_variable_value('${CURRENT_DFTBEAM}')
    item = BuiltIn().get_variable_value('${DFTBEAMSETLIST_ITEM_TEXT}')
    items = msg.split(item)[1:]
    if len(items) < 2:
        msg = "Wrong items length, cannot parse dftbeamsetlist items!"
        logger_warning(msg)
        raise WronglyParsedDataException(msg)
    BuiltIn().set_suite_variable("${CURRENT_DFTBEAMSETLIST_ITEM_0}", items[0])
    BuiltIn().set_suite_variable("${CURRENT_DFTBEAMSETLIST_ITEM_1}", items[1])


def ensure_dftbeamsetlist_length_is_proper(pcap_txt_path, cell_id=None):
    if pcap_txt_path:
        load_dftBeam_text_to_variable(pcap_txt_path=pcap_txt_path, cell_id=cell_id)
    msg = BuiltIn().get_variable_value('${CURRENT_DFTBEAM}')

    lines = msg.split('\n')
    i = __get_text_index_line_in_list(lines=lines, text=BuiltIn().get_variable_value('${DFTBEAMSETLIST_TEXT}'))
    lines = lines[i:i+3]
    msg = "\n".join(lines)

    regexp = BuiltIn().get_variable_value('${LENGTH_UINT32_REGEXP}')
    match = regexp_in_string_exists(string=msg, regexp=regexp)
    value = int(match.group("VALUE"))
    if value != 2:
        msg = "Found wrong value in cellsetupreq dftBeamSetList length! -> {}".format(match)
        logger_warning(msg)
        raise IncorrectValueException(msg)
    logger_console("Found proper value in cellsetupreq dftBeamSetList length! -> {}".format(match))


def ensure_dftbeamsetids_are_proper(pcap_txt_path=None, cell_id=None):
    if pcap_txt_path:
        load_dftBeam_text_to_variable(pcap_txt_path=pcap_txt_path, cell_id=cell_id)
    msg = BuiltIn().get_variable_value('${CURRENT_DFTBEAM}')

    item_0_regexp = BuiltIn().get_variable_value('${DFTBEAMSETID_ITEM_0_UINT8_REGEXP}')
    match_0 = regexp_in_string_exists(string=msg, regexp=item_0_regexp)
    item_0_value = int(match_0.group("VALUE"))
    if item_0_value != 1:
        msg = "Found wrong value in cellsetupreq dftBeamSetId_item_0! -> {}".format(match_0)
        logger_warning(msg)
        raise IncorrectValueException(msg)
    logger_console("Found proper value in cellsetupreq dftBeamSetId_item_0! -> {}".format(match_0))

    item_1_regexp = BuiltIn().get_variable_value('${DFTBEAMSETID_ITEM_1_UINT8_REGEXP}')
    match_1 = regexp_in_string_exists(string=msg, regexp=item_1_regexp)
    item_1_value = int(match_1.group("VALUE"))
    if item_1_value != 4:
        msg = "Found wrong value in cellsetupreq dftBeamSetId_item_1! -> {}".format(match_1)
        logger_warning(msg)
        raise IncorrectValueException(msg)
    logger_console("Found proper value in cellsetupreq dftBeamSetId_item_1! -> {}".format(match_1))


def ensure_numOfDftBeamForSrsBmH_BmV_are_correct_in_both_dftbeamset_items(pcap_txt_path=None, cell_id=None):
    if pcap_txt_path:
        load_dftbeamsetlist_items_to_variable(pcap_txt_path=pcap_txt_path, cell_id=cell_id)

    item_0 = BuiltIn().get_variable_value('${CURRENT_DFTBEAMSETLIST_ITEM_0}')
    item_1 = BuiltIn().get_variable_value('${CURRENT_DFTBEAMSETLIST_ITEM_1}')

    bmh_regexp = BuiltIn().get_variable_value('${NUMOFDFTBEAMFORSRSBMH_UINT8_REGEXP}')
    bmv_regexp = BuiltIn().get_variable_value('${NUMOFDFTBEAMFORSRSBMV_UINT8_REGEXP}')

    item_0_bmh = __get_regexp_int_value(string=item_0, regexp=bmh_regexp)
    item_0_bmv = __get_regexp_int_value(string=item_0, regexp=bmv_regexp)

    item_1_bmh = __get_regexp_int_value(string=item_1, regexp=bmh_regexp)
    item_1_bmv = __get_regexp_int_value(string=item_1, regexp=bmv_regexp)

    if item_0_bmh != item_1_bmh:
        msg = 'numOfDftBeamForSrsBmH has different value in dftbeamsetlist items! {} != {}'.format(
            item_0_bmh, item_1_bmh)
        logger_warning(msg)
        raise IncorrectValueException(msg)

    if item_0_bmv <= item_1_bmv:
        msg = 'numOfDftBeamForSrsBmV has wrong differnece in dftbeamsetlist items! {} != {}'.format(
            item_0_bmv, item_1_bmv)
        logger_warning(msg)
        raise IncorrectValueException(msg)

    logger_console("numOfDftBeamForSrsBmH and BmV are correct!")


def ensure_dftBeamWeightV_real_imag_parts_are_proper(pcap_txt_path=None, trx=64, cell_id=None):
    if pcap_txt_path:
        load_dftbeamsetlist_items_to_variable(pcap_txt_path=pcap_txt_path, cell_id=cell_id)

    logger_console("Ensuring dftBeamWeightV_real_imag_parts_are_proper")
    item_1 = BuiltIn().get_variable_value('${CURRENT_DFTBEAMSETLIST_ITEM_1}')

    __validate_real_imag_parts_for_dftbeamweightv_item_if_they_are_zero(string=item_1, loginfo="item_1", trx=trx)


def __validate_real_imag_parts_for_dftbeamweightv_item_if_they_are_zero(string, loginfo, trx):
    if trx == 64:
        __validate_all_regexp_results_in_string(
            string=string, regexp=BuiltIn().get_variable_value('${REALPARTOFWEIGHTV_ITEM_2_INT16_REGEXP}'),
            expected_value=0, loginfo='{} RealPartOfWeightV_item_2'.format(loginfo)
        )
        __validate_all_regexp_results_in_string(
            string=string, regexp=BuiltIn().get_variable_value('${REALPARTOFWEIGHTV_ITEM_3_INT16_REGEXP}'),
            expected_value=0, loginfo='{} RealPartOfWeightV_item_3'.format(loginfo)
        )
        __validate_all_regexp_results_in_string(
            string=string, regexp=BuiltIn().get_variable_value('${IMAGPARTOFWEIGHTV_ITEM_2_INT16_REGEXP}'),
            expected_value=0, loginfo='{} ImagPartOfWeightV_item_2'.format(loginfo)
        )
        __validate_all_regexp_results_in_string(
            string=string, regexp=BuiltIn().get_variable_value('${IMAGPARTOFWEIGHTV_ITEM_3_INT16_REGEXP}'),
            expected_value=0, loginfo='{} ImagPartOfWeightV_item_3'.format(loginfo)
        )
    if trx == 32:
        __validate_all_regexp_results_in_string(
            string=string, regexp=BuiltIn().get_variable_value('${REALPARTOFWEIGHTV_ITEM_1_INT16_REGEXP}'),
            expected_value=0, loginfo='{} RealPartOfWeightV_item_1'.format(loginfo)
        )
        __validate_all_regexp_results_in_string(
            string=string, regexp=BuiltIn().get_variable_value('${IMAGPARTOFWEIGHTV_ITEM_1_INT16_REGEXP}'),
            expected_value=0, loginfo='{} ImagPartOfWeightV_item_1'.format(loginfo)
        )


def __validate_all_regexp_results_in_string(string, regexp, expected_value, loginfo):
    logger_console("Searching for {} expected value {}...".format(loginfo, expected_value))
    result = re.findall(pattern=regexp, string=string)
    if result and all(int(i) == int(expected_value) for i in result):
        logger_console("{} contains only expected value {}!".format(loginfo, expected_value))
        return
    msg = "Could not find any {} results for regexp {}".format(loginfo, regexp)
    logger_warning(msg)
    raise WronglyParsedDataException(msg)
