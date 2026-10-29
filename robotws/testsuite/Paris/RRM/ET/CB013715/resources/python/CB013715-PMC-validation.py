# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB012738 Feature
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import csv
import json
import traceback
import re

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate, tti_dataframe
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tools import log_begin_end_func_name, logException
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import display_df_as_html, \
    display_df_as_table, save_df_as_html


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()
pd = None


#   Keywords
# ====================================================================================================[120 characters]

def pmc_log_exception(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    details = traceback.format_exc()
    rbi.log_to_console("debug: pmc_log_exception tracedback details. {}".format(details))
    logging.info("pmc_log_exception tracedback details. %s" % details)
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happened (see log.html)" % functionNameStr + RESET + "")


# ----------------------------------------------------------------------------------------------------- PMC check
def load_pmc_dataframe(debug=False):
    global pd
    pd = pandas_gate.install_and_import_pandas()

    if not debug:
        file_csv = rbi.get_variable_value("${path_to_pmc_csv}")
    else:
        file_csv = FILE_CSV
    df = pd.read_csv(file_csv, sep=";")
    df = df.reset_index(drop=True)

    return df


@log_begin_end_func_name
def verify_pmc_values(topo_tl='TDD', cell_id='1', nbr_sce=1, dl_prb_avg=0, ul_prb_avg=0,
                      filename=None, validate=None, debug=False):
    """

    :param topo_tl:
    :param cell_id:
    :param nbr_sce:
    :param validate:
    :param debug:
    :return:
    """
    print('verify_pmc_values with debug={}'.format(debug))
    print('dl_prb_avg={}'.format(dl_prb_avg))
    print('ul_prb_avg={}'.format(ul_prb_avg))
    df = load_pmc_dataframe(debug=debug)
    pmcDf = update_pmc_dataframe(df, cell_id=cell_id, nbr_sce=int(nbr_sce))

    if not debug:
        file_csv = rbi.get_variable_value("${path_to_pmc_csv}")
    else:
        file_csv = FILE_CSV
    display_df_as_html(pmcDf)
    if filename is not None:
        display_df_as_table(pmcDf, base_location=os.path.dirname(filename), filename=os.path.basename(filename),
                            both=True)
    else:
        display_df_as_table(pmcDf)
    save_df_as_html(pmcDf, os.path.dirname(file_csv), title="CB013715_PMC")

    pmcList = ["M55308C10002"]
    query_str = "PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-2/NRCELL-" + str(cell_id) + "'"
    pmcDf_M55308C10002 = pmcDf.query(query_str)
    col = list(pmcDf_M55308C10002.columns)
    idx = col.index("Short Description")
    df_M55308C10002 = pmcDf_M55308C10002.iloc[:, [idx - 1]].astype('int64')
    M55308C10002_value = df_M55308C10002.values[0].astype('int64')[0]

    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        rbi.log("No validation actually implemented... keyword pass!")

    pmcDf_2 = update_pmc_dataframe_pdsch_tx(df, cell_id=cell_id, nbr_sce=int(nbr_sce))
    if filename is not None:
        display_df_as_table(pmcDf_2, base_location=os.path.dirname(filename), filename=os.path.basename(filename),
                            both=True)
    else:
        display_df_as_table(pmcDf_2)
    col = list(pmcDf_2.columns)
    idx = col.index("Short Description")
    df_pdschtx = pmcDf_2.iloc[:, [idx - 1]].astype('int64')
    col = list(df_pdschtx.columns)
    # sum pdsch tx
    sum_pdsch_tx = df_pdschtx[col].sum().values[0]
    sum_prb = sum_pdsch_tx * dl_prb_avg
    print('sum_pdsch_tx: {}'.format(sum_pdsch_tx))
    print('sum_prb_pdsch_tx: {}'.format(sum_prb))
    # print(f"sum_pdsch_tx = {sum_pdsch_tx}")
    if debug:
        base_location = os.path.dirname(filename)
        filename = os.path.basename(filename)
        tti_dataframe.save_df_to_csv(pmcDf_2, csv_file_name="pdsch_tx_PMC.csv", folder_path=base_location)
        tti_dataframe.save_df_to_csv(df_pdschtx, csv_file_name="pdsch_tx.csv", folder_path=base_location)

    pmcDf_3 = update_pmc_dataframe_pdsch_tx_all(df, cell_id=cell_id, nbr_sce=int(nbr_sce))
    if filename is not None:
        display_df_as_table(pmcDf_3, base_location=os.path.dirname(filename), filename=os.path.basename(filename),
                            both=True)
    else:
        display_df_as_table(pmcDf_3)

    # rbi.should_be_true(areResultsCorrect)
    return sum_pdsch_tx, M55308C10002_value


def select_columns(df, nbr_sce, idx):
    """
    Selects columns from a DataFrame based on the number of scenarios.

    Args:
        df: The Pandas DataFrame.
        nbr_sce: The number of scenarios.
        idx: The index of the last column to include.

    Returns:
        A new DataFrame with the selected columns.
    """

    # Define the base columns to always include
    base_columns = [0, 1]

    # Calculate the number of columns to select from the end
    num_end_columns = min(nbr_sce + 1, 6)  # Limit to maximum 6 columns

    # Select the end columns based on the number of scenarios
    end_columns = list(range(idx - num_end_columns, idx + 1))

    # Combine the base and end columns
    selected_columns = base_columns + end_columns

    # Return the selected columns from the DataFrame
    return df.iloc[:, selected_columns]


def update_pmc_dataframe(df, cell_id='1', nbr_sce=1):
    """

    :param df:
    :param cell_id:
    :param nbr_sce:
    :return:
    """

    # remove unnecessary columns. columns remaining: PI_ID, Managed Object Name, PMC values, Short Description
    col = list(df.columns)
    idx = col.index("Short Description")
    # udf = df.iloc[:, [0, 1, idx-2, idx-1, idx]]
    udf = select_columns(df, nbr_sce, idx)

    '''
    [M55332C00001] Number of DL Slots assigned to NR
    [M55332C00002] Number of DL Slots assigned to NR with maximum share
    [M55332C00003] Number of DL Slots assigned to NR with minimum share
    [M55332C01001] Number of UL PRBs assigned to NR
    [M55332C01002] Number of UL PRBs assigned to NR with maximum share
    [M55332C01003] Number of UL PRBs assigned to NR with minimum share
    [M55332C02001] Total number of available DL Slots
    [M55332C02002] Total number of available UL PRBs
    [M55308C36001] Maximum DL PRB utilization per slot
    [M55308C36002] Maximum UL PRB Utilization per slot
    [M55308C10003] Number of PRBs available for PDSCH
    [M55308C10002} PRBs used for PUSCH
    [M55308C10004] PRBs available for PUSCH
    [M55308C19001] AL1 used PDCCH
    [M55308C19002] AL2 used PDCCH
    [M55308C19003] AL4 used PDCCH
    [M55308C19004] AL8 used PDCCH
    [M55308C19005] AL16 used PDCCH
    '''
    pmcList = ["M55332C00001", "M55332C00002", "M55332C00003", "M55332C01001", "M55332C01002", "M55332C01003",
               "M55332C02001", "M55332C02002", "M55308C36001", "M55308C36002", "M55308C10003", "M55308C10002",
               "M55308C10004", "M55308C19001", "M55308C19002", "M55308C19003", "M55308C19004", "M55308C19005"]

    global udf_query_cells
    udf_query_cells = pd.DataFrame()
    if ',' in cell_id:
        # Extract the cell IDs and split them by ','
        cell_ids = cell_id.split(',')
        # Convert the cell IDs to integers
        cell_ids = [int(id_cell) for id_cell in cell_ids]
        for cellid in cell_ids:
            query_cell = "PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-2/NRCELL-" + str(cellid) + "'"
            udf_query = udf.query(query_cell)
            udf_query_cells = pd.concat([udf_query_cells, udf_query], ignore_index=True)
        return udf_query_cells
    else:
        query_str = "PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-2/NRCELL-" + str(cell_id) + "'"
        return udf.query(query_str)


def update_pmc_dataframe_pdsch_tx(df, cell_id='1', nbr_sce=1):
    """

    :param df:
    :param cell_id:
    :param nbr_sce:
    :return:
    """

    # remove unnecessary columns. columns remaining: PI_ID, Managed Object Name, PMC values, Short Description
    col = list(df.columns)
    idx = col.index("Short Description")
    # udf = df.iloc[:, [0, 1, idx-2, idx-1, idx]]
    udf = select_columns(df, nbr_sce, idx)

    """
    M55300C00000: PDSCH initial transmissions with 64QAM MCS table using MCS 0
    M55300C01000: Successful PDSCH transmissions by initial transmission with 64QAM MCS table using MCS 0
    M55300C02000: Successful PDSCH transmissions by any transmission with 64QAM MCS table using MCS 0
    M55300C03000: Unsuccessful PDSCH transmissions by last HARQ reTx with 64QAM MCS table using MCS 0
    M55300C04000: PDSCH initial transmissions with 256QAM MCS table using MCS 0
    M55300C05000: Successful PDSCH transmissions by initial transmission with 256QAM MCS table using MCS 0
    M55300C06000: Successful PDSCH transmissions by any transmission with 256QAM MCS table using MCS 0
    M55300C07000: Unsuccessful PDSCH transmissions by last HARQ reTx with 256QAM MCS table using MCS 0
    """

    # pmcList = ["M55300C00000", "M55300C01000", "M55300C02000", "M55300C03000", "M55300C04000", "M55300C05000",
    #            "M55300C06000", "M55300C07000"]

    # Where x = [0,1,2,3,.....,27,28] -> MCS used [0,1,2,3….28]
    # PMC IDs with x as place holder
    # xList = ["M55300C0000x", "M55300C0100x", "M55300C0200x", "M55300C0300x", "M55300C0400x",
    #          "M55300C0500x", "M55300C0600x", "M55300C0700x"]
    xList = ["M55300C0600x"]
    # xList = ["M55300C0100x", "M55300C0200x", "M55300C0300x",
    #          "M55300C0500x", "M55300C0600x", "M55300C0700x"]

    # create actual PMC list by replacing the x's
    pmcList2 = []
    x = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17",
         "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28"]
    for j in xList:
        for k in x:
            pmcList2.append(j.replace("0x", k))

    global udf_query_cells
    udf_query_cells = pd.DataFrame()
    if ',' in cell_id:
        # Extract the cell IDs and split them by ','
        cell_ids = cell_id.split(',')
        # Convert the cell IDs to integers
        cell_ids = [int(id_cell) for id_cell in cell_ids]
        for cellid in cell_ids:
            query_cell = "PI_ID in @pmcList2 and `Managed Object Name` == 'MRBTS-1/NRBTS-2/NRCELL-" + str(cellid) + "'"
            udf_query = udf.query(query_cell)
            udf_query_cells = pd.concat([udf_query_cells, udf_query], ignore_index=True)
        return udf_query_cells
    else:
        query_str = "PI_ID in @pmcList2 and `Managed Object Name` == 'MRBTS-1/NRBTS-2/NRCELL-" + str(cell_id) + "'"
        return udf.query(query_str)


