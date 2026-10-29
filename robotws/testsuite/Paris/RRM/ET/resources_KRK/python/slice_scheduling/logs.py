# -*- coding: utf-8 -*-
'''
:copyright: Nokia Networks
:mantainer: Mateusz Adamek, Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo, Beata Kapusta
:contact: mateusz.adamek@nokia.com, adrianna.pienkowska@nokia.com, jacek.kozmic@nokia.com, agata.sidlo@nokia.com,
beata.kapusta@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
'''
import os
import re
import time
import shutil
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from testsuite.Paris.RRM.ET.resources_KRK.python.mcshark_management import check_mcshark_plugin_present
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import get_current_date, logger_console
from testsuite.Paris.RRM.ET.resources_KRK.python.common_airphone import collect_airphone_snapshot
from testsuite.Paris.RRM.ET.resources_KRK.python.bip_management import create_tshark_command
from testsuite.Paris.RRM.ET.resources_KRK.python.pm_counters import get_pm_counters_values, wait_for_next_pm_period
from testsuite.Paris.RRM.ET.resources_KRK.python.taf_logs_interface import (
    start_logs_capturing_via_taf, stop_logs_capturing_via_taf
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import (
    get_ap_swconfig_contents, get_gnb_swconfig_contents, collect_gnb_snapshot, run_on_gnb
)
from testsuite.Paris.RRM.ET.resources_KRK.python.file_management import (
    get_latest_file, copy_files_from_local_to_local, change_file_name, move_files_from_local_to_local,
    copy_files_from_gnb, save_json_file
)
from testsuite.Paris.RRM.ET.resources_KRK.python.sherpa_logs import (
    start_collecting_sherpa_traces, stop_collecting_sherpa_traces
)
from testsuite.Paris.RRM.ET.resources_KRK.python.bip_management import (
    start_biplog_collection_from_webem, stop_and_download_biplog_from_webem
)


_SYSLOG_ALREADY_STOPPED = False


class SyslogDoesNotContainLineException(Exception):
    pass


class BipValueNotFound(Exception):
    pass


def get_logs_from_logs_dict(logs_type, step=1):
    """
    Gets logs paths for a given step.
    :param logs_type: str, type of logs which are needed
    :param step: str, from which step logs are needed
    Requires this robot variables:
    LOGS_DICT
    """
    step = int(step) - 1
    logs_dict = BuiltIn().get_variable_value('${LOGS_DICT}')
    logger_console(f'logs_dict {logs_dict[logs_type]} logs_type {logs_type}')
    return logs_dict[logs_type][step]


def __check_paramerters_in_create_logs(required_logs, expanded_logs):
    logs_dict = BuiltIn().get_variable_value('${LOGS_DICT}')
    if not logs_dict:
        logs_dict = dict()
    if not required_logs:
        required_logs = BuiltIn().get_variable_value('${REQUIRED_LOGS}')
    if not required_logs:
        required_logs = []
    elif not isinstance(required_logs, list):
        required_logs = [required_logs]
    if not expanded_logs:
        expanded_logs = BuiltIn().get_variable_value('${EXPANDED_LOGS}')
    if not expanded_logs:
        expanded_logs = []
    elif not isinstance(expanded_logs, list):
        expanded_logs = [expanded_logs]
    return logs_dict, required_logs, expanded_logs


def __save_this_log_path(logs_type, logs_path):
    logs_dict = BuiltIn().get_variable_value('${LOGS_DICT}')
    if logs_type in logs_dict:
        logs_dict[logs_type].append(logs_path)
    else:
        logger_console(f'Log path {logs_path} not saved in LOGS_DICT')
    BuiltIn().set_test_variable('${LOGS_DICT}', logs_dict)


def save_log_paths(logs_type, output_dir=None):
    """
    Adds all logs file of given type in given directory to LOGS_DICT variable.
    Required:
    :param logs_type: str, logs type to collect, ava. BIP, SYSLOG, TTI, TTI_JSON, TTI_CSV_UL, TTI_CSV_DL
                                                      SHERPA, SHERPA_L1L2TRACE, SHERPA_CSV
    Optional:
    :param output_dir: path to directory with log files
    Requires this robot variables:
    LOGS_DICT
    Optional robot variables:
    OUTPUT_DIR_TC - necessary if no output_dir
    """
    logs_dict = BuiltIn().get_variable_value('${LOGS_DICT}')
    if not output_dir:
        output_tsc = BuiltIn().get_variable_value('${OUTPUT_DIR_TC}')
        output_dir = os.path.join(output_tsc, logs_type)
    all_files = OperatingSystem().list_directory(path=output_dir, absolute=True)
    for elem in all_files:
        if logs_type not in logs_dict:
            logs_dict.update({logs_type: list()})
        if elem not in logs_dict[logs_type]:
            logs_dict[logs_type].append(elem)
    BuiltIn().set_test_variable('${LOGS_DICT}', logs_dict)
    logger_console(logs_dict)


def create_logs_dict(required_logs=None, expanded_logs=None):
    """
    If it doesn't already exist, creates LOGS_DICT robot variable to collect logs paths.
    :param required_logs: str or list of needed logs types if none check robot variable, default None
    :param expanded_logs: list, avaiable values ['TTI', 'SHERPA', 'COUNTERS']
        - for SHERPA it adds SHERPA_CSV and SHERPA_L1L2TRACE
        - for TTI it adds TTI_JSON, TTI_CSV_DL, TTI_CSV_UL
        - for COUNTERS it adds COUNTERS_CSV, COUNTERS_JSON instead of COUNTERS
    Optional robot variables:
    REQUIRED_LOGS - necessary if no required_logs
    EXPANDED_LOGS - in place of parameter expanded_logs
    """
    logs_dict, required_logs, expanded_logs = __check_paramerters_in_create_logs(required_logs, expanded_logs)
    for log in required_logs:
        if log in logs_dict:
            continue
        if log == 'SHERPA':
            logs_dict.update({'SHERPA_CSV': list()})
        if expanded_logs:
            if log == 'SHERPA' and log in expanded_logs:
                logs_dict.update({'SHERPA_L1L2TRACE': list()})
            if log == 'TTI' and log in expanded_logs:
                logs_dict.update({'TTI_CSV_DL': list()})
                logs_dict.update({'TTI_CSV_UL': list()})
                logs_dict.update({'TTI_JSON': list()})
                continue
            if log == 'COUNTERS' and log in expanded_logs:
                logs_dict.update({'COUNTERS_CSV': list()})
                logs_dict.update({'COUNTERS_JSON': list()})
                continue
        logs_dict.update({log: list()})
    logger_console(f'logs_dict {logs_dict}')
    BuiltIn().set_test_variable('${LOGS_DICT}', logs_dict)


def __get_bs_sequence(logs_type):
    bs_logs = BuiltIn().get_variable_value('${BS_LOGS_NR}')
    for nr, logs in enumerate(bs_logs, start=1):
        if logs_type == logs:
            bs_logs.remove(logs_type)
            BuiltIn().set_test_variable('${BS_LOGS_NR}', bs_logs)
            return nr


def __set_bs_sequence(logs_type):
    try:
        bs_logs = BuiltIn().get_variable_value('${BS_LOGS_NR}')
        bs_logs.append(logs_type)
        BuiltIn().set_test_variable('${BS_LOGS_NR}', bs_logs)
    except Exception as e:
        BuiltIn().set_test_variable('${BS_LOGS_NR}', [logs_type])


def ng_link_logs_start(options='-i eth3', save_logs=True):
    """
    Starts NG link logs collection.
    :param options: str, options to be passed to tcpdump command, default -i eth3
    :param save_logs: bool, if True saves log paths to LOGS_DICT
    If save_logs is True, requires robot variables:
    LOGS_DICT - dicts with logs paths, this logs collected in NG
    """
    start_logs_capturing_via_taf('tcpdump', hostname=None, options=options)
    create_logs_dict('NG')


def collect_bts_kpi_counters(counter_list, output_csv_dir=None, save_logs=True, prefix=None, pm_period=5, json=True,
                             json_prefix=None):
    """
    Collects KPI counters.
    :param counter_list: list or str, list of counters to collect
    :param output_csv_dir: str, path to direcotry where to save CSV
    :param prefix: str, prefix to be added to CSV file
    :param pm_period: str or number, pm period to wait for coutners to update
    :param json: bool, if True will create json file with coutner values
    :param json_prefix: str, prefix to be added to JSON file
    :param save_logs: bool, if True saves log paths to LOGS_DICT
    If save_logs is True, requires robot variables:
    LOGS_DICT - dicts with logs paths, this logs collected in COUNTERS or COUNTERS_JSON and COUNTERS_CSV
    """
    output_csv_dir, json = __create_coutners_dirs(output_csv_dir, json)
    if not prefix:
        prefix = BuiltIn().get_variable_value('${COUNTER_CSV_PREFIX}')
    output_csv_dir = os.path.join(output_csv_dir, f'{prefix}')
    wait_for_next_pm_period(interval=int(pm_period))
    counters_collected = get_pm_counters_values(counter_ids_list=counter_list, csv_filepath=output_csv_dir)
    csv_file_path = get_latest_file(f'{output_csv_dir}*csv')
    if json:
        json_path = __save_counters_in_json_file(counters_collected, json, json_prefix)
        if save_logs:
            create_logs_dict(['COUNTERS_JSON', 'COUNTERS_CSV'])
            __save_this_log_path('COUNTERS_JSON', json_path)
            __save_this_log_path('COUNTERS_CSV', csv_file_path)
            return
    if save_logs:
        create_logs_dict('COUNTERS')
        __save_this_log_path('COUNTERS', csv_file_path)


def __save_counters_in_json_file(counters_collected, json, json_prefix):
    pm_time = get_current_date()
    if not json_prefix:
        json_prefix = BuiltIn().get_variable_value('${COUNTER_JSON_PREFIX}')
    json_path = os.path.join(json, f'{json_prefix}_{pm_time}.json')
    save_json_file(json_path, counters_collected)
    return json_path


def __create_coutners_dirs(output_csv_dir, json):
    if json:
        output_csv_dir = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'COUNTERS_CSV')
        OperatingSystem().create_directory(output_csv_dir)
        json = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'COUNTERS_JSON')
        OperatingSystem().create_directory(json)
    elif not output_csv_dir:
        output_csv_dir = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'COUNTERS')
        OperatingSystem().create_directory(output_csv_dir)
    return output_csv_dir, json


