# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    get_gnb_build_release, get_gnb_build, get_cells_info, get_mrbts_nrbts_ids, get_capability_unit_name
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console, logger_warning
)
from taf.sw.reporting_portal import reporting_portal
from robot.libraries.BuiltIn import BuiltIn
import socket
import time


class NoProperSetupDetectedException(Exception):
    pass


def __check_if_any_cell_is_tech(cells, tech):
    s = sum([1 for c in cells if tech in c['technology']])
    logger_console("Count of {} cells: {}".format(tech, s))
    return s


def __get_cell_tech_for_variables_setup(cells_info, unit_name):
    tdd_count = __check_if_any_cell_is_tech(cells_info, 'TDD')
    fdd_count = __check_if_any_cell_is_tech(cells_info, 'FDD')
    suite_name = BuiltIn().get_variable_value('${SUITE_NAME}')

    if 'ASIB' in unit_name and fdd_count == 4 and tdd_count == 2:
        logger_console("Assuming BOO_AP_LOO setup with 4 FDD cells and two TDD")
        return 'FDD', '1', '2'
    elif 'ASIB' in unit_name and fdd_count == 1:
        logger_console("Assuming BL_AP_KL setup with one cell FDD")
        return 'FDD', '0', '1'
    elif 'ASIB' in unit_name and fdd_count == 2:
        logger_console("Assuming BO_AP_KL setup with two cells FDD")
        return 'FDD', '0', '1'
    elif 'ASIL' in unit_name and tdd_count == 2 and fdd_count == 0:
        logger_console("Assuming LO_AP_LO setup with two cells TDD")
        return "TDD", '0', '1'
    elif 'ASIL' in unit_name and fdd_count == 2 and tdd_count == 0:
        logger_console("Assuming LO_AP_LO setup with two cells FDD")
        return "FDD", '0', '1'
    elif 'ASIL' in unit_name and fdd_count == 2 and tdd_count == 2:
        logger_console("Assuming LO_AP_LO setup with two cells FDD and two cells TDD")
        if 'TDD' in suite_name:
            return "TDD", '0', '1'
        else:
            return "FDD", '2', '3'

    msg = "No setup information!"
    logger_warning(msg)
    raise NoProperSetupDetectedException(msg)


