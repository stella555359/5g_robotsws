# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import os
import re
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities \
    import get_current_date, logger_console
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.mcshark_management \
    import check_mcshark_plugin_present
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.bip_management \
    import create_tshark_command
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management \
    import move_files_from_local_to_local
from validate_functions import check_msg_with_values_in_frame


class BIPError(Exception):
    pass


def split_pcap_txt_to_frames(bip_txt_path, re_frame_pattern=None):
    """Saves filtered bip file to txt file using filter.
    Required:
    :param bip_file: path to bip file to be filtered, if None checks output_dir for bip files
    :param prefix: prefix added to an output file
    :param filters: filters to use by mcshark
    Sets robot variable BIP_TXT_OUTPUT_PATH
    """
    if not re_frame_pattern:
        re_frame_pattern = r'Frame \d+\: \d+ bytes on wire \(\d+ bits\), \d+ bytes captured \(\d+ bits\)'
    re.compile(re_frame_pattern)
    with open(bip_txt_path, 'r') as bip_file:
        bip = bip_file.read()
        return re.split(re_frame_pattern, bip)[1:]


def bip_to_txt_filter(bip_file, prefix, filters=''):
    """Saves filtered bip file to txt file using filter.
    Required:
    :param bip_file: path to bip file to be filtered, if None checks output_dir for bip files
    :param prefix: prefix added to an output file
    :param filters: filters to use by mcshark
    Sets robot variable BIP_TXT_OUTPUT_PATH
    """
    output_dir = __create_output_dir_for_prefix(prefix)
    __save_filtered_pcap_to_txt_file(output_dir, prefix, bip_file, True, filters)
    current_output_txt = BuiltIn().get_variable_value("${BIP_TXT_OUTPUT_PATH}")
    temp = bip_file.split('_')
    if len(temp) > 1:
        data_stamp = '{}_{}'.format(temp[-2], temp[-1].split('.')[0])
    else:
        data_stamp = get_current_date()
    temp = current_output_txt.split('.')[0]
    new_name = '{}_{}.txt'.format(temp, data_stamp)
    move_files_from_local_to_local(current_output_txt, new_name)
    return new_name


def check_message_filter_in_bip(bip_txt_path, message_filter):
    logger_console(f'Checking bip file: {bip_txt_path} has any {message_filter} frame.')
    frames = __prepare_frames(bip_txt_path, message_filter)
    if not frames:
        raise BIPError(f'No frames with {message_filter}.')


def check_all_msgs_in_procent_of_frames_have_value(bip_txt_path, msgs_to_check, values, procent=80,
                                                   message_filter=None, many_groups=False):
    BuiltIn().set_test_variable('${MANY_GROUPS}', many_groups)
    frames = __prepare_frames(bip_txt_path, message_filter)
    logger_console(f'Checking bip file: {bip_txt_path} for messages:\n{msgs_to_check}')
    matches_from_all_frames = __get_all_msgs_from_all_frames(msgs_to_check, frames)
    errs, frames_wo = __how_many_frames_have_values(matches_from_all_frames, values)
    recived = int((1 - frames_wo/len(matches_from_all_frames))*100)
    if recived < int(procent):
        msg = f'Too many frames with wrong messeges, expected {procent}%, but recived  {recived}%,'
        msg = f'{msg} first error:\n{errs[0]}'
        raise BIPError(msg)
    logger_console(f'Frames with wrong messeges {100-recived}%')


def check_msgs_if_first_msgs_has_values(bip_txt_path, msgs_to_check, values, message_filter=None,
                                        many_groups=False):
    BuiltIn().set_test_variable('${MANY_GROUPS}', many_groups)
    frames = __prepare_frames(bip_txt_path, message_filter)[1:]
    logger_console(f'Checking bip file: {bip_txt_path} for messages:\n{msgs_to_check}')
    matches_from_all_frames = __get_all_msgs_from_all_frames(msgs_to_check, frames)
    for frame in matches_from_all_frames:
        first_msg = frame[0]
        if not __check_frame_has_values([first_msg], [values[0]]):
            error = __check_frame_has_values(frame, values)
            if error:
                raise BIPError(error)