def update_pmc_dataframe_pdsch_tx_all(df, cell_id='1', nbr_sce=1):
    """

    :param df:
    :param cell_id:
    :param nbr_sce:
    :return:
    """

    # remove unnecessary columns. columns remaining: PI_ID, Managed Object Name, PMC values, Short Description
    col = list(df.columns)
    idx = col.index("Short Description")
    # udf = df.iloc[:, [0, 1, idx-2, idx-1, idx]]
    udf = select_columns(df, nbr_sce, idx)

    """
    M55300C00000: PDSCH initial transmissions with 64QAM MCS table using MCS 0
    M55300C01000: Successful PDSCH transmissions by initial transmission with 64QAM MCS table using MCS 0
    M55300C02000: Successful PDSCH transmissions by any transmission with 64QAM MCS table using MCS 0
    M55300C03000: Unsuccessful PDSCH transmissions by last HARQ reTx with 64QAM MCS table using MCS 0
    M55300C04000: PDSCH initial transmissions with 256QAM MCS table using MCS 0
    M55300C05000: Successful PDSCH transmissions by initial transmission with 256QAM MCS table using MCS 0
    M55300C06000: Successful PDSCH transmissions by any transmission with 256QAM MCS table using MCS 0
    M55300C07000: Unsuccessful PDSCH transmissions by last HARQ reTx with 256QAM MCS table using MCS 0
    """

    # pmcList = ["M55300C00000", "M55300C01000", "M55300C02000", "M55300C03000", "M55300C04000", "M55300C05000",
    #            "M55300C06000", "M55300C07000"]

    # Where x = [0,1,2,3,.....,27,28] -> MCS used [0,1,2,3….28]
    # PMC IDs with x as place holder
    xList = ["M55300C0000x", "M55300C0100x", "M55300C0200x", "M55300C0300x", "M55300C0400x",
             "M55300C0500x", "M55300C0600x", "M55300C0700x"]

    # create actual PMC list by replacing the x's
    pmcList2 = []
    x = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17",
         "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28"]
    for j in xList:
        for k in x:
            pmcList2.append(j.replace("0x", k))

    global udf_query_cells
    udf_query_cells = pd.DataFrame()
    if ',' in cell_id:
        # Extract the cell IDs and split them by ','
        cell_ids = cell_id.split(',')
        # Convert the cell IDs to integers
        cell_ids = [int(id_cell) for id_cell in cell_ids]
        for cellid in cell_ids:
            query_cell = "PI_ID in @pmcList2 and `Managed Object Name` == 'MRBTS-1/NRBTS-2/NRCELL-" + str(cellid) + "'"
            udf_query = udf.query(query_cell)
            udf_query_cells = pd.concat([udf_query_cells, udf_query], ignore_index=True)
        return udf_query_cells
    else:
        query_str = "PI_ID in @pmcList2 and `Managed Object Name` == 'MRBTS-1/NRBTS-2/NRCELL-" + str(cell_id) + "'"
        return udf.query(query_str)


