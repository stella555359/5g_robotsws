# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
import os
from validation_general import (
    ensure_it_is_file_stream,
    convert_enum_to_list,
    regexp_item_in_stream,
    regexp_in_string_exists,
    validate_single_quotas,
    validate_given_slice_list,
    validate_given_cell,
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.bip_management import (
    create_tshark_command,
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    check_file_exists,
    get_latest_file,
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.mcshark_management import (
    ensure_mcshark_package_is_installed,
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console,
    logger_warning,
)


class NotExistingCellSetupReqTxtFileException(Exception):
    pass


class CellGroupIdDoesNotEqualToCellIdException(Exception):
    pass


class SdInBipDoesNotMatchScfException(Exception):
    pass


class NoSliceListInCellSetupReqException(Exception):
    pass


def __save_pcap_to_txt(output_dir, prefix, pcap_path, using_mcshark, filter, syscom, names='l1l2bip'):
    if syscom:
        output_path = os.path.join(output_dir, prefix + ".txt")
    else:
        output_path = os.path.join(output_dir, names, prefix + ".txt")

    tshark = create_tshark_command(
        bip_pcap_file=pcap_path,
        using_mcshark=using_mcshark,
        filter_mode=filter,
        luashark_path=None,
        output_path=output_path,
        syscom_tcp_port=True,
    )
    OperatingSystem().run(tshark)
    return output_path


def __look_for_pcap_file_with_cellsetupreq(output_dir, pattern, using_mcshark, filter, syscom, names='l1l2bip'):
    try:
        if syscom:
            latest_bip = get_latest_file(os.path.join(output_dir, pattern))
        else:
            latest_bip = get_latest_file(os.path.join(output_dir, names, pattern))

    except ValueError:
        return None
    logger_console(
        "Decoding {} file to txt format and checking if {} returns sth...".format(
            latest_bip, filter
        )
    )
    output = __save_pcap_to_txt(
        output_dir=output_dir,
        prefix="testfile",
        pcap_path=latest_bip,
        using_mcshark=using_mcshark,
        filter=filter,
        syscom=syscom
    )
    if check_file_exists(output):
        logger_console("Returning pcap with filter {}: {}".format(filter, latest_bip))
        return latest_bip
    logger_console(
        "{} does not contain any msg with filter {}!".format(latest_bip, filter)
    )
    return None


def __get_latest_collected_bip(output_dir, using_mcshark, filter, syscom):
    patterns = ["p_*.pcap", "0_*.pcap", "1_*.pcap", "2_*.pcap", 'syscom*.pcap', 'bip.pcap']
    for p in patterns:
        bip_with_cellsetupreq = __look_for_pcap_file_with_cellsetupreq(
            output_dir=output_dir, pattern=p, using_mcshark=using_mcshark, filter=filter, syscom=syscom
        )
        if bip_with_cellsetupreq is not None:
            return bip_with_cellsetupreq
    raise NotExistingCellSetupReqTxtFileException(
        "Could not find bip file with filter {}!".format(filter)
    )


def save_filtered_pcap_to_txt_file(
    output_dir, prefix, using_mcshark=None, pcap_path=None, filter="", syscom=False
):
    mcshark_global_path = BuiltIn().get_variable_value("${BIP_MCSHARK_PATH}")
    if not pcap_path:
        pcap_path = __get_latest_collected_bip(
            output_dir=output_dir, using_mcshark=using_mcshark, filter=filter, syscom=syscom
        )
    if using_mcshark:
        ensure_mcshark_package_is_installed(mcshark_path=mcshark_global_path)
    output_path = __save_pcap_to_txt(
        output_dir=output_dir,
        prefix=prefix,
        pcap_path=pcap_path,
        using_mcshark=using_mcshark,
        filter=filter,
        syscom=syscom
    )
    BuiltIn().set_suite_variable("${BIP_TXT_OUTPUT_PATH}", output_path)


def ensure_decoded_txt_file_exists():
    txt = BuiltIn().get_variable_value("${BIP_TXT_OUTPUT_PATH}")
    exists = check_file_exists(txt)
    if not exists:
        raise NotExistingCellSetupReqTxtFileException(
            "File does not contain any data {}!".format(txt)
        )


def get_cell_group_ids():
    stream = ensure_it_is_file_stream(
        BuiltIn().get_variable_value("${BIP_TXT_OUTPUT_PATH}"), "icom_5g"
    )
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    grp_ids = regexp_item_in_stream(
        regexp=BuiltIn().get_variable_value("${VALID_BIP_CELLGRP_ID_REGEXP}"),
        stream=cellsetupreq_msgs,
        item="CELLGRP_ID",
    )
    logger_console("Retrieved CellGrpIDs {}".format(grp_ids))
    return grp_ids


def ensure_cell_ids_consists_of_the_same_cellgrp_ids(cell=None, grp_ids=None):
    if grp_ids is None:
        grp_ids = get_cell_group_ids()
    if cell is None:
        cell = [0, 1, 2, 3]
    elif isinstance(cell, str):
        cell = [int(cell)]

    for c in cell:
        c = validate_given_cell(c)
        try:
            cellgrp_id = grp_ids[c]
        except IndexError:
            msg = "CellGroup with Index {} does not exist in list {}!".format(
                c, grp_ids
            )
            raise CellGroupIdDoesNotEqualToCellIdException(msg)
        if str(cellgrp_id) != str(c):
            msg = "CellGroupID does not equal to given Cell ID: {} != {}".format(
                cellgrp_id, c
            )
            raise CellGroupIdDoesNotEqualToCellIdException(msg)
    logger_console("Cell Ids are the same as the Cell Group Ids!")


def ensure_slice_aware_scheduler_is_activated():
    """There is no need for first elem in list, as it contains no necessary data. Then we
    parse concrete string with msg for given cell.
    """
    cell = validate_given_cell(
        BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE}")
    )
    bip_path = BuiltIn().get_variable_value("${BIP_TXT_OUTPUT_PATH}")
    logger_console("Ensuring Slice Aware Scheduler exists in: {}".format(bip_path))
    stream = ensure_it_is_file_stream(bip_path, "icom_5g")
    cellsetupreq_msgs = convert_enum_to_list(enum=stream, without_first_elem=True)
    regexp_in_string_exists(
        text=BuiltIn().get_variable_value("${VALID_BIP_FEATURE_ACTIVATED}"),
        string=cellsetupreq_msgs,
        is_slice=True,
    )
    logger_console("Found feature activated on cell {}".format(cell))


def __retrieve_slice_list(cell_id=0, slice_list_id=0, is_nsa=False):
    """Assuming that there is only 2 slice list, split returns 3 items,
    where 1-index and 2-index returns correct slice lists
    2-nd slice list contains too much data, so we delete not needed data
    """
    if is_nsa:
        split = BuiltIn().get_variable_value("${VALID_BIP_NSA_SLICE_LIST_SPLIT_TEXT}")
    else:
        split = BuiltIn().get_variable_value("${VALID_BIP_SLICE_LIST_SPLIT_TEXT}")

    string = BuiltIn().get_variable_value('${PROPER_CELL_SETUP_MSG}')

    if split not in string:
        msg = "There is no slice list in given cellsetupreq for cell {}!".format(
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
        regexp=BuiltIn().get_variable_value("${VALID_BIP_MINQUOTA_REGEXP}"),
        string=slice_list,
    )
    match_maxquota = regexp_in_string_exists(
        regexp=BuiltIn().get_variable_value("${VALID_BIP_MAXQUOTA_REGEXP}"),
        string=slice_list,
    )
    return {
        "min": match_minquota.group("MINQUOTA"),
        "max": match_maxquota.group("MAXQUOTA"),
    }


def ensure_quotas_contain_correct_values(expected_quotas, slice_list_id=1, is_nsa=False):
    cell = validate_given_cell(
        BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE}")
    )
    slice_list_id = validate_given_slice_list(slice_list_id)
    bip_path = BuiltIn().get_variable_value("${BIP_TXT_OUTPUT_PATH}")
    logger_console("Ensuring Quotas contain correct values in: {}".format(bip_path))
    slice_list = __retrieve_slice_list(
        cell_id=cell, slice_list_id=slice_list_id, is_nsa=is_nsa
    )
    actual_quotas = __retrieve_quotas_from_slice_list([slice_list])
    validate_single_quotas(
        actual=actual_quotas, expected=expected_quotas[slice_list_id]
    )


