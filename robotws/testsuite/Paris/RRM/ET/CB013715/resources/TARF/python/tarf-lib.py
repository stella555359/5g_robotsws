# ====================================================================================================
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB012738 Subfeature
# ----------------------------------------------------------------------------------------------------

import logging
import os
import re
import plotly.graph_objects as go
import math
import json

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf
from taf.ul.ettf.logger import custom_logger, log

# SWENG Libraries:
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole

# ET or Feature Specific Libraries:
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.dtx import get_dtx_stats
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tools import log_begin_end_func_name
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import display_df_as_html


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()
logger = custom_logger(name='CB012738-lib', filename='test_execution_CB012738.log', disable_html_logging=True)


# AlTh1 = rbi.get_variable_value("${cqiDciCssAl1HR}")/10
# AlTh2 = rbi.get_variable_value("${cqiDciCssAl2HR}")/10
# AlTh4 = rbi.get_variable_value("${cqiDciCssAl4HR}")/10
# AlTh8 = rbi.get_variable_value("${cqiDciCssAl8HR}")/10

AlTh1 = rbi.get_variable_value("${cqiDciCssAl1}")/10
AlTh2 = rbi.get_variable_value("${cqiDciCssAl2}")/10
AlTh4 = rbi.get_variable_value("${cqiDciCssAl4}")/10
AlTh8 = rbi.get_variable_value("${cqiDciCssAl8}")/10

# ====================================================================================================
#   Keywords
# ====================================================================================================


def visualization():
    pd.set_option('display.max_columns', None)
    pd.set_option('display.expand_frame_repr', False)


def load_dataframe(file):
    global pd
    pd = pandas_gate.install_and_import_pandas()

    if file == "csv":
        path_to_csv = rbi.get_variable_value("${path_to_ttitrace_csv}")
        df = pd.read_csv(path_to_csv)
    else:
        path_to_pickle = rbi.get_variable_value("${path_to_ttitrace_pkl}")
        df = pd.read_pickle(path_to_pickle)

    df = df.reset_index(drop=True)

    return df


def prepare_dataframe_for_analysis(df):
    df = df[["timeStamp", "sfn", "slot",
             "rnti",
             "dlHarqRxDataArray.dtx",
             "dlHarqRxDataArray.ackNack",
             "ulHarqRxData.dtx",
             "dlHarqRxDataArray.radioLinkFailureStatus",
             "csiSrReportData.dtx",
             "csiSrReportData.csiReport.cqi",
             "ulPucchReceiveRespPsData.sinr",
             "dlFdSchedData.dciFormat",
             "dlFdSchedData.startPrb",
             "dlFdSchedData.numOfPrb",
             "dlFdSchedData.rat0Bitmap",
             "dlFdSchedData.cqiAlSelection",
             "dlFdSchedData.aggregationLevel",
             "dlFdSchedData.searchSpaceId",
             "dlFdSchedData.pdcchCqi",
             "dlFdSchedData.pdcchPowerBoostType",
             "dlFdSchedData.mcsTable",
             # cqiPdcchReduction not in ulFdSchedData
             "dlFdSchedData.cqiPdcchReduction",
             "dlFdSchedData.cqiPdcchOffset",
             # laMode not in ulFdSchedData
             "dlFdSchedData.laMode",
             "dlFdSchedData.dciSizeOffset",
             "dlPdcchDciData.ueDciInfoList",
             "dlPreTdBlockUeData.cs2BlockUeList",
             "ulFdSchedData.cqiAlSelection",
             "ulFdSchedData.aggregationLevel",
             "ulFdSchedData.pdcchPowerBoostType",
             "ulFdSchedData.pdcchCqi",
             "ulFdSchedData.cqiPdcchOffset",
             "ulFdSchedData.mcsTable",
             "ulFdSchedData.dciSizeOffset",
             "ulPdcchDciData.ueDciInfoList",
             "ulPreTdBlockUeData.cs2BlockUeList"]]

    df = df.rename(columns={
        "dlHarqRxDataArray.dtx": "dlHarqDtx",
        "dlHarqRxDataArray.ackNack": "dlHarqAckNack",
        "ulHarqRxData.dtx": "ulHarqDtx",
        "dlHarqRxDataArray.radioLinkFailureStatus": "dlRlfStatus",
        "csiSrReportData.dtx": "CqiDtx",
        "csiSrReportData.csiReport.cqi": "CqiIn",
        "ulPucchReceiveRespPsData.sinr": "PucchSinr",
        "dlFdSchedData.cqiAlSelection": "dlCqiSel",
        "dlFdSchedData.dciFormat": "dlDci",
        "dlFdSchedData.startPrb": "dlStartPrb",
        "dlFdSchedData.numOfPrb": "dlNumOfPrb",
        "dlFdSchedData.rat0Bitmap": "rat0Bitmap",
        "dlFdSchedData.searchSpaceId": "dlsearchSpId",
        "dlFdSchedData.aggregationLevel": "dlAL",
        "dlFdSchedData.pdcchPowerBoostType": "dlPwBoost",
        "dlFdSchedData.pdcchCqi": "dlPdcchCqi",
        "dlFdSchedData.cqiPdcchReduction": "dlPdcchRed",
        "dlFdSchedData.cqiPdcchOffset": "dlCqiOffset",
        "dlFdSchedData.laMode": "laMode",
        "dlFdSchedData.mcsTable": "dlMcs",
        "dlFdSchedData.dciSizeOffset": "dlDciOffset",
        "dlPdcchDciData.ueDciInfoList": "dlDciInfoList",
        "dlPreTdBlockUeData.cs2BlockUeList": "dlcs2BlckReason",
        "ulFdSchedData.cqiAlSelection": "ulCqiSel",
        "ulFdSchedData.aggregationLevel": "ulAL",
        "ulFdSchedData.pdcchPowerBoostType": "ulPwBoost",
        "ulFdSchedData.pdcchCqi": "ulPdcchCqi",
        "ulFdSchedData.cqiPdcchOffset": "ulCqiOffset",
        "ulFdSchedData.mcsTable": "ulMcs",
        "ulFdSchedData.dciSizeOffset": "ulDciOffset",
        "ulPdcchDciData.ueDciInfoList": "ulDciInfoList",
        "ulPreTdBlockUeData.cs2BlockUeList": "ulcs2BlckReason"})

    # Convert to binary, for debugging purposes
    # df['b_rat0Bitmap'] = df['rat0Bitmap'].map(lambda x: format(int(x), '020b'))

    return df


def prepare_dl_dataframe_for_analysis(df):
    df = df[["timeStamp", "sfn", "slot",
             "rnti",
             "dlHarqRxDataArray.dtx",
             "dlHarqRxDataArray.ackNack",
             "dlHarqRxDataArray.radioLinkFailureStatus",
             "csiSrReportData.dtx",
             "csiSrReportData.csiReport.cqi",
             "dlFdSchedData.dciFormat",
             "dlFdSchedData.startPrb",
             "dlFdSchedData.numOfPrb",
             "dlFdSchedData.rat0Bitmap",
             "dlFdSchedData.cqiAlSelection",
             "dlFdSchedData.aggregationLevel",
             "dlFdSchedData.searchSpaceId",
             "dlFdSchedData.pdcchCqi",
             "dlFdSchedData.txNumber",
             "dlFdSchedData.pdcchPowerBoostType",
             "dlFdSchedData.mcsTable",
             # cqiPdcchReduction not in ulFdSchedData
             "dlFdSchedData.cqiPdcchReduction",
             "dlFdSchedData.cqiPdcchOffset",
             # laMode not in ulFdSchedData
             "dlFdSchedData.laMode",
             "dlFdSchedData.dciSizeOffset",
             "dlPagingOrSibSchedData.dciFormat",
             "dlPagingOrSibSchedData.aggregationLevel",
             "dlPdcchDciData.ueDciInfoList",
             "dlPreTdBlockUeData.cs2BlockUeList"]]

    df = df.rename(columns={
        "dlHarqRxDataArray.dtx": "dlHarqDtx",
        "dlHarqRxDataArray.ackNack": "dlHarqAckNack",
        "dlHarqRxDataArray.radioLinkFailureStatus": "dlRlfStatus",
        "csiSrReportData.dtx": "CqiDtx",
        "csiSrReportData.csiReport.cqi": "CqiIn",
        "dlFdSchedData.cqiAlSelection": "dlCqiSel",
        "dlFdSchedData.dciFormat": "dlDci",
        "dlFdSchedData.startPrb": "dlStartPrb",
        "dlFdSchedData.numOfPrb": "dlNumOfPrb",
        "dlFdSchedData.rat0Bitmap": "rat0Bitmap",
        "dlFdSchedData.searchSpaceId": "dlsearchSpId",
        "dlFdSchedData.aggregationLevel": "dlAL",
        "dlFdSchedData.txNumber": "dltxNum",
        "dlFdSchedData.pdcchPowerBoostType": "dlPwBoost",
        "dlFdSchedData.pdcchCqi": "dlPdcchCqi",
        "dlFdSchedData.cqiPdcchReduction": "dlPdcchRed",
        "dlFdSchedData.cqiPdcchOffset": "dlCqiOffset",
        "dlFdSchedData.laMode": "laMode",
        "dlFdSchedData.mcsTable": "dlMcs",
        "dlFdSchedData.dciSizeOffset": "dlDciOffset",
        "dlPagingOrSibSchedData.dciFormat": "dlPagingDci",
        "dlPagingOrSibSchedData.aggregationLevel": "dlPagingAL",
        "dlPdcchDciData.ueDciInfoList": "dlDciInfoList",
        "dlPreTdBlockUeData.cs2BlockUeList": "dlcs2BlckReason"})

    # Convert to binary, for debugging purposes
    # df['b_rat0Bitmap'] = df['rat0Bitmap'].map(lambda x: format(int(x), '020b'))

    return df


