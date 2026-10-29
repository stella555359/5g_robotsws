import math
import logging

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from taf.config.scf import scf
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

import testsuite.Paris.resources.SWENG.python.TtiTrace.pandas_gate as pandas_gate
from testsuite.Paris.RRM.ET.resources.DSS.python.tti_analysis.dtx import get_dtx_stats
from testsuite.Paris.RRM.ET.resources.DSS.python.tti_analysis.mumimo import get_mumimo_stats, \
    generate_rank_stats, generate_subcellId_stats
from testsuite.Paris.RRM.ET.resources.DSS.python.tti_analysis.ue_cell_identification import identify_cells_and_ues
from testsuite.Paris.RRM.ET.resources.DSS.python.tti_analysis.check_nack import\
    filter_valid_events_and_check_acknack_retx

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]


logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console(
            "  %s: exception happened (see log.html)" % functionNameStr)


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def is_string_empty_or_none(my_string):
    return my_string is None or len(my_string) == 0


def get_sfn_column(row_from_list):
    sfn_column = 0
    for i, element in enumerate(row_from_list):
        if element.isdigit():
            sfn_column = i
            break
    return sfn_column


def getValue(scfObj, pName, distName):
    outString = ""
    logging.info("getValue(): pName = %s" % pName)
    logging.info("getValue(): outString = %s" % outString)
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("getValue(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("getValue", e)
    return outString


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


def verify_SCF_Paramaters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB009915 feature should get activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # scfFilePath = BuiltIn().run_keyword(
    #    "CB009915-C-Keywords.Get Testcase Log Directory") + "/SCF.xml"
    # BuiltIn().log("verifyFeatureActivation: scfFilePath = %s (SCF)" % scfFilePath)
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_bts = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id)
    mr_nr_cell_cell1 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-1'
    mr_nr_cell_cell2 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-2'
    try:
        expected_scf_list = [{'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell2},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell2}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    rbi.should_be_true(is_SCF_correct)


def load_dataframe(path_to_pickle):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


def get_dtx_statistics_physCellId_ul(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


def get_dtx_statistics_rnti_ul(filename):
    is_TTITrace_correct = False
    isPassed = True
    output = ""
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='rnti', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
        isPassed = False
    return output


def get_dtx_statistics_lcrId_ul(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='lcrId', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


def get_dtx_statistics_physCellId_dl(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='dl')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='dl')
        logging.info("combined_mumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_dl", e)
    return combined_mumimo_stats, mumimo_stats


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='ul')
        logging.info("combined_ulmumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_ul", e)
    return combined_mumimo_stats, mumimo_stats


def get_cells_and_ues_physCellId(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = identify_cells_and_ues(df)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_cells_and_ues_physCellId", e)
    return output


@log_begin_end_func_name
def get_rank_statistics_rnti_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='dl')
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_dl", e)
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_rank_statistics_rnti_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='ul')
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_ul", e)
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df, by='physCellId', direction='dl')
        logging.info("combined_dl_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_dl", e)
    return combined_subcell_stats, subcell_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df, by='physCellId', direction='ul')
        logging.info("combined_ul_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_ul", e)
    return combined_subcell_stats, subcell_stats


@log_begin_end_func_name
def get_directory(path):
    path_tmp = path.split("/")
    path = "/".join(path_tmp[:-1])
    return path


@log_begin_end_func_name
def filter_dataframe_ul(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulTdSchedSubcellData.subcellId',
                               'ulTdSchedSubcellData.numAllocCellPrbUl', 'lcrId']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlTdSchedSubcellData.subcellId',
                               'dlTdSchedSubcellData.numAllocCellPrbDl', 'lcrId']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_mumimo_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlFdSchedData.subcellId',
                               'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers',
                               'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_mumimo_ul(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulFdSchedData.subcellId',
                               'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers',
                               'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def drop_head_tail_entries(df, num=1000):
    """Function drops num entries from the beginning and the end of the dataframe to compensate for the
    abnormalities seen in trace during start and stop of traffic"""
    df = df[num:-num]
    return df


@log_begin_end_func_name
def prepare_df_to_compute_mumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_ulmumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


def return_only_rbgsize_pdsch(chBW=273, ConfigType=1):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    return rbgsize


def cal_num_of_pdsch(chBW, ConfigType, nbrOfBlankedPRBsHighEdgeDL=0, nbrOfBlankedPRBsLowEdgeDL=0, w_debug=0):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    rat0bitmap = [rbgsize for i in range(chBW//rbgsize)]
    rat0bitmap.append(chBW % rbgsize)
    rat0bitmap_full = rat0bitmap
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsHighEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsHighEdgeDL))
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsLowEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsLowEdgeDL))
    msg = 'cal_num_of_pdsch: rat0bitmap'
    if w_debug:
        datedConsole(getHeaderLine(msg, rat0bitmap_full))
    if nbrOfBlankedPRBsHighEdgeDL != 0 or nbrOfBlankedPRBsLowEdgeDL != 0:
        x = 0
        y = 0
        if w_debug:
            datedConsole(getHeaderLine('Instrum1 '+msg, rat0bitmap[-1]))
        res = nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1]
        if w_debug:
            datedConsole(getHeaderLine('Instrum1.1 ' + msg, (res, nbrOfBlankedPRBsHighEdgeDL, rat0bitmap[-1])))
        # if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] <= 0:
        if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] == 0:
            rat0bitmap = rat0bitmap[:-1]
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        elif nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] < 0:
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        else:
            y = math.ceil((nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1])/rbgsize)
            if w_debug:
                datedConsole(getHeaderLine('Instrum3.0 ' + msg, y))
            rat0bitmap = rat0bitmap[:-1-y]
            if w_debug:
                datedConsole(getHeaderLine('Instrum3 ' + msg, rat0bitmap))
        x = math.ceil(nbrOfBlankedPRBsLowEdgeDL/rbgsize)
        rat0bitmap = rat0bitmap[x:]
        if rat0bitmap[-1] == rbgsize:
            usablepdsch = len(rat0bitmap) * rbgsize
        else:
            usablepdsch = len(rat0bitmap[:-1]) * rbgsize + rat0bitmap[-1]
    else:
        usablepdsch = chBW
    msg = '=====> Full rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap_full))
    msg = '=====> Full NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap_full)))
    msg = '=====> Usable rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap))
    msg = '=====> Usable NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap)))
    msg = '=====> Usable PRB PDSCH'
    datedConsole(getHeaderLine(msg, usablepdsch))
    return chBW, rat0bitmap_full, usablepdsch, rat0bitmap


@log_begin_end_func_name
def verify_TTITraces_for_acknack_retx(path_to_pickle):
    filter_valid_events_and_check_acknack_retx(path_to_pickle=path_to_pickle)


@log_begin_end_func_name
def prepare_df_to_compute_mumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_ulmumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
