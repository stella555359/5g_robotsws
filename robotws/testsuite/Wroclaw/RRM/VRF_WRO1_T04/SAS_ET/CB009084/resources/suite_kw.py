# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import \
    get_current_date, logger_console, logger_warning
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone import \
    collect_airphone_snapshot
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import \
    create_dir_at_output_dir
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    get_ap_swconfig_contents, get_gnb_swconfig_contents, collect_gnb_snapshot, run_on_gnb, download_vendor_file,
    get_gnb_build_release, get_gnb_build, get_cells_info, get_mrbts_nrbts_ids, get_capability_unit_name, get_fbb_info
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    get_latest_file, save_json_file, change_file_name, copy_files_from_local_to_local
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.sherpa_logs import (
    start_collecting_sherpa_traces, stop_collecting_sherpa_traces
)

from taf.sw.reporting_portal import reporting_portal
from robot.libraries.BuiltIn import BuiltIn
import socket
import time
import os
import re

_SYSLOG_ALREADY_STOPPED = False


class DeltaRecommissioningFailureException(Exception):
    pass


class CellWithActivatedFeatureNotInExpectedRangeException(Exception):
    pass


class NoProperSetupDetectedException(Exception):
    pass


class SyslogDoesNotContainLineException(Exception):
    pass


def sleeping(): pass


def is_c_testsuite():
    return '-C' in BuiltIn().get_variable_value('${SUITE_NAME}')


def is_e_testsuite():
    return '-E' in BuiltIn().get_variable_value('${SUITE_NAME}')


def is_f_testsuite():
    return '-F' in BuiltIn().get_variable_value('${SUITE_NAME}')


def is_g_testsuite():
    return '-G' in BuiltIn().get_variable_value('${SUITE_NAME}')


def is_h_testsuite():
    return '-H' in BuiltIn().get_variable_value('${SUITE_NAME}')


def __check_if_any_cell_is_tech(cells, tech):
    s = sum([1 for c in cells if tech in c['technology']])
    logger_console("Count of {} cells: {}".format(tech, s))
    return s


def __get_cell_tech_for_variables_setup(cells_info, unit_name):
    tdd_count = __check_if_any_cell_is_tech(cells_info, 'TDD')
    fdd_count = __check_if_any_cell_is_tech(cells_info, 'FDD')
    suite_name = BuiltIn().get_variable_value('${SUITE_NAME}')
    logger_console(suite_name)

    if 'ASIB' in unit_name and fdd_count == 1 and tdd_count == 1:
        logger_console("Assuming BOO_AP_KLLL setup with second cell FDD and first TDD")
        return 'FDD', '1', '2'
    elif 'ASIB' in unit_name and fdd_count in (6, 3) and tdd_count == 0:
        logger_console("Assuming BOO_AP_LOO setup for PRB+DSS")
        return 'FDD', '1', '2'
    elif 'ASIB' in unit_name and fdd_count == 4 and tdd_count == 2:
        logger_console("Assuming BOO_AP_KLLL setup with four cells FDD and two TDD")
        return 'FDD', '0', '1'
    elif 'ASIB' in unit_name and fdd_count == 1:
        logger_console("Assuming BL_AP_KL setup with one cell FDD")
        return 'FDD', '0', '1'
    elif 'ASIB' in unit_name and fdd_count == 2:
        logger_console("Assuming BO_AP_KL setup with two cells FDD")
        return 'FDD', '0', '1'
    elif 'ASIB' in unit_name and tdd_count == 2:
        logger_console("Assuming BL_AP_KL setup with two cells TDD")
        return 'TDD', '0', '1'
    elif 'ASIL' in unit_name and (tdd_count == 2 and fdd_count == 0):
        logger_console("Assuming LO_AP_LO setup with two cells TDD")
        return "TDD", '0', '1'
    elif 'ASIL' in unit_name and (fdd_count == 2 and tdd_count == 0):
        logger_console("Assuming LO_AP_LO setup with two cells FDD")
        return "FDD", '0', '1'
    elif 'ASIL' in unit_name and fdd_count == 3:
        logger_console("Assuming LO_AP_LOOO setup with three cells FDD")
        return "FDD", '0', '1'
    elif 'ASIL' in unit_name and fdd_count == 2 and tdd_count == 2:
        logger_console("Assuming LO_AP_LO setup with two cells FDD and two cells TDD")
        if 'FDD' in suite_name or 'DSS' in suite_name:
            return "FDD", '2', '3'
        else:
            return "TDD", '0', '1'

    msg = "No setup information!"
    logger_warning(msg)
    raise NoProperSetupDetectedException(msg)


