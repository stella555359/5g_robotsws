# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import \
    get_current_date, logger_console
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone import \
    collect_airphone_snapshot
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import \
    create_dir_at_output_dir
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    get_ap_swconfig_contents, get_gnb_swconfig_contents, collect_gnb_snapshot, run_on_gnb
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    get_latest_file, save_json_file, change_file_name
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.sherpa_logs import (
    start_collecting_sherpa_traces, stop_collecting_sherpa_traces
)
from robot.libraries.BuiltIn import BuiltIn
from validation_general import is_testcase_from_nsa_c_suite, is_testcase_from_sa_b_suite
import suite_kws_C as suiteC__
import suite_kws_B as suiteB__
import time
import os

_SYSLOG_ALREADY_STOPPED = False


def create_output_dir_tc(tc):
    path = create_dir_at_output_dir(dir_name=tc)
    BuiltIn().set_suite_variable("${OUTPUT_DIR_TC}", path)


def set_variables_based_on_deployment_and_release():
    if is_testcase_from_sa_b_suite():
        suiteB__.set_variables_based_on_deployment_and_release()
        logger_console("Detected type: SA")
    elif is_testcase_from_nsa_c_suite():
        suiteC__.set_variables_based_on_deployment_and_release()
        logger_console("Detected type: NSA")


def set_variables_based_on_tc(additional=None):
    if is_testcase_from_sa_b_suite():
        suiteB__.set_variables_based_on_tc(additional)
    elif is_testcase_from_nsa_c_suite():
        suiteC__.set_variables_based_on_tc(additional)


def wait_for_tput_end_state(seconds):
    logger_console("Waiting for tput end state {} seconds".format(seconds))
    time.sleep(int(seconds))


def wait_for_pdu_session_setup(seconds):
    logger_console("Waiting for pdu session_setup {} seconds".format(seconds))
    time.sleep(int(seconds))


def wait_wts_ready_state_before_x2_link(seconds=200):
    logger_console("Waiting WTS ready state {} seconds".format(seconds))
    time.sleep(int(seconds))


def change_tti_trace_log_pcap_name(file_path):
    prefix = BuiltIn().get_variable_value("${TTITRACE_NAME_PREFIX}")
    prefix += get_current_date() + "_" + os.path.basename(file_path)
    new_file_path = os.path.join(os.path.dirname(file_path), prefix)
    change_file_name(old_name=file_path, new_name=new_file_path)
    logger_console("Changed Tti trace filename from {} to {}".format(file_path, new_file_path))


def __prepare_syslog_prefix():
    prefix = BuiltIn().get_variable_value("${SYSLOG_NAME_PREFIX}")
    prefix += get_current_date() + "_"
    return prefix


def start_syslog_capture(output_dir=BuiltIn().get_variable_value("${OUTPUT_DIR}")):
    prefix = __prepare_syslog_prefix()
    ta5g_syslog_instance = BuiltIn().get_library_instance('ta5g_syslog')
    logger_console("Starting syslog capture with prefix {} ...".format(prefix))
    try:
        ta5g_syslog_instance.start_syslog_for_enb(logs_dirpath=output_dir,
                                                  log_filename_prefix=prefix,
                                                  alias=BuiltIn().get_variable_value('${SYSLOG_ALIAS}'))
    except Exception as err:
        logger_console(type(err))
        logger_console(err)
    logger_console("Waiting for syslog ready state...")
    time.sleep(5)

    syslog_exp = os.path.join(output_dir, prefix) + "*.log"
    syslog_file = get_latest_file(syslog_exp)
    logger_console("Matching regexp {} with file: {}".format(syslog_exp, syslog_file))
    BuiltIn().set_suite_variable("${SYSLOG_OUTPUT_PATH}", syslog_file)


def stop_syslog_capture():
    global _SYSLOG_ALREADY_STOPPED
    if _SYSLOG_ALREADY_STOPPED:
        return

    ta5g_syslog_instance = BuiltIn().get_library_instance('ta5g_syslog')
    ta5g_syslog_instance.collect_syslog_results(alias=BuiltIn().get_variable_value('${SYSLOG_ALIAS}'))
    ta5g_syslog_instance.teardown_all_aliases_for_syslog()
    _SYSLOG_ALREADY_STOPPED = True
    logger_console("Waiting for syslog end state...")
    time.sleep(5)


