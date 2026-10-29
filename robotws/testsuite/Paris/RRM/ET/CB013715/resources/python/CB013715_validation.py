# ====================================================================================================
# This is a Python File, which helps to implement the Private Robot Keywords used for CB007491-G
# and -H Subfeature
# ----------------------------------------------------------------------------------------------------

import logging
import os
import plotly.graph_objects as go
from plotly.subplots import make_subplots
# import numpy
import math
import cmath

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf
from taf.ul.ettf.logger import custom_logger, log

# ET or Feature Specific Libraries:
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate
# from testsuite.Paris.RRM.ET.resources.DSS.TARF.python.tti_analysis.dtx import get_dtx_stats
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tools import log_begin_end_func_name

import CB013715_tools
import SlotSfn_PDSCH
import SlotSfn_PUSCH
import SlotSfn_pucchResources
import SlotSfn_CSIRS

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()
logger = custom_logger(name='CB013715_validation', filename='test_execution_CB013715_Overlap_test.log')


# ====================================================================================================
#   Keywords
# ====================================================================================================
def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")


def get_directory(path_to_pickle):
    split_path = path_to_pickle.split('/')
    return "/".join(split_path[:-1])


def return_result(result_test=False):
    if result_test:
        return "PASS"
    else:
        return "FAIL"


def load_dataframe(file, event='ulPucchReceiveReqData'):
    global pd
    pd = pandas_gate.install_and_import_pandas()

    if event == 'ulPucchReceiveReqData':
        if file == "csv":
            path_to_csv = rbi.get_variable_value("${path_to_ttitrace_ulPucchReceiveReqData_csv}")
            df = pd.read_csv(path_to_csv, sep=';')
        else:
            path_to_pickle = rbi.get_variable_value("${path_to_ttitrace_ulPucchReceiveReqData_pkl}")
            df = pd.read_pickle(path_to_pickle)
    elif event == 'ulPuschReceiveRespPsData':
        if file == "csv":
            path_to_csv = rbi.get_variable_value("${path_to_ttitrace_ulPuschReceiveRespPsData_csv}")
            df = pd.read_csv(path_to_csv, sep=';')
        else:
            path_to_pickle = rbi.get_variable_value("${path_to_ttitrace_ulPuschReceiveRespPsData_pkl}")
            df = pd.read_pickle(path_to_pickle)
    else:
        if file == "csv":
            path_to_csv = rbi.get_variable_value("${path_to_ttitrace_ulFdSchedData_csv}")
            df = pd.read_csv(path_to_csv, sep=';')
        else:
            path_to_pickle = rbi.get_variable_value("${path_to_ttitrace_ulFdSchedData_pkl}")
            df = pd.read_pickle(path_to_pickle)

    df = df.reset_index(drop=True)

    return df


def prepare_dataframe_for_pucch_cfo_analysis(df, physCellId=50):
    df = df[df['rnti'] != '65535']
    df = df[df['physCellId'] == physCellId]
    df = df[["timeStamp",
             "sfn",
             "slot",
             "rnti",
             "physCellId",
             "ulPucchReceiveReqData.subcellId",
             "ulPucchReceiveReqData.longTermCfoMetric.Re",
             "ulPucchReceiveReqData.longTermCfoMetric.Im",
             "ulPucchReceiveReqData.longTermCfoMetricOfBeam"]]

    df = df.rename(columns={
        "ulPucchReceiveReqData.subcellId": "subcellId",
        "ulPucchReceiveReqData.longTermCfoMetric.Re": "shortTermCfoMetric_Q",
        "ulPucchReceiveReqData.longTermCfoMetric.Im": "shortTermCfoMetric_I",
        "ulPucchReceiveReqData.longTermCfoMetricOfBeam": "ul_longTermCfoMetricOfBeam"})

    # SCS = 30KHz = 30000Hz
    # FO(Hz) = 3000 X ((angle(cfo) / 2pi) * (2048 / '2048+144))* 1/4)
    # FO (Hz) = 3000 X ((angle(cfo) * 2048) / (2pi * 4 * (2048+144))
    df['atan(Q/I)'] = numpy.arctan(df['shortTermCfoMetric_Q']/df['shortTermCfoMetric_I'])
    # df['atan(I/Q)'] = numpy.arctan(df['shortTermCfoMetric_I']/df['shortTermCfoMetric_Q'])
    df['atan2(Q/I)'] = numpy.arctan2(df['shortTermCfoMetric_Q'], df['shortTermCfoMetric_I'])
    df['factor'] = (4096 / (2 * math.pi * (288 + 4096) * 4)) * 30000
    df['CFO_Hz_1'] = (df['atan2(Q/I)'] / (2 * math.pi)) * (4096 / ((288 + 4096) * 4)) * 30000
    df['pucch_CFO_Hz'] = df['atan2(Q/I)'] * df['factor']
    df['pucch_Phase'] = df.apply(lambda row: get_phase(row), axis=1)
    df['pucch_CFO_Hz_2'] = df.apply(lambda row: get_cfo_hz(row), axis=1)

    # need to add         "dlFdSchedData.scheduledBearers": "dlSchedBrs",  above
    # df = df[df.index > get_traffic_start_index(df)]

    return df


def get_cfo_hz(row):
    CarrierSp_mapping = {
        '15KHz': 15_000,
        '30KHz': 30_000,
        '120KHz': 120_000,
    }
    CarrierSp = '30KHz'
    c = complex(float(row['shortTermCfoMetric_Q']), float(row['shortTermCfoMetric_I']))
    if c != 0:
        cfo_hz = cmath.phase(c) / (2 * cmath.pi * 4 * (4096 + 288) / 4096) * CarrierSp_mapping[CarrierSp]
    else:
        cfo_hz = float(0)
    return cfo_hz


def get_phase(row):
    c = complex(float(row['shortTermCfoMetric_Q']), float(row['shortTermCfoMetric_I']))
    if c != 0:
        phase = cmath.phase(c)
    else:
        phase = float(0)
    return phase


def prepare_dataframe_for_pusch_cfo_analysis(df, physCellId=50):
    CarrierSp_mapping = {
        '15KHz': 15_000,
        '30KHz': 30_000,
        '120KHz': 120_000,
    }
    CarrierSp = '30KHz'
    df = df[df['rnti'] != '65535']
    df = df[df['physCellId'] == physCellId]
    df = df[["timeStamp",
             "sfn",
             "slot",
             "rnti",
             "physCellId",
             "ulPuschReceiveRespPsData.shortTermCfoMetric_I",
             "ulPuschReceiveRespPsData.shortTermCfoMetric_Q"]]

    df = df.rename(columns={
        "ulPuschReceiveRespPsData.shortTermCfoMetric_I": "shortTermCfoMetric_I",
        "ulPuschReceiveRespPsData.shortTermCfoMetric_Q": "shortTermCfoMetric_Q"})

    # SCS = 30KHz = 30000Hz
    # FO(Hz) = 30000 X ((angle(cfo) / 2pi) * (2048 / '2048+144))* 1/4)
    # FO(Hz) = 30000 X ((angle(cfo) * 4096) / (2pi * 4 * (4096+288))
    # FO(Hz) = 30000 X ((angle(cfo) * 2048) / (2pi * 4 * (2048+144))
    factor = (4096 * 30000) / (2 * math.pi * 4 * (288 * 4096))
    df['atan(Q/I)'] = numpy.arctan(df['shortTermCfoMetric_Q']/df['shortTermCfoMetric_I'])
    df['CFO_Hz_1'] = df['atan(Q/I)'] * factor
    df['atan(I/Q)'] = numpy.arctan(df['shortTermCfoMetric_I']/df['shortTermCfoMetric_Q'])
    df['atan2(Q/I)'] = numpy.arctan2(df['shortTermCfoMetric_Q'], df['shortTermCfoMetric_I'])
    df['factor'] = (4096 / (2 * math.pi * (288 + 4096) * 4)) * 30000
    df['CFO_Hz_1'] = (df['atan2(Q/I)'] / (2 * math.pi)) * (4096 / ((288 + 4096) * 4)) * 30000
    df['pusch_CFO_Hz'] = df['atan2(Q/I)'] * df['factor']
    df['pusch_Phase'] = df.apply(lambda row: get_phase(row), axis=1)
    df['pusch_CFO_Hz_2'] = df.apply(lambda row: get_cfo_hz(row), axis=1)

    # need to add         "dlFdSchedData.scheduledBearers": "dlSchedBrs",  above
    # df = df[df.index > get_traffic_start_index(df)]

    return df


def prepare_dataframe_for_pusch_ulFdSchedData_cfo_analysis(df, physCellId=50):
    CarrierSp_mapping = {
        '15KHz': 15_000,
        '30KHz': 30_000,
        '120KHz': 120_000,
    }
    CarrierSp = '30KHz'
    df = df[df['rnti'] != '65535']
    df = df[df['physCellId'] == physCellId]
    df = df[["timeStamp",
             "sfn",
             "slot",
             "rnti",
             "physCellId",
             "ulFdSchedData.longTermCfoMetric.Re",
             "ulFdSchedData.longTermCfoMetric.Im"]]

    df = df.rename(columns={
        "ulFdSchedData.longTermCfoMetric.Re": "shortTermCfoMetric_Q",
        "ulFdSchedData.longTermCfoMetric.Im": "shortTermCfoMetric_I"})

    # SCS = 30KHz = 30000Hz
    # FO(Hz) = 30000 X ((angle(cfo) / 2pi) * (2048 / '2048+144))* 1/4)
    # FO(Hz) = 30000 X ((angle(cfo) * 4096) / (2pi * 4 * (4096+288))
    # FO(Hz) = 30000 X ((angle(cfo) * 2048) / (2pi * 4 * (2048+144))
    factor = (4096 * 30000) / (2 * math.pi * 4 * (288 * 4096))
    df['atan(Q/I)'] = numpy.arctan(df['shortTermCfoMetric_Q']/df['shortTermCfoMetric_I'])
    df['CFO_Hz_1'] = df['atan(Q/I)'] * factor
    df['atan(I/Q)'] = numpy.arctan(df['shortTermCfoMetric_I']/df['shortTermCfoMetric_Q'])
    df['atan2(Q/I)'] = numpy.arctan2(df['shortTermCfoMetric_Q'], df['shortTermCfoMetric_I'])
    df['factor'] = (4096 / (2 * math.pi * (288 + 4096) * 4)) * 30000
    df['CFO_Hz_1'] = (df['atan2(Q/I)'] / (2 * math.pi)) * (4096 / ((288 + 4096) * 4)) * 30000
    df['pusch_CFO_Hz'] = df['atan2(Q/I)'] * df['factor']
    df['pusch_Phase'] = df.apply(lambda row: get_phase(row), axis=1)
    df['pusch_CFO_Hz_2'] = df.apply(lambda row: get_cfo_hz(row), axis=1)

    # need to add         "dlFdSchedData.scheduledBearers": "dlSchedBrs",  above
    # df = df[df.index > get_traffic_start_index(df)]

    return df


def save_data_for_analysis(udf, physCellId=50, channel='pucch', event='ulFdSchedData'):
    path_to_pickle = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    file = "%s/manual_analysis_CFO_%s_physCellId_%s_%s.csv"
    udf.to_csv(str(file % (get_directory(path_to_pickle), channel, physCellId, event)), sep=';')

    if channel == 'pusch':
        plot_data_cfo(udf, physCellId, channel, event, get_directory(path_to_pickle))
    if channel == 'pucch':
        plot_data_cfo(udf, physCellId, channel, event, get_directory(path_to_pickle))

    # for link in ["dl", "ul"]:
    #     plot_data(udf, link, get_directory(path_to_pickle))


@log_begin_end_func_name
def Verify_CFO():
    # pd = pandas_gate.install_and_import_pandas()
    df = load_dataframe("csv")
    physCellId = 50
    udf = prepare_dataframe_for_pucch_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pucch', event='ulPucchReceiveReqData')

    physCellId = 51
    udf = prepare_dataframe_for_pucch_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pucch', event='ulPucchReceiveReqData')

    physCellId = 52
    udf = prepare_dataframe_for_pucch_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pucch', event='ulPucchReceiveReqData')

    df = load_dataframe("csv", event='ulPuschReceiveRespPsData')
    physCellId = 50
    udf = prepare_dataframe_for_pusch_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pusch', event='ulPuschReceiveRespPsData')

    physCellId = 51
    udf = prepare_dataframe_for_pusch_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pusch', event='ulPuschReceiveRespPsData')

    physCellId = 52
    udf = prepare_dataframe_for_pusch_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pusch', event='ulPuschReceiveRespPsData')

    df = load_dataframe("csv", event='ulFdSchedData')
    physCellId = 50
    udf = prepare_dataframe_for_pusch_ulFdSchedData_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pusch', event='ulFdSchedData')

    df = load_dataframe("csv", event='ulFdSchedData')
    physCellId = 51
    udf = prepare_dataframe_for_pusch_ulFdSchedData_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pusch', event='ulFdSchedData')

    df = load_dataframe("csv", event='ulFdSchedData')
    physCellId = 52
    udf = prepare_dataframe_for_pusch_ulFdSchedData_cfo_analysis(df, physCellId=physCellId)
    save_data_for_analysis(udf, physCellId=physCellId, channel='pusch', event='ulFdSchedData')


def plot_data_cfo(udf, physCellId, channel, event, path):
    # this gets rid of all lines where CFO has no value
    dfNoNull = udf[pd.notnull(udf[channel+"_CFO_Hz_2"])]

    # fig = go.Figure()
    fig = make_subplots(rows=1, cols=2)

    fig.add_trace(go.Scatter(
        x=dfNoNull.timeStamp, y=dfNoNull[channel+'_CFO_Hz_2'],
        mode='markers', name=channel+" CFO Hz ", marker=dict(size=2)
    ), row=1, col=1)
    fig.add_trace(go.Scatter(
        x=dfNoNull.timeStamp, y=dfNoNull[channel+'_Phase'],
        mode='lines', name=channel+" Phase ", marker=dict(size=2)
    ), row=1, col=2)

    cfoThs = [1734.0, -1734.0]
    for i in cfoThs:
        fig.add_hline(y=i, line_dash="dot", line_width=0.5, line_color="black",
                      annotation_text="cfoTh_"+str(i),
                      annotation_position="bottom right", row=1, col=1)
    title = "plot CFO_Hz_"+channel+"_"+event+"_physCellId_"+str(physCellId)
    fig.update_layout(
        title=title, xaxis_title="Time", yaxis_title="_CFO_Hz",
        yaxis2=dict(
            overlaying="y",
            side="left"
        )
    )
    fig.update_layout(xaxis2_title="Time", yaxis=dict(title_text='CFO_Hz'), yaxis2=dict(title_text='Phase'))
    file_name = "/" + title.replace(" ", "_") + ".html"
    fig.write_html(path+file_name, auto_open=False)


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


def get_traffic_start_index(df):
    df_brs_noNull = df[pd.notnull(df.dlSchedBrs)].copy()
    # replace list of dictionaries in dlSchedBrs column with just its bearer 1 scheduledBytes value
    df_brs_noNull['dlSchedBrs'] = df_brs_noNull['dlSchedBrs'].\
        apply(lambda list_of_dicts: get_scheduledBytes_from_bearer1(list_of_dicts))

    return df_brs_noNull[df_brs_noNull.dlSchedBrs > 0].first_valid_index()


def get_scheduledBytes_from_bearer4(list_of_dicts):
    for i in list_of_dicts:
        if i['lcId'] == 4:
            return i['scheduledBytesPerBearer']