def ng_link_logs_stop(output_dir=None, save_logs=True):
    """
    Starts NG capture to 'NG' folder.

    :param output_dir: str, path to directory where ng link logs should be collected
    :param save_logs: bool, if True saves path to NG folder
    """
    prefix = BuiltIn().get_variable_value('${NG_NAME_PREFIX}')
    current_date = get_current_date()
    if output_dir is None:
        output_dir = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'NG')
        OperatingSystem().create_directory(output_dir)
    stop_logs_capturing_via_taf('tcpdump', output_dir)
    old_name = os.path.join(output_dir, 'tcpdump/tcpdump.pcap')
    if prefix:
        file_name = f'ng_{prefix}_{current_date}.pcap'
    else:
        file_name = f'ng_{current_date}.pcap'
    new_name = os.path.join(output_dir, file_name)
    move_files_from_local_to_local(old_name, new_name)
    OperatingSystem().remove_directory(os.path.join(output_dir, 'tcpdump'))
    if save_logs:
        __save_this_log_path('NG', new_name)


def __set_bip_output_path(output_dir):
    prefix = BuiltIn().get_variable_value('${BIP_NAME_PREFIX}')
    if prefix is None:
        prefix = 'BIP'
    filename = prefix + get_current_date() + '.pcap'
    return os.path.join(output_dir, filename)


