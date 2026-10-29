# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import time
import os
import re

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Paris.RRM.ET.resources_KRK.python.file_management import (
    check_file_exists, copy_files_from_local_to_local
)
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console, logger_warning

from validation_txt import convert_enum_to_list, ensure_it_is_file_stream, regexp_in_stream_exists


class EgateConsoleLogDoesNotExistException(Exception):
    pass


class StreamDoesNotContainLineException(Exception):
    pass


class EgateConsoleLogWrongValueException(Exception):
    pass


class FileNotFoundError(Exception):
    pass


def copy_egate_console_log_to_output_dir(output_dir=None):
    egate_console_log = BuiltIn().get_variable_value('${EGATE_CONSOLE_LOG}')
    if not check_file_exists(egate_console_log):
        raise EgateConsoleLogDoesNotExistException('{} does not exist!'.format(egate_console_log))
    if output_dir is None:
        output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')

    copy_files_from_local_to_local(src_local_paths=egate_console_log, dst_local_path=output_dir)

    BuiltIn().set_suite_variable('${EGATE_CONSOLE_LOG_AT_OUTPUT_DIR}',
                                 os.path.join(output_dir, os.path.basename(egate_console_log)))
    egate_console_log = BuiltIn().get_variable_value('${EGATE_CONSOLE_LOG_AT_OUTPUT_DIR}')

    if not check_file_exists(egate_console_log):
        raise EgateConsoleLogDoesNotExistException('{} does not exist!'.format(egate_console_log))
    logger_console('Copied {} to {}'.format(egate_console_log, output_dir))


def validate_sib1_downlink_uplink_config_common_egate_console_log(bwp_type, egate_console_log=None):
    if not egate_console_log:
        egate_console_log = BuiltIn().get_variable_value('${EGATE_CONSOLE_LOG_AT_OUTPUT_DIR}')

    logger_console('Validating sib1 downlink uplink config common at {}'.format(egate_console_log))

    stream = ensure_it_is_file_stream(path_or_stream=egate_console_log)
    regexp_in_stream_exists(stream=stream, path=egate_console_log,
                            text=BuiltIn().get_variable_value('${DOWNLINK_CONFIG_COMMON_EGATE}'))
    regexp_in_stream_exists(stream=stream, path=egate_console_log,
                            text=BuiltIn().get_variable_value('${UPLINK_CONFIG_COMMON_EGATE}'))

    stream_list = convert_enum_to_list(enum=stream, without_first_elem=False)
    stream_string = '\n'.join(stream_list)

    regexps = BuiltIn().get_variable_value('${VALIDATION_EGATE_CONSOLE_LOG_REGEXPS}')

    cb_list = re.findall(pattern=regexps['carrierBandwidth'], string=stream_string)
    lab_list = re.findall(pattern=regexps['locationAndBandwidth'], string=stream_string)

    values = BuiltIn().get_variable_value('${VALIDATION_EGATE_CONSOLE_LOG_G_MULTIPLE_BWPS}')
    cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')

    expected_cb_large = values[cell_tech]['carrierBandwith_LargeBWP']
    expected_cb_small = values[cell_tech]['carrierBandwith_SmallBWP']
    expected_lab_small = values[cell_tech]['locationAndBandwidth_SmallBWP']
    expected_lab_large = values[cell_tech]['locationAndBandwidth_LargeBWP']

    msg = '{} wrong value in sib1 downlink uplink config common, actual {} expected {}'

    if str(expected_cb_large) not in cb_list:
        local_msg = msg.format('carrierBandwidth', cb_list, expected_cb_large)
        logger_warning(local_msg)
        raise EgateConsoleLogWrongValueException(local_msg)
    if str(expected_lab_small) not in lab_list:
        local_msg = msg.format('locationAndBandwidth', lab_list, expected_lab_small)
        logger_warning(local_msg)
        raise EgateConsoleLogWrongValueException(local_msg)

    if bwp_type == 'large':
        logger_console('TC with UEs with large BWP, so additionally locationAndBandwidth for large BWP is checked')
        if str(expected_lab_large) not in lab_list:
            local_msg = msg.format('locationAndBandwidth', lab_list, expected_lab_large)
            logger_warning(local_msg)
            raise EgateConsoleLogWrongValueException(local_msg)
        logger_console('Large BWP: Expected carrierBandwidth {} locationAndBandwidth: small {}, large {},'
                       '\nValues cB: {}\nValues lAB: {}'.format(
                        expected_cb_large, expected_lab_small, expected_lab_large, cb_list, lab_list
                        ))
    else:
        logger_console('TC with UEs with small BWP, so additionally carrierBandwidth for small BWP is checked')
        if str(expected_cb_small) not in cb_list:
            local_msg = msg.format('carrierBandwidth', cb_list, expected_cb_small)
            logger_warning(local_msg)
            raise EgateConsoleLogWrongValueException(local_msg)
        logger_console('Large BWP: Expected carrierBandwidth: small {}, large {} locationAndBandwidth,'
                       '\nValues cB: {}\nValues lAB: {}'.format(
                        expected_cb_small, expected_cb_large, expected_lab_small, cb_list, lab_list
                        ))