def get_scheduledBytes_from_bearer1(list_of_dicts):
    for i in list_of_dicts:
        if i['lcId'] == 1:
            return i['scheduledBytesPerBearer']


@log_begin_end_func_name
def verify_TTITraces_for_DL_PRBBLANKING_CELL1(bwpPrb=52, first_prb_non_blanking_cell1=0,
                                              last_prb_non_blanking_cell1=273,
                                              nbrOfBlankedPRBsHighEdgeDL=0,
                                              nbrOfBlankedPRBsLowEdgeDL=0):
    """
    verify DL PRB Blanking constraint for Full BWP - DO NOT USED for dedicated BWP (PS-BWP)
    :param first_prb_non_blanking_cell1:
    :param last_prb_non_blanking_cell1:
    :return:
    """
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    # path_to_ttitrace_pkl = "/home/ute/csamson/TRACES/ttitrace_streaming.pkl"
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_dlfdsched_pkl}")
    list_of_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    if not list_of_subcells or list_of_subcells is None:
        list_of_subcells = [0, 2]
    print("verify_TTITraces_for_DL_PRBBLANKING_CELL1 : list_of_subcells=" + str(list_of_subcells)[1:-1])
    list_of_non_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    if not list_of_non_subcells or list_of_non_subcells is None:
        list_of_non_subcells = [1]
    print("verify_TTITraces_for_DL_PRBBLANKING_CELL1 : list_of_non_subcells=" + str(list_of_non_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p0 =\
            run_prb_blanking_analysis_dl(path_to_ttitrace_pkl, bwpPrb=bwpPrb,
                                         list_of_subcells=list_of_subcells,
                                         list_of_non_subcells=list_of_non_subcells,
                                         exclude_samples_for_analysis=1000,
                                         first_prb_non_blanking=first_prb_non_blanking_cell1,
                                         last_prb_non_blanking=last_prb_non_blanking_cell1,
                                         nbrOfBlankedPRBsHighEdgeDL=nbrOfBlankedPRBsHighEdgeDL,
                                         nbrOfBlankedPRBsLowEdgeDL=nbrOfBlankedPRBsLowEdgeDL,
                                         name='dl_dataframe_for_manual_analysis_prblanking_cell1')
        msg = "verify_TTITraces_for_DL_PRBBLANKING_CELL1: is_TTITrace_correct_p0 = %s"
        logging.info(msg % (is_TTITrace_correct_p0))
        msg = 'verify_TTITraces_for_DL_PRBBLANKING_CELL1: is_TTITrace_correct_p0'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p0))
    except Exception as e:
        logException("verify_TTITraces_for_DL_PRBBLANKING_CELL1", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p0))
    rbi.should_be_true(is_TTITrace_correct_p0)


@log_begin_end_func_name
def verify_TTITraces_for_DL_PRBBLANKING_CELL2(bwpPrb=52, first_prb_non_blanking_cell2=0,
                                              last_prb_non_blanking_cell2=273,
                                              nbrOfBlankedPRBsHighEdgeDL=0,
                                              nbrOfBlankedPRBsLowEdgeDL=0):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_dlfdsched_pkl}")
    list_of_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    if not list_of_subcells or list_of_subcells is None:
        list_of_subcells = [1]
    print("verify_TTITraces_for_DL_PRBBLANKING_CELL2 : list_of_subcells=" + str(list_of_subcells)[1:-1])
    list_of_non_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    if not list_of_non_subcells or list_of_non_subcells is None:
        list_of_non_subcells = [0, 2]
    print("verify_TTITraces_for_DL_PRBBLANKING_CELL2 : list_of_non_subcells=" + str(list_of_non_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p1 = \
            run_prb_blanking_analysis_dl(path_to_ttitrace_pkl, bwpPrb=bwpPrb,
                                         list_of_subcells=list_of_subcells,
                                         list_of_non_subcells=list_of_non_subcells,
                                         exclude_samples_for_analysis=1000,
                                         first_prb_non_blanking=first_prb_non_blanking_cell2,
                                         last_prb_non_blanking=last_prb_non_blanking_cell2,
                                         nbrOfBlankedPRBsHighEdgeDL=nbrOfBlankedPRBsHighEdgeDL,
                                         nbrOfBlankedPRBsLowEdgeDL=nbrOfBlankedPRBsLowEdgeDL,
                                         name='dl_dataframe_for_manual_analysis_prblanking_cell2')
        msg = "verify_TTITraces_for_DL_PRBBLANKING_CELL2: is_TTITrace_correct_p1 = %s"
        logging.info(msg % (is_TTITrace_correct_p1))
        msg = 'verify_TTITraces_for_DL_PRBBLANKING CELL2: is_TTITrace_correct_p1'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p1))
    except Exception as e:
        logException("verify_TTITraces_for_DL_PRBBLANKING_CELL2", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p1))
    rbi.should_be_true(is_TTITrace_correct_p1)


@log_begin_end_func_name
def verify_TTITraces_for_UL_PRBBLANKING_CELL1(bwpPrb=52, first_prb_non_blanking_cell1=0,
                                              last_prb_non_blanking_cell1=52,
                                              nbrOfBlankedPRBsHighEdgeUL=0,
                                              nbrOfBlankedPRBsLowEdgeUL=0):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_ulfdsched_pkl}")
    list_of_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    if not list_of_subcells or list_of_subcells is None:
        list_of_subcells = [0, 2]
    print("verify_TTITraces_for_UL_PRBBLANKING_CELL1 : list_of_subcells=" + str(list_of_subcells)[1:-1])
    list_of_non_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    if not list_of_non_subcells or list_of_non_subcells is None:
        list_of_non_subcells = [1]
    list_of_non_subcells.append(255)
    print("verify_TTITraces_for_UL_PRBBLANKING_CELL1 : list_of_non_subcells=" + str(list_of_non_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p0 =\
            run_prb_blanking_analysis_ul(path_to_ttitrace_pkl, bwpPrb=bwpPrb,
                                         list_of_subcells=list_of_subcells,
                                         list_of_non_subcells=list_of_non_subcells,
                                         exclude_samples_for_analysis=1000,
                                         first_prb_non_blanking=first_prb_non_blanking_cell1,
                                         last_prb_non_blanking=last_prb_non_blanking_cell1,
                                         nbrOfBlankedPRBsHighEdgeUL=nbrOfBlankedPRBsHighEdgeUL,
                                         nbrOfBlankedPRBsLowEdgeUL=nbrOfBlankedPRBsLowEdgeUL,
                                         name='ul_dataframe_for_manual_analysis_prblanking_cell1')
        msg = "verify_TTITraces_for_UL_PRBBLANKING_CELL1: is_TTITrace_correct_p0 = %s"
        logging.info(msg % (is_TTITrace_correct_p0))
        msg = 'verify_TTITraces_for_UL_PRBBLANKING CELL1: is_TTITrace_correct_p0'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p0))
    except Exception as e:
        logException("verify_TTITraces_for_UL_PRBBLANKING_CELL1", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p0))
    rbi.should_be_true(is_TTITrace_correct_p0)


@log_begin_end_func_name
def verify_TTITraces_for_UL_PRBBLANKING_CELL2(bwpPrb=52, first_prb_non_blanking_cell2=0,
                                              last_prb_non_blanking_cell2=273,
                                              nbrOfBlankedPRBsHighEdgeUL=0,
                                              nbrOfBlankedPRBsLowEdgeUL=0):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_ulfdsched_pkl}")
    list_of_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    if not list_of_subcells or list_of_subcells is None:
        list_of_subcells = [1]
    list_of_subcells.append(255)
    print("verify_TTITraces_for_UL_PRBBLANKING_CELL2 : list_of_subcells=" + str(list_of_subcells)[1:-1])
    list_of_non_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    if not list_of_non_subcells or list_of_non_subcells is None:
        list_of_non_subcells = [0, 2]
    print("verify_TTITraces_for_UL_PRBBLANKING_CELL2 : list_of_non_subcells=" + str(list_of_non_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p1 = \
            run_prb_blanking_analysis_ul(path_to_ttitrace_pkl, bwpPrb=bwpPrb,
                                         list_of_subcells=list_of_non_subcells,
                                         list_of_non_subcells=list_of_subcells,
                                         exclude_samples_for_analysis=1000,
                                         first_prb_non_blanking=first_prb_non_blanking_cell2,
                                         last_prb_non_blanking=last_prb_non_blanking_cell2,
                                         nbrOfBlankedPRBsHighEdgeUL=nbrOfBlankedPRBsHighEdgeUL,
                                         nbrOfBlankedPRBsLowEdgeUL=nbrOfBlankedPRBsLowEdgeUL,
                                         name='ul_dataframe_for_manual_analysis_prblanking_cell2')
        msg = "verify_TTITraces_for_UL_PRBBLANKING_CELL2: is_TTITrace_correct_p1 = %s"
        logging.info(msg % (is_TTITrace_correct_p1))
        msg = 'verify_TTITraces_for_UL_PRBBLANKING CELL2: is_TTITrace_correct_p1'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p1))
    except Exception as e:
        logException("verify_TTITraces_for_UL_PRBBLANKING_CELL2", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p1))
    rbi.should_be_true(is_TTITrace_correct_p1)


@log_begin_end_func_name
def filter_dataframe_prbblanking_ul(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulFdSchedData.subcellId',
                               'ulFdSchedData.startPrb', 'ulFdSchedData.numOfPrb', 'ulFdSchedData.cellBwpId',
                               'lcrId']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def prepare_df_to_compute_ul_prbblanking_info(df, list_of_subcells, list_of_non_subcells):
    for non_pooled_subcell in list_of_non_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.startPrb', 'ulFdSchedData.numOfPrb', 'ulFdSchedData.cellBwpId'],
                                 inplace=True)
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
@log('UL prb overlap analysis TtiTraces...', 'UL prb overlap analysis TtiTraces finished', logger)
def run_prb_blanking_analysis_ul(path_to_pickle,  bwpPrb=52,
                                 list_of_subcells=[0, 2],
                                 list_of_non_subcells=[1],
                                 exclude_samples_for_analysis=1000,
                                 first_prb_non_blanking=0,
                                 last_prb_non_blanking=273,
                                 nbrOfBlankedPRBsHighEdgeUL=0,
                                 nbrOfBlankedPRBsLowEdgeUL=0,
                                 name='ul_dataframe_for_manual_analysis_prblanking_cell1'):
    """Check PUSCH TtiTraces PRB Constraints"""
    # rbgSize = 16
    prbMax = bwpPrb
    rbgSize = CB013715_tools.return_only_rbgsize_pdsch(chBW=prbMax, ConfigType=1)
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_prbblanking_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_ul_prbblanking_info(df,
                                                                   list_of_subcells,
                                                                   list_of_non_subcells)
    df_pooled_subcells.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    filename = str("%s/%s.csv" % (get_directory(path_to_pickle), name))
    logging.info("run_prb_blanking_analysis_ul filename = %s" % filename)
    list_rnti = CB013715_tools.get_rnti_from_csv_file(filename=filename)
    ulFdSchedData_startPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='ulFdSchedData.startPrb')
    ulFdSchedData_numOfPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='ulFdSchedData.numOfPrb')
    ulFdSchedData_subcellId = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='ulFdSchedData.subcellId')
    resultTest = True
    resultTest1 = True
    logging.info("CB013715 list_of_subcells = %s" % list_of_subcells)
    logging.info("CB013715 list_rnti = %s" % list_rnti)
    # logging.info("CB013715 ulFdSchedData_startPrb = %s" % ulFdSchedData_startPrb)
    # logging.info("CB013715 ulFdSchedData_numOfPrb = %s" % ulFdSchedData_numOfPrb)
    if len(list_rnti) == 0:
        logging.error("list_rnti empty")
        msg = 'run_prb_blanking_analysis_ul: list_rnti empty!!!'
        datedConsole(msg)
        resultTest = False
        raise Exception('Check failed, list_rnti empty')
    for rnti in list_rnti:
        startPrb = ulFdSchedData_startPrb[rnti][1:]
        # logging.info("rnti = %s startPrb = %s" % (rnti, startPrb))
        numOfPrb = ulFdSchedData_numOfPrb[rnti][1:]
        # logging.info("rnti = %s numOfPrb = %s" % (rnti, numOfPrb))
        all_startPrb_by_rnti = len(startPrb)
        logging.info("=====> Checking for rnti %s " % rnti)
        for i in range(all_startPrb_by_rnti):
            if int(float(ulFdSchedData_startPrb[rnti][i])) < int(first_prb_non_blanking):
                startprb_int = int(float(ulFdSchedData_startPrb[rnti][i]))
                logging.error("startPrb (%s) for rnti=%s < first_prb_non_blanking (%s) for Index (%s)"
                              % (startprb_int, rnti, first_prb_non_blanking, i))
                resultTest = False
                raise Exception('Check failed, startPrb {} for rnti {} < first_prb_non_blanking {} for Index {}'
                                .format(startprb_int, rnti, first_prb_non_blanking, i))
            end_prb = int(float(ulFdSchedData_startPrb[rnti][i])) + int(float(ulFdSchedData_numOfPrb[rnti][i])) - 1
            if end_prb > int(last_prb_non_blanking):
                logging.error("end_prb (%s} for rnti=%s > last_prb_non_blanking (%s) for Index (%s)"
                              % (end_prb, rnti, last_prb_non_blanking, i))
                resultTest = False
                raise Exception('Check failed, end_prb {} for rnti {} > last_prb_non_blanking {} for Index {}'
                                .format(end_prb, rnti, last_prb_non_blanking, i))
    subcellId = ulFdSchedData_subcellId[list_rnti[0]][0]
    msg = "[run_prb_blanking_analysis_ul][subcellId=%s] nbrOfBlankedPRBsLowEdgeUL=%s"
    logger.info(msg % (subcellId, nbrOfBlankedPRBsLowEdgeUL))
    msg = "[run_prb_blanking_analysis_ul][subcellId=%s] nbrOfBlankedPRBsHighEdgeUL=%s"
    logger.info(msg % (subcellId, nbrOfBlankedPRBsHighEdgeUL))
    SlotSfnRec2 = SlotSfn_PUSCH.createSlotSfnRecords(csvfile=filename, prbMax=bwpPrb,
                                                     ble=nbrOfBlankedPRBsLowEdgeUL,
                                                     bhe=nbrOfBlankedPRBsHighEdgeUL,
                                                     pattern='ulFdSchedData', chBW=bwpPrb)
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec2)
    SlotSfn_PUSCH.printSlotSfnRec(SlotSfnRec2, onlyKO=True)
    countSlotSfnRecord_ul = SlotSfn_PUSCH.countSlotSfnRecord(SlotSfnRec2)
    logging.info("=====> ul countSlotSfnRecord==%s" % countSlotSfnRecord_ul)
    countPrbInconsistency_ul = SlotSfn_PUSCH.countPrbInconsistency(SlotSfnRec2)
    nbr_err = float(countPrbInconsistency_ul / countSlotSfnRecord_ul)
    logging.info("=====> ul nbr_err=%s" % nbr_err)
    logger.info("=====> countSlotSfnRecord_ul=%s" % countSlotSfnRecord_ul)
    logger.info("=====> countPrbInconsistency_ul=%s" % countPrbInconsistency_ul)
    logger.info("=====> ul nbr_err=%s" % nbr_err)
    SlotSfn_PUSCH.printPartOfSlotSfnRecord(SlotSfnRec2, onlyKO=True)
    if nbr_err != 0:
        resultTest1 = False
        msg = 'nbr_err %f > 0 countPrbInconsistency_ul %i and countSlotSfnRecord_ul %i'
        logger.info(msg % (nbr_err, countSlotSfnRecord_ul, countPrbInconsistency_ul))
        raise Exception('Check failed, nbr_err {} > 0 countPrbInconsistency_ul {} and countSlotSfnRecord_ul {}'
                        .format(nbr_err, countPrbInconsistency_ul, countSlotSfnRecord_ul))
    return all([resultTest, resultTest1])