def start_bip_capture():
    """
    Starts bip capture from webem to 'BIP' folder.
    """
    start_biplog_collection_from_webem(names='BIP')
    create_logs_dict('BIP')


def stop_bip_capture(save_logs=True):
    """
    Stops bip capture from webem, adds feature and time signature to collected bip file,
    and saves collected logs to LOGS_DICT.
    Requires this robot variables:
    OUTPUT_DIR_TC
    """
    output_tsc = BuiltIn().get_variable_value('${OUTPUT_DIR_TC}')
    stop_and_download_biplog_from_webem(output_pcap_path=output_tsc, names='BIP')
    new_path = __set_bip_output_path(os.path.join(output_tsc, 'BIP'))
    old_path = output_tsc + '/BIP/bip.pcap'
    copy_files_from_local_to_local(old_path, new_path)
    OperatingSystem().remove_file(old_path)
    if save_logs:
        __save_this_log_path('BIP', new_path)


def change_tti_trace_log_pcap_name(file_path, destination_dir=None):
    """
    Adds feature name and time signature to tti pcap name.
    Required:
    :param file_path: an orginal file path
    Additional:
    :param destination_dir: destination directory if differen than the files
    Requires this robot variables:
    TTITRACE_NAME_PREFIX
    """
    prefix = BuiltIn().get_variable_value('${TTITRACE_NAME_PREFIX}')
    prefix += get_current_date() + '_' + os.path.basename(file_path)
    new_path = file_path
    if destination_dir:
        file_name = file_path.split('/')[-1]
        new_path = os.path.join(destination_dir, file_name)
    new_file_path = os.path.join(os.path.dirname(new_path), prefix)
    change_file_name(old_name=file_path, new_name=new_file_path)
    logger_console('Changed TTI trace filename from {} to {}'.format(file_path, new_file_path))
    OperatingSystem().remove_directory(file_path)