def __print_set_variables_based_on_deployment_and_release():
    logger_console(
        "Detected configuration: {}\n".format(BuiltIn().get_variable_value('${UNIT_NAME}')) +
        "Release: {}\n".format(BuiltIn().get_variable_value('${RELEASE}')) +
        "Cell Tech: {}\n".format(BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')) +
        "ue_1_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_1}')) +
        "ue_2_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_2}')) +
        "ue_3_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_3}')) +
        "ue_4_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_4}')) +
        "Max Tput: {}\n".format(BuiltIn().get_variable_value('${MAX_TPUT}')) +
        "Max Tput Half: {}\n".format(BuiltIn().get_variable_value('${MAX_TPUT_HALF}')) +
        "nrBtsId: {}\n".format(BuiltIn().get_variable_value('${NRBTS_ID}')) +
        "mrBtsId: {}\n".format(BuiltIn().get_variable_value('${MRBTS_ID}')) +
        "Cell with Slices: {}\n".format(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')) +
        "Cell with Slices Inc: {}\n".format(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE_INCREASED}')) +
        "Cell with Grp Ids List: {}\n".format(BuiltIn().get_variable_value('${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}'))
    )


def set_variables_based_on_deployment_and_release():
    cells_info = get_cells_info()
    unit_name = get_capability_unit_name()
    release = get_gnb_build_release(convert_to_trunk=True)
    release_no_conv = get_gnb_build_release(convert_to_trunk=False)
    build = get_gnb_build(convert_to_trunk=True)
    deltas = BuiltIn().get_variable_value('${DELTAS}')
    wts_cfg = BuiltIn().get_variable_value('${WTS_CONFIGS}')
    ue_ip = BuiltIn().get_variable_value('${UE_IP_DL}')
    cell_tech, cell_id, cell_id_inc = __get_cell_tech_for_variables_setup(cells_info=cells_info, unit_name=unit_name)
    logger_console("Cell ID: {}".format(cell_id))
    cell_grp_ids = [0] if 'ASIB' in unit_name and '0' in cell_id else [0, 1, 2, 3]
    is_tdd = 'TDD' in cell_tech
    mrbts, nrbts = get_mrbts_nrbts_ids()

    BuiltIn().set_suite_variable("${UNIT_NAME}", unit_name)
    BuiltIn().set_suite_variable("${RELEASE}", release)
    BuiltIn().set_suite_variable("${RELEASE_NO_CONV}", release_no_conv)
    BuiltIn().set_suite_variable("${SW_VERSION}", build)
    BuiltIn().set_suite_variable("${CELL_TECHNOLOGY}", cell_tech)
    BuiltIn().set_suite_variable("${WTS_CFG}", wts_cfg['SA'][cell_tech]['default'])
    BuiltIn().set_suite_variable("${WTS_CFG_FDM_BL_KL}", wts_cfg['SA'][cell_tech]['fdm_bl_kl'])
    BuiltIn().set_suite_variable("${WTS_CFG_VONR}", wts_cfg['SA'][cell_tech]['VONR'])
    BuiltIn().set_suite_variable("${WTS_CFG_CA_1PLMN}", wts_cfg['SA'][cell_tech]['CA_1PLMN'])
    BuiltIn().set_suite_variable("${WTS_CFG_CA_3PLMN}", wts_cfg['SA'][cell_tech]['CA_3PLMN'])
    BuiltIn().set_suite_variable("${WTS_CFG_3PLMN}", wts_cfg['SA'][cell_tech]['3plmn'])
    BuiltIn().set_suite_variable("${MAX_TPUT}", '1470m' if is_tdd else '220m')
    BuiltIn().set_suite_variable("${MAX_TPUT_HALF}", '275m' if is_tdd else '110m')
    BuiltIn().set_suite_variable("${MAX_TPUT_VAL}", '1470' if is_tdd else '211')
    BuiltIn().set_suite_variable("${UE_IP_DL_1}", ue_ip[cell_tech][0])
    BuiltIn().set_suite_variable("${UE_IP_DL_2}", ue_ip[cell_tech][1])
    BuiltIn().set_suite_variable("${UE_IP_DL_3}", ue_ip[cell_tech][2])
    BuiltIn().set_suite_variable("${UE_IP_DL_4}", ue_ip[cell_tech][3])
    BuiltIn().set_suite_variable("${DELTA_DEFAULT_2SLICES}", deltas['SA'][cell_tech]['quotas_fdm_setup'])
    BuiltIn().set_suite_variable("${DELTA_WITH_QUOTAS_AND_FDM_ENABLED}", deltas['SA'][cell_tech]['quotas_fdm_setup'])
    BuiltIn().set_suite_variable("${DELTA_WITH_QUOTAS_AND_FDM_DISABLED}", deltas['SA'][cell_tech]['fdm_disabled'])
    BuiltIn().set_suite_variable("${DELTA_VONR}", deltas['SA'][cell_tech]['vonr'])
    BuiltIn().set_suite_variable("${DELTA_3PLMN}", deltas['SA'][cell_tech]['3plmn'])
    BuiltIn().set_suite_variable("${DELTA_CA_1PLMN_3SLICES}", deltas['SA'][cell_tech]['ca_1plmn_3slices'])
    BuiltIn().set_suite_variable("${DELTA_CA_3PLMN_3SLICES}", deltas['SA'][cell_tech]['ca_3plmn_3slices'])
    BuiltIn().set_suite_variable("${DELTA_SETUP_3SLICES_FOR_ONLINE_CHANGE}", deltas['SA'][cell_tech]['change_online1'])
    BuiltIn().set_suite_variable("${DELTA_CHANGE_SNSSAI_2_TO_4}", deltas['SA'][cell_tech]['change_2_to_4_slice'])
    BuiltIn().set_suite_variable("${MRBTS_ID}", mrbts)
    BuiltIn().set_suite_variable("${NRBTS_ID}", nrbts)
    BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE}", cell_id)
    BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE_INCREASED}", cell_id_inc)
    BuiltIn().set_suite_variable("${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}", cell_grp_ids)
    BuiltIn().set_suite_variable("${UE_INFO.1.CELL_ID}", "${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")
    BuiltIn().set_suite_variable("${UE_INFO.2.CELL_ID}", "${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")

    __print_set_variables_based_on_deployment_and_release()