def prepare_ul_dataframe_for_analysis(df):
    df = df[["timeStamp", "sfn", "slot",
             "rnti",
             "ulHarqRxData.dtx",
             "csiSrReportData.dtx",
             "csiSrReportData.csiReport.cqi",
             "ulPucchReceiveRespPsData.sinr",
             "ulFdSchedData.dciFormat",
             "ulFdSchedData.searchSpaceId",
             "ulFdSchedData.cqiAlSelection",
             "ulFdSchedData.aggregationLevel",
             "ulFdSchedData.pdcchPowerBoostType",
             "ulFdSchedData.pdcchCqi",
             "ulFdSchedData.cqiPdcchOffset",
             "ulFdSchedData.mcsTable",
             "ulFdSchedData.dciSizeOffset",
             "ulPdcchDciData.ueDciInfoList",
             "ulPreTdBlockUeData.cs2BlockUeList"]]

    df = df.rename(columns={
        "ulHarqRxData.dtx": "ulHarqDtx",
        "csiSrReportData.dtx": "CqiDtx",
        "csiSrReportData.csiReport.cqi": "CqiIn",
        "ulPucchReceiveRespPsData.sinr": "PucchSinr",
        "ulFdSchedData.dciFormat": "ulDci",
        "ulFdSchedData.searchSpaceId": "ulsearchSpId",
        "ulFdSchedData.cqiAlSelection": "ulCqiSel",
        "ulFdSchedData.aggregationLevel": "ulAL",
        "ulFdSchedData.pdcchPowerBoostType": "ulPwBoost",
        "ulFdSchedData.pdcchCqi": "ulPdcchCqi",
        "ulFdSchedData.cqiPdcchOffset": "ulCqiOffset",
        "ulFdSchedData.mcsTable": "ulMcs",
        "ulFdSchedData.dciSizeOffset": "ulDciOffset",
        "ulPdcchDciData.ueDciInfoList": "ulDciInfoList",
        "ulPreTdBlockUeData.cs2BlockUeList": "ulcs2BlckReason"})

    return df


def plot_data(udf, link, path):
    udfSinr = udf[pd.notnull(udf.PucchSinr)]
    udfSinr.PucchSinr = udfSinr.PucchSinr.map(lambda x: x[0])
    SinrTime = udfSinr[udfSinr.PucchSinr < -255].timeStamp
    SinrValue = udfSinr[udfSinr.PucchSinr < -255].PucchSinr

    # this gets rid of all lines where AL has no value
    dfNoNull = udf[pd.notnull(udf[link+"AL"])]

    udfDtx = udf[pd.notnull(udf["dlHarqDtx"]) | pd.notnull(udf["CqiDtx"])]

    fig = go.Figure()

    fig.add_trace(go.Scatter(
        x=dfNoNull.timeStamp, y=dfNoNull[link+'AL'],
        mode='markers', name=link+"AL", marker=dict(size=2)
    ))
    fig.add_trace(go.Scatter(
        x=dfNoNull.timeStamp, y=dfNoNull[link+'CqiSel'],
        mode='markers', name=link+"CqiSel", marker=dict(size=2)
    ))
    fig.add_trace(go.Scatter(
        x=udf.timeStamp, y=udf.CqiIn,
        mode='lines+markers', name="Cqi UE", marker=dict(size=3)
    ))
    fig.add_trace(go.Scatter(
        x=udfDtx.timeStamp, y=udfDtx['dlHarqDtx'],
        mode='markers', name="dlHarqDtx", marker=dict(size=4, color="orange"), yaxis="y2"
    ))
    fig.add_trace(go.Scatter(
        x=udfDtx.timeStamp, y=udfDtx['CqiDtx'],
        mode='markers', name="CqiDtx", marker=dict(size=4, color="red"), yaxis="y2"
    ))
    fig.add_trace(go.Scatter(
        x=SinrTime, y=SinrValue,
        mode='markers', name="PucchSinr", marker=dict(size=4, color="blue"), yaxis="y2"
    ))
    AlThs = [4, 7, 10, 13]
    for i in AlThs:
        fig.add_hline(y=i, line_width=0.5, line_color="black")

    title = "plot "+link+"AL and CQIsel"
    fig.update_layout(
        title=title, xaxis_title="Time", yaxis_title="AL and CQI_sel",
        yaxis2=dict(
            overlaying="y",
            side="left"
        )
    )
    file_name = "/" + title.replace(" ", "_") + (".html")
    fig.write_html(path+file_name, auto_open=False)


def save_data_for_analysis(udf):
    path_to_pickle = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    file_cvs = "%s/manual_analysis_HR_AL_selection_with_changing_CQI_values.csv"
    udf.to_csv(str(file_cvs % get_directory(path_to_pickle)), sep=';')


def save_data_for_analysis_rnti(udf, rnti):
    path_to_pickle = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    file_cvs = "%s/manual_analysis_HR_AL_selection_with_changing_CQI_values_rnti_" + rnti + ".csv"
    udf.to_csv(str(file_cvs % get_directory(path_to_pickle)), sep=';')

    # for link in ["dl", "ul"]:
    #     plot_data(udf, link, get_directory(path_to_pickle))


# ----------------------------------------------------------------------------------- CQI Changes
@log_begin_end_func_name
def Verify_HR_AL_selection_with_changing_CQI_values():

    df = load_dataframe("pkl")
    udf = prepare_dataframe_for_analysis(df)

    save_data_for_analysis(udf)

    areResultsCorrect = True
    try:
        areResultsCorrect &= checkAl1(udf)
        areResultsCorrect &= checkAlSelectionWhenCqiIsIncreasing(udf)
        areResultsCorrect &= checkAlSelectionWhenCqiIsDecreasing(udf)
    except Exception as e:
        areResultsCorrect = False
        logException("Verify_CB012738_AlSelection_CQI", e)

    rbi.should_be_true(areResultsCorrect)


@log_begin_end_func_name
def Verify_AL_selection_with_changing_CQI_values(path_to_pickle, dir='all', ue_rnti=None,
                                                 validate=None, nbrEvent=None):

    global pd
    pd = pandas_gate.install_and_import_pandas()
    visualization()
    df = pd.read_pickle(path_to_pickle)
    df_filtered = df[df["csiSrReportData.csiReport.cqi"] != 255]
    if nbrEvent is not None:
        df_filtered = df_filtered.head(nbrEvent)
    if dir == "all":
        udf = prepare_dataframe_for_analysis(df_filtered)
    elif dir == "dl":
        udf = prepare_dl_dataframe_for_analysis(df_filtered)
    else:
        udf = prepare_ul_dataframe_for_analysis(df_filtered)

    if ue_rnti is None:
        udf_rnti = udf
    else:
        # udf_rnti = udf[udf['rnti'] == int(ue_rnti)]
        # Find the row where 'ue_rnti' is in 'dlDciInfoList'
        # for index, row in udf.iterrows():
        #     if row['dlDciInfoList'] is not None:
        #         for item in row['dlDciInfoList']:
        #             if int(ue_rnti) == item['rnti']:
        #                udf.loc[index, 'rnti'] = int(ue_rnti)
        #                udf.loc[index, 'dlDciInfoList'] = str(item)
        #                break
        for link in ["dl", "ul"]:
            udf = udf.reset_index(drop=True)
            for index, row in udf.iterrows():
                if row[link + 'DciInfoList'] is not None:
                    item_upated = False
                    for item in row[link + 'DciInfoList']:
                        if int(ue_rnti) == item['rnti']:
                            udf.loc[index, 'rnti'] = int(ue_rnti)
                            udf.loc[index, link + 'DciInfoList'] = str(item)
                            item_upated = True
                            break
                    if not item_upated:
                        udf.loc[index, link + 'DciInfoList'] = None
        udf_rnti = udf[udf['rnti'] == int(ue_rnti)]

    save_data_for_analysis_unitary_test(udf_rnti, path_to_ttitrace_pkl=path_to_pickle, dir=dir)

    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        areResultsCorrect = True
        try:
            areResultsCorrect &= checkAl1(udf_rnti)
            areResultsCorrect &= checkAlSelectionWhenCqiIsIncreasing(udf_rnti)
            areResultsCorrect &= checkAlSelectionWhenCqiIsDecreasing(udf_rnti)
        except Exception as e:
            areResultsCorrect = False
            logException("Verify_CB012738_AlSelection_CQI", e)

        logging.info("areResultsCorrect: %s" % areResultsCorrect)


def save_data_for_analysis_unitary_test(udf, path_to_ttitrace_pkl, dir='all'):
    path_to_pickle = path_to_ttitrace_pkl
    file_cvs = '%s/manual_analysis_%s_AL_selection_with_changing_CQI_values.csv'
    udf.to_csv(str(file_cvs % (get_directory(path_to_pickle), dir)), sep=';')


