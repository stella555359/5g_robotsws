# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB011006 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.CB011006.libraries.CB011006_tools import load_pmc_dataframe
from testsuite.Ulm.ET.CB011006.libraries.CB011006_tools import load_tput_dict
from testsuite.Ulm.ET.CB011006.libraries.CB011006_tools import log_exception
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html
from testsuite.Ulm.ET.L2.libraries.syslogs_analysis import check_no_fatality_error_in_syslogs


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

# ----------------------------------------------------------------------------------------------------- PMC check
@log_begin_end_func_name
def verify_pmc_values():
    df = load_pmc_dataframe()
    pmcDf = update_pmc_dataframe(df)

    column_list = ["Default Scenario", "Blanking Scenario"]
    index_list = ["PRBs for PDSCH", "PRBs for PUSCH"]
    pmcDfPrint = pd.DataFrame(pmcDf.iloc[0:2, 2:4].values, index=index_list, columns=column_list)
    display_df_as_html(pmcDfPrint)

    areResultsCorrect = True
    try:
        prbs_dl_without_blanking = int(pmcDf.iloc[0, 2])
        prbs_dl_with_blanking = int(pmcDf.iloc[0, 3])
        areResultsCorrect &= prbs_dl_without_blanking*0.9 > prbs_dl_with_blanking

        prbs_ul_without_blanking = int(pmcDf.iloc[1, 2])
        prbs_ul_with_blanking = int(pmcDf.iloc[1, 3])
        areResultsCorrect &= prbs_ul_without_blanking*0.9 > prbs_ul_with_blanking

    except Exception as e:
        areResultsCorrect = False
        log_exception("Verify_CB011006_PMC_values", e)

    rbi.should_be_true(areResultsCorrect)


def update_pmc_dataframe(df):
    col = list(df.columns)
    idx = col.index("Short Description")
    udf = df.iloc[:, [0, 1, idx-2, idx-1, idx]]

    pmcList = ["M55308C10003", "M55308C10004"]

    return udf.query("PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-3'")


# ----------------------------------------------------------------------------------------------------- Tput check
@log_begin_end_func_name
def verify_tput_values():
    tput_dict = load_tput_dict()

    df_tput = pd.DataFrame({}, index=["throughput_dl", "throughput_ul"], columns=["Sc_default", "Sc_blanking"])

    areResultsCorrect = True
    try:
        for traffic in ["throughput_dl", "throughput_ul"]:
            tput_sc1_cell3 = int(tput_dict["scenario_1"]["MRBTS-1/NRBTS-1/NRCELL-3"][traffic])
            tput_sc2_cell3 = int(tput_dict["scenario_2"]["MRBTS-1/NRBTS-1/NRCELL-3"][traffic])
            # print(traffic, tput_sc1_cell3, tput_sc2_cell3)
            df_tput.loc[traffic] = [tput_sc1_cell3, tput_sc2_cell3]

            areResultsCorrect &= tput_sc1_cell3 > tput_sc2_cell3
    except Exception as e:
        areResultsCorrect = False
        log_exception("Verify_CB011006_Tput_values", e)

    display_df_as_html(df_tput)
    rbi.should_be_true(areResultsCorrect)
