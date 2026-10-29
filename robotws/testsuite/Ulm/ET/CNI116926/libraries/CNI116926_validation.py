# =====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB011006 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# -----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import json
import re
from tabulate import tabulate

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.SQD68.pmc_analysis import (verify_pm_counters,
                                                           prepare_for_pm_counter_testing,
                                                           finalise_pm_counter_testing)
from testsuite.Ulm.ET.L2.libraries.syslogs_analysis import check_no_fatality_error_in_syslogs

# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


# =====================================================================================================[120 characters]
#   Validation Functions
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_Tput(*args):
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    try:
        expected_tput_dict = {int(cell): {dir_1: int(tput_1), dir_2: int(tput_2)}
                              for cell, dir_1, tput_1, dir_2, tput_2 in (element.split(':') for element in args)}
        logging.info("expected_tput_dict = %s" % json.dumps(expected_tput_dict, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for cell in expected_tput_dict.keys():
                    reported_tput_dl = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_dl']))
                    expected_tput_dl = expected_tput_dict[cell]["dl"]
                    verdicts.append(int(abs(reported_tput_dl-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    reported_tput_ul = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_ul']))
                    expected_tput_ul = expected_tput_dict[cell]["ul"]
                    verdicts.append(int(abs(reported_tput_ul-expected_tput_ul)*100/expected_tput_ul) <= 5)
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        logException("verify_Tput", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_Tput_CA_2cells(tput_string, ca_mode):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # tput_string = "pcell:scell:dir1:tput1:dir2:tput2", e.g. "3:1:dl:500:ul:200"
    # ca_mode = "dlOnly" or "dlAndUl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    logging.info("tput_string = %s" % str(tput_string))
    logging.info("ca_mode = %s" % str(ca_mode))
    try:
        expected_tput_list = [{"pcell": pcell, "scell": scell, dir1: int(tput1), dir2: int(tput2)}
                              for pcell, scell, dir1, tput1, dir2, tput2 in [tput_string.split(':')]]
        logging.info("expected_tput_list = %s" % json.dumps(expected_tput_list, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for ca_set in expected_tput_list:
                    dist_name_pcell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["pcell"]
                    dist_name_scell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell"]
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_dl_pcell = int(round(tput_dict[dist_name_pcell]['throughput_dl']))
                    reported_tput_dl_scell = int(round(tput_dict[dist_name_scell]['throughput_dl']))
                    reported_tput_dl_both = reported_tput_dl_pcell + reported_tput_dl_scell
                    logging.info("reported_tput_dl_both = %s" % (reported_tput_dl_both))
                    expected_tput_dl = ca_set["dl"]
                    verdicts.append(int(abs(reported_tput_dl_both-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_ul_pcell = int(round(tput_dict[dist_name_pcell]['throughput_ul']))
                    reported_tput_ul_scell = int(round(tput_dict[dist_name_scell]['throughput_ul']))
                    reported_tput_ul_both = reported_tput_ul_pcell + reported_tput_ul_scell
                    logging.info("reported_tput_ul_both = %s" % (reported_tput_ul_both))
                    expected_tput_ul = ca_set["ul"]
                    verdicts.append(int(abs(reported_tput_ul_both-expected_tput_ul)*100/expected_tput_ul) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    verdicts.append(reported_tput_dl_scell > 0)  # <--- check that SCell TPut is NOT zero
                    # ---------------------------------------------------------------------------------[120 characters]
                    if ca_mode == "dlAndUl":
                        verdicts.append(reported_tput_ul_scell > 0)  # <--- check that SCell TPut is NOT zero
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        logException("verify_Tput_CA_2cells", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_Tput_CA_4cells(tput_string, ca_mode):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # tput_string = "pcell:scell1:scell2:scell3:dir1:tput1:dir2:tput2", e.g. "4:1:2:3:dl:500:ul:200"
    # ca_mode = "dlOnly" or "dlAndUl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    logging.info("tput_string = %s" % str(tput_string))
    logging.info("ca_mode = %s" % str(ca_mode))
    try:
        expected_tput_list = [{"pcell": pcell,
                               "scell1": scell1, "scell2": scell2, "scell3": scell3,
                               dir1: int(tput1), dir2: int(tput2)}
                              for pcell, scell1, scell2, scell3, dir1, tput1, dir2, tput2 in [tput_string.split(':')]]
        logging.info("expected_tput_list = %s" % json.dumps(expected_tput_list, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for ca_set in expected_tput_list:
                    dist_name_pcell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["pcell"]
                    dist_name_scell1 = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell1"]
                    dist_name_scell2 = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell2"]
                    dist_name_scell3 = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell3"]
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_dl_pcell = int(round(tput_dict[dist_name_pcell]['throughput_dl']))
                    reported_tput_dl_scell1 = int(round(tput_dict[dist_name_scell1]['throughput_dl']))
                    reported_tput_dl_scell2 = int(round(tput_dict[dist_name_scell2]['throughput_dl']))
                    reported_tput_dl_scell3 = int(round(tput_dict[dist_name_scell3]['throughput_dl']))
                    reported_tput_dl_all = (reported_tput_dl_pcell + reported_tput_dl_scell1 +
                                            reported_tput_dl_scell2 + reported_tput_dl_scell3)
                    logging.info("reported_tput_dl_all = %s" % (reported_tput_dl_all))
                    expected_tput_dl = ca_set["dl"]
                    verdicts.append(int(abs(reported_tput_dl_all-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_ul_pcell = int(round(tput_dict[dist_name_pcell]['throughput_ul']))
                    reported_tput_ul_scell1 = int(round(tput_dict[dist_name_scell1]['throughput_ul']))
                    reported_tput_ul_scell2 = int(round(tput_dict[dist_name_scell2]['throughput_ul']))
                    reported_tput_ul_scell3 = int(round(tput_dict[dist_name_scell3]['throughput_ul']))
                    reported_tput_ul_all = (reported_tput_ul_pcell + reported_tput_ul_scell1 +
                                            reported_tput_ul_scell2 + reported_tput_ul_scell3)
                    logging.info("reported_tput_ul_all = %s" % (reported_tput_ul_all))
                    expected_tput_ul = ca_set["ul"]
                    verdicts.append(int(abs(reported_tput_ul_all-expected_tput_ul)*100/expected_tput_ul) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    verdicts.append(reported_tput_dl_scell1 > 0)  # <--- check that SCell-1 TPut is NOT zero
                    verdicts.append(reported_tput_dl_scell2 > 0)  # <--- check that SCell-2 TPut is NOT zero
                    verdicts.append(reported_tput_dl_scell3 > 0)  # <--- check that SCell-3 TPut is NOT zero
                    # ---------------------------------------------------------------------------------[120 characters]
                    if ca_mode == "dlAndUl":
                        verdicts.append(reported_tput_ul_scell1 > 0)  # <--- check that SCell-1 TPut is NOT zero
                        verdicts.append(reported_tput_ul_scell2 > 0)  # <--- check that SCell-2 TPut is NOT zero
                        verdicts.append(reported_tput_ul_scell3 > 0)  # <--- check that SCell-3 TPut is NOT zero
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        logException("verify_Tput_CA_4cells", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_TTITraces_for_raState(cell='1', num_of_ues='10', ue_type='nsa', procedure_type='attach'):
    is_raState_present = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")

    ul_raState = 'ulPreSchedData.raState'
    dl_raState = 'dlPreSchedData.raState'
    preambleType = 'preambleData.preambleType'
    rach_nsa_attach_cbra = ("CBRA-" +
                            "SCHEDULE_MSG2-CT_NONE-INITIALACCESS-" +
                            "AWAIT_MSG3-CT_NONE-INITIALACCESS-" +
                            "SCHEDULE_MSG3_NEW_TX-CT_NONE-INITIALACCESS-" +
                            "MSG3_SCHEDULED-CT_NONE-INITIALACCESS-" +
                            "AWAIT_SCHEDULE_CONTRES_TIMER_EXPIRY-CT_NSAINITIALACCESS-SGNBADDITION-" +
                            "AWAIT_PUSCH_ACK_NACK_FOR_CONT_RES-CT_NSAINITIALACCESS-SGNBADDITION")

    # Procedure of CFRA (Contention Free RACH Procedure) during initial access is described here, please copy the hole
    # string into your web browser
    #
    # https://dn-prod.ext.net.nokia.com/rm/web#action=com.ibm.rdm.web.pages.showArtifactPage&artifactURI=https%3A%2F%2F
    # dn-prod.ext.net.nokia.com%2Frm%2Fresources%2FMD_XiPdAPvREe-AqvopbP1qhQ&artifactInModule=https%3A%2F%2Fdn-prod.ext.
    # net.nokia.com%2Frm%2Fresources%2FBI_TrwSovvcEe-AqvopbP1qhQ&componentURI=https%3A%2F%2Fdn-prod.ext.net.nokia.com%2
    # Frm%2Frm-projects%2F_EuvegO3rEe-rL47x_rCCmw%2Fcomponents%2F_EvmaIO3rEe-rL47x_rCCmw&oslc.configuration=https%3A%2F%
    # 2Fdn-prod.ext.net.nokia.com%2Fgc%2Fconfiguration%2F9
    rach_nsa_attach_cfra = ("CFRA-" +
                            "SCHEDULE_MSG2-CT_NSAINITIALACCESS-SGNBADDITION-" +
                            "AWAIT_MSG3-CT_NSAINITIALACCESS-SGNBADDITION-" +
                            "SCHEDULE_MSG3_NEW_TX-CT_NSAINITIALACCESS-SGNBADDITION-" +
                            "MSG3_SCHEDULED-CT_NSAINITIALACCESS-SGNBADDITION")
    rach_sa_attach = (r"CBRA-" +
                      "SCHEDULE_MSG2-CT_NONE-INITIALACCESS-" +
                      "AWAIT_MSG3-CT_NONE-INITIALACCESS-" +
                      "SCHEDULE_MSG3_NEW_TX-CT_NONE-INITIALACCESS-" +
                      "MSG3_SCHEDULED-CT_NONE-INITIALACCESS-" +
                      "SCHEDULE_MSG4_WITH_DL_CCCH_DATA-CT_SAINITIALACCESS-INITIALACCESS-" +
                      "AWAIT_MSG4_WITH_DL_CCCH_DATA_ACK-CT_SAINITIALACCESS-INITIALACCESS-" +
                      ".*?MSG5-CT_SAINITIALACCESS-INITIALACCESS-" +  # <--- there is .*? !!!
                      "MSG5_SCHEDULED-CT_SAINITIALACCESS-INITIALACCESS")
    rach_sa_reest = (r"CBRA-" +
                     "SCHEDULE_MSG2-CT_NONE-INITIALACCESS-" +
                     "AWAIT_MSG3-CT_NONE-INITIALACCESS-" +
                     "SCHEDULE_MSG3_NEW_TX-CT_NONE-INITIALACCESS-" +
                     "MSG3_SCHEDULED-CT_NONE-INITIALACCESS-" +
                     "SCHEDULE_MSG4_WITHOUT_DL_CCCH_DATA-CT_SAINITIALACCESS-RRCREESTABLISHMENT-" +
                     "AWAIT_.*?DL_CCCH_DATA_ACK-CT_SAINITIALACCESS-RRCREESTABLISHMENT-" +  # <--- there is .*? !!!
                     ".*?MSG5.*?-CT_SAINITIALACCESS-RRCREESTABLISHMENT-" +  # <--- there is .*? !!!
                     "MSG5_SCHEDULED-CT_SAINITIALACCESS-RRCREESTABLISHMENT")
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl)

        # Filter on given Cell only:
        df_filtered = df.loc[df['lcrId'] == int(cell)].copy()
        logging.info("df_filtered = \n%s" % (df_filtered))

        # Remove 'none' in both places:
        df_filtered = df_filtered.dropna(subset=[ul_raState, dl_raState, preambleType], how='all').copy()
        logging.info("df_filtered = \n%s" % (df_filtered))

        # Remove 'ATTACHED' in any places:
        df_filtered = df_filtered[~((df_filtered[ul_raState] == 'ATTACHED') |
                                    (df_filtered[dl_raState] == 'ATTACHED'))]
        logging.info("df_filtered = \n%s" % (df_filtered))

        header = df_filtered.columns.tolist()
        rach_procedures_list = df_filtered.values.tolist()
        logging.info(tabulate(rach_procedures_list, headers=header, tablefmt='grid'))

        df_filtered = df_filtered.drop(['rnti', 'lcrId'], axis=1)  # axis=1 specifies that we're dropping a column
        logging.info("df_filtered = \n%s" % (df_filtered))
        rach_procedures_list = df_filtered.values.tolist()
        rach_procedures_list = [''.join(str(sublist)) for sublist in rach_procedures_list]
        rach_procedures_reported = ''.join(rach_procedures_list)
        rach_procedures_reported = rach_procedures_reported.replace('None', '').replace('[', '').replace(']', '')
        rach_procedures_reported = rach_procedures_reported.replace(',', '').replace(' ', '').replace('\'\'', '-')
        logging.info("rach_procedures_list = \n%s" % (rach_procedures_reported))

        if ue_type == "sa":
            rach_procedures_expected = rach_sa_attach
        # For NSA case
        elif "CFRA" in rach_procedures_reported:
            rach_procedures_expected = rach_nsa_attach_cfra
        else:
            rach_procedures_expected = rach_nsa_attach_cbra

        logging.info("rach_procedures_expected = %s" % rach_procedures_expected)
        matches = re.findall(rach_procedures_expected, rach_procedures_reported)
        num_of_attached_ues_reported = len(matches)
        logging.info("num_of_attached_ues_reported = %s" % num_of_attached_ues_reported)
        is_raState_present = num_of_attached_ues_reported == int(num_of_ues)

        if "reest" in procedure_type and ue_type == "sa":
            rach_procedures_expected = rach_sa_reest
            logging.info("rach_procedures_expected = %s" % rach_procedures_expected)
            matches = re.findall(rach_procedures_expected, rach_procedures_reported)
            num_of_reest_ues_reported = len(matches)
            logging.info("num_of_reest_ues_reported = %s" % num_of_reest_ues_reported)
            is_raState_present = is_raState_present and (num_of_reest_ues_reported == int(num_of_ues))

        logging.info("is_raState_present = %s" % is_raState_present)
    except Exception as e:
        logException("verify_TTITraces_for_raState", e)
    if not is_raState_present:
        raise Exception("The number reported UE's and the number of configured UE's is not matching")


@log_begin_end_func_name
def verify_pmc(subfeature="", details=""):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # subfeature - any test helping to destinguish verification
    # details - any test helping to identify the details
    # -------------------------------------------------------------------------------------------------[120 characters]
    logging.info("subfeature = %s" % subfeature)
    logging.info("details = %s" % details)
    pmc_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
    pmc_index = rbi.get_variable_value("${pmc_index}")
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    column = -(pmc_index+3)
    logging.info("pmc_file = %s" % pmc_file)
    logging.info("column = %s" % column)
    are_pmcs_correct = None
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        if subfeature == "4CC" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell1": int(scell1),
                                 "scell2": int(scell2),
                                 "scell3": int(scell3),
                                 "num_of_ues": int(num_of_ues)}
                                for cells, pcell, scell1, scell2, scell3, ues, num_of_ues in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55138C03001": cells_under_test["num_of_ues"],  # GNB_SCELL_3_ADMI_REQ_SA
                             "M55138C03002": cells_under_test["num_of_ues"],  # GNB_SCELL_3_ADMI_SUCC_SA
                             "M55139C03001": cells_under_test["num_of_ues"],  # GNB_DU_SCELL_3_ADMI_REQ_SA
                             "M55139C03002": cells_under_test["num_of_ues"],  # GNB_DU_SCELL_3_ADMI_SUCC_SA
                             "M55118C09503": cells_under_test["num_of_ues"],  # RRC_RECONF_ADD3DLSCELL_ATT_SA
                             "M55118C09502": cells_under_test["num_of_ues"]}  # RRC_RECONF_ADD3DLSCELL_SUCC_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            # -----------------------------------------------------------------------------------------[120 characters]
            expected_pmcs = {"M55316C09000": cells_under_test["num_of_ues"]}  # SCell activations
            for cell_id in range(1, 4):
                cell = cells_under_test["scell%s" % cell_id]
                verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
    except Exception as e:
        logException("verify_pmc", e)
    if are_pmcs_correct is None:
        are_pmcs_correct = False
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    rbi.should_be_true(are_pmcs_correct)


# =====================================================================================================[120 characters]
#   Private Functions
# =====================================================================================================[120 characters]

def compress_data_frame(df, column_name):
    consecutive_sets = (df[column_name] != df[column_name].shift(1)).cumsum()
    return df.groupby([column_name, consecutive_sets], sort=False).apply(get_first_appearance).reset_index(drop=True)


def get_first_appearance(group):
    return group.iloc[0]


@log_begin_end_func_name
def get_df_from_pkl(path_to_pickle):
    ul_raState = 'ulPreSchedData.raState'
    ul_callType = 'ulPreSchedData.callType'
    ul_ueAddCause = 'ulPreSchedData.ueAddCause'
    dl_raState = 'dlPreSchedData.raState'
    dl_callType = 'dlPreSchedData.callType'
    dl_ueAddCause = 'dlPreSchedData.ueAddCause'
    preambleType = 'preambleData.preambleType'
    # -------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    df = df[['rnti', 'lcrId', ul_raState, dl_raState, ul_callType, dl_callType, ul_ueAddCause, dl_ueAddCause,
             preambleType]]
    return df


@log_begin_end_func_name
def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = get_scf_value(scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            logException("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returnedValue, aResult))
    return isPassed


def get_scf_value(scfObj, pName, distName):
    outString = ""
    logging.info("get_scf_value(): pName = %s" % (pName))
    logging.info("get_scf_value(): outString = %s" % (outString))
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("get_scf_value(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("get_scf_value", e)
    return outString


@log_begin_end_func_name
def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("\n" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")