def get_ap_snapshot(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    prefix = BuiltIn().get_variable_value('${SNAPSHOT_NAME_PREFIX}')
    filename = prefix + get_current_date() + "_" + "ap.zip"
    collect_airphone_snapshot(output_filepath=os.path.join(output_dir, filename))


def get_gnb_snapshot(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    prefix = BuiltIn().get_variable_value('${SNAPSHOT_NAME_PREFIX}')
    filename = prefix + get_current_date() + "_" + "gnb.zip"
    collect_gnb_snapshot(output_filepath=os.path.join(output_dir, filename))


def __set_sherpa_output_path(prefix, output_dir):
    filename = prefix + "_" if prefix[-1:] != "_" else prefix
    filename += BuiltIn().get_variable_value("${SW_VERSION}") + get_current_date() + ".pcap"
    return os.path.join(output_dir, filename)


def start_sherpa_capture(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    path = __set_sherpa_output_path(prefix=BuiltIn().get_variable_value('${SHERPA_PREFIX}'),
                                    output_dir=output_dir)
    BuiltIn().set_suite_variable("${SHERPA_OUTPUT_PATH}", path)
    logger_console("Starting Sherpa Capture: {}".format(BuiltIn().get_variable_value('${SHERPA_OUTPUT_PATH}')))
    start_collecting_sherpa_traces(sherpa_types=BuiltIn().get_variable_value('${SHERPA_TYPES}'),
                                   log_filename=os.path.basename(path),
                                   log_dirpath=output_dir,
                                   eth_interface=BuiltIn().get_variable_value('${SHERPA_ETH_INTERFACE}'),
                                   alias=BuiltIn().get_variable_value('${ALIAS_TSHARK_SHERPA}'))


def stop_sherpa_capture(output_dir_csv=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    output_path = BuiltIn().get_variable_value('${SHERPA_OUTPUT_PATH}')
    logger_console("Stopping Sherpa Capture: {}".format(output_path))
    stop_collecting_sherpa_traces(sherpa_types=BuiltIn().get_variable_value('${SHERPA_TYPES}'),
                                  sherpa_pcap_file_path=output_path,
                                  sherpa_csv_dir=output_dir_csv,
                                  alias=BuiltIn().get_variable_value('${ALIAS_TSHARK_SHERPA}'))


def pkill_tcpdump():
    logger_console("Killing tcpdump...")
    time.sleep(2)
    run_on_gnb(cmd="pkill tcpdump")


def __save_swconfig_to_file(filepath, func):
    logger_console("Saving to file: {}".format(filepath))
    swconfig_content = func()
    with open(filepath, 'w') as file:
        file.write(swconfig_content)


def save_swconfigs_to_files(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    __save_swconfig_to_file(os.path.join(output_dir, 'swconfig_gnb.txt'), get_gnb_swconfig_contents)
    __save_swconfig_to_file(os.path.join(output_dir, 'swconfig_ap.txt'), get_ap_swconfig_contents)


def __send_to_rep_portal(running_tc, status, apx):
    if is_testcase_from_sa_b_suite():
        suiteB__.send_to_rep_portal(running_tc=running_tc, status=status, apx=apx)
    elif is_testcase_from_nsa_c_suite():
        suiteC__.send_to_rep_portal(running_tc=running_tc, status=status, apx=apx)


def try_to_send_result_to_rep_portal(output_dir):
    test_tags = BuiltIn().get_variable_value("${TEST_TAGS}")
    if "SKIP_REPORT" in test_tags or BuiltIn().get_variable_value("${SKIP_REPORT_TO_QC}"):
        logger_console("Skipping QC reporting...")
        return

    running = BuiltIn().get_variable_value("${RUNNING_TESTCASES}")
    apx = BuiltIn().get_variable_value("${RUNNING_TESTCASES_APPENDIX}")
    all_reports = []
    for key, value in running.items():
        report = __send_to_rep_portal(running_tc=key, status=value, apx=apx)
        all_reports.append(report)

    save_json_file(os.path.join(output_dir, "report_qc.json"), all_reports)


def set_tc_status_to_passed(tc):
    running = BuiltIn().get_variable_value('${RUNNING_TESTCASES}')
    running[tc] = 'passed'
    BuiltIn().set_suite_variable("${RUNNING_TESTCASES}", running)
    msg = "Running testcases after passed {}:\n{}".format(tc, BuiltIn().get_variable_value('${RUNNING_TESTCASES}'))
    logger_console(msg)


def create_default_value_quotas(quotas, name):
    default_quota = {"min": '0', "max": '100'}
    BuiltIn().set_suite_variable("${name}", quotas.insert(0, default_quota))


def get_latest_file_with_counters():
    counters_list = BuiltIn().get_variable_value("${COUNTER_DIRECTORY_LIST}", [])
    return counters_list[-1]