def __print_set_variables_based_on_deployment_and_release():
    logger_console(
        "Detected configuration: {}\n".format(BuiltIn().get_variable_value('${UNIT_NAME}')) +
        "Release: {}\n".format(BuiltIn().get_variable_value('${RELEASE}')) +
        "SW Version: {}\n".format(BuiltIn().get_variable_value('${SW_VERSION}')) +
        "Cell Tech: {}\n".format(BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')) +
        "nrBtsId: {}\n".format(BuiltIn().get_variable_value('${NRBTS_ID}')) +
        "mrBtsId: {}\n".format(BuiltIn().get_variable_value('${MRBTS_ID}')) +
        "unit_name: {}\n".format(BuiltIn().get_variable_value('${UNIT_NAME}')) +
        "fbb_info: {}\n".format(BuiltIn().get_variable_value('${FBB_INFO}'))
    )


def set_variables_based_on_deployment_and_release():
    cells_info = get_cells_info()
    unit_name = get_capability_unit_name()
    fbb_info = get_fbb_info()
    release = get_gnb_build_release(convert_to_trunk=True)
    build = get_gnb_build(convert_to_trunk=True)
    ips = BuiltIn().get_variable_value('${UE_IP_DL}')
    thput = BuiltIn().get_variable_value('${TPUT}')
    deltas = BuiltIn().get_variable_value('${DELTAS}')
    wts_cfg = BuiltIn().get_variable_value('${WTS_CONFIGS}')
    cell_tech, cell_id, cell_id_inc = __get_cell_tech_for_variables_setup(cells_info=cells_info, unit_name=unit_name)
    mrbts, nrbts = get_mrbts_nrbts_ids()
    cell_grp_ids = [0] if 'ASIB' in unit_name and '0' in cell_id else [0, 1]

    BuiltIn().set_suite_variable("${MRBTS_ID}", mrbts)
    BuiltIn().set_suite_variable("${NRBTS_ID}", nrbts)
    BuiltIn().set_suite_variable("${UNIT_NAME}", unit_name)
    BuiltIn().set_suite_variable("${FBB_INFO}", fbb_info)
    BuiltIn().set_suite_variable("${RELEASE}", release)
    BuiltIn().set_suite_variable("${SW_VERSION}", build)
    BuiltIn().set_suite_variable("${CELL_TECHNOLOGY}", cell_tech)
    BuiltIn().set_suite_variable("${DELTA_MAX_OVER_100}", deltas[cell_tech]['max_over_100'])
    BuiltIn().set_suite_variable("${DELTA_MIN_OVER_100}", deltas[cell_tech]['min_over_100'])
    BuiltIn().set_suite_variable("${DELTA_MIN_OVER_MAX}", deltas[cell_tech]['min_over_max'])
    if cell_tech == 'TDD':
        BuiltIn().set_suite_variable("${DELTA_6NSA_20SA}", deltas[cell_tech]['6nsa_20sa'])
        BuiltIn().set_suite_variable("${DELTA_7NSA_21SA}", deltas[cell_tech]['7nsa_21sa'])
        BuiltIn().set_suite_variable("${DELTA_GRB_ENABLED}", deltas[cell_tech]['grb_enabled'])
        BuiltIn().set_suite_variable("${WTS_CFG_6UE}", wts_cfg[cell_tech]['6UE_ext_traffic'])
        BuiltIn().set_suite_variable("${WTS_CFG_GRB_ENABLED}", wts_cfg[cell_tech]['grb_enabled'])
    if cell_tech == 'FDD':
        BuiltIn().set_suite_variable("${DELTA_6NSA_20SA}", deltas[cell_tech]['6nsa_20sa'])
        BuiltIn().set_suite_variable("${WTS_CFG_6UE}", wts_cfg[cell_tech]['6UE_ext_traffic'])
        BuiltIn().set_suite_variable("${DELTA_PRB_POOLING}", deltas[cell_tech]['pooling'])
        BuiltIn().set_suite_variable("${DELTA_PRB_DSS}", deltas[cell_tech]['prb_dss'])
        BuiltIn().set_suite_variable("${DELTA_DSS}", deltas[cell_tech]['dss'])
        BuiltIn().set_suite_variable("${WTS_CFG_PRB}", wts_cfg[cell_tech]['pooling'])
        BuiltIn().set_suite_variable("${WTS_CFG_PRB_DSS}", wts_cfg[cell_tech]['prb_dss'])
        BuiltIn().set_suite_variable("${WTS_CFG_DSS}", wts_cfg[cell_tech]['dss'])
    BuiltIn().set_suite_variable("${DELTA_F_MU_MIMO}", deltas[cell_tech]['f_mu_mimo'])
    BuiltIn().set_suite_variable("${WTS_CFG_F_MU_MIMO}", wts_cfg[cell_tech]['f_mu_mimo'])
    BuiltIn().set_suite_variable("${MAX_TPUT_F_MU_MIMO}", '600M')
    BuiltIn().set_suite_variable("${DELTA_G_MULTIPLE_BWPS}", deltas[cell_tech]['g_multiple_bwps'])
    BuiltIn().set_suite_variable("${WTS_CFG_G_MULTIPLE_BWPS}", wts_cfg[cell_tech]['g_multiple_bwps'])
    BuiltIn().set_suite_variable("${MAX_TPUT_G_MULTIPLE_BWPS}", '1450' if cell_tech == 'TDD' else '230')
    BuiltIn().set_suite_variable("${DELTA_C_HARQ_RETX}", deltas[cell_tech]['c_harq_retx'])
    BuiltIn().set_suite_variable("${WTS_CFG_C_HARQ_RETX}", wts_cfg[cell_tech]['c_harq_retx'])
    BuiltIn().set_suite_variable("${MAX_TPUT_C_HARQ_RETX}", '212M')
    BuiltIn().set_suite_variable("${DELTA_H_EC2_GBR_LOAD}", deltas[cell_tech]['h_ec2_gbr_load'])
    BuiltIn().set_suite_variable("${WTS_CFG_H_EC2_GBR_LOAD}", wts_cfg[cell_tech]['h_ec2_gbr_load'])
    BuiltIn().set_suite_variable("${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}", cell_grp_ids)
    BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE_WEBEM}", cell_id_inc)
    BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE_EGATE}", cell_id_inc)
    BuiltIn().set_suite_variable("${3UE_IP}", ips[cell_tech][:3])
    BuiltIn().set_suite_variable("${2UE_IP}", ips[cell_tech][:2])
    for i in range(len(ips[cell_tech])):
        BuiltIn().set_suite_variable("$UE_IP_DL_{}".format(i), ips[cell_tech][i])
    BuiltIn().set_suite_variable("${20SA_6NSA_UE_IP}", ips[cell_tech]+ips['NSA'])
    BuiltIn().set_suite_variable("${MAX_TPUT}", thput[cell_tech])
    BuiltIn().set_suite_variable("${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}", cell_grp_ids)

    __print_set_variables_based_on_deployment_and_release()