@log_begin_end_func_name
def verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL1(bwpPrb=52, first_prb_non_blanking_cell1=0,
                                                    last_prb_non_blanking_cell1=52,
                                                    nbrOfBlankedPRBsHighEdgeDL=0,
                                                    nbrOfBlankedPRBsLowEdgeDL=0):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_csirsscheddata_pkl}")
    list_of_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    if not list_of_subcells or list_of_subcells is None:
        list_of_subcells = [0, 2]
    print("verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL1 : list_of_subcells=" + str(list_of_subcells)[1:-1])
    list_of_non_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    if not list_of_non_subcells or list_of_non_subcells is None:
        list_of_non_subcells = [1]
    list_of_non_subcells.append(255)
    print("verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL1 : list_of_non_subcells=" + str(list_of_non_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p0 =\
            run_prb_blanking_analysis_csirs_dl(path_to_ttitrace_pkl, bwpPrb=bwpPrb,
                                               list_of_subcells=list_of_subcells,
                                               list_of_non_subcells=list_of_non_subcells,
                                               exclude_samples_for_analysis=1000,
                                               first_prb_non_blanking=first_prb_non_blanking_cell1,
                                               last_prb_non_blanking=last_prb_non_blanking_cell1,
                                               nbrOfBlankedPRBsHighEdgeDL=nbrOfBlankedPRBsHighEdgeDL,
                                               nbrOfBlankedPRBsLowEdgeDL=nbrOfBlankedPRBsLowEdgeDL,
                                               name='dl_dataframe_for_manual_analysis_csirs_prblanking_cell1')
        msg = "verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL1: is_TTITrace_correct_p0 = %s"
        logging.info(msg % (is_TTITrace_correct_p0))
        msg = 'verify_TTITraces_for_CSIRS_DL_PRBBLANKING CELL1: is_TTITrace_correct_p0'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p0))
    except Exception as e:
        logException("verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL1", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p0))
    rbi.should_be_true(is_TTITrace_correct_p0)


@log_begin_end_func_name
def filter_dataframe_csirs_dl(df):
    if 'csiRsSchedData.csiRsTraceType' in df.columns:
        required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'csiRsSchedData.subcellId',
                                   'csiRsSchedData.csiRsTraceType', 'csiRsSchedData.startSymbol',
                                   'csiRsSchedData.startPrb', 'csiRsSchedData.numOfPrb',
                                   'csiRsSchedData.csiRsConfig', 'lcrId']
    else:
        required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'csiRsSchedData.subcellId',
                                   'csiRsSchedData.startSymbol',
                                   'csiRsSchedData.startPrb', 'csiRsSchedData.numOfPrb',
                                   'csiRsSchedData.csiRsConfig', 'lcrId']
    df = df[required_discriminators].copy()
    if 'csiRsSchedData.csiRsTraceType' in df.columns:
        df = df[(df['csiRsSchedData.csiRsTraceType'] == 'UECSIRS') |
                (df['csiRsSchedData.csiRsTraceType'] == 'CELLCSIRS')]
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    # logging.info("=====> filter_dataframe_csirs_dl=%s" % df)
    return df


@log_begin_end_func_name
def prepare_df_to_compute_dl_csirs_prbblanking_info(df, list_of_subcells, list_of_non_subcells):
    for non_pooled_subcell in list_of_non_subcells:
        df = df.where(df['csiRsSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'csiRsSchedData.subcellId',
                                  'csiRsSchedData.startSymbol', 'csiRsSchedData.startPrb', 'csiRsSchedData.numOfPrb',
                                  'csiRsSchedData.csiRsConfig', 'lcrId'],
                                 inplace=True)
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
@log('DL CSIRS prb overlap analysis TtiTraces...', 'DL CSIRS prb overlap analysis TtiTraces finished', logger)
def run_prb_blanking_analysis_csirs_dl(path_to_pickle,  bwpPrb=52,
                                       list_of_subcells=[0, 2],
                                       list_of_non_subcells=[1],
                                       exclude_samples_for_analysis=1000,
                                       first_prb_non_blanking=0,
                                       last_prb_non_blanking=273,
                                       nbrOfBlankedPRBsHighEdgeDL=0,
                                       nbrOfBlankedPRBsLowEdgeDL=0,
                                       name='dl_dataframe_for_manual_analysis_prblanking_cell1'):
    """Check DL CSIRS TtiTraces PRB Constraints"""
    # rbgSize = 16
    prbMax = bwpPrb
    rbgSize = CB013715_tools.return_only_rbgsize_pdsch(chBW=prbMax, ConfigType=1)
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_csirs_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_dl_csirs_prbblanking_info(df,
                                                                         list_of_subcells,
                                                                         list_of_non_subcells)
    df_pooled_subcells.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    filename = str("%s/%s.csv" % (get_directory(path_to_pickle), name))
    logging.info("run_prb_blanking_analysis_csirs_dl filename = %s" % filename)
    list_rnti = CB013715_tools.get_rnti_from_csv_file(filename=filename)
    csirsSchedData_startPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='csiRsSchedData.startPrb')
    csirsSchedData_numOfPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='csiRsSchedData.numOfPrb')
    csirsSchedData_subcellId = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='csiRsSchedData.subcellId')
    resultTest = True
    resultTest1 = True
    logging.info("CB013715 list_of_subcells = %s" % list_of_subcells)
    logging.info("CB013715 list_rnti = %s" % list_rnti)
    # logging.info("CB013715 csirsSchedData_startPrb = %s" % csirsSchedData_startPrb)
    # logging.info("CB013715 csirsSchedData_numOfPrb = %s" % csirsSchedData_numOfPrb)
    if len(list_rnti) == 0:
        logging.error("list_rnti empty")
        msg = 'run_prb_blanking_analysis_csirs_dl: list_rnti empty!!!'
        datedConsole(msg)
        resultTest = False
        raise Exception('Check failed, list_rnti empty')
    for rnti in list_rnti:
        startPrb = csirsSchedData_startPrb[rnti][1:]
        # logging.info("rnti = %s startPrb = %s" % (rnti, startPrb))
        numOfPrb = csirsSchedData_numOfPrb[rnti][1:]
        # logging.info("rnti = %s numOfPrb = %s" % (rnti, numOfPrb))
        all_startPrb_by_rnti = len(startPrb)
        logging.info("=====> Checking for rnti %s " % rnti)
        for i in range(all_startPrb_by_rnti):
            if int(float(csirsSchedData_startPrb[rnti][i])) < int(first_prb_non_blanking):
                startprb_int = int(float(csirsSchedData_startPrb[rnti][i]))
                logging.error("startPrb (%s) for rnti=%s < first_prb_non_blanking (%s) for Index (%s)"
                              % (startprb_int, rnti, first_prb_non_blanking, i))
                resultTest = False
                raise Exception('Check failed, startPrb {} for rnti {} < first_prb_non_blanking {} for Index {}'
                                .format(startprb_int, rnti, first_prb_non_blanking, i))
            end_prb = int(float(csirsSchedData_startPrb[rnti][i])) + int(float(csirsSchedData_numOfPrb[rnti][i])) - 1
            if end_prb > int(last_prb_non_blanking):
                logging.error("end_prb (%s} for rnti=%s > last_prb_non_blanking (%s) for Index (%s)"
                              % (end_prb, rnti, last_prb_non_blanking, i))
                resultTest = False
                raise Exception('Check failed, end_prb {} for rnti {} > last_prb_non_blanking {} for Index {}'
                                .format(end_prb, rnti, last_prb_non_blanking, i))
    subcellId = csirsSchedData_subcellId[list_rnti[0]][0]
    msg = "[run_prb_blanking_analysis_csirs_dl][subcellId=%s] nbrOfBlankedPRBsLowEdgeDL=%s"
    logger.info(msg % (subcellId, nbrOfBlankedPRBsLowEdgeDL))
    msg = "[run_prb_blanking_analysis_csirs_dl][subcellId=%s] nbrOfBlankedPRBsHighEdgeDL=%s"
    logger.info(msg % (subcellId, nbrOfBlankedPRBsHighEdgeDL))
    SlotSfnRec2 = SlotSfn_CSIRS.createSlotSfnRecords(csvfile=filename, prbMax=bwpPrb,
                                                     ble=nbrOfBlankedPRBsLowEdgeDL,
                                                     bhe=nbrOfBlankedPRBsHighEdgeDL,
                                                     pattern='csiRsSchedData', chBW=bwpPrb)
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec2)
    SlotSfn_CSIRS.printSlotSfnRec(SlotSfnRec2, onlyKO=True)
    countSlotSfnRecord_dl = SlotSfn_CSIRS.countSlotSfnRecord(SlotSfnRec2)
    logging.info("=====> dl countSlotSfnRecord==%s" % countSlotSfnRecord_dl)
    countPrbInconsistency_dl = SlotSfn_CSIRS.countPrbInconsistency(SlotSfnRec2)
    nbr_err = float(countPrbInconsistency_dl / countSlotSfnRecord_dl)
    logging.info("=====> dl nbr_err=%s" % nbr_err)
    logger.info("=====> countSlotSfnRecord_dl=%s" % countSlotSfnRecord_dl)
    logger.info("=====> countPrbInconsistency_dl=%s" % countPrbInconsistency_dl)
    logger.info("=====> dl nbr_err=%s" % nbr_err)
    SlotSfn_CSIRS.printPartOfSlotSfnRecord(SlotSfnRec2, onlyKO=True)
    if nbr_err != 0:
        resultTest1 = False
        msg = 'nbr_err %f > 0 countPrbInconsistency_dl %i and countSlotSfnRecord_dl %i'
        logger.info(msg % (nbr_err, countSlotSfnRecord_dl, countPrbInconsistency_dl))
        raise Exception('Check failed, nbr_err {} > 0 countPrbInconsistency_dl {} and countSlotSfnRecord_dl {}'
                        .format(nbr_err, countPrbInconsistency_dl, countSlotSfnRecord_dl))
    return all([resultTest, resultTest1])


@log_begin_end_func_name
def verify_Pcap_for_pucchResources_UL_PRBBLANKING(filecsv, bwpPrb=52,
                                                  nbrOfBlankedPRBsHighEdgeUL=0,
                                                  nbrOfBlankedPRBsLowEdgeUL=0):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    path_to_csvtrace = filecsv
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p0 =\
            run_pucchresources_prb_blanking_analysis_pcap_ul(csvfile=path_to_csvtrace, bwpPrb=bwpPrb,
                                                             nbrOfBlankedPRBsHighEdgeUL=nbrOfBlankedPRBsHighEdgeUL,
                                                             nbrOfBlankedPRBsLowEdgeUL=nbrOfBlankedPRBsLowEdgeUL)
        text = "verify_Pcap_for_pucchResources_UL_PRBBLANKING: is_TTITrace_correct_p0 = %s"
        logging.info(text % is_TTITrace_correct_p0)
        msg = 'verify_Pcap_for_pucchResources_UL_PRBBLANKING CELL: is_TTITrace_correct_p0'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p0))
    except Exception as e:
        logException("verify_Pcap_for_pucchResources_UL_PRBBLANKING", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p0))
    rbi.should_be_true(is_TTITrace_correct_p0)


@log_begin_end_func_name
@log('UL pucchresources overlap analysis pcap...', 'UL pucchresources overlap analysis pcap finished', logger)
def run_pucchresources_prb_blanking_analysis_pcap_ul(csvfile, bwpPrb=52,
                                                     nbrOfBlankedPRBsHighEdgeUL=0,
                                                     nbrOfBlankedPRBsLowEdgeUL=0):
    logging.info("run_pucchresources_prb_blanking_analysis_pcap_ul filename = %s" % csvfile)
    list_cells = CB013715_tools.get_cell_from_csv_file(csvfile, '3gpp.subcellid')
    subcellid = list_cells[0]
    msg = "[SubCellId=%s] nbrOfBlankedPRBsHighEdgeUL=%s"
    logging.info(msg % (subcellid, nbrOfBlankedPRBsHighEdgeUL))
    msg = "[SubCellId=%s] nbrOfBlankedPRBsLowEdgeUL=%s"
    logging.info(msg % (subcellid, nbrOfBlankedPRBsLowEdgeUL))
    msg = "[pucchresources_analysis][SubCellId=%s] nbrOfBlankedPRBsLowEdgeUL=%s"
    logger.info(msg % (subcellid, nbrOfBlankedPRBsLowEdgeUL))
    msg = "[pucchresources_analysis][SubCellId=%s] nbrOfBlankedPRBsHighEdgeUL=%s"
    logger.info(msg % (subcellid, nbrOfBlankedPRBsHighEdgeUL))
    resultTest = True
    SlotSfnRec = SlotSfn_pucchResources.createSlotSfnRecords(csvfile=csvfile, prbMax=bwpPrb,
                                                             ble=nbrOfBlankedPRBsLowEdgeUL,
                                                             bhe=nbrOfBlankedPRBsHighEdgeUL,
                                                             pattern='UlData_pucchReceiveReqPucchResourceL1sw_t')
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    SlotSfn_pucchResources.printSlotSfnRec(SlotSfnRec, onlyKO=True)
    countSlotSfnRecord_subcellId = SlotSfn_pucchResources.countSlotSfnRecord(SlotSfnRec)
    countPrbInconsistency_subcellId = SlotSfn_pucchResources.countPrbInconsistency(SlotSfnRec)
    logging.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
    logging.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
    if int(countSlotSfnRecord_subcellId) > 0:
        nbr_err = float(countPrbInconsistency_subcellId / countSlotSfnRecord_subcellId)
    else:
        logging.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
        logging.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
        nbr_err = 0
    logging.info("=====> nbr_err=%s" % nbr_err)
    logger.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
    logger.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
    logger.info("=====> nbr_err=%s" % nbr_err)
    # SlotSfn_pucchResources.printPartOfSlotSfnRecord(SlotSfnRec, onlyKO=True)
    if nbr_err != 0:
        resultTest = False
        msg = 'nbr_err %f > 0 countPrbInconsistency_subcellId %i and countSlotSfnRecord_subcellId %i'
        logger.info(msg % (nbr_err, countPrbInconsistency_subcellId, countSlotSfnRecord_subcellId))
        msg = 'Check failed, nbr_err {} > 0 countPrbInconsistency_subcellId {} and countSlotSfnRecord_subcellId {}'
        raise Exception(msg.format(nbr_err, countPrbInconsistency_subcellId, countSlotSfnRecord_subcellId))

    return all([resultTest])