def update_pmc_dataframe_template(df, cell_id='1'):
    """
    keep as an example
    :param df:
    :param cell_id:
    :return:
    """
    col = list(df.columns)
    idx = col.index("Short Description")
    udf = df.iloc[:, [0, 1, idx - 2, idx - 1, idx]]

    # M55306C0000x RA setup attempts for contention-based group A preambles corresponding to SSB beam ID x
    # Where x = [1,2,3,4,5,6,7] -> Beams used [0,1,2,3….6]
    # PMC IDs with x as place holder
    xList = ["M55306C0000x"]

    # create actual PMC list by replacing the x's
    pmcList = []
    x = ["00", "01", "02", "03", "04", "05", "06"]
    for j in xList:
        for k in x:
            pmcList.append(j.replace("0x", k))

    global udf_query_cells
    udf_query_cells = pd.DataFrame()
    if ',' in cell_id:
        # Extract the cell IDs and split them by ','
        cell_ids = cell_id.split(',')
        # Convert the cell IDs to integers
        cell_ids = [int(id_cell) for id_cell in cell_ids]
        for cellid in cell_ids:
            query_cell = "PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-" + str(cellid) + "'"
            udf_query = udf.query(query_cell)
            udf_query_cells = pd.concat([udf_query_cells, udf_query], ignore_index=True)
        return udf_query_cells
    else:
        query_str = "PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-" + str(cell_id) + "'"
        return udf.query(query_str)