def __split_frames_to_msgs(frames, message_filter, msg_regex=r'icom_5g'):
    gathered_msg = list()
    for frame in frames:
        if message_filter in frame:
            gathered_msg.append(frame)
    return gathered_msg


def __save_pcap_to_txt(output_dir, prefix, pcap_path, filters, using_mcshark=True):
    output_path = os.path.join(output_dir, '{}.txt'.format(prefix))
    tshark = create_tshark_command(bip_pcap_file=pcap_path, using_mcshark=using_mcshark, filter_mode=filters,
                                   luashark_path=None, output_path=output_path, syscom_tcp_port=True)
    OperatingSystem().run(tshark)
    return output_path


def __create_output_dir_for_prefix(prefix):
    tsc_output = BuiltIn().get_variable_value("${OUTPUT_DIR_TC}")
    dir_name = os.path.join(tsc_output, prefix)
    OperatingSystem().create_directory(dir_name)
    return dir_name


def __save_filtered_pcap_to_txt_file(output_dir, prefix, pcap_path, using_mcshark=True, filters=''):
    if using_mcshark:
        check_mcshark_plugin_present()
    output_path = __save_pcap_to_txt(output_dir=output_dir, prefix=prefix, pcap_path=pcap_path,
                                     using_mcshark=using_mcshark, filters=filters)
    BuiltIn().set_test_variable("${BIP_TXT_OUTPUT_PATH}", output_path)


def __get_all_msgs_from_all_frames(msgs_to_check, frames):
    matches_from_all_frames = list()
    for frame in frames:
        matches_for_msgs = __get_all_matches_from_frame(msgs_to_check, frame)
        if matches_for_msgs:
            matches_from_all_frames.append(matches_for_msgs)
    if not matches_from_all_frames:
        raise BIPError(f'No messages in any frame!')
    return matches_from_all_frames


def __get_all_matches_from_frame(msgs, frame):
    matches = list()
    for msg in msgs:
        matches += re.findall(msg, frame)
    return matches


def __prepare_frames(bip_txt_path, message_filter):
    frames = split_pcap_txt_to_frames(bip_txt_path)
    if message_filter:
        frames = __split_frames_to_msgs(frames, message_filter)
    return frames


def __check_frames_have_values(matches, values):
    errors, frames_wo_value = __how_many_frames_have_values(matches, values)
    if errors:
        msg = errors[0]
        raise BIPError(msg)


def __how_many_frames_have_values(matches, expected_values):
    frames_wo_value = 0
    errors = list()
    for frame in matches:
        error = __check_frame_has_values(frame, expected_values)
        if error:
            errors.append(error)
            frames_wo_value += 1
    return errors, frames_wo_value


def __check_frame_has_values(frame, expected_values):
    many_groups = BuiltIn().get_variable_value('${MANY_GROUPS}')
    if many_groups:
        return __check_frame_has_values_if_many_groups(frame, expected_values)
    return __check_frame_has_values_if_no_many_groups(frame, expected_values)


def __check_frame_has_values_if_many_groups(frame, expected_values):
    errors = list()
    for group in range(len(frame)):
        matched = frame[group]
        msg_error = __check_frame_has_values_if_no_many_groups(matched, expected_values)
        errors.extend(msg_error)
    return errors


def __check_frame_has_values_if_no_many_groups(frame, expected_values):
    def __check_values_gather_errors(msg_to_check, idx):
        value = expected_values[idx]
        error = check_msg_with_values_in_frame(msg_to_check, value)
        if error:
            errors.append(error)

    idx = 0
    errors = list()
    for msg in frame:
        if isinstance(msg, tuple):
            for group in msg:
                __check_values_gather_errors(group, idx)
                idx += 1
        else:
            __check_values_gather_errors(msg, idx)
            idx += 1
    return errors