@log_begin_end_func_name
def verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING(filecsv, bwpPrb=52,
                                                       nbrOfBlankedPRBsHighEdgeUL=0,
                                                       nbrOfBlankedPRBsLowEdgeUL=0):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    path_to_csvtrace = filecsv
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p0 = \
            run_puschreceivereq_prb_blanking_analysis_pcap_ul(csvfile=path_to_csvtrace, bwpPrb=bwpPrb,
                                                              nbrOfBlankedPRBsHighEdgeUL=nbrOfBlankedPRBsHighEdgeUL,
                                                              nbrOfBlankedPRBsLowEdgeUL=nbrOfBlankedPRBsLowEdgeUL)
        text = "verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING: is_TTITrace_correct_p0 = %s"
        logging.info(text % is_TTITrace_correct_p0)
        msg = 'verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING CELL: is_TTITrace_correct_p0'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p0))
    except Exception as e:
        logException("verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p0))
    rbi.should_be_true(is_TTITrace_correct_p0)


@log_begin_end_func_name
@log('UL puschreceivereq overlap analysis pcap...', 'UL puschreceivereq overlap analysis pcap finished', logger)
def run_puschreceivereq_prb_blanking_analysis_pcap_ul(csvfile, bwpPrb=52,
                                                      nbrOfBlankedPRBsHighEdgeUL=0,
                                                      nbrOfBlankedPRBsLowEdgeUL=0):
    logging.info("run_pucchresources_prb_blanking_analysis_pcap_ul filename = %s" % csvfile)
    list_cells = CB013715_tools.get_cell_from_csv_file(csvfile, '3gpp.subcellid')
    subcellid = list_cells[0]
    msg = "[SubCellId=%s] nbrOfBlankedPRBsHighEdgeUL=%s"
    logging.info(msg % (subcellid, nbrOfBlankedPRBsHighEdgeUL))
    msg = "[SubCellId=%s] nbrOfBlankedPRBsLowEdgeUL=%s"
    logging.info(msg % (subcellid, nbrOfBlankedPRBsLowEdgeUL))
    msg = "[puschreceivereq_analysis][SubCellId=%s] nbrOfBlankedPRBsLowEdgeUL=%s"
    logger.info(msg % (subcellid, nbrOfBlankedPRBsLowEdgeUL))
    msg = "[puschreceivereq_analysis][SubCellId=%s] nbrOfBlankedPRBsHighEdgeUL=%s"
    logger.info(msg % (subcellid, nbrOfBlankedPRBsHighEdgeUL))
    resultTest = True
    SlotSfnRec = SlotSfn_PUSCH.createSlotSfnRecords(csvfile=csvfile, prbMax=bwpPrb,
                                                    ble=nbrOfBlankedPRBsLowEdgeUL,
                                                    bhe=nbrOfBlankedPRBsHighEdgeUL,
                                                    pattern='UlData_puschReceiveReqGrant_t',
                                                    pattern_3gpp='3gpp.',
                                                    chBW=bwpPrb)
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    SlotSfn_PUSCH.printSlotSfnRec(SlotSfnRec, onlyKO=True)
    countSlotSfnRecord_subcellId = SlotSfn_PUSCH.countSlotSfnRecord(SlotSfnRec)
    countPrbInconsistency_subcellId = SlotSfn_PUSCH.countPrbInconsistency(SlotSfnRec)
    logging.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
    logging.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
    if int(countSlotSfnRecord_subcellId) > 0:
        nbr_err = float(countPrbInconsistency_subcellId / countSlotSfnRecord_subcellId)
    else:
        logging.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
        logging.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
        nbr_err = 0
    logging.info("=====> nbr_err=%s" % nbr_err)
    logger.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
    logger.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
    logger.info("=====> nbr_err=%s" % nbr_err)
    # SlotSfn_PUSCH.printPartOfSlotSfnRecord(SlotSfnRec, onlyKO=True)
    if nbr_err != 0:
        resultTest = False
        msg = 'nbr_err %f > 0 countPrbInconsistency_subcellId %i and countSlotSfnRecord_subcellId %i'
        logger.info(msg % (nbr_err, countPrbInconsistency_subcellId, countSlotSfnRecord_subcellId))
        msg = 'Check failed, nbr_err {} > 0 countPrbInconsistency_subcellId {} and countSlotSfnRecord_subcellId {}'
        raise Exception(msg.format(nbr_err, countPrbInconsistency_subcellId, countSlotSfnRecord_subcellId))

    return all([resultTest])


def load_dataframe(path_to_pickle):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


@log_begin_end_func_name
def filter_dataframe_prbblanking_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlFdSchedData.subcellId',
                               'dlFdSchedData.startPrb', 'dlFdSchedData.numOfPrb', 'dlFdSchedData.rat0Bitmap',
                               'dlFdSchedData.ueBwpId', 'dlFdSchedData.cellBwpId', 'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    # logging.info("=====> filter_dataframe_prbblanking_dl=%s" % df)
    return df


@log_begin_end_func_name
def drop_head_tail_entries(df, num=1000):
    """Function drops num entries from the beginning and the end of the dataframe to compensate for the
    abnormalities seen in trace during start and stop of traffic"""
    df = df[num:-num]
    return df


@log_begin_end_func_name
def prepare_df_to_compute_prbblanking_info(df, list_of_subcells, list_of_non_subcells):
    """
    Used only for Full BWP case
    :param df:
    :param list_of_subcells:
    :param list_of_non_subcells:
    :return:
    """
    for non_pooled_subcell in list_of_non_subcells:
        df = df.where(df['dlFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    # df = df.where(df['dlFdSchedData.cellBwpId'] == 1).dropna()
    df = df.where(df['dlFdSchedData.ueBwpId'] == 1).dropna()
    df_pooled_subcells = df
    # logging.info(df_pooled_subcells['dlFdSchedData.rat0Bitmap'].astype(str))
    # df_pooled_subcells['dlFdSchedData.rat0Bitmap_hex'] =\
    #     df_pooled_subcells['dlFdSchedData.rat0Bitmap'].astype(str).astype(int).apply(bin)
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.startPrb', 'dlFdSchedData.numOfPrb', 'dlFdSchedData.rat0Bitmap'],
                                 inplace=True)
    #                              'dlFdSchedData.rat0Bitmap_hex'],
    # df_pooled_subcells['dlFdSchedData.rat0Bitmap_hex'] = df_pooled_subcells['dlFdSchedData.rat0Bitmap'].apply(bin)
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
@log('DL prb overlap analysis TtiTraces...', 'DL prb overlap analysis TtiTraces finished', logger)
def run_prb_blanking_analysis_dl(path_to_pickle, bwpPrb=52,
                                 list_of_subcells=[0, 2],
                                 list_of_non_subcells=[1],
                                 exclude_samples_for_analysis=1000,
                                 first_prb_non_blanking=0,
                                 last_prb_non_blanking=273,
                                 nbrOfBlankedPRBsHighEdgeDL=0,
                                 nbrOfBlankedPRBsLowEdgeDL=0,
                                 name='dl_dataframe_for_manual_analysis_prblanking_cell1'):
    """Check PDSCH L1L2pcap PRB Constraints"""
    # rbgSize = 16
    prbMax = bwpPrb
    rbgSize = CB013715_tools.return_only_rbgsize_pdsch(chBW=prbMax, ConfigType=1)
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_prbblanking_dl(df)
    logging.info("run_prb_blanking_analysis_dl: length of df = %s" % len(df))
    len_df = len(df)
    if len_df > 3*exclude_samples_for_analysis:
        df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_prbblanking_info(df,
                                                                list_of_subcells,
                                                                list_of_non_subcells)
    df_pooled_subcells.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    filename = str("%s/%s.csv" % (get_directory(path_to_pickle), name))
    logging.info("run_prb_blanking_analysis_dl filename = %s" % filename)
    list_rnti = CB013715_tools.get_rnti_from_csv_file(filename=filename)
    dlFdSchedData_startPrb =\
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='dlFdSchedData.startPrb')
    dlFdSchedData_numOfPrb =\
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='dlFdSchedData.numOfPrb')
    dlFdSchedData_subcellId =\
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                   linename='dlFdSchedData.subcellId')
    resultTest = True
    resultTest1 = True
    logging.info("CB013715 list_of_subcells = %s" % list_of_subcells)
    logging.info("CB013715 list_rnti = %s" % list_rnti)
    # logging.info("CB013715 dlFdSchedData_startPrb = %s" % dlFdSchedData_startPrb)
    # logging.info("CB013715 dlFdSchedData_numOfPrb = %s" % dlFdSchedData_numOfPrb)
    if len(list_rnti) == 0:
        logging.error("list_rnti empty")
        msg = 'run_prb_blanking_analysis_dl: list_rnti empty!!!'
        datedConsole(msg)
        resultTest = False
        raise Exception('Check failed, list_rnti empty')
    for rnti in list_rnti:
        startPrb = dlFdSchedData_startPrb[rnti][1:]
        # logging.info("rnti = %s startPrb = %s" % (rnti, startPrb))
        numOfPrb = dlFdSchedData_numOfPrb[rnti][1:]
        # logging.info("rnti = %s numOfPrb = %s" % (rnti, numOfPrb))
        all_startPrb_by_rnti = len(startPrb)
        logging.info("=====> Checking for rnti %s " % rnti)
        for i in range(all_startPrb_by_rnti):
            if int(float(dlFdSchedData_startPrb[rnti][i])) < int(first_prb_non_blanking):
                logging.error("startPrb for rnti=%s < first_prb_non_blanking (%s) for Index (%s)"
                              % (rnti, first_prb_non_blanking, i))
                resultTest = False
                raise Exception('Check failed, startPrb for rnti {} < first_prb_non_blanking {} for Index {}'
                                .format(rnti, first_prb_non_blanking, i))
            startPrb_mod_rbgSize = int(float(dlFdSchedData_startPrb[rnti][i])) % rbgSize
            if startPrb_mod_rbgSize != 0:
                logging.error("startPrb_mod_rbgSize for rnti=%s ERR for Index (%s)"
                              % (rnti, i))
                resultTest = False
                raise Exception('Check failed, startPrb_mod_rbgSize for rnti {} ERR for Index {}'
                                .format(rnti, i))
            end_prb = int(float(dlFdSchedData_startPrb[rnti][i])) + int(float(dlFdSchedData_numOfPrb[rnti][i])) - 1
            if end_prb > int(last_prb_non_blanking):
                logging.error("end_prb (%s} for rnti=%s > last_prb_non_blanking (%s) for Index (%s)"
                              % (end_prb, rnti, last_prb_non_blanking, i))
                resultTest = False
                raise Exception('Check failed, end_prb {} for rnti {} > last_prb_non_blanking {} for Index {}'
                                .format(end_prb, rnti, last_prb_non_blanking, i))
    subcellId = dlFdSchedData_subcellId[list_rnti[0]][0]
    msg = "[run_prb_blanking_analysis_dl][CellId=%s] nbrOfBlankedPRBsLowEdgeDL=%s"
    logger.info(msg % (subcellId, nbrOfBlankedPRBsLowEdgeDL))
    msg = "[run_prb_blanking_analysis_dl][CellId=%s] nbrOfBlankedPRBsHighEdgeDL=%s"
    logger.info(msg % (subcellId, nbrOfBlankedPRBsHighEdgeDL))
    SlotSfnRec = SlotSfn_PDSCH.createSlotSfnRecords(csvfile=filename, prbMax=prbMax,
                                                    ble=nbrOfBlankedPRBsLowEdgeDL,
                                                    bhe=nbrOfBlankedPRBsHighEdgeDL,
                                                    pattern='dlFdSchedData', chBW=prbMax)
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    SlotSfn_PDSCH.printSlotSfnRec(SlotSfnRec, onlyKO=True)
    countSlotSfnRecord_dl = SlotSfn_PDSCH.countSlotSfnRecord(SlotSfnRec)
    logging.info("=====> dl countSlotSfnRecord==%s" % countSlotSfnRecord_dl)
    countPrbInconsistency_dl = SlotSfn_PDSCH.countPrbInconsistency(SlotSfnRec)
    nbr_err = float(countPrbInconsistency_dl / countSlotSfnRecord_dl)
    logging.info("=====> dl nbr_err=%s" % nbr_err)
    logger.info("=====> countSlotSfnRecord_dl=%s" % countSlotSfnRecord_dl)
    logger.info("=====> countPrbInconsistency_dl=%s" % countPrbInconsistency_dl)
    logger.info("=====> dl nbr_err=%s" % nbr_err)
    SlotSfn_PDSCH.printPartOfSlotSfnRecord(SlotSfnRec, onlyKO=True)
    if nbr_err != 0:
        resultTest1 = False
        msg = 'nbr_err %f > 0 countPrbInconsistency_dl %i and countSlotSfnRecord_dl %i'
        logger.info(msg % (nbr_err, countPrbInconsistency_dl, countSlotSfnRecord_dl))
        raise Exception('Check failed, nbr_err {} > 0 countPrbInconsistency_dl {} and countSlotSfnRecord_dl {}'
                        .format(nbr_err, countPrbInconsistency_dl, countSlotSfnRecord_dl))
    return all([resultTest, resultTest1])


@log_begin_end_func_name
def check_ul_fragmentation_with_prb_blanking(list_cells,
                                             longpucchstartprb,
                                             longpucchnumprb,
                                             first_prb_non_blanking=0,
                                             last_prb_non_blanking=273):
    resultTest = True
    for cell in list_cells:
        cell_val = int(cell)
        startPrb = longpucchstartprb[cell][0:]
        logging.info("cell = %s startPrb = %s" % (cell, startPrb))
        numOfPrb = longpucchnumprb[cell][0:]
        logging.info("cell = %s numOfPrb = %s" % (cell, numOfPrb))
        all_startPrb_by_cell = len(startPrb)
        logging.info("=====> Checking for cell %s " % cell)
        for i in range(all_startPrb_by_cell):
            if int(float(longpucchstartprb[cell][i])) < int(first_prb_non_blanking):
                logging.error("startPrb for cell=%s < first_prb_non_blanking (%s) for Index (%s)"
                              % (cell, first_prb_non_blanking, i))
                raise Exception('Check failed, startPrb for cell {} < first_prb_non_blanking {} for Index {}'
                                .format(cell, first_prb_non_blanking, i))
                resultTest = False
            end_prb = int(float(longpucchstartprb[cell][i])) + int(float(longpucchnumprb[cell][i])) - 1
            if end_prb > int(last_prb_non_blanking):
                logging.error("end_prb (%s} for cell=%s > last_prb_non_blanking (%s) for Index (%s)"
                              % (end_prb, cell, last_prb_non_blanking, i))
                raise Exception('Check failed, end_prb {} for rnti {} > last_prb_non_blanking {} for Index {}'
                                .format(end_prb, cell, last_prb_non_blanking, i))
                resultTest = False
    return resultTest, startPrb, numOfPrb, cell_val


@log_begin_end_func_name
def get_pucch_region_position(longPucchStartSr1Prb_val,
                              longPucchStartSr2Prb_val,
                              longPucchNumSrPrb_val,
                              longPucchStartHarq1Prb_val,
                              longPucchStartHarq2Prb_val,
                              longPucchNumHarqPrb_val,
                              longPucchStartPcsi1Prb_val,
                              longPucchStartPcsi2Prb_val,
                              longPucchNumPcsiPrb_val):
    if ((int(longPucchStartHarq1Prb_val) + int(longPucchNumHarqPrb_val) == int(longPucchStartSr2Prb_val)) and
            (int(longPucchStartSr2Prb_val) + int(longPucchNumSrPrb_val) == int(longPucchStartHarq2Prb_val)) and
            (int(longPucchStartHarq2Prb_val) + int(longPucchNumHarqPrb_val) == int(longPucchStartPcsi1Prb_val))):
        pucch_low_edge_region_position = True
        pucch_high_edge_region_position = False
    else:
        pucch_low_edge_region_position = True
        pucch_high_edge_region_position = True
    return pucch_low_edge_region_position, pucch_high_edge_region_position