@log_begin_end_func_name
def Verify_HR_AL_selection_with_changing_CQI_values_rnti(rnti, validate=None, need_return=False,
                                                         nbrEvent=8000, w_filter_dci=True):

    df = load_dataframe("pkl")
    df_filtered = df[df["csiSrReportData.csiReport.cqi"] != 255]
    if nbrEvent is not None:
        df_filtered = df_filtered.head(nbrEvent)
    udf = prepare_dataframe_for_analysis(df_filtered)

    # udf_rnti = udf[udf['rnti'] == int(rnti)]
    if w_filter_dci:
        for link in ["dl", "ul"]:
            udf = udf.reset_index(drop=True)
            for index, row in udf.iterrows():
                if row[link + 'DciInfoList'] is not None:
                    item_upated = False
                    for item in row[link + 'DciInfoList']:
                        if int(rnti) == item['rnti']:
                            udf.loc[index, 'rnti'] = int(rnti)
                            udf.loc[index, link + 'DciInfoList'] = str(item)
                            item_upated = True
                            break
                    if not item_upated:
                        udf.loc[index, link + 'DciInfoList'] = None
    udf_rnti = udf[udf['rnti'] == int(rnti)]

    save_data_for_analysis_rnti(udf_rnti, rnti)

    areResultsCorrect = True
    try:
        areResultsCorrect &= checkAl1(udf_rnti)
        areResultsCorrect &= checkAlSelectionWhenCqiIsIncreasing(udf_rnti)
        areResultsCorrect &= checkAlSelectionWhenCqiIsDecreasing(udf_rnti)
    except Exception as e:
        areResultsCorrect = False
        logException("Verify_CB012738_AlSelection_CQI", e)

    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        rbi.should_be_true(areResultsCorrect)

    if need_return:
        return udf_rnti


@log_begin_end_func_name
def Verify_HR_AL_selection_with_changing_CQI_values_rnti_v1(rnti, validate=None, need_return=False, nbrEvent=2000):

    df = load_dataframe("pkl")
    df_filtered = df[df["csiSrReportData.csiReport.cqi"] != 255]
    df_filtered = df_filtered.head(nbrEvent)
    udf = prepare_dataframe_for_analysis(df_filtered)

    udf_rnti = udf[udf['rnti'] == int(rnti)]
    for index, row in udf.iterrows():
        if row['dlDciInfoList'] is not None:
            for item in row['dlDciInfoList']:
                if int(rnti) == item['rnti']:
                    udf.loc[index, 'rnti'] = int(rnti)
                    udf.loc[index, 'dlDciInfoList'] = str(item)
                    break

    udf_rnti = udf[udf['rnti'] == int(rnti)]

    save_data_for_analysis_rnti(udf_rnti, rnti)

    areResultsCorrect = True
    try:
        areResultsCorrect &= checkAl1(udf_rnti)
        areResultsCorrect &= checkAlSelectionWhenCqiIsIncreasing(udf_rnti)
        areResultsCorrect &= checkAlSelectionWhenCqiIsDecreasing(udf_rnti)
    except Exception as e:
        areResultsCorrect = False
        logException("Verify_CB012738_AlSelection_CQI", e)

    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        rbi.should_be_true(areResultsCorrect)

    if need_return:
        return udf_rnti


@log_begin_end_func_name
def checkAl1(df):
    # Check for ul and dl the correct AL above AL1 threshold
    result = True
    for link in ["dl", "ul"]:
        df1 = df[df[link+"CqiSel"] >= AlTh1]
        result &= not df1.empty
        result &= all(df1[link+"AL"] == 1)
        df1_bad = df1[df1[link+"AL"] != 1]
        logging.info("checkAl1 Result %s for link %s " % (result, link))
        logging.info("checkAl1 with AlTh1 %s for link %s df1_bad=: %s" % (AlTh1, link, df1_bad))

    logging.info("checkAl1: %s" % result)
    return result


@log_begin_end_func_name
def checkAlSelectionWhenCqiIsIncreasing(df):
    # Only use the first part of the data, where AL is decreasing

    ALs = [8, 4, 2]

    AlThs = [AlTh4, AlTh2, AlTh1]

    result = True
    for link in ["dl", "ul"]:
        lastIndexOfAl1 = df[df[link+"AL"] == 1].last_valid_index()
        udfCqiUp = df[df.index <= lastIndexOfAl1]
        result &= not udfCqiUp.empty

        for i in range(3):
            idx = udfCqiUp[udfCqiUp[link+"CqiSel"] < AlThs[i]].last_valid_index()
            last_valid_index = udfCqiUp[udfCqiUp[link + "AL"] == ALs[i]].last_valid_index()
            result &= ((udfCqiUp[udfCqiUp[link+"AL"] == ALs[i]].last_valid_index()) == idx)

    logging.info("checkAlSelectionWhenCqiIsIncreasing: %s" % result)
    return result


@log_begin_end_func_name
def checkAlSelectionWhenCqiIsDecreasing(df):
    # Only use the second part of the data, where AL is increasing
    ALs = [2, 4, 8]

    AlThs = [AlTh1, AlTh2, AlTh4]

    result = True
    for link in ["dl", "ul"]:
        firstIndexOfAl1 = df[df[link+"AL"] == 1].first_valid_index()
        udfCqiDown = df[df.index >= firstIndexOfAl1]
        result &= not udfCqiDown.empty

        for i in range(3):
            # Check that the correct AL is selected, when cqiSelection goes below a threshold
            # Info: Check for cqiSelection below AL8 threshold is done separately
            idx = udfCqiDown[udfCqiDown[link+"CqiSel"] < AlThs[i]].first_valid_index()
            result &= (udfCqiDown[udfCqiDown[link+"AL"] == ALs[i]].first_valid_index() == idx)

    logging.info("checkAlSelectionWhenCqiIsDecreasing: %s" % result)
    return result


# ----------------------------------------------------------------------------------- CSI/CQI DTX
@log_begin_end_func_name
def Verify_HR_erasure_timer_expiration_for_invalid_CQI():

    df = load_dataframe("pkl")
    udf = prepare_dataframe_for_analysis(df)

    result = True
    try:
        for link in ["dl", "ul"]:
            # data preparations
            idx = udf[udf[link+"AL"] == 2].last_valid_index()
            dfEndRemoved = udf[udf.index < idx]
            result &= not dfEndRemoved.empty
            lastNonDtxIndex = dfEndRemoved[dfEndRemoved.CqiDtx == "NON_DTX"].last_valid_index()
            lastNonDtxTime = dfEndRemoved.at[lastNonDtxIndex, "timeStamp"]

            dfValidCqi = udf[udf.index < lastNonDtxIndex]
            result &= not dfValidCqi.empty
            dfValidCqi = dfValidCqi[pd.notnull(dfValidCqi.dlPdcchRed)]

            # from last NonDtx time until this time the erasure process should have been started
            timeUntilErasureHasStarted = lastNonDtxTime + pd.Timedelta(seconds=0.2)
            dfErasureStart = dfEndRemoved[(dfEndRemoved.timeStamp > lastNonDtxTime)
                                          & (dfEndRemoved.timeStamp < timeUntilErasureHasStarted)]

            # data checks
            # when valid CQIs are received, the erasure process should be disabled => cqiPdcchReduction = 255
            result &= all(dfValidCqi.dlPdcchRed == 255)
            # when the erasure process starts => cqiPdcchReduction != 255
            result &= any(dfErasureStart.dlPdcchRed != 255)

    except Exception as e:
        result = False
        logException("Verify_CB012738_TimerExpiration_InvalidCqi", e)

    rbi.should_be_true(result)


# ----------------------------------------------------------------------------------- HARQ DTX
@log_begin_end_func_name
def Verify_HR_AL_selection_with_HARQ_DTX_injection():

    df = load_dataframe("pkl")
    udf = prepare_dataframe_for_analysis(df)

    save_data_for_analysis(udf)

    areResultsCorrect = True
    try:
        areResultsCorrect &= checkALAndCqiStart(udf)
        areResultsCorrect &= checkHarqDtxInfluence(udf)
    except Exception as e:
        areResultsCorrect = False
        logException("Verify_CB012738_AlSelection_HarqDtx", e)

    rbi.should_be_true(areResultsCorrect)


def checkALAndCqiStart(udf):
    result = True
    for link in ["dl", "ul"]:
        dfNoNull = udf[pd.notnull(udf[link+"AL"])]
        result &= not dfNoNull.empty
        result &= (dfNoNull[link+"AL"].iloc[0] == 1)
        result &= (dfNoNull[link+"CqiSel"].iloc[0] >= AlTh1)

    logging.info("checkALAndCqiStart %s" % result)
    return result