def __print_set_variables_based_on_tc():
    logger_console(
        "Running Testcases: {}\n".format(BuiltIn().get_variable_value('${RUNNING_TESTCASES}')) +
        "Cell with Slices: {}\n".format(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    )


def __parse_tc_name_and_retrieve_crucial_info(tc_name):
    scfs = BuiltIn().get_variable_value('${SCFS}')
    BuiltIn().set_suite_variable("${BASIC_SCF_FILE}", scfs['basic'])
    tcs = {}
    appendix = ''
    if tc_name is None:
        return tcs, appendix

    # H-EC3
    if "wrong_quotas_configuration" in tc_name:
        tcs['H_EC3'] = 'failed'
    if "GBR_service_enabled" in tc_name:
        tcs['H_B1'] = 'failed'
    # G-B1
    if 'G_B1_slice_aware-scheduler_with_multiple_BWPs' in tc_name:
        tcs['G_B1'] = 'failed'
    # G-EC2
    if 'G_EC2_slice_aware_scheduler_with_smallest_BWP' in tc_name:
        tcs['G_EC2'] = 'failed'
    # E-B101
    if "E-B101_slice_aware_scheduler_with_PRB_Pooling_and_DSS_enabled" in tc_name:
        tcs['EB101_DSS_PRB'] = 'failed'
        BuiltIn().set_suite_variable("${BASIC_SCF_FILE}", scfs['custom'])
    if "E-B101_slice_aware_scheduler_with_DSS_enabled" in tc_name:
        tcs['EB101_DSS'] = 'failed'
        BuiltIn().set_suite_variable("${BASIC_SCF_FILE}", scfs['custom'])
    if 'E-B101_slice_aware_scheduler_with_PRB_Pooling_enabled' in tc_name:
        tcs['EB101_PRB'] = 'failed'
        BuiltIn().set_suite_variable("${BASIC_SCF_FILE}", scfs['custom'])
    # F-B1
    if "FB1_slice" in tc_name:
        tcs['FB1'] = 'failed'
    # C-B101 and C-B102
    if "C_003_B102_allocated_PRBs_for_NSA_counters_FDD" in tc_name:
        tcs['B101'] = 'failed'
        tcs['B102'] = 'failed'
        tcs['B301'] = 'failed'
    # C-B101 max possible slices
    if "EC1" in tc_name:
        tcs['EC1'] = 'failed'
    # C-B501 reTX
    if 'reTX_01' in tc_name:
        tcs['reTX_01'] = 'failed'
    if 'reTX_02' in tc_name:
        tcs['reTX_02'] = 'failed'
    if 'H-EC2_slice_aware_scheduler_with_excessive_gbr_load_FDD' in tc_name:
        tcs['H_EC2_GBR_LOAD'] = "failed"

    return tcs, appendix


def set_variables_based_on_tc(additional=None):
    tcs, apx = __parse_tc_name_and_retrieve_crucial_info(BuiltIn().get_variable_value('${TEST_NAME}'))
    tcs_add, apx_add = __parse_tc_name_and_retrieve_crucial_info(additional)
    tcs.update(tcs_add)
    cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')

    BuiltIn().set_suite_variable("${RUNNING_TESTCASES}", tcs)
    BuiltIn().set_suite_variable("${RUNNING_TESTCASES_APPENDIX}", apx)
    if cell_tech == 'TDD':
        BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE}", '0')
    else:
        BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE}", '2')

    __print_set_variables_based_on_tc()