def __retrieve_sd_values_from_slice_list(slice_list):
    sd_regexps = BuiltIn().get_variable_value("${VALID_BIP_SD_REGEXPS}")
    rtn = []
    for regexp in sd_regexps:
        match = regexp_in_string_exists(regexp=regexp, string=slice_list)
        rtn.append(match.group("SDVALUE"))
    logger_console("Found sd values: {}".format(rtn))
    return rtn


def __dec2hex(val):
    return str(hex(int(val)))


def __hex2dec(val):
    return str(int(val, 16))


def __compose_sd_value(sd_values):
    sd_hex = ""
    sd_hex += __dec2hex(sd_values[0])
    sd_hex += __dec2hex(sd_values[1]).replace("0x", "")
    sd_hex += __dec2hex(sd_values[2]).replace("0x", "")
    sd_dec = __hex2dec(sd_hex)
    logger_console("Composed sd value in hex: {}, dec: {}".format(sd_hex, sd_dec))
    return sd_dec


def ensure_sd_has_values_as_in_scf(expected_sd, slice_list_id=0):
    cell = validate_given_cell(
        BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE}")
    )
    slice_list_id = validate_given_slice_list(slice_list_id)
    bip_path = BuiltIn().get_variable_value("${BIP_TXT_OUTPUT_PATH}")
    logger_console(
        "Ensuring sd from bip has the same values as in SCF: {}".format(bip_path)
    )
    slice_list = __retrieve_slice_list(
        cell_id=cell, slice_list_id=slice_list_id
    )
    sd_values = __retrieve_sd_values_from_slice_list([slice_list])
    sd = __compose_sd_value(sd_values)
    if sd != expected_sd[slice_list_id]:
        msg = "sd not matching in bip! actual: {} expected: {}".format(
            sd, expected_sd[slice_list_id]
        )
        raise SdInBipDoesNotMatchScfException(msg)
    logger_console("sd values are the same either in bip as in scf!")