def __print_set_variables_based_on_tc():
    logger_console(
        "Running Testcases: {}\n".format(BuiltIn().get_variable_value('${RUNNING_TESTCASES}')) +
        "Max Tput: {}\n".format(BuiltIn().get_variable_value('${MAX_TPUT}')) +
        "Max Tput Half: {}\n".format(BuiltIn().get_variable_value('${MAX_TPUT_HALF}')) +
        "Thput Expected: {}\n".format(BuiltIn().get_variable_value('${THPUT_EXPECTED_VALUE}')) +
        "Thput Range: {}\n".format(BuiltIn().get_variable_value('${THPUT_RANGE}'))
    )


def __parse_tc_name_and_retrieve_crucial_info(tc_name):
    tcs = {}
    appendix = ''
    if tc_name is None:
        return tcs, appendix
    if "B101" in tc_name:
        tcs['B101'] = 'failed'
    if "B102" in tc_name:
        tcs["B102"] = 'failed'
        if 'fdm' in tc_name:
            appendix += 'fdm_disabled'
    if 'dl_prb_share' in tc_name:
        tcs['B103'] = 'failed'
    if "B104" in tc_name:
        tcs["B104"] = 'failed'
    if 'B601' in tc_name:
        tcs['B601'] = 'failed'
    if 'VoNR' in tc_name:
        tcs['B_VONR'] = 'failed'
    if 'B_014_IWK2' in tc_name:
        tcs['B_CA_1PLMN'] = 'failed'
    if 'B_013_IWK2' in tc_name:
        tcs['B_CA_3PLMN'] = 'failed'
    if 'changing_configuration_online' in tc_name:
        tcs['B021'] = 'failed'

    return tcs, appendix


def set_variables_based_on_tc(additional=None):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    tcs, apx = __parse_tc_name_and_retrieve_crucial_info(test_name)
    tcs_add, apx_add = __parse_tc_name_and_retrieve_crucial_info(additional)
    tcs.update(tcs_add)
    cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')
    is_tdd = 'TDD' in cell_tech
    vonr_and_tdd = 'VoNR' in test_name and is_tdd
    max_tput = '1470m' if vonr_and_tdd else BuiltIn().get_variable_value('${MAX_TPUT}')
    max_tput_half = '250m' if vonr_and_tdd else BuiltIn().get_variable_value('${MAX_TPUT_HALF}')

    BuiltIn().set_suite_variable("${RUNNING_TESTCASES}", tcs)
    BuiltIn().set_suite_variable("${RUNNING_TESTCASES_APPENDIX}", apx)
    BuiltIn().set_suite_variable("${MAX_TPUT}", max_tput)
    BuiltIn().set_suite_variable("${MAX_TPUT_HALF}", max_tput_half)
    BuiltIn().set_suite_variable("${THPUT_EXPECTED_VALUE}", max_tput[:-1])
    BuiltIn().set_suite_variable("${THPUT_RANGE}", '100' if is_tdd else '30')
    __print_set_variables_based_on_tc()


def send_to_rep_portal(running_tc, status, apx):
    report_qc = BuiltIn().get_variable_value("${REPORT_QC}")
    testcases_titles = BuiltIn().get_variable_value("${QC_TESTCASES_TITLES}")
    qc_dir_names = BuiltIn().get_variable_value("${QC_DIR_NAMES}")
    release = BuiltIn().get_variable_value("${RELEASE}")
    sw_version = BuiltIn().get_variable_value('${SW_VERSION}')
    cell_tech = BuiltIn().get_variable_value("${CELL_TECHNOLOGY}")
    suite_path = BuiltIn().get_variable_value("${CB008132_B_ROBOT_FILE_PATH}")
    test_line = socket.gethostname().replace('-', '_')
    path = qc_dir_names[release][running_tc]['path']
    project = qc_dir_names[release][running_tc]['project']

    if 'CA_1PLMN' in running_tc or 'CA_3PLMN' in running_tc:  # PLMN TCs dont need cell tech, other TCs need
        tc_title = testcases_titles[running_tc]
        suite_path = BuiltIn().get_variable_value("${CB008132_B_PLMNS_ROBOT_FILE_PATH}")
    else:
        tc_title = testcases_titles[cell_tech][running_tc + "_" + apx if apx else running_tc]
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