def create_output_dir_tc(tc):
    path = create_dir_at_output_dir(dir_name=tc)
    BuiltIn().set_suite_variable("${OUTPUT_DIR_TC}", path)


def __wait_for_sth(seconds, msg):
    logger_console(msg)
    logger_warning(msg)
    time.sleep(int(seconds))


def wait_before_ue_attach(seconds, msg_info="Waiting for {} seconds to attach UE"):
    msg = msg_info.format(seconds)
    __wait_for_sth(seconds, msg)


def wait_before_tput(seconds, msg_info="Waiting for {} seconds to start tput"):
    msg = msg_info.format(seconds)
    __wait_for_sth(seconds, msg)


def wait_for_tput_end_state(seconds, msg_info="Waiting for tput end state {} seconds"):
    msg = msg_info.format(seconds)
    __wait_for_sth(seconds, msg)


def wait_for_logs_proper_format(seconds, msg_info='Waiting for logs proper format state {} seconds'):
    msg = msg_info.format(seconds)
    __wait_for_sth(seconds, msg)


def wait_for_bler_in_counters_visibility(seconds, msg_info="Waiting for BLER in counters visibility {} seconds"):
    msg = msg_info.format(seconds)
    __wait_for_sth(seconds, msg)


def wait_for_starting_wts_procedure(seconds, msg_info='Waiting for WTS starting procedure end state {} seconds'):
    msg = msg_info.format(seconds)
    __wait_for_sth(seconds, msg)


