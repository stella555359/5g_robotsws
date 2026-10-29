# ====================================================================================================[120 characters]
# This is a Python file, which helps to implement TTITraces Analysis used in CB008409 feature
# Team: 'SqdGp66'
# Email: 'I_MN_RAN_RD_VRF_ULM_SQD_66@internal.nsn.com'
# Email: 'I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.L2.libraries.tools import get_directory
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html


# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]
# Important: Keywords' input parameter should be "path_to_pickle" and not "data_frame" if possible


@log_begin_end_func_name
def verify_incremental_cqi_step_size_values(filtered_df, additionalCqiIncrRankRedn=1, allowedCqiIncrement=1,
                                            df_empty_at_end=True):
    """This function computes maximum increment of CQi used in DL Link Adaption based on Collected TTI traces

        :param filtered_df: dataframe filtered with dlLaAverageCqi event
        :param additionalCqiIncrRankRedn: Configured parameter for additional CQI increment while rank reduction
        :param allowedCqiIncrement: Configured parameter for allowed CQI increment
        :param df_empty_at_end: parameter to check if the dataframe should be empty at the end of the function
    """

    # Verification of 5G_UP_ALG_260006
    # rrmRestrictedInstCqi calculation with valid and existing WB-CQI report:
    #   1.  If there was no rank switch the maximum allowed CQI step up for TTI event: rrmInstCqi should not exceed
    #       the configured value of NIDD allowedCqiIncrement
    #   2.  If there is/was a rank reduction, the maximum allowed CQI step up for TTI event: rrmInstCqi should not
    #       exceed the configured values of allowedCqiIncrRestriction + additionalCqiIncrRankRedn

    df = filtered_df

    df['rank'] = df['rank'].str.replace('\\D+', '', regex=True).astype('int')  # remove 'RANK', keep only digits
    df['rrmInstCqi'] = df['rrmInstCqi'].astype(int)
    df['rankIncrement'] = df['rank'].diff()
    df['cqiIncrement'] = df['rrmInstCqi'].diff()
    df.loc[df['rankIncrement'] < 0, 'cqiIncAllowedByRankReduction'] = additionalCqiIncrRankRedn
    df.loc[df['cqiIncrement'] > 0, 'cqiIncAllowed'] = allowedCqiIncrement
    df['sumAllowedCqiIncr'] = (df.fillna(0)['cqiIncAllowed'] + df.fillna(0)['cqiIncAllowedByRankReduction'])
    df.loc[df['cqiIncrement'] > df['sumAllowedCqiIncr'], 'testFailed'] = 'failed'
    cqiIncrValues = df['cqiIncrement'].value_counts().sort_index(ascending=False)
    rankIncrValues = df['rankIncrement'].value_counts().sort_index(ascending=False)
    rbi.log("Check if cqi incrementation is restricted to max allowedCqiIncrement of {}:"
            .format(allowedCqiIncrement), 'INFO')
    rbi.log("Check if cqi incrementation is restricted to max additionalCqiIncrRankRedn of {}:"
            .format(additionalCqiIncrRankRedn), 'INFO')

    rbi.log(cqiIncrValues)
    rbi.log(rankIncrValues)

    rbi.log("df_empty_at_end should be {}:".format(df_empty_at_end), 'INFO')

    if (not df['testFailed'].dropna().empty) and df_empty_at_end:
        display_df_as_html(df)
        rbi.fail("Frame contain not filtered cqi values {}:".format(df['testFailed'].value_counts()))
    if df['testFailed'].dropna().empty and not df_empty_at_end:
        display_df_as_html(df)
        rbi.fail("Frame is empty, should contain not filtered cqi values, allowedCqiIncrement was not changed"
                 " during the running test {}:".format(df['testFailed'].value_counts()))