def verify_within_threshold(pid, pm_info, reported_value, expected_value, threshold, pmcut=True, pmcut_attr="value",
                            filename=None):
    expression = (abs(int(reported_value) - int(expected_value)) <= threshold) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "threshold", "~ %s" % threshold, filename=filename)
    if pmcut and pid:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_within_range(pid, pm_info, reported_value, expected_min_value,
                        expected_max_value, pmcut=True, pmcut_attr="value", filename=None):
    expression = (int(expected_min_value) <= int(reported_value) <= int(expected_max_value)) if int(reported_value) >=\
                                                                                                0 else False
    min_str = ("%s" % expected_min_value) if int(expected_min_value) < 1e6 else "%.1E" % expected_min_value
    max_str = ("%s" % expected_max_value) if int(expected_max_value) < 1e6 else "%.1E" % expected_max_value
    range_str = "[%s, %s]" % (min_str, max_str)
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, range_str,
                                         expression, "range (min", "<= x <=max)", filename=filename)
    if pmcut and pid:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_is_equal(pid, pm_info, reported_value, expected_value, pmcut=True, pmcut_attr="value", filename=None):
    expression = (int(reported_value) == int(expected_value)) if (int(reported_value) >= 0 or
                                                                  int(expected_value) < 0) else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "is equal", "== %s" % expected_value, filename=filename)
    if pmcut and pid:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_is_lower(pid, pm_info, reported_value, expected_value, pmcut=True, pmcut_attr="value", filename=None):
    expression = (int(reported_value) <= int(expected_value)) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "is lower", "<= %s" % expected_value, filename=filename)
    if pmcut and pid:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_is_greater(pid, pm_info, reported_value, expected_value, pmcut=True, pmcut_attr="value", filename=None):
    expression = (int(reported_value) >= int(expected_value)) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "is greater", ">= %s" % expected_value, filename=filename)
    if pmcut and pid:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_percentage_within_threshold(pid, pm_info, reported_value, expected_value, threshold,
                                       pmcut=True, pmcut_attr="value", filename=None):
    expression = (abs(float(reported_value) * 100.0 / float(expected_value) - 100.0)
                  <= threshold) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "%% threshold", "~ %s" % expected_value, filename=filename)
    if pmcut and pid:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def fail_verification(pid, pm_info, reported_value, expected_value):
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         False, "is equal", "== %s" % expected_value)
    return result