def checkHarqDtxInfluence(udf):
    result = True

    # get the index of the first Harq Dtx
    first_dtx_idx = udf[udf["dlHarqDtx"] == "DTX"].first_valid_index()
    # get the dataframe where the first 5 Harq Dtxs are in
    udf_1 = udf[udf.index < first_dtx_idx + 500]
    dtx_idxs_1 = udf_1[udf_1["dlHarqDtx"] == "DTX"].index.values.tolist()

    # get the index of the last Harq Dtx
    last_dtx_idx = udf[udf["dlHarqDtx"] == "DTX"].last_valid_index()
    # get the dataframe where the second 5 Harq Dtxs are in
    udf_2 = udf[udf.index > last_dtx_idx - 500]
    dtx_idxs_2 = udf_2[udf_2["dlHarqDtx"] == "DTX"].index.values.tolist()

    for link in ["dl", "ul"]:
        # for the first 5 inserted Harq Dtxs:
        # check that cqiAlSelection drops shortly after the first Harq Dtx and increases again after the last
        valid_idx_before_first_HarqDtx = udf[link+"CqiSel"][udf.index < dtx_idxs_1[0]].last_valid_index()
        valid_idx_with_last_HarqDtx = udf[link+"CqiSel"][udf.index > dtx_idxs_1[-1]].first_valid_index()
        valid_idx_after_last_HarqDtx = udf[link+"CqiSel"][udf.index > dtx_idxs_1[-1] + 100].first_valid_index()

        result &= udf[link+"CqiSel"].iloc[valid_idx_before_first_HarqDtx] > \
            udf[link+"CqiSel"].iloc[valid_idx_with_last_HarqDtx]

        result &= udf[link+"CqiSel"].iloc[valid_idx_after_last_HarqDtx] > \
            udf[link+"CqiSel"].iloc[valid_idx_with_last_HarqDtx]

        # for the second 5 inserted Harq Dtxs:
        # check that cqiAlSelection drops shortly after the first Harq Dtx and increases again after the last
        valid_idx_before_first_HarqDtx = udf[link+"CqiSel"][udf.index < dtx_idxs_2[0]].last_valid_index()
        valid_idx_with_last_HarqDtx = udf[link+"CqiSel"][udf.index > dtx_idxs_2[-1]].first_valid_index()
        valid_idx_after_last_HarqDtx = udf[link+"CqiSel"][udf.index > dtx_idxs_2[-1] + 100].first_valid_index()

        result &= udf[link+"CqiSel"].iloc[valid_idx_before_first_HarqDtx] > \
            udf[link+"CqiSel"].iloc[valid_idx_with_last_HarqDtx]

        result &= udf[link+"CqiSel"].iloc[valid_idx_after_last_HarqDtx] > \
            udf[link+"CqiSel"].iloc[valid_idx_with_last_HarqDtx]

    # check that AL was changed during the scenario execution
    result &= any(udf[link+"AL"][pd.notnull(udf[link+"AL"])] != 1)

    logging.info("checkHarqDtxInfluence %s" % result)
    return result


# ----------------------------------------------------------------------------------- Online Modification
@log_begin_end_func_name
def Verify_Online_Modification_of_HR_parameters():
    df = load_dataframe("pkl")
    udf = prepare_dataframe_for_analysis(df)

    save_data_for_analysis(udf)

    # data from before the first UE deregisters
    firstBrIndex = udf[udf.laMode == "BASICRELIABILITY"].first_valid_index()
    dfMod = udf[udf.index < firstBrIndex]

    # data after the new UE registers
    lastBrIndex1 = udf[udf.laMode == "BASICRELIABILITY"].last_valid_index()
    lastBrIndex2 = udf[(udf.dlDciOffset == 0) & (udf.laMode == "HIGHRELIABILITY")].last_valid_index()
    lastBrIndex = max(lastBrIndex1, lastBrIndex2)
    dfReg = udf[udf.index > lastBrIndex]

    areResultsCorrect = True
    try:
        areResultsCorrect &= checkCqiInput(dfMod)
        areResultsCorrect &= checkCqiInput(dfReg)
        areResultsCorrect &= VerifyOnlineModificationForInitialUE(dfMod)
        areResultsCorrect &= VerifyOnlineModificationForNewUE(dfReg, lastBrIndex)
    except Exception as e:
        areResultsCorrect = False
        logException("Verify_CB012738_Online_Modification", e)

    rbi.should_be_true(areResultsCorrect)


def checkCqiInput(df):
    # Received CQI is always 13
    dfCqiIn_NoNull = df[pd.notnull(df.CqiIn)]
    result = not dfCqiIn_NoNull.empty
    result &= all(dfCqiIn_NoNull.CqiIn == 13)

    logging.info("checkCqiInput: %s" % result)
    return result


def VerifyOnlineModificationForInitialUE(dfMod):
    areResultsCorrect = True
    try:
        areResultsCorrect &= checkAlAndCqiAtTheBeginning(dfMod)
        areResultsCorrect &= checkAlAndCqiInTheMiddle(dfMod)
        areResultsCorrect &= checkAlAndCqiAtTheEnd(dfMod)
    except Exception as e:
        areResultsCorrect = False
        logException("VerifyOnlineModificationForInitialUE", e)

    rbi.should_be_true(areResultsCorrect)
    return areResultsCorrect


def checkAlAndCqiAtTheBeginning(dfMod):
    result = True
    for link in ["dl", "ul"]:
        dfModNoNull = dfMod[pd.notnull(dfMod[link+"AL"])]
        result &= not dfModNoNull.empty

        # at first AL is always 2; also CqiSel is < AlTh1 and >= AlTh2
        firstIndexOfDf = dfMod.first_valid_index()
        lastIndexOfAl2 = dfMod[dfMod[link+"AL"] == 2].last_valid_index()
        dfAl2 = dfModNoNull[(dfModNoNull.index >= firstIndexOfDf) & (dfModNoNull.index <= lastIndexOfAl2)]

        result &= not dfAl2.empty
        result &= all(dfAl2[link+"AL"] == 2)
        result &= all(dfAl2[link+"CqiSel"] < AlTh1) & all(dfAl2[link+"CqiSel"] >= AlTh2)

    logging.info("checkAlAndCqiAtTheBeginning: %s" % result)
    return result


def checkAlAndCqiInTheMiddle(dfMod):
    result = True
    for link in ["dl", "ul"]:
        dfModNoNull = dfMod[pd.notnull(dfMod[link+"AL"])]
        result &= not dfModNoNull.empty

        # then AL is always 4, CqiSel remained as in the step before (< AlTh1 and >= AlTh2)
        # this means that AlTh2 was actually increased beyond the current CqiSel
        lastIndexOfAl2 = dfModNoNull[dfModNoNull[link+"AL"] == 2].last_valid_index()
        lastIndexOfAl4 = dfModNoNull[dfModNoNull[link+"AL"] == 4].last_valid_index()
        dfAl4 = dfModNoNull[(dfModNoNull.index > lastIndexOfAl2) & (dfModNoNull.index <= lastIndexOfAl4)]
        result &= not dfAl4.empty
        result &= all(dfAl4[link+"AL"] == 4)
        result &= all(dfAl4[link+"CqiSel"] < AlTh1) & all(dfAl4[link+"CqiSel"] >= AlTh2)

    logging.info("checkAlAndCqiInTheMiddle: %s" % result)
    return result


def checkAlAndCqiAtTheEnd(dfMod):
    result = True
    for link in ["dl", "ul"]:
        dfModNoNull = dfMod[pd.notnull(dfMod[link+"AL"])]
        result &= not dfModNoNull.empty

        # then CqiSel < AlTh4 and AL is 8
        # because the received CQI is always 14, this means that the algo changed the CqiSel value
        # due to a changed parameter
        lastIndexOfAl4 = dfModNoNull[dfModNoNull[link+"AL"] == 4].last_valid_index()
        lastIndexOfAl8 = dfModNoNull[dfModNoNull[link+"AL"] == 8].last_valid_index()
        dfModAl8 = dfModNoNull[(dfModNoNull.index > lastIndexOfAl4) & (dfModNoNull.index <= lastIndexOfAl8)]
        result &= not dfModAl8.empty
        result &= all(dfModAl8[link+"AL"] == 8)
        result &= all(dfModAl8[link+"CqiSel"] < AlTh4)

    logging.info("checkAlAndCqiAtTheEnd: %s" % result)
    return result


def VerifyOnlineModificationForNewUE(dfReg, lastBrIndex):
    areResultsCorrect = True
    try:
        areResultsCorrect &= checkAlAndCqiAfterRegister(dfReg, lastBrIndex)
        areResultsCorrect &= checkAlAndCqiAfterNiddRevert(dfReg)
    except Exception as e:
        areResultsCorrect = False
        logException("VerifyOnlineModificationForNewUE", e)

    rbi.should_be_true(areResultsCorrect)
    return areResultsCorrect


def checkAlAndCqiAfterRegister(dfReg, lastBrIndex):
    result = True
    for link in ["dl", "ul"]:
        dfRegNoNull = dfReg[pd.notnull(dfReg[link+"AL"])]
        result &= not dfRegNoNull.empty
        # for new UE check again that still CqiSel < AlTh4 and AL is 8
        lastIndexOfAl8 = dfRegNoNull[dfRegNoNull[link+"AL"] == 8].last_valid_index()
        dfRegAl8 = dfRegNoNull[(dfRegNoNull.index > lastBrIndex) & (dfRegNoNull.index <= lastIndexOfAl8)]
        result &= not dfRegAl8.empty
        result &= all(dfRegAl8[link+"AL"] == 8)
        result &= all(dfRegAl8[link+"CqiSel"] < AlTh4)

    logging.info("checkAlAndCqiAfterRegister: %s" % result)
    return result


def checkAlAndCqiAfterNiddRevert(dfReg):
    result = True
    for link in ["dl", "ul"]:
        dfRegNoNull = dfReg[pd.notnull(dfReg[link+"AL"])]
        result &= not dfRegNoNull.empty

        # check that pdcchCqiOffsetHR was set to 0 again for new UE
        lastIndexOfAl4 = dfRegNoNull[dfRegNoNull[link+"AL"] == 4].last_valid_index()
        lastIndexOfAl8 = dfRegNoNull[dfRegNoNull[link+"AL"] == 8].last_valid_index()
        dfAl4 = dfRegNoNull[(dfRegNoNull.index > lastIndexOfAl8) & (dfRegNoNull.index <= lastIndexOfAl4)]
        result &= not dfAl4.empty
        result &= all(dfAl4[link+"AL"] == 4)
        result &= all(dfAl4[link+"CqiSel"] < AlTh1) & all(dfAl4[link+"CqiSel"] >= AlTh2)

    logging.info("checkAlAndCqiAfterNiddRevert: %s" % result)
    return result


