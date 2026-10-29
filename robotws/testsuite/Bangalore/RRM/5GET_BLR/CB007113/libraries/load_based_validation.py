# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB007113 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

from cellsetup_req_parser import extract_l1subpool_cell_relation
from load_metric_analysis import (run_load_based_prb_pooling_analysis,
                                  check_total_pooled_prbs)
from plot_prballocation_per_subcell import plot_prb_allocation_per_subcell
from log_function_progress import log_begin_end_func_name

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_TTITraces_for_loadbase(pkl_path, expected_total_prbs):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # A new event parameter "ulTdSchedSubcellData.numAllocCellPrbUl" shows the allocation of resource PRBs
    #   by BBRM in round robin manner after each pooling window of 50ms
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = pkl_path
    try:
        plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        is_TTITrace_correct = run_load_based_prb_pooling_analysis(path_to_ttitrace_pkl,
                                                                  subcell_expecting_higher_prb_allocation=0,
                                                                  list_of_pooled_subcells=[0, 1, 2, 3],
                                                                  non_pooled_subcell=None,
                                                                  exclude_samples_for_analysis=1000,
                                                                  expected_total_prbs=int(expected_total_prbs))
        logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_loadbase", e)
    rbi.should_be_true(is_TTITrace_correct)


@log_begin_end_func_name
def verify_TTITraces_for_loadbase_on_ASOE(pkl_path, expected_total_prbs=409):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # A new event parameter "ulTdSchedSubcellData.numAllocCellPrbUl" shows the allocation of resource PRBs
    #   by BBRM in round robin manner after each pooling window of 50ms
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    path_to_ttitrace_pkl = pkl_path
    try:
        plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        is_TTITrace_correct_p1 = run_load_based_prb_pooling_analysis(path_to_ttitrace_pkl,
                                                                     subcell_expecting_higher_prb_allocation=0,
                                                                     list_of_pooled_subcells=[0, 2],
                                                                     non_pooled_subcell=None,
                                                                     exclude_samples_for_analysis=1000,
                                                                     expected_total_prbs=expected_total_prbs)
        logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        is_TTITrace_correct_p2 = run_load_based_prb_pooling_analysis(path_to_ttitrace_pkl,
                                                                     subcell_expecting_higher_prb_allocation=1,
                                                                     list_of_pooled_subcells=[1, 3],
                                                                     non_pooled_subcell=None,
                                                                     exclude_samples_for_analysis=1000,
                                                                     expected_total_prbs=expected_total_prbs)
        logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
    except Exception as e:
        logException("verify_TTITraces_for_loadbase", e)
    rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2)


@log_begin_end_func_name
def verify_total_pooled_prbs(pkl_path, expected_total_prbs):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = pkl_path
    try:
        plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        is_TTITrace_correct = check_total_pooled_prbs(path_to_ttitrace_pkl,
                                                      subcell_expecting_higher_prb_allocation=0,
                                                      list_of_pooled_subcells=[0, 1, 2, 3],
                                                      non_pooled_subcell=None,
                                                      exclude_samples_for_analysis=1000,
                                                      expected_total_prbs=int(expected_total_prbs))
        logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_loadbase", e)
    rbi.should_be_true(is_TTITrace_correct)


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]


@log_begin_end_func_name
def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = getValue(scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            logException("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returnedValue, aResult))
    return isPassed


def getValue(scfObj, pName, distName):
    outString = ""
    logging.info("getValue(): pName = %s" % (pName))
    logging.info("getValue(): outString = %s" % (outString))
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("getValue(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("getValue", e)
    return outString


@log_begin_end_func_name
def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")