@log_begin_end_func_name
def get_start_end_prb_pusch_decicatedBWP(cell_val,
                                         first_prb_non_blanking,
                                         last_prb_non_blanking,
                                         longPucchStartSr1Prb_val,
                                         longPucchStartSr2Prb_val,
                                         longPucchNumSrPrb_val,
                                         longPucchStartHarq1Prb_val,
                                         longPucchStartHarq2Prb_val,
                                         longPucchNumHarqPrb_val,
                                         longPucchStartPcsi1Prb_val,
                                         longPucchStartPcsi2Prb_val,
                                         longPucchNumPcsiPrb_val):
    """return first PUSCH prb and last PUSCH prb for dedicated BWP case and return also PUCCH size"""
    # Check that longPucchStartSr1Prb + longPucchNumSrPrb == longPucchStartHarq1Prb
    # Check that longPucchStartHarq1Prb + longPucchNumHarqPrb == longPucchStartPcsi1Prb
    # Check that longPucchStartPcsi2Prb + longPucchNumPcsiPrb == longPucchStartHarq2Prb
    # Check that longPucchStartHarq2Prb + longPucchNumHarqPrb == longPucchStartSr2Prb

    resultTest7 = True
    resultTest8 = True
    resultTest9 = True
    resultTest10 = True
    CellId = {50: 1, 51: 2, 52: 3, 53: 4}

    logging.info("CB013715 longPucchStartSr1Prb_val = %s" % longPucchStartSr1Prb_val)

    if not (int(longPucchStartSr1Prb_val) + int(longPucchNumSrPrb_val) == int(longPucchStartHarq1Prb_val)
            or int(longPucchStartHarq1Prb_val) == int(longPucchStartSr1Prb_val)):
        logging.error("longPucchStartSr1Prb + longPucchNumSrPrb != longPucchStartHarq1Prb (%s, %s, %s)"
                      % (longPucchStartSr1Prb_val, longPucchNumSrPrb_val, longPucchStartHarq1Prb_val))
        logging.error("or longPucchStartHarq1Prb != longPucchStartSr1Prb (%s, %s)"
                      % (longPucchStartHarq1Prb_val, longPucchStartSr1Prb_val))
        text = 'longPucchStartSr1Prb + longPucchNumSrPrb != longPucchStartHarq1Prb ({}, {}, {})' \
               + 'or longPucchStartHarq1Prb != longPucchStartSr1Prb ({}, {})'
        resultTest7 = False
        raise Exception(text.format(longPucchStartSr1Prb_val, longPucchNumSrPrb_val,
                                    longPucchStartHarq1Prb_val, longPucchStartHarq1Prb_val,
                                    longPucchStartSr1Prb_val))

    logging.info("CB013715 resultTest7 = %s" % resultTest7)

    if not (int(longPucchStartHarq1Prb_val) + int(longPucchNumHarqPrb_val) == int(longPucchStartPcsi1Prb_val)):
        logging.error("longPucchStartHarq1Prb + longPucchNumHarqPrb != longPucchStartPcsi1Prb (%s, %s, %s)"
                      % (longPucchStartHarq1Prb_val, longPucchNumHarqPrb_val,
                         longPucchStartPcsi1Prb_val))
        text = 'longPucchStartHarq1Prb + longPucchNumHarqPrb != longPucchStartPcsi1Prb ({}, {}, {})'
        resultTest8 = False
        raise Exception(text.format(longPucchStartHarq1Prb_val, longPucchNumHarqPrb_val,
                                    longPucchStartPcsi1Prb_val))

    logging.info("CB013715 resultTest8 = %s" % resultTest8)

    if int(longPucchStartPcsi2Prb_val) + int(longPucchNumPcsiPrb_val) != \
            int(longPucchStartHarq2Prb_val):
        logging.error("longPucchStartPcsi2Prb + longPucchStartPcsi2Prb != longPucchStartHarq2Prb (%s, %s, %s)"
                      % (longPucchStartPcsi2Prb_val, longPucchNumPcsiPrb_val,
                         longPucchStartHarq2Prb_val))
        resultTest9 = False
        raise Exception('longPucchStartPcsi2Prb + longPucchStartPcsi2Prb != longPucchStartHarq2Prb ({}, {}, {})'
                        .format(longPucchStartPcsi2Prb_val, longPucchNumPcsiPrb_val,
                                longPucchStartHarq2Prb_val))

    logging.info("CB013715 resultTest9 = %s" % resultTest9)

    if not (int(longPucchStartHarq2Prb_val) + int(longPucchNumHarqPrb_val) == int(longPucchStartSr2Prb_val)
            or int(longPucchStartHarq2Prb_val) == int(longPucchStartSr2Prb_val)):
        logging.error("longPucchStartHarq2Prb + longPucchNumHarqPrb != longPucchStartSr2Prb_val (%s, %s, %s)"
                      % (longPucchStartHarq2Prb_val, longPucchNumHarqPrb_val, longPucchStartSr2Prb_val))
        logging.error("or longPucchStartHarq2Prb != longPucchStartSr2Prb_val (%s, %s)"
                      % (longPucchStartHarq2Prb_val, longPucchStartSr2Prb_val))
        text = 'longPucchStartHarq2Prb + longPucchNumHarqPrb != longPucchStartSr2Prb_val ({}, {}, {})' \
               + 'or longPucchStartHarq2Prb != longPucchStartSr2Prb_val ({}, {})'
        resultTest10 = False
        raise Exception(text.format(longPucchStartHarq2Prb_val, longPucchNumHarqPrb_val,
                                    longPucchStartSr2Prb_val, longPucchStartHarq2Prb_val,
                                    longPucchStartSr2Prb_val))

    logging.info("CB013715 resultTest10 = %s" % resultTest10)

    logging.info("longPucchNumSrPrb_val = %s" % str(longPucchNumSrPrb_val))
    logging.info("longPucchNumHarqPrb_val = %s" % str(longPucchNumHarqPrb_val))
    logging.info("longPucchNumPcsiPrb_val = %s" % str(longPucchNumPcsiPrb_val))

    #  take into account when CB006878 is activated (actDynUlResAlloc = TRUE)
    #  if actDynUlResAlloc = TRUE => PRB regions for pCSI are shareable with PUSCH region
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # test_scf_file = '/home/ute/csamson/TRACES/SCF.xml'
    BuiltIn().log("verifyFeatureActivation: scfFilePath = %s (SCF)" % path_to_scf_xml)
    mrbts_id = rbi.get_variable_value('${MRBTS_ID}')
    nrbts_id = rbi.get_variable_value('${NRBTS_ID}')
    cellid_val = CellId[cell_val]
    mr_nr_cell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-' + str(cellid_val)
    logging.info("mr_nr_cell = %s" % mr_nr_cell)
    expected_scf_list = [{'p_name': 'actDynUlResAlloc', 'value': 'true', 'dist_name': mr_nr_cell}]
    is_CB006878_activated = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    # is_CB006878_activated = True
    logging.info("CB006878 activated = %s" % is_CB006878_activated)
    if is_CB006878_activated:
        longPucchNumPcsiPrb_val_int = 0
    else:
        longPucchNumPcsiPrb_val_int = int(longPucchNumPcsiPrb_val)
    first_pusch_prb = int(first_prb_non_blanking)
    if int(longPucchStartHarq1Prb_val) == int(longPucchStartSr1Prb_val):
        first_pusch_prb = \
            int(first_pusch_prb) + int(longPucchNumSrPrb_val) + longPucchNumPcsiPrb_val_int
    else:
        first_pusch_prb = \
            int(first_pusch_prb) + int(longPucchNumSrPrb_val) + int(longPucchNumHarqPrb_val) \
            + longPucchNumPcsiPrb_val_int

    if int(longPucchStartHarq2Prb_val) == int(longPucchStartSr2Prb_val):
        last_pusch_prb = \
            int(last_prb_non_blanking) - int(longPucchNumSrPrb_val) - longPucchNumPcsiPrb_val_int
    else:
        last_pusch_prb = \
            int(last_prb_non_blanking) - int(longPucchNumSrPrb_val) \
            - int(longPucchNumHarqPrb_val) - longPucchNumPcsiPrb_val_int

    logging.info("CB013715 first_pusch_prb w PUCCH size = %s" % str(first_pusch_prb))
    logging.info("CB013715 last_pusch_prb w PUCCH size = %s" % str(last_pusch_prb))

    if int(longPucchStartHarq1Prb_val) == int(longPucchStartSr1Prb_val):
        pucch_size_lower = int(longPucchNumSrPrb_val) + int(longPucchNumPcsiPrb_val)
    else:
        pucch_size_lower = \
            int(longPucchNumSrPrb_val) + int(longPucchNumHarqPrb_val) + int(longPucchNumPcsiPrb_val)
    if int(longPucchStartHarq2Prb_val) == int(longPucchStartSr2Prb_val):
        pucch_size_upper = int(longPucchNumSrPrb_val) + int(longPucchNumPcsiPrb_val)
    else:
        pucch_size_upper = \
            int(longPucchNumSrPrb_val) + int(longPucchNumHarqPrb_val) + int(longPucchNumPcsiPrb_val)
    pucch_size = pucch_size_lower + pucch_size_upper
    logging.info("CB013715 pucch_size = %s" % str(pucch_size))
    rbi.set_test_variable("${PUCCH_SIZE}", str(pucch_size))
    rbi.set_test_variable("${FIRST_PUSCH_PRB}", str(first_pusch_prb))
    rbi.set_test_variable("${LAST_PUSCH_PRB}", str(last_pusch_prb))
    msg = 'verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking CELL' + str(cell_val) + ': PUCCH_SIZE'
    datedConsole(getHeaderLine(msg, str(pucch_size)))
    msg = 'verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking CELL' + str(cell_val) + ': FIRST_PUSCH_PRB'
    datedConsole(getHeaderLine(msg, str(first_pusch_prb)))
    msg = 'verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking CELL' + str(cell_val) + ': LAST_PUSCH_PRB'
    datedConsole(getHeaderLine(msg, str(last_pusch_prb)))
    return first_pusch_prb, last_pusch_prb, pucch_size, resultTest7, resultTest8, resultTest9, resultTest10


@log_begin_end_func_name
def get_start_end_prb_pusch_decicatedPSBWP(cell_val,
                                           first_prb_non_blanking,
                                           last_prb_non_blanking,
                                           longPucchStartSr1Prb_val,
                                           longPucchStartSr2Prb_val,
                                           longPucchNumSrPrb_val,
                                           longPucchStartHarq1Prb_val,
                                           longPucchStartHarq2Prb_val,
                                           longPucchNumHarqPrb_val,
                                           longPucchStartPcsi1Prb_val,
                                           longPucchStartPcsi2Prb_val,
                                           longPucchNumPcsiPrb_val):
    """return first PUSCH prb and last PUSCH prb for dedicated BWP case and return also PUCCH size"""
    # Check that longPucchStartSr1Prb + longPucchNumSrPrb == longPucchStartHarq1Prb
    # Check that longPucchStartHarq1Prb + longPucchNumHarqPrb == longPucchStartPcsi1Prb
    # Check that longPucchStartPcsi1Prb + longPucchNumPcsiPrb == longPucchStartSr2Prb
    # Check that longPucchStartSr2Prb + longPucchNumSrPrb == longPucchStartHarq2Prb
    # Check that longPucchStartHarq2Prb + longPucchNumHarqPrb == longPucchStartPcsi2Prb

    resultTest7 = True
    resultTest8 = True
    resultTest9 = True
    resultTest10 = True
    CellId = {50: 1, 51: 2, 52: 3, 53: 4}

    logging.info("CB013715 longPucchStartSr1Prb_val = %s" % longPucchStartSr1Prb_val)

    if not (int(longPucchStartSr1Prb_val) + int(longPucchNumSrPrb_val) == int(longPucchStartHarq1Prb_val)):
        logging.error("longPucchStartSr1Prb + longPucchNumSrPrb != longPucchStartHarq1Prb (%s, %s, %s)"
                      % (longPucchStartSr1Prb_val, longPucchNumSrPrb_val, longPucchStartHarq1Prb_val))
        logging.error("or longPucchStartHarq1Prb != longPucchStartSr1Prb (%s, %s)"
                      % (longPucchStartHarq1Prb_val, longPucchStartSr1Prb_val))
        text = 'longPucchStartSr1Prb + longPucchNumSrPrb != longPucchStartHarq1Prb ({}, {}, {})'
        resultTest7 = False
        raise Exception(text.format(longPucchStartSr1Prb_val, longPucchNumSrPrb_val,
                                    longPucchStartHarq1Prb_val))

    logging.info("CB013715 resultTest7 = %s" % resultTest7)

    if not (int(longPucchStartHarq1Prb_val) + int(longPucchNumHarqPrb_val) == int(longPucchStartSr2Prb_val)):
        logging.error("longPucchStartHarq1Prb + longPucchNumHarqPrb != longPucchStartSr2Prb (%s, %s, %s)"
                      % (longPucchStartHarq1Prb_val, longPucchNumHarqPrb_val,
                         longPucchStartSr2Prb_val))
        text = 'longPucchStartHarq1Prb + longPucchNumHarqPrb != longPucchStartSr2Prb ({}, {}, {})'
        resultTest8 = False
        raise Exception(text.format(longPucchStartHarq1Prb_val, longPucchNumHarqPrb_val,
                                    longPucchStartSr2Prb_val))

    logging.info("CB013715 resultTest8 = %s" % resultTest8)

    if int(longPucchStartHarq2Prb_val) + int(longPucchNumHarqPrb_val) != \
            int(longPucchStartPcsi1Prb_val):
        logging.error("longPucchStartHarq2Prb + longPucchNumHarqPrb != longPucchStartPcsi1Prb (%s, %s, %s)"
                      % (longPucchStartHarq2Prb_val, longPucchNumHarqPrb_val,
                         longPucchStartPcsi1Prb_val))
        resultTest9 = False
        raise Exception('longPucchStartHarq2Prb + longPucchNumHarqPrb != longPucchStartPcsi1Prb ({}, {}, {})'
                        .format(longPucchStartHarq2Prb_val, longPucchNumHarqPrb_val,
                                longPucchStartPcsi1Prb_val))

    logging.info("CB013715 resultTest9 = %s" % resultTest9)

    if not (int(longPucchStartPcsi1Prb_val) + int(longPucchNumPcsiPrb_val) == int(longPucchStartPcsi2Prb_val)):
        logging.error("longPucchStartPcsi1Prb + longPucchNumPcsiPrb != longPucchStartPcsi2rb (%s, %s, %s)"
                      % (longPucchStartPcsi1Prb_val, longPucchNumPcsiPrb_val, longPucchStartPcsi2Prb_val))
        text = 'longPucchStartPcsi1Prb + longPucchNumPcsiPrb != longPucchStartPcsi2rb ({}, {}, {})'
        resultTest10 = False
        raise Exception(text.format(longPucchStartPcsi1Prb_val, longPucchNumPcsiPrb_val,
                                    longPucchStartPcsi2Prb_val))

    logging.info("CB013715 resultTest10 = %s" % resultTest10)

    logging.info("longPucchNumSrPrb_val = %s" % str(longPucchNumSrPrb_val))
    logging.info("longPucchNumHarqPrb_val = %s" % str(longPucchNumHarqPrb_val))
    logging.info("longPucchNumPcsiPrb_val = %s" % str(longPucchNumPcsiPrb_val))

    #  take into account when CB006878 is activated (actDynUlResAlloc = TRUE)
    #  if actDynUlResAlloc = TRUE => PRB regions for pCSI are shareable with PUSCH region
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # path_to_scf_xml = '/home/ute/csamson/TRACES/SCF.xml'
    BuiltIn().log("verifyFeatureActivation: scfFilePath = %s (SCF)" % path_to_scf_xml)
    mrbts_id = rbi.get_variable_value('${MRBTS_ID}')
    nrbts_id = rbi.get_variable_value('${NRBTS_ID}')
    cellid_val = CellId[cell_val]
    mr_nr_cell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-' + str(cellid_val)
    # mr_nr_cell = 'MRBTS-' + '1' + '/NRBTS-' + '1' + '/NRCELL-' + str(cellid_val)
    logging.info("mr_nr_cell = %s" % mr_nr_cell)
    expected_scf_list = [{'p_name': 'actDynUlResAlloc', 'value': 'true', 'dist_name': mr_nr_cell}]
    is_CB006878_activated = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    # is_CB006878_activated = True
    logging.info("CB006878 activated = %s" % is_CB006878_activated)
    if is_CB006878_activated:
        longPucchNumPcsiPrb_val_int = 0
    else:
        longPucchNumPcsiPrb_val_int = int(longPucchNumPcsiPrb_val)
    first_pusch_prb = int(first_prb_non_blanking)
    last_pusch_prb = int(last_prb_non_blanking)
    logging.info("CB013715 first_pusch_prb wo PUCCH size = %s" % str(first_pusch_prb))
    logging.info("CB013715 last_pusch_prb wo PUCCH size = %s" % str(last_pusch_prb))
    pucch_size_lower = 0
    if int(longPucchStartHarq1Prb_val) == int(longPucchStartSr1Prb_val):
        pucch_size_lower = pucch_size_lower + int(longPucchNumSrPrb_val)
    else:
        pucch_size_lower = pucch_size_lower + int(longPucchNumSrPrb_val) + int(longPucchNumHarqPrb_val)
    if int(longPucchStartHarq2Prb_val) == int(longPucchStartSr2Prb_val):
        pucch_size_lower = pucch_size_lower + int(longPucchNumSrPrb_val)
    else:
        pucch_size_lower = pucch_size_lower + int(longPucchNumSrPrb_val) + int(longPucchNumHarqPrb_val)
    if int(longPucchStartPcsi1Prb_val) == int(longPucchStartPcsi2Prb_val):
        pucch_size_lower = pucch_size_lower + int(longPucchNumPcsiPrb_val_int)
    else:
        pucch_size_lower = pucch_size_lower + 2 * int(longPucchNumPcsiPrb_val_int)
    pucch_size_upper = 0
    pucch_size = pucch_size_lower + pucch_size_upper
    first_pusch_prb = first_pusch_prb + pucch_size_lower
    # add here the pCsi NumPrb to pucch size if CB006878 is activated
    if is_CB006878_activated:
        pucch_size = pucch_size + 2 * int(longPucchNumPcsiPrb_val)
    logging.info("CB013715 first_pusch_prb w PUCCH size = %s" % str(first_pusch_prb))
    logging.info("CB013715 last_pusch_prb w PUCCH size = %s" % str(last_pusch_prb))
    logging.info("CB013715 pucch_size = %s" % str(pucch_size))
    rbi.set_test_variable("${PUCCH_SIZE}", str(pucch_size))
    rbi.set_test_variable("${FIRST_PUSCH_PRB}", str(first_pusch_prb))
    rbi.set_test_variable("${LAST_PUSCH_PRB}", str(last_pusch_prb))
    msg = 'verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking CELL' + str(cell_val) + ': PUCCH_SIZE'
    datedConsole(getHeaderLine(msg, str(pucch_size)))
    msg = 'verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking CELL' + str(cell_val) + ': FIRST_PUSCH_PRB'
    datedConsole(getHeaderLine(msg, str(first_pusch_prb)))
    msg = 'verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking CELL' + str(cell_val) + ': LAST_PUSCH_PRB'
    datedConsole(getHeaderLine(msg, str(last_pusch_prb)))
    return first_pusch_prb, last_pusch_prb, pucch_size, resultTest7, resultTest8, resultTest9, resultTest10