def calculate_pdcch_dci_transmit_power(N_RB_SC=12, NRB=106, pdcchPowerOffset=0,
                                       pdcchPowerOffsetAdd=0, staticPdcchPowerOffset=0):
    """
    :param N_RB_SC: N_RB_SC =12: resource block size in the frequency domain (expressed as the number of subcarriers)
    :param NRB: the total number of PRBs over the carrier bandwidth. It equals to MRBTS/NRBTS/NRCELLGRP/dlBandwidth
    :param pdcchPowerOffset: the extra power offset that applies to the transmit power of PDCCH under some conditions
    :param pdcchPowerOffsetAdd: the power offset from PDCCH power boosting.
     If PDCCH power boosting flag is marked as 5G_UP_ALG_29346/5G_UP_ALG_29348
    :param staticPdcchPowerOffset: Static power offset added on the PDCCH transmit power specified by 5G_L2_3121.
    :return: pdcchDciTransmitPower
    """
    pdcchDciTransmitPower = -10 * math.log10(N_RB_SC * NRB) + pdcchPowerOffset + pdcchPowerOffsetAdd
    pdcchDciTransmitPower = pdcchDciTransmitPower + staticPdcchPowerOffset
    return pdcchDciTransmitPower


def calculate_pdcch_dci_transmit_power_wo_CB012738(N_RB_SC=12, NRB=106, pdcchPowerOffset=0, staticPdcchPowerOffset=0):
    """
    :param N_RB_SC: N_RB_SC =12: resource block size in the frequency domain (expressed as the number of subcarriers)
    :param NRB: the total number of PRBs over the carrier bandwidth. It equals to MRBTS/NRBTS/NRCELLGRP/dlBandwidth
    :param pdcchPowerOffset: the extra power offset that applies to the transmit power of PDCCH under some conditions
    :param staticPdcchPowerOffset: Static power offset added on the PDCCH transmit power specified by 5G_L2_3121.
    :return: pdcchDciTransmitPower
    """
    pdcchDciTransmitPower = -10 * math.log10(N_RB_SC * NRB) + pdcchPowerOffset + staticPdcchPowerOffset
    return pdcchDciTransmitPower


# Function to calculate pdcch_dci_transmit_power
def calculate_pdcch_dci_transmit_power_from_df(row):
    return -10 * math.log10(row['N_RB_SC'] * row['NRB']) + row['pdcchPowerOffset'] +\
        row['pdcchPowerOffsetAdd'] + row['staticPdcchPowerOffset']


def calculate_pdcch_dci_transmit_power_wo_CB012738_from_df(row):
    return -10 * math.log10(row['N_RB_SC'] * row['NRB']) + row['pdcchPwOffset_1'] + row['staticPdcchPowerOffset']


def get_prb_values(cellTechnology, chBW, nbrOfBlankedPRBsDL):
    """ This function returns the desired prb values from the list present on the specification according
        to the duplex, technology and bandwidth used.

        Sample row:
        Duplex	System BW(MHz)	Transmission BW(PRB)
          FDD	    20	               106


        :return float variable of max_prb_from_cell_bw

    """
    pd = pandas_gate.install_and_import_pandas()
    df = pd.DataFrame({'Duplex': ['FDD', 'FDD', 'FDD', 'FDD', 'FDD', 'TDD', 'TDD', 'TDD', 'TDD', 'TDD', 'TDD', 'TDD',
                                  'TDD', 'TDD'],
                       'System BW(MHz)': [5, 10, 15, 20, 40, 20, 30, 40, 50, 60, 70, 80, 90, 100],
                       'Transmission BW(PRB)': [25, 52, 79, 106, 216, 51, 78, 106, 133, 162, 189, 217, 245, 273]})
    prb_row = df.loc[(df['System BW(MHz)'] == chBW) & (df['Duplex'] == cellTechnology)]
    max_prb_from_cell_bw = prb_row['Transmission BW(PRB)'].iloc[0]
    # dont take into the nbrOfBlankedPRBsDL here !!!
    # max_prb_from_cell_bw = max_prb_from_cell_bw - nbrOfBlankedPRBsDL

    return max_prb_from_cell_bw


def get_maxNumberOfPRBperSlot(cellTechnology_NRCELL, chBW_NRCELL, nbrOfBlankedPRBsDL_NRCELL, lcrId=1):
    maxNumberPRBperSLot = get_prb_values(cellTechnology_NRCELL[int(lcrId - 1)], chBW_NRCELL[int(lcrId - 1)],
                                         nbrOfBlankedPRBsDL_NRCELL[int(lcrId - 1)])
    return maxNumberPRBperSLot


def get_pdcchPowerOffset(row, column_name):
    if (
        row["Beamforming"]
        and row["MIMO4X4Enabled"]
        and row[column_name] is not None  # check if the value is not None
        and int(row[column_name]) < 2
    ):
        # - 3dB
        pdcchPowerOffset = -30
    else:
        pdcchPowerOffset = 0
    return pdcchPowerOffset


def calculate_delta(row, column_name):
    """
    Function to calculate delta with conversion from string to numeric
    :param row
    :param column_name
    :return: int(tx_power) - int(pdcch_power) or None
    """
    pd = pandas_gate.install_and_import_pandas()
    try:
        tx_power_dci = pd.to_numeric(row[column_name], errors='coerce')
        pdcch_txpower_ref = pd.to_numeric(row['pdcch_dci_txpw_ref'], errors='coerce')
        if pd.isna(tx_power_dci) or pd.isna(pdcch_txpower_ref):
            return None
        else:
            return float(tx_power_dci) - float(pdcch_txpower_ref)
    except Exception as e:
        return None


@log_begin_end_func_name
def Verify_SCF_Parameters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB012738 feature should be activated
    # -------------------------------------------------------------------------------------------------
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    pdcch_str = rbi.get_variable_value("${distName_PDCCH}")
    rbi.log_to_console(pdcch_str)
    nrcell_str = rbi.get_variable_value("${distName_NRCELL}")
    nrcell_str_sorted = sorted(nrcell_str)
    actHighSpeedCell_List = rbi.get_variable_value("${actHighSpeedCell_NRCELL}")
    ulDMRSAdditionalPosition_NRCELL_List = rbi.get_variable_value("${ulDMRSAdditionalPosition_NRCELL}")
    rbi.log_to_console(nrcell_str_sorted)
    rbi.log_to_console("actHighSpeedCell_NRCELL_List= %s" % actHighSpeedCell_List)
    rbi.log_to_console("ulDMRSAdditionalPosition_NRCELL_List= %s" % ulDMRSAdditionalPosition_NRCELL_List)
    try:
        expected_scf_list = [{'p_name': 'alSelection', 'value': 'dynamic', 'dist_name': pdcch_str[0]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[0]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[1]},
                             {'p_name': 'actHighSpeedCell', 'value': actHighSpeedCell_List[0],
                              'dist_name': nrcell_str_sorted[0]},
                             {'p_name': 'actHighSpeedCell', 'value': actHighSpeedCell_List[1],
                              'dist_name': nrcell_str_sorted[1]},
                             {'p_name': 'actHighSpeedCell', 'value': actHighSpeedCell_List[2],
                              'dist_name': nrcell_str_sorted[2]},
                             {'p_name': 'ulDMRSAdditionalPosition', 'value': ulDMRSAdditionalPosition_NRCELL_List[0],
                              'dist_name': nrcell_str_sorted[0]},
                             {'p_name': 'ulDMRSAdditionalPosition', 'value': ulDMRSAdditionalPosition_NRCELL_List[1],
                              'dist_name': nrcell_str_sorted[1]},
                             {'p_name': 'ulDMRSAdditionalPosition', 'value': ulDMRSAdditionalPosition_NRCELL_List[2],
                              'dist_name': nrcell_str_sorted[2]}
                             ]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Parameters", e)
    rbi.should_be_true(is_SCF_correct)