@log_begin_end_func_name
def verify_restriction_phases_and_incremental_CQI_step_size_values(path_to_pickle, testcase, allowedCqiIncrement=1,
                                                                   allowedCqiIncrementSpecial=3,
                                                                   additionalCqiIncrRankRedn=1, starttime=0,
                                                                   endtime=0):

    """This function checks if the CQI increment is restricted in predefined timeslots

        Suggested pkl file: pkl file with event dlLaAverageCqi csiSrReportData.csiReport and dlFdSchedData present

        :param path_to_pickle: Path of input pickle file
        :param testcase: testcase number (e.g. TC02, TC03)
        :param allowedCqiIncrement: Configured parameter for allowed CQI increment
        :param allowedCqiIncrementSpecial: allowed CQI increment during special phase, like online
                                           modification/commissioning
        :param additionalCqiIncrRankRedn: Configured parameter for additional CQI increment while rank reduction
        :param starttime: starttime of the special phase (online modification)
        :param endtime: endtime of the special phase (online modification)
    """

    df_raw = pd.read_pickle(path_to_pickle)

    df = df_raw[['timeStamp', 'sfn', 'slot', 'rnti', 'dlLaAverageCqi.rank', 'dlLaAverageCqi.rrmInstCqi']]
    df.rename(columns={'dlLaAverageCqi.rank': 'rank', 'dlLaAverageCqi.rrmInstCqi': 'rrmInstCqi'}, inplace=True)
    df.dropna(inplace=True)

    if testcase == 'TC02':
        # No special time phases for TC02
        rbi.log("Verify TC02")
        verify_incremental_cqi_step_size_values(df, additionalCqiIncrRankRedn, allowedCqiIncrement)

    # For TC03 and TC04
    # Here we are splitting the TTI trace is different timephases for evaluation. Basically we are splitting in 3
    # parts, with a special phase in the middle of the TTI trace, where the allowedCqiIncrement can be different
    # (lower/higher) compare to the other timephases of the TTI trace (e.g. online modification of
    # allowedCqiIncrement or HR bearer assigned)
    # Splitting TTI trace timeline:
    # |---------------------------------|---------------------------------------|----------------------------------|
    # |TTI phase normal cqi restriction | TTI phase with special values for cqi |  TTI phase normal cqi restriction|

    elif testcase == 'TC03':
        rbi.log("Verify TC03")
        rbi.log("Starttime online modify: {}".format(starttime))
        rbi.log("Endtime online modify: {}".format(endtime))
        check_cqi_values_in_special_phases(df, allowedCqiIncrement, allowedCqiIncrementSpecial,
                                           additionalCqiIncrRankRedn, starttime, endtime)

    elif testcase == 'TC04':
        rbi.log("Verify TC04")
        # Filter for HR phase
        df_HR = df_raw[df_raw['dlFdSchedData.laMode'] == 'HIGHRELIABILITY']
        startime_HR = df_HR[['timeStamp']].iloc[0]
        endtime_HR = df_HR[['timeStamp']].iloc[-1]
        # added 1s as guardtime, as sometimes, unrestricted cqi values starts earlier
        starttime_cqi_special_restricted_phase = startime_HR - pd.Timedelta(seconds=1)
        starttime = starttime_cqi_special_restricted_phase.iloc[0]
        rbi.log('Starttime HR {}'.format(starttime))
        # added 10s as guardtime, as after HR, cqi values are unrestricted for about 10s, HR LA needs 10s
        endtime_cqi_special_restricted_phase = endtime_HR + pd.Timedelta(seconds=10)
        endtime = endtime_cqi_special_restricted_phase.iloc[0]
        rbi.log('Endtime HR {}'.format(endtime))

        check_cqi_values_in_special_phases(df, allowedCqiIncrement, allowedCqiIncrementSpecial,
                                           additionalCqiIncrRankRedn, starttime, endtime)

    else:
        rbi.fail("No testcase found with name {}:".format(testcase))


@log_begin_end_func_name
def check_cqi_values_in_special_phases(df_filtered, allowedCqiIncrement, allowedCqiIncrementSpecial,
                                       additionalCqiIncrRankRedn, starttime, endtime):
    """This function checks if the CQI increment is restricted and unrestricted in predefined timeslots

        Suggested df_filtered: df with event dlLaAverageCqi present

        :param df_filtered: df with event dlLaAverageCqi present
        :param allowedCqiIncrement: Configured parameter for allowed CQI increment
        :param allowedCqiIncrementSpecial: allowed CQI increment during special phase, like online
                                           modification/commissioning
        :param additionalCqiIncrRankRedn: Configured parameter for additional CQI increment while rank reduction
        :param starttime_cqi_special_restricted_phase: starttime of the special phase
                                                       (online modification/commissioning)
        :param endtime_cqi_special_restricted_phase: endtime of the special phase until it's finished
    """

    # Filter TTI trace for special phase with different values for allowedCqiIncrement
    filtered_df_special_phase = df_filtered[(df_filtered['timeStamp'] >= starttime) &
                                            (df_filtered['timeStamp'] <= endtime)]

    # Filter TTI trace for normal phase
    filtered_df_normal_phase = pd.concat([df_filtered[(df_filtered['timeStamp'] < starttime)],
                                          df_filtered[(df_filtered['timeStamp'] > endtime)]])

    # Verification of cqi increment in special time phases, like online modification
    rbi.log("verify_incremental_cqi_step_size_values filtered_df_UnRestricted_phase")
    verify_incremental_cqi_step_size_values(filtered_df_special_phase, additionalCqiIncrRankRedn,
                                            allowedCqiIncrementSpecial)

    # Verification of cqi increment in non-special timephases
    rbi.log("verify_incremental_cqi_step_size_values filtered_df_normal_phase")
    verify_incremental_cqi_step_size_values(filtered_df_normal_phase, additionalCqiIncrRankRedn,
                                            allowedCqiIncrement)

    # Verification of cqi increment over hole TTI data stream
    rbi.log("verify_incremental_cqi_step_size_values df")
    verify_incremental_cqi_step_size_values(df_filtered, additionalCqiIncrRankRedn, allowedCqiIncrement, False)