def addToPmcutDict(pid, value=None, info=None, rtpm=None, result=None):
    global pmcutDict
    pid_format_regex = r"M([-+]?\d+).([-+]?\d+)"
    match_pid_format_ca = re.match(pid_format_regex+"[_.](.*)", pid)
    if match_pid_format_ca:
        if '_' in pid:
            new_pid = pid.split('_')[0]
        elif '.' in pid:
            new_pid = pid.split('.')[0]
        else:
            new_pid = pid
        logging.info("addToPmcutDict received pid='%s' and it will chaged it to '%s'" % (pid, new_pid))
        pid = new_pid
    match_pid_format = re.match(pid_format_regex+'$', pid)
    if match_pid_format:
        if pid in list(pmcutDict.keys()):
            action = 'Updating'
            if value is not None:
                pmcutDict[pid]["value"] = value
            if info is not None:
                pmcutDict[pid]["info"] = info
            if rtpm is not None:
                pmcutDict[pid]["rtpm"] = rtpm
            if result is not None and result.lower() != "failed":
                pmcutDict[pid]["result"] = result
        else:
            action = 'Creating'
            value = -1 if value is None else value
            info = "" if info is None else info
            rtpm = -1 if rtpm is None else rtpm
            result = "" if result is None else result
            pmcutDict[pid] = {"value": value, "info": info, "rtpm": rtpm, "result": result}
        logging.info("%s pmcut dict key='%s', value=%s, info=%s, rtpm=%s, result=%s" %
                     (action, pid, pmcutDict[pid]["value"], pmcutDict[pid]["info"],
                      pmcutDict[pid]["rtpm"], pmcutDict[pid]["result"]))


def search_for_failed_in_pmcut_dict(pmcut_dict=None):
    if pmcut_dict is None:
        global pmcutDict
        pmcut_dict = pmcutDict
    for pmName, pmDict in pmcut_dict.items():
        if pmDict["result"] == "Failed":
            return "Failed"
    return "Passed"


def get_int_value(str_value, order_number=0):
    int_value = -1
    if str_value == "-1":
        int_value = -1
    elif str_value.startswith("ERR"):
        int_value = -1
    elif str_value.isdigit():
        int_value = int(str_value)
    elif "|" in str_value:
        int_value = int(str_value.split("|")[order_number])
        logging.info("get_int_value(): PMC value is NOT an Integer, but a list --> check XML report files!")
        logging.info("get_int_value(): int_value = %s" % int_value)
    else:
        logging.info("get_int_value(): PMC value has STRANGE format --> check XML report files!")
    return int_value