@log_begin_end_func_name
def run_prb_blanking_analysis_cprt_pcap(file,
                                        first_prb_non_blanking=0,
                                        last_prb_non_blanking=273):
    logging.info("run_prb_blanking_analysis_cprt_pcap filename = %s" % file)
    CellId = {50: 1, 51: 2, 52: 3, 53: 4}
    # rbgSize = return_only_rbgsize_pdsch(chBW=273, ConfigType=1)
    # list by itf_l2_ps_cell_CellSetupReq_t.physCellId
    list_cells = CB013715_tools.get_cell_from_csv_file(filename=file,
                                                       pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr1Prb'
    longPucchStartSr1Prb =\
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr2Prb'
    longPucchStartSr2Prb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumSrPrb'
    longPucchNumSrPrb =\
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')

    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartHarq1Prb'
    longPucchStartHarq1Prb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartHarq2Prb'
    longPucchStartHarq2Prb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumHarqPrb'
    longPucchNumHarqPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')

    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartPcsi1Prb'
    longPucchStartPcsi1Prb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartPcsi2Prb'
    longPucchStartPcsi2Prb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumPcsiPrb'
    longPucchNumPcsiPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=file,
                                                                   linename=linename,
                                                                   pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')

    resultTest = True
    resultTest1 = True
    resultTest2 = True
    resultTest3 = True
    resultTest4 = True
    resultTest5 = True
    resultTest6 = True
    resultTest7 = True
    resultTest8 = True
    resultTest9 = True
    resultTest10 = True

    logging.info("CB013715 first_prb_non_blanking = %s" % first_prb_non_blanking)
    logging.info("CB013715 last_prb_non_blanking = %s" % last_prb_non_blanking)

    logging.info("CB013715 list_cells = %s" % list_cells)
    logging.info("CB013715 longPucchStartSr1Prb = %s" % longPucchStartSr1Prb)
    logging.info("CB013715 longPucchStartSr2Prb = %s" % longPucchStartSr2Prb)
    logging.info("CB013715 longPucchNumSrPrb = %s" % longPucchNumSrPrb)

    logging.info("CB013715 longPucchStartHarq1Prb = %s" % longPucchStartHarq1Prb)
    logging.info("CB013715 longPucchStartHarq2Prb = %s" % longPucchStartHarq2Prb)
    logging.info("CB013715 longPucchNumHarqPrb = %s" % longPucchNumHarqPrb)

    logging.info("CB013715 longPucchStartPcsi1Prb = %s" % longPucchStartPcsi1Prb)
    logging.info("CB013715 longPucchStartPcsi2Prb = %s" % longPucchStartPcsi2Prb)
    logging.info("CB013715 longPucchNumPcsiPrb = %s" % longPucchNumPcsiPrb)

    if len(list_cells) == 0:
        logging.error("list_cells empty")
        resultTest = False
        raise Exception('Check failed, list_cells empty')

    # Check that longPucchStartSr1Prb + longPucchNumSrPrb == longPucchStartHarq1Prb or
    #            longPucchStartSr1Prb == longPucchStartHarq1Prb
    # Check that longPucchStartHarq1Prb + longPucchNumHarqPrb == longPucchStartPcsi1Prb
    # Check that longPucchStartPcsi2Prb + longPucchNumPcsiPrb == longPucchStartHarq2Prb
    # Check that longPucchStartHarq2Prb + longPucchNumHarqPrb == longPucchStartSr2Prb or
    #            longPucchStartHarq2Prb == longPucchStartSr2Prb

    # pusch lower start prb should be (first_prb_non_blanking + longPucchNumSrPrb + longPucchNumHarqPrb +
    # longPucchNumPcsiPrb) and pusch upper start prb should be (last_prb_non_blanking - longPucchNumSrPrb -
    # longPucchNumHarqPrb - longPucchNumPcsiPrb)

    # longPucchStartSr1Prb check with Prb blanking constraint
    resultTest1, longPucchStartSr1Prb_val, longPucchNumSrPrb_val, cell_val =\
        check_ul_fragmentation_with_prb_blanking(list_cells=list_cells,
                                                 longpucchstartprb=longPucchStartSr1Prb,
                                                 longpucchnumprb=longPucchNumSrPrb,
                                                 first_prb_non_blanking=first_prb_non_blanking,
                                                 last_prb_non_blanking=last_prb_non_blanking)

    resultTest2, longPucchStartSr2Prb_val, longPucchNumSrPrb_val, cell_val =\
        check_ul_fragmentation_with_prb_blanking(list_cells=list_cells,
                                                 longpucchstartprb=longPucchStartSr2Prb,
                                                 longpucchnumprb=longPucchNumSrPrb,
                                                 first_prb_non_blanking=first_prb_non_blanking,
                                                 last_prb_non_blanking=last_prb_non_blanking)

    resultTest3, longPucchStartHarq1Prb_val, longPucchNumHarqPrb_val, cell_val =\
        check_ul_fragmentation_with_prb_blanking(list_cells=list_cells,
                                                 longpucchstartprb=longPucchStartHarq1Prb,
                                                 longpucchnumprb=longPucchNumHarqPrb,
                                                 first_prb_non_blanking=first_prb_non_blanking,
                                                 last_prb_non_blanking=last_prb_non_blanking)

    resultTest4, longPucchStartHarq2Prb_val, longPucchNumHarqPrb_val, cell_val =\
        check_ul_fragmentation_with_prb_blanking(list_cells=list_cells,
                                                 longpucchstartprb=longPucchStartHarq2Prb,
                                                 longpucchnumprb=longPucchNumHarqPrb,
                                                 first_prb_non_blanking=first_prb_non_blanking,
                                                 last_prb_non_blanking=last_prb_non_blanking)

    resultTest5, longPucchStartPcsi1Prb_val, longPucchNumPcsiPrb_val, cell_val =\
        check_ul_fragmentation_with_prb_blanking(list_cells=list_cells,
                                                 longpucchstartprb=longPucchStartPcsi1Prb,
                                                 longpucchnumprb=longPucchNumPcsiPrb,
                                                 first_prb_non_blanking=first_prb_non_blanking,
                                                 last_prb_non_blanking=last_prb_non_blanking)

    resultTest6, longPucchStartPcsi2Prb_val, longPucchNumPcsiPrb_val, cell_val =\
        check_ul_fragmentation_with_prb_blanking(list_cells=list_cells,
                                                 longpucchstartprb=longPucchStartPcsi2Prb,
                                                 longpucchnumprb=longPucchNumPcsiPrb,
                                                 first_prb_non_blanking=first_prb_non_blanking,
                                                 last_prb_non_blanking=last_prb_non_blanking)

    logging.info("CB013715 resultTest1 = %s" % resultTest1)
    logging.info("CB013715 resultTest2 = %s" % resultTest2)
    logging.info("CB013715 resultTest3 = %s" % resultTest3)
    logging.info("CB013715 resultTest4 = %s" % resultTest4)
    logging.info("CB013715 resultTest5 = %s" % resultTest5)
    logging.info("CB013715 resultTest6 = %s" % resultTest6)

    # Check that longPucchStartSr1Prb + longPucchNumSrPrb == longPucchStartHarq1Prb
    # Check that longPucchStartHarq1Prb + longPucchNumHarqPrb == longPucchStartPcsi1Prb
    # Check that longPucchStartPcsi2Prb + longPucchNumPcsiPrb == longPucchStartHarq2Prb
    # Check that longPucchStartHarq2Prb + longPucchNumHarqPrb == longPucchStartSr2Prb

    # add detection of PDCCH region position
    pucch_low_edge_region_position, pucch_high_edge_region_position =\
        get_pucch_region_position(longPucchStartSr1Prb_val=longPucchStartSr1Prb_val[0],
                                  longPucchStartSr2Prb_val=longPucchStartSr2Prb_val[0],
                                  longPucchNumSrPrb_val=longPucchNumSrPrb_val[0],
                                  longPucchStartHarq1Prb_val=longPucchStartHarq1Prb_val[0],
                                  longPucchStartHarq2Prb_val=longPucchStartHarq2Prb_val[0],
                                  longPucchNumHarqPrb_val=longPucchNumHarqPrb_val[0],
                                  longPucchStartPcsi1Prb_val=longPucchStartPcsi1Prb_val[0],
                                  longPucchStartPcsi2Prb_val=longPucchStartPcsi2Prb_val[0],
                                  longPucchNumPcsiPrb_val=longPucchNumPcsiPrb_val[0])
    text = "CB013715 pucch_low_edge_region_position = %s and pucch_high_edge_region_position = %s"
    logging.info(text % (pucch_low_edge_region_position, pucch_high_edge_region_position))
    if pucch_low_edge_region_position and pucch_high_edge_region_position:
        get_start_end_prb_pusch_decicatedBWP(cell_val=cell_val,
                                             first_prb_non_blanking=first_prb_non_blanking,
                                             last_prb_non_blanking=last_prb_non_blanking,
                                             longPucchStartSr1Prb_val=longPucchStartSr1Prb_val[0],
                                             longPucchStartSr2Prb_val=longPucchStartSr2Prb_val[0],
                                             longPucchNumSrPrb_val=longPucchNumSrPrb_val[0],
                                             longPucchStartHarq1Prb_val=longPucchStartHarq1Prb_val[0],
                                             longPucchStartHarq2Prb_val=longPucchStartHarq2Prb_val[0],
                                             longPucchNumHarqPrb_val=longPucchNumHarqPrb_val[0],
                                             longPucchStartPcsi1Prb_val=longPucchStartPcsi1Prb_val[0],
                                             longPucchStartPcsi2Prb_val=longPucchStartPcsi2Prb_val[0],
                                             longPucchNumPcsiPrb_val=longPucchNumPcsiPrb_val[0])
    elif pucch_low_edge_region_position and not pucch_high_edge_region_position:
        get_start_end_prb_pusch_decicatedPSBWP(cell_val=cell_val,
                                               first_prb_non_blanking=first_prb_non_blanking,
                                               last_prb_non_blanking=last_prb_non_blanking,
                                               longPucchStartSr1Prb_val=longPucchStartSr1Prb_val[0],
                                               longPucchStartSr2Prb_val=longPucchStartSr2Prb_val[0],
                                               longPucchNumSrPrb_val=longPucchNumSrPrb_val[0],
                                               longPucchStartHarq1Prb_val=longPucchStartHarq1Prb_val[0],
                                               longPucchStartHarq2Prb_val=longPucchStartHarq2Prb_val[0],
                                               longPucchNumHarqPrb_val=longPucchNumHarqPrb_val[0],
                                               longPucchStartPcsi1Prb_val=longPucchStartPcsi1Prb_val[0],
                                               longPucchStartPcsi2Prb_val=longPucchStartPcsi2Prb_val[0],
                                               longPucchNumPcsiPrb_val=longPucchNumPcsiPrb_val[0])
    else:
        text = 'impossible case !!! pucch_low_edge_region_position = {} and pucch_high_edge_region_position = {}'
        raise Exception(text.format(pucch_low_edge_region_position, pucch_high_edge_region_position))

    return all([resultTest, resultTest1, resultTest2, resultTest3, resultTest4, resultTest5,
                resultTest6, resultTest7, resultTest8, resultTest9, resultTest10])


@log_begin_end_func_name
def verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking(filecsv,
                                                        first_prb_non_blanking_cell=0,
                                                        last_prb_non_blanking_cell=273):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    path_to_csvtrace = filecsv
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p0 =\
            run_prb_blanking_analysis_cprt_pcap(file=path_to_csvtrace,
                                                first_prb_non_blanking=first_prb_non_blanking_cell,
                                                last_prb_non_blanking=last_prb_non_blanking_cell)
        text = "verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking: is_TTITrace_correct_p0 = %s"
        logging.info(text % is_TTITrace_correct_p0)
        msg = 'verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking CELL: is_TTITrace_correct_p0'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p0))
    except Exception as e:
        logException("verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p0))
    rbi.should_be_true(is_TTITrace_correct_p0)


@log_begin_end_func_name
def display_dynamic_pusch(filecsv):
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_csvtrace = filecsv
    try:
        logging.basicConfig(level=logging.DEBUG)
        physcellid = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace,
                                                                       'itf_l2_ps_cell_CellSetupReq_t.physCellId')
        # text = "display_dynamic_pusch: physcellid = %s"
        # logging.info(text % physcellid)
        subcellid = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace, '3gpp.subcellid')
        cellbwpid = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace, 'itf_l2_ps_cell_Bwp.cellBwpId')
        bwpType = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace, 'itf_l2_ps_cell_Bwp.bwpType')
        bandwidth = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace,
                                                                      'itf_l2_ps_cell_BwpDefinitionUl.bandwidth')
        field = 'itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item'
        long_pucch_start_pusch_prb = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace, field)
        field = 'itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item'
        long_pucch_num_pusch_prb = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace, field)
        field = 'itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item'
        long_pucch_start_dyn_pusch_prb = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace, field)
        field = 'itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item'
        long_pucch_num_dyn_pusch_prb = CB013715_tools.get_specified_column_from_csv_file(path_to_csvtrace, field)
        datedConsole(getHeaderLine('physcellid', physcellid))
        datedConsole(getHeaderLine('subcellid', subcellid))
        datedConsole(getHeaderLine('cellbwpid', cellbwpid))
        datedConsole(getHeaderLine('bwpType', bwpType))
        datedConsole(getHeaderLine('bandwidth', bandwidth))
        datedConsole(getHeaderLine('long_pucch_start_pusch_prb', long_pucch_start_pusch_prb))
        datedConsole(getHeaderLine('long_pucch_num_pusch_prb', long_pucch_num_pusch_prb))
        datedConsole(getHeaderLine('long_pucch_num_pusch_prb', long_pucch_start_dyn_pusch_prb))
        datedConsole(getHeaderLine('long_pucch_num_pusch_prb', long_pucch_num_dyn_pusch_prb))
    except Exception as e:
        logException("display_dynamic_pusch", e)
    return long_pucch_start_dyn_pusch_prb, long_pucch_num_dyn_pusch_prb


