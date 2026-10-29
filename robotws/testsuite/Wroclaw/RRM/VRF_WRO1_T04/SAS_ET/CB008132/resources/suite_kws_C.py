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
import os


_SYSLOG_ALREADY_STOPPED = False


class DeltaRecommissioningFailureException(Exception):
    pass


class CellWithActivatedFeatureNotInExpectedRangeException(Exception):
    pass


class NoProperSetupDetectedException(Exception):
    pass


def sleeping():
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
    elif 'ASIL' in unit_name and (tdd_count == 2 and fdd_count == 0):
        logger_console("Assuming LO_AP_LO setup with two cells TDD")
        return "TDD", '0', '1'
    elif 'ASIL' in unit_name and (fdd_count == 2 and tdd_count == 0):
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
        "SW Version: {}\n".format(BuiltIn().get_variable_value('${SW_VERSION}')) +
        "WTS cfg: {}\n".format(BuiltIn().get_variable_value('${WTS_CFG}')) +
        "WTS C 3PLMN cfg: {}\n".format(BuiltIn().get_variable_value('${WTS_CFG_C_3PLMN}')) +
        "WTS cfg VONR: {}\n".format(BuiltIn().get_variable_value('${WTS_CFG_VONR}')) +
        "WTS cfg 1PLMN: {}\n".format(BuiltIn().get_variable_value('${WTS_CFG_CA_1PLMN}')) +
        "Cell Tech: {}\n".format(BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')) +
        "ue_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_1}')) +
        "ue_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_2}')) +
        "ue_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_3}')) +
        "ue_ip_dl: {}\n".format(BuiltIn().get_variable_value('${UE_IP_DL_4}')) +
        "Max Tput: {}\n".format(BuiltIn().get_variable_value('${MAX_TPUT}')) +
        "nrBtsId: {}\n".format(BuiltIn().get_variable_value('${NRBTS_ID}')) +
        "mrBtsId: {}\n".format(BuiltIn().get_variable_value('${MRBTS_ID}')) +
        "Delta CA 3PLMN 3slices: {}\n".format(BuiltIn().get_variable_value('${DELTA_CA_3PLMN_3SLICES}')) +
        "Delta VONR: {}\n".format(BuiltIn().get_variable_value('${DELTA_VONR}')) +
        "Delta 1 PLMN: {}\n".format(BuiltIn().get_variable_value('${DELTA_CA_1PLMN_2SLICES}'))
    )


