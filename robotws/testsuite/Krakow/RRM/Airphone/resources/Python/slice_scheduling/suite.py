# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:maintainer: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import socket
import time
import os
import re

from robot.libraries.BuiltIn import BuiltIn
from taf.sw.reporting_portal import reporting_portal

from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import (
    run_on_gnb, download_vendor_file, collect_gnb_snapshot, get_mrbts_nrbts_ids, get_fbb_info, get_cells_info,
    get_capability_unit_name, get_gnb_build_release, get_gnb_build
)
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import (
    save_json_file, copy_files_from_local_to_local
)
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import get_current_date, logger_console, logger_warning
from testsuite.Krakow.RRM.Airphone.resources.Python.common_airphone import collect_airphone_snapshot
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import create_dir_at_output_dir
from testsuite.Krakow.RRM.Airphone.resources.Python.common_wts import ensure_eth3_bh_is_ok, ensure_eth4_bh_is_ok

_SYSLOG_ALREADY_STOPPED = False


class DeltaRecommissioningFailureException(Exception):
    pass


class CellWithActivatedFeatureNotInExpectedRangeException(Exception):
    pass


class NoProperSetupDetectedException(Exception):
    pass


class SyslogDoesNotContainLineException(Exception):
    pass


class DifferentNumberOfUesAndSpidValuesException(Exception):
    pass


def sleeping():
    pass


def wait_for_delta_recommissioning():
    time.sleep(120)


def set_variables_based_on_deployment_and_release():
    fbb_info = get_fbb_info()
    unit_name = get_capability_unit_name()
    release = get_gnb_build_release(convert_to_trunk=True)
    build = get_gnb_build(convert_to_trunk=True)
    mrbts, nrbts = get_mrbts_nrbts_ids()

    BuiltIn().set_suite_variable('${UNIT_NAME}', unit_name)
    BuiltIn().set_suite_variable('${FBB_INFO}', fbb_info)
    BuiltIn().set_suite_variable('${RELEASE}', release)
    BuiltIn().set_suite_variable('${SW_VERSION}', build)
    BuiltIn().set_suite_variable('${MRBTS_ID}', mrbts)
    BuiltIn().set_suite_variable('${NRBTS_ID}', nrbts)


def get_cells_id_based_on_cell_tech_and_ue_type(cells_info, cell_deployment):
    """
    Gets cell ids, physical cell id and technology type for all cells in gBN
    :param cells_info: list, list of cell information from webem output of get_cells_info function from common_gnb
    :param cell_deployment: list, list of cell deployment which can be in output, pass like [SA], [SA, SA+NSA]
    :return: dict, dictionary with two list, one representing all TDD cells and the other FDD cells, inside the list
    in tuples for each cell (global_cell_id, physical_cell_id, cell_technology) are given, cells are sorted by
    global_cell_id
    """
    tdd_cells = []
    fdd_cells = []

    for cell in cells_info:
        cell_id = cell["globalCellId"]
        phy_cell_id = cell["physicalCellId"]
        cell_type = cell["cellDepType"]
        if 'FDD' in cell["technology"]:
            fdd_cells.append((cell_id, phy_cell_id, cell_type))
        else:
            tdd_cells.append((cell_id, phy_cell_id, cell_type))

    if cell_deployment:
        fdd_cells = [x for x in fdd_cells if x[2] in cell_deployment]
        tdd_cells = [x for x in tdd_cells if x[2] in cell_deployment]

    return {'FDD': sorted(fdd_cells, key=lambda x: x[0]), 'TDD': sorted(tdd_cells, key=lambda x: x[0])}


def __return_cell_tech(suite=True, cell_tech=None):
    if cell_tech:
        return cell_tech
    if suite:
        name_to_parse = BuiltIn().get_variable_value('${SUITE NAME}')
    else:
        name_to_parse = BuiltIn().get_variable_value('${TEST NAME}')
    if 'FDD' in name_to_parse:
        return 'FDD'
    if 'TDD' in name_to_parse:
        return 'TDD'
    return None


def set_cell_variables_suite(cell_technology=None, cell_deployment=None):
    cells_info = get_cells_info()
    cell_tech = __return_cell_tech(cell_tech=cell_technology)
    cells = get_cells_id_based_on_cell_tech_and_ue_type(cells_info, cell_deployment)
    BuiltIn().set_suite_variable("${CELL_TECHNOLOGY}", cell_tech)
    robot_variables = set_cell_params(cell_tech, cells)
    logger_console(''.join([f"\n{var}: {BuiltIn().get_variable_value(var)}" for var in robot_variables]))


def set_cell_variables_test(cell_technology=None, cell_deployment=None):
    cells_info = get_cells_info()
    cell_tech = __return_cell_tech(suite=False, cell_tech=cell_technology)
    cells = get_cells_id_based_on_cell_tech_and_ue_type(cells_info, cell_deployment)
    BuiltIn().set_suite_variable("${CELL_TECHNOLOGY}", cell_tech)
    robot_variables = set_cell_params(cell_tech, cells)
    logger_console(f''.join([f"\n{var}: {BuiltIn().get_variable_value(var)}" for var in robot_variables]))