def _add_msg_to_check_in_the_future(new_msg):
    old_msges = BuiltIn().get_variable_value('${MSG_TO_CHECK}')
    if old_msges is None:
        BuiltIn().set_suite_variable('${MSG_TO_CHECK}', [new_msg])
    else:
        old_msges.append(new_msg)


def check_old_msg_in_egate_log(egate_log_path, old_msges):
    for msg in old_msges:
        _read_egate_file(egate_log_path, msg, timeout=30, since_beginning=True)


def _read_egate_file(egate_log_path, msg, timeout, since_beginning):
    with open(egate_log_path, 'r') as egate_log:
        if since_beginning is False:
            egate_log.seek(0, 2)
        start_time = time.time()
        while True:
            line = egate_log.readline()
            if time.time() - start_time > timeout:
                error_msg = 'Message "{}" not found in {} after {}s'.format(msg, egate_log_path, timeout)
                logger_warning(error_msg)
                _add_msg_to_check_in_the_future(msg)
                time.sleep(10)
                break
            if not line:
                time.sleep(0.1)
                continue
            if msg in line:
                found_msg = 'Message {} found in {}'.format(msg, egate_log_path)
                logger_console(found_msg)
                break


def check_egate_log_in_real_time(egate_log_path, msg, timeout=300, since_beginning=True):
    try:
        _read_egate_file(egate_log_path, msg, timeout, since_beginning)
    except FileNotFoundError:
        wait_for_egate_log()
        _read_egate_file(egate_log_path, msg, timeout, since_beginning)


def wait_for_egate_log():
    logger_warning('Egate log not found, trying one more time')
    time.sleep(30)


def __check_if_values_for_8124_are_correct(actual, expected):
    int_count = 0
    msg = "CS-RNTI has wrong value"
    for act, exp in zip(actual, expected):
        try:
            if isinstance(int(act), int):
                int_count += 1
                logger_console("CS-RNTI is correct")
        except ValueError:
            if act != exp:
                local_msg = logger_console('{} is not equal to {}!'.format(act, exp))
                raise EgateConsoleLogWrongValueException(local_msg)
            logger_console("{} is equal to {}".format(act, exp))

    if int_count < 1:
        raise EgateConsoleLogWrongValueException(msg)


def check_rrc_reconfiguration_for_8124_validation(egate_console_log=None):
    rrc_reconfig = []
    if not egate_console_log:
        egate_console_log = BuiltIn().get_variable_value('${EGATE_CONSOLE_LOG}')

    logger_console("\nCheck RRC Reconfiguration message in {}\n".format(egate_console_log))
    stream = ensure_it_is_file_stream(path_or_stream=egate_console_log)

    stream_list = convert_enum_to_list(enum=stream, without_first_elem=False)
    stream_string = '\n'.join(stream_list)

    regexps = BuiltIn().get_variable_value('${VALIDATION_EGATE_CONSOLE_LOG_REGEXPS}')

    rrc_reconfig += re.findall(pattern=regexps['skipUplinkTxDynamic'], string=stream_string)[1:]
    rrc_reconfig += re.findall(pattern=regexps['enhancedSkipUplinkTxConfigured-r16'], string=stream_string)[1:]
    rrc_reconfig += re.findall(pattern=regexps['cs-RNTI setup'], string=stream_string)

    values = BuiltIn().get_variable_value('${VALIDATION_EGATE_CONSOLE_RRC_RECONFIGURATION_8124}')

    expected_rrc_reconfig = [val for key, val in values.items()]

    __check_if_values_for_8124_are_correct(rrc_reconfig, expected_rrc_reconfig)

    logger_console("Values in RRC Reconfiguration are correct!\n")