def set_variables_based_on_deployment_and_release():
    cells_info = get_cells_info()
    unit_name = get_capability_unit_name()
    release = get_gnb_build_release(convert_to_trunk=True)
    build = get_gnb_build(convert_to_trunk=True)
    deltas = BuiltIn().get_variable_value('${DELTAS}')
    wts_cfg = BuiltIn().get_variable_value('${WTS_CONFIGS}')
    ue_ip = BuiltIn().get_variable_value('${UE_IP_DL}')
    plmns = BuiltIn().get_variable_value('${PLMN_PER_RESOURCE_GROUP}')
    cell_tech, cell_id, cell_id_inc = __get_cell_tech_for_variables_setup(cells_info=cells_info, unit_name=unit_name)
    mrbts, nrbts = get_mrbts_nrbts_ids()
    tput_margin = BuiltIn().get_variable_value('$COUNTER_TPUT_MARGIN')
    cell_grp_ids = [0] if '0' in cell_id else [2]

    BuiltIn().set_suite_variable("${UNIT_NAME}", unit_name)
    BuiltIn().set_suite_variable("${RELEASE}", release)
    BuiltIn().set_suite_variable("${SW_VERSION}", build)
    BuiltIn().set_suite_variable("${CELL_TECHNOLOGY}", cell_tech)
    BuiltIn().set_suite_variable("${WTS_CFG}", wts_cfg['NSA'][cell_tech]['default'])
    BuiltIn().set_suite_variable("${WTS_CFG_VONR}", wts_cfg['NSA'][cell_tech]['VONR'])
    BuiltIn().set_suite_variable("${WTS_CFG_CA_1PLMN}", wts_cfg['NSA'][cell_tech]['CA_1PLMN'])
    BuiltIn().set_suite_variable("${WTS_CFG_C_3PLMN}", wts_cfg['NSA'][cell_tech]['c_3plmn'])
    BuiltIn().set_suite_variable("${WTS_CFG_DL_PRB_SHARE}", wts_cfg['NSA'][cell_tech]['dl_prb_share'])
    BuiltIn().set_suite_variable("${MAX_TPUT}", '1400m' if 'TDD' in cell_tech else '200m')
    BuiltIn().set_suite_variable("${MAX_INTERNAL_TPUT}", '175' if 'TDD' in cell_tech else '150')
    BuiltIn().set_suite_variable("${MAX_TPUT_VAL}", '1400' if 'TDD' in cell_tech else '212')
    BuiltIn().set_suite_variable("${MAX_TPUT_PLMNS}", '500m')
    BuiltIn().set_suite_variable("${UE_IP_DL_1}", ue_ip[cell_tech][0])
    BuiltIn().set_suite_variable("${UE_IP_DL_2}", ue_ip[cell_tech][1])
    BuiltIn().set_suite_variable("${UE_IP_DL_3}", ue_ip[cell_tech][2])
    BuiltIn().set_suite_variable("${UE_IP_DL_4}", ue_ip[cell_tech][3])
    BuiltIn().set_suite_variable("${DELTA_DEFAULT_2SLICES}", deltas['NSA'][cell_tech]['2nsa_slices'])
    BuiltIn().set_suite_variable("${DELTA_CA_3PLMN_3SLICES}", deltas['NSA'][cell_tech]['ca_3plmn_3slices'])
    BuiltIn().set_suite_variable("${DELTA_1_NSA_1SA_SLICE}", deltas['NSA'][cell_tech]['1nsa_1sa_slice'])
    BuiltIn().set_suite_variable("${DELTA_1NSA_SLICE}", deltas['NSA'][cell_tech]['1nsa_slice'])
    BuiltIn().set_suite_variable("${DELTA_3NSA_SLICE}", deltas['NSA'][cell_tech]['3nsa_1sa_slice'])
    BuiltIn().set_suite_variable("${DELTA_6NSA_SLICE}", deltas['NSA'][cell_tech]['6nsa_slice'])
    BuiltIn().set_suite_variable("${DELTA_CA_1PLMN_2SLICES}", deltas['NSA'][cell_tech]['ca_1plmn_2slices'])
    BuiltIn().set_suite_variable("${DELTA_VONR}", deltas['NSA'][cell_tech]['vonr'])
    BuiltIn().set_suite_variable("${DELTA_DL_PRB_1NSA_2SA_SLICES}",
                                 deltas['NSA'][cell_tech]['dl_prb_share_1_nsa_2_sa_slices'])
    BuiltIn().set_suite_variable("${DELTA_DL_PRB_3NSA_SLICES}", deltas['NSA'][cell_tech]['dl_prb_share_3_nsa_slices'])
    BuiltIn().set_suite_variable("${DELTA_CHANGE_SNSSAI_2_TO_4}", deltas['SA'][cell_tech]['change_2_to_4_slice'])
    BuiltIn().set_suite_variable("${MRBTS_ID}", mrbts)
    BuiltIn().set_suite_variable("${NRBTS_ID}", nrbts)
    BuiltIn().set_suite_variable("${RESOURCE_GROUP_ID_1}", plmns['RESOURCE_GROUP_ID_1'])
    BuiltIn().set_suite_variable("${RESOURCE_GROUP_ID_2}", plmns['RESOURCE_GROUP_ID_2'])
    BuiltIn().set_suite_variable("${RESOURCE_GROUP_ID_3}", plmns['RESOURCE_GROUP_ID_3'])
    BuiltIn().set_suite_variable("${THROUGHPUT_MARGIN}", tput_margin)
    BuiltIn().set_suite_variable("${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}", cell_grp_ids)
    BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE}", cell_id)
    BuiltIn().set_suite_variable("${CELL_WITH_ACTIVATED_FEATURE_INCREASED}", cell_id_inc)

    if release == "SBTS22R4":
        BuiltIn().set_suite_variable("${DELTA_CA_1PLMN_2SLICES}",
                                     BuiltIn().get_variable_value('${DELTA_CA_1PLMN_2SLICES_22R4}'))
        BuiltIn().set_suite_variable("${DELTA_CA_3PLMN_3SLICES}",
                                     BuiltIn().get_variable_value('${DELTA_CA_3PLMN_3SLICES_22R4}'))

    __print_set_variables_based_on_deployment_and_release()