def wait_for_gnb_partnerships_ready_state(seconds, msg_info='Waiting for gNB DSS partnerships ready state {} seconds'):
    msg = msg_info.format(seconds)
    __wait_for_sth(seconds, msg)


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


def remove_admin_logs_if_exists():
    admin_log_paths = BuiltIn().get_variable_value("${ADMIN_LOG_PATHS}")
    for path in admin_log_paths:
        if os.path.exists(path):
            BuiltIn().set_suite_variable("${ADMIN_DESTINATION}", path)
            os.remove(path)
            break


def save_admin_logs_after_tc(output_dir):
    admin_log_paths = BuiltIn().get_variable_value("${ADMIN_LOG_PATHS}")
    for path in admin_log_paths:
        if os.path.exists(path):
            prefix = '{}_admin_api_default.log'.format(get_current_date())
            new_path = '{}/{}'.format(output_dir, prefix)
            copy_files_from_local_to_local(path, new_path)
            break


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


def check_msg_in_syslog(msg):
    syslog_path = BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}')
    new_syslog_path = "{}_{}.log".format(syslog_path.strip(".log"), msg)
    found_msg = None
    with open(syslog_path, 'r') as syslog_file:
        syslog = syslog_file.read()
        for line in syslog:
            if msg in line:
                found_msg = "Found message {} in syslog {}".format(msg, syslog_path)
                logger_console(found_msg)
                break
    if found_msg is None:
        raise SyslogDoesNotContainLineException("Message {} not foound in syslog {}".format(msg, syslog_path))
    copy_files_from_local_to_local(syslog_path, new_syslog_path)


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


def __overwrite_vendor_file(vendor_dict, gnb_vendor_file, vendor_file_path):
    flags = [False, False]
    with open(gnb_vendor_file, 'r') as gnb_vendor_obj:
        gnb_vendor = gnb_vendor_obj.readlines()
        with open(vendor_file_path, 'w+') as vendor_file:
            for line in gnb_vendor:
                line_to_save, flags = __get_line_to_save(vendor_dict, line, flags)
                vendor_file.write(line_to_save)


def __get_line_to_save(vendor_dict, line, flags):
    new_line_template = '          <p name="{}">{}</p>\n'
    new_line = line
    if re.search(r'bbHwVariant">ABIO<\/p>', line):
        flags[0] = True
    if flags[0] and re.search(r'"bbL1SpPrbCapacityId">1<', line):
        flags[1] = True
    if all(flags):
        for key, value in vendor_dict.items():
            if key in line:
                new_line = new_line_template.format(key, value)
        if 'maxNumStreamPrbUlL1Sp' in line:
            flags = [False, False]
    return new_line, flags


def rewrite_vendor_file(vendor_file_path):
    gnb_vendor_file = BuiltIn().get_variable_value("${VENDOR_GNB}")
    download_vendor_file(gnb_vendor_file)
    if 'DSS' in vendor_file_path:
        vendor_dict = BuiltIn().get_variable_value("${VENDOR_DSS_DICT}")
    else:
        vendor_dict = BuiltIn().get_variable_value("${VENDOR_PRB_DICT}")
    __overwrite_vendor_file(vendor_dict, gnb_vendor_file, vendor_file_path)


