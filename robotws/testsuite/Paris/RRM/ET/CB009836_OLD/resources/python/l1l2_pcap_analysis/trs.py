import logging

from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

from testsuite.Paris.RRM.ET.CB009836.resources.python.l1l2_pcap_analyzer_framework.pcap_dataframe import save_df_to_csv

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
pd = None


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


""" Functions to be used """


@log_begin_end_func_name
def check_trs(normalized_df, physCellId=50, subcellid=0, trsinfo=1, slot=0, nbrslot=10, folder_path=None,
              trscsirs=None):
    """
    Check TRS periodicity (should be 80ms).

    Args:
        normalized_df (pd.DataFrame): Normalized TRS data.
        subcellid (int, optional): Subcell ID (default is 0).
        trsinfo (int, optional): TRS information (default is 1).
        slot (int, optional): Slot number (default is 0).
        folder_path (str, optional): Path to folder containing TRS files (default is None).
        trscsirs (list, optional): List of TRS CSIRs (default is None).

    Returns:
        trscsirs: List of TRS CSIRs
    """
    cellId = int(physCellId) - 50 + 1
    trscsirs = []
    if trsinfo:
        type = 'TRS'
    else:
        type = 'CSIRS'
    df_cell = normalized_df.where(normalized_df['SubcellID'].astype(int) == subcellid).dropna()
    df_cell_trs = df_cell.where(df_cell['TRSInfo'].astype(int) == trsinfo).dropna()
    df_cell_slot = df_cell_trs.where(df_cell_trs['Slot'].astype(int) == slot).dropna()
    df_cell_slot['deltaSFN'] = df_cell_slot['normalized_sfn'].diff(-1).dropna()
    diff_sfn = list((df_cell_slot['deltaSFN'].dropna().unique()))
    diff_sfn_abs = [abs(ele) for ele in diff_sfn]
    diff_sfn_abs_no_zero = [value for value in diff_sfn_abs if value != 0]
    period_csirs_ms_cell = [int(element * nbrslot) for element in diff_sfn_abs_no_zero]
    csv_file_name = type + "_physCellId_" + str(physCellId) + ".csv"
    save_df_to_csv(df_cell, csv_file_name=csv_file_name, folder_path=folder_path + '/')
    csv_file_name = type + "_physCellId_" + str(physCellId) + "_slot" + str(slot) + ".csv"
    save_df_to_csv(df_cell_slot, csv_file_name=csv_file_name, folder_path=folder_path + '/')
    msg = 'period_trs_ms_cell' + str(cellId) + ' ' + type + ' slot' + str(slot)
    datedConsole(getHeaderLine(msg, period_csirs_ms_cell))
    if trsinfo:
        TRS = {'TRSSlot': slot, 'period': period_csirs_ms_cell}
    else:
        TRS = {'CSIRSSlot': slot, 'period': period_csirs_ms_cell}
    trscsirs.append(TRS)
    return trscsirs