def __print_set_variables_based_on_tc():
    logger_console(
        "Running Testcases: {}\n".format(BuiltIn().get_variable_value('${RUNNING_TESTCASES}')) +
        "Cell with Slices: {}\n".format(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')) +
        "Cell with Slices Inc: {}\n".format(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE_INCREASED}'))
    )


def __parse_tc_name_and_retrieve_crucial_info(tc_name):
    tcs = {}
    appendix = ''
    if tc_name is None:
        return tcs, appendix
    if "C_001_B101" in tc_name:
        tcs['C101'] = 'failed'
    if "C_017" in tc_name:
        tcs['C_017'] = 'failed'
    if "C_004_B102" in tc_name:
        tcs['C102'] = 'failed'
    if "C_005_B301" in tc_name:
        tcs['C301'] = 'failed'
        tcs['C011'] = 'failed'
    if 'C_18' in tc_name:
        tcs['C_18'] = 'failed'
    if 'IWK4' in tc_name and 'VoNR' in tc_name:
        tcs['C_VONR'] = 'failed'
    if 'C_013_IWK4' in tc_name and '3plmns' in tc_name:
        tcs['C_CA_3PLMN'] = 'failed'
    if 'C_014_IWK4' in tc_name and '1plmn' in tc_name:
        tcs['C_CA_1PLMN'] = 'failed'
    if 'C_007_B1' in tc_name:
        tcs['C_007_B1'] = 'failed'
    if 'C_010_B2' in tc_name:
        tcs['C_010_B2'] = 'failed'

    return tcs, appendix


def set_variables_based_on_tc(additional=None):
    tcs, apx = __parse_tc_name_and_retrieve_crucial_info(BuiltIn().get_variable_value('${TEST_NAME}'))
    tcs_add, apx_add = __parse_tc_name_and_retrieve_crucial_info(additional)
    tcs.update(tcs_add)
    cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')

    BuiltIn().set_suite_variable("${RUNNING_TESTCASES}", tcs)
    BuiltIn().set_suite_variable("${RUNNING_TESTCASES_APPENDIX}", apx)

    BuiltIn().set_suite_variable("${UE_INFO.11.CELL_ID}", "${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")

    __print_set_variables_based_on_tc()


def send_to_rep_portal(running_tc, status, apx):
    report_qc = BuiltIn().get_variable_value("${REPORT_QC}")
    testcases_titles = BuiltIn().get_variable_value("${QC_TESTCASES_TITLES}")
    qc_dir_names = BuiltIn().get_variable_value("${QC_DIR_NAMES}")
    release = BuiltIn().get_variable_value("${RELEASE}")
    sw_version = BuiltIn().get_variable_value('${SW_VERSION}')
    cell_tech = BuiltIn().get_variable_value("${CELL_TECHNOLOGY}")
    suite_path = BuiltIn().get_variable_value("${CB008132_C_ROBOT_FILE_PATH}")
    test_line = socket.gethostname().replace('-', '_')

    if 'CA_1PLMN' in running_tc or 'CA_3PLMN' in running_tc:  # PLMN TCs dont need cell tech, other TCs need
        tc_title = testcases_titles[running_tc]
    else:
        tc_title = testcases_titles[cell_tech][running_tc + "_" + apx if apx else running_tc]
    report = report_qc.copy()
    report['qc_testlab_path'] = qc_dir_names[release][running_tc]['path']
    report['qc_test_set_name'] = qc_dir_names[release][running_tc]['project']
    report['features_covered'] = [qc_dir_names[release][running_tc]['project']]
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

    logger_console("Sending TC to Rep Portal...\nTC: {}\nStatus: {}\nURL: {}".format(tc_title, status, rep_url))
    logger_console('Wait 5s after sending report to prevent being overwritten by the next report')
    time.sleep(5)

    return report