@log_begin_end_func_name
def show_cqi_values_increment_report(path_to_pickle):
    """This function shows the CQI increment reported by the UE

            Suggested pkl file: pkl file with event csiSrReportData.csiReport. present
            :param path_to_pickle: Path of input pickle file
    """
    df_raw = pd.read_pickle(path_to_pickle)

    df_csiReport = df_raw[['timeStamp', 'sfn', 'slot', 'rnti', 'csiSrReportData.csiReport.cqi',
                           'csiSrReportData.csiReport.ri']]
    df_csiReport.rename(columns={'csiSrReportData.csiReport.cqi': 'csiReport.cqi',
                                 'csiSrReportData.csiReport.ri': 'csiReport.ri'}, inplace=True)
    df_csiReport.dropna(inplace=True)
    df_csiReport['csiIncrement'] = df_csiReport['csiReport.cqi'].diff()
    cqiIncrValuesReported = df_csiReport['csiIncrement'].value_counts().sort_index(ascending=False)
    rbi.log(cqiIncrValuesReported)


@log_begin_end_func_name
def get_expected_pmc_values_eda04035793(path_to_pickle, cell):
    """

    This function processes performance monitoring counters related to a specific cell from a given pickle file.
    It validates the pm counters which were part of EDA 04035793 and generates expected PMC values and descriptions.

    https://rca-shark.ext.net.nokia.com/onlinerca/04035793
    https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=04035793

    Validated pm counters are:
    M55301C19020-35    Wideband CQI Histogram when UE reports related to 64QAM table - CQI Level 0-15
    M55301C20020-35    Wideband CQI Histogram when UE reports related to 256QAM table - CQI Level 0-15

    Input Parameters:
    param: path_to_pickle (str): The file path to the pickle file containing the DataFrame.
    param: cell (int): The cell identifier used to filter the DataFrame.

    Output:
    - pmc_values_dict (dict): A dictionary where keys are PMC counter names and values are counts of occurrences.
    - pmc_values_description_dict (dict): A dictionary where keys are PMC counter names and values are descriptions.

    Functionality:
    - Reads a DataFrame from a pickle file and filters it based on the specified cell.
    - Forward fills the 'mcsTable' column for each 'lcrId' and 'rnti' group.
    - Saves the filtered DataFrame to a CSV file.
    - Computes counts of occurrences for each CQI value within 'mcsTable' groups.
    - Generates PMC counter names and descriptions based on CQI values and 'mcsTable' types.
    - Returns dictionaries containing PMC values and their descriptions.

    """

    # Load and filter the DataFrame
    df = pd.read_pickle(path_to_pickle)
    df.to_csv(f"{get_directory(path_to_pickle)}/Debug_pm_counter_cell.csv", index=False)
    df = df[df['lcrId'] == cell][['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.mcsTable',
                                  'csiSrReportData.csiReport.cqi', 'csiSrReportData.ulChannel',
                                  'csiSrReportData.pucchFormat', 'csiSrReportData.reportType',
                                  'csiSrReportData.csiOnPuschMeas.csiPart1CrcCheck',
                                  'csiSrReportData.csiOnPuschMeas.dtxCsiPart1']]

    # Forward fill 'mcsTable' using vectorized operations
    df['mcsTable'] = df.groupby(['lcrId', 'rnti'])['dlFdSchedData.mcsTable'].transform('ffill')

    df.to_csv(f"{get_directory(path_to_pickle)}/Debug_pm_counter_cell_{cell}.csv", index=False)

    # Initialize dictionaries for storing results
    pmc_values_dict = {}
    pmc_values_description_dict = {}

    # Precompute CQI values and their corresponding counter names
    cqi_values = range(16)
    counter_names = {
        "qam256": [f'M55301C200{20 + cqi:02}' for cqi in cqi_values],
        "qam64": [f'M55301C190{20 + cqi:02}' for cqi in cqi_values]
    }

    # Group by 'mcsTable' and process each group using vectorized operations
    for mcsTable, df_group in df.groupby('mcsTable'):
        table_type = "256TBL" if mcsTable == "qam256" else "64TBL"
        cqi_counts = df_group['csiSrReportData.csiReport.cqi'].value_counts().reindex(cqi_values, fill_value=0)

        for cqi, pm_counter_name in zip(cqi_values, counter_names[mcsTable]):
            pmc_values_dict[pm_counter_name] = cqi_counts[cqi]
            pmc_values_description_dict[pm_counter_name] = (
                f'[NRCELL-{cell}]  WB_CQI_{table_type}_CQI_{cqi:02} ; '
                f'Wideband CQI Histogram when UE reports related to {mcsTable} table - CQI Level {cqi}'
            )

    return pmc_values_dict, pmc_values_description_dict