def __prepare_syslog_prefix():
    prefix = BuiltIn().get_variable_value('${SYSLOG_NAME_PREFIX}')
    if prefix is None:
        prefix = 'SYSLOG'
    prefix += get_current_date() + '_'
    return prefix


def start_syslog_capture(output_dir=None):
    """
    Starts syslog capture
    Optional:
    :param output_dir: path to directory where syslog should be collected
    Requires this robot variables:
    SYSLOG_ALIAS
    Optional robot variables:
    OUTPUT_DIR_TC - necessary if no output_dir creates folder in tc output dir
    Sets robot variable:
    SYSLOG_OUTPUT_PATH - path to the collected file
    """
    if not output_dir:
        output_dir = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'SYSLOG')
        OperatingSystem().create_directory(output_dir)
    prefix = __prepare_syslog_prefix()
    ta5g_syslog_instance = BuiltIn().get_library_instance('ta5g_syslog')
    logger_console('Starting syslog capture with prefix {} ...'.format(prefix))
    try:
        ta5g_syslog_instance.start_syslog_for_enb(logs_dirpath=output_dir,
                                                  log_filename_prefix=prefix,
                                                  alias=BuiltIn().get_variable_value('${SYSLOG_ALIAS}'))
    except Exception as err:
        logger_console(err)
    __wait_for_syslog_state('ready')

    syslog_exp = os.path.join(output_dir, prefix) + '*.log'
    syslog_file = get_latest_file(syslog_exp)
    logger_console('Matching regexp {} with file: {}'.format(syslog_exp, syslog_file))
    BuiltIn().set_test_variable('${SYSLOG_OUTPUT_PATH}', syslog_file)
    create_logs_dict('SYSLOG')


def __wait_for_syslog_state(state):
    logger_console('Waiting for syslog {} state...'.format(state))
    time.sleep(5)


def stop_syslog_capture(save_logs=True):
    """
    Stops syslog capture and saves syslog paths in LOGS_DICT
    Requires this robot variables:
    SYSLOG_ALIAS
    LOGS_DICT
    """
    global _SYSLOG_ALREADY_STOPPED
    if _SYSLOG_ALREADY_STOPPED:
        return
    ta5g_syslog_instance = BuiltIn().get_library_instance('ta5g_syslog')
    ta5g_syslog_instance.collect_syslog_results(alias=BuiltIn().get_variable_value('${SYSLOG_ALIAS}'))
    ta5g_syslog_instance.teardown_all_aliases_for_syslog()
    _SYSLOG_ALREADY_STOPPED = True
    __wait_for_syslog_state('end')
    if save_logs:
        logger_console(f"__save_this_log_path('SYSLOG', BuiltIn().get_variable_value('SYSLOG_OUTPUT_PATH'))")
        __save_this_log_path('SYSLOG', BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}'))


def check_msg_in_syslog(msg):
    """
    Checks if message is in syslog logs.

    :param msg: str, Message in logs that will be searched for
    :raises SyslogDoesNotContainLineException: Raises if the message is not found in the syslog logs
    """
    syslog_path = BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}')
    new_syslog_path = '{}_{}.log'.format(syslog_path.strip('.log'), msg)
    found_msg = None
    with open(syslog_path, 'r') as syslog_file:
        syslog = syslog_file.read()
        for line in syslog:
            if msg in line:
                found_msg = 'Found message {} in syslog {}'.format(msg, syslog_path)
                logger_console(found_msg)
                break
    if found_msg is None:
        raise SyslogDoesNotContainLineException('Message {} not foound in syslog {}'.format(msg, syslog_path))
    copy_files_from_local_to_local(syslog_path, new_syslog_path)


