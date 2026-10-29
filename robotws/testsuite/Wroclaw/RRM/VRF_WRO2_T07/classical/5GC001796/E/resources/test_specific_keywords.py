import io
import re
import os
from testsuite.Wroclaw.RRM.resources.log.log import blog
from FdSchedDataProcessor import UlFdSchedData, DlFdSchedData
from TableMatcher import TableMatcher
from testsuite.Wroclaw.RRM.resources.tti_verification.csv_verification import process_needed_messages, \
    filter_list_of_dicts

scf_params_default = {'dllaBlerTarget': '10', 'dllaDeltaCqiMax': '150', 'dllaDeltaCqiMin': '-150',
                      'dllaDeltaCqiStepdown': '250', 'dllaIniMcs': '3', 'actDl256Qam': 'false',
                      'actUl256Qam': 'false', 'actUlDftSOfdm': 'false', 'actDlLaDynBlerTarget': 'false'}
scf_params_no_default = {'dllaBlerTarget': '5', 'dllaDeltaCqiMax': '120', 'dllaDeltaCqiMin': '-130',
                         'dllaDeltaCqiStepdown': '150', 'dllaIniMcs': '5', 'actDl256Qam': 'true',
                         'actUl256Qam': 'false', 'actUlDftSOfdm': 'false'}

syslog_ul_prints_flags = {'0x1003F': ('1', 'UL tput prints'), '0x10040': ('1', 'UL tput prints'),
                          '0x420000': ('1', 'UL tput prints'), '0x10041': ('5', 'UL tput prints')}


def get_average_ul_tput():
    array_ul = []
    directory = '/tmp/btslog2/'

    for file in os.listdir(directory):
        if file.endswith('.LOG'):
            with io.open(os.path.join(directory, file), errors='ignore') as file_log:
                full_file = file_log.readlines()
            ul_logs = _separate_ul_log_messages(full_file)
            array_ul.extend(_get_uplink_values(ul_logs))
    print(array_ul)
    for ul_value in range(int(len(array_ul)/20)):
        array_ul.remove(min(array_ul))
    average_of_ul = sum(array_ul)/float(len(array_ul))
    return average_of_ul*8/(1024.0**2)


def check_max_ul(avg_ul_truput, value):
    assert avg_ul_truput > float(value)


def _separate_ul_log_messages(logs):
    ul_messages = []
    UL_MESSAGE_MARKER = 'L2_LO_UL_0 INF/L2Lo, UlCounterUpdate.cpp'
    for message in logs:
        if UL_MESSAGE_MARKER in message:
            ul_messages.append(message)
    return ul_messages


def _get_uplink_values(uplink_logs):
    UL_MESSAGE_REGEX = r'^.*: (\d+) Bytes received.*$'
    return _get_values_out_of_logs(uplink_logs, UL_MESSAGE_REGEX)


def _get_values_out_of_logs(logs, regex):
    values = []
    for message in logs:
        match = re.search(regex, message)
        if match is None:
            continue
        value = match.groups()[0]
        if int(value) > 0:
            values.append(int(value))
    return values


def check_ul_mcs_mapping(tti_path, mcs_tables, expected_ptrs, expected_qam, expected_bandwidth, expected_rank):
    relevant_messages = process_needed_messages(tti_path, ['ulFdSchedData'])
    relevant_messages = filter_list_of_dicts(array=relevant_messages,
                                             key='ptrsFlagUlProposedMcs',
                                             val=expected_ptrs.upper())
    bad_msg = 0

    for ul_fd_sched_data in relevant_messages:
        processed_msg = UlFdSchedData(ul_fd_sched_data)
        if processed_msg.is_valid == '1':
            t_matcher = TableMatcher(processed_msg, mcs_tables, 'ul', expected_ptrs,
                                     expected_qam, expected_bandwidth, expected_rank)
            if not t_matcher.is_mcs_correct():
                bad_msg += 1
    try:
        error_in_percent = bad_msg * 100 / float(len(relevant_messages))
    except ZeroDivisionError:
        raise Exception('No relevant logs have been found in the collected files.')

    blog('error: {}%.'.format(error_in_percent))
    assert error_in_percent <= 3.0, 'Mapping mcs with mcs from tables does not work properly.'


def check_dl_mcs_mapping(tti_path, mcs_tables, expected_ptrs, expected_qam, expected_bandwidth, expected_rank):
    relevant_messages = process_needed_messages(tti_path, ['dlFdSchedData'])
    relevant_messages = filter_list_of_dicts(array=relevant_messages,
                                             key='ptrsFlagDlProposedMcs',
                                             val=expected_ptrs.upper())
    bad_msg = 0

    for dl_fd_sched_data in relevant_messages:
        processed_msg = DlFdSchedData(dl_fd_sched_data)
        if processed_msg.is_valid == '1':
            t_matcher = TableMatcher(processed_msg, mcs_tables, 'dl', expected_ptrs,
                                     expected_qam, expected_bandwidth, expected_rank)
            if not t_matcher.is_mcs_correct():
                bad_msg += 1
    try:
        error_in_percent = bad_msg * 100 / float(len(relevant_messages))
    except ZeroDivisionError:
        raise Exception('No relevant logs have been found in the collected files.')

    blog('error: {}%.'.format(error_in_percent))
    assert error_in_percent <= 3.0, 'Mapping mcs with mcs from tables is not work properly.'
