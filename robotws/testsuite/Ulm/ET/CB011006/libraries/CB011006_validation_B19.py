# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB011006 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging

import pandas as pd

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.CB011006.libraries.CB011006_tools import load_pmc_dataframe
from testsuite.Ulm.ET.CB011006.libraries.CB011006_tools import log_exception
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


#   Keywords
# ====================================================================================================[120 characters]

# ----------------------------------------------------------------------------------------------------- PMC check
@log_begin_end_func_name
def verify_pmc_values():
    df = load_pmc_dataframe()
    pmc_df_list = update_pmc_dataframe(df)

    for df in pmc_df_list:
        display_df_as_html(df)

    # BWP1=small
    df_bwp1 = pmc_df_list[0]
    try:
        areResultsCorrect1 = True
        areResultsCorrect1 &= not df_bwp1.empty
        areResultsCorrect1 &= (df_bwp1.iloc[:, 2].map(int) == 0).all()
        areResultsCorrect1 &= (df_bwp1.iloc[:, 3].map(int) == 0).all()
        areResultsCorrect1 &= (df_bwp1.iloc[:, 4].map(int) == 1).all()
        logging.info("BWP1 PM counter check: %s" % areResultsCorrect1)
    except Exception as e:
        areResultsCorrect1 = False
        log_exception("Verify_CB011006_PMC_values_BWP_1", e)

    # BWP2=medium
    df_bwp2 = pmc_df_list[1]
    try:
        areResultsCorrect2 = True
        areResultsCorrect2 &= not df_bwp2.empty
        areResultsCorrect2 &= (df_bwp2.iloc[:, 2].map(int) == 0).all()
        areResultsCorrect2 &= (df_bwp2.iloc[:, 3].map(int) == 0).all()
        areResultsCorrect2 &= (df_bwp2.iloc[:, 4].map(int) == 1).all()
        logging.info("BWP2 PM counter check: %s" % areResultsCorrect2)
    except Exception as e:
        areResultsCorrect2 = False
        log_exception("Verify_CB011006_PMC_values_BWP_2", e)

    # BWP3=large
    df_bwp3 = pmc_df_list[2]
    try:
        areResultsCorrect3 = True
        areResultsCorrect3 &= not df_bwp3.empty
        # first one is 0, because BWP feature is not active, yet
        areResultsCorrect3 &= (df_bwp3.iloc[:, 2].map(int) == 0).all()
        areResultsCorrect3 &= (df_bwp3.iloc[:, 3].map(int) == 1).all()
        areResultsCorrect3 &= (df_bwp3.iloc[:, 4].map(int) == 1).all()
        logging.info("BWP3 PM counter check: %s" % areResultsCorrect3)
    except Exception as e:
        areResultsCorrect3 = False
        log_exception("Verify_CB011006_PMC_values_BWP_3", e)

    rbi.should_be_true(areResultsCorrect1 & areResultsCorrect2 & areResultsCorrect3)


def update_pmc_dataframe(df):
    col = list(df.columns)
    idx = col.index("Short Description")
    udf = df.iloc[:, [0, 1, idx-4, idx-2, idx-1, idx]]

    pmcList_Bwp1 = ["M55166C00001", "M55166C00003"]
    pmcList_Bwp2 = ["M55166C00002", "M55166C00004"]
    pmcList_Bwp3 = ["M55166C00511", "M55166C00512"]

    df_bwp1 = udf.query("PI_ID in @pmcList_Bwp1 and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-3'")
    df_bwp2 = udf.query("PI_ID in @pmcList_Bwp2 and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-3'")
    df_bwp3 = udf.query("PI_ID in @pmcList_Bwp3 and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-3'")

    return [df_bwp1, df_bwp2, df_bwp3]