def get_ap_snapshot(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    """
    Collects AP snapshot

    :param output_dir: str, Directory where snapshot will be saved
    """
    prefix = BuiltIn().get_variable_value('${SNAPSHOT_NAME_PREFIX}')
    filename = prefix + get_current_date() + '_' + 'ap.zip'
    collect_airphone_snapshot(output_filepath=os.path.join(output_dir, filename))


def get_gnb_snapshot(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    """
    Collects gNB snapshot

    :param output_dir: str, Directory where snapshot will be saved
    """
    prefix = BuiltIn().get_variable_value('${SNAPSHOT_NAME_PREFIX}')
    filename = prefix + get_current_date() + '_' + 'gnb.zip'
    collect_gnb_snapshot(output_filepath=os.path.join(output_dir, filename))


def __set_sherpa_output_path(prefix, output_dir):
    filename = prefix + '_' if prefix[-1:] != '_' else prefix
    filename += BuiltIn().get_variable_value('${SW_VERSION}') + get_current_date()
    BuiltIn().set_test_variable('${SHERPA_FULLNAME}', filename)
    filename += '.pcap'
    return os.path.join(output_dir, filename)


def __save_sherpa_l1l2trace_logs(output_dir_csv, prefix='l1l2trace'):
    l1l2trace_dir = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'SHERPA_L1L2TRACE')
    OperatingSystem().create_directory(l1l2trace_dir)
    new_name = BuiltIn().get_variable_value('${SHERPA_FULLNAME}') + '_' + prefix + '.csv'
    new_path = os.path.join(l1l2trace_dir, new_name)
    old_name = BuiltIn().get_variable_value('${SHERPA_FULLNAME}') + '/micro__l1l2Trace.csv'
    old_path = os.path.join(output_dir_csv, old_name)
    copy_files_from_local_to_local(old_path, new_path)
    return new_path


def start_sherpa_capture(output_dir=None, extended=False):
    """
    Starts sherpa capture
    Optional:
    :param output_dir: str, path to directory where sherpa should be collected
    :param extended: bool, if True SHERPA_L1L2 directory created
    Requires this robot variables:
    SHERPA_PREFIX
    SHERPA_TYPES
    SHERPA_ETH_INTERFACE
    ALIAS_TSHARK_SHERPA
    Optional robot variables:
    OUTPUT_DIR_TC - necessary if no output_dir creates folder in tc output dir
    Sets robot variable:
    SHERPA_OUTPUT_PATH - path to the collected file
    """
    if not output_dir:
        output_dir = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'SHERPA')
        OperatingSystem().create_directory(output_dir)
    path = __set_sherpa_output_path(prefix=BuiltIn().get_variable_value('${SHERPA_PREFIX}'),
                                    output_dir=output_dir)
    BuiltIn().set_test_variable('${SHERPA_OUTPUT_PATH}', path)
    logger_console('Starting Sherpa Capture: {}'.format(BuiltIn().get_variable_value('${SHERPA_OUTPUT_PATH}')))
    start_collecting_sherpa_traces(sherpa_types=BuiltIn().get_variable_value('${SHERPA_TYPES}'),
                                   log_filename=os.path.basename(path),
                                   log_dirpath=output_dir,
                                   eth_interface=BuiltIn().get_variable_value('${SHERPA_ETH_INTERFACE}'),
                                   alias=BuiltIn().get_variable_value('${ALIAS_TSHARK_SHERPA}'))
    create_logs_dict('SHERPA', expanded_logs=['SHERPA' if extended else ''])