@log_begin_end_func_name
def verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name="",
                       threshold_percent=0.1, verification_type="verify_within_threshold", debug=False, filename=None):
    tc_result = "Failed"
    list_of_found_piids_under_test = []
    try:
        # --------------------------------------------------------------------------------------------[120 characters]
        with open(pmc_csv_file, 'r') as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=';', quotechar='|')
            pmcut = {}
            for row in csv_reader:
                piid = row[0]
                if piid in piids_and_expected_values and "NRCELL-%s" % cell in row[1]:
                    list_of_found_piids_under_test.append(piid)
                    pmcut[piid] = {
                        "reported": get_int_value(row[column]),
                        "expected": piids_and_expected_values[piid],
                        "info": "[NRCELL-%s] " % cell + row[-2]
                    }
                    thr = 0 if not threshold_percent else max(int(pmcut[piid]["expected"]*threshold_percent/100), 3)
                    if verification_type == "verify_within_threshold":
                        verify_within_threshold(pid=piid,
                                                pm_info=pmcut[piid]["info"],
                                                reported_value=pmcut[piid]["reported"],
                                                expected_value=pmcut[piid]["expected"],
                                                threshold=thr,
                                                filename=filename)
                    if verification_type == "verify_is_lower":
                        verify_is_lower(pid=piid,
                                        pm_info=pmcut[piid]["info"],
                                        reported_value=pmcut[piid]["reported"],
                                        expected_value=pmcut[piid]["expected"],
                                        filename=filename)
                    if verification_type == "verify_is_greater":
                        verify_is_greater(pid=piid,
                                          pm_info=pmcut[piid]["info"],
                                          reported_value=pmcut[piid]["reported"],
                                          expected_value=pmcut[piid]["expected"],
                                          filename=filename)
                    if verification_type == "verify_is_equal":
                        verify_is_equal(pid=piid,
                                        pm_info=pmcut[piid]["info"],
                                        reported_value=pmcut[piid]["reported"],
                                        expected_value=pmcut[piid]["expected"],
                                        filename=filename)
        # --------------------------------------------------------------------------------------------[120 characters]
        logging.info("list_of_found_piids_under_test = %s" % list_of_found_piids_under_test)
        logging.info("piids_and_expected_values = %s" % piids_and_expected_values)
        list_of_not_found_piids = [k for k in piids_and_expected_values if k not in list_of_found_piids_under_test]
        logging.info("list_of_not_found_piids = %s" % list_of_not_found_piids)
        for not_found_piid in list_of_not_found_piids:
            pmcut[not_found_piid] = {
                "reported": 'N/A',
                "expected": piids_and_expected_values[not_found_piid],
                "info": "[NRCELL-%s] " % cell
            }
            fail_verification(pid=not_found_piid,
                              pm_info=pmcut[not_found_piid]["info"],
                              reported_value='N/A',
                              expected_value=pmcut[not_found_piid]["expected"])
        # --------------------------------------------------------------------------------------------[120 characters]
        tc_result = search_for_failed_in_pmcut_dict()
        logging.info("tc_result = %s" % tc_result)
        # print_pm_counter_testcase_footer(tc_result)
        # pmResultDict = add_tc_result_to_report_json_dict(tc_name, tc_result)
    except Exception as e:
        logException("verify_pm_counters", e)
    return (tc_result.lower() == "passed")