def change_setup_from_l1bypass_to_fs():
    cmd = r'echo "tag -fd app.btsom.nts.L1BypassMap" | nc 0 15007'
    logger_console('Changing setup from L1Bypass to Fullstack with command {}'.format(cmd))
    rc, output = run_on_gnb(cmd)
    logger_console("Command output: {}".format(output))
    msg = r"'app.btsom.nts.L1BypassMap' succesfully deleted"
    if msg not in output:
        raise NoProperSetupDetectedException("Couldn't change setup version to Fullstack")


def __retrieve_tc_title(cell_tech, tc_titles, running_tc, apx):
    try:
        logger_console("Trying to return TC title {} with cell technology {}".format(running_tc, cell_tech))
        return tc_titles[cell_tech][running_tc + "_" + apx if apx else running_tc]
    except KeyError as e:
        logger_console("Trying to return TC title {} without cell technology".format(running_tc))
        return tc_titles[running_tc + "_" + apx if apx else running_tc]


def send_to_rep_portal(running_tc, status, apx):
    report_qc = BuiltIn().get_variable_value("${REPORT_QC}")
    testcases_titles = BuiltIn().get_variable_value("${QC_TESTCASES_TITLES}")
    qc_dir_names = BuiltIn().get_variable_value("${QC_DIR_NAMES}")
    release = BuiltIn().get_variable_value("${RELEASE}")
    sw_version = BuiltIn().get_variable_value('${SW_VERSION}')
    cell_tech = BuiltIn().get_variable_value("${CELL_TECHNOLOGY}")
    suite_path = BuiltIn().get_variable_value("${SUITE_SOURCE}")
    test_line = socket.gethostname().replace('-', '_')
    path = qc_dir_names[release][running_tc]['path']
    project = qc_dir_names[release][running_tc]['project']
    tc_title = __retrieve_tc_title(cell_tech, testcases_titles, running_tc, apx)

    report = report_qc.copy()
    report['qc_testlab_path'] = path
    report['qc_test_set_name'] = project
    report['features_covered'] = [project]
    report["testline"] = test_line
    report["build"] = sw_version
    report["qc_id"] = None
    report["tool"] = 'Robot'
    report["hw_id"] = ''
    report["name"] = tc_title
    report["qc_test_instance_name"] = tc_title
    report["suite_path"] = suite_path
    report["result"] = status

    rep_url = reporting_portal().report_to_rp(**report)

    msg = "Sending TC to Rep Portal...\nTC: {}\nStatus: {}\nURL: {}\npath: {}\nproject: {}"
    logger_console(msg.format(tc_title, status, rep_url, path, project))
    logger_console('Wait 5s after sending report to prevent being overwritten by the next report')
    time.sleep(5)

    return report


def try_to_send_result_to_rep_portal(output_dir):
    test_tags = BuiltIn().get_variable_value("${TEST_TAGS}")
    if "SKIP_REPORT" in test_tags or BuiltIn().get_variable_value("${SKIP_REPORT_TO_QC}"):
        logger_console("Skipping QC reporting...")
        return

    running = BuiltIn().get_variable_value("${RUNNING_TESTCASES}")
    apx = BuiltIn().get_variable_value("${RUNNING_TESTCASES_APPENDIX}")
    all_reports = []
    for key, value in running.items():
        report = send_to_rep_portal(running_tc=key, status=value, apx=apx)
        all_reports.append(report)

    save_json_file(os.path.join(output_dir, "report_qc.json"), all_reports)


def set_tc_status_to_passed(tc):
    running = BuiltIn().get_variable_value('${RUNNING_TESTCASES}')
    running[tc] = 'passed'
    BuiltIn().set_suite_variable("${RUNNING_TESTCASES}", running)
    msg = "Running testcases after passed {}:\n{}".format(tc, BuiltIn().get_variable_value('${RUNNING_TESTCASES}'))
    logger_console(msg)


def get_latest_file_with_counters():
    counters_list = BuiltIn().get_variable_value("${COUNTER_DIRECTORY_LIST}", [])
    return counters_list[-1]