@log_begin_end_func_name
def Verify_FDD_10MHz_SCF_Parameters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB012738 feature should be activated
    # -------------------------------------------------------------------------------------------------
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    pdcch_str = rbi.get_variable_value("${distName_PDCCH}")
    rbi.log_to_console(pdcch_str)
    nrcell_str = rbi.get_variable_value("${distName_NRCELL}")
    nrcell_str_sorted = sorted(nrcell_str)
    rbi.log_to_console(nrcell_str_sorted)
    try:
        expected_scf_list = [{'p_name': 'alSelection', 'value': 'dynamic', 'dist_name': pdcch_str[1]},
                             {'p_name': 'alSelection', 'value': 'dynamic', 'dist_name': pdcch_str[2]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[2]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[3]}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("Verify_FDD_SCF_Parameters", e)
    rbi.should_be_true(is_SCF_correct)


@log_begin_end_func_name
def Verify_FDD_20MHz_SCF_Parameters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB012738 feature should be activated
    # -------------------------------------------------------------------------------------------------
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    pdcch_str = rbi.get_variable_value("${distName_PDCCH}")
    rbi.log_to_console(pdcch_str)
    nrcell_str = rbi.get_variable_value("${distName_NRCELL}")
    nrcell_str_sorted = sorted(nrcell_str)
    rbi.log_to_console(nrcell_str_sorted)
    try:
        expected_scf_list = [{'p_name': 'alSelection', 'value': 'dynamic', 'dist_name': pdcch_str[1]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[2]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[3]}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("Verify_FDD_SCF_Parameters", e)
    rbi.should_be_true(is_SCF_correct)


@log_begin_end_func_name
def Verify_DSS_SCF_Parameters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB012738 feature should be activated
    # -------------------------------------------------------------------------------------------------
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    pdcch_str = rbi.get_variable_value("${distName_PDCCH}")
    rbi.log_to_console(pdcch_str)
    nrcell_str = rbi.get_variable_value("${distName_NRCELL}")
    nrcell_str_sorted = sorted(nrcell_str)
    rbi.log_to_console(nrcell_str_sorted)
    try:
        expected_scf_list = [{'p_name': 'alSelection', 'value': 'dynamic', 'dist_name': pdcch_str[0]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[0]},
                             {'p_name': 'actLAForHiReliab', 'value': 'false', 'dist_name': nrcell_str_sorted[1]}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("Verify_DSS_SCF_Parameters", e)
    rbi.should_be_true(is_SCF_correct)


@log_begin_end_func_name
def Verify_SCF_Parameters_for_HR():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB012738 feature should be activated
    # -------------------------------------------------------------------------------------------------
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    pdcch_str = rbi.get_variable_value("${distName_PDCCH}")
    # rbi.log_to_console(pdcch_str)
    nrcell_str = rbi.get_variable_value("${distName_NRCELL}")
    # rbi.log_to_console(nrcell_str)
    try:
        expected_scf_list = [{'p_name': 'alSelection', 'value': 'dynamic', 'dist_name': pdcch_str[0]},
                             {'p_name': 'actLAForHiReliab', 'value': 'true', 'dist_name': nrcell_str[0]},
                             {'p_name': 'actLAForHiReliab', 'value': 'true', 'dist_name': nrcell_str[1]}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("Verify_SCF_Parameters_for_HR", e)
    rbi.should_be_true(is_SCF_correct)


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


def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")


def get_dtx_statistics():
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='rnti/lcrId/physCellId', direction='ul')
        logging.info("get_dtx_statistics(): output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)


def get_directory(path_to_pickle):
    split_path = path_to_pickle.split('/')
    return "/".join(split_path[:-1])


def extract_SlotTypeSelectorBase_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    # SlotType = re.findall(r"(\d*).*Slot: (\d*).*Type: (.*)", syslogextract)
    # SlotType = re.findall(r"(\d*).*Slot=(\d*).*Type= (.*)", syslogextract)
    SlotType = re.findall(r"(\d*).*Slot=(\d*).*Type=(.*)", syslogextract)
    if SlotType:
        timestamp, slot, slot_type = SlotType[0]
        print(f"Timestamp: {timestamp}")
        print(f"Slot: {slot}")
        print(f"Type: {slot_type}")
    else:
        print("No matches found.")
    print(SlotType)
    return SlotType


def extract_ESTATUS5G_NOTOK_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ESTATUS5G_NOTOK.(.*)", syslogextract)
    print(err)
    return err


def extract_GnbOamCellUpdateFailed_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.GnbOamCellUpdateFailed.(.*)", syslogextract)
    print(err)
    return err


def extract_AASYSINFO_FS_OVERLOAD_IND_MSG_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    AASYSINFO_FS_OVERLOAD_IND_MSG
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.AASYSINFO_FS_OVERLOAD_IND_MSG.(.*)", syslogextract)
    print(err)
    return err


def extract_IncorrectCellParameterSettingAI_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    Raising fault IncorrectCellParameterSettingAI
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.Raising fault IncorrectCellParameterSettingAI.(.*)", syslogextract)
    print(err)
    return err


def extract_BearerErrorIndication_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    Raising fault IncorrectCellParameterSettingAI
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.Sending BearerErrorIndication due to MaxRlcRetransmission exceeded.(.*)", syslogextract)
    print(err)
    return err


def extract_ERR_uplane_L2_PS_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ERR/.uplane/L2-PS
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ERR/\.uplane/L2-PS.(.*)", syslogextract)
    print(err)
    return err


def extract_ERR_L2_PS_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ERR/L2-PS
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ERR/L2-PS.(.*)", syslogextract)
    print(err)
    return err


def extract_resource_Allocation_Failed_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ERR/L2-PS
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.resource allocation failed.(.*)", syslogextract)
    print(err)
    return err


def extract_ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL.(.*)", syslogextract)
    print(err)
    return err


def extract_ENDSSDLRESOURCEALLOCATIONFAIL_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ENDSSDLRESOURCEALLOCATIONFAIL
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL.(.*)", syslogextract)
    print(err)
    return err


def extract_L2_PS_CellSetupLogger_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.INF/\.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger\.cpp:.(.*)", syslogextract)
    print(err)
    return err


def extract_INF_L2_PS_CellSetupLogger_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.INF/L2-PS/src/sgnl/psCell/CellSetupLogger\.cpp:.(.*)", syslogextract)
    print(err)
    return err


# ----------------------------------------------------------------------------------------------------- PMC check
@log_begin_end_func_name
def verify_pmc_values(topo_tl='TDD'):
    df = load_pmc_dataframe()
    pmcDf = update_pmc_dataframe(df)
    save_pmc_data_for_analysis(pmcDf, name_result_file='manual_analysis_PMC_values.csv')

    pmcDf_AL_used_PDCCH = update_pmc_dataframe_AL_used_PDCCH(df)
    save_pmc_data_for_analysis(pmcDf_AL_used_PDCCH, name_result_file='manual_analysis_PMC_values_AL_used_PDCCH.csv')

    column_list = ["Sc 1"]
    index_list = ["UL Starv", "DL Starv", "1Sym", "2Sym", "3Sym"]
    pmcDfPrint = pd.DataFrame(pmcDf.iloc[5:10, 3].values, index=index_list, columns=column_list)
    display_df_as_html(pmcDfPrint)

    # Slicing the DataFrame: pmcDf_AL_used_PDCCH.iloc[0:4, 2:7] selects the first 4 rows and columns 2 to 6
    # (since iloc is zero-indexed and the end index is exclusive).
    # Extracting Values: .values converts the selected slice into a NumPy array.
    # Creating a New DataFrame: pd.DataFrame(..., index=index_list, columns=column_list)
    # creates a new DataFrame using the extracted values,
    # with index_list as the index and column_list as the column names.
    column_list = ["Sc 1"]
    index_list = ["Al1 PDCCH", "Al2 PDCCH", "Al4 PDCCH", "Al8 PDCCH", "Al16 PDCCH"]
    pmcAlDfPrint = pd.DataFrame(pmcDf_AL_used_PDCCH.iloc[0:5, 3].values, index=index_list, columns=column_list)
    display_df_as_html(pmcAlDfPrint)

    areResultsCorrect = True
    # try:
    #    areResultsCorrect &= pmcDf.iloc[7, 2] > pmcDf.iloc[7, 3] > pmcDf.iloc[7, 4]
    #    areResultsCorrect &= pmcDf.iloc[7, 4] < pmcDf.iloc[7, 5] < pmcDf.iloc[7, 6]

    #     areResultsCorrect &= pmcDf.iloc[8, 2] < pmcDf.iloc[8, 3] < pmcDf.iloc[8, 4]
    #     areResultsCorrect &= pmcDf.iloc[8, 4] > pmcDf.iloc[8, 5] > pmcDf.iloc[8, 6]
    # 3 symbols not possible for TDD > 10MHz
    #     if topo_tl == "FDD":
    #         areResultsCorrect &= pmcDf.iloc[9, 2] < pmcDf.iloc[9, 3] < pmcDf.iloc[9, 4]
    #         areResultsCorrect &= pmcDf.iloc[9, 4] > pmcDf.iloc[9, 5] > pmcDf.iloc[9, 6]

    #     areResultsCorrect &= pmcDf.iloc[5, 2] < pmcDf.iloc[5, 3] < pmcDf.iloc[5, 4]
    #     areResultsCorrect &= pmcDf.iloc[5, 4] > pmcDf.iloc[5, 5] > pmcDf.iloc[5, 6]

    #     areResultsCorrect &= pmcDf.iloc[6, 2] < pmcDf.iloc[6, 3] < pmcDf.iloc[6, 4]
    #     areResultsCorrect &= pmcDf.iloc[6, 4] > pmcDf.iloc[6, 5] > pmcDf.iloc[6, 6]
    # except Exception as e:
    #     areResultsCorrect = False
    #     log_exception("Verify_CB012738_PMC_values", e)

    # rbi.should_be_true(areResultsCorrect)


def load_pmc_dataframe():
    global pd
    pd = pandas_gate.install_and_import_pandas()

    file_csv = rbi.get_variable_value("${path_to_pmc_csv}")
    # file_csv = '/home/ute/csamson/TRACES/pmCounters.csv'
    df = pd.read_csv(file_csv, sep=";")
    df = df.reset_index(drop=True)

    return df


def update_pmc_dataframe(df):
    """ works only with 1 scenario (file PM files)"""
    # M55335C0x001 Number of slots with Uplink CCE starvation with free PUSCH resources in certain Cell BWP
    # M55335C0x002 Number of slots with Downlink CCE starvation with free PDSCH resources in certain Cell BWP
    # M55335C0x006 Number of Downlink slots with 1 PDCCH symbols configured in the certain Cell BWP
    # M55335C0x007 Number of Downlink slots with 2 PDCCH symbols configured in the certain Cell BWP
    # M55335C0x008 Number of Downlink slots with 3 PDCCH symbols configured in the certain Cell BWP
    # Where x = [2,5,8,11,14,17,20,23,26,29] -> BWP used [0,1,2,3….9]

    # remove unnecessary columns. columns remaining: PI_ID, Managed Object Name, PMC values, Short Description
    col = list(df.columns)
    idx = col.index("Short Description")
    """
    df.iloc[:, [0, 1, idx-2, idx-1, idx]]: This selects columns by their integer location.
    [0, 1]: Selects the first two columns.
    [idx-2, idx-1, idx]: Selects the last 3 columns relative to the index idx.
    BEWARE that the test that used this procedure have 1 scenario so 1 column by scenario (means by counter files)
    => to improve later !!!
    """
    udf = df.iloc[:, [0, 1, idx-2, idx-1, idx]]

    # PMC IDs with x as place holder
    xList = ["M55335C0x001", "M55335C0x002", "M55335C0x006", "M55335C0x007", "M55335C0x008"]

    # create actual PMC list by replacing the x's
    pmcList = []
    x = ["02", "05", "08", "11", "14", "17", "20", "23", "26", "29"]
    for j in xList:
        for k in x:
            pmcList.append(j.replace("0x", k))

    pmcDf = udf.query("PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-1'").copy()
    # convert col 3, 4 to interger
    pmcDf.iloc[:, 2] = pmcDf.iloc[:, 2].astype(int)
    pmcDf.iloc[:, 3] = pmcDf.iloc[:, 3].astype(int)
    # pmcDf.iloc[:, 4] = pmcDf.iloc[:, 4].astype(int)
    # pmcDf.iloc[:, 5] = pmcDf.iloc[:, 5].astype(int)
    # pmcDf.iloc[:, 6] = pmcDf.iloc[:, 6].astype(int)

    return pmcDf


def update_pmc_dataframe_AL_used_PDCCH(df):
    # M55308C1900x ALx used for PDCCH
    # Where x = [1,2,3,4,5] -> AL used [1,2,4,8,16]

    # remove unnecessary columns. columns remaining: PI_ID, Managed Object Name, PMC values, Short Description
    col = list(df.columns)
    idx = col.index("Short Description")
    udf = df.iloc[:, [0, 1, idx-2, idx-1, idx]]

    # PMC IDs with x as place holder
    xList = ["M55308C1900x"]

    # create actual PMC list by replacing the x's
    pmcList = []
    x = ["01", "02", "03", "04", "05"]
    for j in xList:
        for k in x:
            pmcList.append(j.replace("0x", k))

    pmcDf = udf.query("PI_ID in @pmcList and `Managed Object Name` == 'MRBTS-1/NRBTS-1/NRCELL-1'").copy()
    pmcDf.iloc[:, 2] = pmcDf.iloc[:, 2].astype(int)
    pmcDf.iloc[:, 3] = pmcDf.iloc[:, 3].astype(int)
    # pmcDf.iloc[:, 4] = pmcDf.iloc[:, 4].astype(int)
    # pmcDf.iloc[:, 5] = pmcDf.iloc[:, 5].astype(int)
    # pmcDf.iloc[:, 6] = pmcDf.iloc[:, 6].astype(int)

    return pmcDf


def save_pmc_data_for_analysis(df, name_result_file='manual_analysis_PMC_values.csv'):
    path_to_csv = rbi.get_variable_value("${path_to_pmc_csv}")
    # path_to_csv = '/home/ute/csamson'
    csv_file = "%s/" + name_result_file
    df.to_csv(str(csv_file % get_directory(path_to_csv)), sep=';')


def get_last_item(input_string, starting_item):
    starting_string = '{"' + starting_item + '":'
    start_idx = input_string.find(starting_string)

    while start_idx != -1:
        end_idx = find_matching_brace(input_string, start_idx)
        if end_idx == -1:
            break

        json_str = input_string[start_idx:end_idx + 1]
        start_idx = input_string.find(starting_string, end_idx + 1)

    # print(json_str)
    last_item = find_last_occurrence('\"(.*?)\":', json_str)
    return last_item


def find_matching_brace(s, start):
    count = 1
    for i in range(start + 1, len(s)):
        if s[i] == '{':
            count += 1
        elif s[i] == '}':
            count -= 1
            if count == 0:
                return i
    return -1


def find_last_occurrence(pattern, input_string):
    matches = re.findall(pattern, input_string)
    if matches:
        return matches[-1]
    else:
        return None


def is_string_empty_or_none(my_string):
    return my_string is None or len(my_string) == 0


@log_begin_end_func_name
@log('extract_nrCellGrpId_from_syslog...', 'extract_nrCellGrpId_from_syslog finished', logger)
def extract_nrCellGrpId_from_syslog(syslogextract, file='l2ps-cellsetup-syslog', need_return=True):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # pattern = r'\{\"nrCellGrpId\":.*?\"slotAggregationConfig\":.*?\}'
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    matches = re.findall(pattern, syslogextract_flt)
    nrCellGrps = []
    for msg in matches:
        try:
            data = json.loads(msg)
        except Exception as e:
            text = "[extract_nrCellGrpId_from_syslog]"
            text = text + " json.loads(msg) err. Let's just ignore all exceptions, like this one: {}"
            datedConsole(text.format(str(e)))
            continue
        nrCellGrp_per_cell = {'cell': data['nrCellIdentity'],
                              'nrCellGrpId': data['nrCellGrpId']}
        if nrCellGrp_per_cell not in nrCellGrps:
            nrCellGrps.append(nrCellGrp_per_cell)
        filename = file + '-cell-' + str(data['nrCellIdentity']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
        f.close()
    sorted_nrCellGrps = sorted(nrCellGrps, key=lambda p: p['cell'])

    if need_return:
        return sorted_nrCellGrps


@log_begin_end_func_name
@log('extract_cellcsirs_from_syslog_cell...', 'extract_cellcsirs_from_syslog_cell finished', logger)
def extract_cellcsirs_from_syslog_cell(syslogextract, csirsgroups, cellcsirs=None,
                                       file='l2ps-cellsetupresp-syslog-'):
    if cellcsirs is None:
        cellcsirs = []

    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'messageResult'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print('last item: ' + last_item)
    # pattern = r'\{\"messageResult\":\{.*?diagnosticInformation.*?\}'
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    index = 0
    for msg in matches:
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        # print(data)
        msg = "[extract_cellcsirs_from_syslog_cell][CellId=%s] process with nrCellIdentity=%s"
        logger.info(msg % (data['nrCellIdentity'], data['nrCellIdentity']))
        filename = file + '-cellcsirs_per_cell-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        index = index + 1
        # f_cellcsirs_per_cell = open(filename, 'w')
        with open(filename, 'w') as f_cellcsirs_per_cell:
            try:
                cellCsiRsConfig = {'cellId': data['nrCellIdentity'],
                                   'resource_set': data['cellCsiRsTimeDomainAllocation']['resourceSet']}
                try:
                    for i in range(len(cellCsiRsConfig['resource_set'])):
                        cellCsiRsConfig['resource_set'][i].pop('csiImResSlotOffset')
                except (TypeError, IndexError):
                    pass
                json.dump(cellCsiRsConfig, f_cellcsirs_per_cell, indent=4)
                for cellcsirs_item in cellcsirs:
                    if cellcsirs_item['cellId'] == data['nrCellIdentity']:
                        msg = "[extract_cellcsirs_from_syslog_cell] remove nrCellIdentity=%s"
                        logger.info(msg % cellcsirs_item['cellId'])
                        cellcsirs = list(filter(lambda i: i['cellId'] != data['nrCellIdentity'], cellcsirs))
                msg = "[extract_cellcsirs_from_syslog_cell] add nrCellIdentity=%s"
                logger.info(msg % data['nrCellIdentity'])
                cellcsirs.append(cellCsiRsConfig)

            except (TypeError, IndexError):
                pass
        filename = file + '-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
        f.close()
    slot_offsets = cellcsirs
    cellCsiRsConfig_Sorted = sorted(slot_offsets, key=lambda p: p['cellId'])
    msg = "[extract_cellcsirs_from_syslog_cell] =====> cellCsiRsConfig_Sorted=%s"
    logger.info(msg % cellCsiRsConfig_Sorted)
    return cellCsiRsConfig_Sorted


@log_begin_end_func_name
@log('extract_csirsPoolingGroupId_from_syslog...', 'extract_csirsPoolingGroupId_from_syslog finished', logger)
def extract_csirsPoolingGroupId_from_syslog(syslogextract: str, csirsgroups=None,
                                            file='l2ps-cellsetup-syslog'):
    if not isinstance(syslogextract, str) or\
            (isinstance(syslogextract, str) and is_string_empty_or_none(syslogextract)):
        raise TypeError("[extract_csirsPoolingGroupId_from_syslog] syslogextract should be a string.")
    if csirsgroups is not None and not isinstance(csirsgroups, list):
        raise TypeError("[extract_csirsPoolingGroupId_from_syslog] csirsgroups should be a list or None.")
    if csirsgroups is None:
        datedConsole(f"[extract_csirsPoolingGroupId_from_syslog] csirsgroups is None. Create Empty List")
        csirsgroups = []
    print(csirsgroups)
    print(type(csirsgroups))
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    # syslogextract_flt2 = re.sub('^(.*CellSetupReq_t: )', "", syslogextract_flt)
    # msg_console = '=====> syslogextract_flt2'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt2))
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    try:
        pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
        # pattern = r'\{\"nrCellGrpId\":.*?\"actDlSchLowBufferOpt\":.*?\}'
    except (TypeError, IndexError):
        pattern = r'\{\"nrCellGrpId\":.*?\"actDlSchLowBufferOpt\":.*?\}'
        pass
    matches = re.findall(pattern, syslogextract_flt)
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        try:
            data = json.loads(msg)
        except Exception as e:
            text = "[extract_csirsPoolingGroupId_from_syslog]"
            text = text + " json.loads(msg) err. Let's just ignore all exceptions, like this one: {}"
            datedConsole(text.format(str(e)))
            continue
        csirsgroup_per_cell = {'cell': data['nrCellIdentity'],
                               'csirsPoolingGroupId': data['bbPoolingInfoCell']['csirsPoolingGroupId'],
                               'lcrId': data['lcrId']}
        msg = "[extract_csirsPoolingGroupId_from_syslog][CellId=%s] =====> msg_begin_loop"
        logger.info(msg % data['nrCellIdentity'])
        cell_found = False
        for csirsgroup in csirsgroups:
            msg = "[extract_csirsPoolingGroupId_from_syslog] =====> csirsgroup_begin_loop with %s"
            logger.info(msg % csirsgroup)
            # current_id = csirsgroup['cell']
            current_id = csirsgroup.get('cell', None)  # improve robustness
            if current_id == data['nrCellIdentity']:
                csirsgroup['csirsPoolingGroupId'] = data['bbPoolingInfoCell']['csirsPoolingGroupId']
                msg = "[extract_csirsPoolingGroupId_from_syslog] =====> update csirsgroup with %s"
                logger.info(msg % csirsgroup['csirsPoolingGroupId'])
                cell_found = True
        if not cell_found:
            if csirsgroup_per_cell not in csirsgroups:
                msg = "[extract_csirsPoolingGroupId_from_syslog] "
                msg = msg + "=====> append in csirsgroup because csirsgroup_per_cell not present (with %s)"
                logger.info(msg % csirsgroup_per_cell)
                csirsgroups.append(csirsgroup_per_cell)
        if not csirsgroups:
            if csirsgroup_per_cell not in csirsgroups:
                msg = "[extract_csirsPoolingGroupId_from_syslog] "
                msg = msg + "=====> First append in csirsgroup because csirsgroup_per_cell not present (with %s)"
                logger.info(msg % csirsgroup_per_cell)
                csirsgroups.append(csirsgroup_per_cell)
        filename = file + '-cell-' + str(data['nrCellIdentity']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
        f.close()
    msg = "=====> csirsgroups is %s"
    logger.info(msg % csirsgroups)
    sorted_csirs = sorted(csirsgroups, key=lambda p: p['cell'])
    return sorted_csirs


@log_begin_end_func_name
@log('extract_csirsPoolingGroupId_from_syslog_v1...', 'extract_csirsPoolingGroupId_from_syslog_v1 finished', logger)
def extract_csirsPoolingGroupId_from_syslog_v1(syslogextract, file='l2ps-cellsetup-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    # syslogextract_flt2 = re.sub('^(.*CellSetupReq_t: )', "", syslogextract_flt)
    # msg_console = '=====> syslogextract_flt2'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt2))
    # pattern = r'\{\"nrCellGrpId\":.*?\"slotAggregationConfig\":.*?\}'
    pattern = r'\{\"nrCellGrpId\":.*?\"actDlSchLowBufferOpt\":.*?\}'

    matches = re.findall(pattern, syslogextract_flt)
    csirsgroups = []
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        data = json.loads(msg)
        csirsgroup_per_cell = {'cell': data['nrCellIdentity'],
                               'csirsPoolingGroupId': data['bbPoolingInfoCell']['csirsPoolingGroupId']}
        if csirsgroup_per_cell not in csirsgroups:
            csirsgroups.append(csirsgroup_per_cell)
        filename = file + '-cell-' + str(data['nrCellIdentity']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
        f.close()
    sorted_csirs = sorted(csirsgroups, key=lambda p: p['cell'])
    return sorted_csirs


@log_begin_end_func_name
@log('extract_uecsirs_from_syslog...', 'extract_uecsirs_from_syslog finished', logger)
def extract_uecsirs_from_syslog(syslogextract, csirsgroups,
                                uecsirs=None, file='l2ps-cellsetupresp-syslog', debug=False):
    if uecsirs is None:
        uecsirs = []
    if type(debug) is bool:
        _debug = debug
    else:
        if debug == 'True':
            _debug = True
        else:
            _debug = False
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    pattern = r'\{\"messageResult\":\{.*?diagnosticInformation.*?\}'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    index = 0
    index_uecsirs = 0
    for msg in matches:
        print('data')
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        print(data)
        if _debug:
            msg_console = '=====> msg_begin_loop'
            datedConsole(getHeaderLine(msg_console, data['nrCellIdentity']))
        msg = "[extract_uecsirs_from_syslog][CellId=%s] =====> msg_begin_loop"
        logger.info(msg % data['nrCellIdentity'])
        filename = file + '-uecsirs_per_cell-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        index = index + 1
        csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
        with open(filename, 'w') as f_uecsirs_per_cell:
            try:
                uecsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
                                    'uecsirs': data['availablePucchAndCsiRsResources']}
            except (TypeError, IndexError):
                continue
            json.dump(uecsirs_per_cell, f_uecsirs_per_cell, indent=4)
        # 21/05/2025 : version before refactoring
        # f_uecsirs_per_cell = open(filename, 'w')
        # csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
        # try:
        #     uecsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
        #                         'uecsirs': data['availablePucchAndCsiRsResources']}
        # except (TypeError, IndexError):
        #     continue
        # json.dump(uecsirs_per_cell, f_uecsirs_per_cell, indent=4)
        # End Of version before the refactoring
        if _debug:
            msg_console = '=====> extract_uecsirs_from_syslog : csirsgroup'
            datedConsole(getHeaderLine(msg_console, csirsgroup[0]))
            msg_console = '=====> extract_uecsirs_from_syslog begin loop : uecsirs'
            datedConsole(getHeaderLine(msg_console, uecsirs))
        msg = "[extract_uecsirs_from_syslog] =====> csirsgroup=%s"
        logger.info(msg % csirsgroup[0])
        msg = "[extract_uecsirs_from_syslog] =====> begin loop : uecsirs=%s"
        logger.info(msg % uecsirs)
        # if csirsPoolingGroupId already present in cellcsirs => remove it before add new csirsPoolingGroupId
        for uecsirs_item in uecsirs:
            if _debug:
                msg_console = '=====> extract_uecsirs_from_syslog : cellcsirs_elt_loop'
                datedConsole(getHeaderLine(msg_console, uecsirs_item))
                msg_console = '=====> extract_uecsirs_from_syslog : len uecsirs'
                datedConsole(getHeaderLine(msg_console, len(uecsirs)))
            msg = "[extract_uecsirs_from_syslog] =====> uecsirs_elt_loop=%s"
            logger.info(msg % uecsirs_item)
            msg = "[extract_uecsirs_from_syslog] =====> len uecsirs=%s"
            logger.info(msg % len(uecsirs))
            if uecsirs_item['csirsPoolingGroupId'] == csirsgroup[0]:
                if _debug:
                    msg_console = '=====> extract_uecsirs_from_syslog: remove csirsgroup'
                    datedConsole(getHeaderLine(msg_console, uecsirs_item['csirsPoolingGroupId']))
                msg = "[extract_uecsirs_from_syslog] remove csirsgroup=%s"
                logger.info(msg % uecsirs_item['csirsPoolingGroupId'])
                uecsirs = list(filter(lambda i: i['csirsPoolingGroupId'] != csirsgroup[0], uecsirs))
            index_uecsirs = index_uecsirs + 1
        if uecsirs_per_cell not in uecsirs:
            if _debug:
                msg_console = '=====> extract_uecsirs_from_syslog: add csirsgroup in uecsirs'
                datedConsole(getHeaderLine(msg_console, uecsirs_per_cell))
            msg = "[extract_uecsirs_from_syslog] =====> add csirsgroup=%s in uecsirs"
            logger.info(msg % uecsirs_per_cell)
            uecsirs.append(uecsirs_per_cell)
    slot_offsets = uecsirs
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    msg = "[extract_uecsirs_from_syslog] =====> sorted_slots=%s"
    logger.info(msg % sorted_slots)
    return sorted_slots


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    AlTh1 = 10.1
    AlTh2 = 6.9
    AlTh4 = 3.6
    AlTh8 = 1.0

    # file_csv = '/home/ute/csamson/TRACES/pmCounters.csv'
    # verify_pmc_values()

    # for all tc except tc with paging
    # file_pkl = '/home/ute/csamson/TRACES/paging/run6/ttitrace_streaming.pkl'
    # Verify_AL_selection_with_changing_CQI_values(file_pkl, ue_rnti=20084)
    # Verify_AL_selection_with_changing_CQI_values(file_pkl)
    # for test with paging
    file_pkl = '/home/ute/csamson/TRACES/paging/run9/ttitrace_streaming_dlFdSchedData.pkl'
    Verify_AL_selection_with_changing_CQI_values(file_pkl, 'dl')

    # file_csv = '/home/ute/csamson/TRACES/msg_DlData_PdcchSendReq_pcap.csv'
    # file_csv = '/home/ute/csamson/TRACES/msg_DlData_PdcchSendReq_pcap_REF.csv'
    # file_csv = '/home/ute/csamson/TRACES/msg_DlData_PdcchSendReq_pcap_TEST.csv'

    # make_beautifully_csv_file(file_csv, NRB=106, MIMO4X4Enabled=False, actBeamforming=False)