@log_begin_end_func_name
def verify_pmc(subfeature="", details="", details2="", debug=False, filename=None):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # sub-feature - any test helping to distinguish verification
    # details - any test helping to identify the details
    # as example :
    # details=cellid:M55308C36001:expected:verification_type:threshold_percent:M55308C36002:
    # expected::verification_type:threshold_percent
    # for ex ; 1:M55308C36001:100:verify_within_threshold:0:M55308C36002:55:verify_within_threshold:0
    # verification_type can be 'verify_within_threshold', 'verify_is_lower', 'verify_is_greater' or 'verify_is_equal'
    # -------------------------------------------------------------------------------------------------[120 characters]
    logging.info("subfeature = %s" % subfeature)
    logging.info("details = %s" % details)
    logging.info("details2 = %s" % details2)
    tc_name = ""
    if not debug:
        print_pm_counter_testcase_header("verify_pmc", rbi.get_variable_value("${SUITE_NAME}"), filename=filename)
        pmc_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
        pmc_index = rbi.get_variable_value("${pmc_index}")
    else:
        print_pm_counter_testcase_header("verify_pmc")
        pmc_file = FILE_CSV
        pmc_index = 0
    column = -(pmc_index+3)
    logging.info("pmc_file = %s" % pmc_file)
    logging.info("column = %s" % column)
    are_pmcs_correct = None
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        if subfeature == "CB013715" and details and ":" in details:
            pms_under_test = [{"pcell": pcell,
                               "M55308C36001": int(expected_PM1),
                               "verif_M55308C36001": verif1,
                               "th_M55308C36001": int(th1),
                               "M55308C36002": int(expected_PM2),
                               "verif_M55308C36002": verif2,
                               "th_M55308C36002": int(th2)}
                              for pcell, PM1, expected_PM1, verif1, th1, PM2, expected_PM2, verif2, th2
                              in [details.split(':')]][0]
            logging.info("pms_under_test = %s" % json.dumps(pms_under_test, indent=4))
            verdicts = []
            cell = pms_under_test["pcell"]
            # BEWARE that pmcutDict is initialized in print_pm_counter_testcase_info_to_console fct
            print_pm_counter_testcase_info_to_console("verify_pmc for", cell, to_console=False)
            expected_pmcs = {"M55308C36001": pms_under_test["M55308C36001"],  # Max DL PRB utilization per slot
                             "M55308C36002": pms_under_test["M55308C36002"]}  # Max UL PRB Utilization per slot
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0,
                                               verification_type='verify_within_threshold', debug=debug,
                                               filename=filename))
            if subfeature == "CB013715" and details2 and ":" in details2:
                pms_under_test = [{"pcell": pcell,
                                   "M55308C10002": int(expected_PM3),
                                   "verif_M55308C10002": verif3,
                                   "th_M55308C10002": int(th3),
                                   "M55332C02001": int(expected_PM4),
                                   "verif_M55332C02001": verif4,
                                   "th_M55332C02001": int(th4)
                                   }
                                  for pcell, PM3, expected_PM3, verif3, th3, PM4, expected_PM4, verif4, th4
                                  in [details2.split(':')]][0]
                expected_pmcs = {"M55308C10002": pms_under_test["M55308C10002"],  # PRBs used for PUSCH
                                 "M55332C02001": pms_under_test["M55332C02001"]}  # Total num of available DL Slots
                verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs,
                                                   threshold_percent=pms_under_test["th_M55308C10002"],
                                                   verification_type=pms_under_test["verif_M55308C10002"],
                                                   debug=debug, filename=filename))
            # -----------------------------------------------------------------------------------------[120 characters]
            are_pmcs_correct = all(verdicts)
    except Exception as e:
        pmc_log_exception("verify_pmc", e)
    if are_pmcs_correct is None:
        are_pmcs_correct = False
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    if are_pmcs_correct:
        tc_result = "Passed"
    else:
        tc_result = "Failed"
    print_pm_counter_testcase_footer(tc_result, filename=filename)
    rbi.should_be_true(are_pmcs_correct)


def verify_pm_within_threshold(pid, pm_info, reported_value, expected_value, threshold_percent, filename=None):
    threshold = 0 if not threshold_percent else max(int(int(expected_value) * int(threshold_percent) / 100), 3)
    expression = (abs(int(reported_value) - int(expected_value)) <= threshold) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "threshold", "~ %s" % threshold, filename=filename)
    return result