def stop_sherpa_capture(output_dir_csv=None, save_logs=True):
    """
    Stops sherpa captrue and saves sherpa paths in LOGS_DICT
    Optional:
    :param output_dir_csv: path to directory where sherpa csv files should be saved
    :param save_logs: boolean, if True saves logs to LOGS_DICT variable
    Requires this robot variables:
    SHERPA_TYPES
    ALIAS_TSHARK_SHERPA
    SHERPA_OUTPUT_PATH - should be set by start_sherpa_capture kw
    Optional robot variables:
    OUTPUT_DIR_TC - necessary if no output_dir creates folder in tc output dir
    LOGS_DICT - necessary if save_logs set to True
    Creates separate directory for csv files (SHERPA_CSV) and l1l2trace.csv file (SHERPA_L1L2TRACE)
    """
    if not output_dir_csv:
        output_dir_csv = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'SHERPA_CSV')
        OperatingSystem().create_directory(output_dir_csv)
    output_path = BuiltIn().get_variable_value('${SHERPA_OUTPUT_PATH}')
    logger_console('Stopping Sherpa Capture: {}'.format(output_path))
    stop_collecting_sherpa_traces(sherpa_types=BuiltIn().get_variable_value('${SHERPA_TYPES}'),
                                  sherpa_pcap_file_path=output_path,
                                  sherpa_csv_dir=output_dir_csv,
                                  alias=BuiltIn().get_variable_value('${ALIAS_TSHARK_SHERPA}'))
    if save_logs:
        __save_this_log_path('SHERPA', BuiltIn().get_variable_value('${SHERPA_OUTPUT_PATH}'))
        __save_this_log_path('SHERPA_CSV', output_dir_csv)
        logs_dict = BuiltIn().get_variable_value('${LOGS_DICT}')
        if 'SHERPA_L1L2TRACE' in logs_dict:
            l1l2_trace_path = __save_sherpa_l1l2trace_logs(output_dir_csv)
            __save_this_log_path('SHERPA_L1L2TRACE', l1l2_trace_path)
        __clean_sherpa_logs_dict()


def __clean_sherpa_logs_dict():
    logs_dict = BuiltIn().get_variable_value('${LOGS_DICT}')
    error_path = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'SHERPA/SavingPackets_tshark_error_log')
    if error_path in logs_dict['SHERPA']:
        logs_dict['SHERPA'].remove(error_path)
    BuiltIn().set_test_variable('${LOGS_DICT}', logs_dict)
    OperatingSystem().remove_file(error_path)


def __save_swconfig_to_file(filepath, func):
    logger_console('Saving to file: {}'.format(filepath))
    swconfig_content = func()
    with open(filepath, 'w') as file:
        file.write(swconfig_content)


def save_swconfigs_to_files(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    """
    Saves AP and gNB swconfigs in txt format

    :param output_dir: str, Directory where snapshot will be saved
    """
    __save_swconfig_to_file(os.path.join(output_dir, 'swconfig_gnb.txt'), get_gnb_swconfig_contents)
    __save_swconfig_to_file(os.path.join(output_dir, 'swconfig_ap.txt'), get_ap_swconfig_contents)


def start_syscom_collection(syscom_file_name='xp_syscom_gnb1_source.pcap'):
    """
        Function for starting collection of syscom on gNB

        :param syscom_file_name: str, filename
    """
    try:
        ssh_instance = ssh()
        ssh_instance.connect_to(hostname='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu')
        ssh_instance.send_command(command='nohup syscomdump -w /tmp/{} >/dev/null 2>&1 &'.format(syscom_file_name))
        logger_console('Syscom collection started successfully')
    finally:
        ssh_instance.disconnect()
    create_logs_dict('SYSCOM')
    OperatingSystem().create_directory(os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'SYSCOM'))


def stop_syscom_collection(output_dir=None, syscom_file_name='xp_syscom_gnb1_source.pcap', save_logs=True):
    """
       Function for stoping collection of syscom and copying it from gNB

       :param output_dir: str, Path where file will be saved
       :param syscom_file_name: str, Filename
       :param save_logs: bool, if True saves paths to SYSCOM folder, default = True
    """
    if not output_dir:
        output_dir = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR_TC}'), 'SYSCOM')
    prefix = BuiltIn().get_variable_value('${SYSCOME_NAME_PREFIX}')
    current_date = get_current_date()
    if prefix:
        syscom_new_name = f'xp_syscom_gnb1_source_{prefix}_{current_date}.pcap'
    else:
        syscom_new_name = f'xp_syscom_gnb1_source_{current_date}.pcap'
    run_on_gnb(cmd=f'pkill -f "syscomdump -w /tmp/{syscom_file_name}"')
    gnb_path = f'/tmp/{syscom_file_name}'
    local_path = os.path.join(output_dir, syscom_new_name)
    copy_files_from_gnb(gnb_path, local_path)
    if save_logs:
        __save_this_log_path('SYSCOM', local_path)
    logger_console('Syscom collection ended successfully')