def run_prb_blanking_analysis_pcap_dl(pcapfile, chBW=52,
                                      first_prb_non_blanking=0,
                                      last_prb_non_blanking=52):
    """ Support only full dedicated BWP case """
    if not isinstance(chBW, int):
        raise TypeError("Parameters 'chBW' must be integers")
    if not isinstance(first_prb_non_blanking, int) or not isinstance(first_prb_non_blanking, int):
        raise TypeError("Parameters 'first_prb_non_blanking', and 'first_prb_non_blanking' must be integers")
    logging.info("run_prb_blanking_analysis_pcap_dl filename = %s" % pcapfile)
    rbgSize = CB013715_tools.return_only_rbgsize_pdsch(chBW=chBW, ConfigType=1)
    list_rnti = CB013715_tools.get_rnti_from_csv_file(filename=pcapfile, pattern='3gpp.rnti')
    dlFdSchedData_startPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=pcapfile,
                                                                   linename='DlData_PdschGrantL1sw.startPrb',
                                                                   pattern='3gpp.rnti')
    dlFdSchedData_numOfPrb = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=pcapfile,
                                                                   linename='DlData_PdschGrantL1sw.numOfPrb',
                                                                   pattern='3gpp.rnti')
    dlFdSchedData_rbgSize = \
        CB013715_tools.get_specified_column_from_csv_file_for_rnti(filename=pcapfile,
                                                                   linename='DlData_PdschGrantL1sw.rbgSize',
                                                                   pattern='3gpp.rnti')
    resultTest = True
    # logging.info("CB013715 list_of_subcells = %s" % list_of_subcells)
    logging.info("CB013715 list_rnti = %s" % list_rnti)
    # logging.info("CB013715 dlFdSchedData_startPrb = %s" % dlFdSchedData_startPrb)
    # logging.info("CB013715 dlFdSchedData_numOfPrb = %s" % dlFdSchedData_numOfPrb)
    if len(list_rnti) == 0:
        logging.error("list_rnti empty")
        msg = 'run_prb_blanking_analysis_pcap_dl: list_rnti empty!!!'
        datedConsole(msg)
        raise Exception('Check failed, list_rnti empty')
        resultTest = False
    for rnti in list_rnti:
        startPrb = dlFdSchedData_startPrb[rnti][1:]
        # logging.info("rnti = %s startPrb = %s" % (rnti, startPrb))
        numOfPrb = dlFdSchedData_numOfPrb[rnti][1:]
        # logging.info("rnti = %s numOfPrb = %s" % (rnti, numOfPrb))
        all_startPrb_by_rnti = len(startPrb)
        logging.info("=====> Checking for rnti %s " % rnti)
        for i in range(all_startPrb_by_rnti):
            rbgSize_rnti = int(dlFdSchedData_rbgSize[rnti][i])
            first_prb_non_blanking_to_check = first_prb_non_blanking
            last_prb_non_blanking_to_check = last_prb_non_blanking
            rbgSize_to_check = rbgSize
            if int(float(dlFdSchedData_startPrb[rnti][i])) < int(first_prb_non_blanking_to_check):
                logging.error("startPrb for rnti=%s < first_prb_non_blanking (%s) for Index (%s)"
                              % (rnti, first_prb_non_blanking_to_check, i))
                resultTest = False
                raise Exception('Check failed, startPrb for rnti {} < first_prb_non_blanking {} for Index {}'
                                .format(rnti, first_prb_non_blanking_to_check, i))
            startPrb_mod_rbgSize = int(float(dlFdSchedData_startPrb[rnti][i])) % rbgSize_to_check
            # if rbgSize_to_check != rbgSize_PSBWP and startPrb_mod_rbgSize != 0:
            #     logging.error("startPrb_mod_rbgSize for rnti=%s ERR for Index (%s)"
            #                   % (rnti, i))
            #     raise Exception('Check failed, startPrb_mod_rbgSize for rnti {} ERR for Index {}'
            #                     .format(rnti, i))
            #     resultTest = False
            end_prb = int(float(dlFdSchedData_startPrb[rnti][i])) + int(float(dlFdSchedData_numOfPrb[rnti][i])) - 1
            if end_prb > int(last_prb_non_blanking_to_check):
                logging.error("end_prb (%s} for rnti=%s > last_prb_non_blanking (%s) for Index (%s)"
                              % (end_prb, rnti, last_prb_non_blanking_to_check, i))
                resultTest = False
                raise Exception('Check failed, end_prb {} for rnti {} > last_prb_non_blanking {} for Index {}'
                                .format(end_prb, rnti, last_prb_non_blanking_to_check, i))
    return all([resultTest])


@log_begin_end_func_name
def verify_Pcap_for_DL_PRBBLANKING(filecsv, bwpPrb=52,
                                   first_prb_non_blanking_cell=0,
                                   last_prb_non_blanking_cell=52):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    path_to_pcaptrace = filecsv
    try:
        logging.basicConfig(level=logging.DEBUG)
        is_TTITrace_correct_p0 =\
            run_prb_blanking_analysis_pcap_dl(path_to_pcaptrace, chBW=int(bwpPrb),
                                              first_prb_non_blanking=int(first_prb_non_blanking_cell),
                                              last_prb_non_blanking=int(last_prb_non_blanking_cell))
        logging.info("verify_Pcap_for_DL_PRBBLANKING: is_TTITrace_correct_p0 = %s" % is_TTITrace_correct_p0)
        msg = 'verify_Pcap_for_DL_PRBBLANKING CELL: is_TTITrace_correct_p0'
        datedConsole(getHeaderLine(msg, is_TTITrace_correct_p0))
    except Exception as e:
        logException("verify_Pcap_for_DL_PRBBLANKING", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p0))
    rbi.should_be_true(is_TTITrace_correct_p0)


@log_begin_end_func_name
@log('DL prb overlap analysis pcap...', 'DL prb overlap analysis pcap finished', logger)
def run_PDSCH_prb_blanking_overlap_analysis_pcap_dl(filecsv, bwpPrb=52,
                                                    nbrOfBlankedPRBsHighEdgeDL=0,
                                                    nbrOfBlankedPRBsLowEdgeDL=0,
                                                    w_return=True):
    """Check PDSCH L1L2pcap PRB Constraints"""
    logging.info("run_PDSCH_prb_blanking_overlap_analysis_pcap_dl filename = %s" % filecsv)
    prbMax = bwpPrb
    list_cells = CB013715_tools.get_cell_from_csv_file(filecsv, '3gpp.subcellid')
    subcellid = list_cells[0]
    msg = "[PDSCH_prb_blanking_overlap_analysis][SubCellId=%s] nbrOfBlankedPRBsLowEdgeDL=%s"
    logging.info(msg % (subcellid, nbrOfBlankedPRBsLowEdgeDL))
    logger.info(msg % (subcellid, nbrOfBlankedPRBsLowEdgeDL))
    msg = "[PDSCH_prb_blanking_overlap_analysis][SubCellId=%s] nbrOfBlankedPRBsHighEdgeDL=%s"
    logging.info(msg % (subcellid, nbrOfBlankedPRBsHighEdgeDL))
    logger.info(msg % (subcellid, nbrOfBlankedPRBsHighEdgeDL))
    # Validation Threshold to accept
    threshold = 0.01
    resultTest = True
    pattern = 'DlData_PdschGrantL1sw'
    SlotSfnRec =\
        SlotSfn_PDSCH.createSlotSfnRecords(csvfile=filecsv,
                                           prbMax=int(prbMax),
                                           ble=int(nbrOfBlankedPRBsLowEdgeDL),
                                           bhe=int(nbrOfBlankedPRBsHighEdgeDL),
                                           pattern=pattern,
                                           pattern_3gpp='3gpp.',
                                           chBW=int(prbMax))
    # logging.info("=====> SlotSfnRec==%s" % SlotSfnRec)
    SlotSfn_PDSCH.printSlotSfnRec(SlotSfnRec, onlyKO=True)
    countSlotSfnRecord_subcellId = SlotSfn_PDSCH.countSlotSfnRecord(SlotSfnRec)
    countPrbInconsistency_subcellId = SlotSfn_PDSCH.countPrbInconsistency(SlotSfnRec)
    logging.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
    logging.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
    logger.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
    logger.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
    if int(countSlotSfnRecord_subcellId) > 0:
        nbr_err = float(countPrbInconsistency_subcellId / countSlotSfnRecord_subcellId)
    else:
        logging.info("=====> countSlotSfnRecord_subcellId=%s" % countSlotSfnRecord_subcellId)
        logging.info("=====> countPrbInconsistency_subcellId=%s" % countPrbInconsistency_subcellId)
        nbr_err = 0.0
    logging.info("=====> nbr_err=%s" % nbr_err)
    logger.info("=====> nbr_err=%s" % nbr_err)
    # SlotSfn_PDSCH.printPartOfSlotSfnRecord(SlotSfnRec, onlyKO=True)
    if nbr_err >= threshold:
        resultTest = False
        rbi.log("nbr_err %f present and threshold %f reached..." % (nbr_err, threshold), 'ERROR')
        logger.info("nbr_err %f present and threshold %f reached..." % (nbr_err, threshold))
        msg = 'Check failed, nbr_err %f > %f countPrbInconsistency_subcellId %i and countSlotSfnRecord_subcellId %i'
        raise Exception(msg.format(nbr_err, threshold, countPrbInconsistency_subcellId, countSlotSfnRecord_subcellId))
    else:
        resultTest = True
        msg = 'WARN, nbr_err %f < %f countPrbInconsistency_subcellId %i and countSlotSfnRecord_subcellId %i'
        if nbr_err != 0.0:
            logging.info(msg % (nbr_err, threshold, countPrbInconsistency_subcellId, countSlotSfnRecord_subcellId))
            logger.info(msg % (nbr_err, threshold, countPrbInconsistency_subcellId, countSlotSfnRecord_subcellId))
        nbr_err_percent = nbr_err*100
        msg = "nbr_err=%f [%f percent] present but threshold=%f not reached.. Passing test case"
        if nbr_err != 0.0:
            rbi.log(msg % (nbr_err, nbr_err_percent, threshold), 'WARN')
            logger.info(msg % (nbr_err, nbr_err_percent, threshold))
    countRat0BitmapInconsistency_dl = SlotSfn_PDSCH.countRat0BitmapInconsistency(SlotSfnRec)
    logging.info("=====> dl countRat0BitmapInconsistency_dl=%s" % countRat0BitmapInconsistency_dl)
    nbr_err_rat0bitmap = float(countRat0BitmapInconsistency_dl / countSlotSfnRecord_subcellId)
    logging.info("=====> dl nbr_err_rat0bitmap=%f" % nbr_err_rat0bitmap)
    logger.info("=====> countRat0BitmapInconsistency_dl=%i" % countRat0BitmapInconsistency_dl)
    logger.info("=====> dl nbr_err_rat0bitmap=%f" % nbr_err_rat0bitmap)
    if nbr_err_rat0bitmap != 0.0:
        msg = 'WARN, nbr_err %f != 0 countPrbInconsistency_subcellId %i and countSlotSfnRecord_subcellId %i'
        logging.info(msg % (nbr_err_rat0bitmap, countRat0BitmapInconsistency_dl, countSlotSfnRecord_subcellId))
        logger.info(msg % (nbr_err_rat0bitmap, countRat0BitmapInconsistency_dl, countSlotSfnRecord_subcellId))
        msg = "nbr_err_rat0bitmap %f [count=%i] present..."
        rbi.log(msg % (nbr_err_rat0bitmap, countRat0BitmapInconsistency_dl), 'ERROR')
    msg = 'run_PDSCH_prb_blanking_overlap_analysis_pcap_dl CELL: resultTest'
    datedConsole(getHeaderLine(msg, resultTest))
    if w_return:
        result_str = return_result(resultTest)
        rbi.set_test_variable("${TestResult}", str(result_str))
    return all([resultTest])


def extract_ull1sp_from_syslog(syslogextract, l1sp_e=None, file='l2ps-SCellMappingReq-syslog'):
    if l1sp_e is None:
        l1sp_e = []
    return extract_l1sp_from_syslog(syslogextract, 'ul', l1sp_e, file=file)


def extract_dll1sp_from_syslog(syslogextract, l1sp_e=None, file='l2ps-SCellMappingReq-syslog'):
    if l1sp_e is None:
        l1sp_e = []
    return extract_l1sp_from_syslog(syslogextract, 'dl', l1sp_e, file=file)