def print_pm_counter_testcase_header(qcTestCaseName, testcase_str=None, testcase_info=None, filename=None):
    print_to_html_and_file("-" * 90, filename)
    print_to_html_and_file("QC Test Case Name: %s" % qcTestCaseName, filename)
    if testcase_info is not None:
        testcase_str = "(%s)" % str(testcase_str)
    else:
        testcase_str = ""
    if testcase_info is not None:
        print_to_html_and_file(str(testcase_info), filename)
    print_to_html_and_file(testcase_str.ljust(15) + "PI ID".rjust(5) + "Expected".rjust(15) + "Reported".rjust(15) +
                           "Verdict".rjust(15) + "Condition".rjust(15) +
                           " " + " ".ljust(15) + "PM Counter description".ljust(30),
                           filename)


def print_pm_counter_pid_result(pid, info, reported_value, expected_value, condition, condition_type, condition_info,
                                filename=None):
    result = "Passed" if condition else "Failed"
    print_to_html_and_file(str(pid).rjust(20) + str(expected_value).rjust(15) + str(reported_value).rjust(15) +
                           result.rjust(15) + condition_type.rjust(15) + " " + condition_info.ljust(15) + info + '\n',
                           filename=filename)
    return result


def print_pm_counter_testcase_footer(tc_result, print_to_console=True, filename=None):
    print_to_html_and_file("-" * 90, filename=filename)
    if filename:
        print_to_html_and_file(tc_result, filename=filename)
    if print_to_console:
        print_pm_counter_testcase_result_to_console(tc_result)


def print_pm_counter_testcase_info_to_console(tc_name, cell_id=None, reporting_info="", to_console=True):
    global pmcutDict
    pmcutDict = {}
    if cell_id:
        msg = "\n  " + tc_name + ":   cell=" + str(cell_id)+"   " + str(reporting_info) + "\n"
        if to_console:
            rbi.log_to_console(msg.ljust(133), no_newline=True)
    else:
        if to_console:
            rbi.log_to_console(("\n  " + tc_name + ":   " + str(reporting_info)).ljust(133), no_newline=True)


def print_pm_counter_testcase_result_to_console(tc_result):
    if tc_result.lower() == 'passed':
        rbi.log_to_console(GREEN, no_newline=True)
    else:
        rbi.log_to_console(RED, no_newline=True)
    rbi.log_to_console(tc_result+RESET+"")


def print_to_html_and_file(text, filename=None):
    # print(text)
    logging.info("%s" % text)
    rbi.log(text, 'INFO', console=True)
    if filename is not None:
        base_location = os.path.dirname(filename)
        filename = os.path.basename(filename)
        if base_location and filename:
            file_path = base_location + '/' + filename
            try:
                with open(file_path, 'a') as f:
                    f.write(text + "\n")
                rbi.log("File write successful", 'TRACE', console=False)
            except Exception as e:
                rbi.log(f"File write failed: {e}", 'ERROR', console=True)


def test_verify_pmc_values():
    pd = pandas_gate.install_and_import_pandas()

    global FILE_CSV, PATH_CSV
    FILE_CSV = '/home/ute/csamson/TRACES/pmCounters.csv'
    PATH_CSV = '/home/ute/csamson/TRACES'
    verify_pmc_values(cell_id='1', nbr_sce=1, filename=PATH_CSV+"CB013715_PMC.csv",
                      dl_prb_avg=28, ul_prb_avg=12, debug=True)
    # verify_pmc_values(cell_id='1,2', debug=True)


def test_verify_pmc():
    pd = pandas_gate.install_and_import_pandas()

    global FILE_CSV, PATH_CSV
    FILE_CSV = '/home/ute/csamson/TRACES/pmCounters.csv'
    PATH_CSV = '/home/ute/csamson/TRACES'

    # details = '1:M55308C36001:100:M55308C36002:55'
    details = '1:M55308C36001:100:verify_within_threshold:0:M55308C36002:55:verify_within_threshold:0'
    details2 = '1:M55308C10002:318333:verify_within_threshold:5:M55332C02001:300000:verify_within_threshold:0'
    verify_pmc(subfeature="CB013715", details=details, details2=details2, debug=True)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    # test_verify_pmc_values()
    test_verify_pmc()