def __set_cell_robot_variable(var_name, var_value, suite):
    var_name = "${" + var_name + "}"
    if suite:
        BuiltIn().set_suite_variable(var_name, int(var_value))
    else:
        BuiltIn().set_test_variable(var_name, int(var_value))
    return var_name


def set_cell_params(cell_tech, cells, suite=True):
    robot_variables = []
    if cell_tech:
        cells = cells[cell_tech]
        for index, cell in enumerate(cells):
            global_id, phy_id, _ = cell
            robot_variables.append(__set_cell_robot_variable(f"CELL_{index+1}_ID", global_id, suite))
            robot_variables.append(__set_cell_robot_variable(f"CELL_{index+1}_PCI", phy_id, suite))

        sib_dict = {2: [idx[0] for idx in cells]}
        BuiltIn().set_suite_variable("${SIB_RECEPTION_DICT_SA_SANSA}", sib_dict)
        robot_variables.append("${SIB_RECEPTION_DICT_SA_SANSA}")

        cell_grp_ids = [idx[0]-1 for idx in cells]
        BuiltIn().set_suite_variable("${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}", cell_grp_ids)
        robot_variables.append("${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}")

    if BuiltIn().get_variable_value("${SIB_RECEPTION_DICT_SA_SANSA}") is None:
        logger_warning('No cell technology info provided, no cell variable has been set!')
    return robot_variables


def get_ap_snapshot(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR_TC}')):
    prefix = BuiltIn().get_variable_value('${SNAPSHOT_NAME_PREFIX}')
    filename = prefix + get_current_date() + "_" + "ap.zip"
    collect_airphone_snapshot(output_filepath=os.path.join(output_dir, filename))


def get_gnb_snapshot(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR_TC}')):
    prefix = BuiltIn().get_variable_value('${SNAPSHOT_NAME_PREFIX}')
    filename = prefix + get_current_date() + "_" + "gnb.zip"
    logger_console(output_dir)
    collect_gnb_snapshot(output_filepath=os.path.join(output_dir, filename))


def check_if_any_cell_is_tech(cells, tech):
    num_cells_with_tech = sum([1 for cell in cells if tech in cell['technology']])
    logger_console('Count of {} cells: {}'.format(tech, num_cells_with_tech))
    return num_cells_with_tech


def get_cell_tech_for_variables_setup(cells_info, unit_name):
    tdd_count = check_if_any_cell_is_tech(cells_info, 'TDD')
    fdd_count = check_if_any_cell_is_tech(cells_info, 'FDD')

    if tdd_count:
        return "TDD", "0", "1"
    else:
        return "FDD", "0", "1"


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


def remove_admin_logs_if_exists():
    admin_log_paths = BuiltIn().get_variable_value("${ADMIN_LOG_PATHS}")
    if admin_log_paths is None:
        admin_log_paths = ['/home/ute/robotws/admin_api_default.log', '/home/ute/MN/UTE/robotws/admin_api_default.log']
    for path in admin_log_paths:
        if os.path.exists(path):
            BuiltIn().set_suite_variable("${ADMIN_DESTINATION}", path)
            os.remove(path)
            break


def save_admin_logs_after_tc(output_dir):
    admin_log_paths = BuiltIn().get_variable_value("${ADMIN_LOG_PATHS}")
    if admin_log_paths is None:
        admin_log_paths = ['/home/ute/robotws/admin_api_default.log', '/home/ute/MN/UTE/robotws/admin_api_default.log']
    for path in admin_log_paths:
        if os.path.exists(path):
            prefix = '{}_admin_api_default.log'.format(get_current_date())
            new_path = '{}/{}'.format(output_dir, prefix)
            copy_files_from_local_to_local(path, new_path)
            break


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

    logger_console(f'TC to Rep Portal...\nTC: {tc_title}\nStatus: {status}\npath: {path}\nproject: {project}')
    if status == 'passed':
        rep_url = reporting_portal().report_to_rp(**report)
        logger_console(f'Report has been sent. URL: {rep_url}')
        logger_console('Wait 5s after sending report to prevent being overwritten by the next report')
        time.sleep(5)

    return report


def set_running_testcases(tcs, apx=()):
    if isinstance(tcs, str):
        tcs = [tcs]
    running = dict(zip(list(tcs), ['failed']*len(list(tcs))))
    BuiltIn().set_test_variable("${RUNNING_TESTCASES}", running)
    BuiltIn().set_test_variable("${RUNNING_TESTCASES_APPENDIX}", apx)


def try_to_send_result_to_rep_portal(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
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


def configure_ips_on_eth3_eth4_interfaces(eth3_interfaces=None, eth4_interfaces=None):
    if eth3_interfaces is None:
        eth3_interfaces = ['10.0.1.1', '10.0.1.50', '10.0.1.51', '10.0.1.121', '10.0.1.131', '10.0.1.133', '10.0.1.134',
                           '10.0.1.135', '10.0.1.136', '10.0.1.137']
    if eth4_interfaces is None:
        eth4_interfaces = ['10.0.2.1', '10.0.2.121']
    ensure_eth3_bh_is_ok(eth3_interfaces)
    ensure_eth4_bh_is_ok(eth4_interfaces)