@log('extract_l1sp_from_syslog...', 'extract_l1sp_from_syslog finished', logger)
def extract_l1sp_from_syslog(syslogextract, direction, l1sp_e=None, file='l2ps-cellmapping-syslog'):
    if l1sp_e is None:
        l1sp_e = []
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # syslogextract_flt2 = re.sub('^(.*SCellMappingReq: )', "", syslogextract_flt)
    syslogextract_flt2 = re.sub('^(.*CellMappingReq: )', "", syslogextract_flt)
    # pattern = r'\{\"CellMappingList\":.*?\"cellIndex\":.*?\}\]\}'
    pattern = r'\{\"nrCellIdentity\":.*?\"csirsPoolingGroupId\":.*?\}'

    # msg_console = '=====> syslogextract_flt2'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt2))
    logger_extract_syslog.info("begin extract_l1sp_from_syslog processing...")
    matches = re.findall(pattern, syslogextract_flt2)
    l1sp = []
    sp0 = []
    sp1 = []
    sp2 = []
    sp3 = []
    l1sp_2 = []
    sp0_2 = []
    sp1_2 = []
    sp2_2 = []
    sp3_2 = []
    index = 0
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        data = json.loads(msg)
        print(data)
        # msg_console = '=====> data'
        # datedConsole(getHeaderLine(msg_console, data))
        index = index + 1
        # msg_console = '=====> SubcellList'
        # datedConsole(getHeaderLine(msg_console, data[direction + 'SubcellList']))
        msg = "[extract_l1sp_from_syslog][CellId=%s][%s] =====> process with CellId %s"
        logger_extract_syslog.info(msg % (direction, data['nrCellIdentity'], data['nrCellIdentity']))
        for item in data[direction + 'SubcellList']:
            # msg_console = '=====> ' + direction + ' l1SubpoolId'
            # datedConsole(getHeaderLine(msg_console, item['l1SubpoolId']))
            msg = "[extract_l1sp_from_syslog][CellId=%s][%s] From item => %sSubcellId=%s l1PoolId=%s l1SubpoolId=%s"
            logger_extract_syslog.info(msg % (data['nrCellIdentity'], direction, direction,
                                              item[direction + 'SubcellId'],
                                              item['l1PoolId'], item['l1SubpoolId']))
            l1sp_per_cell = [data['nrCellIdentity'],
                             item['l1SubpoolId'],
                             item['l1PoolId']]
            if l1sp_per_cell not in l1sp:
                l1sp.append(l1sp_per_cell)
                msg = "[extract_l1sp_from_syslog][CellId=%s][%s] =====> append %s in l1sp"
                logger_extract_syslog.info(msg % (data['nrCellIdentity'], direction, l1sp_per_cell))
            name = direction + 'SubcellId'
            subcellid_per_l1sp = [item[name],
                                  item['l1SubpoolId'],
                                  item['l1PoolId']]
            if subcellid_per_l1sp not in l1sp_2:
                l1sp_2.append(subcellid_per_l1sp)
                msg = "[extract_l1sp_from_syslog][CellId=%s][%s] =====> append %s in l1sp2"
                logger_extract_syslog.info(msg % (data['nrCellIdentity'], direction, subcellid_per_l1sp))
            # msg_console = '=====> l1sp'
            # datedConsole(getHeaderLine(msg_console, l1sp))
        filename = file + '-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
    filename = file + '-' + direction + '-cellmapping' + '.json'
    if direction == 'dl':
        rbi.set_test_variable("${FileNameDLCellMapping}", filename)
    else:
        rbi.set_test_variable("${FileNameULCellMapping}", filename)
    with open(filename, 'w') as f:
        json.dump(l1sp, f, indent=4)
    if l1sp:
        mincellidentity = min([int(x[0]) for x in l1sp])
    else:
        mincellidentity = 0
    for element in l1sp:
        print(element)
        if int(element[2]) == 9:
            if int(element[1]) == 0:
                sp0.append(int(element[0]) - mincellidentity)
            elif int(element[1]) == 1:
                sp1.append(int(element[0]) - mincellidentity)
            else:
                sp0.append(int(element[0]) - mincellidentity)
        elif int(element[2]) == 12:
            if int(element[1]) == 2:
                sp2.append(int(element[0]) - mincellidentity)
            elif int(element[1]) == 3:
                sp3.append(int(element[0]) - mincellidentity)
            else:
                sp2.append(int(element[0]) - mincellidentity)
    for element in l1sp_2:
        print(element)
        if int(element[2]) == 9:
            if int(element[1]) == 0:
                sp0_2.append(int(element[0]))
            elif int(element[1]) == 1:
                sp1_2.append(int(element[0]))
            else:
                sp0_2.append(int(element[0]))
        elif int(element[2]) == 12:
            if int(element[1]) == 2:
                sp2_2.append(int(element[0]))
            elif int(element[1]) == 3:
                sp3_2.append(int(element[0]))
            else:
                sp2_2.append(int(element[0]))
    logger_extract_syslog.info("End Of extract_l1sp_from_syslog processing...")
    msg = "[extract_l1sp_from_syslog] =====> sp0 %s sp1 %s sp2 %s sp3 %s"
    logger_extract_syslog.info(msg % (sp0, sp1, sp2, sp3))
    msg = "[extract_l1sp_from_syslog] =====> sp0_2 %s sp1_2 %s sp2_2 %s sp3_2 %s"
    logger_extract_syslog.info(msg % (sp0_2, sp1_2, sp2_2, sp3_2))
    return [sorted(sp0), sorted(sp1), sorted(sp2), sorted(sp3),
            sorted(sp0_2), sorted(sp1_2), sorted(sp2_2), sorted(sp3_2)]


def test_csv_puschreceivereq():
    path = '/home/ute/csamson/TRACES'
    csvfile = path + '/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId1_expand.csv'
    run_puschreceivereq_prb_blanking_analysis_pcap_ul(csvfile, bwpPrb=106,
                                                      nbrOfBlankedPRBsHighEdgeUL=0,
                                                      nbrOfBlankedPRBsLowEdgeUL=0)


def test_csv_PDSCH_prb_blanking_overlap_analysis_From_PCAP():
    path = '/home/ute/csamson/TRACES'
    csvfile = path + '/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId0.csv'
    run_PDSCH_prb_blanking_overlap_analysis_pcap_dl(csvfile, bwpPrb=79,
                                                    nbrOfBlankedPRBsHighEdgeDL=0,
                                                    nbrOfBlankedPRBsLowEdgeDL=13,
                                                    w_return=False)


def test_prb_blanking_analysis_pcap_dl():
    path = '/home/ute/csamson/TRACES'
    csvfile = path + '/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId0.csv'
    verify_Pcap_for_DL_PRBBLANKING(csvfile, bwpPrb=106,
                                   first_prb_non_blanking_cell=0,
                                   last_prb_non_blanking_cell=106)


def load_dataframe_from_pickle(path_to_pickle):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


@log_begin_end_func_name
def verify_TTITraces_for_UL_Pooling(path_to_pickle,
                                    name='ul_df_for_manual_analysis_all_subcells_UL_Pooling'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_UL_Pooling.pkl'
    filter_valid_events_and_check_UL_Pooling(path_to_pickle=path_to_ttitrace_pkl,
                                             target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe_from_pickle(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def filter_valid_events_and_check_UL_Pooling(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for UL pooling Check and
        saves it into a new pickle to be used by other functions

        :param path_to_pickle: Path of input pickle file
        :param target_pkl_path: Path of new target pickle file

        :returns: target_pkl_path
    """
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    pd.reset_option('^display.')

    # TTI Trace Events
    ulAllocatedPooledResourcesData_numAllocCellPrbUl_event = 'ulAllocatedPooledResourcesData.numAllocCellPrbUl'
    ulAllocatedPooledResourcesData_activeUlSubcellsList = 'ulAllocatedPooledResourcesData.activeUlSubcellsList'
    ulAllocatedPooledResourcesData_activeUlSubcellCountARM = 'ulAllocatedPooledResourcesData.activeUlSubcellCountARM'
    ulMetricIndData_gbrPrbDemand_event = 'ulMetricIndData.metricIndData.gbrPrbDemand'
    ulMetricIndData_nonGbrPrbDemand_event = 'ulMetricIndData.metricIndData.nonGbrPrbDemand'
    ulMetricIndData_rrmAvgSpectralEffSlot_event = 'ulMetricIndData.metricIndData.rrmAvgSpectralEffSlot'
    ulMetricIndData_avgLoadNonGbr_event = 'ulMetricIndData.metricIndData.avgLoadNonGbr'
    ulAllocatedPooledResourcesData_allocStreamPrbGbrUl = 'ulAllocatedPooledResourcesData.allocStreamPrbGbrUl'
    ulAllocatedPooledResourcesData_allocStreamPrbNonGbrUl = 'ulAllocatedPooledResourcesData.allocStreamPrbNonGbrUl'

    filtered_df = (
        df.loc[(df['rnti'] != 65535),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                ulAllocatedPooledResourcesData_numAllocCellPrbUl_event,
                ulAllocatedPooledResourcesData_activeUlSubcellsList,
                ulAllocatedPooledResourcesData_activeUlSubcellCountARM,
                ulMetricIndData_gbrPrbDemand_event,
                ulMetricIndData_nonGbrPrbDemand_event,
                ulMetricIndData_rrmAvgSpectralEffSlot_event,
                ulMetricIndData_avgLoadNonGbr_event,
                ulAllocatedPooledResourcesData_allocStreamPrbGbrUl,
                ulAllocatedPooledResourcesData_allocStreamPrbNonGbrUl]]).dropna(
        subset=[
            ulAllocatedPooledResourcesData_numAllocCellPrbUl_event,
            ulAllocatedPooledResourcesData_activeUlSubcellsList,
            ulAllocatedPooledResourcesData_activeUlSubcellCountARM,
            ulMetricIndData_gbrPrbDemand_event,
            ulMetricIndData_nonGbrPrbDemand_event,
            ulMetricIndData_rrmAvgSpectralEffSlot_event,
            ulMetricIndData_avgLoadNonGbr_event,
            ulAllocatedPooledResourcesData_allocStreamPrbGbrUl,
            ulAllocatedPooledResourcesData_allocStreamPrbNonGbrUl
        ], how='all').reset_index(drop=True)

    filtered_df.rename(columns={
        'sfn': 'sfn',
        'slot': 'Slot',
        'subcellid': 'SubcellID',
        ulAllocatedPooledResourcesData_numAllocCellPrbUl_event: 'numAllocCellPrbUl',
        ulAllocatedPooledResourcesData_activeUlSubcellsList: 'activeUlSubcellsList',
        ulAllocatedPooledResourcesData_activeUlSubcellCountARM: 'activeUlSubcellCountARM',
        ulMetricIndData_gbrPrbDemand_event: 'gbrPrbDemand',
        ulMetricIndData_nonGbrPrbDemand_event: 'nonGbrPrbDemand',
        ulMetricIndData_rrmAvgSpectralEffSlot_event: 'rrmAvgSpectralEffSlot',
        ulMetricIndData_avgLoadNonGbr_event: 'avgLoadNonGbr',
        ulAllocatedPooledResourcesData_allocStreamPrbGbrUl: 'allocStreamPrbGbrUl',
        ulAllocatedPooledResourcesData_allocStreamPrbNonGbrUl: 'allocStreamPrbNonGbrUl'
    }, inplace=True)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path


@log_begin_end_func_name
def verify_TTITraces_for_DL_Pooling(path_to_pickle,
                                    name='ul_df_for_manual_analysis_all_subcells_DL_Pooling'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_DL_Pooling.pkl'
    filter_valid_events_and_check_DL_Pooling(path_to_pickle=path_to_ttitrace_pkl,
                                             target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe_from_pickle(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def filter_valid_events_and_check_DL_Pooling(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for UL pooling Check and
        saves it into a new pickle to be used by other functions

        :param path_to_pickle: Path of input pickle file
        :param target_pkl_path: Path of new target pickle file

        :returns: target_pkl_path
    """
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    pd.reset_option('^display.')

    # TTI Trace Events
    dlAllocatedPooledResourcesData_numAllocCellPrbDl_event = 'dlAllocatedPooledResourcesData.numAllocCellPrbDl'
    dlAllocatedPooledResourcesData_activeDlSubcellsList = 'dlAllocatedPooledResourcesData.activeDlSubcellsList'
    dlAllocatedPooledResourcesData_activeDlSubcellCountARM = 'dlAllocatedPooledResourcesData.activeDlSubcellCountARM'
    dlMetricIndData_gbrPrbDemand_event = 'dlMetricIndData.metricIndData.gbrPrbDemand'
    dlMetricIndData_nonGbrPrbDemand_event = 'dlMetricIndData.metricIndData.nonGbrPrbDemand'
    dlMetricIndData_rrmAvgSpectralEffSlot_event = 'dlMetricIndData.metricIndData.rrmAvgSpectralEffSlot'
    dlMetricIndData_avgLoadNonGbr_event = 'dlMetricIndData.metricIndData.avgLoadNonGbr'
    dlAllocatedPooledResourcesData_allocStreamPrbGbrDl = 'dlAllocatedPooledResourcesData.allocStreamPrbGbrDl'
    dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl = 'dlAllocatedPooledResourcesData.allocStreamPrbNonGbrDl'

    filtered_df = (
        df.loc[(df['rnti'] != 65535),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                dlAllocatedPooledResourcesData_numAllocCellPrbDl_event,
                dlAllocatedPooledResourcesData_activeDlSubcellsList,
                dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
                dlMetricIndData_gbrPrbDemand_event,
                dlMetricIndData_nonGbrPrbDemand_event,
                dlMetricIndData_rrmAvgSpectralEffSlot_event,
                dlMetricIndData_avgLoadNonGbr_event,
                dlAllocatedPooledResourcesData_allocStreamPrbGbrDl,
                dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl]]).dropna(
        subset=[
            dlAllocatedPooledResourcesData_numAllocCellPrbDl_event,
            dlAllocatedPooledResourcesData_activeDlSubcellsList,
            dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
            dlMetricIndData_gbrPrbDemand_event,
            dlMetricIndData_nonGbrPrbDemand_event,
            dlMetricIndData_rrmAvgSpectralEffSlot_event,
            dlMetricIndData_avgLoadNonGbr_event,
            dlAllocatedPooledResourcesData_allocStreamPrbGbrDl,
            dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl
        ], how='all').reset_index(drop=True)

    filtered_df.rename(columns={
        'sfn': 'sfn',
        'slot': 'Slot',
        'subcellid': 'SubcellID',
        dlAllocatedPooledResourcesData_numAllocCellPrbDl_event: 'numAllocCellPrbDl',
        dlAllocatedPooledResourcesData_activeDlSubcellsList: 'activeDlSubcellsList',
        dlAllocatedPooledResourcesData_activeDlSubcellCountARM: 'activeDlSubcellCountARM',
        dlMetricIndData_gbrPrbDemand_event: 'gbrPrbDemand',
        dlMetricIndData_nonGbrPrbDemand_event: 'nonGbrPrbDemand',
        dlMetricIndData_rrmAvgSpectralEffSlot_event: 'rrmAvgSpectralEffSlot',
        dlMetricIndData_avgLoadNonGbr_event: 'avgLoadNonGbr',
        dlAllocatedPooledResourcesData_allocStreamPrbGbrDl: 'allocStreamPrbGbrDl',
        dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl: 'allocStreamPrbNonGbrDl'
    }, inplace=True)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    global pd
    pd = pandas_gate.install_and_import_pandas()
    # test_csv_PDSCH_prb_blanking_overlap_analysis_From_PCAP()
    # test_prb_blanking_analysis_pcap_dl()
    test_csv_puschreceivereq()
